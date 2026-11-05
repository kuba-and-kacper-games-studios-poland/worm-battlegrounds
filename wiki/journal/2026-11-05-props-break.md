---
title: "Props break under blasts: trees, bushes and rocks are cut, their pieces fly off"
date: 2026-11-05
status: open
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.** A blast used to throw a whole tree, bush or rock it reached. Now it cuts its round hole through the
prop, like through the ground: what's left joined to the prop's base keeps standing, and every piece cut free flies
away from the blast and up (35 studs per second, a spin up to 6 radians per second), lies 3 seconds and fades out over
1 second. A blast through a trunk sends the whole crown flying; one at a crown's edge bites a hole in it. A prop
whose ground is blasted away still falls whole. Props never block worms or shots. This supersedes the "thrown" part
of the entry "Floating ledges and props that react to blasts".

**Where.** `Module.Update(center, radius)` in `Arena/Scripts/Server/Props.lua`: `_cut()` subtracts the blast's
cylinder from every part of the prop it reaches (`GeometryService:SubtractAsync`, box collisions), `_split()` keeps
the groups of touching pieces that reach the base and throws the rest as `<Prop>Piece` Models. New setting
`PROP_BASE_HEIGHT` 0.6 (a piece starting at most that far above the base stands on the ground); `PROP_KNOCK_SPEED`
35 and `PROP_KNOCK_SPIN` 6 now apply to the cut-off pieces; `PROP_FADE_DELAY` 3, `PROP_FADE_TWEENINFO` 1 s,
`PROP_SUPPORT_DEPTH` 1.5 unchanged. A one-part prop (a mesh, on maps not rebuilt) is still thrown whole.

**How to check.** Played in Studio on Picnic Plains, five blasts: an oak's crown got a round bite, a pine cut through
its trunk lost its top in two flying pieces (15 and 6 parts), a rock and a bush were cut. Each carve took 0.01 to
0.14 s, with no warnings. Not seen yet: a full match with bots shooting props.

**For the wiki.** Match modes & maps → Picnic Plains: trees, bushes and rocks break apart under blasts (pieces fly
off), instead of being thrown whole. Architecture's arena section: props are part-built and carved like the terrain.
