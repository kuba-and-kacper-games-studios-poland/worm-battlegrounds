# MatchBoard

The lobby's way into matches, along the bottom: **ACTIVE LOBBIES**, a scrolling row of public matches, one lobby card
per mode (map picture, mode, "3/6 players", map name, timer, **Join** or **Join teams**), and at the right the yellow
**SOLO VS BOTS** (**Play with party** in a party) with a blue **CUSTOM** over it. In the board's place it shows the
setup for a solo or party match (the bots' difficulty, what it means, what it pays, **Start**) or, after joining a
public match, the waiting room: the match, the countdown, the players, **Vote to start** and **Leave match**.

**Look.** The board is ported 1:1 from the studio's `LobbyInventory` gui (its `BottomLeft` and `BottomRight` frames,
2026-11-09) as `Primitive` nodes in `U_Play`, laid out in screen fractions with aspect-ratio constraints (no
`S_ScreenScale`). CUSTOM, which the design lacks, is a copy of SOLO VS BOTS, smaller and blue. The setup and the
waiting room are the GUI kit's panels from before the port (`WormBattlegroundsBrawl`: `Box` `Panel` hanging from the
bottom left beside Party, at 10.5 % across, so the lobby's stage stays clear, 0.75 on Desktop, 0.9 on Mobile, `U_Setup` 800 × 660, `U_WaitingRoom` 720 × 860, 560 × 600 on
phones and tablets), since the design has no piece for them. The texts code writes into the buttons (SOLO VS BOTS,
JOIN) carry `TextCase_Upper`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchBoard"` |
| Theme | `WormBattlegroundsBrawl` (the setup and the waiting room) |
| Modes | Night only |
| Devices | The kit's panels: Desktop at 0.75, Mobile at 0.9, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `MatchBoard`: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Play` | Frame, full screen | The board (`BottomLeft`, `BottomRight`); hidden while the setup or the waiting room shows |
| `U_Play` › `S_Solo` | ImageButton (yellow) | Opens the setup; its `Name1` reads "Solo vs bots", or "Play with party" in a party |
| `U_Play` › `S_Custom` | ImageButton (blue) | Opens `CustomLobby` (its tags) |
| `U_Rows` | ScrollingFrame (horizontal) | Holds one `Row` per public match |
| `U_Setup` | Box (`Panel`, `Fixed`) | The solo or party setup, hidden until Solo vs bots. Has `S_ScreenScale` |
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
| `PREFAB | Row` | `U_Rows` | A lobby card: `S_MapIcon` (the map's picture; the design's until the map has a `Thumbnail`), `S_Mode`, `S_Players` ("3/6 players"), `S_Map` (the map's name), `S_Timer`, `S_Join` (ImageButton; its `Name1` reads Join or Join teams) |
| `PREFAB | PlayerName` | `U_Players` | `S_Avatar`, `S_Name` |

## Driven by

The game's `MatchBoard` module (`Board` and `Setup` handlers): the cards, Solo vs bots, the setup and swapping the panels. The `Lobby` module turns the ScreenGui on outside matches (and off while a full-screen widget is open).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchBoard_Preview`) fills the four lobby cards and example players and scales the kit's panels to the screen.

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
| Solo vs bots, Join, a difficulty, Vote, Leave | Click | Tap | Select and A | MatchBoard connects them |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |
| Back | Click | Tap | B (Circle) | `S_Back` tags (`Utils_ButtonKey`); MatchBoard connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a kit button's skin takes the theme's `Pressed` tint |
| Picked difficulty | `S_None` … `S_Hard` › `Face` | `Kit_SelectedImage` (blue) when picked, else `Kit_Image` (slate) |
