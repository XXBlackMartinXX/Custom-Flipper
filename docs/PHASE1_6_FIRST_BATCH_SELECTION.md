# Phase 1.6 — First Integration Batch Selection

Docs only. This selects the first 5 apps to actually attempt building against the
Unleashed base, **when that step is separately approved** — nothing has been
imported, merged, or built yet. This is a selection, not an action.

## Selection logic

Per instruction, only `APPROVE`/`APPROVE WITH NOTES` apps from
`PHASE1_6_TOP25_SOURCE_AUDIT.md` were eligible, and the goal was the **most
conservative possible slice** of the 21 clean approvals — not just "5 good apps,"
but specifically the 5 with the least storage/hardware footprint of all 21, to
validate the import pipeline itself before anything more complex. That ruled out:

- `upython` (deferred — real GPIO + IR transmit) and `iconedit` (approve-with-notes
  — real HID keystroke injection) per the audit findings above.
- `animation_switcher` and `theme_manager` (approve-with-notes — both write to the
  shared `/ext/dolphin/` system directory rather than app-private storage). Not
  rejected, just not first-batch material when 21 fully clean, storage-private-or-
  storage-free options exist instead.

That leaves 19 unqualified-clean apps. From those, the 5 below were picked for
**category spread with zero or app-private-only storage footprint** — 4 of the 5
have *zero* storage API usage at all (confirmed in the source audit), and the 5th
(`chess`) has only a private save-file.

## The 5 selected

### 1. `flipper95`

- **Source path**: `applications/external/flipper95/`
- **Why selected**: Zero storage, zero hardware API usage of any kind — the
  simplest possible import (1 file). It's also functionally a build/runtime sanity
  check (prime-number CPU stress test), which makes it a good first thing to get
  running: if `flipper95` runs correctly post-build, that's a real signal the build
  itself is healthy, independent of the app's own value.
- **Expected files to import**: `flipper95.c` (1 file)
- **Expected manifest changes**: Add one `App()` entry to the relevant
  `applications/external`-equivalent registration point in our tree (exact
  mechanism depends on Phase 2/3 architecture decisions not yet made — see
  `PHASE1_RECOMMENDED_INTEGRATION_PLAN.md`); copy `application.fam` as-is
- **Expected assets**: None (no icon/asset files beyond the standard app icon, if any)
- **Expected dependency changes**: None
- **Expected build risk**: Very low — single file, no HAL calls, pure C
- **Expected test command**: `.\fbt.cmd COMPACT=1 DEBUG=0` (build only, per current
  safety scope); manual confirmation would require actually launching the app on
  hardware, which is out of scope until real hardware testing is separately approved
- **Rollback plan**: Remove the single added file + its manifest entry, rebuild to
  confirm the tree returns to the current confirmed-clean baseline

### 2. `network_subnet`

- **Source path**: `applications/external/network_subnet/`
- **Why selected**: Zero storage, zero hardware API usage; multi-file
  (scenes/views/core split) so it tests the more common FAP structure most future
  imports will actually look like, rather than only testing single-file apps
- **Expected files to import**: 16 files (`network_subnet.c/.h`, `views/`,
  `scenes/`, `core/subnet_math.c/.h`)
- **Expected manifest changes**: One `App()` entry, as above
- **Expected assets**: None (its `images/` folder is empty — just a `.gitkeep`)
- **Expected dependency changes**: None
- **Expected build risk**: Low — pure math/string logic, standard scene-manager
  pattern already used throughout Official/Unleashed's own apps
- **Expected test command**: Build-only, as above
- **Rollback plan**: Remove the 16 files + manifest entry, rebuild to confirm clean baseline

### 3. `programmer_calc`

- **Source path**: `applications/external/programmer_calc/`
- **Why selected**: Zero storage, zero hardware API usage; a genuinely useful
  developer utility, moderate file count (14 files) without any scene/view split —
  tests a different internal structure than `network_subnet`
- **Expected files to import**: 14 files
- **Expected manifest changes**: One `App()` entry
- **Expected assets**: None beyond standard icon
- **Expected dependency changes**: None
- **Expected build risk**: Low
- **Expected test command**: Build-only, as above
- **Rollback plan**: Remove the 14 files + manifest entry, rebuild to confirm clean baseline

### 4. `vin_decoder`

- **Source path**: `applications/external/vin_decoder/`
- **Why selected**: Zero storage, zero hardware API usage, single file — despite the
  automotive subject matter, confirmed by source read to be a pure decode/lookup
  tool with no vehicle interaction, GPIO, or CAN-bus capability whatsoever. Included
  partly to demonstrate that "sounds vehicle-related" isn't itself disqualifying
  when the actual source shows no hardware interaction at all.
- **Expected files to import**: `vin_decoder.c` (1 file)
- **Expected manifest changes**: One `App()` entry
- **Expected assets**: None
- **Expected dependency changes**: None
- **Expected build risk**: Very low
- **Expected test command**: Build-only, as above
- **Rollback plan**: Remove the single file + manifest entry, rebuild to confirm clean baseline

### 5. `chess`

- **Source path**: `applications/external/chess/`
- **Why selected**: The only app-private-storage (not zero-storage) pick in this
  batch, included deliberately to test that pattern too, plus it's the most
  structurally complex of the 5 (helpers/views/scenes split, plus two small bundled
  third-party libraries — a chess engine and a software speech synthesizer) without
  any hardware API usage at all. A good "does our import pipeline handle a
  realistically-sized multi-directory app with vendored sub-libraries" test before
  attempting something like `upython` later.
- **Expected files to import**: 17 files across `helpers/`, `views/`, `scenes/`,
  `sam/` (SAM speech synth), and `chess/` (smallchesslib) — plus whatever icon/font
  assets ship with it
- **Expected manifest changes**: One `App()` entry; note its `application.fam` will
  need a license/attribution check for the two bundled libraries
  (`smallchesslib`, `stm32_sam`) before import, per `CREDITS.md`/
  `THIRD_PARTY_NOTICES.md` discipline — not just the top-level app's own license
- **Expected assets**: Custom fonts (`helpers/flipchess_fonts.c`), if any bitmap/icon
  assets ship alongside — confirm exact list at actual import time
- **Expected dependency changes**: None beyond the two vendored libs already bundled
  in the app's own directory (no external `requires=[...]`)
- **Expected build risk**: Low-Medium — more files and two vendored libraries mean
  more surface area for a build error than the other 4, but nothing in the audit
  suggests it's actually risky, just larger
- **Expected test command**: Build-only, as above
- **Rollback plan**: Remove all 17+ files + manifest entry + any added third-party
  license entries, rebuild to confirm clean baseline

## What happens if any of these 5 fails to build

Per the existing integration-plan discipline (one app per commit, rebuild after
each): if any of the 5 fails, that one gets its own diagnosis and doesn't block or
get bundled with the others. None of these 5 depend on each other.

## Stop point

This is a selection only. Actually importing and building any of these 5 requires
separate approval to move from "documentation" into "code integration" — which
hasn't been given yet.
