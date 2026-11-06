---
title: "Blasts flash, smoke, throw the ground, shake the camera and vibrate phones"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen", "Arsenal", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/global_data/Haptic/Preset.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** A blast used to be a neon ball that swelled and faded, plus Roblox's classic explosion puff. Now
each blast draws a white flash, an orange fireball (gold for shiny weapons), a short light, and bursts of fire,
sparks and smoke, and throws up to 16 chunks of the ground it hit, in that ground's colours (grass, dirt, a tree's
leaves). The chunks are 0.3 to 1 stud blocks that fly out, bounce and settle on the terrain, lie there for 2.5
seconds and fade; they pass through worms and shots. Bullets and swings flash where they land. The camera shakes along the arena with a little roll, harder for
bigger blasts and those nearer the middle of the view (none past 90 studs). Phones and controllers vibrate: a short
tick when the player fires, a thump for a big or near blast and a lighter one for a small or far one, and a longer
rumble when the player's own worm is hurt. Nothing shakes or vibrates in the lobby. Still no sounds.

**Where.** `Combat/Scripts/Client/Effects.lua` (the `Combat_Explosion`, `Combat_Tracer` and `Combat_Hit` remotes
from the server, which didn't change). Numbers in `Combat/Settings.lua` → Blast Feel: `FEEL_FULL_RADIUS` 10 (a blast
this big is felt at full strength), `FEEL_RANGE` 90 studs, `SHAKE_MAGNITUDE` 4, `SHAKE_SETTLE` 0.45 s,
`HAPTIC_BIG` 0.6 and `HAPTIC_SMALL` 0.15 (strength thresholds), `DEBRIS_MAX` 16, `DEBRIS_SPEED` 25–50,
`DEBRIS_SIZE` 0.3–1, `DEBRIS_LIFETIME` 2.5 s. The chunks are in the `Chip` collision group (Arena's
`COLLISION_GROUPS`), which collides with `Terrain` only. Particle
pictures are placeholders in `BLAST_TEXTURES` (Roblox's built-in `smoke_main`, `fire_main`, `sparkles_main`).
Haptic presets `Combat_Fire`, `Combat_BlastSmall`, `Combat_BlastBig`, `Combat_Hurt` in
`src/global_data/Haptic/Preset.lua`; the fire tick is played in MatchHud's `Aim._fire`. MatchCamera now updates at
the `Camera` render priority so the shake lands on top of it.

**How to check.** In a Studio match, a Bazooka blast shows the fireball, sparks and green and brown chips, and the
view jolts (measured up to about half a degree of roll from bot shots). Vibration can only be felt on a phone or with
a controller, not in Studio.

**For the wiki.** Match screen: a line that blasts shake the screen and phones and controllers vibrate (on firing, on
blasts, when your worm is hit). Arsenal: blasts throw chunks of the ground that land and fade. Controls & platforms: which moments vibrate on
phones and controllers. A History line on each. No setting turns the shake or vibration off yet.

**Unsure.** The haptic strengths and shake sizes were set by eye and not felt on a real phone yet.
