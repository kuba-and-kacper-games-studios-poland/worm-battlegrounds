---
title: "Studio particle effects for blasts, guns, the punch and snails"
date: 2026-11-09
status: open
kind: added
pages: ["Arsenal", "Match screen", "Match modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/libs/Internal/Vfx/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** The match plays the studio's own particle effects (from Studio's `Workspace.New.Particles_1` and
`Particles_2`) in place of the placeholder fireball, smoke and sparks made in code:

| When | Effect | Notes |
| --- | --- | --- |
| A blast | `Explosion` (radius under 6), `Explosion_Fire` (6 to 9), `Explosion_Big` (9 and up) | Scaled by radius ÷ 6.5. The flying chunks of ground, shake, sound and haptics stay |
| A gun fires | `Flash_SMG` (Uzi, Minigun), `Flash_Sniper` (Shotgun) where the shot leaves | |
| A bullet lands | `Flash_Bullet` and `Explosion_Gun` | The tracer lines stay |
| One Punch hits | `Punch` (Saitama-style shockwave), half size | |
| A snail appears | `Spawn` | |
| A snail lands from a fall | `Fall` (dust) | Same threshold as the landing sound |
| A snail heals | `Healing`, twice its size | When Health rises |
| A snail is knocked out in water or lava | `Splash_Water` / `Splash_Lava` | |
| A snail moves fast (over 45 studs/s) | `Trail_Snail` | Flying, knockback |
| The Spartan spear and the Baseball bat fly or swing | Their trails | The bat now has a model |

**Where.** New library `I.Vfx` (`Play`, `Emit`, `AddTrail`, `Get`) plays `PREFAB | <Name>` parts from
`ReplicatedStorage_Assets/Vfx` (place content, saved with the place). Combat's settings `BLAST_VFX`, `BLAST_VFX_RADIUS`
(6.5), `MUZZLE_VFX`, `PUNCH_VFX_SCALE` (0.5); `BLAST_TEXTURES` removed. Snails' new client `Effects` handler, settings
`TRAIL_SPEED` (45), `HEAL_VFX_SCALE` (2). The `BaseballBat` model and both trails are in
`ReplicatedStorage_Assets/Arsenal/Models`.

**How to check.** Studio, 2026-11-09: each effect played in a play test from the client at match camera distance;
the three blast sizes looked right. A full match with every weapon wasn't played yet.

**For the wiki.** Arsenal: the bat has a model; weapons' hit effects. Match screen: the effects table above.
Architecture: the Vfx library and where effect prefabs live.
