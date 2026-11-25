---
title: "Homing missile: lock a target, then aim the launch"
date: 2026-11-25
status: open
kind: fixed
pages: ["Homing missile", "Aiming", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The homing missile's launch couldn't be aimed: a press only placed the target, and FIRE sent the
angle and power left over from the last aimed weapon (the bazooka's), which the player never saw. Now the first press
(a click, a tap) locks the target, shown as a red copy of the crosshair on its spot (MatchHud's `S_TargetMark`); then
the launch is dragged like an arced weapon's, with the power ring, the "62% · 41°" readout and the preview's dots, and
FIRE shoots it. **NEW TARGET**, a blue button left of FIRE (a copy of the lobby's LOCAL button, `U_Retarget`), lets
go of the target so the next press places another. The flight itself is unchanged (Combat's homing behaviour).

**Where.** Aim's `_onInputBegan` (the first press places the target while none is set), `_step` (picking, then
aiming), `_drawTargetMark`, `_clearTarget`, `_canFire` (needs the target and an aim). Settings' `TARGET_HINTS` lost
`Shoot` ("Press FIRE!"), and `TARGET_COLOR` is gone with the 3D ball marker. The gui's `U_Fire` › `U_Retarget` and
`U_Aim` › `S_TargetMark`.

**How to check.** In a match, hold the homing missile: "Click on a target"; click an enemy, the red mark sits on it
and the aim shows; drag, FIRE; NEW TARGET clears it. Checked in Studio on 2026-11-25 (fired at a bot once its 3-turn
wait was over).

**For the wiki.** Homing missile: how to fire it (target, then aim, then FIRE; NEW TARGET to change it). Aiming: the
homing missile no longer fires straight after its target is placed. Still unsure: a pad has no way to place a target
(it never had one).
