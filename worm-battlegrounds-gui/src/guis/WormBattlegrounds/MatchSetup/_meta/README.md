# MatchSetup

The setup before a solo, party or local match: the map (Random, then the rotation's maps for the match's size), how
many share the screen (local play), the bots, what a win pays, then **Start**. It's a WidgetManager widget like the
custom lobby's window, so it opens with WidgetManager's tween, sound, blur and dim, and the lobby board slides away
while it shows.

**Look.** The custom lobby's create window (the studio's `CustomLobby` design, 2026-11-17, replacing the `PlaySolo`
panel and the map strip over it, which the owner found didn't fit and overlapped): its art, header and red X, its map
cards, player and bot buttons and yellow button, rows in a list so the ones a mode hides close up, centred under the
top bar (0.564 down, as the custom lobby's window), the match's mode icon before the title. The picked choices wear a
white outline, the rest grey. It was MatchBoard's `U_Setup` until 2026-11-17, when it became its own widget (the
owner: the custom lobby "makes the screen fade and blur", the local one didn't).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchSetup"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `MatchSetup`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding the window) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Setup` | Frame | The window |
| `U_Setup` › `S_MapList` | ScrollingFrame | Holds the map cards: Random, then the rotation's maps for the match's size |
| `U_Setup` › `S_PlayersRow` | Frame, hidden | Local play's players row: `S_Players2` to `S_Players8` (the custom lobby's player buttons), the picked one marked |
| `U_Setup` › `S_Title` | TextLabel | "Play solo", "Play with party" or "Local play" |
| `U_Setup` › `S_TitleIcon` | ImageLabel, before the title | The match's mode icon (MatchBoard's `MODE_ICONS`: Bots, Party or Local) |
| `U_Setup` › `S_Back` | ImageButton | Closes the window, back to the board |
| `U_Setup` › `S_None`, `S_Easy`, `S_Medium`, `S_Hard` | ImageButton | The bots (the custom lobby's bot buttons); the picked one is marked. `S_None` (OFF) shows only in a party and in local play |
| `U_Setup` › `S_RewardText` | TextLabel | "Win reward", or how a party or local match pays |
| `U_Setup` › `S_RewardAmount` | Frame (a coin and `S_Reward`) | What a solo win pays; hidden for a party and local play |
| `U_Setup` › `S_Start` | ImageButton | Starts the match |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| SoloMap` | `U_Setup` (code clones it into `S_MapList`) | A map card, the custom lobby's `PREFAB \| MapChoice` copied: `S_Icon` (the map's `TileThumbnail`, empty for Random), `S_RandomIcon` (the die, shown on Random only), `S_Name` (capitals), `S_Info` ("Any map", shown on Random only), the `Look_*` picked and unpicked outlines and text colours |

## Driven by

The game's `MatchBoard` module (`Setup` handler) opens it with `I.WidgetManager.Open("MatchSetup")` from SOLO VS BOTS
and LOCAL, and draws it on `WidgetManager_Opened` with `MatchSetup`. The `Lobby` module hides the Loadout panel while
it shows (`PANEL_WIDGETS`).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchSetup_Preview`) fills the title, the rows a match shows and four
map cards (Random first).

| Setting | What it does |
| --- | --- |
| `S_Kind` (Dropdown) | Solo, Party or Local: the title, the players row, No bots and the coins a win pays |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchSetup`, `Enabled` off. WidgetManager
opens it. A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a map, players or bots | Click | Tap | Select and A (the window holds the selection while it shows) | MatchBoard's Setup; Console (`Focus`) |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |
| Back | Click | Tap | B (Circle) | `S_Back` tags (`Utils_ButtonKey`); MatchBoard closes the widget (with a selection, B backs out through the Console module's focus) |

On Console `S_Back` and `S_Start` show their button in a badge (`PadHint`, `Console_Action` `Back`, `Confirm`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and map cards | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Picked | Players, bots and `SoloMap` › `Background.Stroke`, the label | `Look_SelectedStrokeColor` and `Look_SelectedTextColor` (white) when picked, else `Look_StrokeColor` (130, 130, 130) and `Look_TextColor`; MatchBoard's `Custom.SetPicked` |
