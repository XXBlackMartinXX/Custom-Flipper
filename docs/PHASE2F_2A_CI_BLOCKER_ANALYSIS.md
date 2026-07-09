# Phase 2F.2A — CI Blocker Analysis

Docs only. This is the closing root-cause analysis for the Phase 2F.2
`updater_package`/`.fap` blockage recorded in `docs/PHASE2F_2_BUILD_REPORT.md`
and `docs/PHASE2F_2_GO_NO_GO.md`. It supersedes the "not yet resolved"
status of those two documents' Build finding — see the updated versions
of both for the final classification. Nothing about the original 2
failed attempts is erased; this document explains what actually caused
them, using only real, quoted CI evidence gathered in this phase.

## Summary of the original blockage (both attempts failed identically)

- **Run `28979764650`, attempt 1** (commit `e5d2905`): Static PASS.
  Firmware build PASS, exit 0, 862,825 bytes. `updater_package`:
  **BLOCKED** — "fbt.cmd could not be launched as a process on this
  machine/OS." `build\f7-firmware-C\.extapps` confirmed **empty**
  immediately after the firmware build succeeded. Per-app FAP
  verification: 0 of 19 found. `.fap`-artifact upload still produced a
  non-empty 115,177-byte artifact (sha256 `b299fe1d...`), despite zero
  named FAPs being found — an unexplained anomaly at the time.
- **Run `28979764650`, attempt 2** (same commit, rerun via
  `rerun_failed_jobs`, distinct runner instance): every material finding
  reproduced identically — BLOCKED, `.extapps` empty, 0/19 FAPs, and a
  115,177-byte `.fap` artifact again (same size, different sha256
  `43bc6a75...`).

Because both real attempts failed identically, this was classified
`PHASE 2F.2 BUILD BLOCKED / REPRODUCIBLE UPDATER_PACKAGE CI TOOLING` — a
real, unresolved finding, explicitly not blamed on `qrcode`, `hex_viewer`,
or `barcode_gen`'s source at that point, since no log evidence yet existed
to attribute it to anything specific.

## Investigation path (this phase, in order, with real run IDs)

### Step 1 — added console-visible diagnostics (commit `224a9b0`, run `29003000398`)

