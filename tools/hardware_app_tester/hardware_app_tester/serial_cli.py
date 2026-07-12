"""Line-based Flipper Zero CLI client over a serial port.

This is real, intended-to-work code written against the documented
Flipper Zero CLI (the same interface exposed by a terminal program
connected to the device's serial port).

REAL WINDOWS EVIDENCE (Gate A serial-transport-hardening phase): a real
run on Windows against a real Flipper Zero (COM6, exact normal-mode USB
identity confirmed, no ambiguity, no port contention) reached Phase F -
Read-only device handshake - and the handshake subprocess did not exit
within a 30-second external watchdog: no stdout, no stderr,
serial_handshake.json never created, exit code 124 (killed). Because
`cmd_handshake()` only ever prints/writes evidence once, at the very
end, after the *entire* uptime/loader/free sequence returns, this is
consistent with a hang somewhere inside the very first `cli.uptime()`
call - but it could not be conclusively isolated to write(), the read
loop, or the port-open call itself from this development sandbox, which
has no Windows machine and no physical Flipper Zero. Rather than guess,
this module now (a) bounds every I/O call that could previously block
without limit, and (b) hands the caller (cli.py) enough per-stage,
per-response detail (see CliResponse below) that the *next* real run
will pinpoint the exact stage even if it blocks again.

Two concrete defects were fixed, either of which is independently
capable of causing exactly the observed symptom:

1. `self._conn.write(...)` was called with no bound at all - a real
   pyserial `Serial` object defaults `write_timeout=None` (block
   forever) unless explicitly set, and the previous
   `_open_real_serial_connection()` never set it. If the OS/driver-level
   TX buffer could not drain (e.g. a flow-control mismatch, or simply
   the device not reading), `write()` could hang indefinitely with the
   read loop never even being reached - matching the observed empty
   stdout/stderr exactly, since nothing is printed until `_emit()` runs
   at the very end.
2. The read loop depended on `readline()`, which requires the far end
   to terminate its prompt line with a line ending `readline()`
   recognizes. If the real device's `>: ` prompt is not itself
   `\r\n`-terminated (unverified against real wire output before this
   phase), `readline()` could return an empty/partial fragment forever,
   never assembling a complete "line", and - depending on the
   underlying transport's read-timeout semantics - potentially
   contribute to the same class of stall.

Both are fixed here: `write_timeout` is now validated and enforced
end-to-end (see MAX_ACCEPTABLE_WRITE_TIMEOUT), and prompt detection is
now a raw-byte substring search (`sync_to_prompt()`/`send_command()`)
that tolerates CRLF, LF, no final line ending, fragmentation across
reads, and a banner preceding the prompt - see Part 2/3 of the Gate A
serial-transport-hardening mission for the full requirement list.

This module contains NO flash, update, repair, erase, or format
command, and no function in this file may send one - that is a design
invariant checked by tests/test_no_destructive_capability.py.
"""

from __future__ import annotations

import time
from dataclasses import dataclass, field
from typing import List, Optional, Tuple

try:
    from serial import SerialException as _SerialException
    from serial import SerialTimeoutException as _SerialTimeoutException
except ImportError:  # pragma: no cover - pyserial is a pinned project dependency

    class _SerialException(Exception):
        pass

    class _SerialTimeoutException(_SerialException):
        pass

# Order matters: SerialTimeoutException IS-A SerialException, so the
# write-timeout tuple is always checked first (more specific) wherever
# both are used in an except chain below.
_WRITE_TIMEOUT_EXCEPTIONS: Tuple[type, ...] = (_SerialTimeoutException,)
_DISCONNECT_EXCEPTIONS: Tuple[type, ...] = (_SerialException, OSError)

FORBIDDEN_COMMAND_PREFIXES = (
    "storage format",
    "update install",
    "update",  # covers "update install", firmware self-update commands
)


class ForbiddenCommandError(RuntimeError):
    pass


