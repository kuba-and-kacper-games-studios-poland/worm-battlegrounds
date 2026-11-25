# MatchSetup

The setup before a solo, party or local match: the map (Random, then the rotation's maps for the match's size), how
many share the screen and the wind (local play), the bots, what a win pays, then **Play**. A solo match shows only its
difficulty, as three cards with a glyph each, the reward and **Play**, and plays a random map (the owner, 2026-11-25). It's a WidgetManager widget like the
custom lobby's window, so it opens with WidgetManager's tween, sound, blur and dim, and the lobby board slides away
while it shows.

**Look.** The custom lobby's create window (the studio's `CustomLobby` design, 2026-11-17, replacing the `PlaySolo`
panel and the map strip over it, which the owner found didn't fit and overlapped): its art, header and red X, its map
cards, player and bot buttons and yellow button, rows in a list so the ones a mode hides close up, in the middle of
the screen (0.5, as the custom lobby's window, since 2026-11-25; 0.564 down before) over a darker dim (`WidgetManager_Dim` 0.3), the match's mode icon before the title. The picked choices wear a
white outline, the rest grey. It was MatchBoard's `U_Setup` until 2026-11-17, when it became its own widget (the
owner: the custom lobby "makes the screen fade and blur", the local one didn't).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchSetup"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `MatchSetup`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding the window; `WidgetManager_Dim` 0.3) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Setup` | Frame | The window |
| `U_Setup` › `S_DifficultyRow` | Frame, hidden | Solo only: a DIFFICULTY header over `S_DifficultyList` (a centred horizontal list), where MatchBoard clones a `PREFAB \| Difficulty` per difficulty |
| `U_Setup` › `S_MapRow` | Frame | The MAP header and the map list; hidden for solo |
| `U_Setup` › `S_MapList` | ScrollingFrame | Holds the map cards: Random, then the rotation's maps for the match's size |
| `U_Setup` › `S_PlayersRow` | Frame, hidden | Local play's players row: `S_Players2` to `S_Players8` (the custom lobby's player buttons), the picked one marked |
| `U_Setup` › `S_Title` | TextLabel | "Play solo", "Play with party" or "Local play" |
| `U_Setup` › `S_TitleIcon` | ImageLabel, before the title | The match's mode icon (MatchBoard's `MODE_ICONS`: Bots, Party or Local) |
| `U_Setup` › `S_Back` | ImageButton | Closes the window, back to the board |
| `U_Setup` › `S_BotsRow` | Frame | The BOTS header and the bot buttons; hidden for solo |
| `U_Setup` › `S_None`, `S_Easy`, `S_Medium`, `S_Hard` | ImageButton | The bots (the custom lobby's bot buttons); the picked one is marked. `S_None` (OFF) shows only in a party and in local play |
| `U_Setup` › `S_WindBox` | Frame, hidden, in the bots' row (`BotsRow`) at its right | Local play's wind (2026-11-24): a WIND header over `WindList` with `S_WindOff` (OFF) and `S_WindOn` (ON), the bot buttons' copies; MatchBoard shows it only for local play, marks the pick (OFF until picked) and sends it with START |
| `U_Setup` › `S_RewardText` | TextLabel (30 px), on the reward plate (`RewardRow` › `Plate`: a dark rounded panel with a gold outline, 2026-11-25: the owner, "make win reward bigger... eye catching") | "Win reward", or how a party or local match pays |
| `U_Setup` › `S_RewardAmount` | Frame (the diamond and `S_Reward`, gold, 46 px) | What a solo win pays; hidden for a party and local play |
| `U_Setup` › `S_Start` | ImageButton, 0.4948 × 0.1242 of the window (1.3 times its old size, 2026-11-25) | PLAY (START until 2026-11-25), with the play glyph (`Icon`, PLAY SOLO's own) left of the text, the two centred as one: starts the match |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Difficulty` | `U_Setup` (code clones it into `S_DifficultyList`) | A difficulty card (2026-11-25): the map card's look without its map picture and "Any map", `S_Glyph` (the difficulty's glyph, where Random's die sits) over `S_Name` (centred, capitals), `S_Tint` (the card's fill picture, a faint wash rising from the bottom), the same `Look_*` picked and unpicked outlines; MatchBoard tints the wash and the glyph and sets the picked outline and name to the difficulty's colour (`DIFFICULTY_COLORS`) |
| `PREFAB \| SoloMap` | `U_Setup` (code clones it into `S_MapList`) | A map card, the custom lobby's `PREFAB \| MapChoice` copied: `S_Icon` (the map's `TileThumbnail`, empty for Random), `S_RandomIcon` (the die, shown on Random only), `S_Name` (capitals), `S_Info` ("Any map", shown on Random only), the `Look_*` picked and unpicked outlines and text colours |

## Driven by

The game's `MatchBoard` module (`Setup` handler) opens it with `I.WidgetManager.Open("MatchSetup")` from PLAY SOLO
and LOCAL, and draws it on `WidgetManager_Opened` with `MatchSetup`. The `Lobby` module hides the lobby's guis while it
shows (`FULL_SCREEN_WIDGETS`, since 2026-11-25; only the Loadout panel before).

## Preview

`Preview.lua` (`UmeGui_Guis_WormBattlegrounds_MatchSetup_Preview`) fills the title, the rows a match shows and four
map cards (Random first).

| Setting | What it does |
| --- | --- |
| `S_Kind` (Dropdown) | Solo, Party or Local: the title, the players row, No bots, the diamonds a win pays, and for Solo the difficulty cards in place of the maps and bots |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchSetup`, `Enabled` off. WidgetManager
opens it. A restyled copy keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a map, players, bots or wind | Click | Tap | Select and A (the window holds the selection while it shows) | MatchBoard's Setup; Console (`Focus`) |
| Start | Click | Tap | A (Cross) | `S_Start` tags (`Utils_ButtonKey`); MatchBoard connects it |
| Back | Click | Tap | B (Circle) | `S_Back` tags (`Utils_ButtonKey`); MatchBoard closes the widget (with a selection, B backs out through the Console module's focus) |

On Console `S_Back` and `S_Start` show their button in a badge (`PadHint`, `Console_Action` `Back`, `Confirm`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and map cards | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Picked | Players, bots, wind and `SoloMap` › `Background.Stroke`, the label | `Look_SelectedStrokeColor` and `Look_SelectedTextColor` (white) when picked, else `Look_StrokeColor` (130, 130, 130) and `Look_TextColor`; MatchBoard's `Custom.SetPicked` |