Added, purely additively (no pass/fail logic changed): pre-firmware-build
diagnostics (cmd.exe resolution, fbt.cmd metadata/ACL, per-app directory
listings, appid-vs-manifest parsing for all 19 apps), an expanded
PowerShell-version dump (full `$PSVersionTable`, process image path via
`Get-CimInstance`), a FAP-search diagnostic (recursive search under
`build\` and repo-wide, explicit `qrcode.fap`/`hex_viewer.fap`/
`barcode_app.fap` FOUND/NOT FOUND checks, and what the workflow's own
upload-artifact glob would match), and — critically — `Write-Host` calls
so the firmware-build and `updater_package` launch exceptions'
`.Exception.Message`/`.GetType().FullName`/`InnerException` text would
finally appear in the console log instead of only a workflow-artifact log
file this session could never download (confirmed blocked, every attempt,
by the same Azure Blob Storage `CONNECT tunnel failed, response 403`
error throughout this whole project's history).

**Result**: run `29003000398` completed with `conclusion: failure` before
even reaching `updater_package`. Real evidence recovered from the job log:
firmware build itself **PASSED** (exit code 0) — the first time this
project ever confirmed the build succeeding immediately before the
`.extapps` check — but the run then crashed with:

```
D:\a\Custom-Flipper\Custom-Flipper\tools\phase2a_validate.ps1 : The property 'Count' cannot be found on this object.
Verify that the property exists.
    + CategoryInfo          : NotSpecified: (:) [phase2a_validate.ps1], PropertyNotFoundException
    + FullyQualifiedErrorId : PropertyNotFoundStrict,phase2a_validate.ps1
```

This was a **self-inflicted bug in this phase's own new diagnostic code**,
not the original blocker — it crashed before `updater_package` was even
attempted, so this run produced no new evidence about the original issue.

### Step 2 — root-caused and fixed the diagnostic-code bug (commit `0260ca6`)

Reproduced locally in a throwaway pwsh script: the pattern
`$x = if (Test-Path $p) { @(Get-ChildItem ...) } else { @() }` collapses
to **`$null`** (not an empty array) when the `Get-ChildItem` branch
produces zero pipeline output — the inner `@(...)` wrapping does not
survive being returned through the outer `if`-expression on assignment.
Confirmed via direct reproduction (4 isolated test cases, one exact match
to the broken pattern reproducing `$null`, one fix — wrapping the entire
`if/else` in an outer `@(...)` — reproducing a correct empty array).
Applied the fix to both affected variables (`$fapsUnderBuild`,
`$uploadGlobMatches`); the third (`$fapsRepoWide`) was already safe since
it assigns `@(...)` directly with no intervening `if/else`. Verified
locally: `[System.Management.Automation.Language.Parser]::ParseFile()`
reported no errors, and the isolated reproduction confirmed the fix
produces `System.Object[]`/count 0 instead of throwing.

### Step 3 — the real root cause, seen for the first time (run `29003824450`, commit `0260ca6`)

With the diagnostic-code bug fixed, this run got past the crash point and
reached `updater_package` for real. Real evidence from the job log:

```
LAUNCH EXCEPTION (process could not be started - this is an environment problem, not evidence of a source defect): System.Management.Automation.RemoteException: applications_user\barcode_gen\views\create_view.c: In function 'text_input_callback':
[BLOCKED     ] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)
```

The exception's real type — `System.Management.Automation.RemoteException`
— and its message text — the first line of an ordinary GCC compiler
diagnostic, not any kind of process-launch failure — directly
contradicted the generic "fbt.cmd could not be launched as a process on
this machine/OS" text this project had been reporting for every prior
`updater_package` failure (that phrasing was this script's own hardcoded
detail string for the `BLOCKED` classification branch, applied uniformly
to any caught exception — not the real exception message, which had never
been visible in a console log before this run). Also recorded in this
same run: `PowerShell edition: Desktop` (i.e. Windows PowerShell 5.1, not
PowerShell 7/Core, despite `shell: pwsh` in the workflow — parent process
confirmed as `C:\Program Files\PowerShell\7\pwsh.EXE`), and `Real .fap
files found anywhere under build\` / `anywhere in the repo`: **0** either
way, with `qrcode.fap`/`hex_viewer.fap`/`barcode_app.fap` all explicitly
`NOT FOUND anywhere in the repo`.

**Root cause identified**: under `$ErrorActionPreference = 'Stop'`
(script scope), Windows PowerShell wraps a native command's stderr output
in `NativeCommandError` records; with `'Stop'` active, the *first* such
record becomes a terminating exception — aborting the whole
`updater_package` invocation before it can finish emitting that
diagnostic, let alone complete the FAP build, regardless of whether the
stderr text represents a real fatal error or an ordinary compiler
diagnostic line. This is a CI/tooling defect, not an app-source defect by
itself — though it was masking one (see Step 5).

### Step 4 — fixed the CI/tooling root cause (commit `8e5f78f`, confirmed by run `29004603660`)

Fix: scope `$ErrorActionPreference` to `'Continue'` for just the
`updater_package` `cmd /c` invocation (restored afterward via `finally`),
relying on `$LASTEXITCODE` (already captured) as the authoritative
pass/fail signal — exactly as the firmware-build invocation above it
already does, and exactly the officially-recommended pattern for
launching external processes from PowerShell without letting incidental
stderr text become a terminating error. The firmware-build invocation
itself was deliberately left untouched (no evidence implicated it, and it
has a clean real-CI track record).

**Confirmed working** by run `29004603660`: no more `LAUNCH EXCEPTION`.
Real evidence:

```
[FAIL        ] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)
             fbt.cmd launched and exited 2. Full log: .\reports\phase2f\build_updater_20260709_083047.log
