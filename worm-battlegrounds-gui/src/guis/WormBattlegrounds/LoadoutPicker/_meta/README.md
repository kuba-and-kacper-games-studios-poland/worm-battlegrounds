# LoadoutPicker

Every weapon and utility the player owns, to put in the loadout slot that opened it, or **Empty slot**.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Items sit on plain slots in a 240 × 240 grid, the rarity label in the rarity's glow colour (its Preview refills them that way); the copies count got a height so it shows.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LoadoutPicker"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
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

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `LoadoutPicker`, `Enabled` off. WidgetManager opens it (a button's `Interact_Button` with `Interact_Function = "Toggle"`, `Interact_Arg1 = "LoadoutPicker"`, or `I.WidgetManager.Open("LoadoutPicker")`), and the module that fills it draws it on `WidgetManager_Opened`. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click ✕ | Tap ✕ | B (Circle) | `Bg_Top` › `CloseButton` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Pick an item, empty the slot | Click | Tap | Select and A | Loadout connects the tiles and `S_Empty` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Rarity | `ItemTile` › `S_Rarity` | The rarity's name in its colour (`I.Rarity.GetLook(rarity).Base`) |
