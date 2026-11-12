---
title: "Every map plays at X 0, so the map shows while players place their snails"
date: 2026-11-12
status: open
kind: fixed
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
---

**What changed.** The owner: "the volcano is not rendering until bots appear, like until everyone places and the
game starts". Volcano Isle showed an empty arena through the whole drop phase. The place streams
(`Workspace.StreamingEnabled`, `StreamingTargetRadius` 1024 studs): a client gets only the parts near its
`ReplicationFocus`, and until a player's snail spawns that's their avatar, parked at the spawn (0, 0.5, 0). Each match
played where its map's template stood, in MapLab's 400-stud slots: Picnic Plains at X 0 and Rockslide Ridge at 800
were in reach, Volcano Isle at 1200 wasn't. Now every map plays at X 0, by the spawn, whatever its slot, so its parts
reach every player from the moment it loads. Streaming is unchanged. The templates still stand side by side in their
slots in Studio (X 0, 400, 800, 1200), so they never overlap there.

**Where.** `Module._cacheTemplates` in `Arena/Scripts/Server/Loader.lua`, phase Placing: each template is moved along
X so its `Bounds` marker stands at X 0, once, when the Arena caches it at start (the copy in ServerStorage; the place's
template doesn't move). Supersedes the Arena README's "a match plays wherever its template stands".

**How to check.** Studio Match playtest on Volcano Isle, 2026-11-12: through the Drop phase the client had all 479
terrain parts, at X −134 to 138, before any snail spawned; the match played on.

**For the wiki.** Architecture: maps are authored in 400-stud slots, but every match plays at X 0 (streaming reaches
only 1024 studs from a player's avatar until their snail drops). Match modules (the drop phase): the map is there from
the start. Nothing for players unless a page says the map appears late.
