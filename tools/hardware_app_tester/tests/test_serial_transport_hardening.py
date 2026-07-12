"""Regression tests for the Gate A serial-transport-hardening phase.

Context: a real Windows run against a real Flipper Zero (exact
VID_0483&PID_5740 identity, COM6, no ambiguity, no port contention)
reached Phase F - the read-only handshake - and the handshake
subprocess did not exit within a 30-second external watchdog: no
stdout, no stderr, no serial_handshake.json ever created, exit code 124
(killed). This file exercises, with FakeRawSerialConnection (a
synthetic in-process transport - not real hardware), every bounded
operation added or hardened to close every theoretically-hang-capable
gap identified from source inspection: an unbounded `write()` (no
`write_timeout` was previously set), and prompt detection that
previously depended on `readline()`'s line framing.
"""

from pathlib import Path

import pytest

from hardware_app_tester import cli
from hardware_app_tester.mock_transport import FakeRawSerialConnection
from hardware_app_tester.serial_cli import FlipperCliClient, TransportStage


def _client(conn, default_timeout=1.0):
    return FlipperCliClient(conn, default_timeout=default_timeout)


# ---------------------------------------------------------------------------
# 1. Prompt already available on open.
# ---------------------------------------------------------------------------


def test_prompt_already_available_before_any_write():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b">: ", delay_polls=0)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=1.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED
    assert response.timed_out is False
    # The blank-line write to *request* the prompt must never have been
    # needed/sent, since the prompt was already sitting in the buffer.
    assert conn.written == []


# ---------------------------------------------------------------------------
# 2/3/4. CRLF, LF-only, and no-trailing-newline prompt framing.
# ---------------------------------------------------------------------------


def test_prompt_with_crlf_framing():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b"some banner text\r\n>: \r\n", delay_polls=0)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=1.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED


def test_prompt_with_lf_only_framing():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b"some banner text\n>: \n", delay_polls=0)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=1.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED


def test_prompt_with_no_trailing_newline_at_all():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b">: ", delay_polls=0)  # no \r\n, no \n - just the prompt
    client = _client(conn)

    response = client.sync_to_prompt(timeout=1.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED, (
        "prompt detection must not depend on readline()'s line framing - "
        "a real device prompt with no trailing newline at all must still "
        "be recognized"
    )


# ---------------------------------------------------------------------------
# 5/7. Prompt fragmented across several reads, with empty reads in between.
# ---------------------------------------------------------------------------


def test_prompt_fragmented_across_several_reads_with_empty_polls_between():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    # Each fragment only becomes available on a later poll, forcing the
    # caller's read loop to make several read()/in_waiting calls (with
    # genuinely empty polls in between) before the full prompt is visible.
    conn.queue_bytes(b">", delay_polls=2)
    conn.queue_bytes(b":", delay_polls=4)
    conn.queue_bytes(b" ", delay_polls=6)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=2.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED
    assert response.raw_byte_count == 3


# ---------------------------------------------------------------------------
# 6. Banner followed by prompt.
# ---------------------------------------------------------------------------


def test_banner_followed_by_prompt():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b"Flipper Zero Serial Command Line\r\n", delay_polls=0)
    conn.queue_bytes(b"Firmware version: 1.0\r\n>: \r\n", delay_polls=3)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=2.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED
    assert "Flipper Zero Serial Command Line" in response.raw_bytes_sanitized


# ---------------------------------------------------------------------------
# 8. Prompt never arrives - bounded, not an indefinite hang.
# ---------------------------------------------------------------------------


def test_prompt_never_arrives_times_out_honestly_within_bound():
    conn = FakeRawSerialConnection(timeout=0.05, write_timeout=0.2)
    conn.queue_bytes(b"some banner with no prompt in it at all\r\n", delay_polls=0)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=0.3)

    assert response.stage == TransportStage.PROMPT_NOT_FOUND
    assert response.timed_out is True
    assert "some banner" in response.raw_bytes_sanitized


