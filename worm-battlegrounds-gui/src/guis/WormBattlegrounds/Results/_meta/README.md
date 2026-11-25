# Results

The end of a match: MATCH OVER, the player's place, every player's card (place, avatar, name with badges, username,
diamonds), what the player earned (diamonds, XP, level up) with their level bar filling from before the match to after it,
their match stats, **Rematch** (votes and time left) and
**Back to lobby**. It has no close button and can't be closed.

**Look.** The studio's `MatchOver` design (2026-11-12), ported 1:1 as `Primitive` nodes (its pictures, Londrina
font and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive`
ports"). A dark slanted panel in the middle of the screen, kept in shape by its `UIAspectRatioConstraint`. The first
three cards wear gold, silver and bronze outlines and place colours; Rematch is yellow, Back to lobby dark. Added on
2026-11-17 as `Primitive` nodes under the diamonds line: the lobby's level plate (`LevelPlate`) small, its diamond, title,
bar and XP count with the same colours, so the earned panel holds three rows (diamonds and XP, the level bar, the
stats). Since 2026-11-25 the diamond is 1.5 times the row's height with its level's box inside the turned square, so
three digits fit, and the bar is thin and sharp (a small corner, a darker lower half and a bright leading edge on the
gold fill), as the lobby replay's.

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
| `U_Earned` | Frame | `S_Diamonds` ("+50 diamonds"), `S_Xp` (the XP total, counted up line by line), `S_LevelUp` (hidden until a level up) on one line; the level bar (`S_XpRow`) under it; the match stats `S_Damage`, `S_Knockouts`, `S_BestShot` on the last |
| `U_Earned` › `S_XpRow` | Frame (hidden for results with no level before and after the match) | The level bar |
| `S_XpRow` › `S_LevelPop` | UIScale on the diamond's `Badge` | Pops from 1.4 to 1 when a level is reached |
| `S_XpRow` › `S_LevelGradient` | UIGradient on the diamond (a square turned 45°) | The level's prestige frame colours (`I.G_Progression.ApplyFrame`) |
| `S_XpRow` › `S_LevelNum`, `S_LevelTitle` | TextLabel (`S_LevelTitle` `TextCase_Upper`) | "14", "Level 14" |
| `S_XpRow` › `S_XpFill` | Frame in the dark `Track` (the gold to orange gradient and its gloss) | `Size` X = the share of the level filled |
| `S_XpRow` › `S_XpCount` | TextLabel | "60 / 156 XP", "Max level" at the top |
| `U_Widget` › `S_Rematch` | ImageButton | Votes for a rematch; its `S_Text` shows votes and time left ("Rematch  1/2  \|  0:15") |
| `U_Widget` › `S_Lobby` | ImageButton | Back to the lobby |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Placing` | `U_Placings` | `S_Place`, `S_Avatar` (cropped, so it keeps its shape and fills its box when the cards narrow), `S_Name` (team colour, with a `UITextSizeConstraint`), `S_Badges` (Frame: PlayerBadges clones its hidden `PREFAB \| Badge`, an ImageLabel with an `S_Glyph` TextLabel for Roblox's verified and Premium glyphs, once per badge and lays them out after the name), `S_Username`, `S_Diamonds` ("+8 diamonds"), `Background` › `S_Stroke` (the card's outline) |

## Driven by

The game's `MatchHud` module opens it with `I.WidgetManager.Open("Results")` when the match ends, and plays the level
bar from MatchRewards' `XpBefore` to `XpAfter` (its `Results` handler).

## Preview

`Preview.lua` fills the placings.

| Setting | What it does |
| --- | --- |
| `S_Players` (Slider, 2 to 4) | Players |
| `S_LevelUp` (Toggle) | Shows the level-up line |
| `S_XpShare` (Slider, 0 to 1) | How far the level bar is filled ("59 / 156 XP") |

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
| Level bar filling | `S_XpFill`, `S_XpCount`, `S_Xp` | After MatchHud's `RESULTS_XP_DELAY` each XP line adds to `S_Xp` with `Xp_Line`, then the fill tweens (quad out, a share of `RESULTS_XP_FILL_SECONDS`) while `Xp_Tick` ticks climb through `RESULTS_XP_TICK_PITCH` |
| Level reached | `S_LevelPop`, `S_LevelGradient`, `S_LevelUp` | `Level_Up`; the diamond pops (`RESULTS_LEVEL_TWEENINFO`, 0.3 s back out) in the new level's frame, "Level up! Level 15" shows, the bar starts again from empty |
