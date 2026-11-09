---
title: "The studio's rigged snail, with hands, animations and weapon poses"
date: 2026-11-09
status: open
kind: changed
pages: ["Arsenal", "Match modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Motion.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Bodies.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Uzi.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Minigun.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Bazooka.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/HomingMissile.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/Shotgun.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Backdrop.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The snail is the studio's rigged model (from Studio's `Workspace.New.Snails.Snail`) in place of
the static mesh, the same size (scaled 0.45, 4.1 studs tall). It's animated on every screen, in matches and in the
lobby's backdrop match:

| When | Animation | Notes |
| --- | --- | --- |
| Standing | `Idle` (2 s, looped) | |
| Walking | `Walk` (2 s, looped) | Moving along faster than 1.5 studs/s (Snails' `WALK_ANIMATION_SPEED`) |
| Thrown by a blast | `Hide` (the studio's `1`, 0.92 s), held in the shell | Faster than 25 studs/s while not controlled (`HIDE_SPEED`) |
| Landed | `Show` (the studio's `2`, 0.8 s) | Slower than 2 studs/s (`SHOW_SPEED`), at least 1 s after its last fast moment (`HIDE_SECONDS`) |
| Holding an item | The item's pose, first frame | Arsenal row's `HoldPose`: Uzi `Gun`, Minigun `MiniGun`, Bazooka and Homing missile `Bazooka`, Shotgun `ShotGun`; every other item in the `Gun` pose (one hand) |
| Firing a gun | The pose played through (its recoil) | Gun and MiniGun 0.17 s, Bazooka and ShotGun 0.75 s, at least the burst (`Pellets` × `BurstInterval`: Uzi 0.4 s) |

The held weapon now sits in the snail's hands (welded to the rig's `Handle` at the model's new `Grip` attachment),
not floating beside it, and pitches with the aim up to 90° either way; the hands follow. A snail facing left swaps its
hands over so the weapon stays on the camera's side, and a standing snail turns to face its aim (bots too, on the
server: Combat's `ShowAim`). Combat's `HELD_FORWARD`, `HELD_HEIGHT`, `HELD_DEPTH` and Lobby's `BACKDROP_HELD_HEIGHT`,
`BACKDROP_HELD_DEPTH` are gone.

**Where.** The new `SnailRig` library (`I.SnailRig`: `SetMotion`, `Hold`, `SetAim`, `Shoot`); Snails' client `Motion`
handler; Combat's `Held` (`_putAway` plays the shot); `Bodies.Spawn` welds only the skin's RootPart. In the place:
`Assets.Skins.Classic` (the rig; the old static one is in `ServerStorage.!dump.Classic_Static`),
`Workspace.Ume.ReplicatedStorage_Assets/Snails/Animations` (8 `Animation`s with their keyframes), and a `Grip`
attachment on the Uzi, Minigun, Bazooka, Shotgun, HomingMissile and BaseballBat models.

**How to check.** In a Studio match the snails idle, walk, hide in their shell when a blast throws them, and hold
the Bazooka on the shoulder; firing plays its recoil.

**For the wiki.** Architecture: the `SnailRig` library and Snails' `Motion` handler; how the snail is built (rig,
Handle, Grip). Match modules: Snails' animations and Combat's held weapon in the hands. Arsenal: which pose each gun
is held in.

**Still unsure.** The 8 animations aren't published: their `AnimationId`s are empty, so only Studio plays them, and a
live server shows the snail unanimated in its bind pose until the owner publishes them under the studio's group.
