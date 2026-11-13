---
title: "Fall damage counts from where the snail last rose: a jetpack that catches a fall takes none"
date: 2026-11-13
status: open
kind: fixed
pages: ["Arsenal", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Hazards.lua
---

**What changed.** The owner said that using the jetpack, flying down and falling "few studs" gave far too much fall
damage. Fall damage was counted from the highest point since the snail last touched the ground. So a jetpack flight up
to 30 studs, a drop, and a catch by holding jump just above the ground was charged as a 30-stud fall: 21 damage.

Now the fall starts over every time the snail rises: a jump's top, or wherever the jetpack last pushed it up. Only the
last real drop counts. The numbers are unchanged: 1 health per stud above `SAFE_FALL_HEIGHT` (10), at most
`MAX_FALL_DAMAGE` (40). For a jump or a knockback the start is still the top of the arc, so nothing changes there.

**Where.** `Hazards._checkSnail` in Snails: `peaks[model]` restarts at the snail's height whenever it is higher than
the frame before. The bots' predictions (`Predict`, `Sim`) already measure from the top of an arc, so they're
unchanged.

**How to check.** In a match, use the jetpack, fly about 30 studs up, let go, and hold jump again a few studs above the
ground before landing: no damage. Fly as high and land without catching yourself: about 21 damage. Both were measured
in Studio on 2026-11-13: from a peak 31.5 studs up and a catch at 3.6 studs, 200 → 200; with no catch, 200 → 179.

**For the wiki.** Jetpack (Arsenal) and fall damage: a fall counts from where the snail last went up, so catching
yourself with the jetpack before landing avoids the damage. Say it as a tip on the Jetpack.
