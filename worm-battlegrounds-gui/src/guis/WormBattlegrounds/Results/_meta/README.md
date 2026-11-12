# Results

The end of a match: MATCH OVER, the player's place, every player's card (place, avatar, name with badges, username,
coins), what the player earned (coins, XP, level up), their match stats, **Rematch** (votes and time left) and
**Back to lobby**. It has no close button and can't be closed.

**Look.** The studio's `MatchOver` design (2026-11-12), ported 1:1 as `Primitive` nodes (its pictures, Londrina
font and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive`
ports"). A dark slanted panel in the middle of the screen, kept in shape by its `UIAspectRatioConstraint`. The first
three cards wear gold, silver and bronze outlines and place colours; Rematch is yellow, Back to lobby dark.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Results"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and aspect-ratio constraints, no `S_ScreenScale` |
| Export | A ScreenGui named `Results`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`, `PreventClosing` set after export. Root `U_Widget` (full screen, WidgetManager's shape: `Content` holding the panel) and `MouseLockFix` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Result` | TextLabel (rich, `TextCase_Upper`) | "You placed `<font>`2nd`</font>`!", the place in its colour |
| `U_Placings` | Frame with a horizontal UIListLayout | Holds one `Placing` per player; four fit across, more share the width (MatchHud's `RESULTS_FIT_PLACINGS`) |
| `U_Earned` | Frame | `S_Coins`, `S_Xp`, `S_LevelUp` (hidden until a level up) on one line; the match stats `S_Damage`, `S_Knockouts`, `S_BestShot` on the next |
| `U_Widget` › `S_Rematch` | ImageButton | Votes for a rematch; its `S_Text` shows votes and time left ("Rematch  1/2  \|  0:15") |
| `U_Widget` › `S_Lobby` | ImageButton | Back to the lobby |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Placing` | `U_Placings` | `S_Place`, `S_Avatar`, `S_Name` (team colour, with a `UITextSizeConstraint`), `S_Badges` (Frame: PlayerBadges clones its hidden `PREFAB \| Badge`, an ImageLabel with an `S_Glyph` TextLabel for Roblox's verified and Premium glyphs, once per badge and lays them out after the name), `S_Username`, `S_Coins`, `Background` › `S_Stroke` (the card's outline) |

## Driven by

The game's `MatchHud` module opens it with `I.WidgetManager.Open("Results")` when the match ends.

## Preview

`Preview.lua` fills the placings.

| Setting | What it does |
| --- | --- |
| `S_Players` (Slider, 2 to 4) | Players |
| `S_LevelUp` (Toggle) | Shows the level-up line |

## Integration

### Setup

Export it with the Gui tool: a ScreenGui named `Results`. Then set the attribute `PreventClosing = true` on the
exported ScreenGui (a gui table can't hold it): WidgetManager then opens nothing over it.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Rematch | Click | Tap | A (Cross) | `S_Rematch` tags (`Utils_ButtonKey`); MatchHud connects it |
| Back to lobby | Click | Tap | B (Circle) | `S_Lobby` tags (`Utils_ButtonKey`); MatchHud connects it |

Both buttons show their pad button in a `PadHint` badge on Console (`Console_Hint`, `Console_Action` `Confirm`, `Back`).

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons | `Utils_ButtonScale`: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds |
| Place | `Placing` › `S_Place`, `S_Stroke` | 1st to 3rd take `Look_<1-3>PlaceColor` and `Look_<1-3>StrokeColor` (gold 255, 200, 40; silver; bronze), the rest `Look_PlaceColor` (white) and `Look_StrokeColor` (grey 130) |
