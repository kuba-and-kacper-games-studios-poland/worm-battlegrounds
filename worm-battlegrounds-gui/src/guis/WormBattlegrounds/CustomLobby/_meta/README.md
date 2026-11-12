# CustomLobby

A private lobby to play friends (pays no coins). First the player creates it (map, mode, players, bots), then the room shows who's in, who can be invited, **Invite friends**, **Start** (owner) and **Leave**.

**Look.** The studio's `CustomLobby` (the create step) and `CustomLobbyPlayers` (the room) designs (2026-11-12), ported 1:1 as `Primitive` nodes (their pictures, fonts and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive` ports"). Dark slanted panels with a red ✕ in their headers. The picked map, mode, player count and bots wear a white outline and white text, the rest grey; Create lobby and Start are yellow, Leave dark.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CustomLobby"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `CustomLobby`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding both panels) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Create` | Frame | The create step |
| `U_Create` › `S_Close`, `U_Room` › `S_Close` | ImageButton | Close the window (their tags) |
| `U_Maps` | ScrollingFrame with a UIListLayout | Holds one `MapChoice` per map; MatchBoard marks the picked one |
| `U_Create` › `S_Deathmatch`, `S_Teams` | ImageButton | The mode; the picked one is marked |
| `U_Create` › `S_Players2`, `S_Players4`, `S_Players6`, `S_Players8` | ImageButton | The player count; the picked one is marked |
| `U_Create` › `S_BotsNone`, `S_BotsEasy`, `S_BotsMedium`, `S_BotsHard`, `S_BotsNightmare` | ImageButton | The bots that fill the empty places (None is none); the picked one is marked. Nightmare is offered only here |
| `U_Create` › `S_Create` | ImageButton | Creates the lobby and shows `U_Room` |
| `U_Room` | Frame | The room, hidden until created |
| `U_Room` › `S_Info` | TextLabel | "Teams  \|  4 players  \|  Desert  \|  Hard bots" |
| `U_Members` | ScrollingFrame with a UIListLayout | Holds one `Member` per player in the lobby |
| `U_Invitable` | ScrollingFrame with a UIListLayout | Holds one `Invitable` per player in this server |
| `U_Room` › `S_InviteFriends`, `S_Start`, `S_Leave` | ImageButton | Friend invite prompt; start (shown to the owner only); leave |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| MapChoice` | `U_Maps` | An ImageButton: `S_Icon` (map picture, `Crop`: the wide lobby card pictures fill it at their own shape, their sides cut off), `S_Name`, `S_Info` (player counts, "2 / 4") |
| `PREFAB \| Member` | `U_Members` | `S_Avatar`, `S_Name`, `S_Username` |
| `PREFAB \| Invitable` | `U_Invitable` | `S_Avatar`, `S_Name`, `S_Username`, `S_Invite` (ImageButton) |

## Driven by

The game's `MatchBoard` module (`Custom` handler) draws it on `WidgetManager_Opened` with `CustomLobby`.

## Preview

`Preview.lua` fills the maps and the room.

| Setting | What it does |
| --- | --- |
| `S_Room` (Toggle) | Shows the room in place of the create step |
| `S_Members` (Slider, 1 to 8) | Players in the lobby |
| `S_Invitable` (Slider, 0 to 10) | Players who can be invited |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CustomLobby`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CustomLobby"`, or `I.WidgetManager.Open("CustomLobby")`). A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `S_Close` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Create lobby, Start | Click | Tap | A (Cross) | `S_Create`, `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects them |
| Pick, invite, invite friends, leave | Click | Tap | Select and A | MatchBoard connects the buttons |

Close, Create lobby and Start show their pad button in a `PadHint` badge on Console (`Console_Hint`, `Console_Action` `Back`, `Confirm`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and map choices | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Picked | Mode, player count, bots and `MapChoice` › `Background.Stroke`, the label | `Look_SelectedStrokeColor` and `Look_SelectedTextColor` (white) when picked, else `Look_StrokeColor` (130, 130, 130) and `Look_TextColor`. Buttons with `Look_Stroke` also swap their `Stroke` and `Stroke2` pictures (`Look_SelectedStroke`, `Look_SelectedStroke2`). MatchBoard's `Custom` |
