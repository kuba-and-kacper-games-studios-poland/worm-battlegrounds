# Team

Roblox teams by name. Teams defined in `src/global_data/Team/Teams.lua` are created at start; modules can create and remove more at runtime, assign players and list a team's players. Only teams this module created are kept: any other `Team` added to `Teams` is destroyed, and a created team destroyed elsewhere is forgotten. Each team needs its own `TeamColor`, because Roblox finds a player's team by color: a row or a `Create` whose color (a `Color3` is snapped to the nearest `BrickColor`) another team already uses is refused with a warning. `Team_Changed` follows every change of a player's team, however it was made.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Team` |
| Runs on | Server |
| Exposes | `I.Team` (server) |
| Uses | `Teams`, `I.Topic`, `I.Create`, `I.Player` (session), `I.G_Player`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Creating the listed teams, guarding `Teams`, publishing `Team_Changed`, `Create` / `Remove` / `Assign` / `Get` / `GetPlayers` |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `team` command |
| `_meta/_types.lua` | `Team_TeamsTableEntry` |

## API

### Server: `I.Team`

| Function | Returns | What it does |
| --- | --- | --- |
| `Create(teamName: string, teamColor: BrickColor \| Color3, autoAssignable: boolean?)` | `Team?` | Creates a team; returns the existing one when the name is taken, `nil` when another team has that `TeamColor` |
| `Remove(teamName)` | `boolean` | Removes a team this module created |
| `Assign(player, teamName: string?)` | `boolean` | Puts the player on the team; `nil` takes them off any team |
| `Get(teamName)` | `Team?` | The team |
| `GetPlayers(teamName)` | `{ Player }?` | The players on the team; `nil` (with a warning) when the team doesn't exist |

## Network

No remotes.

### Server

**Topics**

- `Team_Changed @ (player: Player, teamName: string)`: whenever the player's `Team` property changes (`Assign`, a direct `player.Team` write), and once when the player joins already on a team (`AutoAssignable`). `teamName` is `""` when the player has no team.

## In the place

| Instance | Where | Attributes |
| --- | --- | --- |
| each created `Team` | `Teams` | `Team_Authorized = true`: marks it as created here; a `Team` without it is destroyed |

## Data

| Where | Key | What |
| --- | --- | --- |
| `src/global_data/Team/Teams.lua` | `[teamName]` | `TeamColor` (unique per team), `AutoAssignable` |
| Session | `Team.TeamConnection` | The player's `Team` change connection, disconnected when they leave |

## Commands

`team` (server):

| Subcommand | Arguments |
| --- | --- |
| `create` | `teamName teamColor [autoAssignable]` |
| `remove` | `teamName` |
| `assign` | `player [teamName]` |
| `get` | `player` |
