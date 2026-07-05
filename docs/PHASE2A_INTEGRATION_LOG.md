# Phase 2A — Integration Log

Branch: `integration/phase2a-first-batch` (orphan branch, base = clean Unleashed
snapshot, no shared history with `claude/flipper-custom-firmware-cxrcer`'s
documentation-only history — kept deliberately separate so the docs branch stays
pure documentation and this branch stays pure buildable firmware source).

## Base commit

| Field | Value |
|---|---|
| Commit | `64b3cdd` — "Import Unleashed firmware base (unmodified) @ 5cdf9b3" |
| Upstream source | `DarkFlippers/unleashed-firmware`, `dev` branch, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c` (already verified/build-confirmed in `docs/BUILD_LOG.md` on the documentation branch) |
| Contents | Full source tree, all 12 pinned submodules flattened into plain tracked files (no nested `.git`), submodule URL/commit pins preserved in `docs/UNLEASHED_BASE_SUBMODULE_PINS.txt` |
| Modifications from upstream | **None.** The cloud sandbox's earlier substitute-toolchain experiment (two `-Wno-error=` flags in `site_scons/cc.scons`) was explicitly reverted (`git checkout -- site_scons/cc.scons`) and build artifacts/fake toolchain directories were removed (`git clean -fdx`) before this snapshot was taken. |
| Integrity issue found and fixed before this became the working base | The very first `git add -A` for this orphan-branch commit silently dropped `applications_user/README.md`, `applications_user/.gitignore`, and a handful of files elsewhere (`.vscode/example/*`, `scripts/ufbt/project_template/*`) because their directories' own blanket `.gitignore` (`*`) rules applied to *every* untracked path — including themselves — on a fresh orphan branch where nothing was tracked yet. Fixed by force-adding the genuinely-missing real files. Two categories of file were deliberately *not* force-added, matching upstream's own intent: a stray `.claude/settings.local.json` (an artifact of this AI tool's own session, not Unleashed source) and several `lib/nanopb/**/*.pb` / `*_pb2.py` / `__pycache__` files that nanopb's own `.gitignore` correctly excludes as generated/test-fixture artifacts (confirmed by reading nanopb's own `.gitignore` directly). |

## Apps imported (in the requested order)

| # | App | Source path (RogueMaster) | Destination path | Files | Manifest changes | Assets | Dependencies | Conflicts | Status | Commit |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `network_subnet` | `applications/external/network_subnet` (commit `472f6925e`) | `applications_user/network_subnet/` | 25 files (source/views/scenes/core + README/changelog + icon/screenshots) | New `application.fam`, unchanged from source (`appid="network_subnet"`); added scoped negation to `applications_user/.gitignore` | 1 icon PNG + 3 screenshot PNGs, all copied as-is | None declared | None found vs. base or vs. other imports | **IMPORTED** | `f7fd2b7` |
| 2 | `programmer_calc` | `applications/external/programmer_calc` | `applications_user/programmer_calc/` | 26 files, including its own GPLv3 `LICENSE` | New `application.fam`, unchanged (`appid="programmercalc"`); `.gitignore` negation added | 1 app icon + 8 doc screenshots + 8 `.flipcorg` catalog images, all copied as-is | None declared | None found | **IMPORTED** | `bba5201` |
| 3 | `vin_decoder` | `applications/external/vin_decoder` | `applications_user/vin_decoder/` | 10 files, including its own GPLv3 `LICENSE` | New `application.fam`, unchanged (`appid="vin_decoder"`); `.gitignore` negation added | 1 app icon + 2 catalog screenshots | None declared | None found | **IMPORTED** | `64f7560` |
| 4 | `flipper95` | `applications/external/flipper95` | `applications_user/flipper95/` | 9 files | New `application.fam`, unchanged (`appid="flipper95"`); `.gitignore` negation added | 1 app icon + 2 catalog screenshots | **`fap_libs=["mbedtls"]`** — not caught by the Phase 1.6 audit (which didn't check `fap_libs`); verified by reading `flipper95.c`: uses only `mbedtls_mpi_*` bignum arithmetic for prime-number testing, no crypto/secret operations. `lib/mbedtls` already exists in the base commit — no new external dependency introduced. | None found | **IMPORTED** | `412d385` |
| 5 | `chess` | `applications/external/chess` | `applications_user/chess/` | 40 files, including its own MIT `LICENSE` | New `application.fam`, unchanged (`appid="chess"`); `.gitignore` negation added | App icon + `icons/` symbol assets + 8 catalog screenshots | Bundles two vendored libraries in its own tree (not separate `requires=[...]`): `chess/smallchesslib.h` (CC0 1.0 / public domain, attributed to Miloslav Ciz per its own header) and `sam/stm32_sam.{h,cpp}` (STM32 port of SAM text-to-speech, "ported from https://github.com/s-macke/SAM" per its header — **license unverified**, flagged rather than assumed) | None found | **IMPORTED** | `42e08a9` |

## Deliberately not imported this phase

Per explicit scope: `upython`, `iconedit`, `animation_switcher`, `theme_manager`, and
every other RogueMaster app not in the approved first batch. None were touched.

## Appid uniqueness check (final, across all 5 + base)

`network_subnet`, `programmercalc`, `vin_decoder`, `flipper95`, `chess` — all five
confirmed unique, and confirmed not present anywhere in `applications/` (the base
firmware's own app tree) via direct grep after each import.

## Attribution / license notes carried forward

- `programmer_calc`, `vin_decoder`: ship their own GPLv3 `LICENSE`, copied unmodified.
- `chess`: ships its own MIT `LICENSE` (differs from the GPLv3 default — noted, not
  a conflict; MIT-into-GPLv3 inclusion is one-directionally compatible), plus two
  bundled third-party libraries with their own attribution (see table above). The
  SAM text-to-speech port's exact license is **unverified** — flagged for follow-up
  before this app goes past this integration branch.
- `network_subnet`, `flipper95`: no separate `LICENSE` file; attribution is via
  `fap_author`/README/changelog, all copied unmodified.
- None of this has been reflected into `CREDITS.md`/`THIRD_PARTY_NOTICES.md` yet —
  those live on the documentation branch and are due for an update in a follow-up
  pass, out of scope for this docs-plus-code phase per the given instructions
  (which scoped Phase 2A deliverables to the four docs listed, not a CREDITS.md
  update).

## Commit sequence

```
64b3cdd Import Unleashed firmware base (unmodified) @ 5cdf9b3
f7fd2b7 Import network_subnet (RogueMaster external app) into applications_user/
bba5201 Import programmer_calc (RogueMaster external app) into applications_user/
64f7560 Import vin_decoder (RogueMaster external app) into applications_user/
412d385 Import flipper95 (RogueMaster external app) into applications_user/
42e08a9 Import chess (RogueMaster external app) into applications_user/
```

One commit per app, each independently revertable (see
`PHASE2A_ROLLBACK_PLAN.md`), none depending on any other.
