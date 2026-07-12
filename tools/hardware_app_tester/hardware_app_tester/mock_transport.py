"""Synthetic, in-process serial transports for developer regression
testing - never a source of real hardware evidence.

Any result produced using these transports MUST be labeled
`"hardware_execution": "NOT PERFORMED"` by the caller and must never be
promoted to, or confused with, a real Gate A hardware classification.
cli.py enforces this by prefixing every status with `MOCK -` when
`--mock` is used.

This module contains two transports:

- `FakeSerialConnection` - the original, line-scripted fake used by
  `--mock` mode and the existing hardening test suite. Upgraded (Gate A
  serial-transport-hardening phase) to also expose the raw-byte
  `read()`/`in_waiting` interface FlipperCliClient's hardened
  send_command()/sync_to_prompt() now use, while preserving `readline()`
  for any caller still using it - the observable behavior for every
  pre-existing test using this class is unchanged.
- `FakeRawSerialConnection` - a new, lower-level fake purpose-built for
  the serial-transport-hardening regression tests: fragmented reads,
  no-newline prompts, injected write-timeout/disconnection, and delayed
  (multi-poll) responses, with the exact raw bytes preserved and
  inspectable via `.written`.
"""

from __future__ import annotations

from typing import List, Optional

try:
    from serial import SerialException as _SerialException
    from serial import SerialTimeoutException as _SerialTimeoutException
except ImportError:  # pragma: no cover - pyserial is a pinned project dependency

    class _SerialException(Exception):
        pass

    class _SerialTimeoutException(_SerialException):
        pass


class FakeSerialConnection:
    """A minimal fake matching the subset of pyserial's Serial interface
    FlipperCliClient actually uses. Scripted responses are queued per-
    command by exact match on the command text that was written; an
    unscripted command returns no bytes (times out), which is the safe,
    honest default rather than guessing a plausible-looking response.
    """

    def __init__(self, timeout: float = 0.2):
        self.timeout = timeout
        self._scripted: dict[str, List[str]] = {}
        self._last_command: Optional[str] = None
        self._buffer = bytearray()
        self.closed = False
        self.written_commands: List[str] = []

    def script(self, command: str, response_lines: List[str]) -> None:
        """Registers the exact response lines (not including the final
        prompt line, which is appended automatically) for one exact
        command string."""
        self._scripted[command] = list(response_lines)

    def write(self, data: bytes) -> int:
        command = data.decode("utf-8").rstrip("\r\n")
        self._last_command = command
        self.written_commands.append(command)
        lines = self._scripted.get(command)
        if lines is None:
            # Unscripted command: no response queued at all - the
            # caller's read loop will time out, exactly like a real
            # device that never answers an unrecognized command.
            return len(data)
        payload = "".join(line + "\r\n" for line in lines) + ">: \r\n"
        self._buffer.extend(payload.encode("utf-8"))
        return len(data)

    @property
    def in_waiting(self) -> int:
        return len(self._buffer)

    def read(self, size: int = 1) -> bytes:
        """Raw-byte read, added during the serial-transport-hardening
        phase so this fake supports FlipperCliClient's hardened,
        readline()-independent read loop. Never blocks (this is a
        synthetic transport) - returns whatever is currently buffered,
        up to `size` bytes, or b"" if nothing is available."""
        if not self._buffer:
            return b""
        n = min(size, len(self._buffer))
        out = bytes(self._buffer[:n])
        del self._buffer[:n]
        return out

    def readline(self) -> bytes:
        """Preserved for any caller still using line-based reads:
        consumes up to and including the next b"\\n", or whatever
        remains if no newline is present."""
        idx = self._buffer.find(b"\n")
        if idx == -1:
            if not self._buffer:
                return b""
            out = bytes(self._buffer)
            self._buffer.clear()
            return out
        out = bytes(self._buffer[: idx + 1])
        del self._buffer[: idx + 1]
        return out

    def close(self) -> None:
        self.closed = True


