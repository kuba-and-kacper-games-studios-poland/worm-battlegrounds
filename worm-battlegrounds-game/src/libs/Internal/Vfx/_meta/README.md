# Vfx

Particle effects made in Studio, played from code. Each effect is a prefab part in the place with its
ParticleEmitters (on it or on its Attachments); playing one copies it to a spot, fires every emitter by its
attributes, and removes the copy once its last particle is gone. Trail prefabs hand their Trail to another part.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Vfx` |
| Exposes | `I.Vfx` |
| Runs on | Client (works on the server too: what it makes there replicates) |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Playing, emitting, scaling and trails |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Vfx.Play(name: string, cframe: CFrame, parent: Instance, scale: number?)` | `BasePart?` | Copies the `name` prefab to `cframe` in `parent`, scaled, fires it (`Emit`) and removes it when done. Nil when the prefab is missing |
| `I.Vfx.Emit(root: Instance, scale: number?)` | `number` | Fires every ParticleEmitter under `root` by its attributes (below), after scaling it; returns the seconds until its last particle is gone |
| `I.Vfx.AddTrail(name: string, part: BasePart)` | `{ Trail }` | Copies a trail prefab's Trails (a prefab may layer several) and their attachments onto `part`, at the same offsets they have on the prefab's part, and its other attachments with what they hold (an exhaust's emitters, as the prefab has them); none when the prefab is missing |
| `I.Vfx.Get(name: string)` | `BasePart?` | The `PREFAB \| <name>` part in `Assets/Vfx`; warns and returns nil when it's missing |

A scale resizes the particles, their speed and acceleration, and the attachments' offsets, so an effect made for one
size fits a smaller or bigger one.

## Emitter attributes

The common Studio VFX convention, set on each ParticleEmitter:

| Attribute | Default | What |
| --- | --- | --- |
| `EmitCount` | none | Particles emitted at once. An emitter without it is a stream: it runs for 1 second (`STREAM_SECONDS`) |
| `EmitDelay` | `0` | Seconds after the play before it fires |
| `EmitDuration` | `0` | When above 0, the emitter streams at its `Rate` for that many seconds instead of a burst |

Emitters stay `Enabled = false` in their prefabs; `Emit` turns streams on and off.

## In the place

Prefabs live in `Workspace.Ume.ReplicatedStorage_Assets/Vfx/`, moved into `ReplicatedStorage.Ume.Assets`
(`I.Dirs.Assets`) when the game starts. Each is an anchored, invisible part named `PREFAB | <name>` (a trail prefab
keeps its visible mesh, as a guide for its attachments), standing in a row from X −300 at Y −14. They came from the
studio's `Particles_1` and `Particles_2` folders (2026-11-09), the trails from the studio's `Trails_New` (2026-11-11):

| Prefab | From | Played by |
| --- | --- | --- |
| `Explosion` | Explosion (LE Impact) | Combat: blasts under 6 studs |
| `Explosion_Fire` | Explosion (Orange flame circle) | Combat: blasts from 6 studs |
| `Explosion_Big` | Explosion (Impact12) | Combat: blasts from 9 studs |
| `Explosion_Gun` | Gun Explosion | Combat: where each bullet lands |
| `Flash_Bullet` | Bullet Flash | Combat: where each bullet lands |
| `Flash_SMG` | SMG Flash | Combat: the Uzi's and Minigun's muzzle |
| `Flash_Sniper` | Sniper Flash | Combat: the Shotgun's muzzle |
| `Punch` | Saitama Punch | Combat: One Punch, along the swing |
| `Spawn` | Spawn | Snails: a snail appearing |
| `Fall` | Fall | Snails: a snail landing from a fall |
| `Splash_Water`, `Splash_Lava` | Water Splash, Lava Splash | Snails: a snail knocked out in water or lava |
| `Healing` | Healing | Snails: a snail healing |
| `Trail_Snail` | Snail (its trail) | Snails: a trail on each snail while it flies |
| `Trail_Jet` | Trails_New: jet (BeamFilled wavey) | Snails: the jetpack's jet while a snail climbs on it |
| `Trail_Smoke` | Trails_New: smoke (BeamWavey fog, made a little grey and subtler), plus an `Exhaust` attachment: `Smoke` (soft grey puffs) and `Thruster` (a tiny orange flame), both off | Combat: the Bazooka's and Homing missile's shots |
| `Trail_BlackHole` | Trails_New: blackhole (BeamNoise cloud, BeamChromatic Thick) | Combat: the Black hole grenade's shot |
| `Trail_Variety` | Trails_New: verity (BeamGlow strays) | Combat: the Variety grenade's shot |
| `Aura_Speed` | An `Aura` attachment: `Spark` and `Bolt` (Glint's spec, cyan and the bottle's yellow), `Streak` (Wind_Streak's, pale cyan), all off (2026-11-12) | Snails: around a snail under the Speed potion, streaming while it lasts |
| `Aura_LowGravity` | An `Aura` attachment: `Bubble` (Splash_Water's Bubble 2) and `Motes` (Ambient_Motes'), violet, drifting up slowly, both off (2026-11-12) | Snails: around a snail under the Low gravity potion, streaming while it lasts |

The Spear's and the Bat's trails are on their Arsenal models instead (Arsenal's README → In the place).

## Usage

```lua
-- A blast 9 studs across, made for 6.5
I.Vfx.Play("Explosion_Big", CFrame.new(position), effectsFolder, 9 / 6.5)

-- A trail that shows only while it's enabled
local trails = I.Vfx.AddTrail("Trail_Snail", model.PrimaryPart) --- @type { Trail }
```
