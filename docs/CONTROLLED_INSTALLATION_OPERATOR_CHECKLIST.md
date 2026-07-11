# Controlled Installation Operator Checklist

**Status: BLANK CHECKLIST — EVERY ITEM BELOW IS UNCHECKED BY DEFAULT.
No installation has been performed. This is a printable companion to
`docs/CONTROLLED_INSTALLATION_PLAN.md`, for a human operator to mark up
during real execution on real hardware.**

Mark each item exactly one of: `PASS`, `FAIL`, `BLOCKED`, `NOT RUN`. Do
not leave an item blank once execution reaches it — use `NOT RUN` if a
step was skipped because an earlier stop condition was hit. Use the
notes field for any observation, however small.

Reference: build baseline `86265727b5b8cfce5086eb88f8bb93d0169ab9a9`, CI
run `29068148596`, updater `flipper-z-f7-update-local.tgz` (2,891,859
bytes, SHA256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55`),
firmware recovery `firmware.dfu` (862,833 bytes, SHA256
`e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`).

## Preconditions

| Item | Result | Notes |
|---|---|---|
| Windows PC available and designated | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper installed | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Known-good USB data cable available | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Battery sufficiently charged | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| microSD inserted and recognized | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Device currently boots normally | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper sees device in normal mode | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Verified artifact directory available | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| DFU/recovery path previously demonstrated | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Operator comfortable proceeding | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Backups

| Item | Result | Notes |
|---|---|---|
| qFlipper-supported backup completed | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Timestamped microSD backup completed | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Current firmware version recorded | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper version recorded | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Device name recorded | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Normal-mode USB InstanceId recorded | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Backup path(s) recorded | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Recovery artifact (firmware.dfu) confirmed present/hash-matched | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Fresh (just-in-time) hash and safeguard checks

| Item | Result | Notes |
|---|---|---|
| `-Mode Preflight` | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| `-Mode ArtifactHashVerify` — updater hash | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| `-Mode ArtifactHashVerify` — firmware recovery hash | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| `-Mode DeviceDetect` | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Normal USB identity (pre-install)

| Item | Result | Notes |
|---|---|---|
| Windows detects exact `VID_0483&PID_5740` | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Human authorization

| Item | Result | Notes |
|---|---|---|
| Operator typed the exact authorization phrase | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## qFlipper package selection

| Item | Result | Notes |
|---|---|---|
| Correct device confirmed in qFlipper | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| "Install from file" selected | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Only `flipper-z-f7-update-local.tgz` selected | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Folder path, filename, size verified before confirming | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| `firmware.dfu` NOT selected | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Installation progress

| Item | Result | Notes |
|---|---|---|
| Installation accepted by qFlipper (not rejected) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| USB remained connected throughout | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper remained open throughout | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| microSD remained inserted throughout | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper reported completion | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## First boot

| Item | Result | Notes |
|---|---|---|
| Device powers on | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Desktop appears | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Buttons respond | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| No boot loop | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| No crash screen | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| No freeze | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| No unexpected recovery-mode entry | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Normal USB return (post-install)

| Item | Result | Notes |
|---|---|---|
| USB reconnects normally | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| qFlipper reconnects and detects normal mode | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Windows detects exact `VID_0483&PID_5740` | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Installed firmware/version info visible | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## microSD recognition (post-install)

| Item | Result | Notes |
|---|---|---|
| microSD recognized after install | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Reboot

| Item | Result | Notes |
|---|---|---|
| One additional normal reboot passes | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Core smoke checks (only after core boot PASS)

| Item | Result | Notes |
|---|---|---|
| Desktop navigation | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Main Menu opens | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Settings opens | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Storage page opens | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| microSD status shown correctly | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| About/System information opens | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| USB reconnect (if tested) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Backlight/volume controls (if available) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Clean exit from all menus | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Low-risk app launch checks

| App | Visible | Launches | Renders | Back exits | No crash | No freeze | No reboot | Notes |
|---|---|---|---|---|---|---|---|---|
| `programmer_calc` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `vin_decoder` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `quadratic_solver` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `sudoku` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `chess` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `2048` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `minesweeper_redux` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `resistors` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `crypto_dictionary` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |
| `fap_boilerplate` | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | ( ) | |

(Mark each cell PASS/FAIL/BLOCKED/NOT RUN; leave unchecked `( )` until
observed.)

## Recovery requirement

| Item | Result | Notes |
|---|---|---|
| Recovery was required | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Exact DFU identity `VID_0483&PID_DF11` confirmed (if recovery attempted) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Recovery authorization phrase typed exactly (if recovery attempted) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Official/stable firmware recovery completed (if recovery attempted) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Normal boot confirmed after recovery (if recovery attempted) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |
| Internal data loss occurred (if recovery attempted) | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

## Final disposition

| Item | Result | Notes |
|---|---|---|
| Final classification recorded in `docs/CONTROLLED_INSTALLATION_RESULTS.md` | ( ) PASS ( ) FAIL ( ) BLOCKED ( ) NOT RUN | |

---

**As distributed, every item above is unchecked and this checklist
reflects no real execution.** Fill it in only while performing the real
procedure in `docs/CONTROLLED_INSTALLATION_PLAN.md`.