class FakeRawSerialConnection:
    """Byte-oriented fake transport for the serial-transport-hardening
    regression tests. Supports:

    - fragmented reads: queue several chunks with increasing
      `delay_polls` so the caller's read loop must make multiple
      read()/in_waiting calls before the full response is visible.
    - no-newline prompts: queue bytes with no trailing newline at all.
    - injected write-timeout: `raise_write_timeout_on_next_write()`.
    - injected disconnection: `disconnect_after_reads(n)` /
      `disconnect_on_next_write()`.
    - delayed responses: `delay_polls` on `queue_bytes()`.
    - raw-byte capture: `.written` holds every exact `write()` payload.

    Delays are expressed in "poll counts" (number of read()/in_waiting
    calls), not wall-clock time, so tests remain fast and deterministic
    rather than depending on real sleeps.
    """

    def __init__(self, timeout: float = 0.5, write_timeout: float = 0.5):
        self.timeout = timeout
        self.write_timeout = write_timeout
        self._chunks: List[dict] = []
        self._poll_count = 0
        self._write_count = 0
        self._available = bytearray()
        self.written: List[bytes] = []
        self.closed = False
        self._raise_write_timeout_next = False
        self._raise_write_disconnect_next = False
        self._disconnect_after_reads: Optional[int] = None
        self._read_count = 0

    def queue_bytes(self, data: bytes, delay_polls: int = 0, after_writes: int = 0) -> None:
        """Queues a response chunk. Two independent gates control when it
        actually appears in `_available`:

        - `after_writes`: the chunk is not eligible at all until at
          least this many `write()` calls have occurred - models "the
          device only replies after it has received the corresponding
          request," so a multi-command test (sync, then uptime, then
          loader_info, ...) can give each command its own response
          without an earlier command's still-unconsumed queue entry
          leaking into a later command's read loop.
        - `delay_polls`: once eligible (per the gate above), the chunk
          is held back this many additional read()/in_waiting polls
          before appearing - models fragmentation of one response
          across several reads.
        """
        self._chunks.append(
            {"after_writes": after_writes, "delay_polls": delay_polls, "data": data, "unlocked_at_poll": None}
        )

    def raise_write_timeout_on_next_write(self) -> None:
        self._raise_write_timeout_next = True

    def disconnect_on_next_write(self) -> None:
        self._raise_write_disconnect_next = True

    def disconnect_after_reads(self, n_reads: int) -> None:
        self._disconnect_after_reads = n_reads

    def write(self, data: bytes) -> int:
        if self._raise_write_timeout_next:
            raise _SerialTimeoutException("simulated write timeout - device not draining TX buffer")
        if self._raise_write_disconnect_next:
            raise _SerialException("simulated device disconnect during write")
        self.written.append(bytes(data))
        self._write_count += 1
        return len(data)

    @property
    def in_waiting(self) -> int:
        self._advance_queue()
        return len(self._available)

    def read(self, size: int = 1) -> bytes:
        self._read_count += 1
        if (
            self._disconnect_after_reads is not None
            and self._read_count > self._disconnect_after_reads
        ):
            raise _SerialException("simulated device disconnect during read")
        self._advance_queue()
        if not self._available:
            return b""
        n = min(size, len(self._available))
        out = bytes(self._available[:n])
        del self._available[:n]
        return out

    def readline(self) -> bytes:  # pragma: no cover - not used by hardened client
        self._advance_queue()
        idx = self._available.find(b"\n")
        if idx == -1:
            return b""
        out = bytes(self._available[: idx + 1])
        del self._available[: idx + 1]
        return out

    def _advance_queue(self) -> None:
        self._poll_count += 1
        still_pending = []
        for chunk in self._chunks:
            if self._write_count < chunk["after_writes"]:
                still_pending.append(chunk)
                continue
            if chunk["unlocked_at_poll"] is None:
                chunk["unlocked_at_poll"] = self._poll_count
            if self._poll_count - chunk["unlocked_at_poll"] >= chunk["delay_polls"]:
                self._available.extend(chunk["data"])
            else:
                still_pending.append(chunk)
        self._chunks = still_pending

    def close(self) -> None:
        self.closed = True
