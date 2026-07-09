# Phase 2G — Risk Register

Docs only. Planning only. No code is imported by this document.

Since `docs/PHASE2G_RECOMMENDED_BATCH.md` recommends **no import batch**,
this register documents (a) the risk of continuing imports from the
remaining questionable candidates anyway, (b) each hard-deferred item
with its specific reason, and (c) why batch padding is rejected —
per this phase's own required structure for a no-candidate outcome.

## Risk of continuing imports from remaining questionable candidates

| Risk | Description | Consequence if ignored |
|---|---|---|
| **License risk** | Importing `fcc_id_lookup` without resolving its missing-`LICENSE`-in-vendored-revision gap, or `c_book` without resolving its bundled-copyrighted-text question, would add code to the accepted baseline with an open provenance/rights question. | A future release could be blocked, or worse, distributed, with genuinely unclear redistribution rights over shipped content. |
| **Capability-disclosure risk** | Importing `upython` (GPIO write/read, IR transmit exposed to arbitrary user scripts) or `iconedit` (HID keystroke injection via `panels/send_usb.c`) as an ordinary default-enabled Tools-category app would silently expand this firmware's real capability surface beyond what every prior phase's own safety-exclusion policy has held the line on. | Undermines the entire project's documented "no BadUSB/HID injection, no undisclosed hardware capability" posture for every other already-imported app — a policy weakening, not a one-off exception. |
| **Storage-scope risk** | Importing `animation_switcher`/`theme_manager` without a dedicated review of their shared `/ext/dolphin/` writes (beyond the existing Phase 1.6-level note) would introduce the first-ever accepted app in this project with write access outside its own app-private directory. | Breaks the "app-private storage only, unless specifically reviewed and accepted" invariant every hardware smoke-test checklist in this project currently assumes and tests for. |
| **Metadata-only-review risk** | Selecting any app from the un-audited ~170-app pool without a dedicated per-app source read repeats a mistake this project has already made and corrected 4 separate times (`upython`, `iconedit`, `sd_info`, `hex_viewer`/`barcode_gen`). | A newly-imported app could ship with an undisclosed capability this project would have caught with proper review — directly contradicts this project's own stated mandate to root-cause and verify rather than assume. |
| **Batch-padding risk (general)** | Selecting any app purely to "have something to import" rather than because it genuinely clears every safety/license/storage/build bar. | Degrades the overall quality and trustworthiness of every future phase's own candidate-review process — once one questionable app is padded in, the precedent weakens scrutiny for the next one too. |

## Hard-deferred items, with reason (restated, not re-reviewed)

| App | Risk class | Reason | Stop condition before reconsideration |
|---|---|---|---|
| `fcc_id_lookup` | MEDIUM (license) | No `LICENSE` file, no SPDX identifier, no copyright header in the vendored revision (`docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`). Strong but not commit-pinned corroborating upstream MIT evidence exists. | A dedicated, narrow license-resolution phase confirms the upstream `LICENSE` text applies to the exact vendored revision, and that `LICENSE` file is included at actual import time. |
| `upython` | HIGH (hardware/control capability) | Real GPIO write/read and IR-transmit bindings exposed to arbitrary user-authored scripts, undisclosed in `fap_description` (`docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`). | A dedicated security-review phase and an expert-only, opt-in build-flag mechanism (this project's own "Tier 5, lab-only" discipline) exist and are applied — not a default-enabled import. |
| `iconedit` | MEDIUM-HIGH (HID injection capability) | `panels/send_usb.c` performs real HID keystroke injection as an optional feature (`docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`). | The HID-send feature is stripped or gated behind an explicit expert-only flag before any import is reconsidered — the pure icon-editing core has no such concern. |
| `c_book` | MEDIUM (copyright) | Bundles verbatim K&R "The C Programming Language" text with no confirmed redistribution right (`docs/PHASE2B_LICENSE_REVIEW.md`). | A confirmed redistribution right for the bundled text is obtained, or the app is re-scoped to ship without the copyrighted content bundled. |
| `animation_switcher` | LOW-MEDIUM (shared storage) | Writes to `/ext/dolphin/manifest.txt`, a shared system directory (`docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`). | A dedicated review of the shared-directory write pattern, consistent with the "app-private storage only, unless specifically reviewed and accepted" bar this project applies to every other app. |
| `theme_manager` | LOW-MEDIUM (shared storage) | Writes to `/ext/dolphin/` with a confirmed backup-before-write step (`docs/PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md`). | Same as `animation_switcher`. |

## Why batch padding is rejected

- **The task's own instruction is explicit**: "do not pad a batch with
  questionable apps just to continue importing," and "if no truly safe
  candidates remain, recommend zero."
- **Every already-imported app in this project cleared the same bar**: a
  dedicated per-app source audit, a static safety-keyword scan with every
  match individually reviewed, a real CI build pass, and (pending)
  hardware validation. None of the 6 hard-deferred apps has cleared that
  bar, and none of the un-audited ~170-app pool has even attempted it.
- **A padded batch would not actually reduce risk or add real value** —
  it would only create the appearance of continued progress while
  quietly lowering this project's own established safety bar, which is
  a worse outcome than an honest, documented pause.

## Conclusion

No new risk register entries are opened for a recommended batch, because
no batch is recommended. The 6 existing hard-deferred items remain open,
unresolved, unchanged by this phase. See
`docs/PHASE2G_GO_NO_GO.md` for the final classification.
