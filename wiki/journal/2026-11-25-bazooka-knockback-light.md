---
title: "Bazooka knockback halved: 45 → 22.5"
date: 2026-11-25
status: open
kind: changed
pages: ["Bazooka", "Weapons"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Bazooka.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/_types.lua
---

**What changed.** The owner: "50% less knockback from bazooka rockets". A rocket throws snails half as hard as before.
Arsenal's `KNOCKBACK` table gains a `Light` step, 22.5, half of `Medium` (45), and the Bazooka row's `Knockback`
went from `"Medium"` to `"Light"`. Every other weapon keeps its step.

**Where.** `KNOCKBACK.Light` in Arsenal's Settings; `Knockback = "Light"` in `Data/Weapons/Bazooka.lua`; the
`Arsenal_Knockback` alias in `_meta/_types.lua` and the Arsenal README list the new step.

**How to check.** In a match, a direct rocket hit on a snail on flat ground throws it about half as far as a Grenade
of the same damage did before.

**For the wiki.** Bazooka: knockback Light (22.5) in its stats, and a History line. Weapons: the knockback steps table
gets Light.