def test_prompt_never_arrives_with_zero_bytes_is_read_timeout_not_prompt_not_found():
    conn = FakeRawSerialConnection(timeout=0.05, write_timeout=0.2)
    client = _client(conn)

    response = client.sync_to_prompt(timeout=0.2)

    assert response.stage == TransportStage.READ_TIMEOUT
    assert response.raw_byte_count == 0


# ---------------------------------------------------------------------------
# 9/10. Write blocks until write timeout / raises SerialTimeoutException.
# ---------------------------------------------------------------------------


def test_write_timeout_is_a_distinct_bounded_stage_not_a_hang():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.raise_write_timeout_on_next_write()
    client = _client(conn)

    response = client.send_command("uptime", timeout=1.0)

    assert response.stage == TransportStage.WRITE_TIMEOUT
    assert response.timed_out is True
    assert response.exception_type == "SerialTimeoutException"


def test_write_timeout_during_prompt_sync_is_reported_not_swallowed():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.raise_write_timeout_on_next_write()
    client = _client(conn)

    response = client.sync_to_prompt(timeout=1.0)

    assert response.stage == TransportStage.WRITE_TIMEOUT
    assert response.exception_type == "SerialTimeoutException"


# ---------------------------------------------------------------------------
# 11. Serial device disconnects while reading.
# ---------------------------------------------------------------------------


def test_disconnection_while_reading_is_detected_not_hung():
    conn = FakeRawSerialConnection(timeout=0.05, write_timeout=0.2)
    conn.disconnect_after_reads(1)
    client = _client(conn)

    response = client.send_command("uptime", timeout=1.0)

    assert response.stage == TransportStage.SERIAL_DISCONNECTED
    assert response.timed_out is True


# ---------------------------------------------------------------------------
# 12. Invalid UTF-8 bytes are preserved and decoded safely.
# ---------------------------------------------------------------------------


def test_invalid_utf8_bytes_are_preserved_and_do_not_crash_decoding():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    # 0xFF is never valid as a UTF-8 continuation/leading byte.
    conn.queue_bytes(b"Uptime: 0d 00:00:05 \xff\xfe garbage\r\n>: \r\n", delay_polls=0)
    client = _client(conn)

    response = client.send_command("uptime", timeout=1.0)

    assert response.stage == TransportStage.DECODE_WARNING
    assert response.decode_warning is True
    assert response.timed_out is False, (
        "a decode warning is not a timeout - the command DID complete, "
        "just with some non-UTF-8 bytes in the response"
    )
    assert "\\xff" in response.raw_bytes_sanitized or "\\xfe" in response.raw_bytes_sanitized


# ---------------------------------------------------------------------------
# 13/14. One command succeeds; first succeeds, second times out.
# ---------------------------------------------------------------------------


def test_one_command_succeeds_cleanly():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b"Uptime: 0d 00:01:00\r\n>: \r\n", delay_polls=0)
    client = _client(conn)

    response = client.send_command("uptime", timeout=1.0)

    assert response.stage == TransportStage.COMMAND_COMPLETED
    assert response.lines == ["Uptime: 0d 00:01:00"]


def test_first_command_succeeds_second_times_out(tmp_path, monkeypatch):
    conn = FakeRawSerialConnection(timeout=0.05, write_timeout=0.2)
    # Gated on write count so each stage only sees its own response:
    # write #1 is prompt-sync's blank-line request, write #2 is uptime.
    conn.queue_bytes(b">: ", after_writes=1)
    conn.queue_bytes(b"Uptime: 0d 00:00:05\r\n>: \r\n", after_writes=2)
    # No further bytes queued - loader info (write #3) will time out.

    monkeypatch.setattr(cli, "_open_real_serial_connection", lambda port, **kw: conn)

    output_path = tmp_path / "handshake.json"

    class Args:
        port = "COM6"
        dry_run = False
        output = str(output_path)

    exit_code = cli.cmd_handshake(Args())

    assert exit_code == 1
    result = __import__("json").loads(output_path.read_text())
    stage_names = [s["stage"] for s in result["stages"]]
    assert "UPTIME_PASS" in stage_names
    assert "LOADER_INFO_FAIL" in stage_names
    # "Do not proceed to the second command if the first command leaves
    # transport state uncertain" - here the *first* real command
    # (uptime) succeeded, so loader_info WAS correctly attempted, but
    # free_heap must NOT be, since loader_info itself then failed.
    assert "FREE_HEAP_START" not in stage_names


