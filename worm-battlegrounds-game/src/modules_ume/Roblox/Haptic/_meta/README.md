# Haptic

Controller and phone vibration from named presets, with a sound fallback. A preset (in `src/global_data/Haptic/Preset.lua`) says what plays: the haptic only, the haptic with a sound, only the sound, or `Dynamic` (the haptic where the device supports it, the sound otherwise). The client creates and plays `HapticEffect`s from presets with optional overrides, or plays a preset once and cleans up after it; the server asks a player's client to play one once.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Haptic` |
| Runs on | Server, Client |
| Exposes | `I.Haptic` (server, client) |
| Uses | `HapticService`, `I.Sound` (the sound channel), `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Creating `HapticEffect`s from presets, playing, stopping and destroying them, one-shot plays (a pooled haptic per preset), the sound channel, support detection |
| `Server.lua` | Validates a preset and asks a player's client to play it once |
| `_meta/_types.lua` | `Haptic_Mode`, `Haptic_Preset`, `Haptic_PresetOverrides`, `Haptic_ActivePlayback` |

## API

### Client: `I.Haptic`

| Function | Returns | What it does |
| --- | --- | --- |
| `Create(hapticId: string, overrides: Haptic_PresetOverrides?)` | `HapticEffect` | Builds an effect from the preset with the overrides applied, tagged with a `Haptic_UUID` attribute |
| `Play(haptic: HapticEffect)` | `HapticEffect?` | Plays it (and its sound, by the preset's mode); `nil` when neither channel could play |
| `PlayOnce(hapticId: string, overrides: Haptic_PresetOverrides?)` | `boolean` | Plays a preset with nothing to clean up. Without overrides it reuses one haptic per preset; with overrides it creates one and destroys it when both channels end or its `Duration` runs out. Rejects a `Looped` preset without a `Duration`. |
| `Stop(haptic)` | `boolean` | Stops it, keeping it for later |
| `Destroy(haptic)` | `boolean` | Stops and destroys it |

### Server: `I.Haptic`

| Function | Returns | What it does |
| --- | --- | --- |
| `Play(player, hapticId: string, overrides: Haptic_PresetOverrides?)` | `boolean` | Asks the player's client to play the preset once (`PlayOnce`). `false` for a player that isn't valid, an unknown or invalid preset, or a `Looped` preset without a `Duration` (nothing could stop it). |

## Usage

```lua
-- Client: one-shot feedback
I.Haptic.PlayOnce("Default")

-- Client: a haptic to stop later
local rumble: HapticEffect = I.Haptic.Create("Default", { Looped = true })
I.Haptic.Play(rumble)
I.Haptic.Destroy(rumble)

-- Server
I.Haptic.Play(player, "Default")
```

## Network

### Server

**Send: RemoteEvents**

- `Haptic_Play @ (player: Player, hapticId: string, overrides: table?)`

### Client

**Receive: RemoteEvents**

- `Haptic_Play @ (hapticId: string, overrides: table?)`: plays the preset once (`PlayOnce`).

## Data

| Where | Key | What |
| --- | --- | --- |
| `src/global_data/Haptic/Preset.lua` | `[hapticId]` | `Mode`, `Type`, `Looped`, `Duration`, `Position`, `Radius`, `WaveformKeys`, `SoundParams` (`Haptic_Preset`) |
