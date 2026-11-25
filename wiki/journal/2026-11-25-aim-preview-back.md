---
title: "The 24 Nov aim preview dots are back (9 dots, a fifth of a flight, power colour)"
date: 2026-11-25
status: open
kind: changed
pages: ["Aiming", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The aim preview the testers played on 24 Nov (around 23:41) is back exactly (the owner: "it was
perfect - so lets try to add those dots back"). While aiming an arced weapon, or a homing missile's launch, 9 dots run
from the snail along the start of the shot's path, covering a fifth of a full-power shot's flight time (at 45°), so
they reach further and spread out with more power and bunch and bend at low power. No wind; they stop at the first
terrain or snail in the way; they shrink from 0.75 to 0.45 units and fade to 75% see-through, in the power's colour
(yellow at little, red at full). The tutorial and the admin aimbot still show the whole path instead.

**Where.** `_drawPreview` and `_hidePreview` in MatchHud's `Aim.lua` (the 24 Nov code); Settings `PREVIEW_DOTS` 9,
`PREVIEW_SHARE` 0.2, `PREVIEW_DOT_SIZE` { 0.75, 0.45 }, `PREVIEW_FADE` 0.75; the gui's `PREFAB | AimDot`, coloured by code.

**How to check.** In a match, aim the Bazooka at full power: nine red dots from the snail, spread far and fading. At
low power they're yellow, close together and curving down. Checked in Studio at full power.

**For the wiki.** Aiming: the preview shows the start of the path, nine dots in the power's colour, no wind; the whole
path only in the tutorial. Supersedes 2026-11-25-aim-dots-removed, 2026-11-25-aim-guide-dots, and the dots parts of
2026-11-25-aim-preview-half and 2026-11-25-aim-power-wedge. Differences from 24 Nov: the power wedge now runs under the
first dots, and the readout is smaller.
