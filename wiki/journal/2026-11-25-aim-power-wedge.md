---
title: "Aim: a power wedge like ShellShock Live, and small white preview dots"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD", "Aiming"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The owner sent a ShellShock Live screenshot: "make this cone triangle power thing similar to that",
then "make it change color based on the power". Every aim, the player's own and every other snail's, now shows a soft
triangle from the snail to the crosshair, its point at the snail and its wide end at the crosshair's ring (0.16 of its
length across), in the power's colour: yellow at little power, orange, red at full. It replaces the morning's circles
on other snails' turns (`POWER_DOTS`, `POWER_DOT_SIZE` and `PREFAB | PowerDot` are gone).

The preview dots changed too. At full power they spread far apart ("we barely see them"), and when zooming they jumped
("the dots behave weirdly"). They're now small white see-through dots (no power colour: "dont change the color of
dots"), one every 1.5 studs along the shot's path, placed on the path exactly, so they stay put on the map as the camera
zooms and come no further apart at full power. There are more of them the further the preview reaches (up to 24).

**Where.** MatchHud's `POWER_WEDGE_SPREAD` (0.16), `PREVIEW_DOTS` (24, was 5), `PREVIEW_STEPS` (40), `PREVIEW_SPACING`
(1.5 studs), `PREVIEW_DOT_SIZE` ({0.42, 0.28}, was {0.75, 0.45}), `PREVIEW_TRANSPARENCY` ({0.3, 0.8}, replacing
`PREVIEW_FADE`); Aim's `_draw` (the wedge), `_drawPreview` and `_placePreviewDot`; the gui's `U_Aim › S_PowerWedge`
(`S_WedgeTop`, `S_WedgeBottom`) and the white `PREFAB | AimDot`.

**How to check.** In a match, drag to aim: a yellow-to-red wedge runs from the snail to the crosshair as the power
grows, and white dots trace the start of the arc at the same spacing at any power; zoom in and out and the dots stay
on the same spots. On a bot's turn its aim shows the same wedge. Checked in Studio on the player's own turn (full power,
red wedge, white dots); a bot's wedge wasn't captured.

**For the wiki.** Aiming: the power wedge and the white preview dots, and a History line. Supersedes the power cone part
of 2026-11-25-others-power-cone and the dots part of 2026-11-25-aim-preview-half.

**Later the same day.** The preview dots were removed outside the tutorial (2026-11-25-aim-dots-removed): only the
power wedge part of this entry still holds.
