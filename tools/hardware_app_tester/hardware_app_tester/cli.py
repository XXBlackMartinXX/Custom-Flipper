"""Command-line entrypoint for the hardware app tester.

Usage (see docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md for the full,
operator-facing version of all of this):

    python -m hardware_app_tester.cli validate-profiles --repo-root <path>
    python -m hardware_app_tester.cli discover [--dry-run]
    python -m hardware_app_tester.cli handshake --port COM5 [--dry-run]
    python -m hardware_app_tester.cli run-gate-a --repo-root <path>
        --report-dir <path> [--dry-run] [--apps a,b,c,d,e]
    python -m hardware_app_tester.cli run-safe-automation --repo-root <path>
        --report-dir <path> [--dry-run]

IMPORTANT CAPABILITY CEILING, disclosed here and in every relevant doc:
this CLI's `run-gate-a`/`run-safe-automation` commands can perform real
device discovery, a real read-only handshake, a real `loader open`/
`loader close` round trip, and real uptime/USB/heap-continuity and
panic-log crash detection - all genuinely exercised against a real
device when run on Windows with a real Flipper Zero attached. They
CANNOT yet perform the profile-declared safe input sequence, screen-
frame capture, or expected-state-transition confirmation described in
docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md Part C steps 7-10, because
`rpc_client.py` is an intentional, documented skeleton (the Flipper RPC
protobuf schema has not been compiled/vendored in this project yet).
Because of this, **no per-app result from this CLI is ever classified
PASS** - the ceiling is NEEDS_REVIEW (clean launch/close/continuity,
but input/screen verification not implemented) or lower (FAIL/BLOCKED
if something goes wrong). This is a deliberate, fail-closed design
choice: "no overall PASS may be emitted unless raw evidence supports
every required condition" (Gate A's own rule), and evidence for the
input/screen steps does not yet exist.

This module never flashes, updates, repairs, erases, or formats a
device - enforced by tests/test_no_destructive_capability.py, which
scans this file too.
"""

from __future__ import annotations

import argparse
import dataclasses
import json
import platform
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

from . import crash_detection, device_state, discovery, evidence
from .profile_schema import (
    ProfileValidationError,
    TestProfile,
    load_all_profiles,
    validate_all_profiles_against_repository,
)
from .serial_cli import FlipperCliClient

EXPECTED_PROFILE_COUNT = 20

#: The mission's preferred Gate A representative set, covering distinct
#: behavior classes (calculator/parser, deterministic utility, puzzle/
#: game, data lookup, simple UI/state machine). Verified against the
#: real, loaded profiles at runtime in select_gate_a_apps() below -
#: never assumed present without checking.
PREFERRED_GATE_A_APPS = [
    "programmer_calc",
    "vin_decoder",
    "quadratic_solver",
    "sudoku",
    "resistors",
]


def _now_iso() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


# ---------------------------------------------------------------------------
# validate-profiles
# ---------------------------------------------------------------------------


def cmd_validate_profiles(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).resolve()
    profiles_dir = repo_root / "tests" / "hardware" / "apps"

    result: Dict[str, Any] = {
        "command": "validate-profiles",
        "timestamp": _now_iso(),
        "repo_root": str(repo_root),
        "profiles_dir": str(profiles_dir),
    }

    try:
        profiles = load_all_profiles(profiles_dir)
    except ProfileValidationError as exc:
        result["status"] = "FAIL"
        result["detail"] = f"Profile schema validation failed: {exc}"
        _emit(result, args)
        return 1

    result["profile_count"] = len(profiles)
    result["expected_profile_count"] = EXPECTED_PROFILE_COUNT
    if len(profiles) != EXPECTED_PROFILE_COUNT:
        result["status"] = "FAIL"
        result["detail"] = (
            f"Expected exactly {EXPECTED_PROFILE_COUNT} profiles, found "
            f"{len(profiles)}. This is a hard stop - the mission requires "
            "an explanation for any app-count change, and this command "
            "does not have one to give."
        )
        _emit(result, args)
        return 1

    repo_issues = validate_all_profiles_against_repository(profiles, repo_root)
    automation_counts: Dict[str, int] = {}
    for p in profiles.values():
        automation_counts[p.automation_class] = (
            automation_counts.get(p.automation_class, 0) + 1
        )
    result["automation_class_counts"] = automation_counts
    result["repository_cross_check_issues"] = [
        dataclasses.asdict(i) for i in repo_issues
    ]

    if repo_issues:
        result["status"] = "FAIL"
        result["detail"] = (
            f"{len(repo_issues)} repository cross-check issue(s) found - "
            "see repository_cross_check_issues."
        )
        _emit(result, args)
        return 1

    result["status"] = "PASS"
    result["detail"] = (
        f"All {len(profiles)} profiles schema-valid and cross-checked "
        "against real source (source_path exists, launch_target matches "
        "the real application.fam appid)."
    )
    _emit(result, args)
    return 0


