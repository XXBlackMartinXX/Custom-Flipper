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


def _parse_appid_from_fam(fam_path: Path) -> Optional[str]:
    """Best-effort, real (not guessed) extraction of the `appid = "..."`
    field from an application.fam file. application.fam is a Python
    literal (App(...) constructor call), not YAML/JSON/TOML, so this
    uses a narrow, explicit regex rather than attempting to actually
    execute or fully parse the file - the same technique already used
    manually (via grep) to build tests/hardware/apps/*.yaml in the prior
    phase's real per-app source inspection.
    """
    import re

    if not fam_path.is_file():
        return None
    text = fam_path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r'appid\s*=\s*"([^"]+)"', text)
    return match.group(1) if match else None


@dataclasses.dataclass
class RepositoryValidationIssue:
    app_id: str
    issue: str


def validate_profile_against_repository(
    profile: TestProfile, repo_root: Path
) -> List[RepositoryValidationIssue]:
    """Cross-checks one profile against the real repository on disk:
    source_path exists, its application.fam's real appid matches
    profile.launch_target (the actual `loader open` argument - this is
    the field that must match the device's own notion of the app's
    identity, not the mission-naming `app_id` slug used for the YAML
    filename), and launch_target is non-empty. Returns a list of
    human-readable issues (empty list = no issues) rather than raising,
    so a caller can accumulate issues across all 20 profiles before
    deciding whether to proceed.
    """
    issues: List[RepositoryValidationIssue] = []

    if not profile.launch_target or not profile.launch_target.strip():
        issues.append(
            RepositoryValidationIssue(
                profile.app_id, "launch_target is empty/not explicit"
            )
        )

    source_dir = repo_root / profile.source_path
    if not source_dir.is_dir():
        issues.append(
            RepositoryValidationIssue(
                profile.app_id,
                f"source_path '{profile.source_path}' does not exist "
                f"under repository root {repo_root}",
            )
        )
        return issues  # can't check the manifest if the directory is missing

    fam_path = source_dir / "application.fam"
    real_appid = _parse_appid_from_fam(fam_path)
    if real_appid is None:
        issues.append(
            RepositoryValidationIssue(
                profile.app_id,
                f"could not read a real appid from "
                f"{fam_path} (missing file, or no appid=\"...\" field found)",
            )
        )
    elif real_appid != profile.launch_target:
        issues.append(
            RepositoryValidationIssue(
                profile.app_id,
                f"profile launch_target '{profile.launch_target}' does "
                f"not match the real appid '{real_appid}' declared in "
                f"{fam_path}",
            )
        )

    return issues


def validate_all_profiles_against_repository(
    profiles: Dict[str, TestProfile], repo_root: Path
) -> List[RepositoryValidationIssue]:
    all_issues: List[RepositoryValidationIssue] = []
    for profile in profiles.values():
        all_issues.extend(validate_profile_against_repository(profile, repo_root))
    return all_issues
