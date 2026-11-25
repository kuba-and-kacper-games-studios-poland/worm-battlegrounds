---
title: "The tutorial bot shoots around the player, and now and then hits"
date: 2026-11-25
status: open
kind: changed
pages: ["Tutorial", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
---

**What changed.** The tutorial's bot no longer fires away from both snails into the water (the owner: "shoots you few
times - but most of the times misses - but shoots around you"). On its turn it fires its Bazooka toward the player,
trying 30°, 40°, 50°, 60° and 70° up at every 5% of power. Most turns it picks at random a shot that lands 8 to 16
studs from the player, past the Bazooka's 6-stud blast, so it shakes them but does no damage. From its second turn, at
35% a turn, never two turns running and only while the player has over 100 health, it takes its closest shot instead,
a hit when that lands within 2 studs (the Bazooka deals up to 35). It never lands within 10 studs of itself. With no
such shot it passes its turn.

**Where.** `_tutorialShot` in the Bots module's `Server.lua` (was `_missOnPurpose`); `TUTORIAL_ANGLES`,
`TUTORIAL_POWER_STEP`, `TUTORIAL_MISS_CLEAR`, `TUTORIAL_NEAR`, `TUTORIAL_HIT_CHANCE`, `TUTORIAL_HIT_SAFE`,
`TUTORIAL_HIT_SLACK` in its `ServerSettings.lua` (`TUTORIAL_MISS_ANGLE` and `TUTORIAL_MISS_POWER_STEP` gone).

**How to check.** Play the tutorial: the bot's shots land around the player's snail, and every few turns one hits.
Checked in Studio only as a search from a normal match's positions (77 to 132 studs apart): 3 to 12 near misses and a
hit within 1.3 studs were found for each bot. The tutorial itself wasn't played.

**For the wiki.** Tutorial: the bot shoots back, mostly near misses, sometimes a hit, never a knockout.
