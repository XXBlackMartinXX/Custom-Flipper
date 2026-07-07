# Phase 2B — Hardware Smoke Test Checklist

Docs only. This is the Phase 2B counterpart to
`docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` (which remains unmodified
and still valid on its own for the 5 apps it covers) — read
`docs/PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` first for scope, safety rules,
and global fail conditions before running any step below; that plan is
batch-agnostic and applies unchanged to this checklist. **No hardware
testing has been performed as part of writing this checklist.**

Record every result in a copy of
`docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md` as you go. If a global
fail condition occurs at any point, stop immediately and follow
`docs/PHASE2A_FLASHING_PRECHECK.md` §5 (rollback) instead of continuing
down this list.

**Phase 2B.4 cross-reference**: `tools/phase2b_hardware_gate.ps1 -Mode
HardwareAssisted` automates the non-GUI preconditions (branch/commit
check, artifact hash verification, device detection, qFlipper detection,
and the flash-confirmation gate) and lists every one of the 8 apps below
as `REQUIRES_HUMAN_OBSERVATION`, pointing back to this checklist — it does
not and cannot perform any of the steps in this document itself. See
`docs/PHASE2B_HARDWARE_ASSISTED_VALIDATION.md` for what that gate does and
does not validate.

Menu path prefix for all 8 apps: **Main Menu → Apps → \<category\>**
(category noted per app below), then the app's own name.

Sections 1–5 (`network_subnet`, `programmer_calc`, `vin_decoder`,
`flipper95`, `chess`) are identical in content to
`docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` — reproduced here so this
document is a complete, standalone checklist for the full 8-app Phase 2B
baseline, not a fragment. Sections 6–8 are new, for the 3 Phase 2B apps.

---

## 1. `network_subnet` (Network Subnet Helper)

- **Category / menu path**: Apps → Tools → "Network Subnet Helper"
- **Launch path**: From the Tools submenu, select "Network Subnet Helper" and
  press OK.
- **Expected screen on launch**: A menu screen offering subnet-calculation entry
  points (IP address input as the first step of the flow).
- **Minimum navigation test**: From the initial menu, navigate into the IP input
  screen, then back out to the app's own menu using Back, confirming Back does not
  exit past the app unexpectedly on the first press.