# ---------------------------------------------------------------------------
# discover
# ---------------------------------------------------------------------------


def cmd_discover(args: argparse.Namespace) -> int:
    result: Dict[str, Any] = {
        "command": "discover",
        "timestamp": _now_iso(),
        "dry_run": args.dry_run,
    }
    if args.dry_run:
        result["status"] = "NOT_RUN"
        result["detail"] = (
            "DryRun: device discovery was not attempted. No serial "
            "enumeration, no device interaction."
        )
        _emit(result, args)
        return 0

    discovery_result = discovery.discover()
    result["status"] = discovery_result.status
    result["detail"] = discovery_result.detail
    result["port"] = (
        dataclasses.asdict(discovery_result.port) if discovery_result.port else None
    )
    _emit(result, args)
    return 0 if discovery_result.status == "PASS" else 1


# ---------------------------------------------------------------------------
# handshake (read-only)
# ---------------------------------------------------------------------------


def _open_real_serial_connection(port: str, timeout: float = 0.5):
    import serial  # local import: keeps this module importable in

    # environments without pyserial installed for non-hardware commands.
    return serial.Serial(port, baudrate=230400, timeout=timeout)


def cmd_handshake(args: argparse.Namespace) -> int:
    result: Dict[str, Any] = {
        "command": "handshake",
        "timestamp": _now_iso(),
        "dry_run": args.dry_run,
        "port": args.port,
    }
    if args.dry_run:
        result["status"] = "NOT_RUN"
        result["detail"] = "DryRun: no serial connection was opened."
        _emit(result, args)
        return 0

    if not args.port:
        result["status"] = "BLOCKED - NO PORT SPECIFIED"
        result["detail"] = "handshake requires --port (resolve it via 'discover' first)."
        _emit(result, args)
        return 1

    try:
        conn = _open_real_serial_connection(args.port)
    except Exception as exc:  # pyserial raises SerialException, OSError, etc.
        result["status"] = "BLOCKED - SERIAL OPEN FAILED"
        result["detail"] = f"Could not open {args.port}: {exc}"
        _emit(result, args)
        return 1

    try:
        cli = FlipperCliClient(conn, default_timeout=5.0)
        uptime_resp = cli.uptime()
        loader_resp = cli.loader_info()
        heap_resp = cli.free_heap()
    except Exception as exc:
        result["status"] = "NEEDS_REVIEW - HANDSHAKE ERROR"
        result["detail"] = f"Unexpected error during read-only handshake: {exc}"
        _emit(result, args)
        return 1
    finally:
        try:
            conn.close()
        except Exception:
            pass

    result["uptime_response"] = dataclasses.asdict(uptime_resp)
    result["loader_response"] = dataclasses.asdict(loader_resp)
    result["free_heap_response"] = dataclasses.asdict(heap_resp)

    if uptime_resp.timed_out or loader_resp.timed_out or heap_resp.timed_out:
        result["status"] = "BLOCKED - CLI NOT RESPONDING"
        result["detail"] = (
            "One or more read-only handshake commands timed out waiting "
            "for the CLI prompt - the device may not be at its desktop, "
            "or another session may already be attached to this port."
        )
        _emit(result, args)
        return 1

    result["status"] = "PASS"
    result["detail"] = "CLI prompt reachable; uptime/loader/heap all responded within timeout."
    _emit(result, args)
    return 0


