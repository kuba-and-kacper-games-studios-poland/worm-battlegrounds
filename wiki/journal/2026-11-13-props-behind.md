---
title: "Trees, bushes and rocks stand behind the snails (2.5 studs back, flattened when too deep)"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** At load every prop moves back so its front is `PROP_BEHIND_GAP` behind the play plane, but its
pivot stays `PROP_GROUND_MARGIN` 0.5 studs in from the ground's back, so snails pass in front of trees instead of
through them (they never collided; they only looked like it). A second round, the same day (the owner: "snails can
hide for example in rocks or trees"): the gap went from 1.5 to 2.5 studs (half a snail's 5-stud length, so a snail
facing the camera in an emote clears it too), and a prop too deep to get that far back with its pivot on the 10-stud
ground is now flattened along Z about its pivot until its front is there (Props' `_flatten`: each part's distance
from the pivot and its depth along Z shrink, and a block turned off the axes is re-fitted to its squashed shape). The
camera looks along −Z, so a flattened tree keeps its outline, but turned leaf blocks lose some width: pines and
canopies look up to a third narrower from the front. The owner picked this over moving deep trees past the ground's
back edge at full size, where some sank behind hills (2026-11-13, compared in Studio on Picnic Plains). Before it, 45 of the 66
props on the four maps that have them still reached the snails (the oaks, pines, birches, palms and the big bushes,
up to 12.8 studs deep). Measured on copies of the templates with the same steps: every prop's front ends 2.4 studs or
more behind the plane on Picnic Plains, Desert, Volcano Isle and Training Meadow; the oaks keep about a third of their
depth, the deepest flattening. Rockslide Ridge has no props.

**Where.** Arena's `Props.Collect` and `_flatten`; `PROP_BEHIND_GAP` 1.5 → 2.5 in Arena's Settings.

**How to check.** Walk past a tree or a rock, or emote beside one: the whole snail stays in front of it. From the
match camera the trees look as before.

**For the wiki.** Match modes & maps: maps' props stand behind the play, so nothing hides a snail.

**From.** The testers: "trees behind so you dont collide"; then the owner, 2026-11-13.
