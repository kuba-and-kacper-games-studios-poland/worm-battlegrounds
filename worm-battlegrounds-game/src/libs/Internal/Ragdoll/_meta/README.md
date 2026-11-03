# Ragdoll

Ragdolls R6 and R15 characters and models: builds ball-socket constraints once, then switches between animated and ragdolled, with joint limits, colliders and launch velocity from presets.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Ragdoll` |
| Exposes | `I.Ragdoll` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The public functions |
| `Scripts/Build.lua` | Building and scanning the rig |
| `Scripts/Body.lua` | Joint limits, colliders, launching, the Humanoid state |
| `Data/Presets.lua` | Named presets |
| `_meta/_types.lua` | Preset, options and cache types |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Ragdoll.Rig(model: Model)` |  | Builds the ragdoll constraints of a character and keeps its joints on death. Safe to call more than once. Rig player characters on the server so the sockets replicate to every client. |
| `I.Ragdoll.SetJoints(model: Model, ragdoll: boolean)` |  | Swaps the motors for the ball sockets (or back). The root align only runs while ragdolled. Call it on the server too, so other clients see the loose joints. |
| `I.Ragdoll.Start(model: Model, options: Ragdoll_StartOptions?)` |  | Ragdolls a model with a preset feel (`Arcade` by default) and an optional launch and duration. Run it where the model's physics is simulated: the owning client for player characters, the server for NPCs. Rigs the model first when needed. A later call while ragdolled only extends the duration. |
| `I.Ragdoll.Stop(model: Model)` |  | Ends the ragdoll, restores joints and collision, and stands a living character back up. |
| `I.Ragdoll.GetPreset(presetName: string)` | `Ragdoll_Preset?` | Returns the ragdoll preset with this name. |
| `I.Ragdoll.IsRagdolled(model: Model)` | `boolean` | Returns whether the model is ragdolled by this environment. |

## Usage

```lua
I.Ragdoll.Start(character, { Preset = "Realistic" })
task.delay(3, I.Ragdoll.Stop, character)
```

## Types

In `_meta/_types.lua`: `Ragdoll_JointLimits`, `Ragdoll_Preset`, `Ragdoll_StartOptions`, `Ragdoll_SavedCollision`, `Ragdoll_SavedLimits`, `Ragdoll_RigCache`.
