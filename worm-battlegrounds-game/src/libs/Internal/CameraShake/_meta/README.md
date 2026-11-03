# CameraShake

Camera shakes from presets or configs. A shaker drives one camera and runs any number of shakes at once (looping or one-shot, with fades), adding their offsets each frame.

| | |
| --- | --- |
| Folder | `src/libs/Internal/CameraShake` |
| Exposes | `I.CameraShake` |
| Runs on | Client |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | `new` (a shaker) and presets |
| `Scripts/Shaker.lua` | A shaker on one camera |
| `Scripts/Shake.lua` | One shake |
| `Data/Presets.lua` | Named shake configs |
| `_meta/_types.lua` | Config, shake and shaker types |

## API

### I.CameraShake

`I.CameraShake.new(camera)` is `Shaker.new`.

| Function | Returns | What it does |
| --- | --- | --- |
| `I.CameraShake.GetPreset(presetName: string)` | `CameraShake_Config?` | Returns the shake config preset with this name. |

### Shaker

| Function | Returns | What it does |
| --- | --- | --- |
| `shaker:Play(config: CameraShake_Config, fadeTime: number?)` | `CameraShake_Shake` | Starts a sustained shake with a fade-in and returns its handle. |
| `shaker:PlayOnce(config: CameraShake_Config, duration: number, fadeInTime: number?, fadeOutTime: number?)` | `CameraShake_Shake` | Starts a shake that fades in, holds for `duration`, then fades out, and returns its handle. |
| `shaker:Stop(shake: CameraShake_Shake?, fadeTime: number?)` |  | Fades out one shake owned by this shaker, or every shake when none is passed. |
| `shaker:StopAll(fadeTime: number?)` |  | Fades out every shake on this shaker. |
| `shaker:Destroy()` |  | Stops every shake, restores the camera, and unbinds the render loop. The shaker cannot be reused. |

### Shake

| Function | Returns | What it does |
| --- | --- | --- |
| `shake:Play(fadeTime: number?)` |  | Starts (or restarts) a sustained shake with a fade-in. |
| `shake:PlayOnce(holdDuration: number, fadeInTime: number?, fadeOutTime: number?)` |  | Fades in, holds for the given duration, then fades out automatically. |
| `shake:Stop(fadeTime: number?)` |  | Starts the fade-out of the shake. |
| `shake:SetMagnitude(magnitude: number)` |  | Updates the shake magnitude while the shake is active. |
| `shake:SetRoughness(roughness: number)` |  | Updates the shake roughness while the shake is active. |
| `shake:SetPositionInfluence(influence: Vector3)` |  | Updates the position influence while the shake is active. |
| `shake:SetRotationInfluence(influence: Vector3)` |  | Updates the rotation influence while the shake is active. |
| `shake:Update(dt: number)` | `Vector3` | Advances the fade state and returns the current shake offset for this frame. |
| `shake:GetState()` | `CameraShake_State` | Returns the current lifecycle state of the shake. |
| `shake:IsActive()` | `boolean` | Returns whether the shake still contributes any motion. |

## Usage

```lua
local shaker = I.CameraShake.new(workspace.CurrentCamera)
shaker:PlayOnce(I.CameraShake.GetPreset("Explosion"), 0.3)
```

## Types

In `_meta/_types.lua`: `CameraShake_Config`, `CameraShake_State`, `CameraShake_Presets`, `CameraShake_Shake`, `CameraShake_Shaker`.
