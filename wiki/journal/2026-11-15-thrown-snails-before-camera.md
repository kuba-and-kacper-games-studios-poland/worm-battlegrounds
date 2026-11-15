---
title: "Thrown snails and their tags no longer stutter: they move before the camera aims"
date: 2026-11-15
status: open
kind: fixed
pages: ["Architecture", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Gear.lua
---

**What changed.** The owner, after the drawing clock fix: "the guis still glitch above snail, it's either the snail
glitching because of the physics or the gui above them". Measured in Studio: the tag is on the snail's ball and the
skin is welded to it, so they move as one; walking was clean, even with 150 ms of simulated lag. The fault was the
order of each frame: `PreRender` and `RenderStepped` handlers run after every `BindToRenderStep` function, MatchCamera's
included. Snails' `Flight` moved a thrown snail's ball on `PreRender`, so the camera always aimed at where it had been
a frame before, and the snail and its tag stuttered on screen as it flew. Gear (the jetpack and other worn pieces)
followed the ball from `RenderStepped`, in no set order with Flight.

Now `Flight` is bound as `Snails_Flight` at `Enum.RenderPriority.Camera` − 2 and `Gear` as `Snails_Gear` at
`Camera` − 1: the ball moves, the gear follows, then the camera aims, as Combat's shots already did.

**Where.** `Module._refresh` in `Snails/Scripts/Client/Flight.lua` and `Module._refreshLoop` in `Gear.lua` (each keeps
a `stepping` flag instead of a connection).

**How to check.** A thrown snail's tag and body glide without shaking while the camera follows it. In Studio, a probe
read each flying ball right after the camera and again before drawing: over 57 frames of flight it never moved after
the camera.

**For the wiki.** Architecture: what moves something the camera follows is bound before the camera. Builds on
`2026-11-15-smooth-shots-and-tags` (the drawing clock and the tag's redraws still hold).
