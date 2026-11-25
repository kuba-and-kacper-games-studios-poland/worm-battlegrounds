---
title: "Calm lobby stage: small pads, snails 1.5 → 1.9×, stepped hills and a painted sky"
date: 2026-11-24
status: open
kind: changed
pages: ["Lobby", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds.rbxl
  - art/lobby_sky/sky.py
---

**What changed.** The lobby stage is a quiet background so the snails carry the colour (the owner: "the rest is just
a background"). The pods are rebuilt Fortnite-style: small pads, the player's front pad glowing cyan with a light,
the free ones smaller, darker and faded. The camera sits lower and flatter. The meadow lost its decorations,
lanterns, fences, hedges, stone ring, path, waterfall, voxel clouds, the trees near the pods and the brick cliff walls;
a `Backdrop` of stepped Lego-like hills stands behind it (two near hills framing the sides with a tree each, a rolling
ridge with a dip in the middle, a hazier far line, a far ground slab). The stage snails are bigger, 1.9 times their
match size (was 1.5; the owner: "the snails are a bit bigger, near each other"). The lobby has its own painted sky
(`art/lobby_sky`).

**Where.** `STAGE_SNAIL_SCALE` in Lobby's `Settings.lua`. Everything else is in the place only: `PREFAB | Stage` in
`Workspace.Ume.ReplicatedStorage_Assets/Lobby` (its `Pods`, `Markers.Camera`, `Backdrop`); the originals are in
`ServerStorage.!dump`. The sky is Lighting's own Sky, renamed `Lobby Sky`, `CelestialBodiesShown` off, its six faces
uploaded to the group (ids in `art/lobby_sky/README.md`); the match presets in `Lighting.Presets` keep `Clear Sky`.
Muting the greens was tried the same day and undone: the scene's colours are the original ones.

**How to check.** Open the lobby: small pads, no clutter, hills behind, the painted sky; the place must be saved and
published for live servers to get it.

**For the wiki.** Lobby: new screenshots of the stage; the snail scale. Architecture: the lobby sky is on Lighting
itself (the `Lobby` preset).

Supersedes the stage description of the 2026-11-15 and 2026-11-16 entries (platforms with ring beams, 1.5×); the
custom lobby's eight pods still hold.
