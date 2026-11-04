# Shop

The shop: the 5 diamond packs and the 4 game passes, every benefit listed, prices read live from Roblox.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Shop"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Shop`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Packs` | Cells (horizontal, `Fixed`) | Holds one `Pack` per diamond pack |
| `U_Passes` | Cells (`Tiles`) | Holds one `Pass` per game pass |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Pack` | `U_Packs` | An Item (`S_Name` = pack, `S_Info` = diamonds; a press prompts the purchase) and `S_Price` |
| `PREFAB | Pass` | `U_Passes` | `S_Name`, `S_Benefits`, `S_Price`, `S_Buy` |

## Driven by

The game's `Shop` module draws it on `WidgetManager_Opened` with `Shop`.

## Preview

`Preview.lua` fills the wiki's packs and passes.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Shop`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "Shop"`, or `I.WidgetManager.Open("Shop")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size. Prices come from `GetProductInfoAsync`, never hard-coded.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Buy | Click | Tap | Select and A | Shop connects the packs and `S_Buy` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
