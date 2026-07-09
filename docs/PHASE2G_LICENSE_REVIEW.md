# Phase 2G — License Review

Docs only. Planning only. No code is imported by this document.

## No new app license review advanced

Since `docs/PHASE2G_RECOMMENDED_BATCH.md` recommends **no import batch**,
there is no new candidate app to review a license for in this phase. No
new upstream source or `LICENSE` file was fetched or read.

## Existing license concerns preserved, not resolved

### `fcc_id_lookup` — remains deferred

The RogueMaster-vendored copy of `applications/external/fcc_id_lookup/`
(at commit `472f6925e8aca9bd031cb37e3cb80b551772c957`, per
`docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`) has no `LICENSE` file,
no SPDX identifier, and no copyright header anywhere in its source.
Strong corroborating evidence — a confirmed MIT license, Copyright (c)
2026 lsr, at the true upstream repository this app's own `fap_weburl`
names (`github.com/lrehmann/fcc-id-lookup-flipper`) — exists but is not
commit-pinned to the specific historical revision RogueMaster vendored.
This gap is **not resolved, not weakened, and not reopened for
re-review** by this phase, per the task's explicit instruction. It
remains open in `docs/KNOWN_ISSUES.md` item 6 until a separate, narrow
license-resolution phase addresses it directly.

### `c_book` — remains blocked/deferred

`c_book` bundles verbatim `.txt` chapters of "The C Programming
Language" (Kernighan & Ritchie, Prentice Hall) — a commercially
published, copyrighted work. The app's own code was confirmed by
`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md` to be a clean, minimal e-book
reader with no unsafe API surface, but that says nothing about the
bundled *content*'s redistribution rights, which remain unconfirmed
(`docs/PHASE2B_LICENSE_REVIEW.md`). This concern is **not resolved and
not weakened** by this phase.

### `image_viewer/example_images/` — exclusion preserved

`applications_user/image_viewer/example_images/` (3 bundled `.bm` demo
images, including `spongebob.bm`, confirmed in Phase 2E.1 to depict a
recognizable trademarked/copyrighted cartoon character with no
attribution or redistribution-rights evidence) remains excluded from
this repository. This phase makes no source-tree changes of any kind and
does not touch this exclusion.

## Other 4 hard-deferred apps — no license concern, different risk class

`upython`, `iconedit`, `animation_switcher`, and `theme_manager` are
deferred for capability/storage reasons, not license reasons (see
`docs/PHASE2G_RISK_REGISTER.md`) — their licenses were not flagged as
unclear by the Top-25 source audit and are not revisited here.

## Statement

Direct source/license verification (a real, dedicated read of the
upstream `LICENSE` file against the exact vendored revision) remains
required before any import of `fcc_id_lookup`, and a confirmed
redistribution right remains required before any import of `c_book`,
regardless of anything in this document — this review does not itself
constitute that verification for either app, nor for any hypothetical
future candidate.
