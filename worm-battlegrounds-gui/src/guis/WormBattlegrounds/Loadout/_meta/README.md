# Loadout

The lobby's bottom-left bar: the emote row (the smiley, the owned emotes, + for the emote shop), the Bazooka, and one slot per loadout slot (3 to 5). Locked slots show their price.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). A dark `Hud` box like the match's loadout bar, titled Loadout, 800 wide and as tall as its rows, from the bottom-left corner; slots 112 square (`BarSlot`), all in one row on PC. On phones and tablets it's 440 wide at scale 0.9, so the slots wrap to two rows and clear the Play button. An empty slot shows the kit's plus; the next locked slot reads on a darker cover with only its price ("2500 coins", over two lines at full size; the hud's small padding leaves it room), and the shiny mark sits in the corner. Owned items sit on plain slots, the rarity only in the name's colour (its Preview refills the slots that way).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Loadout"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `Loadout`: `Enabled` off, `DisplayOrder` -1 (under Party, so its opened panel covers it on phones), `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Loadout` | Box (`Hud`) | The bar. Has `S_ScreenScale` |
| `U_Emotes` | Cells (horizontal, `Fixed`) | The emote row: holds one `Emote` per owned emote between `S_Smiley` and `S_Shop` |
| `U_Emotes` › `S_Smiley` | Item (`Small`) | Expands or folds the emote row |
| `U_Emotes` › `S_Shop` | Item (`Small`) | Opens `EmoteShop` (its tags) |
| `U_Slots` | Cells (`Squares`, `Fixed`, as tall as its rows) | Holds one `Slot` per loadout slot after `S_Bazooka` |
| `U_Slots` › `S_Bazooka` | Item (`Small`) | The basic weapon, always there, no slot |

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
| `S_Unlocked` (Slider, 3 to 5) | The next slot past it shows its cover and price, as Loadout's `Panel.lua` draws it; later ones hide |
| `S_Emotes` (Slider, 1 to 9) | Owned emotes |
| `S_Shiny` (Toggle) | Marks the first item shiny |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Loadout`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size. Item cards' `S_Icon`, `S_Name` and `S_Info` are made by the theme's `Item` control (theme README).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open the emote shop | Click + | Tap + | Select and A | `S_Shop` tags (WidgetManager `Toggle`) |
| Pick a slot, play an emote | Click | Tap | Select and A | Loadout and Cosmetics connect the cards |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Slot name | A slot's `S_Name` | The item's rarity colour (`I.Rarity.GetLook(rarity).Base`); white when empty (Loadout's `EMPTY_NAME_COLOR`) |
