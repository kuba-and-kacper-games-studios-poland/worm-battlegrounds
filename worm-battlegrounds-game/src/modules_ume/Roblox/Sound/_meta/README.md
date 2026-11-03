# Sound

Sounds by name. Sound names map to one or more asset ids in `src/global_data/Sound/SoundsList.lua` (several ids give variations, played at random or in order), and sound groups are defined in `SoundGroupsList.lua`. Either side plays a sound from params (where, which group, volume, pitch range, looping); the server can have one player, several players or everyone create the sound locally (no instance replication, the right choice for one-shot effects), and change or read a player's sound group volume. Each client preloads every listed sound in the background while it loads into the game, without holding the loading back.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Sound` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Sound` (both) |
| Uses | `SoundService`, `ContentProvider`, `I.Network`, `I.Player` (server), `I.Create`, `src/global_data/Sound` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Sound groups, preloading (client), playing, playing on clients, group volumes |
| `Settings.lua` | The default sound group, the load timeout of auto-removed sounds |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `sound` / `s_sound` commands |
| `_meta/_types.lua` | `Sound_Params` |

## API

### Global: `I.Sound`

| Function | Side | Returns | What it does |
| --- | --- | --- | --- |
| `Play(params: Sound_Params)` | both | `Sound?` | Creates and plays the sound; `Location` is a part, attachment, model or position (3D) or nothing (2D). `nil` when the name or asset id is unknown |
| `PlayForPlayer(player, params)` | server | `boolean` | That player's client creates and plays it |
| `PlayForPlayers(players: { Player }, params)` | server | `boolean` | Each listed player's client creates and plays it; players that aren't loaded are skipped |
| `PlayForAll(params)` | server | `boolean` | Every client creates and plays it |
| `ChangeSoundGroupVolume(soundGroupName: string, volume: number)` | client | `boolean` | Sets a group's volume |
| `GetSoundGroupVolume(soundGroupName)` | client | `number` | A group's volume |
| `GetSoundTableLength(soundName)` | both | `number?` | How many asset ids the sound name has |

Called on the client, `PlayForPlayer`, `PlayForPlayers` and `PlayForAll` play the sound locally, warn and return `false`. Use them for one-shot effects; keep server `Play` for sounds whose state every client must share, such as looping music on a part.

**`Sound_Params`:** `Name` (the sound name), `Volume`, `SoundTableIndex` (pick one variation), `Sequential` (play variations in order), `Location`, `FallbackPosition`, `SoundGroup` (default `DEFAULT_SOUND_GROUP`), `AutoPlay`, `AutoRemove`, `Looped`, `PlaybackSpeed`, `TimePosition`, `RollOffMin` / `RollOffMax` / `RollOffMode`, `PitchMin` / `PitchMax` (a random pitch between them).

- `Location`: a `BasePart` or `Attachment` plays from it; a `Model` plays from its `PrimaryPart`, else its first child part, else a holder at its pivot; a `Vector3` or `CFrame` plays from a holder Attachment at that position.
- `FallbackPosition`: the position used when `Location` is missing. The `PlayFor*` functions set it to the world position of an Instance `Location`, so a client that doesn't have that instance (streamed out, server-only) still plays the sound there instead of in 2D.
- `AutoRemove` (default `true`, ignored when `Looped`): the sound is destroyed when it ends or is stopped, or when its asset hasn't loaded after `AUTO_REMOVE_LOAD_TIMEOUT` seconds. A holder Attachment is always destroyed with its sound.

## Usage

```lua
I.Sound.Play({ Name = "Coin", Location = coinPart, PitchMin = 0.95, PitchMax = 1.05 })
I.Sound.PlayForPlayer(player, { Name = "LevelUp", SoundGroup = "SFX" })
I.Sound.PlayForAll({ Name = "Explosion", Location = position })
```

## Network

### Server

**Send: RemoteEvents**

- `Sound_ClientPlay @ (player: Player, params: table)`: `PlayForPlayer`, `PlayForPlayers` (one fire per player) and `PlayForAll` (`FireAll`).

**Send: RemoteFunctions**

- `Sound_ChangeSoundGroupVolume @ (player: Player, soundGroupName: string, volume: number)`, `Sound_GetSoundGroupVolume @ (player: Player, soundGroupName: string)`: used by the `s_sound` command.

### Client

**Receive: RemoteEvents**

- `Sound_ClientPlay @ (params: table)`

**Receive: RemoteFunctions**

- `Sound_ChangeSoundGroupVolume @ (soundGroupName: string, volume: number)`, `Sound_GetSoundGroupVolume @ (soundGroupName: string)`

## Data

| Where | Key | What |
| --- | --- | --- |
| `src/global_data/Sound/SoundsList.lua` | `[soundName]` | One or more asset ids |
| `src/global_data/Sound/SoundGroupsList.lua` | `[groupName]` | Sound groups and their volumes |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_SOUND_GROUP` | `"Master"` | Group a sound goes in when `SoundGroup` isn't set |
| `AUTO_REMOVE_LOAD_TIMEOUT` | `10` | Seconds an `AutoRemove` sound may take to load before it is destroyed |

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `CachedSounds` (Folder) | `SoundService` | One Sound per asset id, cloned by `Play` |
| `SoundsContainer` (SoundGroup) | `SoundService` | 2D sounds while they play |
| `SoundGroups` (Folder) | `SoundService` | The groups from `SoundGroupsList.lua` |
| `SoundsContainer` (SoundGroup) | `Workspace.Ume` | Holds `SoundHolder`, created on the first positional play: on the server a `Model` (`ModelStreamingMode` Persistent) with one anchored invisible Part, on a client a local Part. Each positional sound gets an Attachment under it. |

## Commands

`sound` (client) and `s_sound` (server): `play`, `set_sound_group_volume`, `get_sound_group_volume`, `get_table_length`, and on the server `play_for_player`.
