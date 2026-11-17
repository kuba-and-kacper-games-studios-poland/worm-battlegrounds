---
title: "The spider bomb is the studio's rigged spider and walks as it crawls"
date: 2026-11-17
status: open
kind: changed
pages: ["Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/_meta/README.md
---

**What changed.** The spider bomb's model is now the studio's rigged spider (`Workspace.NEW_STUFF.Spider`): the same
red web-patterned bomb on six legs, now with bones. While it crawls toward the nearest enemy, it plays the studio's walk
cycle: a 0.25 s loop where all six legs step in turn and the body bobs slightly. Its legs rest while it's thrown and
while a snail holds it. Size, crawl speed, damage and everything else are unchanged.

**Where.** In the place: `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/Models/SpiderBomb` holds `RootPart` (with the
`Muzzle` as before), `Body` (the skinned mesh, 37 bones), an `AnimationController` and a `Walk` Animation
(`rbxassetid://79819469630860`, "Snail Spider Walk", uploaded to The Snail Studio group and approved). The old static
model is kept in `ServerStorage.!dump` as `SpiderBomb_2026-11-17_static`. In code: Combat's client `Flight` plays the
model's `Walk` when it draws a part the server moves (the crawl part: anchored, not `Simulated`). The studio's rig held
two copies of the same walk (`1`, `1_1`) and an empty `Untitled`; one was published.

**How to check.** Throw a spider bomb in a match. It flies with its legs still, then walks its legs while it crawls to
its target.

**For the wiki.** Arsenal: Spider bomb, a note that it scuttles on six legs as it crawls, and a History line.
