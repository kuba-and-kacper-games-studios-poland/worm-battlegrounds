---
title: "Spider bomb no longer hangs in mid-air beside snails"
date: 2026-11-13
status: open
kind: fixed
pages: ["Arsenal", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Crawler.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Server.lua
---

**What changed.** A crawling spider bomb found its walls and ground with the projectiles' cast, which also hits
snails. A snail in its way (the shooter or a teammate, 4.1 studs tall, taller than its 2.6-stud ball) counted as a
wall: the spider climbed its side into the air, then dropped (a snail isn't ground to it), climbed again, and hovered
there until its 5 s crawl ran out. Now it finds its way by terrain alone, so it crawls through snails that aren't its
target. It also no longer climbs into a ceiling (it waits under it) or up empty air beside an overhang it fits under.

**Where.** `Projectiles.CastTerrain` (the `Snail` collision group with `RespectCanCollide`: what snails stand on) and
`Projectiles.GetCrawlStep` (moved from `Crawler._getNextStep`), exposed as `I.Combat.GetCrawlStep`; the crawl in
`Crawler.Run`. Numbers unchanged: `CRAWL_STEP_UP` 1.25, `CRAWL_STEP_DOWN` 3, `CONTACT_DISTANCE` 2.5, the spider's
`CrawlTime` 5 and `CrawlSpeed` 10.

**How to check.** Throw a spider bomb so it lands with your own snail between it and an enemy: it crawls through you
along the ground and bursts by the enemy, never climbing you.

**For the wiki.** Arsenal → Spider bomb: it crawls along the ground and up walls toward the nearest enemy, through
other snails. A History line for the fix.

Unsure: the owner's report ("sometimes gets bugged mid-air") wasn't reproduced in a live match. The snail-climbing
loop is the cause found in the code. Also seen, not changed: the spider's row says `Wind = true`, but Combat's Crawler
launches it without wind, unlike every other thrown weapon (practices: "every thrown shot ... feels the wind").
