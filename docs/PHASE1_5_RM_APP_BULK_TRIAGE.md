# Phase 1.5 — RogueMaster External App Catalog: Bulk Automated Triage

Docs only. No firmware source touched, no apps imported, nothing merged. This is the
automated first-pass triage recommended at the end of Phase 1 for the ~650 RogueMaster
external apps that weren't individually read during Phase 1 (Phase 1 individually read
33 name-flagged apps; this pass covers all 681 systematically via metadata + keyword
scanning, then flags a subset for the individual reads that did happen this round).

## Method

A script parsed every `applications/external/*/application.fam` in the RogueMaster
clone (commit `472f6925e8aca9bd031cb37e3cb80b551772c957`, branch `420`) plus each
app's README, extracting real fields — nothing below is estimated or guessed.

**Fields extracted per app:** `appid`, `name`, `apptype`, `fap_category`,
`fap_author`, `fap_version`, `fap_weburl`, `fap_description`, source file count
(where the `.fam` used an explicit list), README presence, total on-disk file
count/size.

**Automated checks run:**
1. Category breakdown via the author-declared `fap_category` field (not a
   name-guess — this is real metadata every app author sets).
2. Duplicate `appid` detection across the whole catalog.
3. Overlap detection against the base (Official + Unleashed's own additions):
   folder-name / appid match against the 57 app directories already in
   `applications/{main,system,settings,debug}` of Official and Unleashed.
4. Safety-keyword regex scan (12 categories: RF attack, brute force,
   crack/exploit, unauthorized access, sniff/capture, credential, BadUSB, rolling
   code, network exfiltration, surveillance, audit/pentest, educational) run
   against each app's `fap_description` **and** its actual README text (not just
   the folder name — this was the main gap in Phase 1's coverage).
5. "Unclear provenance" flag: apps with no README, no `fap_description`, and no
   `fap_author` at all.

## Results

| Metric | Value |
|---|---|
| Total external apps | **681** (682 raw directory entries; one was a stray top-level file, not an app) |
| Have `application.fam` | 681 / 681 |
| Missing `fap_category` | 1 (`princeofarabia` — experimental variant, uncategorized) |
| `apptype` breakdown | EXTERNAL: 675, MENUEXTERNAL: 4, DEBUG: 1, none: 1 |
| No README | 70 |
| No `fap_description` | 21 |
| No `fap_author` | 24 |
| **Unclear provenance** (all three missing) | **5**: `devinfo`, `music_beeper`, `namechanger`, `notes_for_fz`, `sam` |
| Duplicate `appid` within the catalog | 0 |
| Overlap with existing base apps (folder/appid match) | **3**: `mfkey`, `snake_game`, `subghz_remote` (see note below) |
| Apps with ≥1 safety-keyword hit | 216 (of 681) |
| Apps with a **high-risk** keyword hit (RF attack, brute, crack/exploit, unauthorized access, BadUSB, rolling code, network exfil) | **89** — individually pulled and reviewed via real `fap_description` text this pass (not name-guessed); see `PHASE1_5_EXCLUSION_LIST.md` |
| Apps with zero risk-keyword hits, in a safe category, with README+author+description present | **195** — the automated candidate pool behind `PHASE1_5_HIGH_VALUE_SHORTLIST.md` |

### Category breakdown (author-declared `fap_category`, real counts)

| Category | Count | Category | Count |
|---|---|---|---|
| Games | 151 | Bluetooth | 16 |
| Tools | 108 | RFID | 11 |
| GPIO | 97 | GPIO/NRF24 | 11 |
| NFC | 56 | Tools/Educational | 9 |
| Sub-GHz | 40 | GPIO/MALVEKE | 8 |
| GPIO/ESP32 | 35 | GPIO/VGM | 6 |
| Infrared | 32 | GPIO/Debug | 6 |
| USB | 27 | Settings | 4 |
| Media | 26 | GPIO/ESP8266 | 4 |
| GPIO/Sensors | 20 | GPIO/FlipBoard | 4 |
| | | GPIO/GPS | 3 |
| | | iButton | 2 |
| | | GPIO/Games | 2 |
| | | Main / GPIO/FlipperHTTP / (none) | 1 each |

This supersedes the rougher name-keyword-based category estimate given in Phase 1's
`PHASE1_FEATURE_INVENTORY.md` — that was a filename heuristic; this is the real,
author-declared metadata.

### The 3 base-overlap apps — not duplicates to dismiss, need a real compare

- `mfkey` (external, appid `mfkey_init_plugin`) vs. base's own `applications/system/mfkey`
- `snake_game` (external, appid `snake`) vs. base's own `applications/main/snake_game`
- `subghz_remote` (external, appid `subghz_remote_refactored`) vs. base's own
  `applications/main/subghz_remote`

Each external version is plausibly a community fork/enhancement of the app already
shipping in our base, not a blind duplicate. **Recommendation: if these are ever
considered, diff them against the base version's actual code to decide "replace" vs.
"skip as redundant" — do not import both.** Not in the high-value shortlist as new
value; flagged here so they aren't silently lost track of either.

## A concrete example of why automated metadata alone isn't a decision (documented, not hidden)

`applications/external/wifi_deauther`'s `application.fam` field `fap_description`
reads *"This application can be used to test Wiegand readers and keypads"* — which,
read alone, sounds benign. But its `appid` is `wifi_deauther_v2`, its `name` is
"Deauther v2", its `fap_weburl` points to a GPIO tutorials repo, its entry point is
literally `wifi_deauther_app`, its source filenames include `wifi_deauther_uart.c`,
and its actual README (read directly) says: *"Flipper Zero esp8266 deauther app.
Based off the WiFi Marauder App."* The `fap_description` field is simply a stale
copy-paste from the same prolific author's other small GPIO tutorial apps — every
other signal agrees it's a real Wi-Fi deauther (a DoS tool, excluded per project
rules). This is kept in the record as a concrete demonstration that structured
metadata fields can be wrong/stale, and cross-referencing multiple signals (name,
appid, entry point, source filenames, README, web URL) matters — automated triage
here is a **first-pass filter**, not a final safety determination for any single app.

