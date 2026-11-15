---
title: "Touch Jump button over FIRE in the gui source; the HUD's touch controls crash fixed"
date: 2026-11-15
status: open
kind: fixed
pages: ["Match screen", "Controls & platforms", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/TouchControls.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The match HUD's client stopped with `TouchControls:42: attempt to index nil with 'InputBegan'`
(MatchHud's `_start` failing), on every device. In the place, someone had moved the touch **JUMP** button by hand out
of `U_Touch` (bottom left, over the walk buttons) into a new `U_TouchJump` frame in `BottomRight`, just over FIRE;
the gui's source still had it in `U_Touch`, and TouchControls looked for `S_Jump` only there. Now:

- the gui source has the move: `BottomRight` › `U_TouchJump` (Frame, AnchorPoint 0.5, 1, Position 0.5, -0.04, Size
  0.541, 0.559 of `BottomRight`, `Utils_HideOnPlatform`, Mobile only) › `S_Jump` (filling it). `U_Touch` keeps
  `S_Left` and `S_Right`;
- TouchControls finds `S_Left`, `S_Right` and `S_Jump` anywhere in MatchHud, so the buttons work wherever they sit.

What players see on phones and tablets: walk left and right at the bottom left, JUMP at the bottom right over FIRE,
all three only on their own turn (as before).

**Where.** `Module.Start` and `Module._refresh` in `MatchHud/Scripts/Client/TouchControls.lua`; the `BottomRight`
block in the MatchHud gui (`U_TouchJump`).

**How to check.** In a play test the Output shows no MatchHud `_start` error; with Studio's device emulator on a phone,
JUMP shows over FIRE on the player's turn and makes the snail jump.

**For the wiki.** Match screen and Controls & platforms already say Jump is at the bottom right: no change there,
maybe a line that it sits over FIRE. Architecture's MatchHud notes can name `U_TouchJump`.
