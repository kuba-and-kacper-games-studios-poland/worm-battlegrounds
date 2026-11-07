# MatchBoard

The lobby's one panel, laid out like RoWorld's: a welcome line, **Play solo** with **Custom** beside it, and the public matches as cards, two a row (Deathmatch, Duo, Trio, Quads), each with its mode, players and timer across the top, then its map and **Join** (**Join teams** for team modes, both small list buttons). In the same spot it shows the setup for a solo or party match (the bots' difficulty, what it means, what it pays, **Start**) or, after joining a public match, the waiting room: the match, the countdown, the players, **Vote to start** and **Leave match**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Every panel is a `Box` `Panel` hanging from the bottom at 55 % across (0.75 on Desktop, 0.9 on Mobile): `U_Play` 800 × 800 (800 × 700 on phones and tablets, its list scrolling), `U_Setup` 800 × 660, `U_WaitingRoom` 720 × 860 (560 × 600 on phones and tablets). Play solo and Start are the panels' yellow; the match cards are purple, as modes are (`Box` `Card`, `Event`), in the theme's `Matches` grid (344 × 200 cells); Join and Custom are blue; the difficulties are slate `Tab` buttons that turn blue when picked. Titles, buttons and the countdown are capitals, whatever the code writes.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchBoard"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile at 0.9, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `MatchBoard`: `Enabled` off, `DisplayOrder` -1 (under Party, so its opened panel covers it on phones), `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Play` | Box (`Panel`, `Fixed`) | The board; hidden while the setup or the waiting room shows. Has `S_ScreenScale` |
| `U_Play` › `S_Welcome` | Label (`Dim`) | "Welcome, DisplayName" |
| `U_Play` › `S_Solo` | Button (`Primary`, `Large`) | Opens the setup; reads "Play with party" in a party |
| `U_Play` › `S_Custom` | Button (`Large`) | Opens `CustomLobby` (its tags) |
| `U_Rows` | Cells (`Matches`) | Holds one `Row` per public match |
| `U_Setup` | Box (`Panel`, `Fixed`) | The solo or party setup, hidden until Play solo. Has `S_ScreenScale` |
| `U_Setup` › `S_Title` | Label (`Title`) | "Play solo" or "Play with party" |
| `U_Setup` › `S_Back` | Button (`Danger`, `Small`) | Back to the board |
| `U_Setup` › `S_None`, `S_Easy`, `S_Medium`, `S_Hard` | Button (`Tab`) | The bots; the picked one's `Face` takes `Kit_SelectedImage`. `S_None` (No bots) shows only in a party |
| `U_Setup` › `S_Description` | Label (`Dim`) | What the picked bots are like |
| `U_Setup` › `S_Reward` | Label (`Price`) | What the match pays |
| `U_Setup` › `S_Start` | Button (`Primary`, `Large`) | Starts the match |
| `U_WaitingRoom` | Box (`Panel`, `Fixed`) | The waiting room, hidden until the player joins. Has `S_ScreenScale` |
| `U_WaitingRoom` › `S_Match` | Label (`Title`) | "Trios • Map name" |
| `U_WaitingRoom` › `S_Countdown` | Label (`Heading`) | "Match starts in 0:29" |
| `U_WaitingRoom` › `S_Count` | Label (`Dim`) | "5 / 8 players" |
| `U_Players` | Cells | Holds one `PlayerName` per joined player |
| `U_WaitingRoom` › `S_Vote` | Button (`Primary`) | Votes to start; its text shows the votes ("Vote to start  4 / 6") |
| `U_WaitingRoom` › `S_Leave` | Button (`Danger`) | Leaves the match, back to `U_Play` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Row` | `U_Rows` | `S_Mode`, `S_Map`, `S_Players`, `S_Timer`, `S_Join` |
| `PREFAB | PlayerName` | `U_Players` | `S_Avatar`, `S_Name` |

## Driven by

The game's `MatchBoard` module (`Board` and `Setup` handlers): the cards, Play solo, the setup and swapping the panels. The `Lobby` module turns the ScreenGui on outside matches.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills the four match cards and example players and scales the panels to the screen.

| Setting | What it does |
| --- | --- |
| `S_Panel` (Dropdown) | Shows the board, the setup or the waiting room |
| `S_Party` (Toggle) | Play with party: the button and title, and No bots |
| `S_Players` (Slider, 1 to 8) | Players in the waiting room |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Custom | Click | Tap | Select and A | `S_Custom` tags (`Interact_Button` → WidgetManager `Toggle`) |
| Play solo, Join, a difficulty, Vote, Leave | Click | Tap | Select and A | MatchBoard connects them |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |
| Back | Click | Tap | B (Circle) | `S_Back` tags (`Utils_ButtonKey`); MatchBoard connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Picked difficulty | `S_None` … `S_Hard` › `Face` | `Kit_SelectedImage` (blue) when picked, else `Kit_Image` (slate) |