## What still requires manual review (not done this pass)

- The 89 high-risk-keyword apps got their real `fap_description` text pulled and
  read (this pass), which is enough to make a provisional call for most of them (see
  `PHASE1_5_EXCLUSION_LIST.md`) — but a handful of ambiguous ones (noted there
  individually) still need an actual source read before any tier decision, not just
  the one-line description.
- None of the 195 "candidate pool" apps have had their actual `.c` source read yet —
  the automated pass confirms *category + no risk-keyword hit + real
  author/README/description present*, which is a reasonable bar for "worth
  considering," not a security review. A fast per-app read (README + skim source)
  is still owed before any of these are actually copied into a build, per the Phase 1
  recommended integration plan.
- The 5 "unclear provenance" apps (no README, no description, no author) were not
  individually read this pass — flagged for exclusion pending that read, not because
  they're known-bad, but because there's currently nothing to evaluate them on.
- Full security review (static analysis, secret-scanning, network-call auditing per
  the project's later Security Review phase) has not been performed on any app,
  including ones marked "candidate" below.

## Limitations of this automated triage (stated plainly)

- Keyword regex matching produces both false positives (e.g., a game's description
  using the word "tracking" for a UI element) and relies on authors' own
  descriptions being accurate (see the `wifi_deauther` example above, where it
  wasn't) — that's why every high-risk hit was cross-checked against `appid`, name,
  and (for the one case shown) the actual README, not accepted at face value.
- The "195 candidate pool" is a conservative filter (safe category + zero keyword
  hits + fully documented) — it is very likely under-inclusive (good apps in
  borderline categories like GPIO/Sensors or Infrared were excluded from this pool by
  construction, not because they're risky) rather than over-inclusive. That's a
  deliberate choice: a smaller clean shortlist over a large uncertain one, per
  instruction.
- No build/compile check has been run on any of these 681 apps against our
  Unleashed base — "candidate" here means "worth reviewing for integration," not
  "confirmed to build."
