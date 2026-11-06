---
title: "The charge bounces between none and full, only letting go fires; power is a row of circles"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: changed
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** Supersedes part of "Aiming is a crosshair and a held charge". Before: holding the fire button grew a
yellow-to-red cone, and a full charge (1.6 s) fired by itself. Now: held, the power climbs to full in 1.6 s, then falls
back to none in 1.6 s, and keeps bouncing until the player lets go, which fires at the power shown. Nothing fires by
itself: if the turn timer runs out while charging, no shot goes. The power is drawn as 32 overlapping circles from the
muzzle to the crosshair, growing from 0.5 studs to 2.1 (the last one sits on the crosshair and fills its ring) and going
yellow to red, lit as the power fills. Other players see the same circles, and bots still charge up to their shot's
power and fire.

**Where.** `CHARGE_SECONDS` 1.6 in Combat's Settings (each way). MatchHud Settings: `POWER_DOTS` 32, `POWER_COLORS`
(255, 220, 60) → (240, 60, 30), `POWER_DOT_SIZE` { 0.5, 2.1 }; `POWER_WIDTH` is gone. `_step` and `_draw` in `Aim.lua`;
the circles are `Workspace.Ume.Combat.AimPower.Dot1…Dot32`. Combat's `Fire` refuses a shot outside the `Turn` phase.

**How to check.** In a solo match, hold the left button with the Bazooka: the HUD's Power climbs to 100 %, falls back
to 0 % and climbs again; circles light up from the muzzle as it climbs. Let go: it fires. Hold until the timer ends:
no shot.

**For the wiki.** Controls & platforms: aiming, the bouncing charge and that only letting go fires. Match screen: the
power circles.

**From.** The owner's request (2026-11-06): "when it reaches max it bounces back and forth … only shoot when player
releases in time … loading to be circles".
