---
title: "Spider bomb throws further and walks over 1-stud steps smoothly"
date: 2026-11-08
status: open
kind: fixed
pages: ["Spider bomb", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Crawler.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/SpiderBomb.lua
---

**What changed.**
- **Throw:** the Spider bomb's throw reaches about 56% further at full power (`MaxSpeed` 100 → 125). It flies on the
  game's own simulation like the Grenade, so its arc matches the aim line. Before, it used Roblox physics.
- **Landing:** it lands on the first thing it touches and blows up at once on a snail or in liquid.
- **Crawling:** it walks up steps up to 1.25 studs high and down steps up to 3 studs deep, easing up and down instead
  of jumping a stud at a time. Taller walls it climbs, deeper drops it falls down.
- **Under or over its target:** it waits there instead of turning back and forth.
- **On screen:** its model glides after its server position, so it doesn't stutter.

**Where.** `Crawler.Run` (`Projectiles.Launch` and `Fly`, then `Projectiles.Spawn` for the crawl) and
`Crawler._getNextStep`. Combat's `CRAWL_STEP_UP` (1.25), `CRAWL_STEP_DOWN` (3), `CRAWL_STOP` (0.25) and `CRAWL_GLIDE` (18).
`MaxSpeed` is in `SpiderBomb.lua`.

**How to check.** Studio match (2026-11-08): a full-power throw landed on a hill, climbed it, walked the 1-stud steps
on top and dropped down the far side over 5 s with no gaps or stalls.

**For the wiki.** Spider bomb: the reach, and how it walks steps and climbs walls.
