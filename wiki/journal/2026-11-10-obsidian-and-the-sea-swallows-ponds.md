---
title: "Lava turns water into obsidian, and a pond the rising sea reaches becomes the sea"
date: 2026-11-10
status: open
kind: added
pages: ["Match modes & maps", "Desert", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Obsidian.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
---

**What changed.**

- **Obsidian:** on a map holding both water and lava, water that touches lava (above, below or beside it) stops
  being liquid and hardens into obsidian: dark purple stud blocks that are part of the ground. Snails stand on it,
  and blasts cut it like any ground. Desert is the only such map now: its oasis hardens where sudden death's rising
  lava reaches it.
- **The sea swallows ponds:** the liquid that knocks snails out used to be only the sea up to its level (plus 1 stud).
  Now any liquid of the sea's kind joined to it counts as the sea, so a pond the rising sea floods into knocks snails
  out too, even above the sea's level. A pond on its own is still safe.

**Where.** In Arena's `Scripts/Server/Liquid.lua`: `Build` sets `reactive` when the map's markers hold both kinds;
each `_step` then runs `_react`, which takes every water cell with lava on one of its 4 sides out of the liquid,
marks it solid and hands the cells to the new `Scripts/Server/Obsidian.lua`. `Obsidian.Build(cells, cols, origin,
cell, depth)` merges them as the liquid is drawn (each row's runs with the same run in the row below) into anchored
parts named `Obsidian` in the map's `Terrain`: `OBSIDIAN_COLOR` (38, 28, 52), SmoothPlastic with `OBSIDIAN_VARIANT`
`"2022 Stud"`, `CollisionGroup` `Terrain`, as deep as the liquid. The sea: `Liquid._markSea` flood-fills a new `sea`
buffer from every cell of the sea's kind (water when the map has no sea) under the sea level, through all touching
cells of that kind; it runs after `Build`, after each `RaiseLiquid` and every `SEA_MARK_STEPS` (8) steps while the
liquid moves. New `Liquid.IsSea(position)`; `GetHazard` in `Arena/Server.lua` returns the liquid when
`position.Y <= GetSeaLevel() + SEA_SLACK` or `Liquid.IsSea(position)`. New Arena settings: `OBSIDIAN_COLOR`,
`OBSIDIAN_VARIANT`, `SEA_MARK_STEPS`. Narrows `2026-11-08-only-the-sea-kills`: ponds are safe only while the sea
hasn't reached them.

**How to check.** On Desert, run sudden death until the lava rises to the oasis (admin `match round 11`): where the
lava touches the oasis, dark obsidian blocks form, and a Bazooka shot carves them. On a map whose sea is water, let
sudden death raise the sea until it floods into a pond: a snail that falls into the pond's top is knocked out, though
it's above the sea's level plus `SEA_SLACK`. Not checked in Studio by the docs pass.

Bots read `I.Arena.GetHazard` in their predictions and walks (Bots' `Predict`, `Move`, `Sim`), so they treat a flooded
pond as the sea too; how low a spot is over the sea (the brain's `Low`) still reads only `GetSeaLevel`. They don't
foresee obsidian before it forms. Bots weren't retrained for either.

**For the wiki.** Match modes & maps (liquids): lava hardens water into obsidian ground; a pond the rising sea reaches
becomes deadly. Desert: the oasis can turn to obsidian in sudden death. Match modules: Arena's `Obsidian`,
`Liquid.IsSea` and the new settings.