# ---------------------------------------------------------------------------
# run-gate-a / run-safe-automation shared machinery
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class AppRunResult:
    app_id: str
    automation_class: str
    source_path: str
    launch_target: str
    start_time: str
    end_time: str
    duration_seconds: float
    pre_usb_state: str
    post_usb_state: str
    pre_uptime_ms: Optional[int]
    post_uptime_ms: Optional[int]
    pre_loader_state: Optional[str]
    post_loader_state: Optional[str]
    input_steps_sent: List[str]
    expected_transitions: List[str]
    observed_transitions: List[str]
    logs: List[str]
    crash_indicators: List[str]
    memory_result: str
    exit_result: str
    status: str
    rationale: str


def select_gate_a_apps(profiles: Dict[str, TestProfile]) -> List[str]:
    """Verifies the mission's preferred 5-app set is actually present and
    SAFE_AUTOMATION in the real, loaded profiles; raises if not, rather
    than silently substituting - "the final set must be determined from
    the actual profiles and source," so this is checked, not assumed.
    """
    missing = []
    wrong_class = []
    for app_id in PREFERRED_GATE_A_APPS:
        profile = profiles.get(app_id)
        if profile is None:
            missing.append(app_id)
        elif profile.automation_class != "SAFE_AUTOMATION":
            wrong_class.append(app_id)
    if missing or wrong_class:
        raise ProfileValidationError(
            "Preferred Gate A representative set is not fully valid "
            f"against the real profiles: missing={missing}, "
            f"wrong_automation_class={wrong_class}. Refusing to silently "
            "substitute a different set - this requires a human decision."
        )
    return list(PREFERRED_GATE_A_APPS)


