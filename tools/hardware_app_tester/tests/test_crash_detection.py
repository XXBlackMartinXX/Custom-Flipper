"""Dedicated regression tests for hardware_app_tester.crash_detection -
this module previously had zero direct unit tests (an audit gap found
and closed in the Gate A Windows-execution-package phase), even though
its logic is exactly what decides whether an uptime reset, USB
disappearance, heap regression, or panic log is caught.
"""

from hardware_app_tester.crash_detection import (
    DeviceStateSnapshot,
    any_failed,
    any_needs_review,
    check_heap_regression,
    check_loader_returned_to_idle,
    check_uptime_continuity,
    check_usb_continuity,
    evaluate_all,
    scan_log_lines_for_panic,
)


def _snap(uptime_ms=1000, heap=50000, loader="idle", usb=True):
    return DeviceStateSnapshot(
        uptime_ms=uptime_ms, free_heap_bytes=heap, loader_state=loader, usb_present=usb
    )


def test_uptime_reset_detected():
    before = _snap(uptime_ms=5000)
    after = _snap(uptime_ms=200)  # device rebooted, uptime went backwards
    result = check_uptime_continuity(before, after)
    assert result.status == "FAIL - UNEXPECTED REBOOT DETECTED"


def test_uptime_continuity_normal_case_passes():
    before = _snap(uptime_ms=5000)
    after = _snap(uptime_ms=5500)
    result = check_uptime_continuity(before, after)
    assert result.status == "PASS"


def test_usb_disappearance_detected():
    before = _snap(usb=True)
    after = _snap(usb=False)
    result = check_usb_continuity(before, after)
    assert result.status == "FAIL - USB DISAPPEARED"


def test_usb_continuity_normal_case_passes():
    before = _snap(usb=True)
    after = _snap(usb=True)
    assert check_usb_continuity(before, after).status == "PASS"


def test_heap_regression_beyond_threshold_needs_review():
    before = _snap(heap=50000)
    after = _snap(heap=10000)  # dropped 40000 bytes
    result = check_heap_regression(before, after, maximum_heap_delta=4096)
    assert result.status == "NEEDS_REVIEW - HEAP DELTA EXCEEDS PROFILE THRESHOLD"


def test_heap_within_threshold_passes():
    before = _snap(heap=50000)
    after = _snap(heap=49000)  # dropped 1000 bytes
    result = check_heap_regression(before, after, maximum_heap_delta=4096)
    assert result.status == "PASS"


def test_loader_not_idle_after_exit_fails():
    after = _snap(loader="some_other_app")
    result = check_loader_returned_to_idle(after, expected_idle_state="idle")
    assert result.status == "FAIL - LOADER DID NOT RETURN TO IDLE"


def test_loader_idle_after_exit_passes():
    after = _snap(loader="idle")
    assert check_loader_returned_to_idle(after).status == "PASS"


def test_panic_marker_detected_in_logs():
    result = scan_log_lines_for_panic(["some normal line", "PANIC: stack overflow"])
    assert result.status == "FAIL - PANIC/FAULT LOG DETECTED"


def test_hardfault_marker_detected():
    result = scan_log_lines_for_panic(["HardFault_Handler triggered"])
    assert result.status == "FAIL - PANIC/FAULT LOG DETECTED"


def test_no_panic_marker_passes():
    result = scan_log_lines_for_panic(["normal log line", "another normal line"])
    assert result.status == "PASS"


def test_evaluate_all_flags_any_failed():
    before = _snap(uptime_ms=5000, usb=True)
    after = _snap(uptime_ms=100, usb=True)  # uptime reset
    results = evaluate_all(before, after, maximum_heap_delta=4096)
    assert any_failed(results) is True


def test_evaluate_all_flags_any_needs_review():
    before = _snap(heap=50000)
    after = _snap(heap=1000)  # large heap drop, but no reboot/USB-loss
    results = evaluate_all(before, after, maximum_heap_delta=4096)
    assert any_needs_review(results) is True
    assert any_failed(results) is False


def test_evaluate_all_clean_run_has_no_failures_or_reviews():
    before = _snap()
    after = _snap()
    results = evaluate_all(before, after, maximum_heap_delta=4096)
    assert any_failed(results) is False
    assert any_needs_review(results) is False
    assert all(r.status == "PASS" for r in results)
