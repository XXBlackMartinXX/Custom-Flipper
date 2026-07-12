"""Best-effort parsers turning FlipperCliClient CLI text responses into
structured values (crash_detection.DeviceStateSnapshot fields).

HONEST STATUS: the exact text format of a real Flipper Zero's `uptime`,
`free`, and `loader info` CLI command output has never been captured or
verified against a real device in this development session (no
Windows machine, no physical Flipper Zero, no serial port here). The
regex patterns below are written from the CLI command names and
general, publicly-documented conventions, not from a captured real
transcript. Every parser in this module returns `None` on anything it
cannot confidently parse - it never guesses a number or invents a
value, and callers must treat a `None` result as "could not verify",
contributing to a `NEEDS_REVIEW` classification, never a fabricated
`PASS`.

The first real hardware run against this tooling should capture the
actual raw CLI text for each of these commands (already planned via
`serial_handshake.json` in the Gate A evidence schema) so these parsers
can be corrected against real output in a follow-up change, rather than
guessed further from here.
"""

from __future__ import annotations

import re
from typing import List, Optional

from .crash_detection import DeviceStateSnapshot
from .serial_cli import CliResponse


def parse_uptime_ms(lines: List[str]) -> Optional[int]:
    """Tries, in order: a bare integer (in case a build prints raw ms/
    ticks), then a `Hh:Mm:Ss`-shaped duration, then `Nd HH:MM:SS`. Returns
    None if no pattern confidently matches - never fabricates a value.
    """
    joined = " ".join(lines)

    bare_int = re.search(r"\buptime\b.*?(\d+)\s*(?:ms|milliseconds)\b", joined, re.I)
    if bare_int:
        return int(bare_int.group(1))

    days_hms = re.search(r"(\d+)\s*d[ay]*\D+(\d{1,2}):(\d{2}):(\d{2})", joined, re.I)
    if days_hms:
        days, hours, minutes, seconds = (int(g) for g in days_hms.groups())
        total_seconds = ((days * 24 + hours) * 60 + minutes) * 60 + seconds
        return total_seconds * 1000

    hms = re.search(r"\b(\d{1,3}):(\d{2}):(\d{2})\b", joined)
    if hms:
        hours, minutes, seconds = (int(g) for g in hms.groups())
        total_seconds = (hours * 60 + minutes) * 60 + seconds
        return total_seconds * 1000

    return None


def parse_free_heap_bytes(lines: List[str]) -> Optional[int]:
    joined = " ".join(lines)
    match = re.search(r"free[^0-9]{0,20}(\d+)\s*bytes", joined, re.I)
    if match:
        return int(match.group(1))
    return None


def parse_loader_state(lines: List[str]) -> Optional[str]:
    """Returns "idle" for anything that looks like "no application
    running", or the raw matched app-name text if something looks like
    "is running". Returns None if neither pattern confidently matches.
    """
    joined = " ".join(lines)
    if re.search(r"not\s+running|no\s+application|idle", joined, re.I):
        return "idle"
    running = re.search(r"([A-Za-z0-9_./-]+)\s+is\s+running", joined, re.I)
    if running:
        return running.group(1)
    return None


class SnapshotParseIssues(list):
    """A plain list subclass so callers can both check truthiness
    (`if issues:`) and get a readable repr for evidence files."""


def build_snapshot(
    uptime_response: CliResponse,
    free_heap_response: CliResponse,
    loader_response: CliResponse,
    usb_present: bool,
) -> "tuple[Optional[DeviceStateSnapshot], SnapshotParseIssues]":
    """Builds a DeviceStateSnapshot from three real CLI responses.
    Returns (None, issues) if any field could not be parsed - the
    caller must treat that as NEEDS_REVIEW, never assume a default.
    """
    issues = SnapshotParseIssues()

    if uptime_response.timed_out:
        issues.append("uptime command timed out")
    uptime_ms = parse_uptime_ms(uptime_response.lines) if not uptime_response.timed_out else None
    if uptime_ms is None and not uptime_response.timed_out:
        issues.append(
            f"could not parse uptime from response lines: {uptime_response.lines!r}"
        )

    if free_heap_response.timed_out:
        issues.append("free heap command timed out")
    free_heap = (
        parse_free_heap_bytes(free_heap_response.lines)
        if not free_heap_response.timed_out
        else None
    )
    if free_heap is None and not free_heap_response.timed_out:
        issues.append(
            f"could not parse free heap from response lines: {free_heap_response.lines!r}"
        )

    if loader_response.timed_out:
        issues.append("loader info command timed out")
    loader_state = (
        parse_loader_state(loader_response.lines)
        if not loader_response.timed_out
        else None
    )
    if loader_state is None and not loader_response.timed_out:
        issues.append(
            f"could not parse loader state from response lines: {loader_response.lines!r}"
        )

    if issues:
        return None, issues

    return (
        DeviceStateSnapshot(
            uptime_ms=uptime_ms,
            free_heap_bytes=free_heap,
            loader_state=loader_state,
            usb_present=usb_present,
        ),
        issues,
    )
