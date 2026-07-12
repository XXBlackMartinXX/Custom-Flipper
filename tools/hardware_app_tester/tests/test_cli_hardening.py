"""Hardening tests for the Gate A CLI orchestration (cli.py) and its
device_state/profile_schema/discovery collaborators, covering the
scenarios required by the Gate A Windows-execution-package audit that
were not already covered by the pre-existing test suite.
"""

from pathlib import Path

import pytest

from hardware_app_tester import cli, device_state, discovery
from hardware_app_tester.evidence import write_evidence
from hardware_app_tester.mock_transport import FakeSerialConnection
from hardware_app_tester.profile_schema import (
    load_profile,
    validate_profile_against_repository,
)
from hardware_app_tester.serial_cli import CliResponse, FlipperCliClient


# ---------------------------------------------------------------------------
# Malformed CLI response
# ---------------------------------------------------------------------------


def test_malformed_uptime_response_does_not_fabricate_a_value():
    garbage = CliResponse(command="uptime", lines=["#@$! not a real response %%"], timed_out=False)
    assert device_state.parse_uptime_ms(garbage.lines) is None


def test_malformed_free_heap_response_does_not_fabricate_a_value():
    garbage = CliResponse(command="free", lines=["nonsense output"], timed_out=False)
    assert device_state.parse_free_heap_bytes(garbage.lines) is None


def test_build_snapshot_reports_issues_rather_than_guessing():
    uptime_resp = CliResponse(command="uptime", lines=["garbage"], timed_out=False)
    heap_resp = CliResponse(command="free", lines=["Free heap size: 12345 bytes"], timed_out=False)
    loader_resp = CliResponse(command="loader info", lines=["not running any application"], timed_out=False)

    snapshot, issues = device_state.build_snapshot(uptime_resp, heap_resp, loader_resp, usb_present=True)

    assert snapshot is None
    assert any("uptime" in issue for issue in issues)


# ---------------------------------------------------------------------------
# Wrong app launches - this tool structurally cannot detect this without
# RPC screen verification, so the required invariant is: it must NEVER
# claim PASS regardless, even on an otherwise-clean run.
# ---------------------------------------------------------------------------


def test_clean_run_is_capped_at_needs_review_never_pass(tmp_path):
    conn = FakeSerialConnection(timeout=0.2)
    conn.script("uptime", ["Uptime: 0d 00:00:05"])
    conn.script("free", ["Free heap size: 100000 bytes"])
    conn.script("loader info", ["Firmware is not running any application"])
    conn.script("loader open somewrongapp", [])
    conn.script("loader close", [])
    client = FlipperCliClient(conn, default_timeout=1.0)

    profile = load_profile(Path(__file__).resolve().parents[3] / "tests" / "hardware" / "apps" / "programmer_calc.yaml")
    # Force launch_target to something unscripted-but-present to simulate
    # "successful open response" without any way to confirm which app is
    # actually running - the tool has no screen/RPC evidence either way.
    profile.launch_target = "somewrongapp"

    def fake_discover():
        return discovery.DiscoveryResult(
            status="PASS", detail="fixture", port=discovery.PortDescriptor(device="COMX", vid=discovery.NORMAL_MODE_VID, pid=discovery.NORMAL_MODE_PID)
        )

    result = cli._run_one_app(client, profile, tmp_path, discover_fn=fake_discover)

    assert result.status != "PASS", (
        "invariant violated: this tool must never emit PASS - it cannot "
        "verify which app actually launched without RPC screen evidence"
    )


# ---------------------------------------------------------------------------
# App cannot close (loader close times out / never returns to idle)
# ---------------------------------------------------------------------------


def test_app_refuses_to_close_is_not_silently_passed(tmp_path):
    conn = FakeSerialConnection(timeout=0.2)
    conn.script("uptime", ["Uptime: 0d 00:00:05"])
    conn.script("free", ["Free heap size: 100000 bytes"])
    conn.script("loader info", ["Firmware is not running any application"])
    conn.script("loader open programmercalc", [])
    # loader close deliberately unscripted -> times out, simulating an
    # app that refuses to close within the CLI's timeout.
    client = FlipperCliClient(conn, default_timeout=0.3)

    profile = load_profile(Path(__file__).resolve().parents[3] / "tests" / "hardware" / "apps" / "programmer_calc.yaml")

    def fake_discover():
        return discovery.DiscoveryResult(
            status="PASS", detail="fixture", port=discovery.PortDescriptor(device="COMX", vid=discovery.NORMAL_MODE_VID, pid=discovery.NORMAL_MODE_PID)
        )

    result = cli._run_one_app(client, profile, tmp_path, discover_fn=fake_discover)

    assert result.status != "PASS"
    assert "close" in result.exit_result.lower()
    assert "timed_out=True" in result.exit_result


# ---------------------------------------------------------------------------
# Missing source manifest
# ---------------------------------------------------------------------------


