# Loadout

The lobby's **LOADOUT** at the right: two rows of three numbered cards, the Bazooka then slots 1 to 5 (an item's
picture, name and copies, a + on an empty slot, the lock and price on the next slot to open), and under it the
**EMOTES** row (the smiley, the owned emotes, + for the emote shop).

**Look.** Ported 1:1 from the studio's `LobbyInventory` gui (its `Right` frame, 2026-11-09) as `Primitive` nodes,
laid out in screen fractions with aspect-ratio constraints (no `S_ScreenScale`). The design's slot looks are kept as
attributes on the slot prefab (normal, selected, the + slot's darker outline). Added: the shiny mark, the lock cover
(the design's locked inventory card) with the price, and the EMOTES row, which the design lacks, built from copies of
its header and slot card; button tags (`Utils_ButtonScale`, `Utils_ButtonSound`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Loadout"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Loadout`: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Loadout` | Frame | The panel (the design's `Right`) |
| `U_Slots` | Frame | Both rows; the tutorial's arrow points at its top |
| `U_TopRow`, `U_BottomRow` | Frame (horizontal lists) | Loadout clones the basic weapon and slots 1, 2 into the top row, slots 3 to 5 into the bottom one |
| `U_Emotes` | ScrollingFrame (horizontal) | The emote row: `Emote` cards between `S_Smiley` and `S_Shop` |
| `U_Emotes` › `S_Smiley` | ImageButton | Folds or opens the row |
| `U_Emotes` › `S_Shop` | ImageButton (+) | Opens `EmoteShop` (its tags) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| Slot` | `U_TopRow` | An ImageButton: `S_Number`, `S_Icon`, `S_Name`, `S_Amount` ("x5"), `S_Plus` (empty slot), `S_Shiny`, `S_Lock` › `S_Price`. `Background` › `Stroke2` / `Stroke` take the looks in its attributes |
| `PREFAB \| Emote` | `U_Emotes` | An ImageButton: `S_Icon`, `S_Name`; a press plays the emote |

## Driven by

The game's `Loadout` module (`Scripts/Client/Panel.lua`) and `Cosmetics` (`Scripts/Client/Emotes.lua`, the emote row);
`Tutorial` points at `U_Slots`.

## Preview

`Preview.lua` fills the cards and the emote row.

| Setting | What it does |
| --- | --- |
| `S_Unlocked` (Slider, 3 to 5) | Open slots; the next one shows its lock and price, later ones hide |
| `S_Selected` (Slider, 0 to 5) | The slot whose picker is open (selected look) |
| `S_Emotes` (Slider, 1 to 9) | Owned emotes |
| `S_Shiny` (Toggle) | The first slot's item shiny |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Loadout`, `Enabled` off. The Lobby module
turns it on outside matches (and off while a full-screen widget is open). It keeps its `Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a slot (opens `LoadoutPicker`, or asks to open a locked slot) | Click | Tap | Select and A | Loadout (`I.Interact.OnPress`) |
| Play an emote, fold the row | Click | Tap | Select and A | Cosmetics |
| Open the emote shop | Click + | Tap + | Select and A | `S_Shop` tags (WidgetManager `Toggle`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Cards | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Picker open for the slot | `Slot` › `Background` | `Stroke2`, `Stroke`, colour from `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor` (white); otherwise `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` |
| Empty slot | `Slot` | `S_Plus` shown, the outline `Look_EmptyStrokeColor` |
| Item | `Slot` › `S_Name` | The item's rarity colour (`I.Rarity.GetLook(rarity).Base`) |
| Locked | `Slot` › `S_Lock` | Shown, with the price in `S_Price` |
