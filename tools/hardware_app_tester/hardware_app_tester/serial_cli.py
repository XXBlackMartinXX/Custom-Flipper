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

    def __init__(self, serial_connection, default_timeout: float = 5.0):
        """`serial_connection` is expected to be a pyserial-compatible
        object (or, in unit tests, a fake with matching read/write/
        readline methods) - never constructed by this class itself, so
        tests can inject a fake transport with no real hardware.
        """
        self._conn = serial_connection
        self.default_timeout = default_timeout

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
                continue
            text = raw.decode("utf-8", errors="replace").rstrip("\r\n")
            if text.endswith(self.PROMPT.strip()):
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
