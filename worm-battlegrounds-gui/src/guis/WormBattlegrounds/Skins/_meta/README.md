# Skins

The **STYLE** screen, where the player dresses their snail piece by piece: a hat, a neck piece, a body and a shell.
Since 2026-11-14 it's laid out as card decks (the owner's pick, draft A): a deck per slot on the left, the snail in
the middle in a soft light, the room darkened round it (`Shade`, `Backlight`), with the player's name under it (drag to spin it), and the open slot's pieces on the
right over a detail bar. The snail colour row is gone. NEW tags mark pieces the player hasn't seen.

**Look.** The studio's `Customise` gui (2026-11-09), as `Primitive` nodes: its slanted dark cards, pictures and fonts,
and its screen-fraction layout (sizes and positions as screen shares with aspect-ratio constraints, so it scales with
the screen by itself, with no `S_ScreenScale`). The title and BACK are the design's own; the decks are its category
cards, the tiles and the fan's cards its item tile, the detail bar the confirmation dialog's rounded dark panel with the
Gacha design's button. Button tags (`Utils_ButtonScale`, `Utils_ButtonSound`) on every press.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Skins"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Skins`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens; holds `Content` with `U_Decks`, `U_Stage`, `U_Panel`, `TopLeft` and `TopRight` |
| `U_Widget` › `S_Close` | ImageButton (BACK) | Closes the widget (its tags), or B on a pad |
| `U_Decks` › `U_DeckHat`, `U_DeckNeck`, `U_DeckBody`, `U_DeckShell` | ImageButton | A slot's deck: pressing opens it. `S_Name` (lit while open), `S_Owned` ("3/7 owned"), `S_Wearing` (the worn piece), `S_New` (the NEW tag), `S_Fan` › `S_Card1`–`S_Card3` (each holding `Stroke`, tinted with its piece's rarity, and `View`, a ViewportFrame for the piece on a snail) |
| `U_Stage` › `S_View` | ViewportFrame | The snail in the worn outfit, 1.3 times the stage's width so it never clips |
| `U_Stage` › `S_Drag` | ImageButton (invisible, over `S_View`) | A drag on it spins the snail |
| `U_Stage` › `S_PlayerName` | TextLabel | The player's display name; "Drag to spin" under it |
| `U_Panel` › `S_Title`, `S_Count` | TextLabel | The open slot's name and how many of its pieces are owned |
| `U_Pieces` | ScrollingFrame (grid, three across) | Holds one `PieceTile` per piece of the open slot |
| `U_Detail` › `S_View`, `S_Name`, `S_Info` | ViewportFrame, TextLabels | The picked piece: on a snail, its name, its rarity (rich text, in its colour) and set |
| `U_Detail` › `S_Action`, `S_ActionText` | ImageButton, TextLabel | Wear the picked piece (Equip), Worn, or Get (opens the Skin crate) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| PieceTile` | `U_Pieces` | An ImageButton: `S_Name`, `S_Rarity` (the corner mark, tinted with the rarity's colour), `S_Preview` (ViewportFrame for the piece on a snail), `S_Locked` (the lock cover, with `S_Source`: where it comes from), `S_Worn` (the green WEARING badge), `S_New` (the NEW tag). Its `Background` › `Stroke2` / `Stroke` swap to the selected look from the root's attributes |

## Driven by

The game's `Cosmetics` module (`Scripts/Client/Skins.lua`).

## Preview

`Preview.lua` opens HATS (lit, its cards fanned out) and fills the grid with `S_Pieces` tiles (1 to 8): no hat first,
the second worn, the last four locked.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Skins`, `Enabled` off. WidgetManager opens
it (the lobby's STYLE button). It keeps its `Name`, Ids and prefab name.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open a slot | Click its deck | Tap | Select | Cosmetics (`I.Interact.OnPress`) |
| Pick and wear a piece | Click its tile (an owned one is worn at once) | Tap | Select | Cosmetics |
| Spin the snail | Drag on it | Drag | | Cosmetics (`SkinsStage`) |
| Wear, or get, the picked piece | Click the detail bar's button | Tap | Select | Cosmetics |
| Close | BACK | BACK | B | `S_Close` tags (`Interact_Button`, `Utils_ButtonKey`); its `PadHint` badge on Console |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Decks, tiles, the detail button, BACK | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Open deck | `U_Deck<Slot>` › `Background` › `Stroke2`, `Stroke`; `S_Name` | `Look_OpenStroke2`, `Look_OpenStroke`, `Look_OpenStrokeColor`, `Look_OpenTextColor` (the design's selected category); closed `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor`, `Look_TextColor` |
| Deck fanning | `S_Card1`–`S_Card3` | Tween `Position` to `Look_OpenPosition` or `Look_ClosedPosition` (0.35 s, Back out) |
| Worn | `PieceTile` › `Background`, `S_Worn` | `Stroke2` and `Stroke` take `Look_SelectedStroke2`, `Look_SelectedStroke` and `Look_SelectedStrokeColor` (green), and the badge shows; the rest `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` |
| Rarity | `PieceTile` › `S_Rarity`; a fan card's `Stroke` | `ImageColor3` = `I.Rarity.GetLook(rarity).Base` |
| Unseen | `U_Deck<Slot>` › `S_New`, `PieceTile` › `S_New` | Shown: the crate cards' red NEW! tag |
| Not owned | `PieceTile` › `S_Locked` | Shown |
| Detail button | `S_Action` › `Background` › `Main`, `Stroke` | `Look_EquipMainColor` / `Look_EquipStrokeColor` (yellow), `Look_GetMainColor` / `Look_GetStrokeColor` (green), `Look_WornMainColor` / `Look_WornStrokeColor` (grey) |
| Snail | `U_Stage` › `S_View`'s Camera | Eases to the open or picked slot's view and follows a drag (Cosmetics' `STAGE_*`) |
