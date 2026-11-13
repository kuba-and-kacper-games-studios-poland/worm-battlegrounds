---
title: "A weapon that can't fire can't charge; Variety grenade cooldown 0 to 2"
date: 2026-11-13
status: open
kind: fixed
pages: ["Arsenal", "Variety grenade", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/VarietyGrenade.lua
---

**What changed.** A weapon with no uses left or on its cooldown no longer charges (it used to fill, then the server refused the shot, over and over). The Variety grenade has `Cooldown` 2 (was 0), so it also waits 2 of the player's turns before its first use.

**Where.** MatchHud's `LoadoutBar.IsReady`, checked in `Aim`'s may-shoot guards; the Variety grenade's row.

**How to check.** Select the Variety grenade at the start of a match: pressing fire does nothing until it's ready.

**For the wiki.** Variety grenade: its cooldown. Arsenal: weapons not ready don't charge.

**From.** The testers: "verity bomb doesnt have cooldown", "i couldnt shoot verity bomb, it kept charging again".
