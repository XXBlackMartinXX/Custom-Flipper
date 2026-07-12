# RFC 2: Smart App Packs

Status: **PROPOSED** (design only — nothing in this RFC has been
implemented in this phase).

## Problem

`CUSTOM_FULL` (see `MODULAR_FIRMWARE_PROFILES.md`) cannot scale
indefinitely as a single monolithic build, but users still want
convenient, themed groups of apps ("give me all the games," "give me
the ham-radio-adjacent tools") without hand-picking each `.fap` file.
Smart App Packs are a curated, versioned, installable grouping of
external FAPs (never built-in apps — see the profile design's
external-FAP default) that a user can install, enable/disable, and roll
back as a unit.

## Design

### Pack manifest

A pack is a small manifest file (not a binary bundle at rest — the
`.fap` files it references remain individually versioned artifacts):

```json
{
  "pack_id": "games-classic",
  "display_name": "Classic Games Pack",
  "pack_version": "1.0.0",
  "apps": [
    {"app_id": "chess", "min_version": "1.0.0", "fap_sha256": "<pinned>"},
    {"app_id": "sudoku", "min_version": "1.0.0", "fap_sha256": "<pinned>"},
    {"app_id": "2048_improved", "min_version": "1.0.0", "fap_sha256": "<pinned>"},
    {"app_id": "minesweeper_redux", "min_version": "1.0.0", "fap_sha256": "<pinned>"}
  ],
  "dependencies": [],
  "minimum_firmware_api": "<version>",
  "estimated_flash_footprint_bytes": null,
  "estimated_sd_footprint_bytes": null
}
```

### Enable/disable behavior

Disabling a pack removes its apps' entries from the loader-visible menu
(or moves them to a "disabled" folder on microSD) **without deleting
the `.fap` files** — re-enabling is instant and does not require
re-downloading anything. This is a metadata-only operation; it never
touches internal flash or performs a destructive storage action.

### Dependency resolution

Packs may declare dependencies on other packs or on a minimum firmware
API version. Resolution rules:

- A pack that depends on a firmware API version higher than the
  installed firmware reports `BLOCKED - FIRMWARE API TOO OLD`, never
  silently installs a possibly-incompatible app.
- Circular pack dependencies are rejected at manifest-validation time
  (this is a straightforward, well-understood graph-cycle check —
  implementation detail, not re-derived here).
- A pack that depends on another pack that is not installed reports
  `BLOCKED - MISSING DEPENDENCY: <pack_id>`, and does not
  auto-install the dependency without explicit user confirmation.

### Version locking

Each app entry pins a `min_version` and a `fap_sha256`. Installing a
pack:

1. Verifies every referenced `.fap`'s SHA256 against the pinned value
   before copying it to the device (mirrors the canonical-hash
   discipline already proven in
   `tools/pre_flash_safeguard_gate.ps1`'s artifact verification).
2. Refuses to install (fail-closed) if any hash mismatches, rather than
   installing a possibly-tampered or differently-built `.fap`.

### Rollback

Every install operation records the pack's previous state (not
installed / installed-at-version-X) before making any change. Rollback
restores that exact prior state — this is a metadata operation over
already-verified `.fap` files, never a firmware reflash and never a
storage format.

### Integrity verification

Both at install time and periodically (e.g. on boot or on-demand),
installed pack apps' `.fap` files are re-hashed and compared to their
pinned `fap_sha256`. A mismatch is reported, never silently repaired or
re-downloaded automatically — repair requires the same kind of explicit
human confirmation this project's pre-flash safeguards already require
for firmware-level changes.

### Low-memory profile

Pack metadata itself is small (a JSON/CBOR manifest per pack, not the
`.fap` binaries), so the memory cost of the pack *system* is
independent of how many `.fap`s a pack references. The actual RAM/flash
cost of enabling a pack is the sum of its member apps' own costs,
tracked per-app in the RFC 1 Health Center's `memory_profile` field —
Smart App Packs does not introduce a new resource-accounting mechanism,
it reuses RFC 1's.

### Offline operation

All of the above — install, enable/disable, rollback, integrity
verification — operates entirely from files already present (on the
Windows host or the microSD card). No part of this design requires
network access at pack-install time; it is a metadata/hash-verification
system over local files, not a package-manager-with-a-registry system
in this initial design.

## Explicitly out of scope for this RFC

- A remote pack registry/marketplace. This RFC defines the pack format
  and local install mechanics only.
- Automatic pack updates. Any version change is a human-initiated
  install action, following the same authorization discipline as this
  project's firmware installation plan.

## Relationship to other RFCs

- RFC 1 (Health Center) supplies `state` (stable/experimental/blocked)
  used to decide what apps a pack may reference — a pack should not
  bundle a `blocked` app.
- RFC 6 (Upstream Intelligence) may propose pack manifest updates when
  it detects an upstream version bump, but never merges them
  automatically (per this project's "agents may propose findings but
  may not silently merge code" rule).

## Proof-of-concept plan (not built in this phase)

1. Hand-author 2-3 example pack manifests (e.g. "games-classic" above,
   a "calculators" pack) referencing the current 20-app baseline's real
   `application.fam`-declared appids and real, already-computed
   artifact hashes where available.
2. Write a manifest-validation script (schema + hash-format checks only
   — no device interaction) as a first, hardware-independent milestone.
3. Only after real hardware install/enable/disable is possible (this
   session has no such hardware), prototype the actual install/rollback
   mechanics against a real device.
