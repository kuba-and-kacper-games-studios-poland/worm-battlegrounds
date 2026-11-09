---
title: "The server snaps back a snail that leaves the arena's plane"
date: 2026-11-09
status: open
kind: fixed
pages: ["Controls & platforms", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/ServerSettings.lua
---

**What changed.** A player's client moves their snail, and only its own copy of the Plane constraint keeps it at the
arena's Z. An exploiter could drop the constraint and walk around walls in depth. The server now checks it like speed
and height: a snail more than `PLANE_SLACK` (0.5 studs) off the plane (`I.Arena.GetPlane()`) is snapped back with the
warning "left the arena's plane", and its turn is taken.

**Where.** `Module._checkSnail` in `SnailControl/Scripts/Server/Control.lua`; `PLANE_SLACK` in
`SnailControl/ServerSettings.lua`.

**How to check.** Walk and jump on your turn in a Studio match: there are no snap-back warnings, and Z stays 0. This
was checked on 2026-11-09. Leaving the plane on purpose wasn't tested.

**For the wiki.** Controls & platforms, or Architecture's server checks: add "stays on the arena's plane" to the
list of what the server checks.
