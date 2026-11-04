# CustomLobby

A private lobby to play friends (pays no coins). First the player creates it (map, mode, players), then the room shows who's in, who can be invited, **Invite friends**, **Start** (owner) and **Leave**.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CustomLobby"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `CustomLobby`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Create` | Box (`Fixed`) | The create step |
| `U_Maps` | Cells (`Grid`) | Holds one `MapChoice` per map; MatchBoard selects the picked one |
| `U_Create` › `S_Deathmatch`, `S_Teams` | Button | The mode; the picked one is selected |
| `U_Create` › `S_Players2`, `S_Players4`, `S_Players6`, `S_Players8` | Button | The player count; the picked one is selected |
| `U_Create` › `S_Create` | Button (`Primary`) | Creates the lobby and shows `U_Room` |
| `U_Room` | Box (`Fixed`) | The room, hidden until created |
| `U_Room` › `S_Info` | Label | "Teams • Map • 4 players" |
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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CustomLobby`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CustomLobby"`, or `I.WidgetManager.Open("CustomLobby")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Pick, create, invite, start, leave | Click | Tap | Select and A | MatchBoard connects the buttons |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
