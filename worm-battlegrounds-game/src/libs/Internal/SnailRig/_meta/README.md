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
| `I.SnailRig.SetMotion(skin: Model, motion: "Idle" \| "Walk" \| "Hidden")` | | Plays a body motion: `Idle` and `Walk` loop (`Walk` at 1.5× speed, `WALK_PLAY_SPEED`, with the walk's code motion over it: Walking, below); `Hidden` plays `Hide` at 1.8× speed with a 0.05 s blend (`HIDE_PLAY_SPEED`, `HIDE_FADE_TIME`, so it snaps in) and holds its last frame (in the shell); leaving `Hidden` plays `Show` once |
| `I.SnailRig.Hold(skin: Model, itemId: string?, weapon: Model?)` | | Plays the item's `HoldPose` (Arsenal row; `Gun` without one) paused on its first frame, and welds the weapon model's PrimaryPart to the skin's `Handle` at its `Grip` attachment (its RootPart without one), unanchored and massless. nil lets go; the caller destroys the old model |
| `I.SnailRig.SetAim(skin: Model, angle: number?)` | | The held weapon's aim (radians, 0 is +X, counterclockwise on the arena's plane); nil is level |
| `I.SnailRig.Shoot(skin: Model, seconds: number?)` | `number` | Plays the held pose's shot from the start for at least `seconds` (a burst), then pauses on its first frame again. Returns how long it plays, 0 when nothing is held |
| `I.SnailRig.Emote(skin: Model, emoteId: string, seconds: number)` | | Plays an emote: its animation, an `Animation` named after the emote (`Emote_Wave`) in `Assets/Snails/Animations`, once it exists; until then a stand-in motion made in code for `seconds` (Emotes, below) |
| `I.SnailRig.Pose(skin: Model, name: string?)` | | Holds a skin still in the first frame of one of its animations (`Idle` unless named, `STILL_ANIMATION`) by setting its bones' `Transform`s (the moves scaled by the model's scale), with no Animator: for a skin shown unanimated, as in a ViewportFrame. A skin's rest pose has the shell floating above its back and the hands held out; its animations put them in place. Warns when the animation has no keyframes |

A skin is set up the first time it's used and forgotten when it's destroyed. One without an `Animator`, a `Handle`
Motor6D on its PrimaryPart or the hand bones is left alone.

Each frame after the animations (`PreSimulation`), a held weapon's `Handle` and both hands move to the camera's side of
the snail, mirrored across its middle (the studio's rig holds weapons in the snail's right hand, which faces away from
the camera when it faces left), and the weapon and the pose's aiming hands (the weapon's hand for `Gun`, both for the
others) pitch about the `Handle` toward the aim, up to 90° either way. The weapon follows the `Handle` through physics.

## Walking

`Walk`'s own motion is small (the body moves about 0.4 studs, the shell 5°, the eyestalks a few degrees on a 5-stud
snail), and a held weapon's pose, which keys every bone at Action priority, hides it in a match. So while a skin walks,
SnailRig also moves it in code each frame, after the animations and before the aim (`PreSimulation`), on top of
whatever they set, held pose included:

| Part | Motion | Settings |
| --- | --- | --- |
| Body (`Bone`, carrying the whole snail) and the `Handle` Motor6D (the held weapon) | Each step lifts it 0.35 studs and rocks it ±6° forward and back about its base; the weapon moves with it, so the hands keep hold | `WALK_BOB`, `WALK_LEAN` |
| Shell (`Bone.013`) | Sways ±8° side to side once a cycle, and lifts 0.2 studs a beat after the body | `WALK_SHELL_SWAY`, `WALK_SHELL_BOB` |
| Tail (`Bone.009`, `Bone.010`, `Bone.011`) | Swings ±14° up and down, each bone a beat after the one before | `WALK_TAIL_SWING`, `WALK_LAG` |
| Eyestalks (`Bone.005.L/R`, then `Bone.006.L/R`) | Swing ±14° forward and back, lagging the body | `WALK_EYE_SWING`, `WALK_LAG` |

Two steps a cycle, 1.4 cycles a second (`WALK_CYCLES_PER_SECOND`); it blends in and out over 0.15 s
(`WALK_BLEND_TIME`), and each frame takes last frame's moves off first (as the emotes do), so a joint no animation moves
never builds them up. A skin missing one of these bones skips it.

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

## Emotes

The emotes' animations aren't made yet, so `Emote` plays a stand-in motion, applied each frame after the animations
(`PreSimulation`) on the body bone (the RootPart's first `Bone`, which carries the whole snail) and the hand bones,
toward the camera, so every screen draws it the same: it blends in over 0.18 s and out over 0.25 s
(`EMOTE_BLEND_IN`, `EMOTE_BLEND_OUT`), and each frame takes last frame's offsets off first, so a bone no animation
moves never builds them up.

| Emote | Stand-in |
| --- | --- |
| `Wave` | The hand nearer the camera raised and waving |
| `ThumbsUp` | A hop, a hand up and toward the camera |
| `Laugh` | A fast shake and bounce, the hands shaking |
| `Dance` | Swaying and hopping on a beat, the hands up in turn |
| `Flex` | Leaning back, both hands up and pumping |
| `Taunt` | Leaning in, the hands by the head wiggling |
| `Cry` | Drooping and sobbing, the hands to the face |
| `Backflip` | A full flip in the camera's plane over a 2.2-stud hop, in 0.9 s (`FLIP_SECONDS`, `FLIP_HEIGHT`) |
| `VictoryTrumpet` | Both hands high, bouncing |

An emote's animation, once published as an `Animation` named after it in `Assets/Snails/Animations`, replaces its
stand-in with no code change.

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
