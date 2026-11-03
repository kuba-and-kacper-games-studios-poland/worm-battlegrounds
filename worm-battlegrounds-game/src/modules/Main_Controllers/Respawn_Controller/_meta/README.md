# Respawn_Controller

Where players respawn. Every player gets a `RespawnLocation` when they join: the `BaseSpawn` SpawnLocation in the framework's workspace folder, unless another module sets a different one.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Respawn_Controller` |
| Runs on | Server |
| Exposes | `I.RespawnController` (server) |
| Uses | `I.G_Player`, `I.Dirs.UmeWorkspace` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Finding the default SpawnLocation, setting each player's `RespawnLocation` |
| `Settings.lua` | The default SpawnLocation's name |

## API

### Server: `I.RespawnController`

| Function | Returns | What it does |
| --- | --- | --- |
| `UpdateRespawnLocation(player, spawnLocation: SpawnLocation?)` | | Sets the player's `RespawnLocation` to `spawnLocation`, or the default |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_SPAWNLOCATION_NAME` | `"BaseSpawn"` | SpawnLocation used by default |
