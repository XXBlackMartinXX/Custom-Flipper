# Phase 2A — Integration Log

**This is v2 of this document.** The first version of this branch (base commit
`64b3cdd`, apps through `2f2e208`) flattened all of Unleashed's git submodules into
plain files. That broke a real build step — see "Why the branch was rebuilt" below
— and the branch was recreated from scratch with proper git submodules. The commit
hashes in this document are the **v2** hashes; the old ones no longer exist on this
branch (it was force-pushed).

Branch: `integration/phase2a-first-batch` (orphan branch, base = clean Unleashed
snapshot with real submodules, no shared history with
`claude/flipper-custom-firmware-cxrcer`'s documentation-only history).

## Why the branch was rebuilt

The project owner ran the real local Windows build against v1 of this branch and it
failed **before any app code compiled**, at asset/version generation:

```
Git: fetch failed
scons: *** [build\f7-firmware-C\assets\compiled\protobuf_version.h]
    Failed to process git tags for protobuf versioning
```

Root cause, confirmed by reading `scripts/fbt_tools/fbt_assets.py`'s
`_proto_ver_generator`: Unleashed's build genuinely runs `git fetch --tags` and
`git describe --tags --abbrev=0` **inside `assets/protobuf` at build time** to stamp
`protobuf_version.h` with that submodule's own version tag. That requires
`assets/protobuf` to be a real git checkout with a working remote and tag history.
v1 of this branch had flattened every submodule (including `assets/protobuf`) into
plain files with no `.git` metadata at all — so those git commands had nothing valid
to operate on. This was a real, load-bearing mistake in how the base was
constructed, not an app problem; none of the 5 imported apps' own code was ever
reached by the build.

**Fix**: rebuilt the base as an orphan commit with all 12 of Unleashed's pinned
submodules added as genuine git submodules (`git submodule add` against the exact
upstream URL, then checked out to the exact commit Unleashed pins — verified
identical, path-by-path and SHA-by-SHA, against `git submodule status` on the
original Unleashed clone), including the 4 further nested submodules inside them
(`lib/mbedtls/framework`, `lib/stm32wb_copro/scripts`, and FreeRTOS-Kernel's two
`ThirdParty` port directories). Verified directly, on this exact rebuilt tree,
that the specific failing command now succeeds:

```
$ cd assets/protobuf && git describe --tags --abbrev=0
0.29
```

One incidental cleanup during the rebuild: `git submodule add` auto-generates a
`.gitmodules` section named after the path if no existing section already uses that
exact name. For 3 submodules whose upstream `.gitmodules` section name differs from
their path (`lib/st_cmsis_device_wb` → path `lib/stm32wb_cmsis`,
`lib/stm32wbxx_hal_driver` → path `lib/stm32wb_hal`, `subghz_remote` → path
`applications/main/subghz_remote`), this created duplicate sections. Removed the
duplicates, kept upstream's original section names, and confirmed
`git submodule status` still resolves all 12 correctly.

## Base commit (v2)

| Field | Value |
|---|---|
| Commit | `4c95acb` — "Import Unleashed firmware base (v2 - proper git submodules) @ 5cdf9b3" |
| Upstream source | `DarkFlippers/unleashed-firmware`, `dev` branch, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c` — same commit as v1, same commit already verified/build-confirmed (for the *unmodified* base, no submodule flattening involved) in `docs/BUILD_LOG.md` |
| Submodules | All 12 real git submodules, `.gitmodules` present and correct, every pin verified against upstream's own `git submodule status` output |
| Modifications from upstream | **None.** Same as v1: no source patches, no `-Wno-error` flags, build artifacts excluded. |

## Apps imported (same 5, same order, same content — only the base changed)

| # | App | Source path (RogueMaster) | Destination path | Files | Status | Commit (v2) |
|---|---|---|---|---|---|---|
| 1 | `network_subnet` | `applications/external/network_subnet` (commit `472f6925e`) | `applications_user/network_subnet/` | 26 | **IMPORTED** | `749c9ab` |
| 2 | `programmer_calc` | `applications/external/programmer_calc` | `applications_user/programmer_calc/` | 37 | **IMPORTED** | `e4dd48f` |
| 3 | `vin_decoder` | `applications/external/vin_decoder` | `applications_user/vin_decoder/` | 10 | **IMPORTED** | `d18cd29` |
| 4 | `flipper95` | `applications/external/flipper95` | `applications_user/flipper95/` | 9 | **IMPORTED** | `7ca2d5f` |
| 5 | `chess` | `applications/external/chess` | `applications_user/chess/` | 40 | **IMPORTED** | `202245e` |

Every app's actual content (source files, `application.fam`, licenses, findings from
Phase 1.6) is byte-for-byte identical to the v1 import — re-copied fresh from the
same RogueMaster source, re-validated (syntax, brace-balance, appid uniqueness,
capability grep) on this rebuilt tree, all results unchanged. Full per-app detail
(files, manifest changes, assets, dependencies, license notes) is unchanged from the
v1 log and reproduced here:

- **`network_subnet`**: no separate `LICENSE` (attribution via `fap_author`/README);
  no dependencies declared; no conflicts.
- **`programmer_calc`**: ships its own GPLv3 `LICENSE`; no dependencies declared; no
  conflicts.
- **`vin_decoder`**: ships its own GPLv3 `LICENSE`; no dependencies declared; no
  conflicts; re-confirmed zero GPIO/CAN/vehicle-hardware API usage.
- **`flipper95`**: no separate `LICENSE`; declares `fap_libs=["mbedtls"]` — verified
  as pure bignum arithmetic (`mbedtls_mpi_*`), no crypto/secret operations; `mbedtls`
  is one of the 12 real submodules in this base, so this is a legitimate, already-
  present dependency, not a new one.
- **`chess`**: ships its own MIT `LICENSE`; bundles two third-party libraries
  (`smallchesslib.h`, CC0/public domain; `sam/stm32_sam.{h,cpp}`, investigated in
  full in `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` — the upstream `s-macke/SAM`
  project has no open-source license, is self-described "abandonware," and offers
  only a speculative Fair Use claim. Decision: **SAM LICENSE UNCLEAR / DISABLE
  VOICE FEATURE**, a code change pending approval, not yet applied); no conflicts.

## Deliberately not imported this phase

Unchanged from v1: `upython`, `iconedit`, `animation_switcher`, `theme_manager`, and
every other RogueMaster app not in the approved first batch.

## Appid uniqueness check (final, re-run on the rebuilt tree)

`network_subnet`, `programmercalc`, `vin_decoder`, `flipper95`, `chess` — all five
confirmed unique, confirmed absent from `applications/` (base firmware's own tree).

## Attribution / license notes

Unchanged from v1 — see the per-app bullets above. None of this has been reflected
into `CREDITS.md`/`THIRD_PARTY_NOTICES.md` yet (those live on the documentation
branch); still a follow-up item, not part of this phase's scope.

## Commit sequence (v2, current)

```
4c95acb Import Unleashed firmware base (v2 - proper git submodules) @ 5cdf9b3
749c9ab Import network_subnet (RogueMaster external app) into applications_user/
e4dd48f Import programmer_calc (RogueMaster external app) into applications_user/
d18cd29 Import vin_decoder (RogueMaster external app) into applications_user/
7ca2d5f Import flipper95 (RogueMaster external app) into applications_user/
202245e Import chess (RogueMaster external app) into applications_user/
```

One commit per app, each independently revertable (see
`PHASE2A_ROLLBACK_PLAN.md`), none depending on any other. This branch was
force-pushed to replace the flawed v1 history — v1's commit hashes (`64b3cdd`
through `2f2e208`) no longer exist on `integration/phase2a-first-batch`.
