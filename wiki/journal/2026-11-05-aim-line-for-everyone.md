---
title: "Every player sees the active worm's aim line, players' and bots'"
date: 2026-11-05
status: open
kind: added
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** While a worm aims, its dotted aim line (the first 0.6 s of the shot's path, without wind) now
shows on every player's screen, not just the aiming player's. It follows the aim as it moves and goes when the shot
is fired or the worm stops aiming. Bots' aims show the same way.

**Where.** `I.Combat.ShowAim` (server) writes the worm's `AimAngle`, `AimPower` and `AimTime` (the server time of
the latest update, 0 once fired); the `Combat_Aim` remote (10 a second while a player aims) goes through it. MatchHud's
`Aim.lua` draws another worm's line while its `AimTime` keeps changing: `AIM_SHOW_GRACE` 0.4 s without an update hides
it, `AIM_SMOOTHING` 15 eases it between updates. No line for weapons fired at the feet.

**How to check.** In a solo match, the bot's aim dots (10) show on the player's screen while it aims (checked in a
Studio playtest). Two players: the waiting one sees the other's dots move as they drag.

**For the wiki.** Match screen: the aim line is seen by everyone in the match.

**From.** Controls & platforms → suggestion trajectory-preview ("Show a short dotted line from the worm's weapon
while aiming"), already built for the shooter; this shows it to everyone.
