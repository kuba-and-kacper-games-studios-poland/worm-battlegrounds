# LoadoutPicker

Every weapon and utility the player owns, to put in the loadout slot that opened it, or **Empty slot**.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LoadoutPicker"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `LoadoutPicker`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Root `U_Widget` (WidgetManager's shape: `S_ScreenScale`, `Bg_Bottom`, `Bg_Top`, `Content`) and `MouseLockFix` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Widget` › `S_Slot` | Label (`Dim`) | Says which slot is being filled |
| `U_Items` | Cells (`Grid`) | Holds one `ItemTile` per owned item |
| `U_Widget` › `S_Empty` | Button (`Danger`) | Empties the slot |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | ItemTile` | `U_Items` | An Item (`S_Icon`, `S_Name`, `S_Info` = uses and cooldown; outline in its rarity), `S_Rarity`, `S_Copies` ("7 / 10" toward shiny). HoverInfo shows its details |

## Driven by

The game's `Loadout` module draws it on `WidgetManager_Opened` with `LoadoutPicker`.

## Preview

`Preview.lua` fills the grid with example items.

| Setting | What it does |
| --- | --- |
| `S_Items` (Slider, 0 to 6) | Owned items |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `LoadoutPicker`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "LoadoutPicker"`, or `I.WidgetManager.Open("LoadoutPicker")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Pick an item, empty the slot | Click | Tap | Select and A | Loadout connects the tiles and `S_Empty` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
