# Phase 2A — `chess` SAM Text-to-Speech License Review

Docs only. No code changed by this review. Investigates the license status of
`applications_user/chess/sam/stm32_sam.{h,cpp}` and its wrapper
`applications_user/chess/helpers/flipchess_voice.{cpp,h}`, flagged as "unverified"
in the Phase 2A safety review and integration log.

## What was inspected

- `applications_user/chess/sam/stm32_sam.h` and `.cpp` (the ported engine itself)
- `applications_user/chess/helpers/flipchess_voice.cpp` and `.h` (the thin wrapper
  that calls it — four `voice.say(...)` calls with WarGames-movie-quote strings:
  "SHAAL WE PLAY AY GAME?", "WHICH SIDE DO YOU WANT?", "HOW ABOUT A NICE GAME OF
  CHESS?", "A STRANGE GAME... THE ONLY WINNING MOVE IS NOT TO PLAY.")
- `applications_user/chess/README.md`, `LICENSE`, and every other file in the app
  (confirmed identical, file-for-file, to the RogueMaster source via `diff -rq`) —
  no separate license/notice file for the SAM component exists anywhere in the
  vendored copy
- The immediate upstream app repository, `xtruan/flipper-chess` (fetched live)
- The original project the code is ported from, `s-macke/SAM`, cited directly in
  `stm32_sam.h`'s own header comment: `"SAM Text-To-Speech (TTS), ported from
  https://github.com/s-macke/SAM"` (fetched live, both the repo page and its raw
  `README.md`)

## Findings

1. **No license file or license header exists anywhere in the vendored SAM code**
   in this app. `stm32_sam.h`'s only provenance information is the one-line comment
   above; `stm32_sam.cpp` has no header at all beyond a large ASCII-art comment
   banner.
2. **`xtruan/flipper-chess`'s own README does not mention the SAM component at
   all** — it explicitly credits `smallchesslib` (linking to its Codeberg page) but
   says nothing about SAM's origin or license. The app's own MIT `LICENSE` covers
   Struan Clark's original code; it does not — and legally cannot — retroactively
   grant a license for someone else's unlicensed code merely by being present in
   the same repository.
3. **The original `s-macke/SAM` project has no open-source license and says so
   explicitly.** Quoting its README's "License" section verbatim (fetched live):

   > "The software is a reverse-engineered version of a software published more
   > than 34 years ago by 'Don't ask Software'. The company no longer exists. Any
   > attempt to contact the original authors failed. Hence S.A.M. can be best
   > described as Abandonware (http://en.wikipedia.org/wiki/Abandonware). As long
   > this is the case I cannot put my code under any specific open source software
   > license. However the software might be used under the 'Fair Use' act
   > (https://en.wikipedia.org/wiki/FAIR_USE_Act) in the USA."

   In plain terms: this is a reverse-engineered port of 1980s-era Commodore 64
   commercial software from a defunct company, no rights holder has ever granted
   permission to redistribute it, and the repo's own author only offers a
   speculative "might qualify as Fair Use" argument — not a license grant of any
   kind. Fair Use is a US legal defense evaluated case-by-case for specific uses
   (commentary, research, parody, etc.); it is not a blanket permission to
   redistribute in a downstream product, and its applicability here has not been
   established by anyone with the standing to do so.
4. No intermediate, differently-licensed Arduino/STM32 port of SAM could be
   identified as the actual source of this specific STM32-targeted adaptation
   (GitHub code search requires authentication this session couldn't provide) —
   the header's own citation of `s-macke/SAM` as the source is taken at face value,
   since it's the only provenance claim that exists.

## What this does *not* affect

- Every other part of `chess` is clean: Struan Clark's own game/UI code is MIT
  licensed (his own `LICENSE` file); `smallchesslib` is CC0/public domain per its
  own file header (verified in the Phase 2A integration log). Only the SAM voice
  component is in question.
- This does not affect whether `chess` **compiles** — the project owner's real
  local Windows build passed with this code present (see
  `PHASE2A_BUILD_REPORT.md`). Compiling unlicensed code is not itself a build
  problem; distributing it is a legal/compliance problem, which is what this
  review is about.

## Decision

**SAM LICENSE UNCLEAR / REMOVE SAM VOICE FEATURE ENTIRELY** (final — implemented
and build-confirmed, see "Implementation" and "Build status" below)

Rationale: the rest of `chess` (game logic, UI, `smallchesslib`) is cleanly
licensed and has clear ongoing value; only the SAM-based voice easter-egg is in
question, and it is small and cleanly separable (two files plus a four-function
wrapper, none of which the core game depends on functionally — it's flavor text on
scene transitions, not gameplay). Removing the whole app over one separable,
non-essential feature would be disproportionate; shipping it as-is would mean
distributing abandonware with no redistribution rights and only a speculative
fair-use argument backing it, which doesn't meet this project's stated bar for
license compliance. Disabling the feature (and not linking the SAM engine into the
build at all) removes the actual legal exposure while keeping everything else about
the app.

**Implemented** in commit `6359f87` on `integration/phase2a-first-batch` (option 1
of the two originally offered: full removal from the repository, not just from the
build). Specifically:

- Deleted `applications_user/chess/sam/stm32_sam.{h,cpp}` (the ported engine) and
  `applications_user/chess/helpers/flipchess_voice.{cpp,h}` (the wrapper) — these
  files no longer exist anywhere in the tree, not just excluded from compilation.
- Removed every `#include ".../flipchess_voice.h"` and all four
  `flipchess_voice_*()` call sites (in `views/flipchess_scene_1.c` ×3,
  `scenes/flipchess_scene_startscreen.c`, `scenes/flipchess_scene_settings.c`).
- Removed the `uint8_t sound;` field from the `FlipChess` struct
  (`flipchess.h`) and its initialization (`flipchess.c`) — it existed solely to
  gate the now-removed voice calls.
- The start screen previously let the Left/Right buttons set `app->sound` *and*
  `app->haptic` together (labeled "Sound"/"Silent" on screen). Per instruction not
  to invent new audio behavior and to rely only on the existing, independent,
  already-present haptic feature: relabeled the two buttons to "Haptic"/"No Haptic"
  and simplified the key handlers to set only `app->haptic` — no new feature added,
  chess is otherwise silent as instructed.

**Unclear-license code is no longer distributed in this branch.** Verified by a
full grep sweep (`sam`, `stm32_sam`, `flipchess_voice`, `speech`, `voice` — all with
word boundaries) across every `.c`/`.h`/`.cpp`/`.fam` file in `applications_user/chess/`:
zero matches. `chess`'s remaining content (Struan Clark's MIT-licensed game/UI code,
`smallchesslib`'s CC0-licensed engine) is unaffected and unchanged.

Build status: **PASS.** The project owner's real local Windows build against
commit `5e5e0ecf225be947a754e537670a6421838b939b` (the docs commit immediately on
top of this removal, same tree) completed successfully: both `.\fbt.cmd
COMPACT=1 DEBUG=0` and `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` passed,
`firmware.dfu` (862,825 bytes) and the updater `.tgz` (2,732,909 bytes) both
produced, `git status` clean before and after. Full detail in
`PHASE2A_BUILD_REPORT.md`. Hardware flashing/testing: **NOT PERFORMED** — this
confirms the code compiles, not that it has been run on a device.

**This closes the SAM license investigation for Phase 2A**: the unclear-license
code is removed from the repository, and the removal itself is now confirmed to
build cleanly, not just statically validated.
