# Phase 2A — Rollback Plan

Every import this phase is its own commit on `integration/phase2a-first-batch`, with
no cross-app dependencies, so rollback is per-app or whole-branch, at your choice.

## Whole-branch rollback (discard everything from this phase)

Since this branch hasn't been merged anywhere, the simplest full rollback is to just
not push it, or delete it if already pushed:

```
git branch -D integration/phase2a-first-batch          # local
git push origin --delete integration/phase2a-first-batch   # remote, if pushed
```

This has zero effect on `claude/flipper-custom-firmware-cxrcer` (the documentation
branch) — they share no history.

## Per-commit rollback (revert to just before a specific app, keep the rest)

Commit sequence (oldest to newest):

```
64b3cdd  base (Unleashed, unmodified)
f7fd2b7  + network_subnet
bba5201  + programmer_calc
64f7560  + vin_decoder
412d385  + flipper95
42e08a9  + chess
```

To drop only the *last* app and keep everything before it:

```
git checkout integration/phase2a-first-batch
git reset --hard <commit-before-the-one-to-drop>
```

To drop a specific app **without** losing later commits (e.g., remove
`programmer_calc` but keep `vin_decoder`/`flipper95`/`chess`), use an interactive
rebase to drop that one commit — not attempted here since none of this phase's apps
need dropping, but noted for completeness:

```
git rebase -i 64b3cdd   # mark the target commit as "drop"
```

## Per-app manual rollback (exact files/entries to remove)

Use this if you'd rather remove an app's files directly without rewriting commit
history (e.g., to un-import one app going forward while keeping the historical
commits intact for the record).

### `network_subnet`

- Remove: `applications_user/network_subnet/` (25 files)
- Revert in `applications_user/.gitignore`: remove the two lines
  `!/network_subnet/` and `!/network_subnet/**`
- No assets outside that directory; no base-firmware files were touched

### `programmer_calc`

- Remove: `applications_user/programmer_calc/` (26 files, includes its own `LICENSE`)
- Revert in `applications_user/.gitignore`: remove `!/programmer_calc/` and
  `!/programmer_calc/**`
- No assets outside that directory

### `vin_decoder`

- Remove: `applications_user/vin_decoder/` (10 files, includes its own `LICENSE`)
- Revert in `applications_user/.gitignore`: remove `!/vin_decoder/` and
  `!/vin_decoder/**`
- No assets outside that directory

### `flipper95`

- Remove: `applications_user/flipper95/` (9 files)
- Revert in `applications_user/.gitignore`: remove `!/flipper95/` and
  `!/flipper95/**`
- No assets outside that directory. Its `fap_libs=["mbedtls"]` reference is scoped
  to its own `application.fam` — removing the app directory removes the reference;
  `lib/mbedtls` itself is part of the base and is not affected either way.

### `chess`

- Remove: `applications_user/chess/` (40 files, includes its own `LICENSE` and the
  two bundled third-party libraries)
- Revert in `applications_user/.gitignore`: remove `!/chess/` and `!/chess/**`
- No assets outside that directory

## After any manual rollback

```
git status                 # confirm only the intended files changed
git add -A
git commit -m "Roll back <app>: <reason>"
```

Rebuilding (once local build access exists) after any rollback should reproduce
whatever the state was immediately before that app was added — there is no shared
mutation between apps (each only adds its own directory plus its own two-line
`.gitignore` exception).

## What rollback does *not* need to touch

No core firmware file was modified by any of the 5 imports — `applications_user/`
is the only directory touched besides the `.gitignore` scoped exceptions, per the
project's rule to avoid core changes unless absolutely required (none were). Rolling
back any or all of these apps never requires touching `applications/`, `furi/`,
`targets/`, `lib/`, or any build-system file.
