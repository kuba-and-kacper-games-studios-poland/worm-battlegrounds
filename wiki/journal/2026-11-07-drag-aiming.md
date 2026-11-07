---
title: "Aiming is a drag again on PC and touch; the pad keeps its rising and falling power bar"
date: 2026-11-07
status: open
kind: changed
pages: ["Controls & platforms", "Match screen", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
---

**What changed.** Back to the studio's wiki. Before: a crosshair pointed at the mouse or finger, holding charged the
power (bouncing none to full and back), letting go fired; guns and melee weapons fired on the press. Now, on PC and
touch, the player presses anywhere and drags: the drag's direction is the angle and its length the power, full at 30 %
of the screen's height; letting go fires, and a drag shorter than 2 % of the screen's height cancels. Right mouse or Esc
cancels; on touch a second finger cancels (the camera pans). Every weapon is aimed this way, guns and melee too. On a
pad the right stick aims and holding RT runs the power bar up and down (1.6 s each way) until it's let go. The
crosshair and the row of power circles stay, as the "angle marker on the worm and power bar" the wiki asks for; every
player still sees them. Bots are unchanged. The tutorial's aim hint now reads "Drag toward the bot to aim: the longer
the drag, the stronger the shot. Let go to fire".

**Where.** `MIN_DRAG` 0.02 and `MAX_DRAG` 0.3 (shares of the screen's height) in MatchHud's Settings; `_onInputBegan`,
`_onInputChanged`, `_onInputEnded`, `_getDrag` in `Aim.lua`. Combat's `CHARGE_SECONDS` 1.6 is now the pad's power bar
(and the bots' charge). Remote `Combat_Aim` unchanged. Tutorial `HINTS.Fire`.

**How to check.** In a solo match, press and drag right and up from anywhere: the crosshair turns to the drag, the
circles fill as it lengthens, "Power" reads the share; let go and the shot fires. A tiny drag fires nothing. Checked
2026-11-07 in a Studio match: a drag of 160 × 110 px on a 1080-high screen read Power 57 % and 35°, and letting go
fired (Turn → Flight → Settle). Touch and pad weren't tried.

**For the wiki.** Controls & platforms: the aiming rows and the "Aiming works like Worms" paragraph go back to the drag
(PC and touch) and the right stick with RT (console); the pc-aim, touch-aim and power-same answers go back to the
studio's. Match screen: the crosshair is the angle marker. Lobby → First time playing: the tutorial's aim hint.

Supersedes 2026-11-06-crosshair-charge-aiming and 2026-11-06-charge-bounce-circles: the circles, their look, and
everyone seeing the aim still hold; the hold-to-charge input doesn't.
