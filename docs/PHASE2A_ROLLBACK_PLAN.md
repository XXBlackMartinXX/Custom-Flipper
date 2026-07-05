# Phase 2A — Rollback Plan

**v3** — updated for the `chess` SAM-removal cleanup commit (`6359f87`); see
`PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` and the integration log's cleanup entry. v2
updated commit hashes for the rebuilt branch (see `PHASE2A_INTEGRATION_LOG.md` for
why v1 was replaced).

Every import this phase is its own commit on `integration/phase2a-first-batch`, with
no cross-app dependencies, so rollback is per-app or whole-branch, at your choice.

## Whole-branch rollback (discard everything from this phase)

```
git branch -D integration/phase2a-first-batch          # local
git push origin --delete integration/phase2a-first-batch   # remote, if pushed
```

Zero effect on `claude/flipper-custom-firmware-cxrcer` (the documentation branch) —
they share no history.

## Per-commit rollback (revert to just before a specific app, keep the rest)

Commit sequence (oldest to newest, **v2 hashes** — v1's `64b3cdd`..`2f2e208` no
longer exist on this branch after the force-push):

```
4c95acb  base (Unleashed, proper git submodules)
749c9ab  + network_subnet
e4dd48f  + programmer_calc
d18cd29  + vin_decoder
7ca2d5f  + flipper95
202245e  + chess
6b5cc53  + Phase 2A docs (v2)
140ec5c  + build PASS + SAM license review docs
6359f87  + chess: SAM voice feature removed (cleanup, not a new app)
```

To drop only the *last* app and keep everything before it:

```
git checkout integration/phase2a-first-batch
git reset --hard <commit-before-the-one-to-drop>
```

To drop a specific app without losing later commits, use an interactive rebase to
mark that one commit as "drop":

```
git rebase -i 4c95acb
```

## Per-app manual rollback (exact files/entries to remove)

Unchanged from v1 — the app content itself didn't change, only the base underneath:

### `network_subnet`
- Remove: `applications_user/network_subnet/` (26 files)
- Revert in `applications_user/.gitignore`: remove `!/network_subnet/` and
  `!/network_subnet/**`

### `programmer_calc`
- Remove: `applications_user/programmer_calc/` (37 files, includes its own `LICENSE`)
- Revert in `applications_user/.gitignore`: remove `!/programmer_calc/` and
  `!/programmer_calc/**`

### `vin_decoder`
- Remove: `applications_user/vin_decoder/` (10 files, includes its own `LICENSE`)
- Revert in `applications_user/.gitignore`: remove `!/vin_decoder/` and
  `!/vin_decoder/**`

### `flipper95`
- Remove: `applications_user/flipper95/` (9 files)
- Revert in `applications_user/.gitignore`: remove `!/flipper95/` and
  `!/flipper95/**`
- `fap_libs=["mbedtls"]` is scoped to its own `application.fam`; removing the app
  directory removes the reference. `lib/mbedtls` (now a real submodule) is part of
  the base and unaffected either way.

### `chess`
- Remove: `applications_user/chess/` (35 files as of `6359f87`, confirmed by direct
  count — 4 SAM-related files were deleted from the original import in the cleanup
  commit; includes its own `LICENSE` and the remaining `smallchesslib` third-party
  library)
- Revert in `applications_user/.gitignore`: remove `!/chess/` and `!/chess/**`
- **To roll back only the SAM-removal cleanup** (i.e., keep `chess` but restore the
  SAM voice feature) rather than removing the whole app: `git revert 6359f87` on
  top of the current tip, or `git show 202245e:applications_user/chess/sam/stm32_sam.h`
  etc. to recover the pre-removal file contents from history. **Not recommended** —
  that would reintroduce the unclear-license code this cleanup exists to remove.

## Rolling back the base itself (if the submodule approach needs further changes)

Unlike the 5 app commits, the base commit (`4c95acb`) touches `.gitmodules` and 12
submodule gitlinks. Rolling it back means:

```
git submodule deinit --all -f
git reset --hard <commit-before-base>   # only if going back before the base entirely
```

Given this base is what a real local build now needs to succeed against, this
should only be done if a *different* base-construction approach is required — not
as a routine rollback.

## After any manual rollback

```
git status                 # confirm only the intended files changed
git add -A
git commit -m "Roll back <app>: <reason>"
```

## What rollback does *not* need to touch

Unchanged from v1: no core firmware file was modified by any of the 5 imports —
`applications_user/` (plus its own `.gitignore`) is the only thing touched besides
the base commit's submodule setup.
