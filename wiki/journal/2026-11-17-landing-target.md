---
title: "Picking where to land: the old picking with a new pin (picture, name, drop-in), the turn timer counting the drop"
date: 2026-11-17
status: open
kind: changed
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/DropPicker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DropMarker/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DropMarker/_meta/README.md
---

**What changed.** During the drop a target ring follows the mouse (a finger's last tap, the left stick on a pad) and
sits on the land straight under it, with a dashed line marching down to it from the pointer. It's white where a snail
can land, and red under a cross over the sea, a pond or lava, inside the ground or out of the play area; there a click
does nothing (before, a spot in the air over the sea could be placed, and the snail fell into it). Placing slams the
ring in (a gold ring shrinking onto it and a white shock ring) with a thump, and the player's pin drops onto it: a map
pin in their colour with their picture and name (it was a name over a chevron), on a gold ring under a light beam seen
from far out. Placing again moves it, until the timer ends. Other players' placed pins show in their colours on rings
of their colour; bots' stay hidden until they land (they showed before). The "Pick where to land" box is now a ring
timer at the top: a gold ring draining clockwise over the seconds, red with a tick each second in the last 3. In the
tutorial any press still counts, and the ring is white within 10 studs of the lit spot.

**Where.** `DropPicker.lua` (HandleAdornments on parts `DropTarget`, `DropSlam`, `Drop_<participantId>` in
`Workspace.Ume.Match`); Match's `DROP_RING_*`, `DROP_DASH_*`, `DROP_CROSS_*`, `DROP_SLAM_*`, `DROP_SHOCK_*`,
`DROP_PIN_*`, `DROP_BEAM_*`, `DROP_COLORS` (sizes in units: a stud at MatchCamera's `DISTANCE`, so they keep their
size at any zoom). The timer: MatchHud's `U_Drop` (`S_Timer`, `S_RightCut`, `S_LeftCut`), Panels, `DROP_TIMER_COLOR`
gold, `DROP_WARN_FROM` 3, `TIMER_DANGER_COLOR`, `Turn_Tick`. Sound `Drop_Place` (a stand-in until the 17 Nov sound set
is approved). `DROP_SECONDS` stays 15; `Match_PickDrop` is unchanged.

**How to check.** In a public match's drop: the ring follows the mouse on the land, red over the sea, a click there
does nothing; a click on land thumps and drops a pin with a beam; the timer drains and turns red at 3.

**For the wiki.** Match screen → the drop: the target, the red cross, the beam, the ring timer (a screenshot). Controls:
place with a click, a tap or A, move the target with the left stick.

**Checked in Studio (2026-11-17).** Ring timer and target work. Pointing into an island showed red (a snail can't
start inside the ground, and the server refused it too), so a pick inside the ground with its top less than
`DROP_SNAP_RISE` (10) studs above now becomes the spot over that top (`_getSpot`, `DROP_SNAP_GAP` 0.1): pointing at
Y 32.5 inside an island drew a white ring at Y 41 and the server placed the snail at Y 42.4.

**Changed after the owner's second look (same day).** "Make it more subtle, this one looks like it's from a different
game": the ring timer is gone; the drop's timer is now the turn timer's own plate (MatchHud's `U_Drop`, a copy of
`U_Turn`'s `Timer`) reading "0:15" with "Pick where to land" under it, its seconds red for the last
`DROP_WARN_FROM` (3) and ticking (Panels' `_tick`; `DROP_TIMER_COLOR` removed). The target is smaller and thinner, with
no dashed line from the pointer and no inner ring (DropPicker): Match's `DROP_RING_RADIUS` 7 → 4.5, `DROP_RING_WIDTH`
1 → 0.55, `DROP_RING_OUTLINE` 0.4 → 0.22, `DROP_CROSS_SIZE` 6 → 4, `DROP_CROSS_WIDTH` 1.1 → 0.6, `DROP_SLAM_SCALE` 1.8 →
1.35, `DROP_SLAM_SECONDS` 0.3 → 0.25, `DROP_SHOCK_GROWTH` 26 → 9, `DROP_SHOCK_SECONDS` 0.6 → 0.45, `DROP_BEAM_WIDTH`
2.6 → 1.2; `DROP_DASH_*` removed. `Drop_Place` is now its own uploaded sound ("Snail Landing Lock", 87841069953186).
For the wiki: the drop's screenshot shows the timer plate at the top, not a ring.

**Changed after the owner's third look (same day): the ring is gone, the old picking is back.** "The drop selection
totally sucks - it's even more confusing than it was before… the old one was good - I just wanted to change it
visually." The ring on the land, the red cross, the snapping into islands, the slam and the beam are removed
(`DROP_RING_*`, `DROP_CROSS_*`, `DROP_SNAP_*`, `DROP_SLAM_*`, `DROP_SHOCK_*`, `DROP_BEAM_*`, `DROP_COLORS` deleted).
DropPicker is the last commit's again: the spot is the point on the arena's plane under the mouse (a tap, the left
stick), a click, tap or A places it only where a snail fits (not touching terrain, not in a liquid, inside the play
area; the tutorial still takes any press), and every snail's spot shows a pin, bots' too. What stays new is the look:
the pin (DropMarker: a map pin in the snail's colour with its headshot, MatchHud's `BOT_AVATAR` for a bot, and its
name), its tip on the spot; the player's own follows the pointer until placed and is faded (`DROP_PIN_FADE` 0.6) where a
snail doesn't fit; others' are faded until placed; a placed pin drops in (`DROP_PIN_FALL` 0.35, `DROP_PIN_TWEENINFO`)
with `Drop_Place`. The turn timer plate stays. Checked in Studio: the pin sat exactly under the pointer, faded inside a
dune, solid in the air, and a click placed it (`Placed` true, the pin dropped in on the spot).
For the wiki: the drop's screenshot shows the pin under the pointer, no ring.

**Polished after the owner's fourth look (same day).** "You can add some kind of circle or target on the select where
to land - but make it subtle. It's good now - just polish it up." The picking is unchanged. The pin's tip now sits on a
small target: the aim crosshair's ring (a line in the snail's colour over a thin dark one) with a dot on the exact
spot, under the pin (DropMarker's `S_Target`: `S_RingLine`, `S_Dot`, 63 px across at design scale, the billboard now
150 × 222 with the tip 190 down). It fades with the pin where a snail doesn't fit and pops in from 1.6 times its size
when the spot is placed (Match's `DROP_TARGET_POP`, `DROP_TARGET_TWEENINFO` 0.35 s back out). Checked in Studio: the
target's middle sat on the pin's tip and on the pointer's spot, and placing popped it in.
For the wiki: the drop's screenshot shows the pin standing on its small ring.
