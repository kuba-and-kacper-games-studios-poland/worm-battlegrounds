---
title: "Floating ledges and props that react to blasts"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** Floating ledges used to hang on one unbreakable block each, and on Picnic Plains one of those was a
thin dirt plate under a tree that stayed hanging over the crater after a blast. Now no ledge block is unbreakable:
ledges float on their own, and a piece cut off a ledge keeps floating while it is at least 24 square studs; smaller
crumbs fall. Trees, bushes and rocks react to blasts: one the blast reaches is thrown away from it and up (35 studs
per second) with a spin, and one whose ground is blasted away falls. Either way it lies for 3 seconds, fades out over
1 second, and is gone. Island ground still holds on its waterline blocks, which can't be cut.

**Where.** Attributes in the map: `Arena_Floats` on every ledge part (120 parts on Picnic Plains; carved pieces keep
it), `Arena_Prop` on each tree, bush and rock under `Decor`. `_getGroup()` in `Arena/Scripts/Server/Debris.lua`
keeps a group up when its `Arena_Floats` parts cover `FLOAT_MIN_AREA` (24). `Arena/Scripts/Server/Props.lua`
(`Collect` on load, `Update(center, radius)` after each carve): `PROP_SUPPORT_DEPTH` 1.5, `PROP_KNOCK_SPEED` 35,
`PROP_KNOCK_SPIN` 6, `PROP_FADE_DELAY` 3, `PROP_FADE_TWEENINFO` 1 s, in `Arena/Settings.lua`.

**How to check.** Played on the Match map in Studio, the bots shooting for 100 seconds: blasts carved round craters
through ledges and islands with nothing left hanging, no ledge fell, and two pines, a birch, a rock and an oak were
thrown (about 50 studs per second) and faded out, with no warnings. Not seen yet: a prop falling because only its
ground was blasted, and a small ledge crumb falling.

**For the wiki.** Match modes & maps → Picnic Plains: the ledges float and can be blasted apart; trees, bushes and
rocks get blown away. Architecture's terrain section: floating terrain (`Arena_Floats`) next to indestructible
ground, and props.

**Merged.** Props being thrown whole was replaced by props breaking (2026-11-05-props-break).
