---
title: "Tutorial: any press on the lit landing spot counts, and the spot is lower (8 studs over the land, was 20)"
date: 2026-11-15
status: open
kind: fixed
pages: ["Tutorial", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/DropPicker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** The owner: on the tutorial's first step ("Click the lit spot to land there") players couldn't
click the spot, and the spot should be lower.

- A pick only counted within 6 studs sideways of the spot (`TUTORIAL_PICK_RADIUS`, X only) and where a snail fits,
  but the spotlight's hole is at least `HOLE_MIN` (72) pixels: zoomed out, and on phones, its edge is further than
  6 studs from the spot, so a press there did nothing. Now any press within 10 studs of the lit spot, in any direction,
  counts, whether or not a snail fits where it landed (the spotlight's blockers stop presses anywhere else), and the
  snail lands on the lit spot as before. The client sends tutorial presses without its own free-spot check
  (`DropPicker._place`, the match folder's `Kind` is `Tutorial`).
- The lit spot is `TUTORIAL_DROP_HEIGHT` (8) studs over its land instead of `DROP_HEIGHT` (20): `_getSkySpot` takes
  the height. The tutorial bot's spot is lower too.

**Where.** `Module.PickDrop`, `Module._drop` and `Module._getSkySpot` in `Match/Scripts/Server/Phases.lua`;
`Module._place` in `Match/Scripts/Client/DropPicker.lua`; `TUTORIAL_DROP_HEIGHT` and `TUTORIAL_PICK_RADIUS` in
`Match/Settings.lua`.

**How to check.** In Studio with the Workspace attribute `StudioTutorial` on: the lit spot is about 9 studs over the
land (the ball's centre), and a click near the bottom of its circle lands the snail on it (tested 2026-11-15). Still
unsure: a press at the old spot's centre worked in Studio too, so the original failure wasn't reproduced; if players
still can't land, ask which device (touch taps go through `_onTouchTap`) and where they press.

**For the wiki.** Tutorial: the first step's spot is close over the land, and pressing anywhere on it lands there.
