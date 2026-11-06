---
title: "Windows widen the view by 5° again (lobby 40 → 45, match 30 → 35)"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby", "Guis"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
---

**What changed.** Opening a window (Crates, Skins, Modes, Shop…) widens the camera's field of view by 5° behind the
blur, and closing the last window brings it back, in a 0.3 s ease. Before, it didn't work: MatchCamera locked the FOV
controller for the whole session (so nothing happened in Studio), and the lobby stage forced its 40° every frame
(so on the real Lobby map the controller and the stage fought over it). Now the lobby sits at 40° (45° with a window
open) and the match camera at 30° (35°).

**Where.** WidgetManager adds `FOV_INCREASE` (5) to the client `FOV` buff as the value `Widget` while a window is open
(`BACKGROUND_FOV`, `WidgetManager/Settings.lua`). The cameras now set the buff's base instead of writing
`Camera.FieldOfView`: `I.Buff.Set("FOV", "Standard", fov)`, the lobby stage with `STAGE_FOV` (40) in `_refreshCamera`
when it takes the camera, MatchCamera with its `FOV` (30) the first frame it takes the camera. FOV_Controller tweens
the camera to the buff's sum. MatchCamera no longer calls `I.FOV_Controller.SetLock`, and its view bounds use the
camera's real field of view.

**How to check.** Play the Studio map: the lobby camera reads 40; open Crates and it reads 45; close it and it's 40
again. Start a match: the camera reads 30.

**For the wiki.** Guis: opening a window blurs the scene and widens the view by 5°. Lobby: the stage camera's field of
view is 40°.

Still unsure: opening a window during a match wasn't tried in the playtest (the match HUD has no window button); it
goes through the same buff, so it should read 35.
