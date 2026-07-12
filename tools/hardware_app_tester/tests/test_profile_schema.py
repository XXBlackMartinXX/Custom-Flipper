from pathlib import Path

import pytest

from hardware_app_tester.profile_schema import (
    ProfileValidationError,
    load_all_profiles,
    validate_profile_dict,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
PROFILES_DIR = REPO_ROOT / "tests" / "hardware" / "apps"

EXPECTED_APP_IDS = {
    "network_subnet",
    "programmer_calc",
    "vin_decoder",
    "flipper95",
    "chess",
    "flipfetch",
    "quadratic_solver",
    "sudoku",
    "sd_info",
    "docviewlite",
    "resistors",
    "crypto_dictionary",
    "2048",
    "image_viewer",
    "fap_boilerplate",
    "minesweeper_redux",
    "qrcode",
    "hex_viewer",
    "barcode_app",
    "fcc_id_lookup",
}


def _minimal_valid_profile(**overrides):
    base = {
        "app_id": "example_app",
        "display_name": "Example App",
        "category": "Tools",
        "source_path": "applications_user/example_app",
        "launch_type": "external-fap",
        "launch_target": "/ext/apps/Tools/example_app.fap",
        "automation_class": "SAFE_AUTOMATION",
        "timeout_seconds": 10,
        "expected_initial_state": "main_menu",
        "input_sequence": ["OK", "BACK"],
        "expected_state_transitions": ["main_menu -> submenu", "submenu -> main_menu"],
        "exit_method": "back",
        "maximum_heap_delta": 2048,
        "forbidden_operations": [],
        "required_fixture": None,
        "screenshot_masks": [],
        "known_nondeterministic_regions": [],
        "expected_log_patterns": [],
        "forbidden_log_patterns": ["panic", "hardfault"],
    }
    base.update(overrides)
    return base


def test_minimal_valid_profile_passes():
    validate_profile_dict(_minimal_valid_profile())


def test_missing_field_rejected():
    data = _minimal_valid_profile()
    del data["timeout_seconds"]
    with pytest.raises(ProfileValidationError):
        validate_profile_dict(data)


def test_invalid_automation_class_rejected():
    data = _minimal_valid_profile(automation_class="YOLO_AUTOMATION")
    with pytest.raises(ProfileValidationError):
        validate_profile_dict(data)


def test_fixture_required_without_fixture_rejected():
    data = _minimal_valid_profile(
        automation_class="FIXTURE_REQUIRED", required_fixture=None
    )
    with pytest.raises(ProfileValidationError):
        validate_profile_dict(data)


def test_safe_automation_cannot_reference_forbidden_operation():
    data = _minimal_valid_profile(input_sequence=["OK", "subghz_transmit"])
    with pytest.raises(ProfileValidationError):
        validate_profile_dict(data)


def test_all_twenty_real_profiles_load_and_validate():
    profiles = load_all_profiles(PROFILES_DIR)
    assert set(profiles.keys()) == EXPECTED_APP_IDS, (
        f"Profile directory {PROFILES_DIR} does not exactly match the "
        f"expected 20-app set. Missing: "
        f"{EXPECTED_APP_IDS - set(profiles.keys())}, "
        f"Unexpected: {set(profiles.keys()) - EXPECTED_APP_IDS}"
    )


def test_no_duplicate_app_ids_across_real_profiles():
    profiles = load_all_profiles(PROFILES_DIR)
    assert len(profiles) == len(EXPECTED_APP_IDS)
