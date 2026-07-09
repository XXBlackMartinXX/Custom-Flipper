# Phase 2G — Candidate Review

Docs only. Planning only. **No code is imported, merged, modified, or
built by this document.** This phase determines whether any safe, clean,
non-deferred candidate remains after Phases 2A through 2F, drawing
exclusively on existing planning/audit documentation — no new upstream
source was fetched or read in this phase.

## Source docs consulted

| Doc | What it provided |
|---|---|
| `docs/PHASE1_5_HIGH_VALUE_SHORTLIST.md` (docs branch) | The full 195-app candidate pool, grouped by category, with the 8 apps flagged with a footnote at that stage |
| `docs/PHASE1_5_TOP_25_CANDIDATES.md` (docs branch) | The 25-app "final shortlist" narrowed from the 195-app pool — the pool every Phase 2A-2F batch has drawn from |
| `docs/PHASE1_5_EXCLUSION_LIST.md` (docs branch) | The apps excluded at the very first triage pass (RF jamming/deauth, BadUSB/HID-injection abuse, brute-force/cracking, NFC/RFID cloning, credential tooling) — confirms none of that category was ever eligible, so it isn't re-litigated here |
| `docs/PHASE1_5_RM_APP_BULK_TRIAGE.md` (docs branch) | The original 681→195 bulk triage methodology, for context only |
| `docs/PHASE1_6_TOP25_SOURCE_AUDIT.md` (docs branch) | The real per-app source audit of all 25 Top-25 candidates — the audit depth every prior phase's batch has relied on before recommending any app |
| `docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md` (docs branch) | The 4 Top-25 apps downgraded from "approve" after source audit: `upython`, `iconedit`, `animation_switcher`, `theme_manager` |
| `docs/PHASE1_6_FIRST_BATCH_SELECTION.md` (docs branch) | Confirms the Top-25 pool's intended one-batch-at-a-time drawdown discipline |
| `docs/PHASE2B_CANDIDATE_REVIEW.md` through `docs/PHASE2F_CANDIDATE_REVIEW.md` | Each phase's own restatement of already-imported/hard-deferred status, confirming the running tally |
| `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` | Where `fcc_id_lookup`'s license-evidence gap was actually found (post-Top-25-audit, at Phase 2C.1's deeper pre-import pass) |
| `docs/PHASE2B_LICENSE_REVIEW.md` | Where `c_book`'s copyright concern was first flagged (a Top-25-audit "APPROVE" was later reconsidered once the bundled K&R text's actual commercial/copyrighted status was weighed) |
| `docs/PHASE2F_NEXT_GATE.md` | Confirms Phase 2F's own prior determination: the Top-25 pool was the entire remaining clean pool, and going beyond it would require "a fresh Phase 1-style bulk triage beyond the original 681-app/Top-25 scope" — a separate, larger undertaking, not a normal batch-planning pass |
| `docs/KNOWN_ISSUES.md`, `docs/BUILD_LOG.md` (docs branch) | Current status of the hardware-unavailability item (3) and the `fcc_id_lookup` license-gap item (6) |

No Phase 2G-relevant notes existed anywhere in the repository prior to
this document.

## Already-imported apps excluded

All 19 apps in the accepted Phase 2F baseline are removed from
consideration, per the task's explicit list:

`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`,
`flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`, `docviewlite`,
`resistors`, `crypto_dictionary`, `2048`, `image_viewer`, `boilerplate`,
`minesweeper`, `qrcode`, `hex_viewer`, `barcode_gen`.

## Hard-deferred apps excluded and why

All 6 are restated, not re-reviewed — per the task's explicit "do not
reopen `fcc_id_lookup` unless the task is a narrow license-resolution
phase" instruction and the project owner's own explicit list of the
other 5. No new evidence was gathered on any of these 6 in this phase.

