# Quality System Requirements (Part V)

Status: **specification only — no CI workflow changes were made in this
phase.** This document defines what a future CI implementation phase
must cover; it does not itself add or modify any
`.github/workflows/` file, consistent with this project's established
discipline of not broadly modifying CI without a specific, reviewed
reason.

## Required CI checks (target state, not yet implemented)

| Check | Purpose | Real precedent already in this repo |
|---|---|---|
| Manifest validation | Every `application.fam` parses and has required fields | None yet automated in CI; this phase's `hardware_app_tester.profile_schema` demonstrates the pattern for test profiles |
| Dependency validation | No app declares a dependency that doesn't exist | Not yet implemented |
| License validation | Every app has a resolvable license (or an explicitly accepted gap) | This phase's manual `docs/ecosystem/LICENSE_COMPATIBILITY_MATRIX.md` and the discovery that 3 of our own 20 apps lack a `LICENSE` file demonstrate exactly why this check matters |
| Provenance validation | Every app's source is traceable to a real commit/repository | This phase's `docs/ecosystem/SOURCE_PROVENANCE.md` demonstrates the real discipline (commit hash + license hash pinning) this check should enforce automatically |
| Duplicate app-ID detection | No two apps share an `appid` | Already implemented and unit-tested for the 20-app test-profile set: `tests/test_profile_schema.py::test_no_duplicate_app_ids_across_real_profiles` |
| Duplicate destination detection | No two apps install to the same path | Not yet implemented |
| API compatibility | Every app's declared API requirement matches the firmware's actual API version | Directly relevant given this phase's real finding that official firmware's API bumped 87.3→88.0 in the same commit that moved CCID out of core (see `docs/ecosystem/FEATURE_CENSUS.json`) |
| All-app compilation | Every app in the baseline actually builds | Already demonstrated (not by this phase) in this project's own prior CI history — this phase does not repeat that work |
| Unit tests | On-device logic tests pass | See `tests/on_device/` — architecture and candidates identified, no tests compiled/run yet |
| Static analysis | Standard C static analysis passes | Not assessed in this phase |
| Forbidden binary detection | No unexplained binary blobs are committed | Directly relevant given this phase's finding of 210 binary files under RogueMaster's `applications/external/` — this check exists specifically to prevent this project from silently absorbing unexplained blobs the way a naive "copy everything" import would |
| Asset validation | Referenced assets (icons, fonts, images) actually exist and are license-clear | Not assessed in this phase |
| Firmware-size budgets | Firmware/updater size stays within `docs/RESOURCE_BUDGETS.md` thresholds | Budget categories defined this phase; 2 of 8 have real numbers |
| RAM/heap budgets where measurable | Per-app heap delta stays within its profile's `maximum_heap_delta` | Schema field already defined and validated (`profile_schema.py`); real measurement requires hardware not available in this phase |
| Updater reproducibility | The same source produces the same updater artifact bytes | Not assessed in this phase — directly relevant to this project's own `tools/pre_flash_safeguard_gate.ps1` canonical-hash discipline |
| SBOM generation | A software bill of materials exists for every build | Not implemented; `docs/ecosystem/APP_CENSUS.json` is a real precedent for the kind of structured data an SBOM would need |
| Source-pin verification | Every imported app's recorded source commit still resolves | Directly automatable via the same technique this phase's census agents used (`git ls-remote`/clone + commit-hash comparison) — this is exactly RFC 6's proposed automation |
| Test-profile completeness | Every app has a valid `tests/hardware/apps/<app_id>.yaml` | Already implemented and enforced for the current 20-app baseline (`test_all_twenty_real_profiles_load_and_validate`) |
| Documentation consistency | Every app has provenance, license, owner/source, build result, automation class, test descriptor, inclusion decision, and maintenance status recorded somewhere | This phase's `docs/ecosystem/APP_CENSUS.json` schema is the real precedent for what a documentation-consistency check should verify exists per app |

## What every app must have (per this phase's mission, restated as a checklist)

- [ ] Provenance
- [ ] License
- [ ] Owner/source
- [ ] Build result
- [ ] Automation class
- [ ] Test descriptor
- [ ] Inclusion decision
- [ ] Maintenance status

For the current 20-app baseline, this phase provides: automation class
and test descriptor (100%, via `tests/hardware/apps/*.yaml`); provenance
and license (100%, already recorded in earlier phases'
`docs/CUSTOM_APP_INVENTORY.md`/`docs/THIRD_PARTY_LICENSE_AUDIT.md`, with
the 3-app license-file gap newly surfaced this phase); build result
(already established in earlier CI-validated phases, not repeated
here); inclusion decision (`ALREADY_INCLUDED`, per
`docs/ecosystem/APP_CENSUS.json`); maintenance status (not formally
tracked yet — a real gap, honestly disclosed, that RFC 1's Health
Center is designed to close).

## Why no CI workflow file was added in this phase

This phase's own boundaries emphasize architecture and audit work, and
this project's established discipline (from every prior pre-flash
safeguard phase) is to never broadly modify `.github/workflows/`
without a specific, narrow, reviewed reason. Defining the *target*
quality system here, and implementing it as an actual CI workflow in a
dedicated future phase with its own explicit review, is consistent with
that discipline.
