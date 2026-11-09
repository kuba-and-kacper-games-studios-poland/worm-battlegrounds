---
title: "Bot brains, the aim solver, check margins, payouts and the level curve kept off players' devices"
date: 2026-11-09
status: open
kind: changed
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerData/Brains.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Arcs.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/ServerSettings.lua
---

**What changed.** The owner asked that players can't read the game's sensitive code (2026-11-09). Several things that
used to reach every player's device now stay on the server. Nothing changes in play.

**Bots.** The settings file is now `Bots/ServerSettings.lua`, with the skills, loadouts and planning numbers. The
genomes are now `Bots/ServerData/Brains.lua`, which the `train-bots` skill now names. ume hides names containing
"server", and it loads every module's `Settings.lua` on clients.

**The arc solver.** `GetArcs` and `PredictArc` moved from `I.G_Combat` (shared) to `I.Combat` (server,
`Combat/Scripts/Server/Arcs.lua`). Bots call them there.

**The admin aim guide.** The server now solves the guide (`Combat/Scripts/Server/Aimbot.lua`) for a player whose
`Aimbot` attribute the server set. It sends the guide to that player alone with the new remote
`Combat_AimbotGuide @ (guides)`, and an empty list clears it. The client only draws it, so an exploiter setting
`Aimbot` on their own client gets nothing.

The solver's numbers moved to `Combat/ServerSettings.lua` with unchanged values: `AIMBOT_REFRESH` 0.2,
`AIMBOT_POWERS`, `AIMBOT_ARC_SECONDS` 5, `AIMBOT_ARC_STEP` 1/30 and `AIMBOT_HIT_MARGIN` 2.5. The two colours stay in
`Settings.lua`.

**Movement check margins.** `CHECK_INTERVAL`, `SPEED_TOLERANCE`, `MOVE_SLACK`, `STAMINA_GRACE` and `LIFT_GRACE`
moved to `SnailControl/ServerSettings.lua`, unchanged.

**Match payouts and the level curve.** These moved to `MatchRewards/ServerSettings.lua` and
`Progression/ServerSettings.lua`, unchanged.

**How to check.** In a Studio play test, the client's `ReplicatedStorage.Instance.Modules.Main_Game.Bots` holds only
an empty `Scripts` folder. This was checked on 2026-11-09. In the same test, a solo match against Hard bots ran
(bots took turns), and with `Aimbot` set on the server, the player's `Workspace.Ume.Combat.Aimbot` filled on their
turn (29–38 parts), with no errors.

**For the wiki.** Architecture: say that server-only values live in `ServerSettings.lua` / `ServerData/` and never
reach clients, and that the aim guide is solved on the server. Match modules: Bots' files and the aimbot line.

Supersedes the "Where" of 2026-11-09-aimbot-command: the solver is no longer `I.G_Combat.GetArcs`, and the guide is no
longer solved on the client. Its command, colours and what the player sees still hold.
