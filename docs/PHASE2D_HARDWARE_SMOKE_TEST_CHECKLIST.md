# Phase 2D — Hardware Smoke Test Checklist

Docs only. This is the Phase 2D counterpart to
`docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` (which remains unmodified
and still valid on its own for the 10 apps it covers) — read
`docs/PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` first for scope, safety rules,
and global fail conditions before running any step below; that plan is
batch-agnostic and applies unchanged to this checklist. **No hardware
testing has been performed as part of writing this checklist.**

Record every result in a copy of
`docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md` as you go. If a global
fail condition occurs at any point, stop immediately and follow
`docs/PHASE2A_FLASHING_PRECHECK.md` §5 (rollback) instead of continuing
down this list.

**Phase 2D.4 cross-reference**: `tools/phase2d_hardware_gate.ps1 -Mode
HardwareAssisted` automates the non-GUI preconditions (branch/commit
check, artifact hash verification, device detection, qFlipper detection,
and the flash-confirmation gate) and lists every one of the 13 apps below
as `REQUIRES_HUMAN_OBSERVATION`, pointing back to this checklist — it does
not and cannot perform any of the steps in this document itself. See
`docs/PHASE2D_HARDWARE_ASSISTED_VALIDATION.md` for what that gate does and
does not validate.

Menu path prefix for all 13 apps: **Main Menu → Apps → \<category\>**
(category noted per app below), then the app's own name.

Sections 1–10 (`network_subnet`, `programmer_calc`, `vin_decoder`,
`flipper95`, `chess`, `flipfetch`, `quadratic_solver`, `sudoku`,
`sd_info`, `docviewlite`) are identical in content to
`docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` — reproduced here so this
document is a complete, standalone checklist for the full 13-app Phase 2D
baseline, not a fragment. Sections 11–13 are new, for the 3 Phase 2D
apps. `fcc_id_lookup` is **not** included — it is not part of the
accepted Phase 2D baseline (deferred pending a license-evidence
resolution).

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
  under `/ext/apps_data/sudoku/` and nowhere else on the SD card.
- **Exit behavior**: From the paused state (or directly from the board),
  exit back to the Games menu; confirm this happens cleanly.
- **Expected app-private storage path**: `/ext/apps_data/sudoku/` only.
  Any write outside this path is a fail condition per the plan.
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

## 9. `sd_info` (SD Info)

- **Category / menu path**: Apps → Tools → "SD Info"
- **Launch path**: From the Tools submenu, select "SD Info" and press OK.
- **Expected screen on launch**: An SD-card information display (capacity,
  free space, and related card metadata) — per the app's own README ("shows
  information about the SD card and you can also perform a test that will
  show the card status"), plus a distinct test page reachable from the info
  screen.
- **Minimum navigation test**: Confirm the info screen renders real card
  values (not blank/zero placeholders) with a card inserted, then navigate
  to the test page (per source: a dedicated page 2 reachable via the app's
  own paging, prompting "Press OK to start test").
- **One normal input test**: On the test page, press OK to start the SD
  speed test and let it run to completion; confirm a progress indicator
  updates and the app displays read/write speed results on completion,
  without crashing or freezing. **This is the one app in this batch whose
  "normal input" itself triggers real, controlled storage writes — expected
  and by design, not a defect (see the storage note below).**
- **One invalid/edge input test**: Interrupt the test mid-run by pressing
  Back before it completes, and confirm the app exits cleanly without
  hanging (do not assume the test's own cleanup ran — see the SD-card
  inspection step below).