```

The process now genuinely ran (observed duration consistent with a real
compile attempt) and genuinely failed with exit code 2 — a real build
failure, no longer a tooling-level abort. `.extapps` still empty, 0/19
FAPs, `.tgz` not produced — consistent with a real compile failure
blocking the whole FAP-build batch.

### Step 5 — recovered the real compiler error (commit `d1a2de7`, run `29005529368`)

Exit code 2 alone didn't say what failed — the log file with the actual
compiler/scons output was still only in an undownloadable workflow
artifact. Added one more narrow, additive diagnostic: print the last 150
lines of the `updater_package` build log directly to console after the
attempt. Real evidence recovered:

```
	CC	applications_user\barcode_gen\views\create_view.c
	CC	applications_user\barcode_gen\views\message_view.c
	ICONS	build\f7-firmware-C\.extapps\barcode_app\barcode_app_icons.c
	CC	applications_user\barcode_gen\barcode_utils.c
	CC	applications_user\barcode_gen\barcode_app.c
cmd : applications_user\barcode_gen\views\create_view.c: In function 'text_input_callback':
applications_user\barcode_gen\views\create_view.c:165:5: error: implicit declaration of function
'text_input_show_illegal_symbols' [-Werror=implicit-function-declaration]
  165 |     text_input_show_illegal_symbols(create_view_object->barcode_app->text_input, true);
      |     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cc1.exe: all warnings being treated as errors
scons: *** [build\f7-firmware-C\.extapps\barcode_app\views\create_view.o] Error 1
```

Also visible in this same log: `findmy.fap`, `hid_usb.fap`, `hid_ble.fap`,
`mfkey.fap`, `mfkey_init_plugin.fal`, and `2048_improved.fap` all built
successfully (`APPMETA`/`FAP`/`FASTFAP` steps completed) before `scons`
reached `barcode_gen` and stopped on this error — direct evidence that
the build pipeline itself works correctly for other apps, and that this
specific compile error in `barcode_gen` was blocking the entire batch
(consistent with 0/19 FAPs found, not just the 3 new apps: `scons`
without `-k`/`--keep-going` stops launching new build steps once an error
occurs).

### Step 6 — real app-source defect confirmed by direct source inspection, fixed with explicit user approval (commit `b6445ed`, run `29013915792`)

This was presented to the user as a concrete finding, with the analysis
below, and the user was asked how to proceed via `AskUserQuestion` before
any `applications_user/` file was touched. The user explicitly chose
"Attempt a narrow source fix."

**Direct source investigation** (grep across `applications_user/barcode_gen/`):

- `applications_user/barcode_gen/barcode_app.h:12` includes the
  **system** `<gui/modules/text_input.h>`.
- `applications_user/barcode_gen/barcode_app.c:349` allocates
  `app->text_input` via the **system** `text_input_alloc()`.
- The system header (`applications/services/gui/modules/text_input.h`)
  declares exactly 8 functions — `text_input_alloc`, `text_input_free`,
  `text_input_reset`, `text_input_set_result_callback`,
  `text_input_set_minimum_length`, `text_input_set_validator`,
  `text_input_get_validator_callback`, `text_input_set_header_text` —
  **no `text_input_show_illegal_symbols`.**
- `text_input_show_illegal_symbols` exists only in this app's own
  bundled, alternate keyboard implementation
  (`applications_user/barcode_gen/keyboard/text_input.c:757`/
  `text_input.h:85`, credited to `thevan4` in this app's own
  README/third-party notices) — and **nothing else in the app includes
  `keyboard/text_input.h` or calls its own `text_input_alloc()`**
  (confirmed by grep: zero matches). This custom fork is compiled (it's a
  `.c` file under the app directory, so `scons` builds it), but never
  actually wired into the app's real widget instance.
- The two implementations' outer `struct TextInput { View* view;
  FuriTimer* timer; }` is identical, but the real per-instance state lives
  in each module's own `TextInputModel`, retrieved via
  `with_view_model(text_input->view, TextInputModel* model, {...})` — an
  opaque blob whose size/layout is fixed by whichever `text_input_alloc()`
  actually created it. The custom fork's `TextInputModel` has an
  `illegal_symbols` field; the system module's does not.

**Why an `#include` fix would not have been safe**: since
`app->text_input` is a real instance of the **system** module, forcing
`text_input_show_illegal_symbols()` to compile by including the custom
header would call a function that writes into a model field the system's
actual allocated model struct does not have — undefined behavior, not a
working feature, and not something this project would introduce
knowingly.

