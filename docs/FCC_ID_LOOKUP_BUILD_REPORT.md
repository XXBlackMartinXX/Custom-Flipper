# FCC ID Lookup — Build Report

Records the real local and CI build results for the `fcc_id_lookup`
one-app import, mirroring the format of this project's existing
per-batch `PHASEX_2_BUILD_REPORT.md` documents.

## Local build status

**BUILD BLOCKED / ENVIRONMENT.** `fbt.cmd` is confirmed (via `file
fbt.cmd`, not assumed) to be a DOS/Windows batch file; this AI session
runs in a Linux sandbox and cannot execute it. Not a defect in
`fcc_id_lookup` — the same, already-documented environment limitation as
every prior phase's own local-build attempt.

## CI build status: **PASS**

Real Windows CI run via `.github/workflows/fcc-id-lookup-windows-validation.yml`.

**Process note on run history**: the first dispatch (run `29066998462`,
commit `b3e428a`) was auto-cancelled by GitHub Actions partway through
its Build step — not because of any defect, but because a second,
docs-only commit (`ff5a69b`) was pushed to the same branch while the
first run was still executing, and the workflow's `concurrency` group
(scoped per-workflow-per-branch, with no path filter) triggered
`cancel-in-progress` on the older run. Every individual step in that
first run had actually completed with `conclusion: success` up to the
point of cancellation — there is no evidence of any real failure in that
attempt, just a self-inflicted interruption from pushing again too soon.
The second run (`29067243595`, commit `ff5a69b`) completed cleanly
without interruption and is the authoritative result recorded below.

| Field | Value |
|---|---|
| Workflow run | [`29067243595`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29067243595) |
| Commit | `ff5a69ba05e1d7dd1d5876155f90696105f9e92d` |
| Branch | `integration/fcc-id-lookup-one-app-import` |
| Job conclusion | `success` |
| Duration | ~9 minutes 15 seconds (03:38:29–03:47:44 UTC) |

### Real classification (from the validator's own console output)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    PASS
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

### Static validation detail

- `applications_user/fcc_id_lookup: expected='fcc_id_lookup'
  parsed='fcc_id_lookup'` — manifest parse confirmed, real CI-side
  verification (not just this AI session's own local `-Mode Static` run
  from the prior commit).
- Risky keyword scan: `PASS_WITH_REVIEWED_FALSE_POSITIVES` — same result
  as the local run, all matches (including all 11 attributable to
  `fcc_id_lookup`) matched a reviewed entry.

## firmware.dfu

**Generated. Size: 862,833 bytes.**

(Reference: the last recorded good size at the Phase 2A-only baseline
commit `5e5e0ecf225be947a754e537670a6421838b939b` was 862,825 bytes —
this is informational context the validator config carries forward, not
a pass/fail comparison; an 8-byte difference at a different, much later
commit with 20 apps instead of 5 is expected and not itself meaningful.)

## flipper-z-f7-update-local.tgz

**Generated. Size: 2,891,283 bytes.**

(Same informational-only reference note as above; the Phase 2A-only
baseline recorded 2,732,909 bytes.)

## fcc_id_lookup.fap verification result

**PASS.** The validator's own per-app FAP output verification check
(driven by `tools/fcc_id_lookup_validate_config.json`'s 20-entry
`expectedApps` list, each checked individually against the real
`build\f7-firmware-C\.extapps\` directory contents) reported:

```
[PASS        ] Per-app FAP output verification
             All 20 expected .fap files found in D:\a\Custom-Flipper\Custom-Flipper\build\f7-firmware-C\.extapps
```

This is a per-app check, not an aggregate count alone — it would have
reported `FAIL` with the specific missing filename(s) named if
`fcc_id_lookup.fap` (or any of the other 19 already-accepted apps' `.fap`
outputs) were absent. `fcc_id_lookup.fap` is confirmed present.

## Total expected custom FAP count after import

**20** — the 19 already-accepted Phase 2A-2F apps plus `fcc_id_lookup`.
All 20 confirmed present in this real CI run.

## Failures/blocks

**None.** Static PASS_WITH_REVIEWED_FALSE_POSITIVES, Build PASS, both
artifacts generated at plausible sizes, all 20 `.fap` outputs present.
The only irregularity in this phase's process was the self-inflicted
concurrency-cancellation of the first CI attempt (explained above) —
not a build, safety, or app-source failure of any kind, and fully
resolved by the second, clean run.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists
anywhere in this phase's workflow or local tooling. No device, no
flash.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.**
