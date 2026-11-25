---
title: "Aim guide dots past the crosshair, smaller aim readout"
date: 2026-11-25
status: dropped
kind: added
pages: ["Match HUD", "Aiming"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** An arced weapon's aim gets a small assist again (the owner: "bring back the target dots - slight
subtle ones… start them from the target icon so they dont overlap the power cone"; then "2 more dots"): 6 white dots on the shot's real
path, starting 0.9 units past the crosshair's ring, one every 1.6 units, shrinking from 0.55 to 0.3 units and fading
from 0.35 to 0.8 see-through. They ignore the wind and stop at the first terrain or snail, so they show the bend
but not the landing. Only on the player's own aim, never in the tutorial or with the admin aimbot (those show the whole
path). The readout over the crosshair ("62% · 41°") is smaller: 15 px text (was 18), and on phones and tablets its
box is 160 × 11 px, so the text shrinks to about 11 px (the owner: "too big on the mobile").

**Where.** `_drawGuide` and `_hideGuide` in MatchHud's `Aim.lua`; `GUIDE_DOTS`, `GUIDE_GAP`, `GUIDE_SPACING`,
`GUIDE_DOT_SIZE`, `GUIDE_TRANSPARENCY`, `GUIDE_STEP`, `GUIDE_SECONDS` in its Settings; the gui's `PREFAB | AimDot` (cloned
into `U_Aim`) and `S_Readout` (`Utils_PlatformSize` with `Utils_MobileSize` 160 × 11).

**How to check.** In a match, aim the Bazooka: six faint dots continue past the crosshair, curving down at low power.
On a phone, the readout is about half its old size.

**For the wiki.** Aiming: a short faint guide past the crosshair, no wind; the whole path only in the tutorial.
Supersedes the "no path outside the tutorial" part of 2026-11-25-aim-ring-point.

**Dropped the same evening.** The guide dots past the crosshair are gone: the owner found the trajectory "very hard to
predict" and asked for the 24 Nov preview back (2026-11-25-aim-preview-back). The smaller readout from this entry stays.
