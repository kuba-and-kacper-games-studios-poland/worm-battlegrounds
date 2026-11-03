# BackpackPlus

The player's tools, in place of Roblox's backpack and hotbar: a toolbar of slots along the bottom edge, and a backpack view above it with a search bar, a favourite mode button, category filters and a scrolling grid of every tool. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves, so no theme changes it. Its look is the one `AFKTeleport` follows too: dark panels (a black `UIGradient` at 0.35 transparency over a white fill), a 3 px black `UIStroke` and a white `UIStroke_Highlight` at 0.5 fading out down from the top edge, and Source Sans Heavy or Bold white text outlined in black; every stroke is tagged `Utils_UIStroke`. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/BackpackPlus"` |
| Modes | Night only: its values are its own, the same in any mode |
| Devices | Desktop, Mobile and Console: Mobile has its own sizes (`Utils_PlatformSize`, Mobile below); Console shows the gamepad hints (`Console_Hint`, Console below) and hides the slots' key text (`Utils_HideOnPlatform`) |
| Export | A ScreenGui named `BackpackPlus` in StarterGui: `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` so it shows from the start |

To restyle it in a game, copy it into the game's own folders and change the values there, keeping its `Name`, its Ids and the prefab's name: the BackpackPlus module finds them by those names.

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Backpack` | Frame | The backpack view, hidden until BackpackPlus opens it; 2.25 times as wide as tall, above the toolbar. Its `Body` frame holds the rest, with a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) |
| `U_Backpack` › `S_SearchBarContainer`, `S_SearchBar` | Frame, TextBox | The search pill on the right of the top row; the Filter handler filters the items by the typed text |
| `U_Backpack` › `S_FavoriteButtonContainer`, `S_FavoriteButton`, `S_Background` | Frame, ImageButton, Frame | The favourite mode pill on the left, outlined orange to yellow; the `BackpackPlus_FavoriteButton` component toggles favourite mode and tints `S_Background` |
| `U_Backpack` › `S_ItemsContainer`, `S_ItemsContainerGridLayout` | Frame, UIGridLayout | The grid of item slots (92 px cells) in a scrolling frame; BackpackPlus clones `PREFAB \| Slot` into it and sizes the cells |
| `U_Category-All`, `U_Category-1`, `U_Category-2` | Frame | Category filter buttons along the backpack's left side, each an ImageButton tagged `BackpackPlus_FilterButton` with its `BackpackPlus_FilterCategory` (`""` shows every item; the examples filter `Category1` and `Category2`). The component tints each one's `S_Background`; `S_ItemName` is its label. Add, remove or rename them per game |
| `U_Toolbar` | Frame | The toolbar along the bottom edge, slots side by side from the centre; BackpackPlus fills it with toolbar slots and sizes them, the backpack and the grid from its width |
| `U_Toolbar` › `S_PreviousHint`, `S_NextHint` | ImageLabel | The LB (L1) and RB (R1) hints either side of the toolbar's slots, on Console only |
| `U_Backpack` › `S_CloseHint` | ImageLabel | The B (Circle) hint at the backpack view's top right corner, on Console only |

## Prefabs

### `PREFAB | Slot`

In `U_Toolbar`. One tool: a square frame with `S_SlotButton`, an ImageButton tagged `Utils_ButtonScale`, inside it.

| Element | Class | What it is |
| --- | --- | --- |
| `S_SlotButton` | ImageButton | The slot; the `Slot` component handles clicks, drags and equipping |
| `S_Background` | Frame | The slot's black fill (0.2 transparency), outline and highlight; tinted while equipped |
| `S_BackgroundGlowContainer` | Frame | A soft `UIShadow` glow behind the slot |
| `S_ItemIcon` | ImageLabel | The tool's icon, hidden until the tool has one |
| `S_ItemViewportFrame` › `S_ItemWorldModel` | ViewportFrame, WorldModel | The tool's 3D preview, hidden until shown |
| `S_ItemName` | TextLabel | The tool's name |
| `S_KeyCode`, `S_Quantity` | TextLabel | The toolbar key in the top left, the quantity in the top right. `S_KeyCode` sits in a `KeyCodeContainer` frame tagged `Utils_HideOnPlatform` (`Utils_ConsoleVisibility` false), so the key hides on Console, where the bumpers pick a slot, while BackpackPlus still shows and hides `S_KeyCode` itself |
| `S_FavoriteIconContainer` › `S_FavoriteIcon` | Frame, ImageLabel | The mark on the top edge while the tool is a favourite |
| `S_UnequipHint` | ImageLabel | D-pad down above the slot (`Console_Hint`, built with `Console_HintHidden` true): shown on Console only over the equipped Tool's toolbar slot while the backpack is closed |

## Driven by

ume's BackpackPlus module (`src/modules/Main/2_BackpackPlus`) finds this gui as `I.UserInterface.UI["BackpackPlus"]`: its handlers find `U_Backpack`, `U_Toolbar` and the `S_` elements above, and clone `PREFAB | Slot` for every tool. Its components (`BackpackPlus_FavoriteButton`, `BackpackPlus_FilterButton`, `Slot`) run on the tagged buttons and their `S_Background`. ume's Console module draws the `Console_Hint` hints and binds the gamepad (Console below).

## Console

Gamepad hints, each an ImageLabel tagged `Console_Hint` and built hidden, with the System theme's Xbox icons (`Color`, and `ColorThick` for B). In game ume's Console module (`src/modules/Main/0_Console`) shows them while the player is on Console, swaps them to the player's pad (Xbox or PlayStation), and binds the buttons they show:

| Hint | Where | Button | What it does |
| --- | --- | --- | --- |
| `S_PreviousHint` | Left of the toolbar's slots (`LayoutOrder` -1), centred on them (a `UIFlexItem`) | LB / L1 | Equips the Tool on the previous occupied toolbar slot |
| `S_NextHint` | Right of them (`LayoutOrder` 1000) | RB / R1 | Equips the Tool on the next one |
| `S_CloseHint` | Outside the backpack view's top right corner, 0.14 of its height, in the ColorThick style | B / Circle | Closes the backpack view |
| `U_Category-All` › `S_CategoryUpHint` | Above the first category button, 0.45 of its width, 6 px clear | D-pad up | While the backpack is open, selects the category above |
| `U_Category-2` › `S_CategoryDownHint` | Below the last category button, the same size | D-pad down | Selects the category below |
| `PREFAB \| Slot` › `S_UnequipHint` | Above the equipped Tool's toolbar slot, 0.4 of the slot, while the backpack is closed | D-pad down | Unequips the Tool |

D-pad up also opens the closed backpack view (the top bar's backpack button carries it on Console), and D-pad down unequips the equipped Tool while it is closed; a Tool equipped from the backpack shows no hint. BackpackPlus hides the bumper hints while the toolbar holds no Tool, and every unequip hint but the equipped toolbar slot's, through `Console_HintHidden`, which the Console module follows. Categories wrap: down from the last goes to the first, up from the first to the last. A game that adds category buttons moves `S_CategoryDownHint` into its last one. The bumper hints are ImageLabels, not Frames, so BackpackPlus's slot sizing (every Frame in the toolbar) leaves them alone, and they follow the visible slots. In the Gui tool, the Device switch's Console shows them, and its Pad switch shows the PlayStation icons.

## Mobile

BackpackPlus sizes everything from `U_Toolbar`'s width: each toolbar slot is a square that width divided by the toolbar's slot count (ume's `TOOLBAR_SLOTS`: 10 on Desktop, 6 on Mobile), the backpack is as wide as the toolbar and sits just above its slots, and the grid's cells take a slot's share of the backpack. The Mobile sizes work through that:

| Element | Desktop | Mobile | Why |
| --- | --- | --- | --- |
| `U_Toolbar` | `UDim2.new(0.5, 50, 0.1, 0)` | `UDim2.fromScale(0.425, 0.1)`, at least 348 px wide (a `UISizeConstraint`) | Six slots a thumb's size (about 60 px on an 844 × 390 phone, 83 px on an iPad), clear of the thumbstick and the jump button; 58 px slots on a portrait phone, with the category buttons still on screen |
| `U_Backpack` › `Body` | The backpack's own 2.25:1 shape | 1.2 times as tall, growing up from the backpack's bottom edge | Six tools to a row would otherwise leave about two rows in view; this shows about two and a half and keeps the backpack well under Roblox's top bar on a phone |
| `Body` › `Top` | `UDim2.new(1, -24, 0.07, 0)` | `UDim2.new(1, -24, 0.11, 0)` | A taller search and favourite row that still fits beside each other |
| `Body` › `ItemsScrollingFrame` | `UDim2.fromScale(1, 0.88)` | `UDim2.fromScale(1, 0.82)` | Starts under the taller top row |

`Body` holds everything the backpack shows, so the backpack's own frame keeps the size BackpackPlus gives it. Desktop, Console and VR keep the built sizes.

## Preview

`Preview.lua` (`UmeGui_Guis_System_BackpackPlus_Preview`) simulates the backpack in the Gui tool, since the gui itself starts with the backpack view hidden and no slots. The settings set where the simulation starts (again whenever one changes): example tools (names, an icon, quantities, favourites, the demo's `Category1` and `Category2`) in the toolbar and the grid, laid out from the toolbar's width as BackpackPlus does, with the previewed device's slot count (ten on Desktop, six on Mobile). Then the gui works as in game:

| Input | What happens |
| --- | --- |
| Click a slot | Equips its tool (grey background), or unequips it; in favourite mode, favourites it instead |
| Right-click a slot | Favourites or unfavourites its tool: the star pops in or out with BackpackPlus's tweens |
| Drag a slot (the backpack open) | Once the press moves a fifth of the slot, the slot follows the mouse. Let go on a toolbar slot to take it (swapping its tool into the backpack, or with the other toolbar slot), over the backpack to put a toolbar tool back; anywhere else it stays |
| Click **Favorite** | Turns favourite mode on (Gold gradient) and off |
| Click a category | Shows only that category's tools (All shows every tool); the selected one turns grey |
| Type in the search | Shows only tools whose name has every word |
| LB / RB (L1 / R1) | Equips the previous or next toolbar tool, wrapping around. On the Console device the bumper hints show only while the toolbar holds a tool, and the unequip hint over the equipped toolbar slot while the backpack is closed |
| D-pad up | Opens the closed backpack; while it is open, selects the category above (from the first, the last) |
| D-pad down | Selects the category below (from the last, the first) |
| D-pad down (backpack closed) | Unequips the equipped tool; its toolbar slot plays a press |
| B (Circle) | Closes the backpack |

The pad works when the Gui tool passes Studio's gamepad input to the preview (the 3D view focused). The bumpers and the D-pad play a press on the slot or category they land on (its click look and sound, `preview.PlayPress`), as ume's BackpackPlus does in game. The preview follows the mouse with a transparent frame over the whole preview (`__MouseTracker`, never exported).

| Setting | What it does |
| --- | --- |
| `S_Open` (Toggle) | Starts with the backpack view open; while it is open the toolbar shows every slot, empty ones with only their key, as in game |
| `S_Toolbar` (Slider, 0 to 10) | How many toolbar slots start with a tool (at most six on Mobile) |
| `S_Items` (Slider, 0 to 40) | How many more tools the backpack's grid starts with |
| `S_Equipped` (Slider, 0 to 10) | Which toolbar slot starts equipped; 0 for none |

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `BackpackPlus`. A game's restyled copy keeps its `Name`, every `U_` and `S_` Id, and the prefab's name `PREFAB | Slot`.
2. ume modules: `Main/2_BackpackPlus` drives it; `Main/0_Console` binds the gamepad and draws the hints; `Roblox/Interact` and `Utils/Utils` press keyed buttons; `Main/Inventory` holds favourites (`Inventory_LockSwitch`); `Utils/Gradient` gives the `Gold` gradient. Turn Roblox's own backpack off (`StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)`; ume's Core_Controller does it).
3. Settings to look at: BackpackPlus `TOOLBAR_SLOTS` (Default 10, Mobile 6), `TOOLBAR_KEY_MAPPINGS`, `FAVORITE_GRADIENT_NAME`; Console `BACKPACK_PREVIOUS`, `BACKPACK_NEXT`, `BACKPACK_OPEN`, `BACKPACK_CLOSE`, `BACKPACK_CATEGORY_PREVIOUS`, `BACKPACK_CATEGORY_NEXT`.
4. Categories: each category is an ImageButton tagged `BackpackPlus_FilterButton` with its `BackpackPlus_FilterCategory` (`""` shows every tool), inside a `U_Category-<name>` frame, its `S_Background` holding the UIGradient the selection recolours. A Tool joins a category with its `BackpackPlus_FilterCategory` attribute (or its `BackpackPlus_DisplayType`).
5. Tools: `BackpackPlus_Quantity` (the `x12`), `BackpackPlus_DisplayType` (a custom viewport), `BackpackPlus_FilterText` (more words the search matches). An inventory item's Tool carries `Inventory_ItemId` / `Inventory_ItemUUID` so it can be favourited.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Open or close the backpack | `` ` `` (Backquote), or the top bar's backpack button | The top bar's backpack button | D-pad up opens (B / Circle closes) | BackpackPlus `Client.lua`; Console `BACKPACK_OPEN`, `BACKPACK_CLOSE`; TopBar_Controller |
| Equip a toolbar tool | `1`–`9`, `0`, or click its slot | Tap its slot | LB / L1 previous, RB / R1 next | `TOOLBAR_KEY_MAPPINGS`; Console `BACKPACK_PREVIOUS`, `BACKPACK_NEXT` |
| Unequip | The equipped slot's key, or click it again | Tap it again | D-pad down while the backpack is closed | Console `BACKPACK_UNEQUIP` (`I.BackpackPlus.Unequip`) |
| Equip a backpack tool | Click its slot | Tap | | `Components/Slot.lua` |
| Move a tool | Drag it between the toolbar and the backpack (backpack open) | Drag | | `Components/Slot.lua`, `I.BackpackPlus.DropSlot` |
| Favourite a tool | Right-click its slot, or **Favorite** then click | **Favorite** then tap | | `Components/Slot.lua`, `BackpackPlus_FavoriteButton` |
| Pick a category | Click its button | Tap | D-pad up / down while the backpack is open | `BackpackPlus_FilterButton`; Console `BACKPACK_CATEGORY_*` |
| Search | Type in `S_SearchBar` | Type | | BackpackPlus `Client.lua` |

