---
title: "Water no longer stops at where fallen terrain used to be"
date: 2026-11-08
status: open
kind: fixed
pages: ["Arena", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
---

**What changed.** When a blast cut a piece of terrain loose and it fell, water and lava kept treating the spot the
piece fell from as solid ground. They wouldn't flow into it, so water hung at invisible walls in the shape of the old
ledge and didn't fill the hole. Now the liquid looks again at where each falling piece came from, once it lands or
falls out of the arena.

**Where.** `Debris._watch` measures the falling group's box before it moves (`getBox`) and calls
`Liquid.Refresh` on it after the group lands or is removed; it already refreshed where the group landed.

**How to check.** Not reproduced directly: tester reports weren't on the wiki's boards. Carving at the sea's shore and
beside ponds on PicnicPlains (`arena carve`) settled the water in 1.5 s with no errors. A pond whose bank was cut off
should now pour into the gap. Also seen and unchanged: every pond touching the sea is one body, so a new hole down to
sea level fills from the top of any of them, even far away.

**For the wiki.** Arena: falling terrain frees the space it left for water and lava.
