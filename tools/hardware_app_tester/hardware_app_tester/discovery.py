"""Device discovery: exact VID:PID identity matching, DFU rejection,
ambiguous-multiple-device rejection, and port-contention detection.

Mirrors the enumeration/evaluation separation already proven in
tools/pre_flash_safeguard_gate.ps1: the only function that touches a
real OS API (`list_present_ports`) is kept separate from the pure
classification functions below it, so the classification logic can be
unit-tested with synthetic port descriptors and no real hardware.

Exact identity strings (never a substring/regex match on a friendly
name):
    NORMAL_MODE_VID_PID = "VID_0483&PID_5740" (Windows) / "0483:5740" (pyserial)
    DFU_MODE_VID_PID    = "VID_0483&PID_DF11" (Windows) / "0483:df11" (pyserial)

This module never flashes, updates, repairs, erases, or formats a
device. It only enumerates and classifies already-present serial ports.
"""

from __future__ import annotations

import dataclasses
from typing import List, Optional

NORMAL_MODE_VID = 0x0483
NORMAL_MODE_PID = 0x5740
DFU_MODE_VID = 0x0483
DFU_MODE_PID = 0xDF11


@dataclasses.dataclass(frozen=True)
class PortDescriptor:
    """A single serial port as reported by the OS - the pyserial
    equivalent of a pscustomobject fixture in the PowerShell test suite.
    """

    device: str  # e.g. "COM5"
    vid: Optional[int]
    pid: Optional[int]
    description: str = ""
    hwid: str = ""
    in_use_by_other_process: bool = False


@dataclasses.dataclass(frozen=True)
class DiscoveryResult:
    status: str  # "PASS" | "BLOCKED - <reason>" | "NEEDS_REVIEW - <reason>"
    detail: str
    port: Optional[PortDescriptor] = None


def is_normal_mode(port: PortDescriptor) -> bool:
    """Exact identity match only - never a FriendlyName/description match."""
    return port.vid == NORMAL_MODE_VID and port.pid == NORMAL_MODE_PID


def is_dfu_mode(port: PortDescriptor) -> bool:
    """Exact identity match only - never a FriendlyName/description match."""
    return port.vid == DFU_MODE_VID and port.pid == DFU_MODE_PID


def classify_ports(ports: List[PortDescriptor]) -> DiscoveryResult:
    """Pure classification function - no OS calls. Takes a list of
    already-enumerated ports and decides whether exactly one, unambiguous,
    normal-mode Flipper Zero is present.

    This function never initiates any flash, update, repair, erase, or
    format action - it only classifies already-present, already-reported
    port descriptors.
    """
    normal_matches = [p for p in ports if is_normal_mode(p)]
    dfu_matches = [p for p in ports if is_dfu_mode(p)]

    if dfu_matches and not normal_matches:
        return DiscoveryResult(
            status="BLOCKED - DEVICE IN DFU MODE",
            detail=(
                "Exact DFU identity (VID_0483&PID_DF11) detected on "
                f"{dfu_matches[0].device}, but no normal-mode identity "
                "(VID_0483&PID_5740) is present. The hardware app tester "
                "only operates against a normally booted device - it "
                "never initiates or assumes recovery-mode operation."
            ),
            port=None,
        )

    if not normal_matches:
        return DiscoveryResult(
            status="BLOCKED - NO NORMAL-MODE DEVICE DETECTED",
            detail=(
                "No device matching the exact normal-mode identity "
                "VID_0483&PID_5740 is present among "
                f"{len(ports)} enumerated port(s)."
            ),
            port=None,
        )

    if len(normal_matches) > 1:
        devices = ", ".join(p.device for p in normal_matches)
        return DiscoveryResult(
            status="BLOCKED - AMBIGUOUS MULTIPLE DEVICES",
            detail=(
                "More than one device matching the exact normal-mode "
                f"identity VID_0483&PID_5740 is present: {devices}. "
                "Refusing to guess which one to test - connect exactly "
                "one Flipper Zero."
            ),
            port=None,
        )

    candidate = normal_matches[0]
    if candidate.in_use_by_other_process:
        return DiscoveryResult(
            status="BLOCKED - PORT CONTENTION",
            detail=(
                f"{candidate.device} matches the exact normal-mode "
                "identity, but is reported in use by another process "
                "(commonly qFlipper). Close other programs that may "
                "hold this serial port before running the tester."
            ),
            port=None,
        )

    return DiscoveryResult(
        status="PASS",
        detail=(
            f"Exact normal-mode identity VID_0483&PID_5740 detected on "
            f"{candidate.device}, unambiguous, and not held by another "
            "process."
        ),
        port=candidate,
    )


def list_present_ports() -> List[PortDescriptor]:  # pragma: no cover
    """The ONLY function in this module that touches a real OS API.

    Requires pyserial and a real Windows host with a real serial device
    attached - not exercised by this repository's own test suite, which
    validates classify_ports() against synthetic PortDescriptor lists
    instead. Never exercised against real hardware in this development
    session.
    """
    import serial.tools.list_ports  # type: ignore

    results: List[PortDescriptor] = []
    for info in serial.tools.list_ports.comports():
        in_use = False
        try:
            import serial  # type: ignore

            probe = serial.Serial(info.device, timeout=0.05)
            probe.close()
        except Exception:
            in_use = True
        results.append(
            PortDescriptor(
                device=info.device,
                vid=info.vid,
                pid=info.pid,
                description=info.description or "",
                hwid=info.hwid or "",
                in_use_by_other_process=in_use,
            )
        )
    return results


def discover() -> DiscoveryResult:  # pragma: no cover
    """Convenience entry point combining real enumeration with the pure
    classification logic. Never exercised against real hardware in this
    development session - see list_present_ports().
    """
    return classify_ports(list_present_ports())
