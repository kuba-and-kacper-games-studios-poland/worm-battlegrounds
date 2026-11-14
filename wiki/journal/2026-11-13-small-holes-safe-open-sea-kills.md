---
title: "Only the open sea knocks out: small holes and puddles are safe (SEA_MIN_WIDTH 16)"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modes & maps", "Desert", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Move.lua
---

**What changed.** The owner: holes in the ground killed on Desert and on Lakeside Showdown (the lily pad map), "if
the hole is big enough it insta kills you, but if there's a smaller hole the water is good, also small puddles
shouldn't insta kill you". Before, any liquid at or below the sea level plus `SEA_SLACK` (1) knocked a snail out, and
every cell of the sea's kind under that level seeded the sea mark, so lake water that ran into a low crater turned the
whole lake into sea. Now:

- The sea is marked only from the liquid grid's sides and floor (and what of its kind touches that), so water pooled
  low in a hole on the land isn't the sea.
- It knocks out only where it's **open**: joined to the sea, no higher than `SEA_SLACK` over its level, and the
  surface over the snail (up the liquid in its column) is at least `SEA_MIN_WIDTH` = 16 studs across. A snail below
  the land's floor (the bottom of the lowest bedrock, `Loader.GetFloor`) is in the sea under the islands and goes out.
- So: the sea around the islands still knocks out; a pond (Desert's oasis, Lakeside's lake), a puddle, or a crater up
  to about a Grenade's (radius 6.9) that the sea seeps into is safe; a Dynamite (9) or Black hole (14) crater it
  floods is the sea. A hole cut through the land's floor drops a snail into the sea below, which still knocks out.
  Heads under water still lose Match's `UNDERWATER_DAMAGE` (5) a turn, as in ponds.

**Where.** `Liquid.IsOpenSea(position)` and the seeding in `Liquid._markSea` (`Scripts/Server/Liquid.lua`);
`Module.GetHazard` in Arena's `Server.lua` (checks the position and `SEA_SLACK` under it); `SEA_MIN_WIDTH` in Arena's
`Settings.lua`. Bots read `GetHazard` everywhere, so they learn it with no change.

**How to check.** In the PC gym, stacked Bazooka-sized craters near the shore on Picnic Plains and Volcano Isle held
sea water and were safe at the top; Black hole-sized ones were deadly; Desert's oasis and Volcano's lava pools were
never deadly (measured 2026-11-13 with a scratch script). Lakeside Showdown isn't in the gym's saved place yet, so its
lake floor wasn't measured; in Studio, blast a hole in the lake bowl and swim in it.

**For the wiki.** Arena (or the page that explains hazards): "only the open sea knocks you out"; small holes and
puddles are safe, big flooded craters count as sea; the width (16 studs) in plain words ("wider than a Grenade's
crater"). The map pages that mention the sea or ponds (Desert's oasis, Lakeside's lake).

Supersedes the knock-out rule of 2026-11-08-only-the-sea-kills and the "below the sea level" part of
2026-11-10-obsidian-and-the-sea-swallows-ponds; a pond the rising sea reaches still becomes the sea.
