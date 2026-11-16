---
title: "Lobby stage: every snail holds the Bazooka and strikes a random pose"
date: 2026-11-16
status: open
kind: added
pages: ["Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The owner: "make it feel organic and natural". Every snail on the lobby's stage (the player's,
their party's or their custom lobby's) holds a Bazooka and plays one of four poses, picked at random for each snail
(never the one it had) and started at a random point, so they don't move in step. The poses are picked again when the
stage's members change and when the player comes back from a match.

**Where.** Lobby's `STAGE_WEAPON` (`"Bazooka"`, its Arsenal model scaled with the snail, held with
`I.SnailRig.Hold`) and `STAGE_POSES` (`LobbyPose1` to `LobbyPose4`, Animation instances in the place's
`Assets/Snails/Animations`, the studio's bazooka poses). `Stage._pose`, `_poseAll`, `_onInMatch`.

**How to check.** The poses' `AnimationId`s are empty until the owner uploads them, and a pose without one is skipped:
until then the snails hold the Bazooka in their idle. Once uploaded, each snail on the stage strikes a different pose.

**For the wiki.** Lobby: the stage's snails hold a Bazooka and pose.
