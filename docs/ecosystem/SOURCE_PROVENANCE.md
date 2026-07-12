# Source Provenance

Every repository below was actually cloned (`git clone --depth 1
--filter=blob:none`, or a documented fallback) and inspected in this
phase, by dedicated research agents each working against exactly one
repository. Commit hashes, branches, and license hashes below were
read directly from those clones, not inferred or assumed. Retrieval
date for all entries: **2026-07-12**.

## Repositories pinned

| Key | Repository URL | Branch | Commit | License file | License type | License SHA256 |
|---|---|---|---|---|---|---|
| `custom_flipper` (this project) | `https://github.com/XXBlackMartinXX/Custom-Flipper` | `integration/fcc-id-lookup-one-app-import` | `78aa28d4583fdfb47612c52aefd44e4773ad41f1` | `LICENSE` | GPL-3.0 | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |
| `official` | `https://github.com/flipperdevices/flipperzero-firmware` | `dev` | `7432d21a7e362d4a5f636e24d6209fbb2eedff1f` | `LICENSE` | GPL-3.0 | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |
| `unleashed` | `https://github.com/DarkFlippers/unleashed-firmware` | `dev` | `9bcabc0134a4503e341b804999dd73ec890466af` | `LICENSE` | GPL-3.0 | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |
| `unleashed_plugins` (companion apps repo) | `https://github.com/xMasterX/all-the-plugins` | `dev` | `117a38d633a3902d8a89c19cc778db3857a47cd5` | *(license varies per app — no single root LICENSE audited in this phase)* | varies | n/a |
| `momentum` | `https://github.com/Next-Flip/Momentum-Firmware` | `dev` | `8ed809fba8af7ac3f09b9495a597d8963f9178a8` | `LICENSE` | GPL-3.0 | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |
| `momentum_apps` (submodule, companion apps repo) | `https://github.com/Next-Flip/Momentum-Apps` | `dev` | `b05485f7d13ee1595d06745c881f1d3aadb3d45d` | *(license varies per app — no single root LICENSE audited in this phase)* | varies | n/a |
| `roguemaster` | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` | `420` | `9273d355269c6abc77e7b063fcd8ef412343b27b` | `LICENSE` | GPL-3.0 | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |

**Notable finding, confirmed independently across all four primary
firmware repositories and this project's own repository**: every one of
them ships the byte-identical root `LICENSE` file (GPL-3.0, SHA256
`3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`) —
they all share the same upstream GPL-3.0 licensing at the firmware-core
level. This is expected, since all four are forks/derivatives of the
same original Flipper Zero firmware lineage, and it simplifies this
phase's license-compatibility analysis considerably at the firmware-core
level (see `LICENSE_COMPATIBILITY_MATRIX.md`) — the real complexity is
in each *individual app's own* license, not the firmware shell.

## A structural finding common to all three forks

None of `unleashed-firmware`, `Momentum-Firmware`, or
`flipperzero-firmware-wPlugins` (RogueMaster) actually stores its bundled
community apps inside its own `applications_user/` directory — that
directory is an empty, gitignored placeholder in all three (confirmed by
direct inspection), intended for a *local user's own* development, not
for shipped community apps. The real community-app collections live in:

- Unleashed → a separate companion repository, `xMasterX/all-the-plugins`
  (referenced from Unleashed's own `.drone.yml` CI config and `ReadMe.md`).
- Momentum → a git submodule, `Next-Flip/Momentum-Apps`
  (`applications/external` in the main repo).
- RogueMaster → apps are vendored directly into this fork's own
  `applications/external/` (not a submodule/companion repo).

This distinction matters for source pinning: Unleashed's and Momentum's
*effective* app inventories are only as current as their pinned
companion-repo commit, not their main firmware repo's commit — both are
recorded above as separate pins for exactly this reason.

## Total real app counts per repository (verified, not estimated)

| Repository | Location of app inventory | Total app count | How counted |
|---|---|---|---|
| `official` | `applications/` (built-in only; `applications_user/` is an empty placeholder) | 82 | Directory count across `debug/`(27) `examples/`(14) `main/`(10) `services/`(16) `settings/`(10) `system/`(4) `drivers/`(1) |
| `unleashed_plugins` | `apps_source_code/`, `base_pack/`, `non_catalog_apps/` | 317 | 64 + 74 + 179, confirmed no name overlap between the three categories |
| `momentum_apps` | repo root (one app per top-level directory) | 243 | Directory count; 100% have their own `application.fam` |
| `roguemaster` | `applications/external/` | 688 | Directory count (`find -maxdepth 1 -mindepth 1 -type d`), excluding the one top-level `application.fam` manifest file itself |

**This phase's own 20-app baseline was NOT individually re-catalogued
against all 1,330 (82+317+243+688) upstream app directories above** —
that scale of exhaustive, per-app comparison was outside this
foundation phase's time budget. What *was* done, for real, is a direct
cross-reference of this project's own 20 named apps against each
upstream collection (by directory name and by each app's real,
`application.fam`-declared `appid`) — see
`DUPLICATE_AND_SUPERSESSION_MATRIX.md` for the full, real result — plus
a curated sample of other notable candidates per repository, recorded in
`APP_CENSUS.json`/`APP_CENSUS.tsv`. RFC 6 (Upstream Intelligence and
Sync Automation) proposes how a future phase could approach full-scale,
recurring reconciliation instead of a one-time manual sample.

## Retrieval method notes (for reproducibility)

- All four primary repositories, plus the two companion apps
  repositories, were retrieved via `git clone --depth 1
  --filter=blob:none`, which succeeded on the first attempt for every
  one of them (no fallback technique was needed).
- A `--depth 1` clone only contains its single tip commit, so
  `git log -1 --format=%cI -- <path>` returns that same tip-commit date
  for every path — this is a real, disclosed limitation, not a
  fabricated per-app "last changed" signal. Where real per-app history
  was needed (a representative 10-13 app sample per repository), the
  relevant companion-apps clone was unshallowed
  (`git fetch --deepen=500`) to get genuine per-path commit dates - done
  for `unleashed_plugins` and `momentum_apps`; not done for
  `roguemaster` (all sampled paths returned the same single-commit date,
  disclosed as such) or the four main firmware repos' own per-file
  history (not needed for this phase's purpose, since app content lives
  in the companion repos for three of the four).
