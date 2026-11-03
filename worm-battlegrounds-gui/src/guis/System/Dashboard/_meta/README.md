# Dashboard

The AdminPanel module's dashboard: one panel in the CommandBar's look that shows a **panel** per player and per game module. A player's panel holds switches for perks, one-off actions and items to give them; a module's panel is laid out by the module itself, in sections of buttons, switches, sliders, inputs, choices and info lines. Players and modules are the same kind of thing to the dashboard. They are reached from a **rail** of icons down the left edge: search at the top, which opens a page of every player and module as icons on a desktop with a search bar over them, then the viewer's headshot for the players, then a swatch per module (Rail). It sits next to the CommandBar, which stays the quick way to run a typed command. The AdminPanel module opens both from the keyboard: **Ctrl** + **[** the CommandBar, **Ctrl** + **]** the Dashboard.

It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves: a near-black panel (`Color3.fromRGB(14, 14, 16)` at 0.1 transparency) with 12 px corners and a 1 px white border at 0.9, Builder Sans text, and buttons that are white at 0.95 with a white hairline outline at 0.92. The table itself is only the panel's shell (a header and an empty body) and the prefabs: a driver builds everything else from them.

| | |
| --- | --- |
| Path | `"System/Dashboard"` |
| Theme | `System` (nothing in it reads the theme yet) |
| Modes | Night only: its values are its own |
| Preview stage | The whole viewport (scale 1, 1), no shadow, as in game (no `Preview` size: `gui/format.md`) |
| Export | A ScreenGui named `Dashboard` in StarterGui: `Enabled` off, `DisplayOrder` 9990 (under the CommandBar's 9999), `ScreenInsets` `DeviceSafeInsets` |

`init.lua` is about 1,200 lines: it is one gui's table, all data, so it stays whole.

## Elements

`U_Dashboard` is the panel, 760 × 480 px, centred on the screen, 0.75 times as large on Mobile (`Utils_PlatformScale`). Its look is on the panel itself: `BackgroundColor3`, a `UICorner`, a `UIStroke` border with a `UIGradient` inside, and a `UIGradient` of its own, both off. Under it:

| Id | Class | What |
| --- | --- | --- |
| `S_Header` | ImageButton | The top 44 px: a bare transparent button (the panel drags by it) holding `Title` ("Dashboard", Builder Sans SemiBold 15 px, `183, 183, 184`, 16 px in). A `HeaderDivider` hairline (white at 0.92) runs under it |
| `S_CloseButton` | ImageButton | Closes the dashboard: the CommandBar's X (`rbxassetid://99947214964059`), 16 px, at half transparency, centred on the header's line, `Utils_ButtonScale` (1.1 hovered, 0.9 pressed). Centred in `CloseButtonContainer` (ZIndex 2) |
| `S_Body` | Frame | Everything under the header, empty: a driver fills it (Rail) |
| `S_ResizeTop` … `S_ResizeBottomRight` | ImageButton | The CommandBar's eight resize handles, node for node: strips 16 px thick along each edge (10 px outside the panel, 6 inside) and 24 px squares on the corners, in `ResizeHandles` (ZIndex 5), which `Utils_HideOnPlatform` hides on Console, Mobile and VR |
| `EdgeGlow` › `Segment`, `Corner` | Frame | The CommandBar's edge glow (ZIndex 4, `Interactable` off), lit where a press would grab |

## Prefabs

Every pressable prefab's button is `S_Button` (or the Id named below), centred at full size in a bare container that its layout sizes, so its press scale grows from the middle and never moves the layout (`gui/format.md`, Buttons). Each carries `Utils_ButtonScale` (about 1.03 to 1.06 hovered, 0.95 to 0.96 pressed) and `Utils_ButtonSound` (`Button_Click`, `Button_Hover`); list rows sound a click but no hover.

**Body pieces:**

| Prefab | What |
| --- | --- |
| `PREFAB \| ListColumn` | A searchable list: `S_Search` in a `SearchBox` over `S_List` (rows 2 px apart), and `S_Empty` ("Nothing matches") |
| `PREFAB \| PlayerRow` | One player, 46 px: `S_Headshot` (30 px, round), `S_DisplayName`, `S_Username` (a name too long for the row shrinks to fit, since every text is scaled; a 20-letter display name or username can be longer than its 108 px), `S_YouBadge` (on the viewer's row) and `S_SelectedBar` (3 × 20 px, in the accent while picked) |
| `PREFAB \| Divider` | A hairline (white at 0.92), 1 px wide or tall as the driver sizes it |
| `PREFAB \| Content` | Where a panel is shown: a ScrollingFrame padded 16 px, its parts 18 px apart |
| `PREFAB \| Rail` and `PREFAB \| RailButton` | A 56 px column of 40 px icon buttons: `S_Icon` (28 px, with `S_Letter`, Builder Sans ExtraBold 15 px) in `S_Button`, `S_SelectedBar` at the rail's edge while picked |


**Panel pieces** (built by `Panels.lua`):

| Prefab | What |
| --- | --- |
| `PREFAB \| Launcher` | The search page: a 40 px `SearchBox` across the top (the magnifier, then `S_Search`, "Search players and modules", Medium 15 px), over `S_Results` (groups 18 px apart, padded 24 px), and `S_Empty` ("Nothing matches") |
| `PREFAB \| LauncherTile` | One page in the search, like a desktop icon: a 96 × 96 px container with `S_Button` holding `S_Icon` (52 px, 14 px corners, round for a player; with `S_Letter`, ExtraBold 24 px) over `S_Name` (Medium 13 px) |
| `PREFAB \| PanelHeader` | A panel's head: `S_Icon` (56 px; round for a player; with `S_Letter`, Builder Sans ExtraBold 26 px), `S_Name` (Bold 19 px), `S_Description` (Medium 14 px, dimmed) and `S_Stats` (a rich-text line, shown when the panel has stats) |
| `PREFAB \| Section` | One section: `S_Title` (Bold 12 px in capitals, dimmed) over `S_Blocks`, where blocks flow left to right and wrap, 8 px apart |
| `PREFAB \| ActionButton`, `PREFAB \| ToggleButton` | A button (`S_Label` centred) and a switch (`S_Label` and `S_State`, an 8 px dot), 118 × 34 px |
| `PREFAB \| SliderRow` | `S_Label` and `S_Value` over `S_Track` (a bare button holding the `Rail` with `S_Fill`, and `S_Knob`), 44 px |
| `PREFAB \| InputRow` | `S_Label` (0.32 of the row), `S_Field` in a `FieldBox`, and `S_Send` (with `S_SendLabel`, 92 px), 34 px |
| `PREFAB \| ChoiceRow` and `PREFAB \| ChoiceOption` | `S_Label` (0.32 of the row) and `S_Options`, option pills sized to their text that wrap onto more lines in a narrow panel |
| `PREFAB \| InfoRow` | `S_Label` (dimmed) and `S_Value` (right), 22 px |
| `PREFAB \| GiveBlock` and `PREFAB \| ItemTile` | `S_Items` (92 × 86 px tiles, five to a row: `S_Icon` over `S_Name`), then `S_Amount`, `S_Give` (with `S_GiveLabel`, filled with the accent) and `S_GiveHint` |

## Driven by

ume's AdminPanel module (`src/modules_ume/Ume/AdminPanel` in ume) finds it as `I.UserInterface.UI["Dashboard"]` and drives it from `Scripts/Dashboard/Client/Rail.lua` and `Panels.lua`, ports of the two below. **Ctrl** + **]** (`DASHBOARD_KEYS`) opens and closes it for players at the dashboard's level (255).

- **What it builds:** the rail from the server's players and the panels the game's modules register (`I.AdminPanel_Dashboard.Register`).
- **Presses:** each one goes to the server, which checks the player before doing anything.
- **Refreshing:** it builds the page again after each press and when the server says the page changed.

Its `Scripts/Client/Window.lua` drags and resizes it. In the Gui tool, `Preview.lua` drives it.

### Panels

A panel is a plain table: what it shows and how it is laid out. In game, each module that wants one registers its own from `Scripts/AdminPanel/Dashboard/Server.lua` (the AdminPanel README has the shape), and a player's page is made from every module's player sections. `Panels.lua` (inside the gui module, so the Gui tool doesn't list it as a gui) builds one into a `Content` area and holds the shapes:

| Shape | Fields |
| --- | --- |
| `UmeGui_Guis_System_Dashboard_Panel` | `Id` (unique), `Name`, `Description`, `Icon?` (an image), `Color?` (the swatch without one), `Round?` (a round icon, for a player), `Stats?` (a rich-text line under the name), `Sections` |
| `UmeGui_Guis_System_Dashboard_Section` | `Title`, `Blocks` |
| `UmeGui_Guis_System_Dashboard_Block` | `Type`, `Id` (unique in its panel), `Text`, and by type: `Value?` (the starting value), `Min`, `Max`, `Step?` (1), `Format?` (`"×{}"`), `Options`, `Placeholder?`, `Button?` (the Send button's text), `Items`, `Danger?` |
| `UmeGui_Guis_System_Dashboard_Item` | `Name`, `Icon?`, `Color?` |

| Block | Built from | What it does |
| --- | --- | --- |
| `Button` | `ActionButton` | Acts once; `Danger` tints its name red (`255, 110, 110`) |
| `Toggle` | `ToggleButton` | Switches on and off, starting at `Value` |
| `Slider` | `SliderRow` | A number from `Min` to `Max` by `Step`, dragged on its track (a press sets the value under it), shown with as many decimals as the step and in `Format` |
| `Input` | `InputRow` | A field (`Placeholder`) and a button (`Button`, "Send" by default) |
| `Choice` | `ChoiceRow`, a `ChoiceOption` per option | One of `Options`, starting at `Value` (else the first) |
| `Info` | `InfoRow` | Shows `Value`, read-only |
| `Give` | `GiveBlock`, an `ItemTile` per item | Picks one of `Items` and an amount; the hint says what Give gives the panel's player (`Gives 5 × Wooden sword to Nari`), then what it gave |

`Panels.Show(view, content, panel, accent)` builds a panel (after removing the last one), `Panels.Clear()` removes it, `Panels.PaintToggle(button, on, accent)` paints a switch, and `Panels.PaintLetter(icon, name)` writes a name's initial on an icon without an image (`S_Letter`: "E" for Enemies, "W" for World), dark (`14, 14, 16`) on a swatch lighter than 0.6 relative luminance and white on the others. Every switch, slider, choice, field and picked item keeps its value by `<panel id>/<block id>` while the preview runs; a player's panel id is `Player/<username>`, so each player keeps their own perks.

### Rail

`Rail.lua` builds the dashboard's body from the prefabs, after removing the last build, and every press changes what is picked (the players or a module, and which one) and builds it again; the player search filters its rows in place.

| Part | What |
| --- | --- |
| The rail | A `Rail` down the left edge, 56 px wide: the search button (the System theme's magnifier, `rbxassetid://70531937773504`, 20 px in `200, 200, 206`), the viewer's headshot (round) for the players, a short hairline, then a `RailButton` per module with its icon, or its swatch with its initial. The picked one is filled (white at 0.9) with its `S_SelectedBar` in the accent at the rail's edge |
| Search | Opens a `Launcher` across the rest: a `Section` of `LauncherTile`s for the modules, then one for the players. Typing filters both, by name and description or username, and hides a group with nothing left; a tile opens its page. What was typed stays while the dashboard is open |
| The players | Their icon opens a `ListColumn` beside the rail (220 px, "Search players", "Nothing matches" when the search hides every row), with the picked player's panel beside it |
| A module | Its icon shows its panel across the rest of the body |

The shapes it takes are `UmeGui_Guis_System_Dashboard_Context` (the view, the accent, the players with their headshots, the module panels, the state, `GetPlayerPanel(index)` and `Refresh()`) and `UmeGui_Guis_System_Dashboard_State` (`Kind`: `Search`, `Player` or `Module`; `Player`, `Module`, and `Query`, the search page's text).

## Preview

`Preview.lua` drags and resizes the dashboard as the CommandBar's does, through `CommandBar/Window.lua` (down to 600 × 360 px), and builds its rail with the examples in `Examples.lua`: the viewer ("Nari", with the Studio user's headshot when Studio gives one), `builderman` and `Roblox` (with their headshots) and players with none; eight perks, eight actions (Reset data and Kick in red) and ten items, each a swatch; and seven module panels (World, Enemies, NPCs, Economy, Events, Debug, Server), each laid out its own way.

| Setting | What it does |
| --- | --- |
| `S_Players` | How many example players are on the server (1 to 8, default 6) |

Everything but the buttons works in the preview: the rail and the player rows navigate, the search filters, and switches, sliders, choices, fields and Give keep their values. Buttons and Send do nothing beyond their press look. What is picked and every value is kept across rebuilds until the Gui tool reloads the preview.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `Dashboard`, disabled, with every prefab inside it hidden.
2. ume's AdminPanel module drives it (Driven by). It needs `U_Dashboard`, `S_Header`, `S_Body`, `S_CloseButton`, `ResizeHandles` and `EdgeGlow`, and builds the rail and its panels from the prefabs, as `Rail.lua` and `Panels.lua` do, setting `LayoutOrder` on each clone's root and connecting to its button.
3. The accent, which lights what is picked and switched on, is white (the AdminPanel module's `DASHBOARD_ACCENT`; `ACCENT_COLOR` in the Preview).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Move the dashboard | Press the header and drag | Press the header and drag | None yet | AdminPanel `Window.lua`; `CommandBar/Window.lua` in the Preview |
| Resize it | Press an edge or corner and drag (Desktop only) | None: the handles are hidden | None yet | AdminPanel `Window.lua`; `CommandBar/Window.lua` in the Preview |
| Go to search, the players or a module | Click its rail icon | Tap it | None yet | `Rail.lua` (`_select`) |
| Search everything, then open a page | Type in the search page's bar, click a tile | The same, by tapping | None yet | `Rail.lua` (`_launcher`, `_search`) |
| Pick a player | Click their row | Tap it | None yet | `Rail.lua` (`_playerRows`) |
| Find a player | Type in the search box | The same | None yet | `Rail.lua` (`_search`) |
| Use a panel's blocks | Click a button or switch, drag a slider (or click its track), type and click Send, click an option, pick an item and click Give | The same, by tapping and dragging | None yet | `Panels.lua` (`_buildBlock`, `_onSliderMoved`) |
| Open or close | **Ctrl** + **]** (`DASHBOARD_KEYS`), outside any text box | None | None yet | AdminPanel `Client.lua` (`_onKeyPressed`) |
| Close | Click the X | Tap the X | None yet | AdminPanel `Rail.lua` (`Close`) |

### Looks

| State | Element | Look |
| --- | --- | --- |
| Rest, hover, press | Every button (`Utils_ButtonScale`) | About 1.03 to 1.06 hovered and 0.95 to 0.96 pressed (the X 1.1 and 0.9) |
| Picked row or rail icon | `PlayerRow`, `RailButton` | White fill at 0.9, `S_SelectedBar` in the accent; the others no fill, no bar |
| Switch on | A `ToggleButton` | Fill and outline in the accent (0.85 and 0.3), `S_State` in the accent, label `230, 230, 234`; off: white at 0.95, outline white at 0.92, dot `80, 80, 86`, label `200, 200, 206` |
| A slider | `S_Fill`, `S_Knob` | The fill in the accent up to the value, the knob `240, 240, 244` on it |
| Picked option | A `ChoiceOption`'s `S_Button` | Fill in the accent at 0.8, label `230, 230, 234`; the others white at 0.95, label `200, 200, 206` |
| Picked item | An `ItemTile`'s `S_Button` | Fill white at 0.9, outline in the accent at 0.2; the others white at 0.95, outline white at 0.92 |
| Can't be undone | An `ActionButton`'s `S_Label` | `255, 110, 110` instead of `200, 200, 206` |
| The mouse near an edge or corner (Desktop) | `EdgeGlow` › `Segment` or `Corner` | As on the CommandBar (the AdminPanel README, Window) |
