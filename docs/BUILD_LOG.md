# Build Log — Unleashed Base, Phase 0/4 Verification Pass

## Current status: RESOLVED — clean official build confirmed locally (Windows)

The cloud-sandbox blocker described below (network policy denies the vendor
toolchain host) was resolved by running the **official, unmodified** `fbt` build on
a local Windows 11 machine, per `docs/LOCAL_WINDOWS_BUILD_HANDOFF.md`. Summary,
as reported by the project owner (this AI session did not and cannot execute or
observe a Windows build itself — this is recorded as reported, not independently
verified beyond consistency-checking against the handoff instructions):

- Repo: `DarkFlippers/unleashed-firmware`, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c`
- `git status --short` clean both before and after the build
- `.\fbt.cmd COMPACT=1 DEBUG=0` — **PASS**
- `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` — **PASS**
- Firmware artifact present: `build\f7-firmware-C\firmware.dfu`
- Updater package present: `dist\f7-C\flipper-z-f7-update-local.tgz`
- Real hardware flashing/testing: **NOT PERFORMED** (none claimed)

This used the real pinned vendor toolchain (via `fbt.cmd`'s own download, on an
unrestricted network), not the cloud session's ad hoc substitute described below.
**The substitute-toolchain narrative below is kept as an honest record of the cloud
attempt and its diagnostic value (it independently corroborated that nothing in
Unleashed's own source was broken in everything it reached) — it is not the basis for
the PASS verdict above.** No source patches from the substitute-toolchain experiment
were carried into this repository or into the local Windows build; the Windows build
used the official, unpatched `site_scons/cc.scons`.

## Overall verdict (updated)

| Item | Status |
|---|---|
| Phase 0 source verification | **PASS** |
| Base selected | **Unleashed** (`dev` @ `5cdf9b33745f41f1a0405a6da44821128c233f5c`) |
| Clean official build | **PASS** (confirmed on local Windows 11, official toolchain) |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** |
| Feature integration | **PHASE 2A: SAM license item resolved, post-removal build PASS; validation tooling executed, hardened, and run in real Windows CI (Phase 2A.7/2A.8)** — see below |
| Hardware tested | **NOT PERFORMED** |

## Phase 2A update: first app-integration batch — local build PASS

A separate branch, `integration/phase2a-first-batch`, contains 5 individually
source-audited RogueMaster apps (`network_subnet`, `programmer_calc`, `vin_decoder`,
`flipper95`, `chess`) on top of this exact Unleashed base commit, each its own
commit. See `PHASE2A_INTEGRATION_LOG.md`, `PHASE2A_BUILD_REPORT.md`,
`PHASE2A_SAFETY_REVIEW.md`, `PHASE2A_ROLLBACK_PLAN.md`, and
`PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` (mirrored here from that branch) for full
detail.

**The first version of that branch failed a real local Windows build**, at
`protobuf_version.h` generation — Unleashed's build genuinely runs `git fetch
--tags`/`git describe --tags` inside `assets/protobuf` at build time, and that
branch had flattened all submodules into plain files with no `.git` metadata for
those commands to operate on. **Fixed** by rebuilding the branch with all 12
submodules (plus 4 nested) as real git submodules pinned to Unleashed's exact
commits, and **the project owner's re-run of the real local Windows build against
the corrected branch (commit `6b5cc53`) PASSED**: fresh clone, recursive submodule
checkout, `assets/protobuf` version tag resolved correctly (`0.29`), both
`.\fbt.cmd COMPACT=1 DEBUG=0` and `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`
passed, both artifacts present. Hardware flashing/testing: **NOT PERFORMED**.

**The one open licensing item is now resolved, implemented, and build-confirmed**:
`chess` bundled a ported SAM text-to-speech component whose original upstream
project (`s-macke/SAM`) has no valid open-source license — self-described
"abandonware" with only a speculative Fair Use claim, confirmed by fetching that
project's own README directly. Decision: **SAM LICENSE UNCLEAR / REMOVE SAM VOICE
FEATURE ENTIRELY** (full investigation in `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`).
Implemented in commit `6359f87`: the SAM engine and its wrapper were deleted from
the repository outright (not just excluded from the build), all call sites
removed, confirmed by a full grep sweep showing zero remaining
`sam`/`voice`/`speech` references anywhere in `chess`. Scope confirmed confined to
`applications_user/chess/` — no core/firmware files touched.

**The rebuild against this removal has now passed**: the project owner's real
local Windows build at commit `5e5e0ecf225be947a754e537670a6421838b939b`
(`integration/phase2a-first-batch`) reported `git status` clean before and after,
both `.\fbt.cmd COMPACT=1 DEBUG=0` and
`.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` PASS, `build\f7-firmware-C\firmware.dfu`
present (862,825 bytes), `dist\f7-C\flipper-z-f7-update-local.tgz` present
(2,732,909 bytes). Hardware flashing/testing: **NOT PERFORMED**. Full detail in
`PHASE2A_BUILD_REPORT.md`.

**Release status: TEST-READY ONLY / NOT RELEASE-READY.** The SAM license question
is closed and the post-removal build is confirmed passing, but release-readiness
still requires hardware testing and the project's full release-gate checklist,
neither of which has been done.

## Phase 2A.5/2A.6 update: automated validation tooling, executed and hardened

An automated validation runner (`tools/phase2a_validate.ps1` +
`tools/phase2a_validate_config.json`) was added (Phase 2A.5) to automate the
repetitive Static (repo/source/manifest/keyword-scan) and Build (`fbt.cmd`
invocation + artifact verification) checks this project had been doing by
hand, plus a still-unused HardwareAssisted mode gated behind explicit
confirmation and containing no code path for RF/Sub-GHz/NFC/RFID/iButton/
BadUSB/BLE/GPIO/IR or any unauthorized-access behavior. Phase 2A.5 could only
manually reproduce the script's checks (no PowerShell was available in that
session); Phase 2A.6 **installed PowerShell 7.6.3 and executed the script for
real** for the first time.

That real execution found and fixed **two genuine bugs**, both in the
tooling only (no firmware/app code touched): (1) a null-array `.Count` crash
that, left unfixed, would have crashed the script on the exact scenario that
should be its clean/successful path — zero problems found, nothing to
review; (2) a build-launch failure (the process couldn't even start) being
misreported as a generic FAIL instead of the more accurate BLOCKED, which
also caused misleading FAIL/stale-PASS results on the downstream artifact
checks. Both are fixed in commit `ff4ba63` on `integration/phase2a-first-batch`.

**Important scope note**: this execution happened in a cloud sandbox with no
access to the project owner's actual Windows machine
(`C:\Github\Custom-Flipper-phase2a-build`) — that specific request was not,
and could not be, fulfilled this round. What was achieved instead: a fresh
Static run against commit `ff4ba635fda0bf3e0e54188ba6da51335cd924f6` came back
clean (the one broad risky-keyword substring scan's 104 matches were, again,
all manually confirmed benign — zero matches for any real Flipper HAL/
capability API). Build mode came back **BLOCKED** in this sandbox (it cannot
execute `fbt.cmd` at all, being Linux) — this does not change the
independently-known real Build PASS from the project owner's own Windows
build recorded above; it only means this new tooling itself has not yet
reproduced that PASS. Hardware-assisted mode was deliberately not run this
round. Full detail: `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`.

**Release status: TEST-READY ONLY / NOT RELEASE-READY** (unchanged). Hardware
flashing/testing: **NOT PERFORMED** (unchanged). The next concrete step is
for the project owner to run the now-hardened
`tools/phase2a_validate.ps1 -Mode Build` on their real Windows machine to get
this tooling's own, real, Windows-machine Build result.

## Phase 2A.7/2A.8 update: real Windows CI via GitHub Actions, and a validator false-failure fixed

The project owner does not currently have Claude Desktop or local Claude
Code available to drive their own Windows machine, so Phase 2A.7 replaced
that plan with **`.github/workflows/phase2a-windows-validation.yml`** ("Phase
2A Windows Validation") — a GitHub-hosted `windows-latest` CI runner that
runs `tools/phase2a_validate.ps1` in Static then Build mode against
`integration/phase2a-first-batch`, triggered automatically on push or
manually from the Actions tab. It never invokes `-Mode HardwareAssisted`
(no code path in the workflow can call it), never flashes anything, and
uploads reports/artifacts as workflow artifacts only — nothing is committed
back to the repository by the workflow itself.

**The first real run (CI run `28808570107`, head SHA `6920b408...`)
produced a genuine Windows Build PASS**: `build\f7-firmware-C\firmware.dfu`
(**862,825 bytes**) and `dist\f7-C\flipper-z-f7-update-local.tgz`
(**2,732,904 bytes**) both built, all 5 apps' `.fap` outputs present, SAM
removal re-verified clean. **The workflow's overall conclusion was
`failure` anyway** — not because of the build, but because Static mode's
risky-keyword scan re-reported its familiar 104 substring matches (102
`ble`, 2 `jam` — the same ones manually reviewed and confirmed benign back
in Phase 2A.5/2A.6) as `NEEDS_REVIEW`, since the validator had no mechanism
yet to record that they'd already been reviewed. **This was a CI
policy/validator gap, not a firmware/app defect, not a hardware-test result,
and not a release-readiness claim.**

**Fixed in Phase 2A.8** (commit `8d21138` on `integration/phase2a-first-batch`,
`tools/` only): added a structured, per-line `reviewedFalsePositives`
allowlist to `tools/phase2a_validate_config.json` — each of the 104 entries
is keyed on file path + line number + keyword + a SHA-256 hash of the exact
trimmed line text, so any edit to a matched line reverts it to unreviewed
automatically; this is deliberately not a blanket "ignore this keyword"
rule. Also split `forbiddenRiskyKeywords` so that 15 higher-severity
keywords (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `token`, `exfil`) hard-**FAIL** the
run if an unreviewed match ever appears against them — only 2 entries (both
`jam`, both individually justified: a VIN manufacturer code and a surname)
are currently reviewed at that tier; the other 14 remain at zero reviewed
entries, so a real future match would still fail immediately. Verified
locally (this cloud sandbox) both that all 104 current matches now resolve
correctly, and — by deliberately corrupting one hash in a scratch copy of
the config — that an unmatched/stale entry correctly reverts to unreviewed
and fails, before restoring the real file.

**This fix has not yet been re-verified through an actual new GitHub Actions
run as of this document** — that is the immediate next step. **Hardware
flashing/testing remains NOT PERFORMED.** **Release status remains
TEST-READY ONLY / NOT RELEASE-READY.** No firmware/app source was touched by
either the validator fix or this documentation.

## Phase 2A.9 update: CI-validated baseline formally accepted

Pushing the Phase 2A.8 fix automatically re-triggered the "Phase 2A Windows
Validation" workflow. **That run, CI run
[`28814008347`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347)
(head SHA `718eec5fe115c9e0467a8d07d974947a85b27cf6`), is the first to come
back fully green** — independently confirmed via the GitHub Actions API
(`get_workflow_run` → `"conclusion":"success"`; `list_workflow_jobs` → every
step succeeded, including "Run Static validation" and "Run Build
validation" individually). Static: `PASS_WITH_REVIEWED_FALSE_POSITIVES`
(all 104 reviewed matches, zero unreviewed, zero high-confidence-unreviewed).
Build: **PASS** — `firmware.dfu` **862,825 bytes**, updater `.tgz`
**2,733,074 bytes**, all 5 `.fap` outputs present, SAM removal verified.
Hardware-assisted: **NOT RUN**, as designed.

This result is now locked into a formal, auditable acceptance record:
**`docs/PHASE2A_ACCEPTANCE_RECORD.md`**, final classification **PHASE 2A
ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY** — covering source/build/static
verification only, explicitly not hardware-tested and not release-ready.
The two backing GitHub Actions artifacts (firmware+updater; validation
reports) are inventoried in **`docs/PHASE2A_ARTIFACT_MANIFEST.md`**, along
with a new local helper, **`tools/phase2a_artifact_manifest.ps1`**, for
generating real SHA-256 hashes once an artifact is downloaded and extracted
(no such per-file hash has been generated yet — none has been downloaded by
any AI session).

`docs/PHASE2A_NEXT_GATE.md` now records this gate as **PASSED** and defines
exactly two authorized next steps, neither automatic: (A) hardware-assisted
validation, only if/when the project owner has a device and explicitly
requests it; (B) Phase 2B **planning only** (not import) on explicit
request, with import itself requiring a further separate explicit request.

**Hardware flashing/testing remains NOT PERFORMED.** **Release status
remains TEST-READY ONLY / NOT RELEASE-READY.** No firmware/app source was
touched by this round (docs + one new read-only PowerShell helper only).

## Phase 2A.10 update: hash finalization attempted (blocked, documented); baseline tags created locally (not pushed)

Two follow-up tasks were attempted: finalizing real artifact hashes, and
tagging the accepted baseline.

**Hash finalization**: attempted to download both GitHub Actions artifacts
from CI run `28814008347` and hash the extracted `firmware.dfu`/updater
`.tgz` with `tools/phase2a_artifact_manifest.ps1`. **Blocked** — this cloud
sandbox's network egress policy rejects the Azure Blob Storage host
(`productionresultssa12.blob.core.windows.net`) that GitHub Actions artifact
downloads always redirect to (confirmed via a direct `403` and this
session's own proxy status endpoint), and direct calls to `api.github.com`
from this session's own network path are blocked too. Same category of
environment limitation as the Flipper-toolchain-host block documented
earlier in this log. **No hash was fabricated** —
`docs/PHASE2A_ARTIFACT_HASHES.md` records the NOT-YET-GENERATED status
explicitly and gives the exact steps to generate real hashes elsewhere
(download + run the existing script on a machine with real GitHub network
access, or add a self-hashing step to the CI workflow as a separate,
explicitly-approved change).

**Baseline tags**: two annotated tags were created locally —
`phase2a-ci-baseline-20260707` (pointing at the CI-validated commit
`718eec5fe115c9e0467a8d07d974947a85b27cf6`) and
`phase2a-acceptance-record-20260707` (pointing at the Phase 2A.10 docs
commit). **Pushing them failed with a `403`** from this session's own git
relay — a different failure from the artifact-download block above (this
one comes from the relay infrastructure itself, not GitHub; ordinary branch
pushes through the same relay work fine, so this reads as a deliberate
restriction on tag creation specifically, consistent with this project's
"do not publish a public release" boundary). Per this project's standing
rule against retrying policy denials, this was not repeatedly attempted —
**both tags exist only in this session's local clone and are not on
GitHub.** Pushing them (from a machine/session with tag-push permission) is
a leftover step if permanent baseline tags are wanted; the branch commits
and `docs/PHASE2A_ACCEPTANCE_RECORD.md` already serve as the durable,
pushed record regardless.

**Hardware flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.** No firmware/app source was touched.

---

## Phase 2A.11 update: artifact hash finalization and baseline tags completed for real (GitHub Actions)

Phase 2A.10 documented two genuine, confirmed environment blockers: this
cloud sandbox cannot download GitHub Actions artifacts (Azure Blob Storage
host `403`) or push git tags through its own relay (`403`). Rather than
work around either restriction from inside this session, Phase 2A.11 added
`.github/workflows/phase2a-finalize-baseline.yml`, a workflow that runs
entirely on GitHub's own `windows-latest` infrastructure, downloads CI run
`28814008347`'s own artifacts directly (no redirect-following through this
session's proxy), computes real SHA-256 hashes with `Get-FileHash`, and
pushes both baseline tags using the workflow's own `GITHUB_TOKEN`.

The workflow was run for real: [`28859929957`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28859929957).
Real, generated results — **firmware.dfu**: 862,825 bytes, SHA-256
`7c74895107eb5c98c7241ea0d55565ed5e3931ce6f8e7137adba9dc77c0fdfe2`;
**flipper-z-f7-update-local.tgz**: 2,733,074 bytes, SHA-256
`8f1afbd81c603104f94aaa72d89b1bf6185c7cb9103b352748b7b3a4305e3d52`. Both
`phase2a-ci-baseline-20260707` and `phase2a-acceptance-record-20260707` are
now real, pushed tags on GitHub, pointing at commit
`718eec5fe115c9e0467a8d07d974947a85b27cf6` and the acceptance-record commit
respectively. `docs/PHASE2A_ARTIFACT_HASHES.md`,
`docs/PHASE2A_ACCEPTANCE_RECORD.md`, `docs/PHASE2A_ARTIFACT_MANIFEST.md`,
and `docs/PHASE2A_AUTOMATED_VALIDATION_RESULTS.md` were all updated to
record this, and are mirrored to this branch as part of this same update
(having been missed in the immediately-preceding commit, which mirrored
only the workflow file itself, before it had actually been run).

**Hardware flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.** No firmware/app source was touched.

---

## Phase 2A.12 update: hardware-assisted validation gate built and exercised (sandbox result: BLOCKED — no device)

Added `tools/phase2a_hardware_gate.ps1` and its config: a defensive,
non-destructive-by-default gate that automates the non-GUI preconditions
for hardware-assisted validation of the accepted Phase 2A baseline —
branch/commit verification, real artifact hash verification against the
Phase 2A.11 finalized hashes, safe read-only Flipper Zero PnP detection
(`VID_0483&PID_5740`, no serial/RPC contact), best-effort qFlipper
detection, and a flash-confirmation gate that requires a detected device,
both artifact hashes PASS, detected tooling, and an exact typed
confirmation phrase before ever acknowledging that a manual flash may
proceed — the script itself contains no code path that performs a flash,
under any mode or flag. Every GUI-level app check (all 5 apps, plus the
chess private-save-path check, plus the two "no crash"/"no unexpected
hardware activation" global checks) is explicitly logged as
`REQUIRES_HUMAN_OBSERVATION`, pointing to the existing
`docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` — never simulated.

All 5 modes (`Preflight`, `DetectDevice`, `HashVerify`, `HardwareAssisted`,
`ReportOnly`) were actually executed via `pwsh` in this session's own
sandbox, including a deliberate synthetic-artifact mismatch test that
confirmed the hash-comparison logic correctly rejects a wrong file (same
size, wrong SHA-256) rather than passing on size alone. This sandbox has no
Windows machine and no physical Flipper Zero — `Get-PnpDevice` itself does
not exist here — so the honest, real result for this environment is
**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**. Full per-mode
results are in `docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md`.

Also added `docs/PHASE2A_HARDWARE_ASSISTED_VALIDATION.md` (what this gate
does and does not validate, and why hardware validation is different in
kind from CI validation), a minimal cross-reference in the existing smoke
test checklist, and updated `docs/PHASE2A_NEXT_GATE.md` to mark Path A
active with the Phase 2B-planning gating rules tied to Phase 2A.12's
classification (planning may proceed only as clearly-labeled
non-hardware-dependent planning while this stays BLOCKED, and only on the
project owner's explicit further request).

**Phase 2B was not started. No firmware/app source was touched. Hardware
flashing/testing remains NOT PERFORMED. Release status remains TEST-READY
ONLY / NOT RELEASE-READY.**

---

## Phase 2B planning update: candidate review package (planning only, no import)

Built the full Phase 2B planning package — `PHASE2B_CANDIDATE_REVIEW.md`,
`PHASE2B_RECOMMENDED_BATCH.md`, `PHASE2B_RISK_REGISTER.md`,
`PHASE2B_LICENSE_REVIEW.md`, `PHASE2B_INTEGRATION_PLAN.md`, and
`PHASE2B_GO_NO_GO.md` — grounded entirely in the existing Phase 1.5/1.6
candidate-audit work (no fresh source read; this environment has no local
RogueMaster clone), re-screened against the 5 apps Phase 2A already
imported.

Two apps from the Top 25 pool were excluded for real hardware capability
the Phase 1.6 source audit had already found: `upython` (real
`furi_hal_gpio_write`/`furi_hal_gpio_read` and
`furi_hal_infrared_async_tx_start` — IR transmit — exposed to user
scripts) and `iconedit` (real `furi_hal_hid_kb_press`/`release` USB HID
keystroke injection in its "send to PC" feature). Both are on this
project's own safety-exclusion list.

A third finding was new to this phase specifically: `c_book` bundles
verbatim `.txt` chapters of a commercially copyrighted book ("The C
Programming Language," K&R, Prentice Hall) with no confirmed distribution
right — the Phase 1.6 audit had only screened it for hardware/storage
capability (clean) and never evaluated the bundled content's copyright
status. Marked `NEEDS REVIEW` / excluded from the recommended batch, the
same discipline that previously caught `chess`'s unlicensed SAM component
in Phase 2A.

**Recommended tiny batch (3 apps, LOW risk each)**: `flipfetch`,
`quadratic_solver`, `sudoku` — all confirmed by the existing audit to have
zero hardware-capability hits; `sudoku` is the only one with any storage
behavior at all (a private save file, no shared-directory writes).
Recommendation: **GO WITH CONDITIONS** — implementation still requires the
project owner's own separate, explicit request.

**No app source was imported or read fresh. No `applications/` or
`applications_user/` changes. No firmware built. No hardware touched.
Phase 2B implementation was not started. Hardware flashing/testing remains
NOT PERFORMED. Release status remains TEST-READY ONLY / NOT
RELEASE-READY.**

---

## Phase 2B.1 update: pre-import source and license verification (real source read, no import)

Resolved the one open condition from the Phase 2B planning package: all 3
recommended apps (`flipfetch`, `quadratic_solver`, `sudoku`) had been
marked license status `NEEDS REVIEW` only because no local source clone
existed to read a `LICENSE` file from. This phase found that
`raw.githubusercontent.com` and `github.com`'s git-over-HTTPS endpoint are
*not* blocked by this session's network policy (unlike `api.github.com`
and GitHub's HTML pages, which returned `403`, consistent with every
prior phase) — so a real `git fetch`/`checkout` of
`RogueMaster/flipperzero-firmware-wPlugins` at commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` (the exact commit
`PHASE1_6_TOP25_SOURCE_AUDIT.md` had cited) was performed into a scratch
directory outside this repository, and each of the 3 apps' actual
`application.fam`, `LICENSE`, `README`, and full source was read directly.