class TransportStage:
    """The exact, mutually-distinguishable outcomes of one bounded
    transport operation (a single command, or the prompt-sync routine).
    Deliberately plain string constants (not an enum) so they serialize
    directly into JSON evidence without a converter.
    """

    WRITE_TIMEOUT = "WRITE_TIMEOUT"
    READ_TIMEOUT = "READ_TIMEOUT"
    PROMPT_NOT_FOUND = "PROMPT_NOT_FOUND"
    SERIAL_DISCONNECTED = "SERIAL_DISCONNECTED"
    DECODE_WARNING = "DECODE_WARNING"
    COMMAND_COMPLETED = "COMMAND_COMPLETED"

    #: Stages that represent a genuinely completed round trip (a real
    #: response was obtained), as opposed to every other stage, which
    #: means transport state is uncertain and the caller must not
    #: proceed to a subsequent command.
    OK_STAGES = (COMMAND_COMPLETED, DECODE_WARNING)


def _sanitize_bytes(data: bytes, max_len: int = 2000) -> str:
    """A JSON-safe, human-readable representation of raw bytes for
    evidence files - never raises, never silently drops bytes (each
    undecodable byte becomes a visible `\\xNN` escape via
    `backslashreplace`), and is truncated (with a marker) rather than
    producing an unbounded evidence file for a runaway stream.
    """
    text = data.decode("utf-8", errors="backslashreplace")
    if len(text) > max_len:
        return text[:max_len] + f"...<truncated, {len(data)} raw bytes total>"
    return text


def _decode_leniently(data: bytes) -> Tuple[str, bool]:
    """Returns (decoded_text, had_invalid_utf8). Never raises - invalid
    bytes are preserved (visibly, via backslashreplace) rather than
    silently dropped or crashing the read loop.
    """
    try:
        data.decode("utf-8")
        return data.decode("utf-8"), False
    except UnicodeDecodeError:
        return data.decode("utf-8", errors="backslashreplace"), True


def _split_nonempty_lines(text: str) -> List[str]:
    normalized = text.replace("\r\n", "\n").replace("\r", "\n")
    return [line for line in normalized.split("\n") if line != ""]


@dataclass
class CliResponse:
    command: str
    lines: List[str]
    timed_out: bool
    #: One of TransportStage's constants - the authoritative, precise
    #: outcome of this operation. `timed_out` is kept (and derived from
    #: this) purely for backward compatibility with existing callers.
    stage: str = TransportStage.COMMAND_COMPLETED
    raw_byte_count: int = 0
    raw_bytes_sanitized: str = ""
    decode_warning: bool = False
    exception_type: Optional[str] = None
    exception_message: Optional[str] = None
    elapsed_ms: float = 0.0


