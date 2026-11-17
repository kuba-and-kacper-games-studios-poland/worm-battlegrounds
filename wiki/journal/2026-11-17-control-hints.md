---
title: "Control hints while waiting and dropping, for a player's first 9 matches"
date: 2026-11-17
status: open
kind: added
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Hints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ControlHints/init.lua
---

**What changed.** While a player waits for the match and picks where to land, a strip at the bottom of the screen
shows the match's controls for their device, and a tip over it changes every 4 seconds. PC: A D walk, Space jump (hold
to fly), the left mouse button hold to charge and let go, the right button drag the camera, 1 2 3 weapons, the wheel
zoom. Phones and tablets: the walk buttons, JUMP, a finger dragged to aim, FIRE held to charge, two fingers to move the
camera and pinch to zoom. Pad: left stick walk, A jump, right stick aim, RT charge and fire, LB RB weapons, LT with the
right stick the camera (the player's own pad's icons). It switches the moment a pad is picked up. Tips: the wind pushes
thrown shots, a full charge fires by itself, you can keep moving after a throw, the open sea knocks you out, grenades
burst when they stop rolling. Shown only in a player's first 9 matches (from the 10th it's gone for good) and never in
the tutorial match. The public waiting room moves up over the strip while it shows.

**Where.** New gui `ControlHints`; MatchHud's `Hints` handler; `HINTS_GUI_NAME`, `HINTS_MATCHES` 9 (read against the
`MatchesPlayed` statistic, which MatchRewards adds to at every match's end, so the strip shows while it's under 9),
`HINT_TIP_SECONDS` 4, `HINT_TIPS`. The waiting room's `Look_HintsPosition` (0.5, 0.81) in `MatchWaiting`.

**How to check.** A player with `MatchesPlayed` under 9 sees the strip in a public match's waiting room and the drop,
the room above it; `statistic set player MatchesPlayed 9` hides it.

**For the wiki.** Controls & platforms: the in-match hint strip for new players, the tips list.

**Changed in testing (2026-11-17).** Long labels shrank unevenly, so they're one or two words: Desktop Walk · Jump / Fly ·
Shoot · Camera · Weapons · Zoom; Mobile Walk · Jump / Fly · Aim · Shoot · Camera; Console Walk · Jump / Fly · Aim ·
Shoot · Weapons · Camera. Two tips tell the holds ("hold to charge a shot, let go to fire", "hold jump to fly with
your jetpack"), now seven `HINT_TIPS`.

**Changed after the owner's second look (same day).** "Control hints feel very off (they overlay different
notifications and guis)": the strip across the bottom middle (where notifications and the waiting room show) became a
short list at the bottom left in the HUD's pad-hint look: no panel, each control's keys (dark key caps, a dark mouse
with its button gold, dark touch pills, the pad's icons) then its label in white upper case, the tip over the list.
The waiting room no longer moves up for it (that lift, `WaitingRoom`'s and `MatchWaiting`'s `Look_HintsPosition`,
was taken out again), so those two files aren't part of this change any more.
