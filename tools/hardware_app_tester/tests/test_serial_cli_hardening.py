"""Regression tests for the two real bugs found and fixed during the
Gate A Windows-execution-package audit:

1. Prompt-detection comparison never matched a genuine prompt line
   (a string-stripping bug - `">: ".endswith(">:".strip())` is False).
2. send_command() could hang indefinitely if the underlying connection's
   own per-call timeout was None/unbounded - fixed by validating the
   connection's `.timeout` attribute at construction time.

Both use hardware_app_tester.mock_transport.FakeSerialConnection, a
synthetic in-process transport - not real hardware, but a real exercise
of the exact same FlipperCliClient code path a real device would run
through.
"""

import pytest

from hardware_app_tester.mock_transport import FakeSerialConnection
from hardware_app_tester.serial_cli import FlipperCliClient


def test_prompt_detection_now_recognizes_a_real_prompt_line():
    conn = FakeSerialConnection(timeout=0.2)
    conn.script("uptime", ["Uptime: 0d 00:01:23"])
    client = FlipperCliClient(conn, default_timeout=1.0)

    response = client.uptime()

    assert response.timed_out is False, (
        "prompt-detection bug regression: a scripted, well-formed "
        "response with a trailing prompt line must be recognized, not "
        "time out"
    )
    assert response.lines == ["Uptime: 0d 00:01:23"]


def test_unscripted_command_times_out_honestly_rather_than_hanging():
    conn = FakeSerialConnection(timeout=0.05)
    client = FlipperCliClient(conn, default_timeout=0.2)

    response = client.device_info()

    assert response.timed_out is True
    assert response.lines == []


def test_construction_rejects_connection_with_no_timeout_bound():
    class BlockForeverConn:
        timeout = None

        def write(self, data):
            pass

        def readline(self):
            return b""

    with pytest.raises(ValueError):
        FlipperCliClient(BlockForeverConn())


def test_construction_rejects_connection_with_excessive_timeout():
    class SlowConn:
        timeout = 30.0

        def write(self, data):
            pass

        def readline(self):
            return b""

    with pytest.raises(ValueError):
        FlipperCliClient(SlowConn())


def test_construction_accepts_a_reasonable_timeout():
    conn = FakeSerialConnection(timeout=0.2)
    # Should not raise.
    FlipperCliClient(conn)


def test_fake_transport_without_timeout_attribute_is_exempted():
    """Unit-test fakes with no `.timeout` attribute at all (the style
    already used by tests/test_no_destructive_capability.py) must
    continue to work unmodified - only a connection that explicitly
    declares a bad timeout is rejected."""

    class NoTimeoutAttrConn:
        def write(self, data):
            pass

        def readline(self):
            return b""

    FlipperCliClient(NoTimeoutAttrConn())  # should not raise
