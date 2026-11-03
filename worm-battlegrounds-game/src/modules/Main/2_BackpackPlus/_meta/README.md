# BackpackPlus

A replacement for Roblox's backpack and hotbar. The client draws every tool the player holds as a slot (with a viewport preview, a quantity and an optional custom display), in a toolbar with number-key shortcuts and in a backpack view with search and category filters. Slots can be dragged between the toolbar and the backpack, reserved for matching tools, and marked as favourites (which locks the inventory item). The toolbar order is saved per platform.

| | |
| --- | --- |
| Folder | `src/modules/Main/2_BackpackPlus` |
| Runs on | Client, Server |
| Exposes | `I.BackpackPlus` (client) |
| Uses | `I.UserInterface` (the `BackpackPlus` gui), `I.Utils` (`PlayPress`), `I.HoverInfo` (its `BackpackPlus` provider), `I.Component`, `I.Topic`, `I.Network`, `I.Inventory` (favourites), `I.Platform` (and its `PLATFORMS` setting, on the server), `I.Tool` (server) |
| Saves | `Profile.BackpackPlus` (toolbar order) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Starts the handlers, registers the components and Topics, assigns `I.BackpackPlus` |
| `Server.lua` | Saves and returns the toolbar order |
| `Settings.lua` | Toolbar slots and keys, saving, favourite look, viewport camera, custom displays |
| `Scripts/Client/HoverInfo.lua` | The `BackpackPlus` HoverInfo provider: a slot's hover info, from the `Data/HoverInfo` file named after its tool's `BackpackPlus_DisplayType` (none: no box) |
| `Scripts/Client/Backpack.lua` | Opening and closing the backpack view |
| `Scripts/Client/Toolbar.lua` | The toolbar, its size and key shortcuts, the gamepad hints' `Console_HintHidden` (every 0.1 s: the bumpers while the toolbar is empty, every unequip hint but the equipped toolbar slot's while the backpack is closed), loading and saving its order (saves are batched; Tools that arrive after the load go to their saved slot) |
| `Scripts/Client/Slot.lua` | One slot per tool: building, equipping, dragging and dropping, quantity and display updates |
| `Scripts/Client/Filter.lua` | Named filters on the backpack view |
| `Scripts/Client/Favorite.lua` | Favourite mode and toggling an item's favourite |
| `Scripts/Client/Lock.lua` | Locks that disable the backpack (by source) |
| `Scripts/Client/Reserve.lua` | Toolbar slots reserved for matching tools |
| `Components/*.lua` | Slot, slot viewport motion, filter and favourite buttons |
| `Data/DisplayType/*.lua` | Custom viewport displays, by name (`Example.lua` is the template) |
| `Data/HoverInfo/*.lua` | Each display type's hover info (a function of the Tool returning a `HoverInfo_Content`), by display type; `Example.lua` is the template |
| `_meta/_types.lua` | Slot data, the handlers' shared context |

## API

### Client: `I.BackpackPlus`