class FlipperCliClient:
    """Thin wrapper over a pyserial Serial object implementing the
    Flipper Zero line-based CLI protocol: a command is a line of text
    terminated by CRLF, and the device echoes a `>: ` prompt when ready
    for the next command.

    Every I/O operation this class performs is bounded: writes cannot
    block past the connection's own `write_timeout`, and the read loop
    re-checks its own deadline on every iteration regardless of the
    connection's per-call `timeout`. Prompt detection is a raw-byte
    substring search, not a `readline()`-framed comparison, so it
    tolerates CRLF, LF, no final line ending, and fragmentation.
    """

    PROMPT = ">: "

    #: Hardening fix (found during the Gate A Windows-execution audit):
    #: the read loop in send_command() re-checks its own deadline only
    #: *between* calls to the connection's own read - if the
    #: connection's own per-call timeout is None/0 (block-forever), a
    #: single read call can hang indefinitely and the deadline is never
    #: re-evaluated. A real pyserial Serial object with no explicit
    #: timeout defaults to blocking reads. This constant is the maximum
    #: per-call read timeout this client will accept on construction.
    MAX_ACCEPTABLE_CONNECTION_TIMEOUT = 1.0

    #: Same rationale, for `write_timeout` (Gate A serial-transport-
    #: hardening phase): a real pyserial Serial object defaults
    #: `write_timeout=None` (block forever) unless explicitly set. This
    #: is the maximum per-call write timeout this client will accept.
    MAX_ACCEPTABLE_WRITE_TIMEOUT = 1.0

    def __init__(self, serial_connection, default_timeout: float = 5.0):
        """`serial_connection` is expected to be a pyserial-compatible
        object (or, in unit tests, a fake with matching read/write/
        in_waiting methods) - never constructed by this class itself,
        so tests can inject a fake transport with no real hardware.

        Fails closed (raises ValueError) if the connection's own
        `.timeout` or `.write_timeout` attribute is present but missing,
        None, 0, or larger than the respective MAX_ACCEPTABLE_*
        constant - this is what prevents send_command()'s read loop, and
        now its write, from hanging indefinitely on a misconfigured
        connection. A fake test transport with no `.timeout`/
        `.write_timeout` attribute at all is exempted (only an
        explicitly-present, bad value is rejected) - see
        _validate_read_timeout/_validate_write_timeout for the exact
        rule. Real pyserial `Serial` objects always have both
        attributes (write_timeout defaults to None if not passed to the
        constructor), so this exemption only ever applies to
        deliberately minimal test fakes.
        """
        self._validate_read_timeout(serial_connection)
        self._validate_write_timeout(serial_connection)
        self._conn = serial_connection
        self.default_timeout = default_timeout

    @classmethod
    def _validate_read_timeout(cls, serial_connection) -> None:
        if not hasattr(serial_connection, "timeout"):
            return
        conn_timeout = serial_connection.timeout
        if conn_timeout is None or conn_timeout <= 0:
            raise ValueError(
                "Refusing to construct FlipperCliClient: the serial "
                "connection's own .timeout is "
                f"{conn_timeout!r} (block-forever). Construct the "
                "connection with a finite timeout "
                f"(<= {cls.MAX_ACCEPTABLE_CONNECTION_TIMEOUT}s recommended) "
                "so send_command()'s read loop cannot hang indefinitely."
            )
        if conn_timeout > cls.MAX_ACCEPTABLE_CONNECTION_TIMEOUT:
            raise ValueError(
                "Refusing to construct FlipperCliClient: the serial "
                f"connection's own .timeout is {conn_timeout}s, which "
                f"exceeds the maximum accepted "
                f"{cls.MAX_ACCEPTABLE_CONNECTION_TIMEOUT}s - a large "
                "per-call timeout would make send_command()'s own "
                "deadline enforcement too coarse."
            )

    @classmethod
    def _validate_write_timeout(cls, serial_connection) -> None:
        if not hasattr(serial_connection, "write_timeout"):
            return
        write_timeout = serial_connection.write_timeout
        if write_timeout is None or write_timeout <= 0:
            raise ValueError(
                "Refusing to construct FlipperCliClient: the serial "
                "connection's own .write_timeout is "
                f"{write_timeout!r} (block-forever). This is exactly the "
                "defect identified during the Gate A serial-transport-"
                "hardening phase: a real pyserial Serial object defaults "
                "write_timeout=None unless explicitly set, which can make "
                "write() hang indefinitely with no read loop ever "
                f"reached. Construct the connection with a finite "
                f"write_timeout (<= {cls.MAX_ACCEPTABLE_WRITE_TIMEOUT}s "
                "recommended)."
            )
        if write_timeout > cls.MAX_ACCEPTABLE_WRITE_TIMEOUT:
            raise ValueError(
                "Refusing to construct FlipperCliClient: the serial "
                f"connection's own .write_timeout is {write_timeout}s, "
                f"which exceeds the maximum accepted "
                f"{cls.MAX_ACCEPTABLE_WRITE_TIMEOUT}s."
            )

    def _assert_not_forbidden(self, command: str) -> None:
        normalized = command.strip().lower()
        for prefix in FORBIDDEN_COMMAND_PREFIXES:
            if normalized.startswith(prefix):
                raise ForbiddenCommandError(
                    f"Refusing to send forbidden command: {command!r}"
                )

    def _read_available_bytes(self, max_chunk: int = 4096) -> bytes:
        """Bounded raw-byte read: prefers `in_waiting` (real pyserial and
        the raw test fakes both support it) to read exactly what is
        already available in one call; falls back to a single `read(1)`
        call (itself bounded by the connection's own `.timeout`) for any
        transport that does not expose `in_waiting`. Never calls
        `readline()` - prompt detection here does not depend on the far
        end's line-ending convention.
        """
        in_waiting = getattr(self._conn, "in_waiting", None)
        if in_waiting:
            return self._conn.read(min(in_waiting, max_chunk))
        return self._conn.read(1)

    def _write_bounded(self, payload: bytes) -> Optional[CliResponse]:
        """Performs one bounded write. Returns None on success, or a
        fully-formed CliResponse (WRITE_TIMEOUT or SERIAL_DISCONNECTED)
        if the write itself failed - callers return that response
        immediately rather than proceeding to a read loop with the
        command never having been sent.
        """
        try:
            self._conn.write(payload)
        except _WRITE_TIMEOUT_EXCEPTIONS as exc:
            return self._make_response("", [], TransportStage.WRITE_TIMEOUT, b"", exc, 0.0)
        except _DISCONNECT_EXCEPTIONS as exc:
            return self._make_response("", [], TransportStage.SERIAL_DISCONNECTED, b"", exc, 0.0)
        return None

    @staticmethod
    def _make_response(
        command: str,
        lines: List[str],
        stage: str,
        raw: bytes,
        exc: Optional[Exception],
        elapsed_ms: float,
        decode_warning: bool = False,
    ) -> CliResponse:
        return CliResponse(
            command=command,
            lines=lines,
            timed_out=(stage not in TransportStage.OK_STAGES),
            stage=stage,
            raw_byte_count=len(raw),
            raw_bytes_sanitized=_sanitize_bytes(raw),
            decode_warning=decode_warning,
            exception_type=type(exc).__name__ if exc is not None else None,
            exception_message=str(exc) if exc is not None else None,
            elapsed_ms=elapsed_ms,
        )

    def sync_to_prompt(self, timeout: float = 3.0, settle_seconds: float = 0.05) -> CliResponse:
        """Raw-byte CLI prompt synchronization - Part 2 of the Gate A
        serial-transport-hardening mission. Intended to be called
        exactly once, immediately after opening the port and before any
        command is sent:

        1. (Port is already open by the time this is called.)
        2/9. Bounded by `timeout` overall - never blocks past it.
        3. Waits `settle_seconds` for the USB serial interface to settle.
        4. Captures any already-available banner/prompt bytes first,
           before sending anything.
        5. Sends only a harmless blank line (b"\\r\\n") to request the
           prompt - never an application-launch or destructive command.
        6. Reads bounded chunks via `_read_available_bytes()`.
        7. Detects the prompt as a raw-byte substring match (tolerates
           CRLF/LF/no trailing newline, fragmentation, and a preceding
           banner) - never accepts an arbitrary substring, only the
           exact `PROMPT` text (">: ").
        8. All raw bytes seen are preserved in the returned CliResponse.
        10. Never sends anything other than the one blank line above.
        """
        start = time.monotonic()
        time.sleep(settle_seconds)

        buffer = bytearray()
        deadline = start + timeout

        # Step 4: capture whatever the device already sent unsolicited
        # (a banner, or even a stale prompt) before requesting anything.
        try:
            initial = self._read_available_bytes()
        except _DISCONNECT_EXCEPTIONS as exc:
            return self._make_response(
                "<prompt-sync>", [], TransportStage.SERIAL_DISCONNECTED, bytes(buffer), exc,
                (time.monotonic() - start) * 1000,
            )
        if initial:
            buffer.extend(initial)
            text, decode_warning = _decode_leniently(bytes(buffer))
            if self.PROMPT in text:
                stage = TransportStage.DECODE_WARNING if decode_warning else TransportStage.COMMAND_COMPLETED
                return self._make_response(
                    "<prompt-sync>", [], stage, bytes(buffer), None,
                    (time.monotonic() - start) * 1000, decode_warning=decode_warning,
                )

        # Step 5: request the prompt with a harmless blank line only.
        write_failure = self._write_bounded(b"\r\n")
        if write_failure is not None:
            write_failure.raw_byte_count = len(buffer)
            write_failure.raw_bytes_sanitized = _sanitize_bytes(bytes(buffer))
            write_failure.elapsed_ms = (time.monotonic() - start) * 1000
            return write_failure

        while time.monotonic() < deadline:
            try:
                chunk = self._read_available_bytes()
            except _DISCONNECT_EXCEPTIONS as exc:
                return self._make_response(
                    "<prompt-sync>", [], TransportStage.SERIAL_DISCONNECTED, bytes(buffer), exc,
                    (time.monotonic() - start) * 1000,
                )
            if not chunk:
                time.sleep(0.01)
                continue
            buffer.extend(chunk)
            text, decode_warning = _decode_leniently(bytes(buffer))
            if self.PROMPT in text:
                stage = TransportStage.DECODE_WARNING if decode_warning else TransportStage.COMMAND_COMPLETED
                return self._make_response(
                    "<prompt-sync>", [], stage, bytes(buffer), None,
                    (time.monotonic() - start) * 1000, decode_warning=decode_warning,
                )

        stage = TransportStage.READ_TIMEOUT if not buffer else TransportStage.PROMPT_NOT_FOUND
        return self._make_response(
            "<prompt-sync>", [], stage, bytes(buffer), None, (time.monotonic() - start) * 1000,
        )

    def send_command(
        self, command: str, timeout: Optional[float] = None
    ) -> CliResponse:
        """Sends one line of CLI text and reads raw bytes until the next
        prompt or timeout. Never sends a command matching
        FORBIDDEN_COMMAND_PREFIXES.

        Refactored (Gate A serial-transport-hardening phase) to: bound
        the write itself (previously unbounded - see this module's
        docstring), buffer and search raw bytes for the prompt instead
        of depending on `readline()`'s line framing, preserve whatever
        partial response was received on a timeout (never discarded),
        and distinguish WRITE_TIMEOUT / READ_TIMEOUT / PROMPT_NOT_FOUND
        / SERIAL_DISCONNECTED / DECODE_WARNING / COMMAND_COMPLETED
        explicitly via CliResponse.stage.
        """
        self._assert_not_forbidden(command)
        effective_timeout = timeout if timeout is not None else self.default_timeout
        start = time.monotonic()

        write_failure = self._write_bounded((command + "\r\n").encode("utf-8"))
        if write_failure is not None:
            write_failure.command = command
            write_failure.elapsed_ms = (time.monotonic() - start) * 1000
            return write_failure

        buffer = bytearray()
        deadline = time.monotonic() + effective_timeout
        while time.monotonic() < deadline:
            try:
                chunk = self._read_available_bytes()
            except _DISCONNECT_EXCEPTIONS as exc:
                lines = _split_nonempty_lines(_decode_leniently(bytes(buffer))[0])
                return self._make_response(
                    command, lines, TransportStage.SERIAL_DISCONNECTED, bytes(buffer), exc,
                    (time.monotonic() - start) * 1000,
                )
            if not chunk:
                # No data available within the connection's own
                # per-call timeout - avoid a tight busy-spin while
                # waiting for the outer deadline.
                time.sleep(0.01)
                continue
            buffer.extend(chunk)
            text, decode_warning = _decode_leniently(bytes(buffer))
            if self.PROMPT in text:
                before_prompt = text.split(self.PROMPT, 1)[0]
                lines = _split_nonempty_lines(before_prompt)
                stage = TransportStage.DECODE_WARNING if decode_warning else TransportStage.COMMAND_COMPLETED
                return self._make_response(
                    command, lines, stage, bytes(buffer), None,
                    (time.monotonic() - start) * 1000, decode_warning=decode_warning,
                )

        # Deadline reached without finding the prompt - preserve
        # whatever partial response was received rather than discarding
        # it (Part 3's "partial-response preservation on timeout").
        text, _decode_warning = _decode_leniently(bytes(buffer))
        lines = _split_nonempty_lines(text)
        stage = TransportStage.READ_TIMEOUT if not buffer else TransportStage.PROMPT_NOT_FOUND
        return self._make_response(
            command, lines, stage, bytes(buffer), None, (time.monotonic() - start) * 1000,
        )

    def loader_list(self) -> CliResponse:
        return self.send_command("loader list")

    def loader_open(self, target: str) -> CliResponse:
        """`target` is either a built-in app name (e.g. "2048") or an
        external .fap path (e.g. "/ext/apps/Games/2048.fap"). This is
        the only launch mechanism this client exposes - it never
        constructs or sends any update/install/flash-related command.
        """
        self._assert_not_forbidden(f"loader open {target}")
        return self.send_command(f"loader open {target}")

    def loader_info(self) -> CliResponse:
        return self.send_command("loader info")

    def loader_close(self) -> CliResponse:
        return self.send_command("loader close")

    def uptime(self) -> CliResponse:
        return self.send_command("uptime")

    def free_heap(self) -> CliResponse:
        return self.send_command("free")

    def device_info(self) -> CliResponse:
        return self.send_command("device_info")

    def log_tail(self, timeout: float = 1.0) -> CliResponse:
        """Best-effort capture of any log lines emitted spontaneously
        (e.g. from `log` if enabled), not a specific command - callers
        should have already issued `log` mode separately if needed.
        """
        return self.send_command("", timeout=timeout)
