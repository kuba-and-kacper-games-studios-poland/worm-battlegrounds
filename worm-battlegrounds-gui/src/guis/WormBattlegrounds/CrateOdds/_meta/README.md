# CrateOdds

A crate's **Details**: every item it can drop, its rarity and chance (adding up to 100%), and the price. Roblox requires these odds before a paid random item is bought.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CrateOdds"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `CrateOdds`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Crate` | Label (`Heading`) | The crate's name |
| `U_Widget` › `S_Price` | Label (`Coin`) | Its prices |
| `U_Odds` | Cells | Holds one `OddsRow` per item |
| `U_Widget` › `S_Total` | Label (`Dim`) | "Total: 100%" |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | OddsRow` | `U_Odds` | `S_Icon`, `S_Name`, `S_Rarity`, `S_Chance` |

## Driven by

The game's `Crates` module draws it on `WidgetManager_Opened` with `CrateOdds`.

## Preview

`Preview.lua` fills a weapon crate's example odds.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CrateOdds`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CrateOdds"`, or `I.WidgetManager.Open("CrateOdds")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |


### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