| Function | Returns | What it does |
| --- | --- | --- |
| `Toggle()` | | Opens or closes the backpack view |
| `GetState()` | `boolean` | Whether the backpack view is open |
| `ToggleItem(slotFrame: Frame)` | | Equips or unequips the slot's tool |
| `ToggleItemAtSlot(slotId: number)` | | The same for a toolbar slot |
| `Unequip()` | `boolean` | Unequips the equipped Tool and plays its toolbar slot's click look and sound when it stands on the toolbar; `false` while locked, without a living character or with nothing equipped. ume's Console module binds it to D-pad down while the backpack is closed |
| `CycleToolbar(direction: number)` | | Equips the Tool on the next occupied toolbar slot after the equipped one (`1`) or before it (`-1`), wrapping around; with nothing equipped, the first or the last, and plays the slot's click look and sound (`I.Utils.PlayPress`). Does nothing while locked or when the only Tool is already equipped. ume's Console module binds it to the gamepad bumpers |
| `DropSlot(slotFrame: Frame, setToolbarSlotId: number?)` | | Puts a slot in the toolbar (at `setToolbarSlotId`) or back in the backpack. Without an id it uses the mouse position; an id outside the current toolbar leaves the slot where it is |
| `ReloadToolbar()` | | Loads the saved toolbar order again, for Tools granted after spawning; does nothing while a load runs or the character is dead |
| `SetLock(source: string, state: boolean)` / `ClearLock(source)` | | Any active lock disables the backpack (a cutscene, a menu) |
| `IsLocked()` | `boolean` | Whether any lock is active |
| `ReserveToolbarSlot(slotId: number, match: (tool: Tool) -> boolean)` | | Matching tools snap to that slot and can't be dragged off. `slotId` is 1 to `TOOLBAR_SLOTS.Default`; on a platform with fewer slots, a slot above its count stays empty |
| `ClearToolbarReservation(slotId)` | | Ends the reservation; the tool stays |
| `IsToolReservationLocked(tool: Tool)`, `IsSlotReservationLocked(slotFrame)` | `boolean` | Whether a tool or slot is held by a reservation |
| `SetFilter(filterName: string, filterValue: string)` / `ClearFilter(filterName)` | | Named filters on the backpack view (`Category`, a search) |
| `CycleCategory(direction: number)` | `boolean` | Selects the category above (`-1`) or below (`1`) the active one, in the order the category buttons (`BackpackPlus_FilterButton`) stand on screen, each category once, wrapping from the last to the first and back; plays the category button's click look and sound (`I.Utils.PlayPress`). Whether it changed. ume's Console module binds it to D-pad up and down while the backpack is open |
| `SetFavoriteMode(state: boolean)`, `ToggleFavoriteMode()` | | Favourite mode: clicking a slot favourites it |
| `IsFavoriteMode()` | `boolean` | |
| `ToggleSlotFavorite(slotFrame)` | `boolean` | Locks or unlocks the slot's inventory item (`Inventory_LockSwitch`) |

`_getSlotSize` and `_getSlotAbsoluteSize` are shared with the components; don't call them from other modules.

## Usage

```lua
-- Client: block the backpack during a cutscene
I.BackpackPlus.SetLock("Cutscene", true)
I.BackpackPlus.ClearLock("Cutscene")

-- Client: keep the sword in slot 1
I.BackpackPlus.ReserveToolbarSlot(1, function(tool: Tool) return tool.Name == "Sword" end)

-- Client: apply the saved order again once a round's Tools were granted
I.BackpackPlus.ReloadToolbar()
```

## Network

### Server

**Receive: RemoteEvents**

- `_backpackPlus_UpdateSavedToolbarSlots @ (player: Player, newSlotsIds: table)`: saves the toolbar order, slots 1 to the last platform's slot count only. An entry equal to the saved one is kept as it is; a changed entry is saved only when the player has that Tool. At most 5 calls per second per player.

**Receive: RemoteFunctions**

- `_backpackPlus_GetSavedToolbarslots @ (player: Player, currentPlatform: string?)`: the saved order and the previous platform. `currentPlatform` becomes `LastPlatform` only when it is in Platform's `PLATFORMS`. At most 5 calls per second per player.

### Client

**Topics**

- `BackpackPlus_FilterSet @ (filterName: string, filterValue: string?)`
- `BackpackPlus_FavoriteModeChanged @ (isActive: boolean)`
- `BackpackPlus_ToolbarSizeChanged @ ()`

**Send: RemoteEvents**

- `_backpackPlus_UpdateSavedToolbarSlots @ (newSlotsIds: table)`: one save per burst of toolbar changes, 0.25 s after the first. Saved slots whose Tools haven't arrived yet are sent back unchanged.

**Send: RemoteFunctions**