| App | Why deferred | Class |
|---|---|---|
| `fcc_id_lookup` | Top-25 source audit (`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`) originally marked **APPROVE**. Phase 2C.1's deeper pre-import verification then found the RogueMaster-vendored copy has no `LICENSE` file, no SPDX identifier, and no copyright header anywhere in its source (commit `472f6925e8aca9bd031cb37e3cb80b551772c957`). Strong corroborating MIT evidence exists at the true upstream repository (`github.com/lrehmann/fcc-id-lookup-flipper`) but is not commit-pinned to the vendored revision. See `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`, `docs/KNOWN_ISSUES.md` item 6. | License-evidence gap |
| `upython` | Top-25 source audit found real `furi_hal_gpio_write`/`furi_hal_gpio_read`/GPIO-interrupt bindings and real `furi_hal_infrared_async_tx_start` (IR **transmit**) exposed to any user-authored MicroPython script — `fap_description` gave no hint of this. See `docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`. | Hardware/control capability risk |
| `iconedit` | `panels/send_usb.c` calls `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` directly — the "send edited icon to a PC" feature types the icon data as keystrokes, mechanically identical to a BadUSB payload mechanism, just with fixed, self-authored data. See `docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`. | HID injection capability risk |
| `c_book` | Bundles verbatim `.txt` chapters of "The C Programming Language" (K&R, Prentice Hall) — a commercially published, copyrighted work with no confirmed distribution right. Top-25 source audit only confirmed the app's own code was a "pure e-book reader," not that the bundled *content* was clear to redistribute — that distinction was drawn later. See `docs/PHASE2B_LICENSE_REVIEW.md`. | Unresolved copyright question |
| `animation_switcher` | Writes to the shared `/ext/dolphin/manifest.txt`, not app-private storage. See `docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`. | Shared/root-level storage write, not individually re-reviewed |
| `theme_manager` | Writes to `/ext/dolphin/` (with a confirmed backup-before-write step, per source). Same shared-directory consideration as `animation_switcher`. See `docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`. | Shared/root-level storage write, not individually re-reviewed |

## Top-25 pool accounting

The Top-25 shortlist (`docs/PHASE1_5_TOP_25_CANDIDATES.md`) is the pool
every batch since Phase 2A has drawn from, and it is the only pool this
project has ever subjected to a real, dedicated, per-app source audit
(`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`) before recommending anything from
it. The full 25 are now fully accounted for:

- **19 imported**, across Phase 2A through Phase 2F, in small batches
  per each phase's own `RECOMMENDED_BATCH.md` and `IMPORT_LOG.md`:
  `network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`,
  `chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`,
  `docviewlite`, `resistors`, `crypto_dictionary`, `2048`,
  `image_viewer`, `boilerplate`, `minesweeper`, `qrcode`, `hex_viewer`,
  `barcode_gen` — the exact 19-app list this task itself supplied as the
  current accepted baseline.
- **6 hard-deferred** (table above).
- **19 + 6 = 25 / 25.** No app from the audited Top-25 pool remains
  unaccounted for.

## Remaining, un-audited pool (195-app list minus the Top 25)

`docs/PHASE1_5_HIGH_VALUE_SHORTLIST.md` lists 195 candidates total, of
which only the 25 above ever received a dedicated per-app source audit.
The remaining ~170 apps received only Phase 1.5's bulk, metadata-level
triage (README/`.fam` description only) — the same shallow depth that,
for the Top 25 itself, later proved insufficient on its own: `upython`'s
GPIO/IR capability, `iconedit`'s HID-keystroke capability, `sd_info`'s
SD-benchmark writes (Phase 2C.1), and `hex_viewer`/`barcode_gen`'s exact
storage behavior (Phase 2F.1) were all invisible at the metadata level
and only surfaced by a real, dedicated source read.

This phase's task scope is explicitly limited to "existing
planning/audit documentation" — it does not authorize fetching or
reading new upstream source. Consistent with that scope, and consistent
with this project's own repeated lesson that metadata-only review is
unreliable, **no app from the un-audited ~170-app pool is promoted to
candidate status in this document.** Doing so responsibly would require
first performing the same per-app source-audit rigor
`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md` applied to the Top 25 — which is
itself "a fresh Phase 1-style bulk triage beyond the original
681-app/Top-25 scope," explicitly flagged in `docs/PHASE2F_NEXT_GATE.md`
as a separate, larger undertaking, not a narrow batch-planning pass like
this one.

For transparency, a non-exhaustive, illustrative sample of Tools/
Educational-category entries from that un-audited pool that *look*
superficially low-risk by name/description alone (offline reference
tools, simple ciphers, converters) is recorded below — **not as
candidates, but as a starting point for a possible future dedicated
audit pass, should the project owner choose to commission one:**

