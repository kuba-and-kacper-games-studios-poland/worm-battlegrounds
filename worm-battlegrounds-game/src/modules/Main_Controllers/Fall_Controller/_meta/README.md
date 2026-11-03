# Fall_Controller

Brings players back when they fall off the map. Every `CHECK_INTERVAL` seconds it checks each character's height; below `MIN_POSITION` the character is moved, without killing it, to the spot a game's destination resolver returns, else to the top of the player's `RespawnLocation`, else to the origin. Then it publishes `Fall_Controller_Fell`.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Fall_Controller` |
| Runs on | Server |
| Exposes | `I.Fall_Controller` (server) |
| Uses | `I.DoEvery`, `I.World`, `I.Topic` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The height check, the destination and the move back |
| `Settings.lua` | Check interval and height |

## API

### Server: `I.Fall_Controller`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetDestinationResolver(callback: ((player: Player) -> CFrame?)?)` | | Sets the function that picks where a fallen player goes (the feet land on the returned `CFrame`). Returning nil, or passing nil, uses the top of the `RespawnLocation`. |

## Usage

```lua
-- Send fallen players to their last checkpoint
I.Fall_Controller.SetDestinationResolver(function(player: Player)
	return Module.GetCheckpointCFrame(player)
end)

I.Topic.Subscribe("Fall_Controller_Fell", Module._onFell) -- (player, character)
```

## Network

No remotes.

### Server

**Topics**

- `Fall_Controller_Fell @ (player: Player, character: Model)`: after a fallen character was moved back.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `CHECK_INTERVAL` | `1` | Seconds between checks |
| `MIN_POSITION` | `-100` | Height below which a character is moved back |