- `_backpackPlus_GetSavedToolbarslots @ (currentPlatform: string?)`

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `BackpackPlus.ToolbarSlots` | Toolbar order: slot number → `<Tool_ServerUUID>___<name>___<BackpackPlus_ToolbarRetrieve>`. A save changes only the slots within the last platform's slot count, so slots above it stay saved |
| | `BackpackPlus.LastPlatform` | The platform it was saved on |
| Session | `BackpackPlus.ToolbarResolved`, `NewPlatform` | Whether the saved order was applied this session |
| Tool attributes (set by the game) | `BackpackPlus_Quantity` | Number shown on the slot |
| | `BackpackPlus_DisplayType` | A `Data/DisplayType` name drawing the viewport |
| | `BackpackPlus_FilterCategory` | What the `Category` filter matches; a Tool without it is matched by its `BackpackPlus_DisplayType` |
| | `BackpackPlus_FilterText` | Extra words the search matches |
| | `BackpackPlus_ToolbarRetrieve`, `BackpackPlus_Update` | Toolbar placement and a forced refresh |
| | `Inventory_IsInventoryItem`, `Inventory_ItemId`, `Inventory_ItemUUID` | The inventory item a favourite locks |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TOOLBAR_SLOTS` | `Default = 10`, `Mobile = 6` | Visible toolbar slots by platform |
| `TOOLBAR_KEY_MAPPINGS` | `One`…`Zero` → 1…10 | Key → toolbar slot |
| `TOOLBAR_SAVE` | `true` | Save the toolbar order |
| `TOOLBAR_FILL_DELAY` | `1` | Seconds after spawning before the saved order loads. Tools that arrive later go to their saved slot; `ReloadToolbar()` loads the order again |
| `TOOLBAR_FILL_ONLY_WHEN_EMPTY` | `true` | Fill the toolbar only when no saved slot moved. With `TOOLBAR_SAVE` off the toolbar always fills |
| `TOOLBAR_FILL_ON_PLATFORM_CHANGED` | `true` | Fill new slots once when the platform has more |
| `FAVORITE_GRADIENT_NAME` | `"Gold"` | Gradient while favourite mode is on |
| `FAVORITE_ICON_SHOW_TWEEN`, `FAVORITE_ICON_HIDE_TWEEN` | | The favourite icon's tweens |
| `VIEWPORT_CAMERA_FOV`, `VIEWPORT_CAMERA_CFRAME` | `7.5`, … | Slot preview camera |
| `CUSTOM_DISPLAY_UPDATES` | `{}` | Display functions by name, besides `Data/DisplayType` |

## Components

All four are client components inside the `BackpackPlus` gui (`RegisterOnLoaded`).

| Tag | Script | Tag on | What it does |
| --- | --- | --- | --- |
| `BackpackPlus_Slot` | `Components/Slot.lua` | `Frame` (the slot prefab) | Click to equip, drag to move (a release anywhere ends the drag; disabling the gui cancels it), sizes from the toolbar |
| `BackpackPlus_Slot_ViewportMotion` | `Components/Slot_ViewportMotion.lua` | `Frame` (the slot prefab) | Swings the preview model (`UnitDisplayModel` in `S_ItemWorldModel`, also when it is added or rebuilt later) while the slot is on screen, and scales it on hover and press |
| `BackpackPlus_FilterButton` | `Components/FilterButton.lua` | `GuiObject` | Sets the `Category` filter; highlighted while active: its `S_Background` gradient turns grey, and a `Selected` frame inside it, when it has one, shows |
| `BackpackPlus_FavoriteButton` | `Components/FavoriteButton.lua` | `GuiButton` | Toggles favourite mode; gold while on |

| Attribute | On | Type | Default | What |
| --- | --- | --- | --- | --- |
| `BackpackPlus_FilterCategory` | `BackpackPlus_FilterButton` | string | `""` | The category the button filters to |
