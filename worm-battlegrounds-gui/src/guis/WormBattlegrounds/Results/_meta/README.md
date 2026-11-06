# Results

The end of a match: every player's place in team colours, what the player earned (coins, XP, level up), their match stats, **Rematch** (votes and time left) and **Back to lobby**. It has no close button and can't be closed.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The placings are a lineup of tall slate cards side by side (the `Players` cells, people get cards): four fit across at 16:9, and a list that doesn't fit scrolls. The earnings and the match stats share one box under it. Rematch is the one yellow, Back to lobby blue.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Results"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `Results`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`, `PreventClosing` set after export. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Result` | Label (`Title`) | "You placed 2nd!" |
| `U_Placings` | Cells (`Players`) | Holds one `Placing` per player |
| `U_Earned` | Box | `S_Coins`, `S_Xp`, `S_LevelUp` (hidden until a level up) on one line; the match stats `S_Damage`, `S_Knockouts`, `S_BestShot` on the next |
| `U_Widget` › `S_Rematch` | Button (`Primary`) | Votes for a rematch; its text shows votes and time left |
| `U_Widget` › `S_Lobby` | Button | Back to the lobby |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Placing` | `U_Placings` | A tall card, centred top to bottom: `S_Place`, `S_Avatar`, `S_Name` (team colour), `S_Coins` |

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

Export it with the Gui tool: a ScreenGui named `Results`. Then set the attribute `PreventClosing = true` on the exported ScreenGui (a gui table can't hold it): WidgetManager then opens nothing over it. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Rematch | Click | Tap | A (Cross) | `S_Rematch` tags (`Utils_ButtonKey`); MatchHud connects it |
| Back to lobby | Click | Tap | B (Circle) | `S_Lobby` tags (`Utils_ButtonKey`); MatchHud connects it |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
