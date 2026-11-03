# PlayerCollision

Collision groups for player characters. Every character's parts join the `Player` collision group, which doesn't collide with the groups in `IGNORED_COLLISION_GROUPS` (by default, other players: characters pass through each other). At start the default group and each ignored group are registered when the place doesn't have them yet, and the default group is set non-collidable with every ignored group, also when the groups were made in Studio's Collision Groups editor; other pairs are left as they are. Modules move a player to another group when needed.

| | |
| --- | --- |
| Folder | `src/modules/Utils/PlayerCollision` |
| Runs on | Server |
| Exposes | `I.PlayerCollision` (server) |
| Uses | `PhysicsService`, `I.G_Player`, `I.DoEvery` (command dictionary) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Registering the groups, putting characters in them, `Set` |
| `Settings.lua` | The default group and what it ignores |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `player_collision` command |

## API

### Server: `I.PlayerCollision`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(player, collisionGroupName: string)` | `boolean` | Puts the player's character in that collision group |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_COLLISION_GROUP_NAME` | `"Player"` | Group characters start in |
| `IGNORED_COLLISION_GROUPS` | `{ "Player" }` | Groups the default group doesn't collide with (registered at start when missing) |
| `CMD_DICT_REFRESH_SEC` | `30` | Seconds between checks of the command's group list; the dictionary is set again only when the list changed |

## Commands

`player_collision` (server): `set player collisionGroupName`.
