---
title: "Aiming is a crosshair and a held charge (full power in 1.6 s), seen by everyone"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: changed
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
---

**What changed.** Aiming works like Worms. Before: drag back from the worm (direction = angle, length = power), dots
showed the first part of the shot's path, letting go fired. Now: on your turn a crosshair sits 9 studs from your worm,
pointing at the mouse (on touch, the finger; on a pad, the right stick). Holding the mouse button, a finger or RT
charges the power: a yellow-to-red cone grows from the muzzle toward the crosshair. Letting go fires at that power; a
full charge fires by itself after 1.6 seconds. Right click, Esc or B lets go of a charge without firing; a second
finger cancels it (for panning). Guns and melee weapons (Shotgun, Uzi, Baseball Bat…) fire on the press. There is no
path preview any more. Every player sees the active worm's crosshair and power through its turn. Bots turn their
crosshair first (1.5 s), then charge to their shot's power, then fire. The tutorial's aiming hint now reads "Point the
crosshair at the bot, then hold to charge and let go to fire".

**Where.** `CHARGE_SECONDS` 1.6 in Combat's Settings (players and bots). MatchHud Settings: `CROSSHAIR_DISTANCE` 9,
`CROSSHAIR_SIZE` 3 studs, `CROSSHAIR_COLOR` (190, 235, 110), `POWER_COLORS` (255, 220, 60) → (240, 60, 30),
`POWER_WIDTH` 0.4 → 2.4; `MIN_DRAG`, `MAX_DRAG`, `PAD_POWER_SPEED` and the `AIM_LINE_*`/`AIM_DOT_*` keys are gone. Aim
is sent through `Combat_Aim` every 0.1 s of the turn and shown from the worm's `AimAngle`, `AimPower`, `AimTime`. Bots:
`_showAim` in `Bots/Server.lua`; `AIM_START_POWER` is gone. The tutorial hint is `HINTS.Fire` in Tutorial's Settings.

**How to check.** In a solo match, move the mouse on your turn: the crosshair circles the worm. Hold the left button:
the HUD's "Power" climbs and the cone grows; at 100 % the shot fires. On the bot's turn its crosshair swings, then its
cone grows.

**For the wiki.** Controls & platforms: the aiming section for PC (mouse points, hold to charge), touch (press and hold
where you want to aim) and console (right stick, hold RT); the pc-aim question's answer is now the crosshair and
charge. Match screen: the crosshair and power cone, seen by everyone. Unsure: the crosshair is drawn in code until the
kit has a picture for it.

**Merged.** The cone and the full charge firing by itself were replaced by 2026-11-06-charge-bounce-circles.
