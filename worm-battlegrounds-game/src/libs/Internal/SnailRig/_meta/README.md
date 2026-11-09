# SnailRig

Animates the studio's rigged snail: its body motions (idle, walking, hiding in its shell and coming back out), a held
item in its hands in the item's pose, the hands and the weapon pitched toward the aim, and the weapon's shot. Each
side animates its own copies (every client animates every snail), so nothing replicates.

| | |
| --- | --- |
| Folder | `src/libs/Internal/SnailRig` |
| Exposes | `I.SnailRig` |
| Runs on | Client (works on the server too: animations there replicate as usual) |
| Uses | `I.G_Arsenal` (an item's `HoldPose`), `I.Create`, `I.Dirs.Assets` (the animations) |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Loading the animations, the motions, holding, aiming and shooting |
| `_meta/_types.lua` | `SnailRig_Rig`, one skin's parts and animation state |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.SnailRig.SetMotion(skin: Model, motion: "Idle" \| "Walk" \| "Hidden")` | | Plays a body motion: `Idle` and `Walk` loop; `Hidden` plays `Hide` and holds its last frame (in the shell); leaving `Hidden` plays `Show` once |
| `I.SnailRig.Hold(skin: Model, itemId: string?, weapon: Model?)` | | Plays the item's `HoldPose` (Arsenal row; `Gun` without one) paused on its first frame, and welds the weapon model's PrimaryPart to the skin's `Handle` at its `Grip` attachment (its RootPart without one), unanchored and massless. nil lets go; the caller destroys the old model |
| `I.SnailRig.SetAim(skin: Model, angle: number?)` | | The held weapon's aim (radians, 0 is +X, counterclockwise on the arena's plane); nil is level |
| `I.SnailRig.Shoot(skin: Model, seconds: number?)` | `number` | Plays the held pose's shot from the start for at least `seconds` (a burst), then pauses on its first frame again. Returns how long it plays, 0 when nothing is held |

A skin is set up the first time it's used and forgotten when it's destroyed. One without an `Animator`, a `Handle`
Motor6D on its PrimaryPart or the hand bones is left alone.

Each frame after the animations (`PreSimulation`), a held weapon's `Handle` and both hands move to the camera's side of
the snail, mirrored across its middle (the studio's rig holds weapons in the snail's right hand, which faces away from
the camera when it faces left), and the weapon and the pose's aiming hands (the weapon's hand for `Gun`, both for the
others) pitch about the `Handle` toward the aim, up to 90° either way. The weapon follows the `Handle` through physics.

## Animations

Read from `Assets/Snails/Animations` (the Snails README → In the place): an `Animation` per name, holding its
`KeyframeSequence`.

| Name | Loops | Priority | What |
| --- | --- | --- | --- |
| `Idle`, `Walk` | yes | Idle, Movement | The body at rest and walking |
| `Hide`, `Show` | no | Action2 | Into the shell (held on its last frame) and back out |
| `Gun`, `MiniGun`, `Bazooka`, `ShotGun` | paused | Action | A weapon's pose: its first frame while held, played through by `Shoot` |

An `Animation` with an `AnimationId` plays that. While it has none, Studio plays its keyframes
(`KeyframeSequenceProvider:RegisterKeyframeSequence`), and a live server warns once and leaves the snail unanimated.
Publishing: in Studio's Animation Editor, load each `KeyframeSequence` onto the `Classic` skin, publish it under the
game's owner (the studio's group), and paste the id into its `Animation`'s `AnimationId`.

## Rig names

A skin made for this rig keeps the studio's names: its PrimaryPart (`RootPart`) holds the bones, the hand bones are
`Bone.014.L` (the weapon's hand) and `Bone.014.R`, and the `Handle` Motor6D on the RootPart moves an invisible `Handle`
part.

## Usage

```lua
-- A snail walks, then holds a bazooka aimed 30° up and fires it
I.SnailRig.SetMotion(skin, "Walk")
local weapon: Model = I.G_Arsenal.GetModel("Bazooka"):Clone()
I.SnailRig.Hold(skin, "Bazooka", weapon)
I.SnailRig.SetAim(skin, math.rad(30))
weapon.Parent = effectsFolder
task.delay(I.SnailRig.Shoot(skin), function()
	I.SnailRig.Hold(skin, nil)
	weapon:Destroy()
end)
```
