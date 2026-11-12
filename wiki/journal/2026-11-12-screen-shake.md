---
title: "Screen shake: a jolt then a rumble on blasts, and shakes on hits, knockouts and gunshots"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** The owner: "add screen shake on explosions and stuff like that to add more punch to it". Every
shake is now two layers: a sharp jolt (`SHAKE_KICK` 10, CameraShake's Magnitude, roughness 35, gone in
`SHAKE_KICK_SETTLE` 0.18 s), then a rumble (`SHAKE_MAGNITUDE` 4 → 6.5, roughness 14 → 12, settling over
`SHAKE_SETTLE` 0.45 → 0.7 s). Both move the view along the arena's plane with a little roll.

- **Blasts** shake as before by their size (full strength at a radius of 10, `FEEL_FULL_RADIUS`) and how close they
  are to the middle of the view (none past 90 studs, `FEEL_RANGE`), now with the stronger shake.
- **Hits on snails** (Combat's `Combat_Hit`, from blasts, guns and swings) add their own shake: full strength at 60
  damage (`HIT_SHAKE_DAMAGE`), plus 0.8 more on a knockout (`KNOCKOUT_SHAKE`), by the same distance rule. A blast that
  hits snails shakes harder than one that hits only ground.
- **Gunshots** (a gun's `Combat_Tracer`) kick the view a little each: 0.15 strength (`GUN_SHAKE`).

Phones and pads still vibrate as before (`HAPTIC_BIG`, `HAPTIC_SMALL`, `Combat_Hurt`). Falls, water and lava don't
shake: they don't fire `Combat_Hit`.

**Where.** `_onExplosion`, `_onTracer`, `_onHit`, `_shake` and `_getStrength` (now takes an amount, 1 being full
strength) in `Combat/Scripts/Client/Effects.lua`; the settings above in Combat's `Settings.lua`, Blast Feel.

**How to check.** Studio bot match, 2026-11-12: every blast and hit near the view rolled the camera, peaking between
0.2° and 1.4° for about 0.6–0.8 s (MatchCamera never rolls the view, so the roll is the shake). A blast that hit a
snail for 35 peaked at 1.37°. How strong it feels is the owner's call: the numbers above are where to turn it.

**For the wiki.** Match screen: blasts, hits and gunshots shake the screen, harder the bigger and closer they are.
