"""Schema and loader for tests/hardware/apps/<app_id>.yaml test profiles.

This module only validates structure - it does not run any test itself.
"""

from __future__ import annotations

import dataclasses
from pathlib import Path
from typing import Any, Dict, List, Optional

import yaml

VALID_AUTOMATION_CLASSES = {
    "SAFE_AUTOMATION",
    "FIXTURE_REQUIRED",
    "MANUAL_VISUAL_REQUIRED",
    "PROHIBITED_AUTOMATION",
    "NOT_SUPPORTED",
}

REQUIRED_FIELDS = [
    "app_id",
    "display_name",
    "category",
    "source_path",
    "launch_type",
    "launch_target",
    "automation_class",
    "timeout_seconds",
    "expected_initial_state",
    "input_sequence",
    "expected_state_transitions",
    "exit_method",
    "maximum_heap_delta",
    "forbidden_operations",
    "required_fixture",
    "screenshot_masks",
    "known_nondeterministic_regions",
    "expected_log_patterns",
    "forbidden_log_patterns",
]

VALID_LAUNCH_TYPES = {"built-in", "external-fap"}


class ProfileValidationError(ValueError):
    pass


@dataclasses.dataclass
class TestProfile:
    app_id: str
    display_name: str
    category: str
    source_path: str
    launch_type: str
    launch_target: str
    automation_class: str
    timeout_seconds: int
    expected_initial_state: str
    input_sequence: List[str]
    expected_state_transitions: List[str]
    exit_method: str
    maximum_heap_delta: int
    forbidden_operations: List[str]
    required_fixture: Optional[str]
    screenshot_masks: List[str]
    known_nondeterministic_regions: List[str]
    expected_log_patterns: List[str]
    forbidden_log_patterns: List[str]
    raw: Dict[str, Any] = dataclasses.field(default_factory=dict, repr=False)


def validate_profile_dict(data: Dict[str, Any], source_file: str = "<dict>") -> None:
    missing = [f for f in REQUIRED_FIELDS if f not in data]
    if missing:
        raise ProfileValidationError(
            f"{source_file}: missing required field(s): {', '.join(missing)}"
        )

    if data["automation_class"] not in VALID_AUTOMATION_CLASSES:
        raise ProfileValidationError(
            f"{source_file}: automation_class '{data['automation_class']}' "
            f"is not one of {sorted(VALID_AUTOMATION_CLASSES)}"
        )

    if data["launch_type"] not in VALID_LAUNCH_TYPES:
        raise ProfileValidationError(
            f"{source_file}: launch_type '{data['launch_type']}' is not "
            f"one of {sorted(VALID_LAUNCH_TYPES)}"
        )

    if not isinstance(data["timeout_seconds"], int) or data["timeout_seconds"] <= 0:
        raise ProfileValidationError(
            f"{source_file}: timeout_seconds must be a positive integer"
        )

    if data["automation_class"] == "FIXTURE_REQUIRED" and not data.get(
        "required_fixture"
    ):
        raise ProfileValidationError(
            f"{source_file}: automation_class is FIXTURE_REQUIRED but "
            "required_fixture is empty"
        )

    # Never allow a "safe automation" profile to declare a forbidden
    # radio/security operation as part of its own input sequence.
    forbidden_terms = (
        "subghz",
        "sub-ghz",
        "infrared_tx",
        "ir_tx",
        "nfc_write",
        "nfc_emulate",
        "rfid_write",
        "ibutton_write",
        "badusb_run",
        "hid_inject",
        "ble_control",
        "gpio_output",
        "factory_reset",
        "format_sd",
        "format_storage",
        "firmware_update",
        "recovery",
        "repair",
    )
    if data["automation_class"] == "SAFE_AUTOMATION":
        haystack = " ".join(str(x).lower() for x in data.get("input_sequence", []))
        for term in forbidden_terms:
            if term in haystack:
                raise ProfileValidationError(
                    f"{source_file}: SAFE_AUTOMATION profile's "
                    f"input_sequence references forbidden operation "
                    f"'{term}'"
                )


def load_profile(path: Path) -> TestProfile:
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ProfileValidationError(f"{path}: profile must be a YAML mapping")
    validate_profile_dict(data, source_file=str(path))
    return TestProfile(
        app_id=data["app_id"],
        display_name=data["display_name"],
        category=data["category"],
        source_path=data["source_path"],
        launch_type=data["launch_type"],
        launch_target=data["launch_target"],
        automation_class=data["automation_class"],
        timeout_seconds=data["timeout_seconds"],
        expected_initial_state=data["expected_initial_state"],
        input_sequence=data["input_sequence"] or [],
        expected_state_transitions=data["expected_state_transitions"] or [],
        exit_method=data["exit_method"],
        maximum_heap_delta=data["maximum_heap_delta"],
        forbidden_operations=data["forbidden_operations"] or [],
        required_fixture=data.get("required_fixture"),
        screenshot_masks=data["screenshot_masks"] or [],
        known_nondeterministic_regions=data["known_nondeterministic_regions"] or [],
        expected_log_patterns=data["expected_log_patterns"] or [],
        forbidden_log_patterns=data["forbidden_log_patterns"] or [],
        raw=data,
    )


def load_all_profiles(directory: Path) -> Dict[str, TestProfile]:
    profiles: Dict[str, TestProfile] = {}
    for path in sorted(directory.glob("*.yaml")):
        profile = load_profile(path)
        if profile.app_id in profiles:
            raise ProfileValidationError(
                f"Duplicate app_id '{profile.app_id}' in {path} and "
                f"an earlier profile"
            )
        profiles[profile.app_id] = profile
    return profiles
