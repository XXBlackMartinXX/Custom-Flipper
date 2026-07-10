# Pre-Flash Workflow Exception Review

Docs only. Records the review that justified adding exactly one, narrow,
pinned-hash exception to `tools/pre_flash_safeguard_gate.ps1`'s baseline
ancestry/diff-scope check, and the mechanism enforcing it. This exception
resolves the open item disclosed in
`docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md`'s "Important real finding
from this patch" section.

## Why this workflow exists after the accepted baseline

The accepted baseline commit is `86265727b5b8cfce5086eb88f8bb93d0169ab9a9`
(CI validation run `29068148596`). After that commit was accepted,
`.github/workflows/fcc-id-lookup-finalize-baseline.yml` was added at commit
`22167ac` ("fcc: baseline acceptance record and finalization workflow") as
part of this project's own already-completed, already-reviewed
baseline-finalization process. Its job: download the already-built,
already-accepted CI artifacts, compute and record their real SHA256 hashes
into `docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md` /
`FCC_ID_LOOKUP_ARTIFACT_MANIFEST.md`, and tag the baseline commit - not to
rebuild, modify, or re-flash anything. It ran once, as finalization run
`29096377711`.

Under the strict, fail-closed allow-list added by the correctness patch
(only `docs/` and `tools/` permitted between the accepted baseline and
HEAD), this one real `.github/workflows/` file is a genuine, legitimate
difference - and, with no exception, forces `FAIL` on every run against
this repository's real HEAD, forever, since the file is never going away
and the baseline is never moving. That is the exact open item this review
resolves.

## Exact path and pinned hash

- **Path** (exact, not a directory or pattern):
  `.github/workflows/fcc-id-lookup-finalize-baseline.yml`
- **Pinned SHA256** (computed directly from the file's current, reviewed,
  as-committed bytes - not guessed, not derived from a template):
  `3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5`
- **File size**: 19,826 bytes
- **Introduced at commit**: `22167ac`, and has not been modified since
  (`git log --oneline -- <path>` shows exactly one entry for this file).

This exact path/hash pair is embedded in `tools/pre_flash_safeguard_gate.ps1`
as `$PinnedWorkflowExceptions`. No other file, and no other version of this
file's content, is exempted.

## Audit findings (performed before approving the exception)

The workflow's full text was read and checked line-by-line against every
required claim below. All seven were confirmed true; had any been false,
this exception would not have been added (per this phase's own
requirement to classify NEEDS REVIEW or FAILED and stop instead).

