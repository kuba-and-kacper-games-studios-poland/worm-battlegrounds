---
title: "One Punch cooldown 0 → 5: usable from the player's 6th turn"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/OnePunch.lua
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.** The owner asked to "make one punch only accessible after 5 turns". Its `Cooldown` went from 0 to 5.
Strong weapons start a match on their cooldown (Combat's `Uses.Reset`), so One Punch is locked for the player's first
5 turns and usable on their 6th. It still has 1 use a match, so it never cools down again after that.

**Where.** `Cooldown = 5` in `Arsenal/Data/Weapons/OnePunch.lua`. The loadout bar shows the turns left from the
Replicator's `Cooldown_OnePunch`, as it does for the other weapons with a cooldown. The bots read the same row
(their `Sim` mirrors `Uses.Reset`).

**How to check.** Take One Punch into a match: its box is locked with a turn count, which drops by one each of your
turns and frees it on your 6th. Checked in Studio on 2026-11-13 that the synced row reads `Cooldown = 5`. A whole match
with One Punch in the loadout wasn't played. The rule itself is the one Grenade (1), Cluster Bomb (2) and Homing
Missile (3) already use.

**For the wiki.** Arsenal: One Punch's cooldown is 5 turns, and it can't be used before the player's 6th turn.
