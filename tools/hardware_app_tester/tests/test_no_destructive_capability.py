"""Source-text grep test proving the tester package contains no
flashing/update/repair/erase/format command anywhere - the same
discipline used by tools/pre_flash_safeguard_gate.tests.ps1's own
"zero-flash guarantee" regression test.
"""

from pathlib import Path

PACKAGE_DIR = Path(__file__).resolve().parents[1] / "hardware_app_tester"

FORBIDDEN_SUBSTRINGS = [
    "storage format",
    "update install",
    "dfu-util",
    "ST-LINK_CLI",
    "STM32CubeProgrammer",
    "qFlipper.exe",
    "enter_dfu",
    "reboot_to_dfu",
    "flash_firmware",
]


def test_no_forbidden_command_strings_anywhere_in_package():
    """A forbidden substring is only acceptable when it appears as a
    blocklist entry (a line mentioning 'FORBIDDEN', e.g.
    FORBIDDEN_COMMAND_PREFIXES) - never in a context that could send it.
    """
    offenders = []
    for path in PACKAGE_DIR.glob("*.py"):
        in_blocklist_block = False
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if "forbidden" in line.lower():
                in_blocklist_block = "(" in line and ")" not in line
                continue
            lowered = stripped.lower()
            for forbidden in FORBIDDEN_SUBSTRINGS:
                if forbidden.lower() in lowered and not in_blocklist_block:
                    offenders.append((str(path), forbidden, stripped))
            if in_blocklist_block and stripped.endswith(")"):
                in_blocklist_block = False
    assert offenders == [], f"Forbidden command strings found outside a blocklist context: {offenders}"


def test_serial_cli_rejects_forbidden_command_prefixes():
    import importlib
    import sys

    sys.path.insert(0, str(PACKAGE_DIR.parent))
    serial_cli = importlib.import_module("hardware_app_tester.serial_cli")

    class FakeConn:
        def write(self, data):
            pass

        def readline(self):
            return b""

    client = serial_cli.FlipperCliClient(FakeConn(), default_timeout=0.01)
    try:
        client.send_command("update install")
        assert False, "expected ForbiddenCommandError"
    except serial_cli.ForbiddenCommandError:
        pass

    try:
        client.send_command("storage format /ext")
        assert False, "expected ForbiddenCommandError"
    except serial_cli.ForbiddenCommandError:
        pass
