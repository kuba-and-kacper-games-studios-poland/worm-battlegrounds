---
title: "Admin /aimbot command: an aim guide for one player for one match"
date: 2026-11-09
status: open
kind: added
pages: ["Match modules", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Aimbot.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
---

**What changed.** A new admin command, `aimbot <player>` (permission level 255, in the command bar or `/cmd` in
chat), toggles an aim guide for that player in the match they're in. On their turn their screen shows, for every enemy
snail, the path of the shot that lands on it with the weapon they hold (green dots on a hit, orange for the nearest
miss when nothing hits) and the angle and power to set, written like the HUD ("33° 70%"). Guns get a straight line
and an angle; the homing missile its launch; a swing or Dynamite shows nothing. It's off again when the player leaves
the match, and refused outside one.

**Where.** The command is `Combat_Aimbot` in Combat's command bar file; it sets the Player attribute `Aimbot`
(server-written). The guide is Combat's client `Aimbot.lua`, drawn in `Workspace.Ume.Combat.Aimbot`. The arc solver
moved from Bots' `Aim.lua` to Combat's Global as `I.G_Combat.GetArcs(origin, aimAt, itemId, windAcceleration,
powers)`, which bots now call with their `POWER_STEPS` (same results). New Combat settings: `AIMBOT_REFRESH` 0.2,
`AIMBOT_POWERS` 0.1 to 1 by 0.05, `AIMBOT_ARC_SECONDS` 5, `AIMBOT_ARC_STEP` 1/30, `AIMBOT_HIT_MARGIN` 2.5,
`AIMBOT_HIT_COLOR`, `AIMBOT_MISS_COLOR`.

**How to check.** Set `Aimbot` on a player in a Studio match: on their turn, `Workspace.Ume.Combat.Aimbot` holds
dots and one label per enemy (tested: three labels such as "33° 70%" with the Bazooka), and it empties on other
turns.

**For the wiki.** An admin-tools line wherever the wiki lists admin commands (Match modules or Architecture);
Arsenal needs nothing. Still unsure: the command bar itself wasn't run in the test (the attribute was set directly).
