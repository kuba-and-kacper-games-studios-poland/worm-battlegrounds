---
title: "Ponds hurt like Worms' poison: 5 every turn while the head is under, never below 1"
date: 2026-11-12
status: open
kind: added
pages: ["Turns", "Match modes & maps", "Desert"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** At the end of every turn, whoever's turn it was, each snail in play with its head under a liquid that doesn't
knock it out (a pond on its own, like Desert's oasis) loses 5 health, with the damage number popping as usual. A snail with only its
body under, its head above the surface, takes nothing. Like Worms
Armageddon's poison, it never takes a snail below 1 health: a pond weakens a snail, and something else has to finish
it. The sea still knocks snails out as before. It counts as a hit, so the next turn waits 3 s after it. (Worms has no
such damage: its water drowns at once. The owner picked the poison rule, after a first version that took 3 to 7 at the
end of the snail's own turn.)

**Where.** Match's `Turns._hurtUnderwater` (every alive snail whose head's top, `UNDERWATER_HEAD_HEIGHT` 1.6 studs over its ball's centre,
where Classic's eyestalks start in its rest pose, is in `I.Arena.GetLiquid`), called at
the start of each turn's settle; `UNDERWATER_DAMAGE` 5 in Match's Settings.

**How to check.** On Desert, leave a snail in the oasis with its head under: it loses 5 at the end of every turn until it's at 1, and stays
there. Not tried in play yet.

**Still unsure.** Bots don't avoid ponds yet (a bot change, only when the owner asks).

**For the wiki.** Turns or Desert: ponds take 5 a turn and can't knock a snail out.