# ---------------------------------------------------------------------------
# 15. Evidence exists before serial open.
# ---------------------------------------------------------------------------


def test_evidence_file_exists_before_serial_open_is_even_attempted(tmp_path, monkeypatch):
    opened = {"called": False}

    def fake_open(port, **kwargs):
        opened["called"] = True
        raise OSError("simulated open failure - port never actually touched")

    monkeypatch.setattr(cli, "_open_real_serial_connection", fake_open)

    output_path = tmp_path / "handshake.json"

    class Args:
        port = "COM6"
        dry_run = False
        output = str(output_path)

    cli.cmd_handshake(Args())

    assert opened["called"] is True
    result = __import__("json").loads(output_path.read_text())
    stage_names = [s["stage"] for s in result["stages"]]
    assert stage_names[0] == "PROCESS_STARTED"
    assert "SERIAL_OPEN_START" in stage_names
    assert "SERIAL_OPEN_FAIL" in stage_names
    assert result["status"] == "BLOCKED - SERIAL OPEN FAILED"


# ---------------------------------------------------------------------------
# 16. Every stage updates evidence atomically - each recorded stage is
# genuinely present and in order in the final file.
# ---------------------------------------------------------------------------


def test_every_expected_stage_is_recorded_in_order_for_a_clean_handshake(tmp_path, monkeypatch):
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    # Gated on write count so each of the four writes (prompt-sync's
    # blank line, then uptime/loader info/free) only sees its own reply.
    conn.queue_bytes(b">: ", after_writes=1)
    conn.queue_bytes(b"Uptime: 0d 00:00:05\r\n>: \r\n", after_writes=2)
    conn.queue_bytes(b"Firmware is not running any application\r\n>: \r\n", after_writes=3)
    conn.queue_bytes(b"Free heap size: 100000 bytes\r\n>: \r\n", after_writes=4)

    monkeypatch.setattr(cli, "_open_real_serial_connection", lambda port, **kw: conn)

    output_path = tmp_path / "handshake.json"

    class Args:
        port = "COM6"
        dry_run = False
        output = str(output_path)

    exit_code = cli.cmd_handshake(Args())

    assert exit_code == 0
    result = __import__("json").loads(output_path.read_text())
    stage_names = [s["stage"] for s in result["stages"]]
    expected_order = [
        "PROCESS_STARTED",
        "SERIAL_OPEN_START",
        "SERIAL_OPEN_PASS",
        "PROMPT_SYNC_START",
        "PROMPT_SYNC_PASS",
        "UPTIME_START",
        "UPTIME_PASS",
        "LOADER_INFO_START",
        "LOADER_INFO_PASS",
        "FREE_HEAP_START",
        "FREE_HEAP_PASS",
        "SERIAL_CLOSE_START",
        "SERIAL_CLOSE_PASS",
        "FINAL_CLASSIFICATION",
    ]
    assert stage_names == expected_order
    assert result["status"] == "PASS"
    assert result["applications_launched"] is False
    assert result["firmware_operations_performed"] is False


# ---------------------------------------------------------------------------
# 18. No application command is ever sent by probe-serial or handshake.
# ---------------------------------------------------------------------------


def test_handshake_never_sends_an_application_launch_command(tmp_path, monkeypatch):
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b">: ", delay_polls=0)
    conn.queue_bytes(b"Uptime: 0d 00:00:05\r\n>: \r\n", delay_polls=0)
    conn.queue_bytes(b"Firmware is not running any application\r\n>: \r\n", delay_polls=0)
    conn.queue_bytes(b"Free heap size: 100000 bytes\r\n>: \r\n", delay_polls=0)

    monkeypatch.setattr(cli, "_open_real_serial_connection", lambda port, **kw: conn)

    output_path = tmp_path / "handshake.json"

    class Args:
        port = "COM6"
        dry_run = False
        output = str(output_path)

    cli.cmd_handshake(Args())

    sent = [w.decode("utf-8", errors="replace") for w in conn.written]
    assert not any("loader open" in s for s in sent)
    assert not any("format" in s.lower() for s in sent)
    assert not any("update" in s.lower() for s in sent)


