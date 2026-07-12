"""A synthetic, in-process serial transport for developer regression
testing of the CLI orchestration logic (cli.py's `--mock` flag and
this project's own pytest hardening suite) - never a source of real
hardware evidence.

Any result produced using this transport MUST be labeled
`"hardware_execution": "NOT PERFORMED"` by the caller and must never be
promoted to, or confused with, a real Gate A hardware classification.
cli.py enforces this by prefixing every status with `MOCK -` when
`--mock` is used, and this module's own docstring/tests exist to make
that discipline hard to accidentally violate.
"""

from __future__ import annotations

from typing import List, Optional


class FakeSerialConnection:
    """A minimal fake matching the subset of pyserial's Serial interface
    FlipperCliClient actually uses (write/readline/timeout/close).
    Scripted responses are queued per-command by exact match on the
    command text that was written; an unscripted command returns no
    lines (times out), which is the safe, honest default rather than
    guessing a plausible-looking response.
    """

    def __init__(self, timeout: float = 0.2):
        self.timeout = timeout
        self._scripted: dict[str, List[str]] = {}
        self._last_command: Optional[str] = None
        self._pending_lines: List[bytes] = []
        self.closed = False
        self.written_commands: List[str] = []

    def script(self, command: str, response_lines: List[str]) -> None:
        """Registers the exact response lines (not including the final
        prompt line, which is appended automatically) for one exact
        command string."""
        self._scripted[command] = list(response_lines)

    def write(self, data: bytes) -> None:
        command = data.decode("utf-8").rstrip("\r\n")
        self._last_command = command
        self.written_commands.append(command)
        lines = self._scripted.get(command)
        if lines is None:
            # Unscripted command: no response queued at all - the
            # caller's read loop will time out, exactly like a real
            # device that never answers an unrecognized command.
            self._pending_lines = []
            return
        self._pending_lines = [(line + "\r\n").encode("utf-8") for line in lines]
        self._pending_lines.append((">: ").encode("utf-8") + b"\r\n")

    def readline(self) -> bytes:
        if self._pending_lines:
            return self._pending_lines.pop(0)
        return b""

    def close(self) -> None:
        self.closed = True
