# RFC 3: Unified Search and Command Palette

Status: **PROPOSED** (design only — nothing in this RFC has been
implemented in this phase).

## Problem

As the app count and settings surface grow across firmware profiles,
navigating nested menus to find a specific app, setting, file, or
recently-used item becomes slower than it should be. A unified search
surface — a single entry point that searches across categories at once
— is a genuine differentiator official/forked firmware generally lacks
(navigation there is menu-tree-only).

## Scope of what is searchable

| Category | Source of truth |
|---|---|
| Applications | RFC 1 Health Center inventory (`app_id`, `display_name`, `category`) |
| Settings | A static, versioned index of setting names/paths, regenerated when settings change |
| Files | The device's own storage/loader APIs — search is a live filesystem query, not a cached index of file contents |
| Safe local commands | A explicit allow-list of local, non-destructive commands (e.g. "open Settings," "show About," "reboot") — never a free-form command execution surface |
| Favorites | User-configured list, stored like any other user preference |
| Recently used | A bounded, rolling list (e.g. last 10) of opened apps/files, evicted oldest-first |

## Explicit non-goals / safety boundary

- The command palette is **not** a shell or scripting console. "Safe
  local commands" is a fixed, reviewed allow-list, not an arbitrary
  command-execution surface — this avoids recreating a BadUSB/HID-like
  capability through the back door.
- Search never triggers a radio transmission, emulation, or write
  operation merely by matching a query to an app name — selecting a
  search result opens that app exactly as if the user had navigated to
  it manually; the search surface adds no new capability, only a faster
  path to the same, already-reviewed entry points.
- File search surfaces filenames/paths, not arbitrary file content
  indexing that could leak sensitive stored data (e.g. NFC/RFID dumps,
  BadUSB scripts) into a shared results view without the user
  deliberately opening that file.

## Ranking approach (proposed, not tuned)

1. Exact prefix match on display name (highest priority).
2. Fuzzy/substring match on display name.
3. Category-name match (e.g. typing "game" surfaces all Games-category
   apps).
4. Recently-used and favorites get a ranking boost within their own
   match tier, not an unconditional top-of-list placement (a user
   should still be able to find an app they haven't used yet).

Exact scoring weights are an implementation detail to be tuned once a
real prototype exists — not fabricated here as if already measured.

## Memory/performance considerations

- The searchable index (app/settings names) is small and can be held
  fully in RAM at idle — its size is bounded by the Health Center's own
  app count, which this project's resource budgets already track.
- File search must not eagerly index the entire microSD on every
  keystroke; a real implementation should query the filesystem
  incrementally/lazily as the user types, consistent with this
  project's low-memory-profile discipline (see RFC 2's own note on the
  same concern).

## Relationship to other RFCs

- RFC 1 (Health Center) is the source of truth for the app-search
  index.
- RFC 4 (Hardware and Module Compatibility Hub) entries could
  eventually be a searchable category too (e.g. "search: GPIO modules"),
  once that hub itself has real content.

## Proof-of-concept plan (not built in this phase)

1. Define the static settings-index format and hand-populate it from
   the current 20-app baseline plus the device's known built-in
   settings screens (no device interaction required for this step).
2. Prototype ranking logic as a pure, hardware-independent function
   (unit-testable exactly like `tools/hardware_app_tester`'s own
   discovery/profile logic) before any on-device UI work begins.
3. On-device UI and file-search-against-real-storage prototyping is
   deferred to a phase where real hardware execution is possible.