- **One normal input test**: Enter a valid IPv4 address (e.g. `192.168.1.1`) and a
  valid subnet mask/CIDR (e.g. `/24`), proceed to the result screen, and confirm a
  subnet result is displayed (network address, broadcast address, host range, or
  equivalent — exact fields are this app's own logic, not specified here).
- **One invalid/edge input test**: Enter an out-of-range octet (e.g. `999` in an
  IP field) or an invalid mask value, and confirm the app either rejects the input
  with an on-screen message/refusal to proceed, or clamps it, without crashing or
  freezing.
- **Exit behavior**: Press Back repeatedly from the result screen until returning
  to the main Tools menu; confirm this happens cleanly (no crash, no stuck screen).
- **Expected app-private storage path**: This app performs stateless calculation;
  it is not expected to write any persistent file. No writes to
  `/ext/apps_data/` or elsewhere should occur.
- **Pass criteria**: App appears in Tools menu; launches; normal input produces a
  result screen; invalid input is handled without crash/freeze; Back navigation
  returns cleanly to the Tools menu; no unexpected storage writes.
- **Fail criteria**: App missing from menu; fails to launch; crashes or freezes on
  either input case; Back navigation does not return to the menu or exits
  unexpectedly; any storage write outside expectation; any global fail condition
  from the plan.
- **Notes field**: _____________________________________________

---

## 2. `programmer_calc` (Programmer Calculator)

- **Category / menu path**: Apps → Tools → "Programmer Calculator"
- **Launch path**: From the Tools submenu, select "Programmer Calculator" and
  press OK.
- **Expected screen on launch**: A calculator display (numeric entry area plus a
  base indicator — e.g. HEX/DEC/OCT/BIN — consistent with a programmer's
  calculator).
- **Minimum navigation test**: Cycle through the available number-base modes (if
  exposed via a button/menu) and back to the default, confirming the display
  updates and no mode gets the calculator into a stuck state.
- **One normal input test**: Enter a simple calculation in decimal (e.g. `2 + 2`)
  and confirm the display shows the correct result (`4`).
- **One invalid/edge input test**: Attempt a divide-by-zero (e.g. `5 / 0`) or an
  operation likely to be an edge case for this app (e.g. entering a value larger
  than the display can show), and confirm the app shows an error/overflow
  indicator or otherwise handles it gracefully, without crashing or freezing.
- **Exit behavior**: Press Back from the calculator screen; confirm clean return
  to the Tools menu.
- **Expected app-private storage path**: Not expected to persist state to a file
  under normal calculator use; no manifest-declared save file. No writes to
  `/ext/apps_data/` should occur.
- **Pass criteria**: App appears in Tools menu; launches; normal calculation
  produces the correct result; divide-by-zero/edge case is handled without
  crash/freeze; Back returns cleanly to the menu; no unexpected storage writes.
- **Fail criteria**: App missing from menu; fails to launch; incorrect result
  silently accepted as if correct (note: minor calculation-logic disputes are a
  functional-correctness matter, not a smoke-test blocker — only record a fail
  here if the app crashes/freezes/hangs, not for a suspected wrong digit, and note
  the discrepancy separately for follow-up); crash or freeze on either input case;
  Back does not return to the menu; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## 3. `vin_decoder` (VIN Decoder)

- **Category / menu path**: Apps → Tools → "VIN Decoder"
- **Launch path**: From the Tools submenu, select "VIN Decoder" and press OK.
- **Expected screen on launch**: A text-entry screen prompting for a 17-character
  Vehicle Identification Number.
- **Minimum navigation test**: Open the text entry keyboard, confirm cursor
  movement/character selection works, then back out without submitting, confirming
  Back returns to the app's own entry screen (not straight out of the app).
- **One normal input test**: Enter a well-formed, plausible 17-character VIN (any
  syntactically valid VIN is sufficient — this is a smoke test, not a VIN-database
  correctness check) and confirm a decoded-fields result screen is displayed.
- **One invalid/edge input test**: Enter a VIN that is too short (fewer than 17
  characters) or contains an invalid character for VIN encoding (e.g. `I`, `O`, or
  `Q`, which real VINs exclude), and confirm the app rejects it or shows a
  clear error rather than crashing or freezing.
- **Exit behavior**: Press Back from the result screen until returning to the
  Tools menu; confirm this happens cleanly.
- **Expected app-private storage path**: Not expected to persist entered VINs to a
  file. No writes to `/ext/apps_data/` should occur.
- **Pass criteria**: App appears in Tools menu; launches; valid VIN produces a
  result screen; invalid/short VIN is handled without crash/freeze; Back returns
  cleanly to the menu; no unexpected storage writes.
- **Fail criteria**: App missing from menu; fails to launch; crashes or freezes on
  either input case; Back does not return to the menu; any storage write outside
  expectation; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## 4. `flipper95` (Flipper95)

- **Category / menu path**: Apps → Tools → "Flipper95"
- **Launch path**: From the Tools submenu, select "Flipper95" and press OK.
- **Expected screen on launch**: A running display showing prime-number
  computation progress (this app is a CPU stress test — expect continuous visible
  activity, not a static screen).
- **Minimum navigation test**: Confirm the display updates continuously while
  running (progress/counter changing), indicating the app is live rather than
  hung on its very first frame.
- **One normal input test**: Let the app run for a short, bounded interval (e.g.
  30–60 seconds) and confirm it continues producing visible progress without
  hanging.
- **One invalid/edge input test**: Attempt to interrupt/pause the computation
  mid-run via whatever control the app exposes (if any), and confirm the app
  responds to the button press within a reasonable time rather than becoming
  unresponsive. If the app exposes no pause control, treat "Back exits promptly
  from mid-computation" as the edge case instead.
- **Exit behavior**: Press Back while the app is mid-computation; confirm it exits
  promptly back to the Tools menu rather than hanging or requiring a forced reset.
  This is the single most important check for this app, since it is
  explicitly a CPU-load stress test — the failure mode of interest is Back not
  being responsive under load, not a wrong prime.
- **Expected app-private storage path**: Not expected to persist any file. No
  writes to `/ext/apps_data/` should occur.
- **Pass criteria**: App appears in Tools menu; launches; shows continuing visible
  progress under load; responds to Back promptly even mid-computation; no
  crash/freeze/reboot; no unexpected storage writes.
- **Fail criteria**: App missing from menu; fails to launch; freezes (progress
  stops updating and no button, including Back, is acknowledged); does not
  respond to Back within a reasonable time; device becomes unresponsive; any
  global fail condition from the plan (this app, being CPU-intensive, is the one
  most worth watching for genuine freeze vs. "still computing" — give Back a fair
  chance, e.g. a few seconds, before concluding freeze).
- **Notes field**: _____________________________________________

---

## 5. `chess` (Chess)

- **Category / menu path**: Apps → Games → "Chess"
- **Launch path**: From the Games submenu, select "Chess" and press OK.
- **Expected screen on launch**: The app's start screen (title/start screen with
  navigable options — note the SAM voice easter-egg has been removed entirely per
  `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`, so no audio/voice output is expected at
  any point in this app).
