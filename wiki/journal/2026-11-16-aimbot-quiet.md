---
title: "Admin aimbot: landing line and a faint mark, no lock-on"
date: 2026-11-16
status: open
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The admin `aimbot <player>` command no longer draws a dotted path and an angle and power label
over every enemy, and right click no longer locks the aim on. Instead, on that player's turn:

- an arced weapon shows the tutorial's prediction line (MatchHud's `PREDICTION_*`): where the shot at the power held
  flies and lands, faded at the last power fired before a press;
- each enemy snail some aim with the held weapon would hurt gets a faint white fill on its team outline (Combat's
  `AIMBOT_FILL_COLOR` white, `AIMBOT_FILL_TRANSPARENCY` 0.82), so it isn't obvious to anyone watching.

The server decides the marks better: it ranks the arcs from `GetArcs` by where they first touch, then runs the 4
nearest (`AIMBOT_SIMULATED`, replacing `AIMBOT_HIT_MARGIN` 2.5) through the bots' own prediction
(`I.Bots.GetShotHits`: bounces, fuses, bomblets, crawls, black hole pulls and blast reach), so a grenade that bounces
in, or a blast that lands beside a snail, counts. Guns and swings are tried straight at the snail. The remote is now
`Combat_AimbotTargets` (the snails only), replacing `Combat_AimbotGuide`. Removed: MatchHud's `AIMBOT_EASE`, Combat's
`AIMBOT_HIT_COLOR`, `AIMBOT_MISS_COLOR` and client `GetAimGuides`.

**How to check.** Checked in Studio on 2026-11-16: with the aimbot on, 80 prediction dots showed; a bot 45 studs away
in no wind got the fill (0.82), and one 320 studs away into a −10 wind didn't. One full prediction took about 1 ms.

**For the wiki.** Admin tools only, so `:::private` if anywhere: the Architecture page's note that the aim solver
stays on the server.
