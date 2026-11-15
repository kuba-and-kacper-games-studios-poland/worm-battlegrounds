---
title: "The grey spawn block no longer shows in the middle of the Desert's lava"
date: 2026-11-15
status: open
kind: fixed
pages: ["Desert"]
files: []
---

**What changed.** The owner saw a grey block in the lava at the middle of the new Desert map. It was the place's
spawn, `Workspace.Ume.BaseSpawn` (a 10 × 1 × 10 SpawnLocation at 0, 0.5, 0), which stands under every map at X 0 and
poked through the Desert's lava, lower than other maps' liquid. The spawn and its decal are now tagged `HideOnPlay`,
so every client hides them (Transparency 1) while the game runs; the server keeps them, so avatars still spawn and
park as before.

**Where.** In the place, not in code: the `HideOnPlay` tag on `Workspace.Ume.BaseSpawn` and its `Decal`.

**How to check.** In a match on the Desert, nothing grey shows in the lava at the map's middle. In a playtest, the
client's `BaseSpawn.Transparency` is 1.

**For the wiki.** Probably nothing, unless the Desert page mentions the block.
