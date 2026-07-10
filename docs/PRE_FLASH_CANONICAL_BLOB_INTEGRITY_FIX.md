# Pre-Flash Canonical Blob Integrity Fix

Docs only. Records a cross-platform integrity defect found in
`tools/pre_flash_safeguard_gate.ps1`'s pinned finalization-workflow
exception (added in the Pre-Flash Safeguard Hardening phase - see
`docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md`), the root cause, the fix,
and the regression evidence.

## Root cause

The pinned-exception check computed its integrity decision by running
`Get-FileHash` (SHA256) directly against the **checked-out working-tree
file** at `.github/workflows/fcc-id-lookup-finalize-baseline.yml`, and
comparing that hash to the pinned value recorded from the reviewed
content.

This is correct on a checkout where the working-tree bytes are
byte-identical to the committed Git object - which is the normal case on
Linux with Git's default `core.autocrlf=false`. It is **not** correct on
a Windows checkout with `core.autocrlf=true`: Git converts the
repository's canonical `LF` line endings to `CRLF` at checkout time for
text files, so the file that actually lands on disk differs, byte for
byte, from the Git blob that was reviewed and pinned - even though the
repository's own committed content (the Git object) is completely
unchanged. Hashing the working-tree bytes therefore produces a different
SHA256 than the pinned value, and the safeguard reported `FAIL` for a
real, valid, unmodified repository state.

## Windows core.autocrlf=true evidence (as reported)

| Item | Value |
|---|---|
| Windows `core.autocrlf` | `true` |
| Observed Windows working-tree SHA256 | `58affd8ab23e764a31e51e8dbc9672621d35c4356611fd91a85cd190305654f4` |
| Reviewed canonical blob SHA256 | `3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5` |
| HEAD blob equals reviewed blob | `TRUE` (confirmed by manual diagnostic) |
| Workflow path clean in working tree | `TRUE` (confirmed by manual diagnostic) |

The manual diagnostic that accompanied this report already established
that the canonical Git-blob SHA256 matched the expected value, and that
the working-tree SHA differed **only** because of the LF-to-CRLF checkout
conversion - i.e. the repository content is valid; the automated check
was wrong to fail it.

## Canonical versus working-tree hashes

| | Basis | Affected by `core.autocrlf`? | Used for the PASS/FAIL decision? |
|---|---|---|---|
| Canonical Git blob | `git cat-file blob <id>` - the exact bytes Git stores for this object, independent of any checkout | No | **Yes, exclusively** |
| Working-tree file | The checked-out file on disk, as Git's smudge/clean filters (including `core.autocrlf`) leave it | Yes | No - diagnostic display only |

## Reviewed blob ID

`.github/workflows/fcc-id-lookup-finalize-baseline.yml`

- **Git blob ID**: `094ed7bf30eecae5efe384568c5c0aa543260b2f`
- **Canonical SHA256** (computed over the exact bytes of that blob, via
  `git cat-file blob 094ed7bf30eecae5efe384568c5c0aa543260b2f | sha256sum`):
  `3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5`
- Confirmed directly against this repository in this session:
  `git rev-parse HEAD:.github/workflows/fcc-id-lookup-finalize-baseline.yml`
  returns exactly `094ed7bf30eecae5efe384568c5c0aa543260b2f`, and
  `git cat-file blob 094ed7bf30eecae5efe384568c5c0aa543260b2f | sha256sum`
  returns exactly `3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5`.

## Why working-tree hashing was incorrect

The safeguard's whole purpose is to answer "is the *committed, reviewed*
content of this one pinned file unchanged?" - a question about the Git
object graph, not about whatever bytes a particular OS/Git-configuration
combination happens to produce during checkout. Hashing the working tree
conflates two independent things: (1) whether the repository's real
content matches what was reviewed, and (2) whether this particular
checkout's line-ending/encoding transformation happens to be a no-op. A
correct integrity check must depend only on (1).

## Corrected verification model

`tools/pre_flash_safeguard_gate.ps1` now verifies the pinned exception in
this order, implemented in `Get-PinnedWorkflowExceptionResult` (calling
the new `Get-CanonicalGitBlobBytes` / `Get-Sha256OfBytes` helpers):

1. Confirm the accepted baseline is an ancestor of HEAD
   (`git merge-base --is-ancestor`, unchanged from the prior phase).