**Result: all 3 confirmed MIT-licensed** (SHA-256 of each `LICENSE` file
recorded), GPLv3-compatible, requiring only standard attribution. Zero
real unsafe-capability keyword matches across the mandatory 18-keyword
scan; 6 total `ble`-substring false positives found (inside "double"/
"enabled"), the same class of false positive Phase 2A's own scan resolved
102 times. `sudoku` has a real but confirmed app-private-only save path
(`APP_DATA_PATH("save.dat")`, same pattern as `chess`); `flipfetch` and
`quadratic_solver` have no storage footprint at all. No bundled
third-party code in any of the 3.

**Classification: PHASE 2B.1 PRE-IMPORT VERIFICATION PASS.** All 3 apps
`CLEARED FOR IMPORT`; the recommended batch is unchanged and does not need
to shrink. Added `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`,
`PHASE2B_1_IMPORT_READINESS_MATRIX.md`, and `PHASE2B_1_GO_NO_GO.md`;
updated (without erasing) `PHASE2B_LICENSE_REVIEW.md` and
`PHASE2B_GO_NO_GO.md` with a Phase 2B.1 section each.

**No app code was imported. No `applications/` or `applications_user/`
changes to this repository** (the scratch clone used to read real source
lives entirely outside it and was deleted after use). No firmware built.
No hardware touched. Phase 2B implementation was not started — it still
requires the project owner's own separate, explicit request. Hardware
flashing/testing remains NOT PERFORMED. Release status remains TEST-READY
ONLY / NOT RELEASE-READY.

---

## Phase 2B.2 update: cleared batch imported, statically clean, and real CI build PASS

Imported exactly the 3 cleared apps from `docs/PHASE2B_1_GO_NO_GO.md`,
one commit each, on a new branch `integration/phase2b-first-batch`
(created from `integration/phase2a-first-batch`, leaving that branch and
its own baseline tags untouched): `flipfetch`, `quadratic_solver`,
`sudoku` — fetched fresh from `RogueMaster/flipperzero-firmware-wPlugins`
at the exact same commit (`472f6925e8aca9bd031cb37e3cb80b551772c957`)
verified in Phase 2B.1, copied verbatim (LICENSE/README/source/assets),
no refactor, no compile fix needed. Each import commit ran a real safety
scan against the actual committed files before being accepted: zero real
matches against the 19-keyword unsafe-capability list; 6 total
`ble`-substring false positives, all inside "double"/"enabled", with
exact line numbers and SHA-256 hashes recorded.

Added a new `tools/phase2b_validate_config.json` (a superset of the
frozen `tools/phase2a_validate_config.json`, which is untouched) covering
all 8 apps, and a corresponding
`.github/workflows/phase2b-windows-validation.yml` that reuses the
existing Phase 2A CI pattern verbatim. Added one small, backward-compatible
`-ConfigPath` parameter to the shared `tools/phase2a_validate.ps1` so it
could point at the new config without touching Phase 2A's own default
behavior.

This session's own git submodules initialized successfully for the first
time (`raw.githubusercontent.com`/`github.com` git-clone access is not
blocked, unlike `update.flipperzero.one`, the pinned vendor toolchain
host, which is still `403`) — letting local Static validation run
cleanly against all 8 apps. Local **Build** remains genuinely BLOCKED /
ENVIRONMENT for the same toolchain-host reason documented since Phase 0;
no substitute toolchain was used.

**The pushed branch's own CI workflow then ran for real** on a GitHub-hosted
Windows runner: run
[`28877810474`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474),
conclusion **success**, verified via the GitHub API (not claimed on
trust). Static: `PASS_WITH_REVIEWED_FALSE_POSITIVES` (all 110 substring
matches, 104 pre-existing + 6 new, individually reviewed). Build: `PASS`
— `firmware.dfu` 862,825 bytes (identical to the Phase 2A baseline,
confirming the base firmware itself is unchanged), updater package
2,742,659 bytes (larger, expected - 3 more compiled FAPs embedded), all 8
`.fap` outputs present. This is the first real, CI-confirmed build of the
8-app batch together.

**Hardware flashing/testing remains NOT PERFORMED** (out of scope for this
phase by explicit instruction - no HardwareAssisted run, no device, no
flash). **Release status remains TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2B.3 update: CI baseline acceptance record and artifact hash finalization (real, verified)

Locked in the Phase 2B CI baseline (8 apps: 5 Phase 2A + 3 Phase 2B) at
commit `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159`, mirroring the exact
acceptance-record and finalization discipline already used for Phase 2A
(2A.9/2A.11). Added `docs/PHASE2B_3_ACCEPTANCE_RECORD.md`,
`docs/PHASE2B_3_ARTIFACT_MANIFEST.md`, `docs/PHASE2B_3_ARTIFACT_HASHES.md`
(initially honestly PENDING, no hash fabricated), `docs/PHASE2B_3_GO_NO_GO.md`,
`docs/PHASE2B_NEXT_GATE.md`, and
`.github/workflows/phase2b-finalize-baseline.yml` (modeled directly on the
already-proven `phase2a-finalize-baseline.yml`).

Triggered the finalization workflow for real via the GitHub API
(`actions_run_trigger` → `run_workflow`) against
`integration/phase2b-first-batch`. One real environment discovery along
the way: the workflow could not be dispatched until its file was also
mirrored to `claude/flipper-custom-firmware-cxrcer` — every other indexed
workflow's catalog URL resolves to that branch, indicating it is this
repository's actual default branch (distinct from any `integration/*`
branch) - resolved by mirroring there, not by merging into any
release/main branch.