def test_probe_serial_never_sends_an_application_launch_command(tmp_path, monkeypatch):
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.queue_bytes(b">: ", after_writes=1)
    conn.queue_bytes(b"Uptime: 0d 00:00:05\r\n>: \r\n", after_writes=2)

    monkeypatch.setattr(cli, "_open_real_serial_connection", lambda port, **kw: conn)

    output_path = tmp_path / "probe.json"

    class Args:
        port = "COM6"
        command = "uptime"
        dry_run = False
        output = str(output_path)

    exit_code = cli.cmd_probe_serial(Args())

    assert exit_code == 0
    sent = [w.decode("utf-8", errors="replace") for w in conn.written]
    assert not any("loader open" in s for s in sent)
    result = __import__("json").loads(output_path.read_text())
    assert result["status"] == "SERIAL PROBE PASS"
    assert result["applications_launched"] is False
    assert result["firmware_operations_performed"] is False


def test_probe_serial_write_timeout_classification():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.2)
    conn.raise_write_timeout_on_next_write()

    import hardware_app_tester.cli as cli_module

    orig_open = cli_module._open_real_serial_connection
    cli_module._open_real_serial_connection = lambda port, **kw: conn
    try:
        class Args:
            port = "COM6"
            command = "uptime"
            dry_run = False
            output = None

        exit_code = cli_module.cmd_probe_serial(Args())
    finally:
        cli_module._open_real_serial_connection = orig_open

    assert exit_code == 1


def test_probe_serial_command_timeout_classification(tmp_path, monkeypatch):
    conn = FakeRawSerialConnection(timeout=0.05, write_timeout=0.2)
    conn.queue_bytes(b">: ", delay_polls=0)  # prompt sync succeeds
    # No bytes queued for the uptime command itself - it will time out.

    monkeypatch.setattr(cli, "_open_real_serial_connection", lambda port, **kw: conn)

    output_path = tmp_path / "probe.json"

    class Args:
        port = "COM6"
        command = "uptime"
        dry_run = False
        output = str(output_path)

    exit_code = cli.cmd_probe_serial(Args())

    assert exit_code == 1
    result = __import__("json").loads(output_path.read_text())
    assert result["status"] == "SERIAL PROBE BLOCKED - COMMAND TIMEOUT"


def test_probe_serial_open_failed_classification(tmp_path, monkeypatch):
    def fake_open(port, **kwargs):
        raise OSError("simulated port not found")

    monkeypatch.setattr(cli, "_open_real_serial_connection", fake_open)
    output_path = tmp_path / "probe.json"

    class Args:
        port = "COM6"
        command = "uptime"
        dry_run = False
        output = str(output_path)

    exit_code = cli.cmd_probe_serial(Args())

    assert exit_code == 1
    result = __import__("json").loads(output_path.read_text())
    assert result["status"] == "SERIAL PROBE BLOCKED - OPEN FAILED"


# ---------------------------------------------------------------------------
# Constructor validation of write_timeout (Part 1).
# ---------------------------------------------------------------------------


def test_construction_rejects_connection_with_no_write_timeout_bound():
    class BlockForeverWriteConn:
        timeout = 0.2
        write_timeout = None

        def write(self, data):
            pass

        def read(self, size=1):
            return b""

    with pytest.raises(ValueError):
        FlipperCliClient(BlockForeverWriteConn())


def test_construction_rejects_connection_with_excessive_write_timeout():
    class SlowWriteConn:
        timeout = 0.2
        write_timeout = 30.0

        def write(self, data):
            pass

        def read(self, size=1):
            return b""

    with pytest.raises(ValueError):
        FlipperCliClient(SlowWriteConn())


def test_construction_accepts_a_reasonable_write_timeout():
    conn = FakeRawSerialConnection(timeout=0.2, write_timeout=0.5)
    FlipperCliClient(conn)  # should not raise