| # | Claim | Finding |
|---|---|---|
| 1 | No firmware/app source modification | Confirmed. The workflow never touches `applications/`, `applications_user/`, or any firmware source path. |
| 2 | No firmware build replacement | Confirmed. `fbt` (the project's build tool) is never invoked anywhere in this workflow. |
| 3 | No flash/device operation | Confirmed. No mention of `qFlipper`, flashing, DFU, or any device interaction anywhere in the workflow. |
| 4 | No artifact-content mutation | Confirmed. Artifacts are fetched via `gh run download` and only ever read (hashed) - never re-uploaded, re-encoded, or otherwise altered. |
| 5 | No release publication | Confirmed. The workflow creates two annotated git tags via `git tag -a` - it never creates a GitHub Release. |
| 6 | `git add` scope is limited to documentation | Confirmed. The only `git add` in the workflow stages exactly three files: `docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md`, `docs/FCC_ID_LOOKUP_ARTIFACT_MANIFEST.md`, `docs/FCC_ID_LOOKUP_BASELINE_ACCEPTANCE_RECORD.md`. |
| 7 | Fails closed if scope is ever violated | Confirmed. The "Commit docs changes only" step explicitly checks every staged file and runs `Write-Error "Refusing to commit..."` followed by `exit 1` if any staged path does not start with `docs/`. |

**Conclusion: all seven claims hold. The exception is approved.**

## Why this cannot affect the already-built artifact bytes

The accepted `firmware.dfu` and `flipper-z-f7-update-local.tgz` were built
by CI run `29068148596`, which predates this workflow file's existence
entirely - the workflow could not have influenced that build even if it
tried to, and per the audit above, it never tries to. Artifact hash
verification (`-Mode ArtifactHashVerify`) remains bound to the accepted
baseline's own recorded sizes/hashes, completely independent of this
workflow, this exception, or whatever commit HEAD happens to be.

Approving this exception does **not** rebind the accepted artifacts to
HEAD. It only recognizes that one specific, already-reviewed, docs-only
tooling file legitimately exists downstream of the baseline commit,
without permitting the `.github/workflows/` directory in general.

## Fail-closed enforcement mechanism

`Get-BaselineAncestryDiffResult` in `tools/pre_flash_safeguard_gate.ps1`:

1. Confirms the accepted baseline is an ancestor of HEAD
   (`git merge-base --is-ancestor`).
2. Enumerates every changed path between the baseline and HEAD
   (`git diff --name-only`).
3. Classifies each changed file as: allowed by prefix (`docs/`, `tools/`),
   allowed by pinned exception (exact path match **and** a live SHA256
   recomputation of the file's current bytes matching the pinned
   `ExpectedSha256`), or forbidden.
4. Any forbidden file - including a pinned-exception file whose live hash
   no longer matches, or that is missing entirely - forces the overall
   result to `FAIL`, naming every offending file.
5. Only when every changed file is covered by a prefix or a matched
   pinned exception does the check return
   `PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND
   PINNED FINALIZATION WORKFLOW`.

This means: if anyone ever edits
`fcc-id-lookup-finalize-baseline.yml` in the future, its live hash will no
longer match the pinned value, and the check will fail closed - reporting
`FAIL` with an explicit "PINNED EXCEPTION FAILED - hash mismatch" message,
not silently passing. Re-approving a changed version of this file requires
a new review and a new pinned hash in this script; nothing does that
automatically.

## Limitations

- This exception is scoped to one exact file path and one exact hash. It
  is not a general carve-out for `.github/workflows/`, for finalization
  tooling in general, or for any future workflow file, however similar in
  purpose.
- This review does not re-validate the workflow's behavior at the time it
  actually ran (finalization run `29096377711`) - it validates the
  workflow's current, static text against the required safety claims.
  Both are consistent here because the file has not changed since it ran.
- This exception exists in `tools/pre_flash_safeguard_gate.ps1` only. It
  has no bearing on `tools/final_hardware_gate.ps1`'s own baseline
  ancestry checks (a separate, less strict check using a plain
  `NEEDS_REVIEW`-on-mismatch classification, not this fail-closed
  allow-list design) or on any CI workflow itself.

## Regression tests

`tools/pre_flash_safeguard_gate.tests.ps1` (all run against disposable
scratch git repositories under the OS temp directory unless noted) proves
the mechanism, not just the specific pinned value:

| Test | Scenario | Result |
|---|---|---|
| Ancestry Test A | docs/tools-only descendant | `PASS` |
| Ancestry Test B | docs/tools + an exact pinned workflow file, hash matching | `PASS` via the pinned-exception path |
| Ancestry Test C | the exact pinned path present, content/hash altered | `FAIL`, naming the file with a hash-mismatch annotation |
| Ancestry Test D | a different, non-pinned `.github/workflows/` file changed | `FAIL`, naming the file |
| Ancestry Test E | `applications_user/` change | `FAIL`/`BLOCKED`, naming the file |
| Ancestry Test F | accepted baseline not an ancestor of HEAD | `BLOCKED`, never `PASS` |
| Real-repo assertion | this repository's real accepted baseline and real HEAD, using the real, shipped `$PinnedWorkflowExceptions` | `PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND PINNED FINALIZATION WORKFLOW` |

All 13 assertions in that file pass, including the real-repo assertion
against this repository's actual current HEAD.

## Files changed by this exception

- `tools/pre_flash_safeguard_gate.ps1` - `$PinnedWorkflowExceptions`
  constant added; `Get-BaselineAncestryDiffResult` extended with a
  `-PinnedFileExceptions` parameter and a new PASS classification for the
  pinned-exception path; no other check weakened.
- `tools/pre_flash_safeguard_gate.tests.ps1` - Ancestry Tests A-F added/
  reconciled, plus a real-repo assertion (previously an unasserted
  diagnostic).
- `docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md` - this document.