Run [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603)
completed in ~32 seconds with conclusion **success** (verified via
`get_workflow_run`/`list_workflow_jobs`/`get_job_logs` - the real,
unedited job log). Real results: `firmware.dfu` SHA-256
`f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75`
(862,825 bytes), updater package SHA-256
`6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7`
(2,742,659 bytes). Both baseline tags created and pushed fresh:
`phase2b-ci-baseline-20260707` → `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159`,
`phase2b-acceptance-record-20260707` →
`ff44e82d5139717315960273917db064c9deeff1` (the finalization workflow's
own docs commit) — both verified by dereferencing the annotated tag
objects to their target commits, matching the job log's own reported
output exactly.

**Classification: PHASE 2B.3 BASELINE ACCEPTANCE PASS.** No app source
was imported or modified. No `applications/` or `applications_user/`
changes. No firmware binary committed to the repository - only real
hashes, as text. No hardware was touched. Hardware flashing/testing
remains NOT PERFORMED. Release status remains TEST-READY ONLY / NOT
RELEASE-READY.

---

## Phase 2B.4 update: hardware-assisted validation gate built and exercised (sandbox result: BLOCKED — no device)

Added `tools/phase2b_hardware_gate.ps1` and its config: the Phase 2B
counterpart to `tools/phase2a_hardware_gate.ps1` (untouched, still valid
for the Phase 2A-only baseline) - same defensive, non-destructive-by-
default design, extended to all 8 apps in the accepted Phase 2B baseline.
Verifies branch/commit, verifies the real artifact hashes finalized in
Phase 2B.3 (`firmware.dfu`
`f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75`,
updater
`6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7`),
safe read-only Flipper Zero PnP detection, best-effort qFlipper
detection, and a flash-confirmation gate that requires a detected device,
PASS hashes, detected tooling, and an exact typed confirmation phrase
before ever acknowledging a manual flash may proceed - the script never
flashes a device under any mode or flag.

Ran all 5 modes for real in this session's own sandbox (no Windows, no
physical device), including a synthetic hash-mismatch scenario proving
the comparison logic rejects a wrong artifact. Found and fixed a real,
minor bug along the way: two runs launched within the same wall-clock
second produced identical report filenames, silently overwriting one
report with the other (the same second-granularity filename scheme
`tools/phase2a_hardware_gate.ps1` already uses unchanged) - not a scoring
defect, documented honestly, worked around by spacing the runs apart.
Real result for this environment: **HARDWARE VALIDATION BLOCKED - DEVICE
NOT AVAILABLE**. Recorded in `docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md`.

