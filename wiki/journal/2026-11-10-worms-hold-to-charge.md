---
title: "Shooting is Worms Armageddon's again: hold to charge (full in 1.3 s), crosshair in the team's colour"
date: 2026-11-10
status: open
kind: changed
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** Supersedes `2026-11-07-aim-at-mouse` (the power by how far the mouse is from the snail) and the
crosshair and charge numbers of `2026-11-06-crosshair-charge-aiming`. The weapon still points from your snail at the
mouse (a finger on touch, the right stick on a pad). Now holding the left mouse button, RT, or FIRE on a touch screen
charges the power at one even rate, none to full in 1.3 seconds (Worms Armageddon's measured charge, up from the pad's
1.6); letting go fires, and a full charge fires by itself. Guns, melee weapons and weapons placed at the feet fire on
the press. Right click, Esc or B drops a charge without firing; a turn that runs out drops it too. On touch, a finger
on the arena only points the aim (it stays where the finger lifts) and only FIRE shoots; before, a drag set both and
FIRE fired. The crosshair is new: a ring with an X, spinning slowly, in the aiming snail's colour (its team's, or its
own in a free-for-all), about 12.5 studs' worth from the snail at the default zoom (was 9, the studio's blue crosshair
picture). The power is a cone of 14 circles, dark red to pale yellow (was 32, yellow to red), straight along the aim,
each growing in smoothly as the power reaches it, and the last one always stops short of the crosshair (before, the
last sat on it, and the row bent off the mouse's line). Since 2026-11-11 the aim is drawn on the HUD in screen pixels,
so it no longer flickers and looks the same at every zoom (before, zoomed in it was small circles far apart, zoomed out
cramped). The
tutorial's aiming hint reads "Point at the bot to aim, hold the mouse button to charge, let go to fire. On a touch
screen, tap to aim and hold FIRE".

**Where.** Combat's `CHARGE_SECONDS` 1.3 (players and bots). MatchHud's Settings, in units (a stud at the camera's
default distance): `POWER_DOTS` 14, `POWER_COLORS` (170, 0, 0) → (248, 223, 108), `POWER_DOT_SIZE` 0.9 → 2.3,
`POWER_START` 2.3, `POWER_LENGTH` 7, `POWER_GAP` 0.3, `CROSSHAIR_SIZE` 3.4, `CROSSHAIR_SPIN` 60 (degrees a second);
`MIN_PULL`, `MAX_PULL` and `CROSSHAIR_IMAGE` are gone. The MatchHud gui's `U_Aim` layer holds `S_Crosshair` and
`PREFAB | PowerDot`. Combat's client `GetMuzzle` is gone (only the aim used it). `_startShot`, `_onFireBegan` and `_draw` in `Aim.lua`. The crosshair's colour is the
snail model's `Color` attribute. `HINTS.Fire` in Tutorial's Settings.

**How to check.** In a solo match, on your turn: hold the left button and let go before 1.3 s, the shot goes at that
power; hold on, it fires by itself at 100 %; right click mid-charge, nothing fires. The crosshair is your snail's
colour, and a bot's is its own. Checked in Studio on 2026-11-10 (a 0.9 s hold fired on release, a held press fired by
itself 1.34 s in, a right click fired nothing, the crosshair took the snail's red). Not checked on a real phone or pad.

**For the wiki.** Controls & platforms: aiming on PC (mouse points, hold to charge, let go; full charge fires itself),
touch (tap or drag to aim, hold FIRE) and console (right stick, hold RT); cancelling. Match screen: the crosshair in
your team's colour and the power cone.
