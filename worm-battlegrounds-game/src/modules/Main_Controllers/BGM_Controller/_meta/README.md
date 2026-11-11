# BGM_Controller

The game's background music and ambience. Once the player has loaded, it plays the `BGM` music (a name from `src/global_data/Sound/SoundsList.lua`) looped, at half volume, in the `Music` sound group, unless another module already chose a track; in this game Atmosphere's moods choose it (the lobby's theme, each map's track and its sudden-death version). No ambient sound starts on its own, since the game's music carries its ambience. Other modules switch the music or an ambient sound by name; the new sound fades in while the old one fades out and is removed.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/BGM_Controller` |
| Runs on | Client |
| Exposes | `I.BGM_Controller` (client) |
| Uses | `I.Sound`, `I.OnLoaded`, `TweenService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The start track, switching and crossfading the music and an ambient sound |

## API

### Client: `I.BGM_Controller`

| Function | Returns | What it does |
| --- | --- | --- |
| `Play(trackName: string, fadeTime: number?)` | | Switches the music to that `SoundsList` name, crossfading over `fadeTime` seconds (default `0`). Does nothing when it is already playing; keeps the current music when the name doesn't play. |
| `Stop(fadeTime: number?)` | | Fades the music out and removes it |
| `SetAmbient(name: string?, fadeTime: number?)` | | Switches the ambient sound to that name, or stops it when `name` is nil |

## Usage

```lua
-- Entering a boss arena
I.BGM_Controller.Play("BossFight", 2)
I.BGM_Controller.SetAmbient(nil, 2)
```