def test_missing_source_path_flagged_not_silently_skipped(tmp_path):
    profile = load_profile(Path(__file__).resolve().parents[3] / "tests" / "hardware" / "apps" / "programmer_calc.yaml")
    profile.source_path = "applications_user/this_app_does_not_exist"

    issues = validate_profile_against_repository(profile, tmp_path)

    assert len(issues) == 1
    assert "does not exist" in issues[0].issue


def test_missing_application_fam_flagged(tmp_path):
    profile = load_profile(Path(__file__).resolve().parents[3] / "tests" / "hardware" / "apps" / "programmer_calc.yaml")
    (tmp_path / profile.source_path).mkdir(parents=True)
    # No application.fam written inside it.

    issues = validate_profile_against_repository(profile, tmp_path)

    assert len(issues) == 1
    assert "could not read a real appid" in issues[0].issue


def test_launch_target_mismatch_flagged(tmp_path):
    profile = load_profile(Path(__file__).resolve().parents[3] / "tests" / "hardware" / "apps" / "programmer_calc.yaml")
    app_dir = tmp_path / profile.source_path
    app_dir.mkdir(parents=True)
    (app_dir / "application.fam").write_text('App(appid="totally_different_id")\n')

    issues = validate_profile_against_repository(profile, tmp_path)

    assert len(issues) == 1
    assert "does not match the real appid" in issues[0].issue


# ---------------------------------------------------------------------------
# Interrupted evidence write - failures must propagate, never be
# silently swallowed
# ---------------------------------------------------------------------------


def test_interrupted_evidence_write_raises_not_swallowed(tmp_path, monkeypatch):
    real_open = open

    call_count = {"n": 0}

    def flaky_open(path, mode="r", *a, **kw):
        call_count["n"] += 1
        if call_count["n"] == 2 and "w" in mode:
            raise OSError("simulated disk failure during evidence write")
        return real_open(path, mode, *a, **kw)

    monkeypatch.setattr("builtins.open", flaky_open)

    with pytest.raises(OSError):
        write_evidence(str(tmp_path), "interrupted_test", {"a": 1}, "# md\n")


# ---------------------------------------------------------------------------
# DryRun performs no device access
# ---------------------------------------------------------------------------


def test_dry_run_never_calls_real_discovery_or_opens_serial(tmp_path, monkeypatch):
    called = {"discover": False, "serial_open": False}

    def fake_discover():
        called["discover"] = True
        raise AssertionError("discover() must not be called in --dry-run")

    def fake_open_serial(port, timeout=0.5):
        called["serial_open"] = True
        raise AssertionError("_open_real_serial_connection() must not be called in --dry-run")

    monkeypatch.setattr(discovery, "discover", fake_discover)
    monkeypatch.setattr(cli, "_open_real_serial_connection", fake_open_serial)

    test_repo_root = Path(__file__).resolve().parents[3]

    class Args:
        repo_root = str(test_repo_root)
        report_dir = str(tmp_path / "dryrun_report")
        dry_run = True
        mock = False
        output = None

    result = cli._run_apps(Args(), ["programmer_calc"], "run-gate-a")

    assert called["discover"] is False
    assert called["serial_open"] is False
    assert result["status"] == "NOT_RUN"


# ---------------------------------------------------------------------------
# Serial access denied (handshake)
# ---------------------------------------------------------------------------


def test_handshake_reports_blocked_when_serial_open_raises(monkeypatch):
    def raising_open(port, timeout=0.5):
        raise PermissionError("Access is denied (simulated qFlipper contention)")

    monkeypatch.setattr(cli, "_open_real_serial_connection", raising_open)

    class Args:
        port = "COM5"
        dry_run = False
        output = None

    exit_code = cli.cmd_handshake(Args())
    assert exit_code == 1


# ---------------------------------------------------------------------------
# One device with multiple COM interfaces (same physical device exposing
# more than one serial interface) - documents the current, deliberately
# conservative behavior: without a verified way to confirm two ports
# belong to the same physical device, this is still treated as ambiguous
# rather than guessed - fail-closed, not fail-open.
# ---------------------------------------------------------------------------


def test_device_with_multiple_com_interfaces_is_conservatively_ambiguous():
    ports = [
        discovery.PortDescriptor(device="COM5", vid=discovery.NORMAL_MODE_VID, pid=discovery.NORMAL_MODE_PID, hwid="USB VID:PID=0483:5740 SER=ABC123 LOCATION=1-1:1.0"),
        discovery.PortDescriptor(device="COM6", vid=discovery.NORMAL_MODE_VID, pid=discovery.NORMAL_MODE_PID, hwid="USB VID:PID=0483:5740 SER=ABC123 LOCATION=1-1:1.1"),
    ]
    result = discovery.classify_ports(ports)
    assert result.status == "BLOCKED - AMBIGUOUS MULTIPLE DEVICES", (
        "documented, deliberate behavior: this tool does not attempt to "
        "infer 'same physical device, multiple interfaces' from hwid "
        "similarity - it fails closed and requires the operator to "
        "resolve the ambiguity rather than guessing which interface is "
        "the right one"
    )