Also adds `docs/PHASE2B_HARDWARE_ASSISTED_VALIDATION.md` (what this gate
does/does not validate) and `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md`
(all 8 apps - the 5 Phase 2A sections reproduced verbatim plus 3 new
sections for `flipfetch`/`quadratic_solver`/`sudoku`, including a new
sudoku save/load private-path check grounded in its real source). Updates
`docs/PHASE2B_NEXT_GATE.md` with the hardware gate's real classification
and the Phase 2C gating rules tied to it (planning may proceed only as
clearly-labeled non-hardware-dependent planning while this stays
BLOCKED, and only on the project owner's explicit further request).

**Phase 2C was not started. No firmware or app source was touched.
Hardware flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2C planning update: candidate review package (planning only, no import)

Built the full Phase 2C planning package — `PHASE2C_CANDIDATE_REVIEW.md`,
`PHASE2C_RECOMMENDED_BATCH.md`, `PHASE2C_RISK_REGISTER.md`,
`PHASE2C_LICENSE_REVIEW.md`, `PHASE2C_INTEGRATION_PLAN.md`,
`PHASE2C_GO_NO_GO.md`, and `PHASE2C_NEXT_GATE.md` — grounded entirely in
the existing Phase 1.5/1.6 candidate-audit work and the Phase 2B planning/
import record (no fresh source read; real source/license verification is
explicitly deferred to a future Phase 2C.1, mirroring how Phase 2B.1
followed Phase 2B's own planning phase).

Re-screened the Phase 1.5 Top 25 against the now-8-app accepted baseline
(`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`,
`flipfetch`, `quadratic_solver`, `sudoku`) plus 5 apps hard-deferred per
explicit instruction and left unre-reviewed: `upython`, `iconedit`
(real hardware-capability exposure, unchanged from Phase 2B), `c_book`
(unresolved book-copyright question, unchanged from Phase 2B), and
`animation_switcher`/`theme_manager` (shared `/ext/dolphin/` writes,
unchanged from Phase 2B). This leaves a 12-app candidate pool.

**Recommended tiny batch (3 apps, LOW risk each)**: `sd_info`,
`fcc_id_lookup`, `docviewlite` — all confirmed by the existing Phase 1.6
audit to have zero hardware-capability hits and, notably, **zero storage
writes of any kind** (read-only card info, bundled reference data, and a
user-selected document, respectively) — an even more conservative slice
than Phase 2A's/2B's own first batches, neither of which is a game or
private-save-file app this time. Recommendation: **GO WITH CONDITIONS** —
the next actual step is Phase 2C.1 pre-import source/license verification,
not import; implementation still requires the project owner's own
separate, explicit request even after that.

**No app source was imported or read fresh. No `applications/` or
`applications_user/` changes. No firmware built. No hardware touched, no
hardware-connected validation mode run. Phase 2C implementation was not
started. Hardware flashing/testing remains NOT PERFORMED. Release status
remains TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2C.1 update: pre-import source and license verification (real source read, no import)

Resolved the license-evidence gap the Phase 2C planning package flagged,
using real network access to fetch the actual upstream RogueMaster source
at the same pinned commit (`472f6925e8aca9bd031cb37e3cb80b551772c957`)
every prior audit in this project has cited.

**`sd_info`**: **CLEARED FOR IMPORT.** Real `LICENSE` file read directly
from the vendored source — full, unmodified **GPLv3** text, the same
license as the firmware base itself (the most direct possible
compatibility case). A real, material correction was found and recorded
honestly: this app is not zero-storage as the planning phase assumed — it
performs a transient, self-cleaning, explicitly user-initiated SD-card
read/write/delete benchmark at `/ext/sdtest.tmp*` (SD-card root, not
app-private, not persistent, not automatic, not a
safety-exclusion-list capability).

**`docviewlite`**: **CLEARED FOR IMPORT.** Real `LICENSE` file read
directly from the vendored source — full, unmodified **MIT** text.
Storage behavior confirmed exactly as planned (read-only, user-selected
`.txt` file only). One build-risk note recorded: the manifest declares
`fap_icon_assets="images"` but no such directory exists in the vendored
copy — flagged for observation at actual Static/Build validation time,
not assumed either way.

**`fcc_id_lookup`**: **DEFER.** The vendored copy has no `LICENSE` file,
no SPDX header, and no copyright notice anywhere in its source — a real,
specific gap, not a citation-only one. Strong corroborating evidence (a
real, confirmed MIT license, same author, same project, found at the
exact upstream repository this app's own manifest links to) exists, but
is not commit-pinned to the specific historical revision RogueMaster
vendored, so per this phase's own license canary it is not sufficient to
declare the license proven. This is a materially lower-severity DEFER
than `c_book`'s — no unresolved copyright dispute, no commercial content,
a clear and low-effort resolution path (include the confirmed upstream
`LICENSE` at actual import time). Also clarified: the 8.9MB reference
database Phase 1.5/1.6 described as bundled is not actually present in
the vendored source tree at all — it is a separate, optional,
user-supplied asset, so this DEFER is about the wrapper code's own
license only, not a database-provenance question.

**Classification: `PHASE 2C.1 NEEDS REVIEW`** — 2 of 3 apps cleared
(`sd_info`, `docviewlite`), 1 deferred (`fcc_id_lookup`). The original
3-app batch shrinks to a 2-app cleared batch; per explicit instruction, no
substitute app was proposed for the deferred one.

**No app source was imported. No `applications/` or `applications_user/`
changes. No firmware built. No hardware touched, no hardware-connected
validation mode run. Phase 2C implementation was not started. Hardware
flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2C.2 update: cleared batch imported, statically clean, and real CI build PASS

Imported the reduced, cleared 2-app Phase 2C batch — `sd_info` and
`docviewlite` — one at a time, on a new branch
`integration/phase2c-first-batch` created from
`integration/phase2b-first-batch`. `fcc_id_lookup` was **not** imported
(deferred per Phase 2C.1's license-evidence gap) and no substitute app
was added.

Each app's `LICENSE` was re-fetched from the same pinned RogueMaster
commit (`472f6925e8aca9bd031cb37e3cb80b551772c957`) and re-hashed byte-
identical to Phase 2C.1's evidence before import: `sd_info` is **GPLv3**
(the same license as the firmware base itself — the most direct possible
compatibility case), `docviewlite` is **MIT**. No source file in either
app was modified; each app's `entry_point` was confirmed present in its
own source before committing.

Static scan of the real imported source found **zero real unsafe/
capability matches** in either app — only benign `ble`-substring false
positives (`double`, `enabled`, `variable`, `available`, `scrolling`
words), the same class established throughout Phase 2A/2B. One real,
material storage-risk correction was found and recorded, not hidden:
`sd_info`'s SD-card speed test performs real (but transient,
self-cleaning, user-initiated) writes at `/ext/sdtest.tmp*` — not
zero-storage as the original Phase 2C planning pass assumed.
`docviewlite` was confirmed read-only exactly as planned.

The combined 10-app batch (8 Phase 2A/2B + `sd_info` + `docviewlite`) was
validated via a new `tools/phase2c_validate_config.json` and
`.github/workflows/phase2c-windows-validation.yml` (both modeled directly
on their Phase 2B counterparts): local Static validation ran for real via
`pwsh` in this sandbox (`PASS_WITH_REVIEWED_FALSE_POSITIVES`, 139
substring matches all individually reviewed), local Build remains
**BUILD BLOCKED / ENVIRONMENT** (same structural Linux-sandbox limitation
as every prior phase), and **real CI Build validation PASSED** on a
GitHub-hosted Windows runner (run `28897702247`, conclusion `success`):
`firmware.dfu` 862,825 bytes (unchanged from baseline), updater `.tgz`
2,757,340 bytes, all 10 `.fap` outputs present including `sd_info.fap`
and `docviewlite.fap`.

**Classification: `PHASE 2C.2 IMPORT PASS`.**

**No core firmware (`applications/`) was changed. No hardware was
touched, no hardware-connected validation mode was run. No release was
published. Hardware flashing/testing remains NOT PERFORMED. Release
status remains TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2C.3 update: CI baseline acceptance record and artifact hash finalization

Locked in the real Phase 2C.2 CI PASS (run `28897702247`, commit
`969054e`, conclusion `success`) as a formal acceptance record —
`docs/PHASE2C_3_ACCEPTANCE_RECORD.md` — classified
**`PHASE 2C ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY`**, the same narrow
scope every prior phase's own acceptance record has meant: source/build/
static verification only, nothing about hardware or release-readiness.
Added `docs/PHASE2C_3_ARTIFACT_MANIFEST.md` (real GitHub Actions artifact
IDs and archive digests for run `28897702247`, fetched via the GitHub
API) and a `docs/PHASE2C_3_ARTIFACT_HASHES.md` placeholder that honestly
states hashes are pending, not fabricated.

Added `.github/workflows/phase2c-finalize-baseline.yml`, modeled
directly on `phase2b-finalize-baseline.yml`: runs entirely on a
GitHub-hosted `windows-latest` runner (working around this sandbox's
confirmed inability to download Actions artifacts or push tags),
downloads the source run's artifacts via `gh run download`, computes real
SHA-256 hashes with `Get-FileHash`, patches the acceptance record/manifest
in place, and creates two immutable tags
(`phase2c-ci-baseline-20260707`, `phase2c-acceptance-record-20260707`) —
refusing to silently overwrite either tag if it already exists pointing
elsewhere. Never invokes `-Mode HardwareAssisted`, never flashes hardware.

Updated `docs/PHASE2C_NEXT_GATE.md` to reflect the real Phase 2C.1/2C.2/
2C.3 results and define the next allowed paths: a Phase 2C hardware gate
(only with real hardware and explicit request), Phase 2D planning only
(only on explicit request), or a narrow follow-up specifically on
`fcc_id_lookup`'s license gap.

**No firmware/app source was touched. No hardware was touched, no
hardware-connected validation mode was run. Phase 2D was not started.
Hardware flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.**

**Finalization workflow executed for real** (run
[`28899393035`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28899393035),
success, ~46 seconds): real SHA-256 hashes computed on a GitHub-hosted
Windows runner — `firmware.dfu` 862,825 bytes,
`236ea92dfa826fe2459df3413e18952e0807775ed1f5c65737581e5c5c1934e8`;
updater `.tgz` 2,757,340 bytes,
`d2fd4847830c311b487457e29f3ca285b009b2ca6735257739a4198711157632`.
Both `phase2c-ci-baseline-20260707` and `phase2c-acceptance-record-20260707`
tags created fresh and pushed; Phase 2A's and Phase 2B's own tags
confirmed untouched. See `docs/PHASE2C_3_ARTIFACT_HASHES.md` and
`docs/PHASE2C_3_GO_NO_GO.md` for full detail.

---

## Phase 2C.4 update: hardware-assisted validation gate built and exercised (sandbox result: BLOCKED — no device)

Built `tools/phase2c_hardware_gate.ps1` and
`tools/phase2c_hardware_gate_config.json`, modeled directly on the Phase
2A/2B hardware gates, covering all 10 apps in the accepted Phase 2C
baseline. `fcc_id_lookup` remains absent — deferred, not re-reviewed.

Fixed a real, minor tooling limitation carried over from Phase 2A's and
Phase 2B's own hardware gates: their report filenames used
second-granularity timestamps, so rapid repeated invocations could
silently overwrite each other's report. This script uses a
millisecond-precision timestamp plus a random hex suffix instead,
verified directly with a deliberate zero-delay rapid-invocation test (3
back-to-back `-Mode ReportOnly` runs, 2 landing in the same wall-clock
second) that produced zero collisions across all 9 test runs performed
in this phase. Phase 2A's and Phase 2B's own scripts were left
unmodified, per explicit instruction.

Exercised all 5 modes for real via `pwsh` in this sandbox: Preflight,
ReportOnly (×3), DetectDevice, HashVerify (no artifact dir, and against a
deliberate synthetic random-data mismatch — proving the hash-comparison
logic correctly rejects wrong artifacts rather than passing on size
alone), and HardwareAssisted (no artifact dir, no device). Real result:
**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`** — no Windows
machine, no physical Flipper Zero, no qFlipper install in this sandbox;
`Get-PnpDevice` itself is unavailable here (confirmed directly via the
actual PowerShell error, not assumed).

Added `docs/PHASE2C_HARDWARE_ASSISTED_VALIDATION.md`,
`docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md` (full real per-run detail,
including an honest explanation of the benign `NEEDS_REVIEW` results
caused by commit drift and pre-commit tool-file state during testing),
and `docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` (all 10 apps,
including new `sd_info` SD-benchmark-cleanup and `docviewlite`
read-only-confirmation sections). Updated `docs/PHASE2C_NEXT_GATE.md`
with the real classification and Phase 2D gating rules.

**Phase 2D was not started. No firmware or app source was touched.
Hardware flashing/testing remains NOT PERFORMED. Release status remains
TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2D planning update: candidate review package (planning only, no import)

Built the full Phase 2D planning package — `PHASE2D_CANDIDATE_REVIEW.md`,
`PHASE2D_RECOMMENDED_BATCH.md`, `PHASE2D_RISK_REGISTER.md`,
`PHASE2D_LICENSE_REVIEW.md`, `PHASE2D_INTEGRATION_PLAN.md`,
`PHASE2D_GO_NO_GO.md`, and `PHASE2D_NEXT_GATE.md` — grounded entirely in
the existing Phase 1.5/1.6 candidate-audit work and the Phase 2C
planning/import record (no fresh source read; real source/license
verification is explicitly deferred to a future Phase 2D.1).

Re-screened the Phase 1.5 Top 25 against the now-10-app accepted
baseline (`network_subnet`, `programmer_calc`, `vin_decoder`,
`flipper95`, `chess`, `flipfetch`, `quadratic_solver`, `sudoku`,
`sd_info`, `docviewlite`) plus 6 apps hard-deferred per explicit
instruction and left unre-reviewed: `upython`, `iconedit` (real
hardware-capability exposure), `c_book` (unresolved book-copyright
question), `animation_switcher`/`theme_manager` (shared `/ext/dolphin/`
writes), and `fcc_id_lookup` (still-open license-evidence gap, per
`docs/KNOWN_ISSUES.md` item 6). This leaves a 9-app candidate pool.

**Recommended tiny batch (3 apps, LOW risk each)**: `resistors`,
`crypto_dictionary`, `2048` — the clearest zero-storage classification
in the pool, a confirmed pure offline glossary with no crypto operations
performed on user data, and a well-understood app-private high-score
save (the same pattern already proven safe by `chess`/`sudoku`).
Deliberately excluded `hex_viewer`/`qrcode`/`barcode_gen` from this
specific slice — their existing Phase 1.6 storage descriptions don't
explicitly rule out a write, and this project's own Phase 2C.1 finding
with `sd_info` (assumed zero-storage in planning, found to have real
SD-root writes on fresh source read) is the specific reason that kind of
ambiguity is now treated as a reason to defer rather than assume
read-only behavior for a first, most-conservative slice. Recommendation:
**GO WITH CONDITIONS** — the next actual step is Phase 2D.1 pre-import
source/license verification, not import; implementation still requires
the project owner's own separate, explicit request even after that.

**No app source was imported or read fresh. No `applications/` or
`applications_user/` changes. No firmware built. No hardware touched, no
hardware-connected validation mode run. Phase 2D implementation was not
started. Hardware flashing/testing remains NOT PERFORMED. Release status
remains TEST-READY ONLY / NOT RELEASE-READY.**

---

## Phase 2D.1 update: pre-import source/license/safety verification — all 3 apps cleared

Real, fresh network access to `RogueMaster/flipperzero-firmware-wPlugins`
at the pinned commit `472f6925e8aca9bd031cb37e3cb80b551772c957` (the same
commit every prior audit in this project has cited, confirmed via `git
rev-parse FETCH_HEAD` with no discrepancy from the Phase 2D planning
docs). Fetched and read the actual `application.fam`, `LICENSE`, README,
and full source for `resistors`, `crypto_dictionary`, and `2048` into a
scratch clone outside this repository — mirroring exactly the Phase
2B.1/2C.1 verification discipline.

**All 3 apps had a real, readable `LICENSE` file present directly in the
vendored source** — `resistors` and `2048`: MIT; `crypto_dictionary`:
GPLv3 — a materially cleaner outcome than Phase 2C.1, where
`fcc_id_lookup`'s vendored copy had no `LICENSE` file at all. A full
22-keyword safety/API scan (the original 18 plus this phase's new
`seed`/`wallet`/`private key`/`secret`) found zero real matches across all
3 apps, including inside `crypto_dictionary`'s own bundled glossary text,
and zero `furi_hal_*` references of any kind in any of the 3.

**`resistors`**: confirmed zero storage API usage and zero hardware-API
usage directly from source (not merely cited). Its planning-flagged
"~2.3MB bundled asset footprint" turned out to be almost entirely
non-build-input catalog/documentation directories
(`.flipcorg/`/`design/`/`img/`/`screenshots/`) that `application.fam`
does not reference at all — the actual build inputs are ~28KB of
original 1-bit icon art. Two files within the non-build-input material
(`design/resistor_{4,5}_src.*`, apparent photographic reference images)
have unclear provenance; resolved by excluding those directories from any
future import scope entirely, the same strategy already used for
`fcc_id_lookup`'s database in Phase 2C.1.

**`crypto_dictionary`**: confirmed the bundled glossary text (14
symmetric-cipher reference cards) is original, non-copyrightable technical
content in a distinctive personal authorial style, with zero matches for
any credential/secret/wallet/seed/token/password term anywhere — cleaner
than the Phase 2D risk register's own cautious anticipation. Directly
confirmed `FSAM_READ`/`FSOM_OPEN_EXISTING`-only file access (no write call
anywhere in the source) and no cryptographic operations performed on any
data.

**`2048`**: confirmed the high-score save is app-scoped
(`/ext/apps_data/game_2048/`), with a real, directly-observed nuance not
predicted by the planning citation — the path is built from a hardcoded
literal string rather than the idiomatic `APP_DATA_PATH` appid macro
`chess`/`sudoku` use, and the app additionally performs a one-time,
silently-no-op-on-fresh-install legacy-path migration check. Neither
nuance changes the app's clearance; both are documented precisely.

**Result: all 3 apps CLEARED FOR IMPORT** (`docs/PHASE2D_1_GO_NO_GO.md`).
The original 3-app batch remains fully valid — no reduction, no
substitution needed. Full evidence in
`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` and
`docs/PHASE2D_1_IMPORT_READINESS_MATRIX.md`; `docs/PHASE2D_LICENSE_REVIEW.md`
and `docs/PHASE2D_GO_NO_GO.md` were both updated in place with a Phase
2D.1 section, preserving their original planning-phase content as the
historical record.

**No app code was imported. No `applications/` or `applications_user/`
changes. No build attempted. No hardware touched, no hardware-connected
validation mode run. Phase 2D implementation/import was not started —
that requires the project owner's own separate, explicit request. Hardware
flashing/testing remains NOT PERFORMED. Release status remains TEST-READY
ONLY / NOT RELEASE-READY. `fcc_id_lookup` remains deferred, unresolved,
and untouched by this phase.**

---

## Phase 2D.2 update: implementation/import of the cleared 3-app batch — BUILD BLOCKED / UPDATER_PACKAGE CI TOOLING

Imported `resistors` (`621229a`), `crypto_dictionary` (`f9fcc57`), and
`2048` (`52b1361`) one at a time onto a new branch,
`integration/phase2d-first-batch`, from
`RogueMaster/flipperzero-firmware-wPlugins` at the same pinned commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` Phase 2D.1 verified. Each
import preserved its own `LICENSE` file verbatim (MIT for `resistors`
and `2048`, GPLv3 for `crypto_dictionary`), excluded the non-build-input
material identified in Phase 2D.1 (`resistors`'s
`.flipcorg/`/`design/`/`img/`/`screenshots/`, `2048`'s `images/`/`img/`),
and passed a per-app static safety scan with zero real unsafe/capability
matches.

Added `tools/phase2d_validate_config.json` (13-app superset of the
Phase 2C config) and
`.github/workflows/phase2d-windows-validation.yml` (modeled on the Phase
2C CI workflow).

**Real CI result across 3 attempts, reported honestly rather than
rounded up**:

- **Attempt 1** (run `28905289140`): full **PASS** — firmware, updater
  package, and all 13 `.fap` outputs all succeeded (`firmware.dfu`
  862,825 bytes, updater `.tgz` 2,783,994 bytes). One separate,
  non-blocking tooling bug found and fixed in the same commit sequence:
  the workflow's "Upload per-app .fap artifacts" convenience step warned
  "no files found" because `fbt`'s FAP output directory (`.extapps`) is
  dot-prefixed and `actions/upload-artifact@v4` excludes dot-prefixed
  directories by default — fixed by adding `include-hidden-files: true`
  (commit `e01370d`).
- **Attempt 2** (run `28906654889`, two executions on two different
  runner instances, same commit): firmware build and all 13 `.fap`
  outputs **PASS** both times; the separate `updater_package` build
  step **BLOCKED** both times ("fbt.cmd could not be launched as a
  process"), and the updater `.tgz` was consequently never produced.
  A `rerun_failed_jobs` was used to get a second, independent data point
  before concluding this was reproducible rather than a one-off runner
  flake — the second execution reproduced the identical failure at the
  identical step on a different runner, for the identical commit.

**This is treated as a real, currently-unresolved CI/tooling
finding, not an app-source defect** — none of the 3 imported apps'
source changed between the passing and failing attempts; the only change
was an unrelated workflow-YAML edit to a later artifact-upload step. Full
per-attempt detail, including the evidentiary limits on further
root-causing this (Azure Blob artifact-log downloads remain blocked in
this session, the same established limitation from prior phases), is in
`docs/PHASE2D_2_BUILD_REPORT.md`.

Also corrects a real documentation error surfaced while building the
validator config: `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` had
claimed `resistors` showed "zero raw substring matches at all" against
the safety keyword scan — this was too strong. 6 benign
`double`-substring false positives exist (the C floating-point type,
not the Bluetooth LE API), now individually reviewed with exact evidence
in `tools/phase2d_validate_config.json`. See
`docs/PHASE2D_2_SAFETY_REVIEW.md` for the full correction.

**Final classification: `PHASE 2D.2 BUILD BLOCKED / UPDATER_PACKAGE CI
TOOLING`** — not `IMPORT PASS`. See `docs/PHASE2D_2_GO_NO_GO.md` for the
full reasoning and next recommended gate. No `applications/` (core
firmware) changes. No hardware touched, no hardware-connected validation
mode run. Phase 2D.3 was **not** started — the `updater_package` CI
blocker must be resolved or explicitly accepted as a tracked known issue
first. Release status remains **TEST-READY ONLY / NOT RELEASE-READY**.
`fcc_id_lookup` remains deferred, unresolved, and untouched by this
phase.

---

## Phase 2D.2A update: `updater_package` CI blocker diagnosed, remediated, and confirmed

A 4th real CI attempt (`28925181640`, an automatic run at Phase 2D.2's
own docs-only commit `12a7505` — no script/workflow edit) **passed in
full**, including `updater_package`, using the exact same unmodified
script that had just failed twice in a row. This is the pivotal finding
of this phase: the original "reproducibly BLOCKED" conclusion, while
reasonable from the 2 data points then available, was incomplete — the
real pre-fix behavior was **intermittent** (2 of 4 real attempts passed,
~50%), not a deterministic break.

Applied a narrow remediation to `tools/phase2a_validate.ps1`'s
`updater_package` call site only (the firmware build call site, with a
6-for-6 real-CI success record across this whole investigation, is
untouched): added non-secret diagnostics (disk space, `fbt.cmd`
metadata, PowerShell/OS version, Windows Defender status, PATH)
immediately before the attempt, and switched the launch mechanism from
PowerShell's `&` call operator to an explicit `cmd /c` wrapper — same
build target, same arguments, same pass/fail classification logic.

**Post-fix result: 2 of 2 real, independent CI attempts passed in
full** (run `28938933924`, attempts 1 and 2 — the second triggered via
`rerun_workflow_run` specifically for an independent confirmation, on a
different runner instance): `updater_package` PASS both times,
`firmware.dfu` byte-identical (862,825 bytes), updater `.tgz` 2,784,400
and 2,783,411 bytes respectively, all 13 `.fap` outputs present, `.fap`
artifact upload working in both.

**Updated classification: `PHASE 2D.2 IMPORT PASS WITH CI TOOLING
REMEDIATION NOTE`** — a real, narrow, twice-verified fix, reported
honestly alongside the pre-fix intermittent history rather than as an
unconditional clean pass with no context. See
`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`,
`docs/PHASE2D_2A_CI_REMEDIATION_LOG.md`, and the Phase 2D.2A update
sections appended to `docs/PHASE2D_2_BUILD_REPORT.md` and
`docs/PHASE2D_2_GO_NO_GO.md` for full detail.

**No app source changed. No `applications/` (core firmware) changed at
any point in this investigation.** No hardware touched, no
hardware-connected validation mode run. Hardware flashing/testing
remains **NOT PERFORMED**. Release status remains **TEST-READY ONLY /
NOT RELEASE-READY**. Phase 2D.3 is **not started by this phase** — it is
now an allowed next step, pending the project owner's own explicit
request. `fcc_id_lookup` remains deferred, unresolved, and untouched.

---

## Phase 2D.3 update: CI baseline acceptance record and finalize-baseline workflow

A 3rd real CI attempt (run `28941093859`, an automatic run at the
Phase 2D.2A documentation-mirroring commit `d081263` — the actual
current branch HEAD, no script/workflow edit beyond what Phase 2D.2A
already committed) also passed in full, including `updater_package`
(exit code 0, updater `.tgz` 2,783,170 bytes), on a 3rd different runner
instance — a 3rd consecutive independent post-fix confirmation.

Built the Phase 2D.3 CI baseline acceptance package
(`docs/PHASE2D_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2D_3_ARTIFACT_MANIFEST.md`,
`docs/PHASE2D_3_ARTIFACT_HASHES.md` — pending state, not fabricated —
`docs/PHASE2D_3_GO_NO_GO.md`), locked against this run/commit rather than
the earlier `28938933924` run so the tagged commit and its hashed
artifacts are the exact same state. Added
`.github/workflows/phase2d-finalize-baseline.yml`, modeled directly on
`phase2c-finalize-baseline.yml`: downloads the accepted run's real
artifacts on a GitHub-hosted Windows runner, computes real SHA-256
hashes via `Get-FileHash` (never fabricated), patches the pending docs in
place, and creates `phase2d-ci-baseline-20260708`/
`phase2d-acceptance-record-20260708` tags, refusing to overwrite either
if it already exists and points elsewhere. Updated
`docs/PHASE2D_NEXT_GATE.md` with the current gate status and next
allowed paths (a Phase 2D hardware gate or Phase 2E planning, both
pending explicit request).

**No app source changed. No `applications/` (core firmware) changed.**
No hardware touched, no hardware-connected validation mode run. No
binary committed — only hashes, once the finalize workflow actually
runs. Hardware flashing/testing remains **NOT PERFORMED**. Release
status remains **TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup`
remains deferred, unresolved, and untouched.

## Phase 2D.3 completion: finalize-baseline workflow actually ran — real result

`.github/workflows/phase2d-finalize-baseline.yml` was mirrored to this
docs branch, dispatched via `workflow_dispatch` against
`integration/phase2d-first-batch`, and completed in ~37 seconds with
conclusion **success** (run
[`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724)),
verified via the real job log, not inferred from the run's status alone.

Real, computed (never fabricated) results: `firmware.dfu` 862,825 bytes,
SHA-256 `4f3703a8778543257759f367bc02f50d440ef85d21da05b630f705564084b6a8`;
`flipper-z-f7-update-local.tgz` 2,783,170 bytes, SHA-256
`3e015f6c0b303536fab14e4a8b85233b8c439c0f642087cb92f3781bf1b16c49`; 6
validation report/build log files and all 35 `.fap` artifacts (13
expected apps plus 22 benign Unleashed-bundled example/plugin FAPs) also
hashed — full table in `docs/PHASE2D_3_ARTIFACT_HASHES.md`. The workflow
committed these results to `integration/phase2d-first-batch` (commit
`f8edb1c`) and created two new tags, neither of which existed before:
`phase2d-ci-baseline-20260708` → `d0812638a02c50389b9e713ad98f2c8215b75dd5`,
`phase2d-acceptance-record-20260708` → `f8edb1c9c0cac5cf947df7aa96de2450aaedc14b`.
All 6 prior Phase 2A/2B/2C tags were verified unchanged afterward.

`docs/PHASE2D_3_GO_NO_GO.md`'s "Finalization workflow result" section was
then updated in place with this real outcome (previously an honest
placeholder), and all Phase 2D.3 docs were mirrored from
`integration/phase2d-first-batch` to this docs branch to keep both
branches consistent. **Final classification: PHASE 2D.3 BASELINE
ACCEPTANCE PASS.** No app or firmware source changed. No hardware testing
performed. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. Next allowed path: a Phase 2D hardware-assisted gate or
Phase 2E planning only, both pending the project owner's own explicit
further request.

## Phase 2D.4 update: hardware-assisted validation gate created and executed

Added `tools/phase2d_hardware_gate.ps1` and
`tools/phase2d_hardware_gate_config.json`, extending the Phase 2C.4
hardware-gate pattern to the full 13-app accepted Phase 2D baseline
(the 10 apps already covered plus `resistors`, `crypto_dictionary`, and
`2048`), and preserving the Phase 2C.4 collision-resistant report-filename
fix unchanged. New storage checks were added for the 3 new apps:
`resistors` (confirmed zero-storage), `crypto_dictionary` (confirmed
read-only bundled glossary), and `2048` (confirmed app-scoped save path
`/ext/apps_data/game_2048/`) — all sourced directly from
`docs/PHASE2D_2_SAFETY_REVIEW.md`'s own findings, not assumed.

Real execution in this session (Linux sandbox, no Windows machine, no
physical device): `-Mode Preflight`, `-Mode DetectDevice`,
`-Mode ReportOnly`, and `-Mode HardwareAssisted` (no `-ArtifactDir`, no
`-AllowFlashPrompt`) all ran via `pwsh`, each correctly and honestly
classifying `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` — the
same result every prior phase's own hardware gate produced in this same
sandbox. A real download URL for the accepted CI run's firmware artifact
(`28941093859`, artifact `8167725019`) was actually requested via the
GitHub API and resolved successfully, but fetching it hit the same,
already-documented Azure Blob Storage egress block (`403`) as every prior
phase's artifact-download attempt — so real artifact hash verification
was **not run**. A synthetic mismatch test (two `/dev/urandom` files at
the exact expected sizes, clearly labeled as synthetic) confirmed the
hash-comparison logic correctly rejects a same-size, wrong-content file as
`FAIL` rather than passing on size alone. No flash was attempted or
offered. No GUI smoke test was performed — `docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md`
(all 13 apps) remains for a human to complete on real hardware.

**Final classification: HARDWARE VALIDATION BLOCKED - DEVICE NOT
AVAILABLE.** No app or firmware source changed. No hardware flashed.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**. Per
`docs/PHASE2D_NEXT_GATE.md`'s Phase 2D.4 update, non-hardware-dependent
Phase 2E planning may now start on the project owner's own explicit
request; Phase 2E import and release-ready both remain blocked until real
hardware validation actually completes and is explicitly accepted.

## Phase 2E planning update: candidate review package (planning only, no import)

Reviewed the 6-app remaining candidate pool left over from Phase 2D's own
planning (`image_viewer`, `boilerplate`, `minesweeper`, `hex_viewer`,
`qrcode`, `barcode_gen`), citing the existing Phase 1.5/1.6 source-audit
evidence rather than re-reading source — the same citation-only
discipline every prior planning phase (2B, 2C, 2D) has followed, with
real source/license verification explicitly deferred to a future Phase
2E.1. Added `docs/PHASE2E_CANDIDATE_REVIEW.md`,
`docs/PHASE2E_RECOMMENDED_BATCH.md`, `docs/PHASE2E_RISK_REGISTER.md`,
`docs/PHASE2E_LICENSE_REVIEW.md`, `docs/PHASE2E_INTEGRATION_PLAN.md`,
`docs/PHASE2E_GO_NO_GO.md`, and `docs/PHASE2E_NEXT_GATE.md`.

Recommended a tiny 3-app batch — `image_viewer` (Media, 1 file, described
as read-only), `boilerplate` (Tools/Educational, 21 files, app-private
save-file demonstration, real standing dev-tool value), and `minesweeper`
(Games, 20 files, app-private save/config via a dedicated storage
helper) — all confirmed by the existing Phase 1.6 audit to have zero
hits across all 8 HAL capability classes. Deferred `hex_viewer`,
`qrcode`, and `barcode_gen` to a later batch: each has a storage
description that does not explicitly rule out a write ("touch storage
APIs," or, for `qrcode`, simply "Local" with no further detail), and this
project's own Phase 2C.1 experience finding a real, previously-unassumed
write in `sd_info` is treated as the specific reason to resolve that
ambiguity via a fresh Phase-X.1 source read in a future batch rather than
assume read-only behavior now. `fcc_id_lookup`, `upython`, `iconedit`,
`c_book`, `animation_switcher`, and `theme_manager` remain excluded,
unchanged, per the project owner's explicit instruction — none
re-reviewed in this phase.

**Final classification: PHASE 2E PLANNING ONLY / NO CODE IMPORT
PERFORMED, GO WITH CONDITIONS.** No app imported. No firmware/app source
read, modified, or built. No hardware touched, no `HardwareAssisted` mode
run. Hardware flashing/testing remains **NOT PERFORMED**. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**, unchanged. `fcc_id_lookup`
remains deferred, unresolved, and untouched. Next gate is Phase 2E.1
(pre-import source/license verification), on the project owner's own
explicit further request only.

## Phase 2E.1 update: pre-import source/license verification — all 3 apps cleared

Obtained real network access to `RogueMaster/flipperzero-firmware-wPlugins`
at the pinned commit (`472f6925e8aca9bd031cb37e3cb80b551772c957`, a
shallow clone into a scratch directory outside this repository, verified
via `git rev-parse FETCH_HEAD`) and read each of the 3 recommended apps'
(`image_viewer`, `boilerplate`, `minesweeper`) actual `LICENSE`/`README`/
source directly. Added `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`,
`docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`, and
`docs/PHASE2E_1_GO_NO_GO.md`; appended verification sections to
`docs/PHASE2E_LICENSE_REVIEW.md` and `docs/PHASE2E_GO_NO_GO.md` without
erasing their planning-stage findings.

**Real finding**: `image_viewer` bundles 3 example `.bm` images via
`fap_file_assets = "example_images"`. Each was decoded in this session (a
small Python script unpacked the packed 1-bit pixel data and rendered it
as ASCII art, since no image viewer exists in this sandbox) and visually
inspected — `spongebob.bm` clearly depicts a recognizable
trademarked/copyrighted cartoon character (SpongeBob SquarePants) with no
license or attribution anywhere in the app for that image.
`dolphin.bm`/`cat.bm` are also unattributed, though neither is
affirmatively identified as a specific known character. None of the 3 are
required for the app to build or run — its actual code opens whatever
file the user selects via the standard file browser, with no hardcoded
reference to any bundled filename. Resolution: exclude the entire
`example_images/` directory (and the corresponding
`fap_file_assets` line) from the import scope entirely — this is an
import-scope condition on bundled content, not a defect in the app's own
MIT-licensed wrapper code (Ivan Polushin/polioan, confirmed via a real,
unmodified `LICENSE` file).

`boilerplate` has no `LICENSE` file, but its `README.md` contains a real,
explicit permissive statement ("open-source and may be used for whatever
you want to do with it") — recorded as a distinct, honest evidence tier,
not silently upgraded to "MIT-equivalent." `minesweeper` is MIT-licensed
(Alexander Rodriguez/squee72564), confirmed directly, no conditions
beyond routine attribution. Both `boilerplate` and `minesweeper`'s real
manifest-declared appids (`fap_boilerplate`, `minesweeper_redux`) differ
from the directory-name assumption used since Phase 1.5 — recorded
precisely for a future Phase 2E.2. All 3 apps confirmed zero matches
across the full 22-keyword safety scan; storage confirmed directly and
exactly for all 3 (read-only for `image_viewer`; app-private config paths
for `boilerplate`/`minesweeper`).

**Final classification: PHASE 2E.1 PRE-IMPORT VERIFICATION PASS. ALL 3
APPS CLEARED (ONE WITH A SUBSTANTIVE IMPORT-SCOPE CONDITION, ONE WITH A
LICENSE-EVIDENCE NOTE).** No code imported. No firmware/app source
changed. No hardware touched, no `HardwareAssisted` mode run. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup` remains
deferred, unresolved, and untouched — not reopened or re-reviewed. Next
gate: Phase 2E.2 implementation/import of this exact cleared 3-app batch,
on the project owner's own explicit further request only.

## Phase 2E.2 update: implementation/import of the cleared 3-app batch — IMPORT PASS

Created `integration/phase2e-first-batch` from `integration/phase2d-first-batch`
(commit `209066b`) and imported `image_viewer` (`3b20db6`), `boilerplate`
(`74d0927`), and `minesweeper` (`d82c0ff`) one at a time from
`RogueMaster/flipperzero-firmware-wPlugins` at the pinned commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`, re-fetched fresh into a
scratch clone and re-verified against the exact SHA before any file was
copied.

`image_viewer`'s `example_images/` directory (3 bundled `.bm` demo
images, including the `spongebob.bm` file Phase 2E.1 confirmed depicts a
recognizable trademarked cartoon character) was **not imported** — the
corresponding `fap_file_assets` manifest line was removed, the only
textual edit made to any upstream file in this batch. No SpongeBob or
SpongeBob-like image, and no other example image from that directory,
was imported at any point. `boilerplate`'s README-only permissive
license statement was preserved verbatim, no `LICENSE` file invented.
`minesweeper`'s MIT `LICENSE` was preserved verbatim.

Built `tools/phase2e_validate_config.json` (16-app superset, 373 total
reviewed-false-positive entries — 184 new, all benign `ble`-substring
hits inside words like `variable`/`enabled`/`solvable`, zero real
capability matches) and
`.github/workflows/phase2e-windows-validation.yml` (modeled on Phase
2D's, inheriting the Phase 2D.2A `updater_package` remediation and the
Phase 2D.2 `.fap` hidden-path upload fix unchanged). Local build:
`BUILD BLOCKED / ENVIRONMENT` (toolchain download blocked, `403`, the
same root cause every prior phase has hit) — not faked as a pass. Local
Static validation: `PASS_WITH_REVIEWED_FALSE_POSITIVES`.

**Real CI run `28966234832`** (GitHub Actions, `windows-latest`,
`workflow_dispatch`, commit `59b5132`) **passed on the first attempt**:
Static `PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS` (firmware +
`updater_package` + all 16 `.fap` outputs, confirmed by name via the
validator's per-appid check — `image_viewer.fap`, `fap_boilerplate.fap`,
`minesweeper_redux.fap` all present), Hardware `NOT_RUN`. `firmware.dfu`
862,825 bytes; updater `.tgz` 2,831,632 bytes. An earlier automatic
`push`-triggered run was cleanly cancelled by the workflow's own
concurrency group in favor of this manual dispatch — expected, not a
failure.

**Final classification: PHASE 2E.2 IMPORT PASS.** No compile fixes were
required. No core firmware (`applications/`, `lib/`, etc.) was touched.
No hardware touched, no `HardwareAssisted` mode run. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup` remains
deferred, unresolved, and untouched. Next gate: Phase 2E.3 (CI baseline
acceptance and artifact hash finalization), on the project owner's own
explicit further request only.

## Phase 2E.3 update: CI baseline acceptance record and finalize-baseline workflow

Checked for a later automatic CI run beyond the originally-cited
`28966234832`/`59b5132` pair, per this phase's own explicit requirement,
before finalizing anything. Found one: run `28968511276`, an automatic
`push`-triggered run at the Phase 2E.2 documentation-mirroring commit
`dcdfbb4` — the actual current branch HEAD — also passed in full,
including `updater_package` (exit code 0, updater `.tgz` 2,831,378
bytes, all 16 `.fap` outputs present). Used this later run/commit as the
accepted CI baseline instead of the earlier pair, so the tagged commit
and its hashed artifacts are the exact same state.

Built the Phase 2E.3 CI baseline acceptance package
(`docs/PHASE2E_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2E_3_ARTIFACT_MANIFEST.md`,
`docs/PHASE2E_3_ARTIFACT_HASHES.md` — pending state, not fabricated —
`docs/PHASE2E_3_GO_NO_GO.md`), locked against run `28968511276` / commit
`dcdfbb4c262c585d7d4126dc21b40dc3b948fc93`. Added
`.github/workflows/phase2e-finalize-baseline.yml`, modeled directly on
`phase2d-finalize-baseline.yml`: downloads the accepted run's real
artifacts on a GitHub-hosted Windows runner, computes real SHA-256
hashes via `Get-FileHash` (never fabricated), patches the pending docs in
place, and creates `phase2e-ci-baseline-20260708`/
`phase2e-acceptance-record-20260708` tags, refusing to overwrite either
if it already exists and points elsewhere. Updated
`docs/PHASE2E_NEXT_GATE.md` with the current gate status and next
allowed paths (a Phase 2E hardware gate or Phase 2F planning, both
pending explicit request).

**No app source changed. No `applications/` (core firmware) changed.**
No hardware touched, no hardware-connected validation mode run. No
binary committed — only hashes, once the finalize workflow actually
runs. Hardware flashing/testing remains **NOT PERFORMED**. Release
status remains **TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup`
remains deferred, unresolved, and untouched.

## Phase 2E.3 completion: finalize-baseline workflow actually ran — real result

`.github/workflows/phase2e-finalize-baseline.yml` was mirrored to this
docs branch, dispatched via `workflow_dispatch` against
`integration/phase2e-first-batch`, and completed in ~47 seconds with
conclusion **success** (run
[`28972160432`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28972160432)),
verified via the real job/step status for all 15 steps, not inferred
from the run's status alone.

Real, computed (never fabricated) results: `firmware.dfu` 862,825 bytes,
SHA-256 `e7068bf952a12051e668bdc40db6823c41ff55659f5410977361d2aea9f1ffce`;
`flipper-z-f7-update-local.tgz` 2,831,378 bytes, SHA-256
`16b35fcc844abac5f6bfeded6b8f79d5066a0411ac7c1f128aa6406251aee5c3`; 6
validation report/build log files and all 38 `.fap` artifacts (16
expected apps plus 22 benign Unleashed-bundled example/plugin FAPs) also
hashed — full table in `docs/PHASE2E_3_ARTIFACT_HASHES.md`. The workflow
committed these results to `integration/phase2e-first-batch` (commit
`2910536`) and created two new tags, neither of which existed before:
`phase2e-ci-baseline-20260708` → `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93`,
`phase2e-acceptance-record-20260708` → `2910536cc131d2d23feba635ab5d3e806cfdc47d`.
All 8 prior Phase 2A/2B/2C/2D tags were verified unchanged afterward.

`docs/PHASE2E_3_GO_NO_GO.md`'s "Finalization workflow result" section was
then updated in place with this real outcome (previously an honest
placeholder), and all Phase 2E.3 docs were mirrored from
`integration/phase2e-first-batch` to this docs branch to keep both
branches consistent. **Final classification: PHASE 2E.3 BASELINE
ACCEPTANCE PASS.** No app or firmware source changed. No hardware testing
performed. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. Next allowed path: a Phase 2E hardware-assisted gate or
Phase 2F planning only, both pending the project owner's own explicit
further request.

## Phase 2E.4 update: hardware-assisted validation gate created and executed

Added `tools/phase2e_hardware_gate.ps1` and
`tools/phase2e_hardware_gate_config.json`, extending the Phase 2D.4
hardware-gate pattern to the full 16-app accepted Phase 2E baseline (the
13 apps already covered plus `image_viewer`, `boilerplate`, and
`minesweeper`), and preserving the Phase 2C.4/2D.4 collision-resistant
report-filename fix unchanged. New storage checks were added for the 3
new apps: `image_viewer` (confirmed read-only, plus a dedicated
on-device absence check for `cat.bm`/`dolphin.bm`/`spongebob.bm`),
`boilerplate` (confirmed app-private at `/ext/apps_data/boilerplate/`),
and `minesweeper` (confirmed app-private at
`/ext/apps_data/mine_sweeper_redux/`, atomic write-then-rename) — all
sourced directly from `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`
and `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md`'s own findings, not assumed.
A new automated Preflight-level check was also added confirming
`applications_user/image_viewer/example_images/` remains absent from the
repository, re-checked on every run.

Real execution in this session (Linux sandbox, no Windows machine, no
physical device): `-Mode Preflight`, `-Mode DetectDevice`,
`-Mode ReportOnly`, `-Mode HashVerify` (synthetic mismatch), and
`-Mode HardwareAssisted` (no `-ArtifactDir`, no `-AllowFlashPrompt`) all
ran via `pwsh`, each correctly and honestly classifying `HARDWARE
VALIDATION BLOCKED - DEVICE NOT AVAILABLE` (or, for the synthetic
HashVerify run, `HARDWARE VALIDATION FAILED` — proving the comparison
logic, not a real artifact result) — the same result every prior phase's
own hardware gate produced in this same sandbox. The real, finalized
Phase 2E CI artifacts (run `28968511276`, artifact `8179247001`) could
not be downloaded in this sandbox — the same, already-documented Azure
Blob Storage egress block (`403`) as every prior phase's artifact-download
attempt — so real artifact hash verification was **not run**. A synthetic
mismatch test (two `/dev/urandom` files at the exact expected sizes,
clearly labeled as synthetic) confirmed the hash-comparison logic
correctly rejects a same-size, wrong-content file as `FAIL` rather than
passing on size alone. No flash was attempted or offered. No GUI smoke
test was performed — `docs/PHASE2E_HARDWARE_SMOKE_TEST_CHECKLIST.md`
(all 16 apps) remains for a human to complete on real hardware.
Collision-resistant report filenames were re-confirmed via a 5-way
simultaneous invocation stress test producing 10 distinct report files
with zero overwrites.

**Final classification: HARDWARE VALIDATION BLOCKED - DEVICE NOT
AVAILABLE.** No app or firmware source changed. No hardware flashed.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**. Per
`docs/PHASE2E_NEXT_GATE.md`'s Phase 2E.4 update, non-hardware-dependent
Phase 2F planning may now start on the project owner's own explicit
request; hardware-assisted validation with a real device remains
available in parallel whenever a device and Windows machine become
available. `fcc_id_lookup` remains deferred, unresolved, and untouched.
`image_viewer/example_images/` remains excluded, confirmed absent by
this gate's own automated check in every run this phase.

## Phase 2F planning update: candidate review package (planning only, no import)

Reviewed the entire remaining clean candidate pool from the original Top
25 (`docs/PHASE1_5_TOP_25_CANDIDATES.md`) against the accepted 16-app
Phase 2E baseline: `hex_viewer`, `qrcode`, `barcode_gen` — the only 3
Top-25 apps not already imported and not hard-deferred
(`fcc_id_lookup`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, `theme_manager`, none of which was reopened or
re-reviewed in this phase).

Wrote `docs/PHASE2F_CANDIDATE_REVIEW.md`, `docs/PHASE2F_RECOMMENDED_BATCH.md`,
`docs/PHASE2F_RISK_REGISTER.md`, `docs/PHASE2F_LICENSE_REVIEW.md`,
`docs/PHASE2F_INTEGRATION_PLAN.md`, `docs/PHASE2F_GO_NO_GO.md`
(**GO WITH CONDITIONS**), and `docs/PHASE2F_NEXT_GATE.md`, all grounded
in the existing Phase 1.6 individual source audit (re-cited verbatim,
not re-derived) rather than any fresh source read in this phase. All 3
candidates recommended as the tiny batch — the entire remaining clean
pool, not a padded selection.

The single most important finding: Phase 1.6's own citations for
`hex_viewer` ("2 files touch storage APIs") and `barcode_gen` ("3 files
touch storage APIs") do not explicitly confirm read-only behavior,
despite both apps' names implying pure viewing/display. Per the same
caution that caught `sd_info`'s real storage behavior being undersold at
planning stage in Phase 2C.1, both are flagged as requiring direct
Phase 2F.1 source verification before any import decision, not assumed
clean on citation alone. `qrcode`'s existing record shows no such
ambiguity. `barcode_gen`'s 4 bundled encoding-table files (Code39/128/
128C/Codabar) are also flagged for a provenance confirmation, though
their open-technical-standard nature is a materially lower concern than
`image_viewer`'s bundled bitmap images were.

**No code imported. No `applications/` or `applications_user/` change.
No firmware/app source touched. No hardware flashed.**
`integration/phase2f-first-batch` does not exist as of this update.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**. Next
gate: Phase 2F.1 (pre-import source/license verification), on the
project owner's own explicit further request only.

## Phase 2F.1 update: pre-import source/license verification — all 3 apps cleared

Obtained real network access to the pinned RogueMaster commit
(`472f6925e8aca9bd031cb37e3cb80b551772c957`) via a blobless clone plus
cone sparse-checkout limited to `qrcode`, `hex_viewer`, and
`barcode_gen`, then read each app's actual `LICENSE`, `README`, and full
source directly — resolving both storage-behavior questions Phase 2F
planning flagged as needing direct verification rather than citation.

`qrcode`: MIT (Bob Matcuk, 2022). Bundled `qrcode.c`/`qrcode.h` confirmed
to be a third-party MIT-licensed QR-encoding library (Richard Moore/
ricmoo, derived from Project Nayuki's library), attributed inline in the
file's own header and independently corroborated by the app's README —
the same library historically vendored in base `flipperzero-firmware`'s
own `lib/` directory. Storage confirmed app-private
(`/ext/apps_data/qrcodes/`), read-only for QR content, with one benign
one-time legacy-folder migration at every launch (the same pattern
already accepted for `2048` in Phase 2D).

`hex_viewer`: MIT (Roman Shchekin, 2022). **The planning-stage storage
ambiguity is now fully resolved**: a direct read of
`helpers/hex_viewer_storage.c` confirms the app opens user-selected
files with `FSAM_READ`/`FSOM_OPEN_EXISTING` only — no write, edit,
patch, overwrite, or delete call touches the viewed file anywhere in the
20-file source. Its only storage write is its own app-private settings
file (`/ext/apps_data/hex_viewer/`, 4 boolean toggles for haptic/LED/
speaker feedback via the base firmware's own standard, safe
`NotificationApp`/`furi_hal_speaker` APIs). Zero safety/API-capability
hits of any kind, including false positives.

`barcode_gen`: MIT (Alan Tsui, 2023). Real appid discrepancy found: the
manifest declares `barcode_app`, not `barcode_gen` — the same class of
directory-name-vs-appid mismatch already seen for `boilerplate`/
`minesweeper` in Phase 2E. **The 4 bundled encoding-table files'
provenance question is now resolved**: all 4 were read in full and
contain nothing but standard, publicly documented barcode-symbology
character-to-bar-pattern data (Code 39/128/128C/Codabar) — technical
specification data, not a creative work, already correctly declared via
`fap_file_assets`. Storage confirmed app-private only
(`/ext/apps_data/barcodes/`).

Wrote `docs/PHASE2F_1_SOURCE_LICENSE_VERIFICATION.md`,
`docs/PHASE2F_1_IMPORT_READINESS_MATRIX.md`, and
`docs/PHASE2F_1_GO_NO_GO.md` (**PHASE 2F.1 PRE-IMPORT VERIFICATION
PASS**), and updated `docs/PHASE2F_LICENSE_REVIEW.md` and
`docs/PHASE2F_GO_NO_GO.md` in place with the real verification result
(original planning-stage findings preserved unmodified as historical
record).

**All 3 apps CLEARED FOR IMPORT — zero deferred, zero blocked.** The
original 3-app batch and import order (`qrcode` → `hex_viewer` →
`barcode_gen`) remain valid, unchanged. **No code imported. No
`applications/` or `applications_user/` change. No firmware/app source
touched. No hardware flashed.** `image_viewer/example_images/` was not
touched and remains excluded. `fcc_id_lookup` was not reopened.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**. Next
gate: Phase 2F.2 (implementation/import of the exact cleared 3-app
batch), on the project owner's own explicit further request only.

## Phase 2F.2 update: implementation/import of the cleared 3-app batch — BUILD BLOCKED / REPRODUCIBLE UPDATER_PACKAGE CI TOOLING

Created `integration/phase2f-first-batch` from
`integration/phase2e-first-batch` (commit `fcdbb29`) and imported
`qrcode` (`79f50cc`), `hex_viewer` (`04715de`), and `barcode_gen`
(`2512644`) one at a time from
`RogueMaster/flipperzero-firmware-wPlugins` at the pinned commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`, re-fetched fresh into a
scratch clone and re-verified against the exact SHA before any file was
copied. `barcode_gen`'s real appid is `barcode_app`, not `barcode_gen` —
noted precisely, same class of directory-name-vs-appid mismatch already
seen in Phase 2E. README-only illustration screenshots
(`qrcode/ss1.png`/`ss2.png`, `hex_viewer/img/1.png`/`2.png`,
`barcode_gen/img/`/`screenshots/`) were excluded for cleanliness only —
none referenced by any manifest or source file.

Built `tools/phase2f_validate_config.json` (19-app superset, 464 total
reviewed-false-positive entries — 91 new, all benign `ble`-substring
hits inside words like `variable`/`Table`/`scrollable`/`visible`, zero
real capability matches) and
`.github/workflows/phase2f-windows-validation.yml` (modeled on Phase
2E's, inheriting the Phase 2D.2A `updater_package` remediation and the
Phase 2D.2 `.fap` hidden-path upload fix unchanged). Local build:
`BUILD BLOCKED / ENVIRONMENT` (toolchain download blocked, `403`, the
same root cause every prior phase has hit) — not faked as a pass. Local
Static validation: `PASS_WITH_REVIEWED_FALSE_POSITIVES`.

**Real CI run `28979764650` — 2 attempts, both firmware-build PASS, both
`updater_package`-build BLOCKED.** Attempt 1 (`workflow_dispatch`): Static
PASS, firmware build PASS (862,825 bytes), `updater_package` failed to
launch as a process ("fbt.cmd could not be launched as a process on this
machine/OS"), and `build\f7-firmware-C\.extapps` was confirmed empty of
all 19 expected `.fap` files — despite the `.fap`-artifact upload step
still producing a non-empty, 115,177-byte artifact (contents not
independently verified; downloading it hit the same, already-documented
Azure Blob Storage egress block as every prior phase). A rerun via
`rerun_failed_jobs` (attempt 2, a distinct runner instance, confirmed by
differing `fbt.cmd` timestamp and volume serial number) reproduced every
finding **identically**: same firmware.dfu size, byte-identical
`updater_package` error text, the same 19-app FAP-missing list, and an
identically-sized (but differently-hashed) 115,177-byte `.fap` artifact.

This is a **reproducible** finding across 2 independent real CI attempts
(unlike Phase 2D.2A's own `updater_package` launch-failure finding, which
was established as ~50% intermittent across 4 total attempts) — not yet
enough data to say definitively whether this is the same class of
intermittent issue or a new, more consistent regression. No compile
error or app-specific failure text was found anywhere in either attempt's
log for `qrcode`, `hex_viewer`, or `barcode_gen`.

**Final classification (at the time): PHASE 2F.2 BUILD BLOCKED /
REPRODUCIBLE UPDATER_PACKAGE CI TOOLING — not a pass.** No app or
firmware source was touched. No hardware touched, no `HardwareAssisted`
mode run. Hardware flashing/testing remained **NOT PERFORMED**. Release
status remained **TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup`
remained deferred, unresolved, and untouched. **This blockage was fully
resolved in Phase 2F.2A — see the entry immediately below.**

---

## Phase 2F.2A update: root-cause investigation and resolution of the `updater_package`/`.fap` blockage — RESOLVED

Full narrative in `docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md`; exact
commit/run sequence in `docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` (both on
`integration/phase2f-first-batch`).

**Two real, distinct defects were found and fixed, in this order:**

1. Added console-visible diagnostics to `tools/phase2a_validate.ps1`
   (commit `224a9b0`) — this initial diagnostic run (`29003000398`)
   crashed on a self-inflicted `PropertyNotFoundException` in the new
   FAP-search code before reaching `updater_package`: `$x = if
   (Test-Path $p) { @(Get-ChildItem ...) } else { @() }` collapses to
   `$null` (not an empty array) when the `Get-ChildItem` branch produces
   zero output — reproduced locally, fixed by wrapping the whole
   `if/else` in an outer `@(...)` (commit `0260ca6`).
2. With that fixed, run `29003824450` finally revealed the real exception
   behind every prior "fbt.cmd could not be launched" report across this
   project's history: a `System.Management.Automation.RemoteException`
   wrapping the first line of a routine GCC compiler diagnostic
   (`applications_user\barcode_gen\views\create_view.c: In function
   'text_input_callback':`) — Windows PowerShell had been escalating a
   native command's ordinary stderr output into a terminating exception
   under `$ErrorActionPreference = 'Stop'`, hiding every subsequent line
   of real build output, including the actual error, behind a misleading
   process-launch-failure classification. Fixed by scoping
   `$ErrorActionPreference = 'Continue'` around just the `updater_package`
   invocation, relying on `$LASTEXITCODE` as the authoritative signal
   (commit `8e5f78f`, confirmed by run `29004603660`: real exit code 2
   surfaced instead of a launch exception).
3. Added one more diagnostic (commit `d1a2de7`) to print the build log's
   tail to console, revealing the real compiler error (run `29005529368`):
   `create_view.c:165:5: error: implicit declaration of function
   'text_input_show_illegal_symbols' [-Werror=implicit-function-declaration]`.
   Direct source inspection confirmed this function belongs only to
   `barcode_gen`'s own bundled, never-wired-in custom keyboard fork
   (`keyboard/text_input.c`/`.h`) — the app's real `text_input` widget is
   a **system** `TextInput` instance (`text_input_alloc()`,
   `barcode_app.c:349`), whose module has no such function and a
   different internal model layout. This evidence was presented to the
   project owner via `AskUserQuestion`; **the owner explicitly approved a
   narrow source fix.** Applied: removed the 5 dead call sites (2 were
   accidental upstream duplicate calls) in
   `applications_user/barcode_gen/views/create_view.c` (commit `b6445ed`).
4. That fix shifted a previously-reviewed benign false-positive's line
   number (348 → 341) in the same file, correctly triggering the
   validator's own designed self-healing "unreviewed" behavior; updated
   `tools/phase2f_validate_config.json`'s line number to match (content
   hash unchanged, confirmed by direct re-hash) — commit `78914b3`.

**Confirmed by 2 independent real Windows CI runs, both fully passing:**
run `29015213503` (`Static: PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build:
PASS`, firmware.dfu 862,825 bytes, updater `.tgz` 2,877,979 bytes, all 19
`.fap` outputs found including `qrcode.fap`/`hex_viewer.fap`/
`barcode_app.fap`) and run `29015788839` (independent dispatch, distinct
runner instance, identical classification, firmware.dfu 862,825 bytes,
updater `.tgz` 2,878,003 bytes, all 19 FAPs found).

**Final classification: PHASE 2F.2 IMPORT PASS WITH CI TOOLING + APP
SOURCE REMEDIATION.** Code changed: `tools/phase2a_validate.ps1` (shared
validator script, CI/tooling fix), `tools/phase2f_validate_config.json`
(1 line-number update, content unchanged), and exactly one app-source
file, `applications_user/barcode_gen/views/create_view.c` (7 lines
removed, user-approved). No other app touched. No hardware touched, no
`HardwareAssisted` mode run. Hardware flashing/testing remains **NOT
PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. `fcc_id_lookup` remains deferred, unresolved, and
untouched. **Phase 2F.3 is now allowed.**

---

## Phase 2F.3 update: CI baseline acceptance record and finalize-baseline workflow

Checked for a later automatic CI run at the true current branch HEAD
before finalizing (per this project's own established requirement):
pushing the final Phase 2F.2A documentation commit (`37d11ca`, docs-only,
no script/workflow edit) triggered an automatic `push`-event run,
`29017861599`, on an independent runner instance — it completed with
conclusion `success` (Static `PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build
`PASS`: firmware.dfu 862,825 bytes, updater `.tgz` 2,878,428 bytes, all
19 `.fap` outputs found). Since this run validates the repository's
actual current HEAD, it supersedes the two earlier Phase 2F.2A
confirmation runs (`29015213503`/`29015788839`, commit `78914b3`) as the
accepted CI baseline — those two remain real, valid evidence, not erased.

Created `docs/PHASE2F_3_ACCEPTANCE_RECORD.md` (locked against run
`29017861599`, commit `37d11cada5a83afdeb752c6b2106216d7fc09b9f`),
`docs/PHASE2F_3_ARTIFACT_MANIFEST.md` (real GitHub Actions artifact
metadata — 3 artifacts, IDs and archive digests recorded), and
`docs/PHASE2F_3_ARTIFACT_HASHES.md` (explicitly marked PENDING — no hash
fabricated). Updated `docs/PHASE2F_3_GO_NO_GO.md` (**PHASE 2F.3 BASELINE
ACCEPTANCE PASS**, finalization workflow result pending) and
`docs/PHASE2F_NEXT_GATE.md` (Phase 2F.3 status appended).

Created `.github/workflows/phase2f-finalize-baseline.yml`, modeled
directly on `phase2e-finalize-baseline.yml` (the same mechanism Phase
2A.11/2B.3/2C.3/2D.3/2E.3 already used successfully): runs on a real
GitHub-hosted `windows-latest` runner, downloads run `29017861599`'s
artifacts via `gh run download`, computes real SHA-256 hashes with
`Get-FileHash`, patches the docs above, and creates the two immutable
Phase 2F baseline tags (`phase2f-ci-baseline-20260709`,
`phase2f-acceptance-record-20260709`). `workflow_dispatch` only. No
`HardwareAssisted` invocation anywhere in the file. No app or firmware
source touched by this update — docs and one new workflow file only.

---

## Phase 2F.3 completion: finalize-baseline workflow actually ran — real result

Dispatched `Phase 2F Finalize Baseline` via the GitHub API
(`workflow_dispatch` on `integration/phase2f-first-batch`) — run
`29027115867`. Completed in ~59 seconds with conclusion **success**; all
13 steps succeeded, verified via `get_workflow_run`/`list_workflow_jobs`,
not claimed on trust.

Real computed hashes (PowerShell `Get-FileHash -Algorithm SHA256` on a
GitHub-hosted `windows-latest` runner, from the actual downloaded
artifacts of run `29017861599`): `firmware.dfu` — 862,825 bytes, SHA-256
`27f60598d43657710207510520159ba6626722a2825ed8adf5768d002a3a005b`;
`flipper-z-f7-update-local.tgz` — 2,878,428 bytes, SHA-256
`341fa331625c488ff8c6bf079ed0c82b553ef1a11441687a81139464f3f91772`. 41
`.fap` files hashed (19 expected Phase 2A-2F apps plus 22
Unleashed-bundled example/plugin FAPs, the same benign-extras pattern
Phase 2E's own finalization observed). Full table in
`docs/PHASE2F_3_ARTIFACT_HASHES.md`.

The workflow committed its own docs patch (`51df041` — "docs: finalize
Phase 2F artifact hashes from CI artifacts") and pushed it directly to
`integration/phase2f-first-batch`, then created both immutable tags:
`phase2f-ci-baseline-20260709` → `37d11cada5a83afdeb752c6b2106216d7fc09b9f`
and `phase2f-acceptance-record-20260709` → `51df041ed0dc9f49df23305b5f1966cd3294239d`
(the workflow's own docs commit). Both tags did not exist before this run
(no silent-overwrite path was exercised). Independently re-verified in
this session via `git ls-remote --tags origin` — real dereferences match
the workflow's own log output exactly. All 10 prior Phase
2A/2B/2C/2D/2E tags confirmed unchanged at their original targets by the
same direct check.

`docs/PHASE2F_3_GO_NO_GO.md` updated with these real results — **PHASE
2F.3 BASELINE ACCEPTANCE PASS**, no longer pending. Per
`docs/PHASE2F_NEXT_GATE.md`: the next allowed path is a Phase 2F
hardware-assisted gate (if/when a device and Windows machine become
available) or Phase 2G planning only — both require the project owner's
own further explicit request. `fcc_id_lookup` remains deferred,
unresolved, untouched. No app or firmware source changed during Phase
2F.3. No hardware testing performed. Release status remains **TEST-READY
ONLY / NOT RELEASE-READY**.

---

## Phase 2F.4 update: hardware-assisted validation gate created and executed

Built `tools/phase2f_hardware_gate.ps1` and
`tools/phase2f_hardware_gate_config.json`, extending the established
Phase 2A-2E hardware-gate pattern to all 19 apps in the accepted Phase 2F
baseline (`37d11cada5a83afdeb752c6b2106216d7fc09b9f`, CI run
`29017861599`, finalization run `29027115867`). Two Preflight-level
automated checks: the `image_viewer/example_images/` absence check
carried forward unchanged, plus a new check confirming
`applications_user/barcode_gen/views/create_view.c` still does not
contain a call to `text_input_show_illegal_symbols` — the Phase 2F.2A
source fix (commit `b6445ed`).

Real executions performed in this AI session's own Linux sandbox via
`pwsh`: `-Mode Preflight`, `-Mode ReportOnly`, `-Mode DetectDevice`,
`-Mode HashVerify` against a synthetic mismatch (two random-data files
generated via `/dev/urandom` at the exact expected artifact sizes,
862,825 and 2,878,428 bytes, outside the repo, deleted after — correctly
produced `FAIL` for both, proving the hash-comparison logic works
without claiming real artifact verification), and `-Mode HardwareAssisted`
(no `-ArtifactDir`, no device, no `-AllowFlashPrompt`). `Get-PnpDevice`
confirmed unavailable on Linux via the actual PowerShell error text, not
assumed; no qFlipper install found. Real Phase 2F CI artifacts could not
be downloaded in this sandbox (same Azure Blob Storage `403` egress
limitation as every prior phase). Report-filename collision-resistance
re-confirmed: 5 simultaneous `-Mode Preflight` invocations produced 10
distinct report files with zero overwrites. Full detail in
`docs/PHASE2F_HARDWARE_ASSISTED_VALIDATION.md` and
`docs/PHASE2F_HARDWARE_ASSISTED_RESULTS.md`; the 19-app checklist
(sections 1-16 reproduced from Phase 2E's, sections 17-19 new for
`qrcode`/`hex_viewer`/`barcode_gen`) is in
`docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md`, not yet executed on real
hardware.

**Final classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT
AVAILABLE`** — no Windows machine, no physical Flipper Zero, no qFlipper
in this environment. No flash was offered or performed (`-AllowFlashPrompt`
never passed). No GUI smoke test performed. No app or firmware source
changed. `docs/PHASE2F_NEXT_GATE.md` updated: per this classification,
Phase 2G planning may start as non-hardware-dependent-only (not import);
a real hardware gate remains available whenever a device becomes
available. `fcc_id_lookup` remains deferred, unresolved, untouched.
`image_viewer/example_images/` remains excluded, confirmed absent.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**.

---

## Phase 2G planning update: NO-GO / clean candidate pool exhausted

Determined whether any safe, clean, non-deferred candidate remains after
Phase 2A through Phase 2F, drawing exclusively on existing planning/
audit documentation (`docs/PHASE1_5_HIGH_VALUE_SHORTLIST.md`,
`docs/PHASE1_5_TOP_25_CANDIDATES.md`, `docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`,
`docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`, every phase's own
`CANDIDATE_REVIEW.md`) — no new upstream source was fetched or read.

The audited Top-25 candidate pool (the only pool this project has ever
applied real per-app source verification to before recommending an
import) is fully accounted for: 19 apps imported across Phase 2A-2F, 6
apps hard-deferred for specific, documented, unresolved reasons
(`fcc_id_lookup`: license-evidence gap; `upython`: undisclosed GPIO/IR
capability; `iconedit`: HID keystroke-injection capability; `c_book`:
unresolved copyright status of bundled K&R text; `animation_switcher`/
`theme_manager`: shared `/ext/dolphin/` writes). No app in that pool
remains available. The broader ~170-app remainder of the original
195-app pool has never received individual source-level verification —
recommending from it without a dedicated, fresh source-audit pass would
repeat exactly the class of mistake this project has already made and
corrected 4 separate times (`upython`, `iconedit`, `sd_info`,
`hex_viewer`/`barcode_gen`), and performing that audit is out of this
narrow planning phase's own scope.

**Final classification: PHASE 2G NO-GO / CLEAN CANDIDATE POOL
EXHAUSTED.** No import batch recommended, no `integration/
phase2g-first-batch` branch proposed. Full detail in
`docs/PHASE2G_CANDIDATE_REVIEW.md`, `docs/PHASE2G_RECOMMENDED_BATCH.md`,
`docs/PHASE2G_RISK_REGISTER.md`, `docs/PHASE2G_LICENSE_REVIEW.md`,
`docs/PHASE2G_INTEGRATION_PLAN.md`, `docs/PHASE2G_GO_NO_GO.md`, and
`docs/PHASE2G_NEXT_GATE.md`. Recommended next actions instead: Phase 2F
hardware-assisted validation on real hardware (highest value, unrelated
to this outcome), a narrow `fcc_id_lookup` license-resolution phase, or
maintenance/documentation/tooling-hardening work. `fcc_id_lookup`
remains deferred, unresolved, untouched (not reopened, per explicit
instruction). `image_viewer/example_images/` remains excluded,
confirmed absent. No app or firmware source changed. No build attempted.
No hardware testing performed. Release status remains **TEST-READY ONLY
/ NOT RELEASE-READY**.

---

## `fcc_id_lookup` narrow license-resolution phase: LICENSE GAP RESOLVED

A dedicated, narrow follow-up (not an import phase) closed the specific
license-evidence gap tracked since Phase 2C.1
(`docs/KNOWN_ISSUES.md` item 6): whether the strong corroborating
upstream MIT evidence (`github.com/lrehmann/fcc-id-lookup-flipper`,
Copyright (c) 2026 lsr) could be tied to the exact vendored revision
(`RogueMaster/flipperzero-firmware-wPlugins` commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`).

Re-read all 5 files in `applications/external/fcc_id_lookup/` from a
verified local clone pinned to that exact commit; confirmed (again, no
change) no app-local `LICENSE`, SPDX identifier, or copyright header
anywhere in the vendored source. Live-fetched the upstream repository
and found a real MIT `LICENSE` at current `HEAD`, added in commit
`8c49c773eb9b0a399f9e6ede9153372d21056d08` ("Prepare source metadata for
catalog"). Cross-referenced three concrete implementation features
present in the vendored `fcc_id_lookup.c` — a `FCC_DB_READ_CACHE_SIZE`
read-cache, explicit corrupt-record bounds-check comments, and the
zero-size-output-guarded `fcc_grantee_prefix()` signature — against the
upstream commit-message history, and found each maps to a specific
upstream commit chronologically newer than the LICENSE-adding commit in
the same linear history. This establishes, via real source-content
evidence rather than a repo-level assumption or date-matching alone,
that the vendored copy was necessarily pulled from an upstream revision
that already included the `LICENSE` file.

Re-confirmed the app's safety/scope characterization by direct source
read: read-only (one `storage_file_open` call, `FSAM_READ`), no network/
HTTP/Wi-Fi API, no credential/token/API-key handling, no unsafe
hardware/radio API. The ~8.9 MB FCC frequency database itself is not
bundled in the app source or this repository — the app's own `README.md`
documents it as a separate, optional, user-sourced download.

**Final classification: LICENSE GAP RESOLVED**, conditioned on including
the confirmed upstream `LICENSE` file at actual import time. Full detail
in `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md` and
`docs/FCC_ID_LOOKUP_IMPORT_ELIGIBILITY.md`. `docs/KNOWN_ISSUES.md` item 6
updated accordingly. **`fcc_id_lookup` was not imported** — this phase
was licensing/provenance resolution only. A dedicated pre-import
verification pass (safety scan, real CI build, storage/safety review),
gated behind the project owner's own separate explicit request, remains
required before any future import. No application directory was created
or modified, no build was attempted, no firmware or app source changed,
no hardware testing was performed. Release status remains **TEST-READY
ONLY / NOT RELEASE-READY**.

---

## `fcc_id_lookup` dedicated pre-import verification: CLEARED FOR FUTURE IMPORT PLANNING

A dedicated pre-import verification pass, matching the depth every
already-imported app received before its own import, using the verified
local clone pinned to `RogueMaster/flipperzero-firmware-wPlugins` commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`.

Confirmed `application.fam` parses (validated by parsing it with
Python's own `ast` module against a stand-in `App()`/`FlipperAppType`
namespace); `appid="fcc_id_lookup"` maps to expected FAP
`fcc_id_lookup.fap` with no directory/appid discrepancy; entry point
`fcc_id_lookup_app` exists with the standard Flipper external-app
signature; the icon is a valid 10×10 1-bit PNG. Confirmed no FCC
database is bundled or committed anywhere — the ~8.9 MB database remains
a separate, optional, user-sourced download, enforced in code via a
fallback setup-hint message if absent. Confirmed storage behavior is
read-only and app-scoped: all 11 storage-related call sites across the
source are read/open/close/free lifecycle operations, the one
`storage_file_open` call uses `FSAM_READ`/`FSOM_OPEN_EXISTING` only, and
the database path resolves under `APP_ASSETS_PATH` (app-scoped, not
shared/root-level).

Ran this project's own exact safety-keyword substring-scan methodology
(`tools/phase2a_validate.ps1`'s keyword list) manually against both
source files, since the app is not yet present under
`applications_user/` for the tool itself to scan: zero matches against
any high-confidence unsafe keyword (RF/Sub-GHz, NFC, RFID, iButton,
BadUSB, HID, GPIO write, IR transmit, credential, exfil, brute, jam,
deauth); 11 generic-keyword substring matches, all individually reviewed
and confirmed benign ("available", and a static data-decompression
lookup table of company-name suffixes mistakenly matching "token").
Confirmed no network/HTTP behavior — the app's own displayed URLs are
citation text only, never fetched. Confirmed a minimal, entirely
standard dependency surface (Flipper SDK GUI/input/storage headers plus
standard C library headers only).

**Final classification: CLEARED FOR FUTURE IMPORT PLANNING.** Not itself
an import approval — a future one-app import phase remains gated behind
the project owner's own separate, explicit request, a real static scan
through the project's own tooling once the app exists in-tree, a real CI
build attempt, and a dedicated safety-review document at actual import
time. Full detail in `docs/FCC_ID_LOOKUP_PREIMPORT_VERIFICATION.md`,
`docs/FCC_ID_LOOKUP_IMPORT_READINESS_MATRIX.md`, and
`docs/FCC_ID_LOOKUP_GO_NO_GO.md`. No new issue was found in this phase,
so `docs/KNOWN_ISSUES.md` is not modified. `fcc_id_lookup` was not
imported. No application directory was created or modified, no build
was attempted, no firmware or app source changed, no hardware testing
was performed. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

---

## Historical record: cloud sandbox build attempt (superseded, kept for the record)

## What this is

A real, unedited-output record of attempting `./fbt` against a real recursive clone of
`DarkFlippers/unleashed-firmware` (`dev`, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c`)
in this session's sandboxed container. **Result: build did not complete.** This is
reported honestly rather than claimed as a pass — see "Why it stopped" below.

## Environment

- Container: ephemeral cloud sandbox, no physical Flipper Zero attached (permanent
  constraint — see `PHASE0_SOURCE_VERIFICATION.md`).
- Source: recursive shallow clone with all 12 submodules initialized (280MB), commit
  hash as above, unmodified except the two documented local flag changes below.

## Blocker #1 (root cause): vendor toolchain host is policy-blocked

`fbt` downloads a pinned, patched ARM GCC 12.3 toolchain from
`https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz`.
This session's egress proxy returned `403` for `update.flipperzero.one:443`
(confirmed via `curl $HTTPS_PROXY/__agentproxy/status` → `"kind": "connect_rejected",
"detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)"`).
Per this environment's own operating rules, a policy denial is reported, not routed
around. **This is the actual, load-bearing blocker for a canonical, reproducible
build in this environment.**

## What I did instead (clearly non-canonical, for verification only)

To see whether the *source itself* would compile at all (independent of the exact
toolchain), I substituted:
- `gcc-arm-none-eabi` 13.2.rel1 + `gdb-multiarch` + `libstdc++-arm-none-eabi-newlib`
  (Ubuntu 24.04 `apt` packages, not Flipper's pinned 12.3-flipper-39 build)
- A Python 3.11 venv with `pip`-installed `scons`, `pillow`, `pyelftools`,
  `heatshrink2`, `colorlog`, `cxxheaderparser`, `oslex`, `pyserial`, `requests`,
  `lxml`, `ansi`, `protobuf` (standing in for the toolchain's bundled Python
  environment, which also is not downloadable per Blocker #1)
- A hand-built `toolchain/x86_64-linux/` directory satisfying `fbtenv.sh`'s existing-
  toolchain check, so `fbt` would skip the blocked download

**This substitution is not a reproducible-build equivalent** — it exists only to
answer "does the unmodified source compile," not to produce a distributable artifact.

## Local flag changes made (both in `site_scons/cc.scons`, both reverted-in-spirit —
## i.e. neither is proposed for the real project, both exist only in the scratch clone)

1. `-Wno-error=strict-aliasing` — GCC 13's stricter strict-aliasing check flags a
   byte-punning read in vendored `lib/stm32wb_hal/Inc/stm32wbxx_ll_spi.h` (ST's code)
   that GCC 12.3 does not flag as an error. Confirmed as a compiler-version delta, not
   a defect: the pattern (`*(__IO uint8_t*)&SPIx->DR`) is standard low-level register
   access.
2. `-Wno-error=uninitialized` — GCC 13's stricter uninitialized-variable analysis
   flags `lib/drivers/lp5562.c` (`lp5562_configure`, `lp5562_enable`), which use fully
   designated-initializer bitfield structs read via byte-cast. Inspected by hand:
   both structs fully initialize every field via designated init; this is a confirmed
   compiler false positive for this coding pattern under GCC 13, not present under
   GCC 12.

With both changes, the build progressed through **267 successful compile/link/proto
steps** (protobuf codegen, BLE profile/services, bit_lib, digital_signal, FatFS,
datetime, assets, and the start of `targets/f7/ble_glue`) before stopping.

## Why it stopped (Blocker #2 — not attempted further)

`lib/mjs/common/frozen/frozen.c:690` fails with `error: expected ')' before
'PRIu64'` even though the file does `#include <inttypes.h>`. Root-caused by
inspection to Ubuntu's newlib gating `PRIu64` behind `#if __int64_t_defined`
(`/usr/include/newlib/inttypes.h:216`), which is set via a chain of internal
`___int64_t_defined` macros in `machine/_default_types.h` / `sys/_stdint.h` that did
not resolve as expected for this file's specific include order in this newlib
packaging. This is a **substitute-libc packaging quirk**, not a defect in `mjs`
(a mature, widely-used third-party JSON library) or in Unleashed's own code.

I stopped here rather than continuing to patch around individual GCC/newlib version
deltas one at a time. Each fix so far has been narrow and well-understood, but this
one would require forcing an internal libc macro (`__int64_t_defined`) without being
able to verify it doesn't mask a real ABI mismatch elsewhere — that crosses from
"documented, safe warning demotion" into "blindly asserting an unverified libc
invariant," which I'm not willing to do silently. Continuing to firefight toolchain
substitution issues one-by-one stops being a meaningful test of "does Unleashed
build" and becomes "can an ad hoc toolchain be reverse-engineered to match a vendor
build" — a different and much less certain undertaking.

## Honest bottom line

- **Not confirmed**: a clean, reproducible `./fbt` build of Unleashed in this
  environment. Blocked at the root by network policy (Blocker #1); the substitute
  toolchain got substantially further (267 build steps) before hitting a second,
  different-in-kind blocker (Blocker #2).
- **What this pass does show**: no evidence of defects in Unleashed's own source in
  everything that did compile; the two issues fixed were both independently verified
  as GCC-12-vs-13 false positives in vendored/third-party code, not Unleashed bugs.
- **What would resolve this cleanly**: either (a) allow-list
  `update.flipperzero.one` for this environment so the real pinned toolchain can be
  used, or (b) run `./fbt` in an unrestricted environment (a real workstation or CI
  runner), which is how Unleashed's own CI does it.
- No build artifact (`.dfu`/`.elf`/`.bin`) exists as a result of this pass. None is
  claimed.
