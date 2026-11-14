---
title: "Lava on the map burns: 2 s, then 8 health a second, 3 times (24)"
date: 2026-11-13
status: open
kind: added
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Hazards.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Potions.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Move.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** The owner: Volcano Isle's lava on the map (not the rising sea) "should apply burn effect to you
when you touch and you can move for 2s and then your turn ends and you'll loose like 5-10hp every second for few
seconds". Before, that lava did nothing (only the sea knocked out). Now a snail that dips into lava that doesn't knock
it out (the chamber pool at Y 27–28 and the crater pool at Y 63–67, or the lava sea seeping into a small hole) gets a
`Burning` attribute and a flame aura. `BURN_DELAY` (2) s later it loses `BURN_DAMAGE` (8), which ends its turn if it's
playing and hasn't fired (getting hurt ends the turn), then 8 more every `BURN_INTERVAL` (1) s, `BURN_TICKS` (3) hits,
24 in all. One burn per dip: staying in the pool, or dipping again while it burns, adds nothing, so a snail left in
lava can walk out on its next turn. Kill credit goes to whoever last hurt or pushed it.

**Where.** `Module._burn` and the `dipped` check in `_checkSnail` (`Snails/Scripts/Server/Hazards.lua`); `BURN_*` and
`AURAS` (renamed from `POTION_AURAS`, now with `Burning` → `Aura_Burning`) in Snails' `Settings.lua`; Arena's new
`IsInLava(position, radius)`, also used by `IsFree` so no snail drops in lava. The aura prefab
`PREFAB | Aura_Burning` (flames, sparks, smoke; a placeholder) is in the place's `Vfx`, not in code. Bots: `Move`
never stands or lands in lava; `Predict.GetEffects` adds the 24 to a snail a shot throws or drops into lava.

**How to check.** Measured in Studio on Volcano Isle, 2026-11-13: a bot dropped into the chamber pool was `Burning` in
0.1 s, lost 8 at 2.1 s as its turn ended, then 8 at 3.1 s and 4.1 s (200 → 176), and burned no more while it stayed;
the aura's emitters ran on the client.

**For the wiki.** Volcano Isle: its lava pools burn (numbers above); a status line for "Burning" wherever snail
states are listed; Bots avoid lava.
