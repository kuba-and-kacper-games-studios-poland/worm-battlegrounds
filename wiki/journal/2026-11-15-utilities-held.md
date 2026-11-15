---
title: "Utilities are held, then used with a press"
date: 2026-11-15
status: open
kind: changed
pages: ["Utilities", "Medkit", "Bandage"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua

---

**What changed.** Picking a Medkit, Bandage, potion, the Jetpack or the Parachute no longer uses it at once: the
snail holds it (no aim shows), and the next press on the screen uses it (a click, a tap, RT on a pad; Y on a pad picks
it). Then the snail takes back the weapon it held before, or the Bazooka when that one has no uses left or is cooling
down. The owner: "when you click it it equips and the worm is holding it, and when you click on screen it's used".

**Where.** MatchHud's `LoadoutBar.Select` (sends `Combat_Select`, sets `HeldItem`) and `LoadoutBar.UseHeld` (fires
`Combat_UseUtility`, then reselects `lastWeapon` or `"Bazooka"`); `Aim._onInputBegan` calls `UseHeld` while a utility
is selected.

**How to check.** Pick the Medkit: the snail holds it, no aim. Click the arena: health +100, the Medkit cools down
and the snail holds the weapon from before. Only the Medkit was tested in Studio.

**For the wiki.** Utilities (and each utility's page): how to use one, two steps now.
