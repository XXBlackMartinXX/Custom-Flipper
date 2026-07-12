from hardware_app_tester.discovery import PortDescriptor, classify_ports


def test_exact_normal_mode_pass():
    ports = [
        PortDescriptor(device="COM5", vid=0x0483, pid=0x5740, description="Flipper"),
    ]
    result = classify_ports(ports)
    assert result.status == "PASS"
    assert result.port is not None
    assert result.port.device == "COM5"


def test_dfu_only_blocked_not_pass():
    ports = [
        PortDescriptor(device="COM6", vid=0x0483, pid=0xDF11, description="STM32 BOOTLOADER"),
    ]
    result = classify_ports(ports)
    assert result.status.startswith("BLOCKED")
    assert "DFU MODE" in result.status
    assert result.port is None


def test_no_devices_blocked():
    result = classify_ports([])
    assert result.status.startswith("BLOCKED")
    assert result.port is None


def test_ambiguous_multiple_devices_blocked():
    ports = [
        PortDescriptor(device="COM5", vid=0x0483, pid=0x5740),
        PortDescriptor(device="COM7", vid=0x0483, pid=0x5740),
    ]
    result = classify_ports(ports)
    assert result.status == "BLOCKED - AMBIGUOUS MULTIPLE DEVICES"
    assert result.port is None


def test_port_contention_blocked():
    ports = [
        PortDescriptor(
            device="COM5", vid=0x0483, pid=0x5740, in_use_by_other_process=True
        ),
    ]
    result = classify_ports(ports)
    assert result.status == "BLOCKED - PORT CONTENTION"
    assert result.port is None


def test_generic_dfu_named_device_never_passes():
    """Regression: a device with a generic 'DFU'/'Bootloader' name but
    an unrelated VID:PID must never be classified as our DFU or normal
    device - exact identity only, mirroring the PowerShell gate fix.
    """
    ports = [
        PortDescriptor(
            device="COM9",
            vid=0x04F2,
            pid=0xB83E,
            description="Camera DFU Device",
        ),
    ]
    result = classify_ports(ports)
    assert result.status.startswith("BLOCKED")
    assert result.status != "PASS"
    assert result.port is None


def test_camera_dfu_plus_real_normal_mode_still_passes_on_exact_match():
    ports = [
        PortDescriptor(device="COM9", vid=0x04F2, pid=0xB83E, description="Camera DFU Device"),
        PortDescriptor(device="COM5", vid=0x0483, pid=0x5740, description="Flipper"),
    ]
    result = classify_ports(ports)
    assert result.status == "PASS"
    assert result.port.device == "COM5"


def test_dfu_present_alongside_normal_mode_does_not_block_normal_detection():
    """A device transitioning through DFU while another (or the same,
    re-enumerating) port shows normal mode should not itself block -
    this mirrors the sequential-state fix in
    tools/pre_flash_safeguard_gate.ps1's RecoveryReadiness logic. This
    tester only ever targets normal-mode operation, so a normal-mode
    match takes priority whenever both classes of identity are present.
    """
    ports = [
        PortDescriptor(device="COM5", vid=0x0483, pid=0x5740),
        PortDescriptor(device="COM6", vid=0x0483, pid=0xDF11),
    ]
    result = classify_ports(ports)
    assert result.status == "PASS"
    assert result.port.device == "COM5"
