---
title: "Loadout bar: uses left show on each slot (x3), key numbers stay inside"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen", "Loadout"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
---

**What changed.** A loadout slot's uses left never showed: its label was 0 px tall. It now shows in the slot's
bottom-right corner as "x3" (a plain x: the kit's font, Londrina Solid, has no × sign and drew a box). Weapons
without a limit (the Bazooka) show nothing. The slot's key number (1–5, PC only) no longer spills 5 px past the
slot's right edge.

**Where.** `PREFAB | BarSlot` › `S_Uses` and `S_Key` in the MatchHud gui (corner badges sized by the slot:
`S_Key` half its width, `S_Uses` 0.6, both 0.4 of its height). `LoadoutBar._refreshBoxes` writes `x{uses}` from the
`Uses_<itemId>` attribute on Combat's replicator folder; `-1` uses shows nothing.

**How to check.** In a match with a limited weapon in the loadout (Airstrike, Jetpack): "x1"/"x3" in its slot's
corner, counting down as it's used. The MatchHud gui was exported into the place the same day.

**For the wiki.** Match screen → the loadout bar: each slot shows its uses left ("x3") and, on PC, its key.