2. Resolve the workflow path at HEAD to its Git blob ID
   (`git rev-parse HEAD:<path>`). A missing path (or any git error) is a
   `FAIL`.
3. Require that blob ID to equal the pinned, reviewed
   `ExpectedBlobId` exactly. A different committed blob is a `FAIL` -
   this is the primary, canonical-object-based decision.
4. Read the **exact canonical bytes** of that blob directly from the Git
   object database via `git cat-file blob <id>` - captured through the
   child process's raw `StandardOutput.BaseStream`, never through a
   `StreamReader`/text pipeline, so no newline translation or character
   re-encoding is ever applied on any platform or PowerShell version.
5. Compute SHA256 over those exact canonical bytes and require it to
   equal the pinned `ExpectedSha256` exactly (a defense-in-depth
   cross-check independent of the blob-ID match in step 3). A mismatch
   is a `FAIL`.
6. Confirm the workflow path is clean in the working tree
   (`git status --porcelain -- <path>`). Git's own status computation
   already accounts for `core.autocrlf` normalization when comparing the
   working tree to the index, so a checkout-time line-ending conversion
   alone does **not** make this dirty - only a genuine, uncommitted
   local edit (staged or unstaged) does. Any such edit is a `FAIL`, even
   though the committed Git object is unchanged.
7. Only if all of the above hold is the result `PASS`. The working-tree
   SHA256 is still computed and shown in the PASS detail text purely for
   operator awareness (e.g. to explain a Windows CRLF difference) - it is
   never compared against anything to decide the result.

Every other rejection this exception mechanism already enforced is
unchanged: any other `.github/workflows/` file, `applications/`,
`applications_user/`, firmware source, `build/`, `dist/`, `toolchain/`,
or any other path outside `docs/`/`tools/` remains forbidden.

**Implementation notes, per the required constraints:**

- `Get-FileHash` is never called on the checked-out workflow file for the
  security decision - only for the diagnostic-only working-tree SHA256.
- `core.autocrlf` is never read or modified by this script.
- The reviewed workflow file itself is never rewritten, staged, or
  checked out by this script - all reads are via `git rev-parse` /
  `git cat-file`, which touch only the object database.
- `Get-CanonicalGitBlobBytes` uses a `System.Diagnostics.Process` with
  `RedirectStandardOutput` and reads `StandardOutput.BaseStream`
  directly into a `MemoryStream` - binary-safe on Windows PowerShell 5.1
  and PowerShell 7, Windows and Linux alike. The `MemoryStream` and
  `Process` objects are disposed in a `finally` block.
- No git command is ever asked to mutate the working tree or index for
  this check (no `add`, `checkout`, or line-ending normalization is run
  against the reviewed workflow).

## Regression-test results

`tools/pre_flash_safeguard_gate.tests.ps1` was extended with the
"Canonical Git Blob Integrity Fix" test block (Blob Tests A-M, plus one
byte-capture sanity check), run for real via `pwsh` in this session
against disposable scratch git repositories (created under the OS temp
directory, entirely outside this repository, and deleted after each
test):