def _run_one_app(
    cli: FlipperCliClient,
    profile: TestProfile,
    log_dir: Path,
    discover_fn=discovery.discover,
) -> AppRunResult:
    """`discover_fn` defaults to the real discovery.discover() (a real
    pyserial enumeration). --mock runs inject a synthetic always-PASS
    stand-in instead, since mock mode has no real device or real USB
    state to check at all - see cmd wiring in _run_apps()."""
    start = _now_iso()
    start_monotonic = time.monotonic()
    logs: List[str] = []
    crash_indicators: List[str] = []

    pre_discovery = discover_fn()
    pre_usb_state = pre_discovery.status

    pre_uptime_resp = cli.uptime()
    pre_loader_resp = cli.loader_info()
    pre_heap_resp = cli.free_heap()
    pre_snapshot, pre_issues = device_state.build_snapshot(
        pre_uptime_resp, pre_heap_resp, pre_loader_resp, usb_present=(pre_usb_state == "PASS")
    )
    logs.extend(pre_issues)

    open_resp = cli.loader_open(profile.launch_target)
    logs.append(f"loader open {profile.launch_target} -> timed_out={open_resp.timed_out}")

    if open_resp.timed_out:
        end = _now_iso()
        return AppRunResult(
            app_id=profile.app_id,
            automation_class=profile.automation_class,
            source_path=profile.source_path,
            launch_target=profile.launch_target,
            start_time=start,
            end_time=end,
            duration_seconds=time.monotonic() - start_monotonic,
            pre_usb_state=pre_usb_state,
            post_usb_state="NOT_CHECKED",
            pre_uptime_ms=pre_snapshot.uptime_ms if pre_snapshot else None,
            post_uptime_ms=None,
            pre_loader_state=pre_snapshot.loader_state if pre_snapshot else None,
            post_loader_state=None,
            input_steps_sent=[],
            expected_transitions=profile.expected_state_transitions,
            observed_transitions=[],
            logs=logs,
            crash_indicators=["loader open timed out"],
            memory_result="NOT_MEASURED",
            exit_result="NOT_ATTEMPTED",
            status="FAIL",
            rationale=(
                f"loader open {profile.launch_target} did not return a "
                f"CLI prompt within {profile.timeout_seconds}s."
            ),
        )

    # Steps 7-10 (safe input sequence, screen capture, expected-state-
    # transition confirmation) are NOT implemented - see this module's
    # docstring and docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md. Logged
    # explicitly rather than silently skipped.
    logs.append(
        "input sequence / screen-fingerprint verification NOT PERFORMED "
        "- rpc_client.py is an unimplemented skeleton in this phase"
    )

    # Exit: this CLI-only implementation uses `loader close` regardless
    # of profile.exit_method's declared value (e.g. "back") - a real
    # Back-button press requires RPC input injection, not implemented.
    close_resp = cli.loader_close()
    logs.append(f"loader close -> timed_out={close_resp.timed_out}")

    post_uptime_resp = cli.uptime()
    post_loader_resp = cli.loader_info()
    post_heap_resp = cli.free_heap()
    post_discovery = discover_fn()
    post_usb_state = post_discovery.status
    post_snapshot, post_issues = device_state.build_snapshot(
        post_uptime_resp, post_heap_resp, post_loader_resp, usb_present=(post_usb_state == "PASS")
    )
    logs.extend(post_issues)

    log_tail_resp = cli.log_tail(timeout=1.0)
    logs.extend(log_tail_resp.lines)
    panic_check = crash_detection.scan_log_lines_for_panic(log_tail_resp.lines)
    if panic_check.status.startswith("FAIL"):
        crash_indicators.append(panic_check.detail)

    end = _now_iso()

    if pre_snapshot is None or post_snapshot is None:
        status = "NEEDS_REVIEW"
        rationale = (
            "Could not build a complete before/after device-state "
            "snapshot (uptime/heap/loader-state parsing failed on at "
            "least one required field) - see logs for the specific "
            "parse issue(s). This is not evidence of a crash, only of "
            "an unparseable CLI response; treat as needing human review, "
            "not as a pass."
        )
        memory_result = "NOT_MEASURED"
    else:
        crash_results = crash_detection.evaluate_all(
            pre_snapshot,
            post_snapshot,
            profile.maximum_heap_delta,
            log_lines=log_tail_resp.lines,
        )
        crash_indicators.extend(
            r.detail for r in crash_results if not r.status.startswith("PASS")
        )
        memory_result = next(
            (r.detail for r in crash_results if "heap" in r.detail.lower()),
            "NOT_MEASURED",
        )
        if crash_detection.any_failed(crash_results):
            status = "FAIL"
            rationale = "; ".join(
                r.detail for r in crash_results if r.status.startswith("FAIL")
            )
        elif crash_detection.any_needs_review(crash_results):
            status = "NEEDS_REVIEW"
            rationale = "; ".join(
                r.detail for r in crash_results if r.status.startswith("NEEDS_REVIEW")
            )
        else:
            # Launch/close/continuity/crash-safety all clean - but input
            # sequence and screen-fingerprint verification (mission steps
            # 7-10) were never performed, so this can never be PASS.
            status = "NEEDS_REVIEW"
            rationale = (
                "Launch, close, uptime/USB/heap continuity, and panic-log "
                "checks all clean. NOT classified PASS: profile-declared "
                "input sequence and expected-screen-state verification "
                "were not performed (RPC client not implemented in this "
                "phase) - required conditions for a PASS are not fully "
                "evidenced."
            )

    result = AppRunResult(
        app_id=profile.app_id,
        automation_class=profile.automation_class,
        source_path=profile.source_path,
        launch_target=profile.launch_target,
        start_time=start,
        end_time=end,
        duration_seconds=time.monotonic() - start_monotonic,
        pre_usb_state=pre_usb_state,
        post_usb_state=post_usb_state,
        pre_uptime_ms=pre_snapshot.uptime_ms if pre_snapshot else None,
        post_uptime_ms=post_snapshot.uptime_ms if post_snapshot else None,
        pre_loader_state=pre_snapshot.loader_state if pre_snapshot else None,
        post_loader_state=post_snapshot.loader_state if post_snapshot else None,
        input_steps_sent=[],
        expected_transitions=profile.expected_state_transitions,
        observed_transitions=["NOT_CAPTURED - RPC client not implemented"],
        logs=logs,
        crash_indicators=crash_indicators,
        memory_result=memory_result,
        exit_result=f"loader close timed_out={close_resp.timed_out}",
        status=status,
        rationale=rationale,
    )

    log_dir.mkdir(parents=True, exist_ok=True)
    (log_dir / f"{profile.app_id}.log").write_text(
        "\n".join(logs) + "\n", encoding="utf-8"
    )
    return result


