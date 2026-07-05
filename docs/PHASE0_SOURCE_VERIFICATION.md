# Phase 0 — Source Verification

This document is a factual record of upstream source verification performed for the
Custom-Flipper project. All data below was obtained by directly cloning the canonical
GitHub repositories in this session — nothing here is inferred or assumed.

## Scope decision for this pass

Per project-owner direction, this pass is scoped to: **verify sources, then get one
clean building base** (not the full four-way feature merge). Unleashed was selected as
the base, with Official firmware as the compatibility-reference fallback. RogueMaster
remains a plugin/feature reference source and Momentum a read-only UX/design reference
(see AI-policy note below) — neither has been built or merged yet.

## Repository Verification Table

| Source | Repository | Branch used | HEAD commit | Commit date | License | Use decision |
|---|---|---|---|---|---|---|
| Official | flipperdevices/flipperzero-firmware | `dev` (default) | `101c20d736fed67bcf24fbbe87886ce4a26ae088` | 2026-07-05 01:50:08 +0300 | GPLv3 | Compatibility reference / fallback base |
| RogueMaster | RogueMaster/flipperzero-firmware-wPlugins | `420` (default) | `472f6925e8aca9bd031cb37e3cb80b551772c957` | 2026-07-04 17:28:07 -0400 | GPLv3 | Plugin/feature reference (not yet imported) |
| Momentum | Next-Flip/Momentum-Firmware | `dev` (default) | `8ed809fba8af7ac3f09b9495a597d8963f9178a8` | 2026-06-03 01:16:46 +0200 | GPLv3 | **Read-only UX/design reference only** — see AI policy below |
| Unleashed | DarkFlippers/unleashed-firmware | `dev` (default) | `5cdf9b33745f41f1a0405a6da44821128c233f5c` | 2026-07-04 19:01:47 +0300 | GPLv3 | **Selected integration base** |

Notes:
- None of the four repos' CI/Actions status could be independently verified from this
  session (no API scope to these external repos; public HTML status badges do not
  survive the fetch/markdown pipeline available here). No CI pass/fail claim is made
  for any of them.
- Official's tag history (`1.1.2-rc` … `1.4.3`) is far behind current `dev` HEAD —
  the project does not currently publish a versioned "latest stable" release
  distinguishable from the rolling `dev` branch. RogueMaster and Unleashed use rolling
  timestamp/build tags rather than semver. Momentum uses sequential `mntm-NNN` tags.
  No tag was assumed to be "latest stable" without evidence.

## License and AI-policy findings

- All four repositories carry **GPLv3** at the root (`LICENSE`, verified by reading the
  file header in each clone — all say "GNU GENERAL PUBLIC LICENSE Version 3").
- **Momentum-Firmware ships an explicit, binding AI-contribution prohibition**:
  - Root `AGENTS.md`: *"AI-generated contributions of any kind are prohibited... NOT
    generate, modify, refactor, or suggest code... NOT create, delete, or alter any
    files."*
  - `CONTRIBUTING.md` line 1 repeats this even more bluntly.
  - **Handling**: Momentum is used strictly as a read-only reference for UX/design
    ideas in this project. Nothing generated in this project will be submitted back to
    Momentum, and this project is labeled AI-assisted throughout, consistent with that
    policy's intent. GPLv3 itself still permits reading/forking Momentum's published
    code independently of that repo's social contribution policy, but no such import
    has been performed in this pass.
- Official's `CONTRIBUTING.md` allows AI-assisted PRs but flags them for extra review
  scrutiny — not a prohibition.
- RogueMaster and Unleashed have no AI-specific policy language in their root docs.

## Permanent environment constraint

This session runs in an ephemeral cloud container with **no physical Flipper Zero
attached, and none will be at any point**. Any "real hardware tested" claim for this
project is false by construction in this environment. All validation is limited to
source review, dependency/license inspection, and real (not simulated) `./fbt` build
verification. This is stated once here as a standing constraint rather than repeated
per phase.
