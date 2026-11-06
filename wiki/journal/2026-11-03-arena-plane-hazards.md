---
title: "Arena: collision groups, the worm plane, GetHazard and Arena_Loaded"
date: 2026-11-03
status: merged
merged: 2026-11-06
kind: added
pages: ["Match modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** The Arena module gained what worms need:

- **Collision groups**, registered in the Loader's `Init` from `COLLISION_GROUPS`: `Terrain` (collides with
  everything), `Worm` (passes through other worms and through `Default` parts, so avatars and props), `Ghost`
  (collides with nothing). A loaded map's terrain parts join `Terrain`, and carved pieces keep their part's group.
  Architecture's `Projectile` and `Debris` groups don't exist yet: Combat will add `Projectile`, and falling debris
  stays in `Terrain`.
- **The plane**: `Load` makes an invisible `Plane` part at the Bounds marker's center holding a `Plane` attachment
  whose axis runs along Z. `I.Arena.GetPlane()` returns it, and each worm's `PlaneConstraint` uses it as
  `Attachment0`, so worms never leave Z = 0.
- **`I.Arena.GetHazard(position)`** replaces the planned `IsOut(position)`: `"Water"` or `"Lava"` in liquid,
  `"Bounds"` beside or below the Bounds marker (above it is fine), `nil` when safe.
- **`I.Arena.GetMarkers()`** returns the loaded map's Markers folder (the Studio shortcut finds the DropZone there).
- **Topic `Arena_Loaded @ (mapId: string)`**, published by `Load` once the template is in place and its liquids are
  filled.

**Where.** `Arena/Server.lua` (`I.Arena`, `GetHazard`, the Topic), `Scripts/Server/Loader.lua` (groups, `Plane`,
`GetPlane`, `GetMarkers`), `COLLISION_GROUPS` in `Arena/Settings.lua`.

**How to check.** In a Studio test, `Workspace.Ume.Arena.Plane` exists at the bounds' center, the terrain parts' collision
group is `Terrain`, and two worms walk through each other. Walking a worm off the map's side prints
`Worms_Died P_<id> Bounds` (with the Studio shortcut in WormControl).

**For the wiki.** Match modules → Arena: the API (`GetHazard` instead of `IsOut`, plus `GetPlane`, `GetMarkers`), and
the `Arena_Loaded` Topic. Architecture → Collision groups: `Worm` also ignores `Default`; `Projectile` and `Debris`
aren't made yet. Still not done from the P1 plan: `GetDropZone`, `BaseSpawn`, the map's lighting preset and gravity.
