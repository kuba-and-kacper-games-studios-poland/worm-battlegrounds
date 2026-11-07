---
title: "The weapon follows the mouse; power is the distance from the snail"
date: 2026-11-07
status: open
kind: changed
pages: ["Controls & platforms", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
---

**What changed.** On PC the held weapon and the crosshair point from the player's snail toward the mouse at all times
during their turn, without a press. Pressing and holding the left button sets the power by how far the mouse is from
the snail on the screen: none at 2% of the screen's height (`MIN_PULL`), full at 30% (`MAX_PULL`); letting go fires,
and letting go closer than 2% cancels. On touch the same happens with a held finger. While the left button is held,
the camera no longer pans at the screen's left and right edges (`EDGE_PAN_MARGIN`), so the view stays put while
aiming. The pad is unchanged (right stick and the rising-and-falling RT bar).

Supersedes 2026-11-07-drag-aiming: the drag measured from where the press began (its direction the angle, its
length the power) is gone; aiming by holding and letting go still holds.

**Where.** `_aimAtPointer`, `_getPull` and the input handlers in `MatchHud/Scripts/Client/Aim.lua`; `MIN_PULL`,
`MAX_PULL` in `MatchHud/Settings.lua`; `_getEdgePan` in `MatchCamera/Client.lua`.

**How to check.** On your turn, moving the mouse around the snail turns the weapon to it (checked in Studio: the
sent aim matched the mouse's direction from the snail within a degree); hold, pull away from the snail and the power
circles fill; let go to fire.

**For the wiki.** Controls & platforms: the PC row (aim by moving the mouse; power by holding, by distance from the
worm) and the touch row. Match screen: the power bar fills by distance while held.