### Looks

| State | Element | Value |
| --- | --- | --- |
| A slot at rest, equipped | `S_Background` `BackgroundColor3` | `Color3.fromRGB(0, 0, 0)`, `Color3.fromRGB(50, 50, 50)` |
| A category at rest, selected | Its `S_Background` › `UIGradient` `Color` | Its own, `ColorSequence.new(Color3.fromRGB(60, 60, 60))` |
| Favourite mode off, on | `S_FavoriteButton` › `S_Background` › `UIGradient` | Its own (black at 0.5), the `Gold` gradient (`Color3.fromRGB(255, 183, 0)` to `Color3.fromRGB(252, 231, 0)`) at transparency 0 |
| A favourite's star in, out | `S_FavoriteIcon` | From size 0 and rotation -45 to its built size over 0.45 s, Elastic Out; to size 0 over 0.18 s, Quad In (`FAVORITE_ICON_SHOW_TWEEN`, `FAVORITE_ICON_HIDE_TWEEN`) |
| Corners | The panel's `Background`, the categories (`S_Background`, `Highlight`, `IconContainer`) and the slots' `S_Background` | 8 px at 1080p, as a scale of each one's shorter side: `UDim.new(0.02, 0)` on the panel, `UDim.new(0.1, 0)` on the categories and slots; the search and Favorite pills are fully round |
| Hover, press | Buttons tagged `Utils_ButtonScale` | Scale 1.04, 0.95 |
| A dragged slot | `S_SlotButton` | Follows the pointer once the press moved a fifth of the slot; the slot it came from stays behind |
| Icons | The search pill's `SearchIcon`, the Favorite button's `ButtonIcon` (a white star), the category buttons' `ButtonIcon`s, `S_FavoriteIcon`, the preview's example tool | Made by `<art-tools>/icons/ume-gui-system/backpackplus.mjs`: solid white glyphs for the search and the Favorite button, outlined stickers for the rest; their asset ids are in that folder's README |
| Gamepad hints | The `Console_Hint` ImageLabels | Console only, swapped to the player's pad: `Color` for the bumpers and the D-pad, `ColorThick` for B. The bumpers hide while the toolbar is empty; the unequip hint shows over the equipped toolbar slot while the backpack is closed |
