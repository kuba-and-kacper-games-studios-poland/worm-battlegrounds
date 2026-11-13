---
title: "Pictures, models and effects load in the background from the first second (AssetsPreload)"
date: 2026-11-13
status: open
kind: added
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main/0_AssetsPreload/Client.lua
  - worm-battlegrounds-game/src/modules/Main/0_AssetsPreload/Settings.lua
---

**What changed.** A new client module, `AssetsPreload` (folder `src/modules/Main/0_AssetsPreload`, no API), starts
downloading the game's content as soon as the player's client has started, so guis, crate openings and weapons show
their backgrounds, icons and models at once the first time. On a thread of its own it hands
`ContentProvider:PreloadAsync`, in turn: every gui (open or not), the asset ids in the game's data and settings
(Inventory's items, Arsenal's weapons, Crates' rows, every module's settings except Rarity's, whose icons are the
template's placeholders), then the whole asset folder (crate, weapon and skin models, snail animations, Vfx effects,
the lobby stage). Settings: `ID_PATTERN` `^rbxassetid://%d+$`, `SCAN_DEPTH` 8, `SKIP_SETTINGS` `{ "Rarity" }`.

**Where.** `Main/0_AssetsPreload/Client.lua` (`_preload`, `_collectIds`).

**How to check.** Play in Studio: on a fresh cache ContentProvider's queue jumped to about 250 requests at start and
emptied within seconds while the lobby stayed usable; the first Crates opening then shows its models at once. Output
shows one failing id, `rbxassetid://135260262766812` ("No asset content representation"), from an asset in the place
itself, not from this module's lists.

**For the wiki.** Architecture: loading, the preload at start.
