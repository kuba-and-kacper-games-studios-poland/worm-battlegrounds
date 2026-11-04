# Results

The end of a match: every player's place in team colours, what the player earned (coins, XP, level up), their match stats, **Rematch** (votes and time left) and **Back to lobby**. It has no close button and can't be closed.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Results"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Results`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`, `PreventClosing` set after export. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Result` | Label (`Title`) | "You placed 2nd!" |
| `U_Placings` | Cells | Holds one `Placing` per player |
| `U_Earned` | Box | `S_Coins`, `S_Xp`, `S_LevelUp` (hidden until a level up) |
| `U_Stats` | Box | `S_Damage`, `S_Knockouts`, `S_BestShot` |
| `U_Widget` › `S_Rematch` | Button (`Primary`) | Votes for a rematch; its text shows votes and time left |
| `U_Widget` › `S_Lobby` | Button | Back to the lobby |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Placing` | `U_Placings` | `S_Place`, `S_Avatar`, `S_Name` (team colour), `S_Coins` |

## Driven by

The game's `MatchHud` module opens it with `I.WidgetManager.Open("Results")` when the match ends.

## Preview

`Preview.lua` fills the placings.

| Setting | What it does |
| --- | --- |
| `S_Players` (Slider, 2 to 8) | Players |
| `S_LevelUp` (Toggle) | Shows the level-up line |

## Integration

### Setup

Export it with the Gui tool: a ScreenGui named `Results`. Then set the attribute `PreventClosing = true` on the exported ScreenGui (a gui table can't hold it): WidgetManager then opens nothing over it. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Rematch | Click | Tap | A (Cross) | `S_Rematch` tags (`Utils_ButtonKey`); MatchHud connects it |
| Back to lobby | Click | Tap | B (Circle) | `S_Lobby` tags (`Utils_ButtonKey`); MatchHud connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
