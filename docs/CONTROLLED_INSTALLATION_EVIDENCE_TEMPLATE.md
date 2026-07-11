# Controlled Installation Evidence Template

## TEMPLATE ONLY — INSTALLATION NOT PERFORMED

**Every value below is a placeholder. This document contains no real
observations. It exists to be copied and filled in, honestly and only
after the fact, by whoever actually executes
`docs/CONTROLLED_INSTALLATION_PLAN.md` on real hardware.**

Do not fill in any field with an assumed, expected, or invented value.
Leave a field explicitly marked `<not observed>` if the corresponding
step was skipped or not reached.

---

## Session metadata

| Field | Value |
|---|---|
| Date/time (local, with timezone) | `<placeholder>` |
| Operator | `<placeholder>` |
| Windows version | `<placeholder>` |
| qFlipper version | `<placeholder>` |
| Repository HEAD (commit SHA) | `<placeholder>` |
| Accepted baseline commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` |
| Accepted CI run | `29068148596` |

## Artifact evidence

| Field | Value |
|---|---|
| Updater filename | `<placeholder>` |
| Updater size (bytes) | `<placeholder>` |
| Updater SHA256 | `<placeholder>` |
| Firmware recovery filename | `<placeholder>` |
| Firmware recovery size (bytes) | `<placeholder>` |
| Firmware recovery SHA256 | `<placeholder>` |

## Device identity evidence

| Field | Value |
|---|---|
| Device normal-mode `InstanceId` (minimize sensitive serial detail) | `<placeholder>` |
| DFU/recovery-mode `InstanceId` (minimize sensitive serial detail) | `<placeholder>` |
| Current firmware version before install | `<placeholder>` |
| Device name (as configured in qFlipper) | `<placeholder>` |

## Backup evidence

| Field | Value |
|---|---|
| qFlipper backup path | `<placeholder>` |
| microSD backup path | `<placeholder>` |
| Backup completion confirmed (yes/no) | `<placeholder>` |

## Installation outcome

| Field | Value |
|---|---|
| Human authorization phrase typed exactly (yes/no) | `<placeholder>` |
| qFlipper result (accepted / rejected / crashed / other) | `<placeholder>` |
| qFlipper log path | `<placeholder>` |
| Installation began (yes/no) | `<placeholder>` |
| Installation completed per qFlipper (yes/no) | `<placeholder>` |

## Boot evidence

| Field | Value |
|---|---|
| Device powered on after install (yes/no) | `<placeholder>` |
| Desktop appeared (yes/no) | `<placeholder>` |
| Buttons responded (yes/no) | `<placeholder>` |
| Boot loop observed (yes/no) | `<placeholder>` |
| Crash screen observed (yes/no) | `<placeholder>` |
| Freeze observed (yes/no) | `<placeholder>` |
| Unexpected recovery-mode entry observed (yes/no) | `<placeholder>` |
| microSD recognized after install (yes/no) | `<placeholder>` |
| USB reconnected normally (yes/no) | `<placeholder>` |
| qFlipper reconnected in normal mode (yes/no) | `<placeholder>` |
| Windows detected exact `VID_0483&PID_5740` post-install (yes/no) | `<placeholder>` |
| Installed firmware/version info visible (yes/no) | `<placeholder>` |
| One additional normal reboot passed (yes/no) | `<placeholder>` |

## Core smoke check results

| Field | Value |
|---|---|
| Desktop navigation | `<placeholder>` |
| Main Menu | `<placeholder>` |
| Settings | `<placeholder>` |
| Storage page | `<placeholder>` |
| About/System information | `<placeholder>` |
| USB reconnect (if tested) | `<placeholder>` |
| Backlight/volume controls (if available) | `<placeholder>` |
| Clean exit from menus | `<placeholder>` |

## Low-risk app check results

| App | Visible | Launches | Renders | Back exits | No crash | No freeze | No reboot | Notes |
|---|---|---|---|---|---|---|---|---|
| `programmer_calc` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `vin_decoder` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `quadratic_solver` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `sudoku` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `chess` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `2048` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `minesweeper_redux` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `resistors` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `crypto_dictionary` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |
| `fap_boilerplate` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` | `<placeholder>` |

## Errors and warnings

| Field | Value |
|---|---|
| Any errors encountered | `<placeholder>` |
| Any warnings encountered | `<placeholder>` |
| Log paths (qFlipper, Windows Event Viewer, etc.) | `<placeholder>` |

## Recovery

| Field | Value |
|---|---|
| Recovery required (yes/no) | `<placeholder>` |
| Recovery authorization phrase typed exactly (yes/no) | `<placeholder>` |
| Recovery outcome | `<placeholder>` |
| Internal data loss occurred (yes/no) | `<placeholder>` |

## Final classification

| Field | Value |
|---|---|
| Final classification (must be one of the values defined in `docs/CONTROLLED_INSTALLATION_PLAN.md` / the controlling mission) | `<placeholder>` |
| Release status | `TEST-READY ONLY / NOT RELEASE-READY` (unchanged until a separate, explicit release decision is made) |
| Next recommended action | `<placeholder>` |

---

**Reminder: this file, as committed, is a template. A real evidence
document derived from this template must not be committed with any
field still reading `<placeholder>` for a step that was actually
reached during execution — either fill it in honestly or mark it
`<not observed>` if genuinely skipped.**