| Test | Scenario | Result |
|---|---|---|
| Sanity | `Get-CanonicalGitBlobBytes` returns the exact original bytes of a known, independently-authored blob | `PASS` |
| Blob Test A | Canonical LF repository blob: reviewed blob and canonical SHA match | `PASS` |
| Blob Test B | **Windows CRLF working tree**: repository blob unchanged; `git config core.autocrlf true` set for real and the file re-checked out, producing genuine CRLF working-tree bytes with a different SHA256; `git status --porcelain` still clean | `PASS`, decided from the canonical blob |
| Blob Test C | Committed workflow content modified (blob ID differs) | `FAIL` |
| Blob Test D | Same blob ID, but a deliberately wrong pinned `ExpectedSha256` (simulated config drift) | `FAIL` |
| Blob Test E | Dirty **unstaged** workflow modification (blob at HEAD unchanged, working tree dirty) | `FAIL` |
| Blob Test F | Dirty **staged** (but uncommitted) workflow modification | `FAIL` |
| Blob Test G | Unrelated workflow file added (not the pinned path) | `FAIL` |
| Blob Test H | Pinned workflow path missing at HEAD | `FAIL` |
| Blob Test I | Accepted baseline not an ancestor of HEAD | `BLOCKED` (never `PASS`) |
| Blob Test J | docs/tools-only descendant plus the exact pinned workflow blob | `PASS` |
| Blob Test K | `applications_user/` change | `FAIL` |
| Blob Test L | Canonical extraction failure (part 1: `Get-CanonicalGitBlobBytes` given a nonexistent object throws; part 2: the pinned file's loose Git object is removed from the object database while its blob ID still resolves via the tree - `Get-PinnedWorkflowExceptionResult` returns `FAIL` via its `catch` branch, never an uncaught exception and never a silent skip) | `FAIL` (both parts) |
| Blob Test M | Existing USB identity regressions remain intact: exact normal-mode ID passes, exact DFU ID passes recovery, camera DFU stays rejected | `PASS` / `PASS` / `BLOCKED` |

**All 30 assertions in `tools/pre_flash_safeguard_gate.tests.ps1` passed**
(the pre-existing 6 device-identity tests, the pre-existing 6 Ancestry
Tests A-F updated to carry the new `ExpectedBlobId` field, the real-repo
assertion, and the 14 new canonical-blob-integrity assertions above).

**Blob Test B is the load-bearing proof for this fix.** `core.autocrlf`
is implemented in Git's own checkout/smudge logic and is not gated by the
host OS, so setting it and re-checking out the file in this Linux sandbox
reproduces the exact byte-level behavior a Windows checkout exhibits -
this is a real exercise of Git's own CRLF-conversion code path, not a
hand-rolled simulation of it.

**Real-repository verification (this Linux sandbox)**: re-running
`tools/pre_flash_safeguard_gate.ps1 -Mode Preflight` against this
repository's actual current HEAD after the fix still reports
`PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND
PINNED FINALIZATION WORKFLOW` for the "Baseline ancestry and diff-scope
verification" check, confirming the canonical-blob path continues to
work correctly for the real pinned file, not only for scratch fixtures.

## Limitations

- This fix was verified against a real Linux checkout, and against a
  **real reproduction** of `core.autocrlf=true` behavior obtained by
  setting that Git config option and re-checking out the file in this
  same Linux sandbox (Blob Test B). It was **not** verified on an actual
  Windows machine in this session - no Windows environment exists here.
  The evidence in "CURRENT VERIFIED EVIDENCE" at the top of this phase's
  mission (the observed Windows working-tree SHA256 and the manual
  diagnostic result) was supplied by the project owner from their own
  real Windows session, not independently reproduced on real Windows
  hardware by this agent.
- The working-tree SHA256 remains useful only as a diagnostic explanation
  for operators (e.g. "this looks different, and here's why that's
  fine") - it carries no security weight and must never be used to
  decide PASS/FAIL in any future change to this script.
- This fix is scoped to the one pinned finalization-workflow exception
  path. It does not change artifact hash verification (`firmware.dfu` /
  updater `.tgz`), which hashes real downloaded binary files that were
  never subject to Git checkout conversion in the first place, and
  remains on `Get-FileHash` intentionally.
- `tools/final_hardware_gate.ps1` was not touched in this phase - it has
  no pinned-workflow-exception logic of its own.

## Files changed by this fix

- `tools/pre_flash_safeguard_gate.ps1` - `Get-CanonicalGitBlobBytes`,
  `Get-Sha256OfBytes`, and `Get-PinnedWorkflowExceptionResult` added;
  `$PinnedWorkflowExceptions` extended with `ExpectedBlobId`;
  `Get-BaselineAncestryDiffResult`'s pinned-exception branch now calls
  `Get-PinnedWorkflowExceptionResult` instead of hashing working-tree
  bytes directly. `Get-LineSha256` (used for firmware/updater artifact
  hash verification, which is intentionally unaffected) is unchanged.
- `tools/pre_flash_safeguard_gate.tests.ps1` - Blob Tests A-M and a
  byte-capture sanity check added; the pre-existing Ancestry Tests B, C,
  and D updated to supply `ExpectedBlobId` (mandatory on the corrected
  function) alongside `ExpectedSha256`.
- `docs/PRE_FLASH_CANONICAL_BLOB_INTEGRITY_FIX.md` - this document.
