# MatchBoard

The lobby's middle panel. Before joining: **Play solo**, the 3 open public matches, and **Custom lobby**. After joining a public match the waiting room takes its place: the match, the countdown, the players, **Vote to start** and **Leave match**.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchBoard"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `MatchBoard`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Play` | Box (`Panel`, `Fixed`) | The play panel; hidden while the player waits in a match. Has `S_ScreenScale` |
| `U_Solo` | Button (`Primary`) | Opens `SoloSetup` (its tags) |
| `U_Rows` | Cells | Holds one `Row` per open public match |
| `U_Custom` | Button | Opens `CustomLobby` (its tags) |
| `U_WaitingRoom` | Box (`Panel`, `Fixed`) | The waiting room, hidden until the player joins. Has `S_ScreenScale` |
| `U_WaitingRoom` › `S_Match` | Label (`Title`) | "Duo team deathmatch • Map name" |
| `U_WaitingRoom` › `S_Countdown` | Label (`Heading`) | "Match starts in 0:29" |
| `U_WaitingRoom` › `S_Count` | Label (`Dim`) | "5 / 8 players" |
| `U_Players` | Cells | Holds one `PlayerName` per joined player |
| `U_WaitingRoom` › `S_Vote` | Button (`Primary`) | Votes to start; its text shows the votes ("Vote to start  4 / 6") |
| `U_WaitingRoom` › `S_Leave` | Button (`Danger`) | Leaves the match, back to `U_Play` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | `S_Thumbnail` (map picture), `S_Mode`, `S_Map`, `S_Players` ("3 / 8"), `S_Timer` ("0:30"), `S_Join` ("Join" or "Join teams") |
| `PREFAB | PlayerName` | `U_Players` | `S_Avatar`, `S_Name` |

## Driven by

The game's `MatchBoard` module: it turns the ScreenGui on on the Lobby map, refreshes the rows, and swaps `U_Play` for `U_WaitingRoom` when the player joins.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills example rows and players and scales the panels to the screen.

| Setting | What it does |
| --- | --- |
| `S_Rows` (Slider, 0 to 3) | How many public matches are listed |
| `S_Joined` (Toggle) | Shows the waiting room in place of the play panel |
| `S_Players` (Slider, 1 to 8) | Players in the waiting room |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Play solo / Custom lobby | Click | Tap | Select and A | `U_Solo`, `U_Custom` tags (`Interact_Button` → WidgetManager `Toggle`) |
| Join, Vote, Leave | Click | Tap | Select and A | MatchBoard connects `S_Join`, `S_Vote`, `S_Leave` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