- **SD-card inspection (specific to this app — required, not optional)**:
  After both the normal-completion run and the interrupted-mid-test run
  above, use a card reader (or the device's own file browser) to confirm
  **no `/ext/sdtest.tmp*` files remain on the SD card** in either case.
  Source confirms the app writes, reads back, and deletes 48 blocks of
  32KB test data at `/ext/sdtest.tmp_<n>` during a normal run
  (`storage_simply_remove()` called after each block's read-back check) —
  this step exists specifically to confirm that behavior holds on real
  hardware, including when the test is aborted mid-run, not just in
  source.
- **Exit behavior**: Press Back from the info/test screens until returning
  to the Tools menu; confirm this happens cleanly.
- **Expected app-private storage path**: **None — this app is NOT
  app-private.** Its SD speed test writes to `/ext/sdtest.tmp*` (SD-card
  root), only during an explicit, user-initiated test run, and only
  transiently (each block is deleted immediately after its own read-back
  check). This is a real, controlled exception to the "no unexpected
  storage writes" rule used elsewhere in this checklist — expected for
  this app specifically, not a violation, provided no `/ext/sdtest.tmp*`
  file survives after the test ends (whether by completion or interruption).
- **Pass criteria**: App appears in Tools menu; launches; info screen shows
  real card data; test runs to completion with a visible progress
  indicator and a results display; interrupting the test mid-run exits
  cleanly; **no `/ext/sdtest.tmp*` files remain on the SD card after either
  the completed or the interrupted run**; Back returns cleanly to the
  Tools menu.
- **Fail criteria**: App missing from menu; fails to launch; info screen
  shows implausible/blank data with a card present; test hangs or crashes
  (on completion or interruption); **any `/ext/sdtest.tmp*` file left
  behind on the SD card after the test ends**; Back does not return to the
  menu; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## 10. `docviewlite` (Doc Viewer Lite)

- **Category / menu path**: Apps → Tools → "Doc Viewer Lite"
- **Launch path**: From the Tools submenu, select "Doc Viewer Lite" and
  press OK.
- **Expected screen on launch**: A main menu offering "Browse Files" (per
  the app's own README) to open the file browser and select a `.txt` file.
- **Minimum navigation test**: Select "Browse Files," navigate the file
  browser to a `.txt` file on the SD card, and confirm selecting it opens
  the document viewer.
- **One normal input test**: With a document open, use Up/Down to scroll
  line-by-line and Left/Right to page up/down (per the app's documented
  controls), and confirm the visible text changes accordingly; also open
  the Settings menu and change the font size, confirming the display
  updates.
- **One invalid/edge input test**: Attempt to open a `.txt` file larger
  than the app's documented 8KB/100-line limit (or, if none is available,
  a file at or near the SD card's largest available `.txt` file), and
  confirm the app either truncates gracefully, shows a clear limitation
  message, or otherwise handles the oversized file without crashing or
  freezing.
- **Exit behavior**: Press Back from the document view to return to the
  main menu, and again from the main menu to return to the Tools menu;
  confirm both happen cleanly.
- **SD-card inspection (specific to this app)**: After using the app
  (browsing, opening, and reading a document, and changing settings),
  confirm **no new file and no modification to the opened document**
  appears anywhere on the SD card — source confirms this app only calls
  `storage_file_open(..., FSAM_READ, ...)`/`storage_file_read()`, with no
  write call anywhere in its 984-line source. This step exists to confirm
  that holds on real hardware, not just in source.
- **Expected app-private storage path**: **None — confirmed read-only.**
  This app reads a user-selected file only; it is not expected to write
  any persistent file, app-private or otherwise. Any write of any kind is
  a fail condition, not merely an "unexpected path" one.
- **Pass criteria**: App appears in Tools menu; launches; file browser
  opens and a `.txt` file can be selected; scrolling/paging and font-size
  settings work; an oversized file is handled without crash/freeze; Back
  returns cleanly through both screens; **no file on the SD card is
  created or modified by using this app**.
- **Fail criteria**: App missing from menu; fails to launch; file browser
  fails to open or list files; crashes or freezes on either the normal or
  oversized-file case; Back does not return cleanly; **any new or modified
  file appears on the SD card after using this app**; any global fail
  condition from the plan.
- **Notes field**: _____________________________________________

---

## 11. `resistors` (Resistor Calculator)

- **Category / menu path**: Apps → Tools → "Resistor Calculator"
- **Launch path**: From the Tools submenu, select "Resistor Calculator" and
  press OK.
- **Expected screen on launch**: A resistor-band display (per the app's
  own README) allowing a choice of 3, 4, 5, or 6 band resistor, with
  coloured bands rendered on screen.
- **Minimum navigation test**: Use Left/Right to move the current focus
  between bands, confirming the highlighted/selected band changes
  accordingly.
- **One normal input test**: With a band focused, use Up/Down to cycle its
  colour, and confirm the resistance, tolerance, and temperature
  coefficient values displayed update instantly to reflect the new colour
  combination.
- **One invalid/edge input test**: Switch between the 3-band and 6-band
  modes (the app's documented minimum/maximum band counts) and confirm the
  display re-renders correctly for each without crashing or freezing,
  including at the extremes (e.g. cycling a colour all the way around back
  to its starting value).
- **Exit behavior**: Press Back from the main display; confirm clean,
  immediate return to the Tools menu.
- **SD-card inspection (specific to this app — required, not optional)**:
  After using the app (switching band counts and cycling colours), confirm
  **no file of any kind** appears anywhere on the SD card — source
  confirms zero `storage_`/`file_stream`/`RECORD_STORAGE`/`FSAM_`/`FSOM_`
  reference anywhere in this app's `src/`, and zero `furi_hal` usage of
  any kind (`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`,
  `docs/PHASE2D_2_SAFETY_REVIEW.md`). This step exists to confirm that
  holds on real hardware, not just in source.
- **Expected app-private storage path**: **None — confirmed zero-storage.**
  This app performs stateless calculation and rendering only; any storage
  write of any kind, anywhere on the SD card, is a fail condition.
- **Pass criteria**: App appears in Tools menu; launches; band-count
  switching and colour cycling both work and update the resistance/
  tolerance/temp-coefficient values instantly; edge cases (3-band, 6-band,
  colour wraparound) handled without crash/freeze; Back returns cleanly to
  the menu; **no file of any kind is created on the SD card by using this
  app**.
- **Fail criteria**: App missing from menu; fails to launch; crashes or
  freezes on any band-count/colour case; Back does not return to the menu;
  **any storage write of any kind**; any global fail condition from the
  plan.
- **Notes field**: _____________________________________________

---

## 12. `crypto_dictionary` (Crypto Dictionary)

- **Category / menu path**: Apps → Tools → "Crypto Dictionary"
- **Launch path**: From the Tools submenu, select "Crypto Dictionary" and
  press OK.
- **Expected screen on launch**: A menu/reference screen (per the app's
  own README, "a comprehensive reference tool that provides detailed info
  on various algorithms") offering a list of symmetric-cipher glossary
  entries (Blowfish, Camellia, CAST-128, CAST-256, DES, IDEA, RC2, RC4,
  RC5, RC6, Serpent, SM4, Twofish, Triple DES) plus "about" entries.
- **Minimum navigation test**: Scroll through the glossary list using
  Up/Down, confirming the selection/highlight moves through the available
  entries without getting stuck at either end.
- **One normal input test**: Select any one glossary entry (e.g. "DES")
  and press OK, and confirm its bundled reference text is displayed and
  scrollable.
- **One invalid/edge input test**: Navigate to the first and last entries
  in the list and confirm Up/Down at those boundaries either wraps
  gracefully or simply stops, without crashing or freezing; separately,
  open the "about" entry (if present) and confirm it displays without
  error.
- **Exit behavior**: Press Back from an open glossary entry to return to
  the list, and again from the list to return to the Tools menu; confirm
  both happen cleanly.
- **SD-card inspection (specific to this app — required, not optional)**:
  After browsing and opening several glossary entries, confirm **no new
  file and no modification to any bundled glossary file** appears anywhere
  on the SD card — source confirms this app opens its own bundled glossary
  `.txt` files via `FSAM_READ`/`FSOM_OPEN_EXISTING` only, with no write
  call anywhere in its source (`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`,
  `docs/PHASE2D_2_SAFETY_REVIEW.md`). This step exists to confirm that
  holds on real hardware, not just in source.
- **Expected app-private storage path**: **None — confirmed read-only.**
  This app reads its own bundled glossary files only; it is not expected
  to write any persistent file, app-private or otherwise. Any write of any
  kind is a fail condition, not merely an "unexpected path" one.
- **Pass criteria**: App appears in Tools menu; launches; glossary list
  scrolls and an entry opens and displays its reference text; boundary
  navigation and the "about" entry work without crash/freeze; Back returns
  cleanly through both screens; **no file on the SD card is created or
  modified by using this app**.
- **Fail criteria**: App missing from menu; fails to launch; glossary list
  fails to render or an entry fails to open; crashes or freezes on any
  navigation case; Back does not return cleanly; **any new or modified
  file appears on the SD card after using this app**; any global fail
  condition from the plan.
- **Notes field**: _____________________________________________

---

## 13. `2048` (2048)

- **Category / menu path**: Apps → Games → "2048"
- **Launch path**: From the Games submenu, select "2048" and press OK.
- **Expected screen on launch**: A 4x4 numbered-tile game board (per the
  app's own README/README-catalog), either freshly started or resuming a
  previously saved game.
- **Minimum navigation test**: Press each of Up/Down/Left/Right once and
  confirm all tiles on the board shift/merge together in the pressed
  direction, per the documented controls ("control the game using the Up,
  Down, Right, and Left buttons, which allow you to move all cells on the
  playing field simultaneously").
- **One normal input test**: Make a move that merges two identical tiles
  (e.g. two adjacent `2` tiles) and confirm they combine into a `4` tile
  and the score/board updates accordingly.
- **One invalid/edge input test**: Press a direction in which no tile can
  move or merge (e.g. against a full, non-mergeable edge) and confirm the
  app either ignores the move (no board change) or otherwise handles it
  gracefully, without crashing or freezing; if reachable within a
  reasonable play session, also confirm the documented "game ends when no
  further moves are possible" end state is handled cleanly.
- **Save/load behavior (specific to this app)**: Confirmed in source
  (`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`,
  `docs/PHASE2D_2_SAFETY_REVIEW.md`) to write to
  `/ext/apps_data/game_2048/game_2048.save` via a hardcoded
  `EXT_PATH("apps_data/game_2048")` literal, plus a one-time legacy-path
  migration check against `/ext/apps/Games/game_2048.save` on load (a
  silent no-op on this fresh import). Per the app's own README ("progress
  is saved on exit"), exit the game and confirm it resumes the saved board
  on next launch without error or corruption, and that the save file is
  written only under `/ext/apps_data/game_2048/` and nowhere else on the
  SD card (specifically, confirm no file is written to
  `/ext/apps/Games/game_2048.save` or any other shared/root-level
  location).
- **Exit behavior**: Press Back from the game board; confirm clean,
  immediate return to the Games menu (with the save behavior above
  triggered on exit, per the app's own documented design).
- **Expected app-private storage path**: `/ext/apps_data/game_2048/` only.
  Any write outside this path (including the legacy
  `/ext/apps/Games/game_2048.save` location) is a fail condition per the
  plan.
- **Pass criteria**: App appears in Games menu; launches; all four
  directions move/merge tiles correctly; merging produces the correct
  doubled value; the non-mergeable edge case and (if reached) the
  game-over state are handled without crash/freeze; save/load completes
  without error and only touches `/ext/apps_data/game_2048/`; Back returns
  cleanly to the Games menu.
- **Fail criteria**: App missing from Games menu; fails to launch; crashes
  or freezes on any move/merge case; save/load produces an error, corrupts
  data, or writes outside `/ext/apps_data/game_2048/`; Back does not
  return to the menu; any global fail condition from the plan.
- **Notes field**: _____________________________________________

---

## After completing all 13 apps

- Confirm no global fail condition occurred at any point across all 13
  apps.
- Confirm specifically that `sd_info` left no `/ext/sdtest.tmp*` files
  behind, that `docviewlite` created/modified no file at all, that
  `resistors` created no file at all, that `crypto_dictionary`
  created/modified no file at all, and that `2048` wrote only to
  `/ext/apps_data/game_2048/` — these are the five storage-behavior
  confirmations most worth double-checking in this batch.
- Transfer every result (including partial/failed cases) into a copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
- Do not mark the batch as an overall PASS unless every app individually
  passed and no global fail condition occurred — see
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md`'s "Pass criteria for the
  batch overall" (batch-agnostic, applies unchanged here).

**This checklist has not been executed as of this document.** Completing
it is the next step the user performs on real hardware, not something
recorded here.
