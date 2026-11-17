---
title: "Joining the lobby: the camera no longer swoops in from the side"
date: 2026-11-17
status: open
kind: fixed
pages: ["Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
---

**What changed.** On joining, about a second after the lobby's stage camera took over, the camera jumped hundreds of
studs off to the side and swooped back to the stage over two seconds (the owner: "the camera at first tweaks, like it
comes from somewhere else… it looks broken"). Roblox's own camera scripts moved the camera once as the avatar loaded,
and the stage camera eased from wherever the camera was each frame. It now eases from where it last held the camera
(`heldCFrame`), so nothing else can pull it away: on join it stands on the stage at once and stays.

**Where.** Lobby's `Scripts/Client/Stage.lua`: `_refreshCamera` sets `heldCFrame` to the stage's framing when the
lobby takes the camera; `_holdCamera` eases `heldCFrame` toward the target (`STAGE_CAMERA_EASE`, unchanged) and writes it
to the camera.

**How to check.** Join the lobby (Studio play test): the camera is on the stage from the first frame the lobby shows
and never moves after; a custom lobby still backs it off smoothly.

**For the wiki.** Nothing players need to learn; a History line on the Lobby page if it lists fixes.