def _integrity_threatening(result: AppRunResult) -> bool:
    """True if this app's result indicates device integrity is uncertain
    enough that the whole run should stop, per Part H's stop conditions
    (USB disappeared, uptime reset/reboot, CLI unresponsive, wrong app,
    loader would not return to idle)."""
    if result.post_usb_state != "PASS":
        return True
    if result.status == "FAIL":
        return True
    return False


def _run_apps(
    args: argparse.Namespace, app_ids: List[str], run_label: str
) -> Dict[str, Any]:
    repo_root = Path(args.repo_root).resolve()
    profiles_dir = repo_root / "tests" / "hardware" / "apps"
    report_dir = Path(args.report_dir).resolve()

    run_result: Dict[str, Any] = {
        "command": run_label,
        "timestamp": _now_iso(),
        "dry_run": args.dry_run,
        "requested_apps": app_ids,
    }

    profiles = load_all_profiles(profiles_dir)
    run_result["profile_count"] = len(profiles)

    if args.dry_run:
        run_result["status"] = "NOT_RUN"
        run_result["detail"] = (
            "DryRun: planned app set rendered; no serial connection, no "
            "application launch, no device interaction performed."
        )
        run_result["planned_apps"] = [
            {
                "app_id": aid,
                "launch_target": profiles[aid].launch_target,
                "timeout_seconds": profiles[aid].timeout_seconds,
            }
            for aid in app_ids
            if aid in profiles
        ]
        report_dir.mkdir(parents=True, exist_ok=True)
        _emit(run_result, args)
        return run_result

    is_mock = getattr(args, "mock", False)
    discover_fn = discovery.discover

    if is_mock:
        # Mock mode: a synthetic, in-process transport for developer
        # regression testing only - NEVER a source of real hardware
        # evidence. See hardware_app_tester/mock_transport.py's own
        # docstring for the discipline this enforces.
        run_result["hardware_execution"] = "NOT PERFORMED"
        from .mock_transport import FakeSerialConnection

        conn = FakeSerialConnection(timeout=0.2)
        for app_id in app_ids:
            profile = profiles.get(app_id)
            if profile is None:
                continue
            conn.script("uptime", ["Uptime: 0d 00:00:05"])
            conn.script("free", ["Free heap size: 100000 bytes"])
            conn.script("loader info", ["Firmware is not running any application"])
            conn.script(f"loader open {profile.launch_target}", [])
            conn.script("loader close", [])
        cli = FlipperCliClient(conn, default_timeout=1.0)

        def discover_fn():  # noqa: F811 - deliberate shadow for mock mode
            return discovery.DiscoveryResult(
                status="PASS",
                detail="MOCK - synthetic device, not a real discovery result.",
                port=discovery.PortDescriptor(
                    device="MOCK-COM", vid=discovery.NORMAL_MODE_VID, pid=discovery.NORMAL_MODE_PID
                ),
            )

        run_result["device_discovery"] = {
            "status": "MOCK - SYNTHETIC DEVICE",
            "detail": "Mock mode: no real discovery was attempted.",
        }
    else:
        discovery_result = discovery.discover()
        run_result["device_discovery"] = {
            "status": discovery_result.status,
            "detail": discovery_result.detail,
        }
        if discovery_result.status != "PASS":
            run_result["status"] = "GATE A HARDWARE PROOF BLOCKED"
            run_result["detail"] = f"Device discovery did not pass: {discovery_result.detail}"
            _emit(run_result, args)
            return run_result

        port = discovery_result.port.device
        try:
            conn = _open_real_serial_connection(port)
            cli = FlipperCliClient(conn, default_timeout=5.0)
        except Exception as exc:
            run_result["status"] = "GATE A HARDWARE PROOF BLOCKED"
            run_result["detail"] = f"Could not open serial connection to {port}: {exc}"
            _emit(run_result, args)
            return run_result

    app_results: List[AppRunResult] = []
    stopped_early = False
    try:
        for app_id in app_ids:
            profile = profiles.get(app_id)
            if profile is None:
                app_results.append(
                    AppRunResult(
                        app_id=app_id,
                        automation_class="UNKNOWN",
                        source_path="",
                        launch_target="",
                        start_time=_now_iso(),
                        end_time=_now_iso(),
                        duration_seconds=0.0,
                        pre_usb_state="NOT_CHECKED",
                        post_usb_state="NOT_CHECKED",
                        pre_uptime_ms=None,
                        post_uptime_ms=None,
                        pre_loader_state=None,
                        post_loader_state=None,
                        input_steps_sent=[],
                        expected_transitions=[],
                        observed_transitions=[],
                        logs=[],
                        crash_indicators=[],
                        memory_result="NOT_MEASURED",
                        exit_result="NOT_ATTEMPTED",
                        status="BLOCKED",
                        rationale=f"No profile found for app_id '{app_id}'.",
                    )
                )
                continue
            if profile.automation_class != "SAFE_AUTOMATION":
                app_results.append(
                    AppRunResult(
                        app_id=app_id,
                        automation_class=profile.automation_class,
                        source_path=profile.source_path,
                        launch_target=profile.launch_target,
                        start_time=_now_iso(),
                        end_time=_now_iso(),
                        duration_seconds=0.0,
                        pre_usb_state="NOT_CHECKED",
                        post_usb_state="NOT_CHECKED",
                        pre_uptime_ms=None,
                        post_uptime_ms=None,
                        pre_loader_state=None,
                        post_loader_state=None,
                        input_steps_sent=[],
                        expected_transitions=[],
                        observed_transitions=[],
                        logs=[],
                        crash_indicators=[],
                        memory_result="NOT_MEASURED",
                        exit_result="NOT_ATTEMPTED",
                        status="NOT_RUN",
                        rationale=(
                            f"automation_class is '{profile.automation_class}', "
                            "not SAFE_AUTOMATION - never run automatically."
                        ),
                    )
                )
                continue

            result = _run_one_app(cli, profile, report_dir / "app_logs", discover_fn=discover_fn)
            app_results.append(result)
            if _integrity_threatening(result):
                stopped_early = True
                break
    finally:
        try:
            conn.close()
        except Exception:
            pass

    run_result["app_results"] = [dataclasses.asdict(r) for r in app_results]
    run_result["stopped_early"] = stopped_early

    statuses = {r.status for r in app_results}
    if stopped_early:
        base_status = "GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW"
    elif "FAIL" in statuses or "BLOCKED" in statuses:
        base_status = "GATE A HARDWARE PROOF PARTIAL"
    else:
        # Includes the all-NEEDS_REVIEW case (the expected, honest
        # outcome even for a perfectly clean run - see rationale below).
        base_status = "GATE A HARDWARE PROOF PARTIAL"

    run_result["status"] = f"MOCK - {base_status}" if is_mock else base_status
    run_result["detail"] = (
        "See app_results for per-app detail. No per-app result is ever "
        "classified PASS by this tool version - input-sequence and "
        "screen-fingerprint verification are not yet implemented (see "
        "this module's docstring), so a full GATE A HARDWARE PROOF PASS "
        "cannot be emitted regardless of how cleanly the device behaves."
    )
    if is_mock:
        run_result["detail"] += (
            " MOCK MODE: this result used a synthetic in-process "
            "transport, not a real device - it must never be treated as "
            "real hardware evidence."
        )

    _emit(run_result, args)
    return run_result


