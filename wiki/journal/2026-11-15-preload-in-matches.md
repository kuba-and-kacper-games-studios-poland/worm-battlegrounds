---
title: "Matches: the background asset preload no longer fails on Crates"
date: 2026-11-15
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main/0_AssetsPreload/Client.lua
---

**What changed.** Every client on the match place logged `AssetsPreload:59: attempt to index nil with 'GetAll'`: the
preload read `I.G_Crates`, but Crates runs only in the lobby (and the Studio map), so on the Match map the preload
stopped there and never loaded the settings' pictures or the asset folder. It now skips Crates' rows where Crates
isn't loaded.

**Where.** `Module._preload` in `Main/0_AssetsPreload/Client.lua`.

**How to check.** In a match, the console shows no AssetsPreload error. Tested in Studio on the Match map
(`Ume_StudioMapId = "Match"`): no error.

**For the wiki.** Architecture's loading notes, if they describe the preload: in a match it skips Crates.