**Fix applied**: removed the 5 dead call sites in
`applications_user/barcode_gen/views/create_view.c` (2 of which were
themselves accidental back-to-back duplicate calls already present in the
upstream RogueMaster source — not introduced by this project). No other
logic, control flow, or behavior changed — confirmed via diff (7 lines
removed, nothing else touched).

**Confirmed by run `29013915792`**: Build fully **PASSED** —
`updater_package` PASS exit 0, `firmware.dfu` PASS, updater `.tgz` PASS,
**Per-app FAP output verification PASS** ("All 19 expected .fap files
found in `...\.extapps`"). Static regressed to `NEEDS_REVIEW` for an
unrelated, expected reason (see Step 7).

### Step 7 — config line-number self-heal (commit `78914b3`)

Removing 7 lines from `create_view.c` shifted a previously-reviewed
benign false positive — `FURI_LOG_E(TAG, "Unable to remove file!");`
(the substring `ble` inside `Unable`) — from line 348 down to line 341.
This is the validator's own designed self-healing behavior ("any future
edit to a matched line reverts it to unreviewed automatically") working
exactly as intended, not a new security concern. Confirmed directly: the
JSON report's `Evidence` field for the 1 unreviewed match was
`applications_user/barcode_gen/views/create_view.c:341 [ble]:
FURI_LOG_E(TAG, "Unable to remove file!");` — and the trimmed line's
SHA-256 (`4015651920f2ad319eac8c64e7adad90f6941ed2fdbad3402a8a4d94e8171c11`)
was recomputed locally and found **byte-for-byte identical** to the
original Phase 2F.2 review. Updated `tools/phase2f_validate_config.json`'s
`reviewedFalsePositives` entry's line number from 348 to 341; content
hash unchanged.

## Final confirmation — 2 independent full passes

Per this phase's own requirement (both original Phase 2F.2 attempts
failed identically, so 2 independent post-remediation passes were
required before reclassifying):

- **Run `29015213503`** (commit `78914b3`, runner `1000000239`):
  `Static: PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build: PASS`, `Overall:
  AUTOMATED VALIDATION PASS`. `firmware.dfu`: 862,825 bytes. Updater
  `.tgz` (`dist\f7-C\flipper-z-f7-update-local.tgz`): 2,877,979 bytes.
  "All 19 expected .fap files found in `...\.extapps`."
- **Run `29015788839`** (same commit, independent dispatch, runner
  `1000000240`): identical classification —
  `Static: PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build: PASS`, `Overall:
  AUTOMATED VALIDATION PASS`. `firmware.dfu`: 862,825 bytes (identical).
  Updater `.tgz`: 2,878,003 bytes (24-byte difference from run 1 —
  expected, since build timestamps/metadata embedded in the tarball
  legitimately vary run to run; not a concern). "All 19 expected .fap
  files found in `...\.extapps`."

Both runs independently confirm all 19 `.fap` outputs present, including
by name: `qrcode.fap`, `hex_viewer.fap`, `barcode_app.fap`.

## Final conclusion: **RESOLVED**

The original blockage had two real, distinct causes, both now fixed with
direct evidence:

1. A genuine CI/tooling defect (Windows PowerShell escalating a native
   command's routine stderr output to a terminating exception under
   `$ErrorActionPreference = 'Stop'`), which had silently aborted
   `updater_package` before it could ever complete, on every attempt
   across this entire project's history of this failure class — fixed in
   `tools/phase2a_validate.ps1` (commit `8e5f78f`).
2. A genuine app-source defect in `applications_user/barcode_gen/views/create_view.c`
   — 5 dead calls to a function from an unwired, incompletely-integrated
   custom keyboard fork bundled in the app but never actually used —
   fixed with explicit user approval after presenting the evidence
   (commit `b6445ed`).

Both fixes are narrowly scoped: one shared validator script (already the
established pattern for CI/tooling fixes since Phase 2D.2A) and one
7-line removal in a single app source file. No other app source, no core
firmware, no workflow YAML, and no expected-app/FAP-verification logic
was touched or weakened. See `docs/PHASE2F_2_BUILD_REPORT.md` and
`docs/PHASE2F_2_GO_NO_GO.md` for the updated final classification.