def cmd_run_gate_a(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).resolve()
    profiles_dir = repo_root / "tests" / "hardware" / "apps"
    profiles = load_all_profiles(profiles_dir)

    if args.apps:
        app_ids = [a.strip() for a in args.apps.split(",") if a.strip()]
    else:
        app_ids = select_gate_a_apps(profiles)

    result = _run_apps(args, app_ids, "run-gate-a")
    return 0 if result["status"] not in (
        "GATE A HARDWARE PROOF BLOCKED",
        "GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW",
    ) else 1


def cmd_run_safe_automation(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).resolve()
    profiles_dir = repo_root / "tests" / "hardware" / "apps"
    profiles = load_all_profiles(profiles_dir)

    all_safe = sorted(
        app_id
        for app_id, p in profiles.items()
        if p.automation_class == "SAFE_AUTOMATION"
    )
    gate_a_apps = select_gate_a_apps(profiles) if not args.dry_run else PREFERRED_GATE_A_APPS
    remaining = [a for a in all_safe if a not in gate_a_apps]

    result = _run_apps(args, remaining, "run-safe-automation")
    return 0 if "BLOCKED" not in result["status"] and "FAILED" not in result["status"] else 1


# ---------------------------------------------------------------------------
# output helper
# ---------------------------------------------------------------------------


