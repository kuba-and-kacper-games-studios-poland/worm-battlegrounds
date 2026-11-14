---
title: "The spider bomb's throw and bomblets feel the wind"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal", "Wind"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Crawler.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** The owner: "the spider and thrown projectiles should also be affected by wind". The spider bomb's
row already said `Wind = true`, but Combat's Crawler launched it without wind; the cluster bomb's bomblets and the
variety grenade's minis also flew without it. Now all three feel the match's wind as every other thrown shot does
(`I.G_Combat.GetWindAcceleration`: `wind × (WIND_ACCEL 7 + WIND_ACCEL_GROWTH 1.5 × |wind|)` studs/s²). The spider's
crawl after it lands is unchanged (wind doesn't push it along the ground). The aim guide and the bots already solved
the spider's arc with wind, so their aim now matches its flight; the bots' forecast (`Predict.GetShot`) flies the
spider and bomblets with the wind too.

**Where.** `Crawler.Run` and `Bouncer._runBomblet` (`options.Wind`), sent to clients with the shot's options
(`Combat_Shot`); Bots' `Predict.GetShot`.

**How to check.** In wind 6, throw a spider bomb or a cluster bomb high: the spider drifts with the wind like a
grenade, and the bomblets scatter downwind.

**For the wiki.** Arsenal (Spider bomb, Cluster bomb, Variety grenade): they feel the wind. Wind: which shots feel it.

Supersedes the "not changed" note at the end of `2026-11-13-spider-bomb-crawls-terrain-only` (the spider's launch
without wind).
