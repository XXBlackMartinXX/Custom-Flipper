"""Crash and hang detection - pure comparison functions over before/after
device-state snapshots, so this logic is unit-testable without any real
serial connection.

On any detected failure, the caller (test_runner.py) is expected to stop
testing that app, preserve evidence, and never automatically initiate a
DFU or Repair action - this module only classifies; it never acts.
"""

from __future__ import annotations

import dataclasses
from typing import List, Optional


@dataclasses.dataclass(frozen=True)
class DeviceStateSnapshot:
    uptime_ms: int
    free_heap_bytes: int
    loader_state: str
    usb_present: bool


@dataclasses.dataclass(frozen=True)
class CrashCheckResult:
    status: str  # "PASS" | "FAIL - <reason>" | "NEEDS_REVIEW - <reason>"
    detail: str


def check_uptime_continuity(
    before: DeviceStateSnapshot, after: DeviceStateSnapshot
) -> CrashCheckResult:
    """An uptime that goes backwards (or resets near zero) between two
    snapshots taken moments apart indicates an unexpected reboot.
    """
    if after.uptime_ms < before.uptime_ms:
        return CrashCheckResult(
            status="FAIL - UNEXPECTED REBOOT DETECTED",
            detail=(
                f"Uptime decreased from {before.uptime_ms}ms to "
                f"{after.uptime_ms}ms between snapshots - the device "
                "appears to have rebooted unexpectedly."
            ),
        )
    return CrashCheckResult(status="PASS", detail="Uptime is continuous.")


def check_usb_continuity(
    before: DeviceStateSnapshot, after: DeviceStateSnapshot
) -> CrashCheckResult:
    if before.usb_present and not after.usb_present:
        return CrashCheckResult(
            status="FAIL - USB DISAPPEARED",
            detail="USB was present before the test action and absent after it.",
        )
    return CrashCheckResult(status="PASS", detail="USB presence is continuous.")


def check_heap_regression(
    before: DeviceStateSnapshot,
    after: DeviceStateSnapshot,
    maximum_heap_delta: int,
) -> CrashCheckResult:
    delta = before.free_heap_bytes - after.free_heap_bytes
    if delta > maximum_heap_delta:
        return CrashCheckResult(
            status="NEEDS_REVIEW - HEAP DELTA EXCEEDS PROFILE THRESHOLD",
            detail=(
                f"Free heap dropped by {delta} bytes, exceeding this "
                f"app's declared maximum_heap_delta of "
                f"{maximum_heap_delta} bytes. This does not necessarily "
                "mean a leak - the app may not have fully unloaded yet "
                "- but it must be reviewed, not silently accepted."
            ),
        )
    return CrashCheckResult(
        status="PASS",
        detail=f"Heap delta ({delta} bytes) is within the declared threshold.",
    )


def check_loader_returned_to_idle(
    after: DeviceStateSnapshot, expected_idle_state: str = "idle"
) -> CrashCheckResult:
    if after.loader_state != expected_idle_state:
        return CrashCheckResult(
            status="FAIL - LOADER DID NOT RETURN TO IDLE",
            detail=(
                f"Expected loader state '{expected_idle_state}' after "
                f"exit, found '{after.loader_state}' instead - the app "
                "may have refused to close, or the desktop failed to "
                "return."
            ),
        )
    return CrashCheckResult(status="PASS", detail="Loader returned to idle.")


def scan_log_lines_for_panic(log_lines: List[str]) -> CrashCheckResult:
    panic_markers = ("panic", "hardfault", "assert failed", "fatal error")
    for line in log_lines:
        lowered = line.lower()
        for marker in panic_markers:
            if marker in lowered:
                return CrashCheckResult(
                    status="FAIL - PANIC/FAULT LOG DETECTED",
                    detail=f"Log line matched panic marker '{marker}': {line!r}",
                )
    return CrashCheckResult(status="PASS", detail="No panic/fault markers found in logs.")


def evaluate_all(
    before: DeviceStateSnapshot,
    after: DeviceStateSnapshot,
    maximum_heap_delta: int,
    log_lines: Optional[List[str]] = None,
    expected_idle_state: str = "idle",
) -> List[CrashCheckResult]:
    results = [
        check_uptime_continuity(before, after),
        check_usb_continuity(before, after),
        check_heap_regression(before, after, maximum_heap_delta),
        check_loader_returned_to_idle(after, expected_idle_state),
    ]
    if log_lines is not None:
        results.append(scan_log_lines_for_panic(log_lines))
    return results


def any_failed(results: List[CrashCheckResult]) -> bool:
    return any(r.status.startswith("FAIL") for r in results)


def any_needs_review(results: List[CrashCheckResult]) -> bool:
    return any(r.status.startswith("NEEDS_REVIEW") for r in results)