def _emit(result: Dict[str, Any], args: argparse.Namespace) -> None:
    text = json.dumps(result, indent=2, sort_keys=True)
    if getattr(args, "output", None):
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text + "\n", encoding="utf-8")
    print(text)


# ---------------------------------------------------------------------------
# argument parser
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="hardware_app_tester",
        description=(
            "Gate A hardware test CLI. Never flashes, updates, repairs, "
            "erases, or formats a device. See tools/hardware_app_tester/"
            "README.md and docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md."
        ),
    )
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    p_validate = subparsers.add_parser(
        "validate-profiles", help="Schema- and repository-validate all test profiles."
    )
    p_validate.add_argument("--repo-root", required=True)
    p_validate.add_argument("--output")
    p_validate.set_defaults(func=cmd_validate_profiles)

    p_discover = subparsers.add_parser(
        "discover", help="Discover and classify the connected Flipper Zero."
    )
    p_discover.add_argument("--dry-run", action="store_true")
    p_discover.add_argument("--output")
    p_discover.set_defaults(func=cmd_discover)

    p_handshake = subparsers.add_parser(
        "handshake", help="Read-only CLI handshake (uptime/loader/heap queries only)."
    )
    p_handshake.add_argument("--port")
    p_handshake.add_argument("--dry-run", action="store_true")
    p_handshake.add_argument("--output")
    p_handshake.set_defaults(func=cmd_handshake)

    p_gate_a = subparsers.add_parser(
        "run-gate-a", help="Run the 5-app Gate A representative set."
    )
    p_gate_a.add_argument("--repo-root", required=True)
    p_gate_a.add_argument("--report-dir", required=True)
    p_gate_a.add_argument("--apps", help="Comma-separated app_id override.")
    p_gate_a.add_argument("--dry-run", action="store_true")
    p_gate_a.add_argument(
        "--mock",
        action="store_true",
        help=(
            "Developer regression mode only: uses a synthetic in-process "
            "transport, never a real device. Results are always labeled "
            "hardware_execution=NOT PERFORMED and never usable as real "
            "hardware evidence. Ignored if --dry-run is also given."
        ),
    )
    p_gate_a.add_argument("--output")
    p_gate_a.set_defaults(func=cmd_run_gate_a)

    p_safe_all = subparsers.add_parser(
        "run-safe-automation",
        help="Run all remaining SAFE_AUTOMATION apps not in the Gate A set.",
    )
    p_safe_all.add_argument("--repo-root", required=True)
    p_safe_all.add_argument("--report-dir", required=True)
    p_safe_all.add_argument("--dry-run", action="store_true")
    p_safe_all.add_argument(
        "--mock",
        action="store_true",
        help=(
            "Developer regression mode only: uses a synthetic in-process "
            "transport, never a real device. Ignored if --dry-run is "
            "also given."
        ),
    )
    p_safe_all.add_argument("--output")
    p_safe_all.set_defaults(func=cmd_run_safe_automation)

    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
