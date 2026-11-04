# Tutorial

The first-time flow. A new player's first join sends them to the tutorial match (the Lobby module launches it): a 1v1
against the tutorial bot, which aims beside them and falls to two Bazooka hits, with hints in order (walk, jump, aim
and fire, the bot's turn, finish it). When it ends, the match server marks it done and gives 100 coins. Back in the
lobby, a hint and an arrow point to the tutorial crate (the Grenade and the Shotgun), then to the loadout; once both
weapons are in it, the tutorial is done and never shows again. In Studio, which can't teleport, the lobby skips the
match and goes straight to the crate.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Tutorial` |
| Runs on | Server, Client · both maps |
| Exposes | `I.Tutorial` (server) |
| Uses | `I.Currency`, `I.Loadout`, `I.Match` (client), `I.Replicator`, `I.Topic` |
| Saves | `Profile.Tutorial` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Saved progress, the match's end, the crate, the equip step |
| `Client.lua` | Starts the match hints on the Match map, the lobby hints elsewhere |
| `Scripts/Client/MatchHints.lua` | The hints during the tutorial match |
| `Scripts/Client/LobbyHints.lua` | The crate and equip hints and the arrow in the lobby; reports the equip step |
| `Settings.lua` | `Tutorial_Settings` |

## API

### Server: `I.Tutorial`

| Function | Returns | What it does |
| --- | --- | --- |
| `CompleteMatch(player)` | `boolean` | Marks the tutorial match played and gives `MATCH_COINS`, once |
| `IsMatchDone(player)` | `boolean` | Whether the tutorial match is played |
| `IsDone(player)` | `boolean` | Whether the whole tutorial is finished |
| `CanOpenCrate(player)` | `boolean` | Whether the tutorial crate waits (Crates checks it) |

## Network

### Server

**Receive: RemoteEvents**

- `Tutorial_Step @ (player: Player, step: string)`: `"Equipped"` finishes the tutorial once the server sees both
  starter weapons in the loadout. Rate limit 5 per second.

It listens to `Match_Ended` (Match map) and `Crates_Opened` (Lobby map) when those modules run.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Tutorial` | `{ MatchDone = false, CrateOpened = false, Done = false }` |
| Replicator `Tutorial` | `MatchDone`, `CrateReady`, `EquipReady`, `Done` | Which step waits (`CrateReady`: match done, crate not opened; `EquipReady`: crate opened, not done) |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MATCH_COINS` | `"100"` | Coins the tutorial match gives, the tutorial crate's price |
| `CRATE_ID` | `"Tutorial"` | The crate the lobby offers once |
| `STARTER_WEAPONS` | `{ "Grenade", "Shotgun" }` | What the crate gives, and what the equip step checks |
| `MATCH_MAP`, `MATCH_KIND` | `"Match"`, `"Tutorial"` | The map the match hints run on, and the match kind |
| `HINTS` | Walk, Jump, Fire, BotTurn, Finish, Crate, Equip | What each hint says |
| `JUMP_SPEED` | `6` | How fast a worm must rise to count as a jump, in studs per second |
| `HINT_GUI_NAME`, `LOBBY_GUI_NAME`, `CRATES_GUI_NAME`, `LOADOUT_GUI_NAME` | | The hint bubble, and the guis the arrow points into |

## In the place

Drives `TutorialHint` (`U_Hint` › `S_Text`; `S_Arrow` stays hidden) and the `Lobby` gui's `U_Pointer` › `S_Arrow`,
which it keeps over the top of `Crates` › `U_TutorialCrate`, then `Loadout` › `U_Slots`. The tutorial bot's damage
is the Bots module's `DAMAGE_TAKEN`.
