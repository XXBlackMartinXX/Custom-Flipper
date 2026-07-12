"""Orchestrates: device discovery -> per-app test (SAFE_AUTOMATION
profiles only) -> evidence write.

STATUS: this orchestrator is real code, but its two hardware-facing
dependencies (serial_cli.FlipperCliClient, rpc_client.FlipperRpcClient)
have never been exercised against a real device in this development
session - see tools/hardware_app_tester/README.md. Running this module
against real hardware is a task for whoever executes it on their own
Windows PC with a real Flipper Zero; nothing in this repository claims
that has happened yet.

This module never flashes, updates, repairs, erases, or formats a
device, and never runs a test profile whose automation_class is
anything other than SAFE_AUTOMATION - every other class is explicitly
skipped with a NOT_RUN result, never silently promoted to a PASS.
"""

from __future__ import annotations

import dataclasses
from pathlib import Path
from typing import List, Optional

from . import crash_detection, discovery, evidence
from .profile_schema import TestProfile, load_all_profiles
from .serial_cli import FlipperCliClient


@dataclasses.dataclass
class AppTestResult:
    app_id: str
    status: str  # PASS | FAIL | BLOCKED | NOT_SUPPORTED | NEEDS_REVIEW | NOT_RUN
    detail: str


RUNNABLE_AUTOMATION_CLASSES = {"SAFE_AUTOMATION"}


def run_single_app_test(
    cli: FlipperCliClient, profile: TestProfile
) -> AppTestResult:
    """Executes one SAFE_AUTOMATION test profile. Callers must have
    already confirmed profile.automation_class == "SAFE_AUTOMATION" -
    this function refuses to run anything else.
    """
    if profile.automation_class != "SAFE_AUTOMATION":
        return AppTestResult(
            app_id=profile.app_id,
            status="NOT_RUN",
            detail=(
                f"automation_class is '{profile.automation_class}', not "
                "SAFE_AUTOMATION - this runner never executes any other "
                "class automatically."
            ),
        )

    before_uptime = cli.uptime()
    before_heap = cli.free_heap()
    before_loader = cli.loader_info()
    # Real parsing of these CLI responses into structured
    # DeviceStateSnapshot values is intentionally left to the concrete
    # transport implementation once it is exercised against a real
    # device's actual CLI output format - the exact text format has not
    # been captured/verified in this session.

    open_response = cli.loader_open(profile.launch_target)
    if open_response.timed_out:
        return AppTestResult(
            app_id=profile.app_id,
            status="FAIL",
            detail=(
                f"loader open {profile.launch_target} timed out after "
                f"{profile.timeout_seconds}s waiting for the CLI prompt."
            ),
        )

    # Real screen-fingerprint comparison and safe-input-sequence
    # replay against RpcClient are not implemented in this foundation
    # phase - see rpc_client.py. A concrete implementation must confirm
    # profile.expected_initial_state via a captured screen frame before
    # sending profile.input_sequence, then confirm
    # profile.expected_state_transitions, then perform profile.exit_method,
    # then confirm return to idle - exactly mirroring Part I.C of
    # docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md.

    close_response = cli.loader_close()
    after_uptime = cli.uptime()
    after_heap = cli.free_heap()
    after_loader = cli.loader_info()

    return AppTestResult(
        app_id=profile.app_id,
        status="NOT_RUN",
        detail=(
            "CLI open/close round-trip attempted, but screen-fingerprint "
            "comparison and crash-detection evaluation require the "
            "rpc_client transport and real CLI response parsing, neither "
            "of which is implemented/hardware-tested in this foundation "
            "phase. This result is NOT a PASS."
        ),
    )


def run_all_safe_automation_tests(
    cli: FlipperCliClient, profiles_dir: Path
) -> List[AppTestResult]:
    profiles = load_all_profiles(profiles_dir)
    results: List[AppTestResult] = []
    for app_id, profile in sorted(profiles.items()):
        if profile.automation_class == "SAFE_AUTOMATION":
            results.append(run_single_app_test(cli, profile))
        else:
            results.append(
                AppTestResult(
                    app_id=app_id,
                    status="NOT_RUN",
                    detail=(
                        f"automation_class is '{profile.automation_class}' "
                        "- skipped by design, never auto-promoted."
                    ),
                )
            )
    return results


def write_run_evidence(report_dir: str, results: List[AppTestResult]) -> None:
    data = {
        "results": [dataclasses.asdict(r) for r in results],
        "summary": {
            "total": len(results),
            "pass": sum(1 for r in results if r.status == "PASS"),
            "fail": sum(1 for r in results if r.status == "FAIL"),
            "blocked": sum(1 for r in results if r.status == "BLOCKED"),
            "not_run": sum(1 for r in results if r.status == "NOT_RUN"),
            "needs_review": sum(1 for r in results if r.status == "NEEDS_REVIEW"),
        },
    }
    md_lines = ["# Hardware App Tester Run", ""]
    for r in results:
        md_lines.append(f"- `{r.app_id}`: **{r.status}** - {r.detail}")
    evidence.write_evidence(
        report_dir, "hardware_app_tester_run", data, "\n".join(md_lines)
    )
