# CrateOpen

The crate reveal: the crate shakes, bursts in the result's rarity colour, then shows the item ("Shiny!" when it turned shiny), or the 10 items of a 10-pack, with **Open again**.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/CrateOpen"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `CrateOpen`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Stage` | Frame | The reveal area |
| `U_Stage` › `S_Crate` | Picture | The crate before it opens; Crates shakes it |
| `U_Stage` › `S_Burst` | Frame | `I.UIEmitter` bursts here in the result's rarity colour |
| `U_Stage` › `S_Card` | Item | The single result (`S_Icon`, `S_Name`, `S_Info`); outline in its rarity |
| `U_Stage` › `S_Shiny` | Label | "Shiny!" on `S_Card` |
| `U_Cards` | Cells (`Grid`) | The 10 results of a 10-pack (shown in place of `U_Stage`) |
| `U_Widget` › `S_OpenAgain` | Button (`Primary`) | Opens the same crate again |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | ResultCard` | `U_Cards` | An Item and `S_Shiny` |

## Driven by

The game's `Crates` module draws it on `WidgetManager_Opened` with `CrateOpen` and plays the reveal.

## Preview

`Preview.lua` shows each step.

| Setting | What it does |
| --- | --- |
| `S_Step` (Segmented: Crate, One, Ten) | The closed crate, one result, or 10 |
| `S_Shiny` (Toggle) | Shows "Shiny!" on the single result |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `CrateOpen`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "CrateOpen"`, or `I.WidgetManager.Open("CrateOpen")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Open again | Click | Tap | Select and A | Crates connects `S_OpenAgain` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
| Reveal | `U_Stage` | Planned in Crates: shake, burst (`I.UIEmitter`) in the rarity colour, card pop |
