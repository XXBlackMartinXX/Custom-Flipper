"""Line-based Flipper Zero CLI client over a serial port.

This is real, intended-to-work code written against the documented
Flipper Zero CLI (the same interface exposed by a terminal program
connected to the device's serial port), but it has never been executed
against a real device in this development session - there is no
Windows machine, no physical Flipper Zero, and no serial port available
in the sandbox this code was authored in. See tools/hardware_app_tester/README.md.

This module contains NO flash, update, repair, erase, or format
command, and no function in this file may send one - that is a design
invariant checked by tests/test_no_destructive_capability.py.

AUDIT FINDING, FIXED (Gate A Windows-execution-package phase): the
original prompt-detection comparison in send_command() never matched a
genuine prompt line even in the best case (a string-stripping bug, not
a hardware issue) - found by building a synthetic mock transport
(hardware_app_tester/mock_transport.py) and verifying the comparison
directly, then fixed and covered by a regression test
(tests/test_serial_cli_hardening.py). This client still assumes the
real device's prompt line is itself terminated with \r\n, since
`readline()`-based reading requires that - this assumption has not been
verified against a real device's actual wire output in this development
session, and the first real handshake run should capture the raw bytes
to confirm or correct it.
"""

from __future__ import annotations

import time
from dataclasses import dataclass
from typing import List, Optional

FORBIDDEN_COMMAND_PREFIXES = (
    "storage format",
    "update install",
    "update",  # covers "update install", firmware self-update commands
)


class ForbiddenCommandError(RuntimeError):
    pass


@dataclass
class CliResponse:
    command: str
    lines: List[str]
    timed_out: bool


class FlipperCliClient:
    """Thin wrapper over a pyserial Serial object implementing the
    Flipper Zero line-based CLI protocol: a command is a line of text
    terminated by CRLF, and the device echoes a `>: ` prompt when ready
    for the next command.
    """

    PROMPT = ">: "

    #: Hardening fix (found during the Gate A Windows-execution audit):
    #: the read loop in send_command() re-checks its own deadline only
    #: *between* calls to serial_connection.readline() - if the
    #: connection's own per-call timeout is None/0 (block-forever),
    #: readline() can hang indefinitely and the deadline is never
    #: re-evaluated. A real pyserial Serial object with no explicit
    #: timeout defaults to blocking reads. This constant is the maximum
    #: per-call timeout this client will accept on construction.
    MAX_ACCEPTABLE_CONNECTION_TIMEOUT = 1.0

    def __init__(self, serial_connection, default_timeout: float = 5.0):
        """`serial_connection` is expected to be a pyserial-compatible
        object (or, in unit tests, a fake with matching read/write/
        readline methods) - never constructed by this class itself, so
        tests can inject a fake transport with no real hardware.

        Fails closed (raises ValueError) if the connection's own
        `.timeout` attribute is missing, None, 0, or larger than
        MAX_ACCEPTABLE_CONNECTION_TIMEOUT - this is what prevents the
        send_command() read loop below from hanging indefinitely on a
        misconfigured connection. A fake test transport with no
        `.timeout` attribute at all is exempted (getattr default None is
        only rejected when the attribute is explicitly present and bad;
        see _validate_connection_timeout for the exact rule).
        """
        self._validate_connection_timeout(serial_connection)
        self._conn = serial_connection
        self.default_timeout = default_timeout

    @classmethod
    def _validate_connection_timeout(cls, serial_connection) -> None:
        if not hasattr(serial_connection, "timeout"):
            # Fake/mock transports in unit tests commonly have no
            # `.timeout` attribute at all - only real pyserial-shaped
            # connections (or fakes that deliberately set one) are
            # checked here.
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

    def _assert_not_forbidden(self, command: str) -> None:
        normalized = command.strip().lower()
        for prefix in FORBIDDEN_COMMAND_PREFIXES:
            if normalized.startswith(prefix):
                raise ForbiddenCommandError(
                    f"Refusing to send forbidden command: {command!r}"
                )

    def send_command(
        self, command: str, timeout: Optional[float] = None
    ) -> CliResponse:
        """Sends one line of CLI text and reads lines until the next
        prompt or timeout. Never sends a command matching
        FORBIDDEN_COMMAND_PREFIXES.
        """
        self._assert_not_forbidden(command)
        effective_timeout = timeout if timeout is not None else self.default_timeout

        self._conn.write((command + "\r\n").encode("utf-8"))

        lines: List[str] = []
        deadline = time.monotonic() + effective_timeout
        timed_out = True
        while time.monotonic() < deadline:
            raw = self._conn.readline()
            if not raw:
                # No data available within the connection's own
                # per-call timeout - avoid a tight busy-spin while
                # waiting for the outer deadline.
                time.sleep(0.01)
                continue
            text = raw.decode("utf-8", errors="replace").rstrip("\r\n")
            # HARDENING FIX (found during the Gate A Windows-execution
            # audit, verified with a real mock-transport regression
            # test): the previous comparison was
            # `text.endswith(self.PROMPT.strip())`. `self.PROMPT.strip()`
            # strips PROMPT's own trailing space, turning ">: " into
            # ">:" - but a genuine prompt line, after only \r\n is
            # stripped from `text`, still ends in ">: " (with the
            # space), so `">: ".endswith(">:")` is False and the real
            # prompt line was NEVER recognized, even in the best case.
            # This would have made every real command time out
            # regardless of how the device actually responded. Fixed to
            # compare the whitespace-trimmed prompt line on both sides.
            if text.strip() == self.PROMPT.strip():
                timed_out = False
                break
            lines.append(text)
        return CliResponse(command=command, lines=lines, timed_out=timed_out)

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
