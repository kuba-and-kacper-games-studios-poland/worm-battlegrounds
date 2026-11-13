# Tutorial

The first-time flow, guided by a spotlight. A new player's first join sends them to the tutorial match (the Lobby
module launches it): a 1v1 against the tutorial bot, which can't shoot and falls to any hit (Bots' `HEALTH`); the player's shots can't miss it (Combat steers them onto it). The
guide blacks out the screen around what to press next and shows a hint beside it, worded for the player's device:
the lit spot to land on (the drop starts the player and the bot close together, Match's `TUTORIAL_*`), then the bot
to shoot (on touch, the bot, then FIRE), the bot's turn, a retry after a miss, and Return on the results (Rematch is
grey there). When the match ends, the match server marks it done and gives 100 coins. Back in the lobby the guide
lights the Weapons button (the free crate), the crate's x1, the crate and its TAP TO OPEN line while it waits for
the tap, Continue after the reels and the crates' close, then a loadout slot and, in the picker, each starter
weapon; once both are in the loadout, the tutorial is done and never shows again. Studio skips the whole tutorial
(`Skip`) unless Workspace's `StudioTutorial` is true; then the Studio map plays the whole flow on one server, and the
Lobby map alone, which can't start the match, skips it and goes straight to the crate. Each guide shows only where it belongs (the `InMatch` Player
attribute), and takes down only the spotlight it put up, so on the Studio map the match guide never hides the lobby's.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Tutorial` |
| Runs on | Server, Client · every map |
| Exposes | `I.Tutorial` (server) |
| Uses | `I.Currency`, `I.Loadout`, `I.Match` (client), `I.Replicator`, `I.Topic`, `I.Platform`, `I.Console` (client: the pad's button names) |
| Saves | `Profile.Tutorial` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Saved progress, the match's end, the crate, the equip step |
| `Client.lua` | Starts the spotlight, the match guide on the Match map, the lobby guide on the Lobby map, both on the Studio map |
| `Scripts/Client/Spotlight.lua` | The `TutorialHint` gui: the hole over a gui element, a part, a world spot or a screen area (a `Rect`), the blockers around it, the hint panel beside it |
| `Scripts/Client/MatchHints.lua` | The guide during the tutorial match (`TOUCH_HINTS` on touch, `PAD_HINTS` with the pad's button names on a pad) |
| `Scripts/Client/LobbyHints.lua` | The guide to the crate and the loadout in the lobby (the waiting crate's screen area from the Crates viewport's camera); reports the equip step |
| `Settings.lua` | `Tutorial_Settings` |

## API

### Server: `I.Tutorial`

| Function | Returns | What it does |
| --- | --- | --- |
| `CompleteMatch(player)` | `boolean` | Marks the tutorial match played and gives `MATCH_COINS`, once |
| `Skip(player)` | | Marks the whole tutorial done without playing it: no coins, no crate (Studio playtests without `StudioTutorial`) |
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
| `MATCH_MAP`, `LOBBY_MAP`, `MATCH_KIND` | `"Match"`, `"Lobby"`, `"Tutorial"` | The maps that run only the match guide or only the lobby guide, and the match kind |
| `HINTS` | Drop, Aim, BotTurn, Retry, Lobby, Crate, OpenCrate, Tap, Opening, Continue, CloseCrates, Equip, Pick | What each step's hint says (`Pick`'s `%s` is the weapon's name) |
| `TOUCH_HINTS` | Drop, Aim, Fire, Retry | What those match steps say on a touch screen, where touch aims by a tap and shoots with FIRE |
| `PAD_HINTS` | Drop, Aim, Retry | What those match steps say on a pad: each `{Action}` becomes that action's button in the Console module's scheme, named for the player's pad (`I.Console.GetButtonName`: "RT" or "R2") |
| `HOLE_PADDING`, `WORLD_HOLE_RADIUS`, `HOLE_MIN`, `RING_PULSE_RATE` | `10`, `4`, `72`, `4` | The hole: pixels past a gui element, studs around a world spot or snail, its smallest size in pixels, and its ring's pulse |
| `HINT_GAP`, `HINT_EDGE`, `HINT_TOP`, `HINT_TEXT_SIZE`, `HINT_BOTTOM_PADDING` | `24`, `16`, `0.18`, `32`, `18` | Where the hint panel sits (beside the hole, in from the screen's edges, or at this share of the height with no hole) and its text's design size |
| `HINT_GUI_NAME`, `MATCH_HUD_GUI_NAME`, `RESULTS_GUI_NAME`, `LOBBY_GUI_NAME`, `CRATES_GUI_NAME`, `LOADOUT_GUI_NAME`, `PICKER_GUI_NAME` | | The guide's gui, and the guis whose buttons it lights |

## In the place

Drives `TutorialHint` (`U_Spotlight`, `U_Blockers`, `U_Hint` › `S_Text`). Lights, without changing them: MatchHud's
`U_Fire`, Results' `S_Lobby`, the Lobby menu's `S_Weapons`, Crates' `U_BuyX1`, `U_Continue` and `S_Close`, the
Loadout slots (`Slot<n>`) and the LoadoutPicker cards (named by item id). The tutorial bot's play and health are the
Bots module's (`HEALTH`, `TUTORIAL_FUMBLE_POWER`); the tutorial's drop and turn order are the Match module's.
