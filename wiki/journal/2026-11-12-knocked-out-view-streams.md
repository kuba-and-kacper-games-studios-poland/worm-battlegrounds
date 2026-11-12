---
title: "After your snail is knocked out, the map stays loaded and the camera keeps working"
date: 2026-11-12
status: open
kind: fixed
pages: ["Match screen", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
---

**What changed.** Found while testing the camera. Streaming sends each player the arena around their snail (Snails
sets the player's `ReplicationFocus` to its ball when it spawns). A knocked-out snail's ball ended up about 1,000,000
studs below the arena, still the player's focus, so their screen dropped the whole map (7 of 491 terrain parts left,
the `Bounds` marker gone). The camera then stopped moving for the rest of the match, and Arena's client `Carver`
errored on every blast (`attempt to index nil with 'Position'`).

Now a knockout hands the player's focus back to their parked avatar (`ReplicationFocus = nil`), which waits at X 0 by
every map (CharacterPark's `PARK_POSITION`, and 2026-11-12-maps-play-at-x0), so the arena stays loaded while they
watch. What moves the ghost's ball that far down wasn't found; nothing in the game's code sets that position.

**Where.** `Kill` in `Snails/Scripts/Server/Health.lua`, the Streaming phase.

**How to check.** Studio bot match, 2026-11-12: after the player's snail was knocked out, about 510–530 terrain parts
stayed on their screen (the rest carved away), and the camera glided to each bot's turn as before.

**For the wiki.** Architecture, streaming: a knocked-out player streams around their parked avatar.
