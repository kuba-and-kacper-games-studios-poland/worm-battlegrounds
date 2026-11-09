# LoadoutPicker

The **INVENTORY** window: every weapon and utility, to put in the loadout slot that opened it, owned ones first,
then the ones not owned yet under a lock; **EMPTY** empties the slot.

**Look.** Ported 1:1 from the studio's `LobbyInventory` gui (its `Inventory` frame, 2026-11-09) as `Primitive` nodes,
in WidgetManager's shape (`U_Widget` › `Content` › the design's frame, and `MouseLockFix`): its tilted grid of slanted
cards, screen-fraction layout with aspect-ratio constraints (no `S_ScreenScale`). The design's card looks (normal,
equipped, selected) are attributes on the card prefab, and its locked card's cover is `S_Locked`. Added: **EMPTY**,
a copy of the design's JOIN button, left of the close; button tags and `HoverInfo_Target` on the cards.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LoadoutPicker"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `LoadoutPicker`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens |
| `U_Widget` › `S_Close` | ImageButton (red X) | Closes the widget (its tags), or B on a pad |
| `U_Widget` › `S_Empty` | ImageButton (EMPTY) | Empties the slot |
| `U_Items` | ScrollingFrame | Holds an `ItemRow` per three cards |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| ItemRow` | `U_Items` | A row: `Content` holds its cards and the nested `PREFAB \| ItemCard` (code clones it, then removes it from each row) |
| `PREFAB \| ItemCard` (nested) | `ItemRow` › `Content` | An ImageButton: `S_Icon`, `S_Name`, `S_Amount` ("x5"), `S_Rarity` (the corner mark), `S_Locked` (the lock cover). `Background` › `Stroke2` / `Stroke` take the looks in its attributes; `HoverInfo_Title` and `HoverInfo_Rarity` feed HoverInfo |

## Driven by

The game's `Loadout` module (`Scripts/Client/Picker.lua`) draws it on `WidgetManager_Opened` with `LoadoutPicker`.

## Preview

`Preview.lua` fills the grid the way Picker does.

| Setting | What it does |
| --- | --- |
| `S_Items` (Slider, 0 to 7) | Cards: one selected, two equipped, two normal, two locked |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `LoadoutPicker`, `Enabled` off.
WidgetManager opens it (Loadout calls `I.WidgetManager.Open("LoadoutPicker")` when a slot is pressed). It keeps its
`Name`, Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Close | Click X | Tap X | B | `S_Close` tags (`Interact_Button` → WidgetManager `CloseCurrent`, `Utils_ButtonKey`) |
| Pick an owned item, empty the slot | Click | Tap | Select and A | Loadout (`I.Interact.OnPress`); locked cards do nothing |
| Item details | Hover | Long press | Select | `HoverInfo_Target` (name, uses and cooldown, rarity) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Cards, EMPTY, X | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| In this slot | `ItemCard` › `Background` | `Look_SelectedStroke2`, `Look_SelectedStroke`, `Look_SelectedStrokeColor` (white) |
| In another slot | `ItemCard` › `Background` | `Look_EquippedStroke2`, `Look_EquippedStroke`, `Look_EquippedStrokeColor` (green) |
| Otherwise | `ItemCard` › `Background` | `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` (grey) |
| Rarity | `ItemCard` › `S_Rarity` | `ImageColor3` = `I.Rarity.GetLook(rarity).Base` |
| Not owned | `ItemCard` › `S_Locked` | Shown; no copies |
