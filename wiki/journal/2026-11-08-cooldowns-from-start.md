---
title: "Items with a cooldown start the match on it"
date: 2026-11-08
status: open
kind: changed
pages: ["Arsenal", "Loadout"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
---

**What changed.** An item with a cooldown now waits that cooldown from the start of the match, not only after its
first use, so nobody opens with the strongest weapons. Counted in the player's own turns:

| Item | Cooldown | First usable on the player's |
| --- | --- | --- |
| Grenade | 1 | 2nd turn |
| Cluster bomb, Dynamite, Spider bomb | 2 | 3rd turn |
| Homing missile | 3 | 4th turn |

Items with no cooldown (Bazooka, guns, Baseball bat, One punch, Spartan spear, Variety and Black hole grenades,
utilities) are ready on the first turn, as before.

**Where.** `Uses.Reset` sets `Cooldown_<item>` to `Cooldown + 1` at the Drop phase, the same as `Uses.Take` after a
use; each of the player's turns counts one off. The bots' self-play `Sim._seat` does the same, so training matches the
game. Admin `combat give` and `combat refill` still clear it.

**How to check.** Studio match (2026-11-08) with Grenade, Homing missile and Variety grenade equipped: after two of the
player's turns, `Cooldown_Grenade` was 0, `Cooldown_HomingMissile` 2, `Cooldown_VarietyGrenade` 0 in the player's
`Combat` Replicator folder.

**For the wiki.** Arsenal: each weapon's cooldown applies from the start of a match. Loadout: the table above.
