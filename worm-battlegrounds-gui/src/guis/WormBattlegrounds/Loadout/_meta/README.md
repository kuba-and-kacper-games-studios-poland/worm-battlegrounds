# Loadout

The lobby's bottom-left panel: the emote row (the smiley, the owned emotes, + for the emote shop), the Bazooka, and one slot per loadout slot (3 to 5). Locked slots show their price.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Loadout"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Loadout`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Loadout` | Box (`Panel`, `Fixed`) | The panel. Has `S_ScreenScale` |
| `U_Emotes` | Cells (horizontal, `Fixed`) | The emote row: holds one `Emote` per owned emote between `S_Smiley` and `S_Shop` |
| `U_Emotes` › `S_Smiley` | Item (`Small`) | Expands or folds the emote row |
| `U_Emotes` › `S_Shop` | Item (`Small`) | Opens `EmoteShop` (its tags) |
| `U_Slots` | Cells (`Squares`) | Holds one `Slot` per loadout slot after `S_Bazooka` |
| `U_Slots` › `S_Bazooka` | Item (`Square`) | The basic weapon, always there, no slot |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | Emote` | `U_Emotes` | An Item (`S_Icon`): a press plays the emote |
| `PREFAB | Slot` | `U_Slots` | An Item (`S_Icon`, `S_Name`; outline in the item's rarity), `S_Shiny`, `S_Lock` (cover on a locked slot) › `S_Price`; a press opens `LoadoutPicker` for that slot |

## Driven by

The game's `Loadout` (the slots) and `Cosmetics` (the emote row) modules.

## Preview

`Preview.lua` fills 5 slots and the emote row.

| Setting | What it does |
| --- | --- |
| `S_Unlocked` (Slider, 3 to 5) | Slots past it show their lock |
| `S_Emotes` (Slider, 1 to 9) | Owned emotes |
| `S_Shiny` (Toggle) | Marks the first item shiny |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Loadout`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1080 px tall screen: its module sets the UIScale to the screen's height / 1080, ×1.3 on Mobile screens shorter than 500 px, when it shows and when the screen changes size. Item cards' `S_Icon`, `S_Name` and `S_Info` are made by the theme's `Item` control (theme README).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the emote shop | Click + | Tap + | Select and A | `S_Shop` tags (WidgetManager `Toggle`) |
| Pick a slot, play an emote | Click | Tap | Select and A | Loadout and Cosmetics connect the cards |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
