# FOV_Controller

The camera's field of view follows the `FOV` buff. Whenever the buff's sum changes (`Buff_Updated-FOV`), the camera tweens to it, kept between `MIN_FOV` and `MAX_FOV`. A camera with its own field of view (the lobby stage, MatchCamera) sets it as the buff's base, `I.Buff.Set("FOV", "Standard", fov)`, so other values (an open widget's) still add to it. Modules that need the camera to themselves (a cutscene, a scope) lock it by name so buff changes wait.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/FOV_Controller` |
| Runs on | Client |
| Exposes | `I.FOV_Controller` (client) |
| Uses | `I.Buff` (the `FOV` buff), `I.Topic`, `TweenService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Following the `FOV` buff, the locks |
| `Settings.lua` | The allowed range |

## API

### Client: `I.FOV_Controller`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetLock(lockName: string)` | | Stops automatic updates while any lock is set, and cancels a tween that is still playing |
| `ClearLock(lockName)` | | Removes that lock |
| `UpdateCameraFOV(tween: boolean?)` | | Sets the camera to the buff's current sum, tweened with `tween` |

## Usage

```lua
-- Zoom a little while sprinting
I.Buff.Set("FOV", "Sprint", 10)
```

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MIN_FOV`, `MAX_FOV` | `12.5`, `120` | Range the field of view is kept in |
