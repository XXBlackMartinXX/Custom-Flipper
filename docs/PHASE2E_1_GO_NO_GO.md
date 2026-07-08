# Phase 2E.1 — Go / No-Go

Docs only. Pre-import verification only. This is the closing decision
document for Phase 2E.1 — it recommends a path, it does not take it.

## Final Phase 2E.1 classification: **PHASE 2E.1 PRE-IMPORT VERIFICATION PASS**

All 3 apps in the Phase 2E recommended tiny batch (`image_viewer`,
`boilerplate`, `minesweeper`) are **cleared for import**. This is a clean
pass, not a NEEDS REVIEW or partial one — no app in this batch carries an
unresolved license gap that blocks import, an undisclosed hardware
capability, a credential/secret-handling concern, or copied commercial
content without rights that cannot be excluded from scope. Two of the
three apps carry a named condition/note (detailed below and in
`docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`) — one of them
(`image_viewer`'s bundled-bitmap exclusion) is a real, substantive
finding, not a routine formality, and is treated with the weight it
deserves.

## Apps cleared for implementation

1. **`image_viewer`** (Media) — MIT license confirmed directly in the
   vendored source (full, unmodified text, Ivan Polushin/polioan, 2024).
   Zero safety/API-capability hits. Confirmed read-only storage behavior
   by a full, direct read of its only source file. **Import-scope
   condition (required)**: exclude the entire `example_images/` directory
   and remove `fap_file_assets = "example_images"` from `application.fam`
   — this session decoded and visually inspected all 3 bundled `.bm`
   files and found that `spongebob.bm` clearly depicts a recognizable
   trademarked/copyrighted cartoon character (SpongeBob SquarePants) with
   no license or attribution anywhere in the app for that specific image;
   `dolphin.bm`/`cat.bm` are excluded alongside it on the same
   unconfirmed-provenance basis. None of the 3 are required for the app
   to build or function.
2. **`boilerplate`** (Tools/Educational) — real appid discrepancy found:
   the manifest declares `fap_boilerplate`, not `boilerplate`. No formal
   `LICENSE` file exists, but `README.md` contains a real, explicit,
   unambiguous permissive statement from the author ("open-source and may
   be used for whatever you want to do with it") — treated as sufficient
   evidence to clear the app, recorded honestly as a distinct, weaker
   evidence tier than a formal MIT license text, not silently upgraded.
   Zero safety/API-capability hits. Storage confirmed app-private
   (`/ext/apps_data/boilerplate/boilerplate.conf`, exact path). Confirmed
   real, working dev-tool value (a complete, functional demonstration
   app), not filler. **Attribution condition**: preserve `README.md`'s
   "## Licensing" section verbatim in this project's own attribution
   record at import time, since there is no separate `LICENSE` file to
   cite.
3. **`minesweeper`** (Games) — real appid discrepancy found: the manifest
   declares `minesweeper_redux`, not `minesweeper` (and the app is
   actively published on the official Flipper Lab app catalog). MIT
   license confirmed directly in the vendored source (full, unmodified
   text, Alexander Rodriguez/squee72564, 2024). Zero safety/API-capability
   hits, including zero mentions of any hardware-peripheral term at all.
   Storage confirmed app-private via a careful atomic write-then-rename
   pattern (`/ext/apps_data/mine_sweeper_redux/`, exact path). Its one
   third-party header dependency (M\*LIB's `m-deque.h`) is already
   satisfied by this project's existing `lib/mlib` submodule — not a new
   bundled dependency. No import-scope condition beyond routine MIT
   attribution.

## Apps deferred and why

**None.** No app in this batch is deferred or blocked. `image_viewer`'s
bundled-bitmap finding is resolved via exclusion, not deferral — the
concerning content is separable from the app's own clean, MIT-licensed
wrapper code and is not itself part of what would be imported.

## Whether the original 3-app batch remains valid

**Yes — the full 3-app batch remains valid, unchanged.** All 3 apps
recommended in `docs/PHASE2E_RECOMMENDED_BATCH.md` are cleared by this
verification pass, each with the exact import-scope condition/note
recorded above and in the readiness matrix. No batch-size reduction is
required, and no substitution question arises.

## Exact next allowed gate

- **For all 3 apps (`image_viewer`, `boilerplate`, `minesweeper`)**: the
  next gate is **Phase 2E.2 — implementation/import of this exact 3-app
  cleared batch**, in the import order `docs/PHASE2E_INTEGRATION_PLAN.md`
  already established (`image_viewer` → `boilerplate` → `minesweeper`),
  following that plan's one-app-at-a-time, commit-per-app,
  validate-after-each discipline — and only on the project owner's own
  separate, explicit request to begin. Each app's condition (see above
  and `docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`) must be honored at
  that time: `image_viewer` excludes `example_images/` entirely and its
  `application.fam` line; `boilerplate` preserves its README licensing
  statement verbatim in the attribution record; `minesweeper` may exclude
  `img/` for cleanliness.
- **This document does not itself start Phase 2E.2.** As with every
  prior phase transition in this project, an explicit further request is
  required.

## Prompt canaries applied in this phase

- "If any app license cannot be proven, mark that app DEFER." — **Not
  triggered.** `image_viewer` and `minesweeper` had real, readable
  `LICENSE` files; `boilerplate` had a real, explicit, if informal,
  author statement in its `README.md` — none was silently assumed.
- "If bundled data/assets/text lack clear redistribution rights, mark
  that app NEEDS REVIEW or DEFER." — **Triggered and resolved for
  `image_viewer`** specifically: rather than deferring the whole app or
  guessing the bundled `.bm` files are fine, this phase positively
  identified the highest-risk file (`spongebob.bm`) and excluded all 3
  bundled bitmaps from the import scope entirely, resolving the concern
  by removing it from scope rather than by guessing an answer.
- "If image_viewer's bundled bitmaps have unclear provenance and cannot
  be safely excluded from import scope, mark DEFER." — **Not
  triggered as a DEFER**, because the bitmaps *can* be safely excluded
  (confirmed directly: the app's runtime does not reference any specific
  bundled filename) — the exclusion condition is the correct resolution
  path this canary itself anticipates.
- "If any app includes copied commercial text/code/data/assets without
  distribution rights, mark BLOCKED." — **Considered for
  `spongebob.bm`** specifically (a recognizable commercial cartoon
  character with no distribution rights evidence). Not applied as a
  BLOCKED to the whole app, because that specific file is excluded from
  the import scope entirely, the same resolution strategy Phase 2D.1
  used for `resistors`'s ambiguous reference photos and Phase 2C.1 used
  for `fcc_id_lookup`'s database (though `fcc_id_lookup` itself remained
  deferred for a separate, app-wide reason).
- "If any app handles user secrets, keys, wallets, seed phrases, tokens,
  passwords, or credentials, mark DEFER." — **Not triggered.** Zero
  matches across all 3 apps' real source.
- "If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR
  behavior, mark DEFER unless clearly harmless and explicitly approved."
  — **Not triggered.** All 3 confirmed clean against the full 22-keyword
  safety scan of real source; `minesweeper`'s scan additionally found
  zero mentions of any hardware-peripheral term at all.
- "If any app needs source changes outside its own app directory, mark
  NEEDS REVIEW." — **Not triggered.** All 3 apps are fully self-contained;
  `minesweeper`'s one third-party header dependency is already satisfied
  by an existing base-firmware submodule with no change needed.
- "If evidence is missing, write NEEDS REVIEW instead of guessing." —
  Applied in spirit to `boilerplate`'s license: rather than guessing its
  informal README statement is legally equivalent to a formal MIT
  license, this document records it as a distinct, real-but-weaker
  evidence tier, honestly, without either blocking the app or
  overstating the evidence.
- "If the workflow tries to import code in this phase, stop immediately."
  — No import was attempted; this phase is verification only.
- "Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free." — Not claimed anywhere in this phase's output.

## Statement

**PHASE 2E.1 PRE-IMPORT VERIFICATION PASS. ALL 3 APPS CLEARED (ONE WITH A
SUBSTANTIVE IMPORT-SCOPE CONDITION, ONE WITH A LICENSE-EVIDENCE NOTE). NO
CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was modified. No build was attempted. No hardware
was touched, no hardware-connected validation mode was run. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup` remains
deferred, unresolved, and untouched — not reopened or re-reviewed in this
phase.
