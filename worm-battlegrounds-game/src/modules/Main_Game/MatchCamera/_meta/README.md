# MatchCamera

The side-on match camera. Once a map is loaded it is a scriptable camera looking along −Z from `DISTANCE` studs away
with a narrow `FOV`, so the arena reads as flat. It follows a flying shot (parts with the `Projectile` attribute)
while the player's `CameraFollowsShot` setting is on, else the active worm (its `Active` attribute), else the local
player's worm, else the arena's middle, and stays inside the arena's bounds. Players pan by dragging with the right
mouse button, two fingers on touch, or the right stick while LT is held; the pan resets when the camera follows
another worm. It locks the FOV_Controller while it runs. While the player isn't in the match (the `InMatch` Player
attribute, on the Studio map's lobby) it gives Roblox's camera back. It creates no remotes, Topics or saved data.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchCamera` |
| Runs on | Client |
| Uses | `I.Worms` (client), `I.FOV_Controller`, `I.PlayerSettings`, `UserInputService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Following, panning, clamping to the bounds |
| `Settings.lua` | `MatchCamera_Settings`: the view and panning |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `FOV` | `30` | Field of view |
| `DISTANCE` | `110` | How far in front of the plane the camera sits |
| `FOLLOW_SPEED` | `6` | How quickly it catches up with what it follows |
| `STICK_PAN_SPEED` | `60` | Right-stick panning speed at full lean, in studs per second |
| `STICK_DEADZONE` | `0.2` | How far the right stick must lean |

## In the place

Reads `Workspace.Ume.Arena.Markers.Bounds` (the loaded map's play area), `Workspace.Ume.Worms` and
`Workspace.Ume.Combat`.
