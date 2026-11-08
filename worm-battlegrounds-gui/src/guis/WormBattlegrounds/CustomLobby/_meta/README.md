# CustomLobby

A private lobby to play friends (pays no coins). First the player creates it (map, mode, players, bots), then the room shows who's in, who can be invited, **Invite friends**, **Start** (owner) and **Leave**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Mode, player count and bots are tabs (slate, the picked one blue). The two pages have no slot of their own, so the maps sit on the window's slots. Invite is blue; Create lobby and Start are the yellows.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CustomLobby"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `CustomLobby`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Create` | Box (`Fixed`) | The create step |
| `U_Maps` | Cells (`Grid`) | Holds one `MapChoice` per map; MatchBoard selects the picked one |
| `U_Create` › `S_Deathmatch`, `S_Teams` | Button | The mode; the picked one is selected |
| `U_Create` › `S_Players2`, `S_Players4`, `S_Players6`, `S_Players8` | Button | The player count; the picked one is selected |
| `U_Create` › `S_BotsNone`, `S_BotsEasy`, `S_BotsMedium`, `S_BotsHard`, `S_BotsNightmare` | Button | The bots that fill the empty places (Off is none); the picked one is selected. Nightmare is offered only here |
| `U_Create` › `S_Create` | Button (`Primary`) | Creates the lobby and shows `U_Room` |
| `U_Room` | Box (`Fixed`) | The room, hidden until created |
| `U_Room` › `S_Info` | Label | "Teams • Map • 1 / 4 players • Hard bots" |
| `U_Members` | Cells | Holds one `Member` per player in the lobby |
| `U_Invitable` | Cells | Holds one `Invitable` per player in this server |
| `U_Room` › `S_InviteFriends`, `S_Start`, `S_Leave` | Button | Friend invite prompt; start (owner only); leave |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | MapChoice` | `U_Maps` | An Item: `S_Icon` (map picture), `S_Name`, `S_Info` (player counts) |
| `PREFAB | Member` | `U_Members` | `S_Avatar`, `S_Name` |
| `PREFAB | Invitable` | `U_Invitable` | `S_Avatar`, `S_Name`, `S_Invite` |

## Driven by

The game's `MatchBoard` module draws it on `WidgetManager_Opened` with `CustomLobby`.

## Preview

`Preview.lua` fills the maps and the room.

| Setting | What it does |
| --- | --- |
| `S_Room` (Toggle) | Shows the room in place of the create step |
| `S_Members` (Slider, 1 to 8) | Players in the lobby |
| `S_Invitable` (Slider, 0 to 10) | Players who can be invited |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CustomLobby`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CustomLobby"`, or `I.WidgetManager.Open("CustomLobby")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Pick, create, invite, start, leave | Click | Tap | Select and A | MatchBoard connects the buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Picked mode, player count and bots | `S_Deathmatch` … `S_BotsNightmare` › `Face` | `Kit_SelectedImage` (blue) when picked, else `Kit_Image`; MatchBoard's `Custom` |
| Picked map | `MapChoice` › `Body` | Fill rgb(40, 140, 255) at 0.2 transparency when picked, else black at 0.7 (MatchBoard's `SELECTED_*` and `TILE_*` settings) |
