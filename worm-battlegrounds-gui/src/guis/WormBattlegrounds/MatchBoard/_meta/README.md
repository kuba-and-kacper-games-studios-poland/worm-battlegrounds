# MatchBoard

The lobby's bottom-centre row. Before joining: **Play** (the quick match: joins the open public match closest to starting) and **Modes** (opens `PlayModes`: Play solo, Custom lobby, the public matches). After joining a public match the waiting room takes its place: the match, the countdown, the players, **Vote to start** and **Leave match**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Play is the yellow `Hero` button, the screen's one main button; Modes beside it is blue, as other actions are. The row has no panel behind it, so the lobby's stage shows around it: a 760 × 144 frame with its own `S_ScreenScale`, hanging from the bottom centre (0.75 on Desktop, 0.9 on Mobile). The waiting room is a 720 × 860 panel in the same spot (560 × 600 at scale 0.9 on phones and tablets).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchBoard"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `MatchBoard`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Play` | Frame | The Play row; hidden while the player waits in a match. Has `S_ScreenScale` |
| `U_Play` › `S_Quick` | Button (`Primary`, `Hero`) | Joins the open public match closest to starting |
| `U_Play` › `S_Modes` | Button (`Hero`) | Opens `PlayModes` (its tags) |
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
| `PREFAB | PlayerName` | `U_Players` | `S_Avatar`, `S_Name` |

## Driven by

The game's `MatchBoard` module: the quick match on `S_Quick`, and swapping `U_Play` for `U_WaitingRoom` when the player joins. The `Lobby` module turns the ScreenGui on outside matches.

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills example players and scales the panels to the screen.

| Setting | What it does |
| --- | --- |
| `S_Joined` (Toggle) | Shows the waiting room in place of the play panel |
| `S_Players` (Slider, 1 to 8) | Players in the waiting room |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchBoard`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Modes | Click | Tap | Select and A | `S_Modes` tags (`Interact_Button` → WidgetManager `Toggle`) |
| Play, Vote, Leave | Click | Tap | Select and A | MatchBoard connects `S_Quick`, `S_Vote`, `S_Leave` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