- **Minimum navigation test**: From the start screen, navigate into the main menu
  and then into a new game screen, confirming board/UI renders and D-pad movement
  moves a cursor/selection on the board.
- **One normal input test**: Make one legal opening move (select a piece, move it
  to a legal square, confirm) and confirm the board updates to reflect the move.
- **One invalid/edge input test**: Attempt an illegal move (e.g. moving a piece to
  a square it cannot legally reach) and confirm the app rejects it (move does not
  apply, and/or an on-screen indication of an invalid move) without crashing or
  freezing.
- **Save/load behavior (specific to this app)**: If the app exposes a save/exit or
  auto-save mechanism, exit the game and confirm the app either resumes the saved
  position on next launch or otherwise behaves consistently with its own intended
  save behavior — the check here is only "does save/load run without error or
  corruption," not that the save format is documented. Confirm any save file is
  written under this app's own private path, `/ext/apps_data/flipchess/`, and
  nowhere else on the SD card.
- **Exit behavior**: Press Back from the game screen (and, separately, from the
  start screen) until returning to the Games menu; confirm this happens cleanly.
- **Expected app-private storage path**: `/ext/apps_data/flipchess/` only (per
  `flipchess_file.c`'s own `FLIPCHESS_APP_BASE_FOLDER` definition). Any write
  outside this path is a fail condition per the plan.
- **Pass criteria**: App appears in Games menu; launches; board renders; legal
  move applies; illegal move is rejected without crash/freeze; save/load (if
  exercised) completes without error and only touches
  `/ext/apps_data/flipchess/`; Back returns cleanly to the Games menu; no audio
  output occurs (confirming the SAM removal held on real hardware, not just in
  source).
- **Fail criteria**: App missing from Games menu; fails to launch; crashes or
  freezes on either move case; save/load produces an error, corrupts data, or
  writes outside `/ext/apps_data/flipchess/`; Back does not return to the menu;
  any unexpected audio output; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## 6. `flipfetch` (Flipfetch)

- **Category / menu path**: Apps → Tools → "Flipfetch"
- **Launch path**: From the Tools submenu, select "Flipfetch" and press OK.
- **Expected screen on launch**: A "fastfetch"-style system-info display
  showing firmware version, build date, battery percent/voltage/charging
  state, free RAM, free SD space, and uptime (per the app's own source,
  read in `docs/PHASE2B_2_SAFETY_REVIEW.md`), refreshing periodically
  (source defines a 2-second refresh interval).
- **Minimum navigation test**: Confirm the display updates on its own
  (e.g. uptime counter increasing) without requiring any button press,
  indicating the periodic refresh is working rather than the screen being
  a static freeze-frame.
- **One normal input test**: Let the app run for at least one refresh
  interval (a few seconds) and confirm the displayed uptime value
  increases between refreshes.
- **One invalid/edge input test**: There is no user text/numeric input in
  this app (it is a pure display screen) — as the edge case instead,
  press an arbitrary D-pad direction the app does not define a handler
  for, and confirm it is silently ignored rather than crashing.
- **Exit behavior**: Press Back from the info screen; confirm clean,
  immediate return to the Tools menu.
- **Expected app-private storage path**: This app only reads free-space
  info via a read-only storage query — it is not expected to write any
  persistent file. No writes to `/ext/apps_data/` or elsewhere should
  occur.
- **Pass criteria**: App appears in Tools menu; launches; info fields
  display and the uptime value visibly increases over time; unhandled
  input is ignored without crash; Back returns cleanly to the menu; no
  storage writes of any kind.
- **Fail criteria**: App missing from menu; fails to launch; display never
  updates (frozen at first frame); crash/freeze on any input; Back does
  not return to the menu; any storage write; any global fail condition
  from the plan.
- **Notes field**: _____________________________________________

---

## 7. `quadratic_solver` (Quadratic Solver)

- **Category / menu path**: Apps → Tools → "Quadratic Solver"
- **Launch path**: From the Tools submenu, select "Quadratic Solver" and
  press OK.
- **Expected screen on launch**: A screen presenting three adjustable
  values (`a`, `b`, `c` — the coefficients of `ax² + bx + c = 0`, per the
  app's own README) with one selected/highlighted at a time, plus an
  "About" entry.
- **Minimum navigation test**: Use Left/Right to change the selected
  coefficient's value, and confirm the on-screen number updates
  accordingly; navigate to the "About" entry and press Right to view
  additional information, then back out.
- **One normal input test**: Set `a=1`, `b=-3`, `c=2` (a simple quadratic
  with real roots `x=1` and `x=2`), press OK, and confirm a result screen
  displays two real roots.
- **One invalid/edge input test**: Set `a=0` (degenerate — not actually a
  quadratic equation) or values producing no real roots (e.g. `a=1, b=0,
  c=1`), press OK, and confirm the app handles this gracefully (an
  on-screen indication of no real roots, or an equivalent graceful
  response) rather than crashing or freezing.
- **Exit behavior**: Press Back from the result screen (and separately
  from the initial input screen) until returning to the Tools menu;
  confirm this happens cleanly.
- **Expected app-private storage path**: This app performs stateless
  computation only (confirmed in `docs/PHASE2B_2_SAFETY_REVIEW.md`: no
  `storage/storage.h` include at all) — it is not expected to write any
  persistent file. No writes to `/ext/apps_data/` or elsewhere should
  occur.
- **Pass criteria**: App appears in Tools menu; launches; coefficient
  adjustment works; normal input produces the correct real-root result;
  degenerate/no-real-root input is handled without crash/freeze; Back
  returns cleanly to the menu; no storage writes of any kind.
- **Fail criteria**: App missing from menu; fails to launch; crashes or
  freezes on either input case; Back does not return to the menu; any
  storage write; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## 8. `sudoku` (Sudoku)

- **Category / menu path**: Apps → Games → "Sudoku"
- **Launch path**: From the Games submenu, select "Sudoku" and press OK.
- **Expected screen on launch**: A menu screen (per the app's own
  `README.md`/`README_catalog.md`), leading into a rendered Sudoku board
  with a movable cursor.
- **Minimum navigation test**: Use the D-pad to move the cursor across
  several cells on the board, confirming the highlighted/selected cell
  changes accordingly and the cursor does not move off the board or get
  stuck.
- **One normal input test**: Move the cursor to an empty cell and press OK
  to increment a number into it (per the app's documented controls:
  "ok - increment number"), and confirm the board reflects the entered
  value.
- **One invalid/edge input test**: Press Back once on a filled cell (per
  the documented controls: "back - clear number") and confirm the value
  is cleared without crashing; separately, press and hold Back ("long
  back - pause game," per the same documentation) and confirm the app
  pauses rather than exiting unexpectedly or freezing.
- **Save/load behavior (specific to this app)**: Confirmed in source
  (`docs/PHASE2B_2_SAFETY_REVIEW.md`) to save/load game state via
  `storage_file_open`/`storage_file_read`/`storage_file_write` against
  `APP_DATA_PATH("save.dat")`. Exit the game (or let it save per its own
  logic) and confirm the app resumes the saved position on next launch
  without error or corruption, and that the save file is written only
  under `/ext/apps_data/sudoku/` and nowhere else on the SD card — this
  private-path expectation is source-derived (not yet hardware-confirmed;
  see `tools/phase2b_hardware_gate_config.json`'s note), so confirming it
  on real hardware here is specifically valuable, not redundant.
- **Exit behavior**: From the paused state (or directly from the board),
  exit back to the Games menu; confirm this happens cleanly.
- **Expected app-private storage path**: `/ext/apps_data/sudoku/` only.
  Any write outside this path is a fail condition per the plan, and
  specifically the first real confirmation of this app's storage
  location on real hardware.
- **Pass criteria**: App appears in Games menu; launches; board renders;
  cursor movement works; number entry and clearing work; pause works;
  save/load completes without error and only touches
  `/ext/apps_data/sudoku/`; exit returns cleanly to the Games menu.
- **Fail criteria**: App missing from Games menu; fails to launch; crashes
  or freezes on any input case; save/load produces an error, corrupts
  data, or writes outside `/ext/apps_data/sudoku/`; exit does not return
  to the menu; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## After completing all 8 apps

- Confirm no global fail condition occurred at any point across all 8
  apps.
- Transfer every result (including partial/failed cases) into a copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
- Do not mark the batch as an overall PASS unless every app individually
  passed and no global fail condition occurred — see
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md`'s "Pass criteria for the
  batch overall" (batch-agnostic, applies unchanged here).

**This checklist has not been executed as of this document.** Completing
it is the next step the user performs on real hardware, not something
recorded here.
