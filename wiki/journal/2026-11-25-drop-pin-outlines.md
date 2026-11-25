---
title: "Drop pin outlines match its name's outline (about 2.7 px)"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DropMarker/init.lua
---

**What changed.** The owner asked for the drop pin's strokes to fit its name's text outline. The pin's head and point
had 4 px outlines and the landing ring's dark edge showed about 1.3 px each side, against the name's 2.7 px. Now every
dark outline on the pin is about 2.7 px at design size, each a fraction of its own frame (`ScaledSize`), so it scales
with the billboard: head 0.029, point 0.066, the ring's dark line 0.165 under the 0.08 coloured line, the dot 0.3.

**Where.** The DropMarker gui's `S_Head`, `S_Point`, `S_Target` › `RingOutline` and `S_Dot` strokes.

**How to check.** In the drop phase, the pin's head, point and ring have outlines as thick as the outline round the
player's name.

**For the wiki.** Nothing, unless a page shows the drop pin's look.