| App | Declared purpose (metadata only) | Confidence level |
|---|---|---|
| `ascii` | ASCII table reference | NEEDS REVIEW — no source read performed |
| `rot13` | ROT13 cipher | NEEDS REVIEW — no source read performed |
| `caesarcipher` | Caesar cipher encode/decode | NEEDS REVIEW — no source read performed |
| `roman_decoder` | Roman-numeral converter | NEEDS REVIEW — no source read performed |
| `mayan_decoder` | Decimal-to-Mayan numeral converter | NEEDS REVIEW — no source read performed |
| `brainfuck` | Brainfuck language interpreter | NEEDS REVIEW — no source read performed |
| `math_wiz` | Trig/calculus calculator | NEEDS REVIEW — no source read performed |

None of the above is recommended in this phase. Each would need the same
full per-app source audit every already-imported app received before it
could responsibly move past "NEEDS REVIEW."

## Safety-screening summary

- **Zero candidates from the audited Top-25 pool remain** — all 25 are
  imported (19) or hard-deferred (6) for documented, specific reasons.
- **Zero candidates from the un-audited ~170-app pool are promoted** —
  none has the source-level verification this project requires before
  recommending an app, and performing that verification is out of this
  phase's scope.
- Every one of this task's hard-exclusion categories (RF/Sub-GHz, NFC/
  RFID/iButton, BadUSB/HID injection, BLE abuse, GPIO write/control, IR
  transmit, Wi-Fi deauth/jamming, brute force, credential/token/
  password/seed/wallet/exfiltration/bypass, offensive/security-abuse
  workflows) was already screened out of the 195-app pool at Phase 1.5's
  original triage (`docs/PHASE1_5_EXCLUSION_LIST.md`) — nothing in that
  excluded set is reconsidered here.

## License-screening summary

No new license evidence was gathered in this phase. The two open license
concerns from the audited pool (`fcc_id_lookup`'s missing `LICENSE` file
in the vendored revision, `c_book`'s unresolved copyrighted-book content)
remain exactly as documented — neither is resolved, weakened, or
reopened by this review.

## Dependency-surface summary

Not applicable — no candidate is recommended for import in this phase,
so no dependency surface was newly assessed. The audited Top-25 pool's
dependency findings (all 25: "None declared" per
`docs/PHASE1_5_TOP_25_CANDIDATES.md`) remain the most recent evidence on
record for that pool.

## Storage/hardware behavior summary

Not applicable for the same reason. The two shared-storage apps
(`animation_switcher`, `theme_manager`) remain flagged for their
`/ext/dolphin/` writes; no other pending storage/hardware concern exists
outside the 6 hard-deferred apps.

## Confidence level per candidate

| Candidate | Confidence | Basis |
|---|---|---|
| Any Top-25 app | N/A — all 25 already imported or hard-deferred | Full source audit already performed |
| Any un-audited ~170-app-pool app | NEEDS REVIEW (metadata only, illustrative sample above) | No source read performed in this or any phase |

## Explicit planning-only statement

**This document is planning only. No code is imported, no application
directory is created or modified, no build is attempted, and no firmware
or app source changes anywhere as a result of this review.**

## Conclusion: clean candidate pool is exhausted

The audited, project-vetted Top-25 candidate pool — the only pool this
project has ever applied real per-app source verification to before
recommending an import — is **fully exhausted**: 19 apps imported, 6
apps hard-deferred for specific, documented, unresolved reasons. No
app in that pool remains available.

The broader 195-app pool contains apps that were never individually
source-audited, and recommending any of them without that audit would
repeat exactly the class of mistake this project has already made and
corrected multiple times (metadata descriptions concealing real
hardware/HID capability). Performing that audit is a legitimate future
option, but it is a distinct, larger undertaking (a fresh Phase
1-style bulk triage) — not a normal Phase 2G-scale batch-planning
pass, and not something this document unilaterally starts.

**Recommendation: stop app expansion for this phase. See
`docs/PHASE2G_RECOMMENDED_BATCH.md`, `docs/PHASE2G_GO_NO_GO.md`, and
`docs/PHASE2G_NEXT_GATE.md` for the resulting recommendation and next
allowed paths.**
