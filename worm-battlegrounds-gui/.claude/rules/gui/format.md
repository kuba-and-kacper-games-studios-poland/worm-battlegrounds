---
paths:
  - "src/**"
---

# UmeGui

`ServerStorage.UmeGui` (a ModuleScript) is a table-driven gui framework: every gui is a ModuleScript under `Guis/` that returns **only a table**. The engine builds it from `Controls/`, styled by `Themes/`. The Ume Roblox plugin's Gui tool previews, live-reloads and exports these guis; the plugin draws its own widgets (`Guis/Plugin`) from its own copy. Who owns which folder: `gui/repo.md`. Lua here follows `gui/code.md`.

This file is UmeGui's reference. A game's own gui decisions are game rules (`family/family.md` → Rules) and win where they differ.

The project file (`default.project.json`) builds the one ModuleScript from three folders:

```
src/engine/               -> UmeGui
	init.lua              -- API: Build, Export, ApplyDevice, GetGui, GetPreview, GetDevices, GetGuiNames, GetErrors, GetThemeNames, GetVersion
	Version.model.json    -- UmeGui version (minor bump for API additions)
	_meta/_types.lua      -- UmeGui_* shapes
	Engine/               -- Build (walker + View), Validate, Style, Theme, States, Context, Device
	Primitives.lua        -- raw instances with class defaults; strict property checks
	Controls/<Control>.lua
	Libs/                 -- Runtime (`I` shim), Component, Sound, Mirror/ (generated)
src/themes/               -> UmeGui.Themes
	<Theme>/init.lua + Tokens.lua + Gamepad.lua + Styles/<Control>.lua (+ Controls/<Control>.lua)
src/guis/                 -> UmeGui.Guis
	Plugin/<Gui>.lua      -- the Ume Roblox plugin's widgets (ume-gui's; a game gets them too)
	System/<Gui>.lua      -- the guis ume-gui gives every game, and lookups that are never exported (`gui/repo.md`)
	<Folder>/<Gui>.lua    -- or <Gui>/init.lua + <Gui>/Preview.lua (Gui tool preview settings)
```

---

## Gui module

```lua
--- @type UmeGui_Gui
local _gui = {
	Name = "LightShaft",          -- ScreenGui name on export (default: module name)
	Kind = "Default",             -- what it is drawn on (see Kinds); default "Default", a ScreenGui
	Mappings = "Default",         -- Prompt guis only: the input mappings it draws keys with (see Kinds)
	Theme = "System",             -- default "System"
	Mode = "Night",               -- "Night" | "Light"; the default mode
	Modes = { "Night", "Light" }, -- optional: the modes the gui is designed for (default: only Mode, else Night)
	Root = { Control = "Window", Id = "U_Window", Title = "EasyShaders", Children = { ... } },
	Templates = {                 -- prefabs: built at runtime with view:Build, exported hidden for game scripts
		["PREFAB | EffectRow"] = { Control = "ListCard", Parent = "U_Effects", Text = "Effect", Actions = { "Edit", "Remove" } },
	},
	Preview = { Width = 380, Height = 728 },  -- plugin widgets only: their size in the Gui tool's preview (see below)
	Devices = { "Desktop", "Mobile" },        -- optional: the devices the Gui tool offers (see Devices)
	Screen = { DisplayOrder = 1, Enabled = false },   -- optional: ScreenGui properties on export
	ScreenTags = { UserInterface_PreventHiding = {} }, -- optional: framework tags (with their attributes) on the exported ScreenGui
}
return _gui
```

Every built gui sits in a Folder named `Root` (`view.Root`, since 4.0.0); `view.RootHandle` is its top element's handle. A gui with one top element gives it as `Root` and the engine puts it inside that Folder. A screen of separate elements gives a `Folder` root (`Root = { Primitive = "Folder", Children = { ... } }`), which becomes the `Root` Folder itself. Either way export puts the Folder's elements straight into the ScreenGui, so exported guis hold no Folder. Instances a root control keeps beside itself (`handle.Siblings`, e.g. a widget's `MouseLockFix`) are exported next to it.

### Kinds

`Kind` says what a gui is drawn on in game:

| Kind | Drawn on |
| --- | --- |
| `Default` | A ScreenGui (every gui without `Kind`) |
| `Surface` | A SurfaceGui on a part's face |
| `Billboard` | A BillboardGui over a part |
| `Prompt` | A ProximityPrompt's look: a BillboardGui over the prompt's part, which ume's Interact module draws while the prompt shows. Its `Name` is the prompt style (`Interact_Style`). Build it from `Primitive` nodes whose `Props` hold every value, as `System/Prompt` does (Roblox's default prompt, part for part): nothing in it comes from the theme until you add something that does (a control, a gradient). Copy `System/Prompt` and change its values for a game's own. In game a prompt style script plays it; in the Gui tool its Preview module does. `Mappings` names the input mappings it prefers (a module in ume's `src/global_data/Interact/Mappings`: `Default` is Roblox's own textures, `Enhanced` ume's): the preview starts with them, and another can be picked there to see the prompt with it |

The Gui tool's Kind switch lists a category's guis of one kind. It previews Surface, Billboard and Prompt guis on an invisible part in front of the camera, in a Workspace folder that is never saved and goes with **Clear**; a billboard takes the gui's `Preview` size. **Export** puts Default, Surface and Billboard guis in StarterGui as a ScreenGui, SurfaceGui or BillboardGui, and a Prompt gui in `ReplicatedStorage.Ume.Assets.ProximityPrompts` as a BillboardGui named after its prompt style, replacing the old copy.

`Modes` lists the modes a gui supports; `Mode` must be one of them. The Gui tool shows its Night / Light switch only for a gui that lists more than one, and otherwise previews and exports it in its single mode. Plugin guis list both, since their widgets follow the Studio theme.

`Preview` is only for previewing in the plugin's Gui tool: a gui with it is shown centred at that size (scaled down, keeping its aspect ratio, when the viewport is smaller), with a `UIShadow` under the stage, instead of filling the screen. Only plugin widgets (`Guis/Plugin`) give it, as their widget size. Every other gui drawn on a ScreenGui (System guis and a game's guis) leaves it out, so the Gui tool previews it on a stage of the whole viewport (scale 1, 1) with no shadow, as it shows in game; a gui smaller than the screen sizes and places its own root. A Billboard or Prompt gui uses it as its billboard's size instead. Exports ignore it.

A gui is addressed by its path under `Guis/`: `"Plugin/Sync"`. No functions, no requires, no instances in a gui module — only tables and Roblox values (`Color3`, `UDim2`, …). The Gui tool groups guis by folder: its Category dropdown lists the folder paths (`"Plugin"`; guis directly in `Guis/` are under `Guis`), its Gui dropdown the guis in the selected one.

### Widgets

A gui that ume's WidgetManager opens and closes (a menu, a shop, a dialog: anything shown one at a time, opened from a button, a prompt or the server) is a **widget**. Every widget is built in WidgetManager's shape, as `System/WidgetManager_Message` is:

```
Root            Folder
├ U_Widget      Frame: the box WidgetManager tweens. AnchorPoint 0.5,0.5 · Position 0.5,0.5 · its size, size constraints,
│ │             S_ScreenScale and platform tags. No look of its own (BackgroundTransparency 1)
│ ├ Bg_Bottom   Frame, ZIndex -999: the panel's look (fill, UIStroke, gradients, corner decorations)
│ ├ Bg_Top      Frame, ZIndex 999: the header drawn over the rest (title, icon, close button)
│ └ Content     Frame: everything the widget shows
└ MouseLockFix  ImageButton, Modal: frees the mouse from shift lock while the widget shows
```

- `U_Widget` is the widget's top `U_` element: its `S_` elements are found under it (`view:Get("U_Widget", "S_Close")`), prefabs with no list of their own take `Parent = "U_Widget"`, and inner `U_` elements (a list, a detail pane) sit inside `Content`. Never root a widget at a panel frame of its own (`U_Shop`): WidgetManager finds only `U_Widget`.
- The look lives only in `Bg_Bottom` (and `Bg_Top` for a banner); `U_Widget` and `Content` stay transparent. Never put the widget's elements in `Bg_Bottom`. Leave `Bg_Top` out only when the widget has no header.
- WidgetManager always tweens `Position` to 0.5,0.5 (from 0.5,0.47). A widget meant to sit off-centre moves its `AnchorPoint` instead (AnchorPoint 0.5,0 hangs it below the middle).
- The close button closes through WidgetManager, by a click or B: `Tags = { Interact_Button = { Interact_ModuleName = "WidgetManager", Interact_Function = "CloseCurrent" }, Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" } }`.
- A widget opens only through WidgetManager, never through an `Open` function of the module that fills it. A button that opens one names the widget in its tags: `Tags = { Interact_Button = { Interact_ModuleName = "WidgetManager", Interact_Function = "Toggle", Interact_Arg1 = "Shop" } }` (`Toggle` closes it on a second press; `Open` only opens). Prompts and code call `I.WidgetManager.Open("Shop")`. The module that fills the widget draws it when WidgetManager publishes `WidgetManager_Opened` with its name.
- The exported ScreenGui starts hidden (`Screen = { Enabled = false }`): WidgetManager enables it.
- Guis WidgetManager doesn't open (always-on huds, toasts, a takeover like a rare roll's reveal, prompts, world guis) aren't widgets and keep their own shape.

### Preview module

A gui can describe how the plugin's Gui tool previews it: make it a folder module (`<Gui>/init.lua` returns the gui table) and add a `Preview` ModuleScript next to it. `GetGuiNames` skips modules inside a gui module; `GetPreview(path)` returns it (nil without one). Exports ignore it. It is a script (`gui/code.md` applies), class `UmeGui_Guis_<Folder>_<Gui>_Preview`:

```lua
local Module = {

	--[[ Settings ]]

	-- Nodes drawn in the Gui tool's Preview section (any control; containers may nest). S_ Ids name the values
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Rows", Label = "Rows", Value = 4, Min = 0, Max = 12, Step = 1 },
		{ Control = "Toggle", Id = "S_Empty", Label = "Empty", Value = false },
		{ Control = "Button", Id = "S_Shake", Text = "Shake" },
	},
}

-- After every build of the previewed gui, and after any value setting changes
--- @param preview UmeGui_Preview
function Module.Apply(preview) ... end

-- A button setting (a handle with Clicked) was clicked
--- @param preview UmeGui_Preview
function Module.Action(preview, id: string) ... end
```

- `preview.View` is the previewed gui's view; `preview.Values[id]` the current value of each value setting (starting at its node's `Value`, kept across live reloads of the same gui); `preview.Mode` the preview mode.
- `preview.Fill(templateName, items, parent?)` replaces the clones an earlier `Fill` built of that prefab with new ones: `items` clones (a number) or one per params table. Use it to populate lists.
- In every preview, a `Dropdown` with an Id that ships with no `Options` gets example options (`Entry 1` to `Entry 3`, `PREVIEW_OPTIONS` in the tool's Settings) before `Apply` runs, so its menu opens at a readable size; `Apply` can set real ones.
- `preview.Device` is the device the Gui tool shows and `preview.Pad` its gamepad (`"Xbox"` | `"PlayStation"`).
- `preview.PlayPress(button)` plays a press on one of the view's buttons, its click look and sound (`Utils_ButtonScale`, `Utils_ButtonSound`), for an input the Preview module handles itself (a gamepad cycling a list); it runs nothing the button does. Older Gui tools don't pass it: check it exists before calling.
- Both hooks are optional. Errors show in the Gui tool's status line. Example: `src/guis/Plugin/GuiResize/Preview.lua`.

### Naming

Ids name the elements scripts reach (plugin tools now, game scripts once exported). Everything else has no Id and keeps its control's plain names (`Background`, `Content`, `ButtonText`, …), which are never identifiers.

- **`U_Name`** — unique in the whole gui. Scripts find it first: `gui:FindFirstChild("U_Name", true)`, `view:Get("U_Name")`.
- **`PREFAB | Name`** — a template key. Unique in the gui: the export ships each prefab once, hidden, for scripts to clone. Its root takes no Id (the key names it); runtime clones are named `Name`.
- **`S_Name`** — unique only under its nearest `U_` element or prefab, and only allowed under one. The same `S_` name may appear under any number of other `U_` elements and prefabs. Scripts find the `U_` element (or prefab clone) first, then the `S_` element inside it: `view:Get("U_Footer", "S_Update")`, `row:Get("S_Title")`.
- A `U_` element inside another opens its own `S_` scope. `U_` Ids are not allowed inside prefabs, since every clone would repeat them.
- A node inside a prefab named as a prefab (`Props = { Name = "PREFAB | Slot" }`) is a nested prefab: it opens its own `S_` scope, so scripts clone it and find its `S_` children the same way.
- Give an Id only to elements a script reaches. Group related ones under one `U_` with `S_` children (`U_Header` › `S_Refresh`, `S_BoothOn`) instead of a `U_` each when they belong together.

### Node keys

| Key | Type | Meaning |
| --- | --- | --- |
| `Control` | string | Control to build (catalog below). Exactly one of `Control` / `Primitive`. |
| `Primitive` | string | A raw Roblox class (`"Frame"`, `"UIGradient"`) for anything the catalog lacks. It is a plain Roblox instance: Roblox's own defaults, then its `Props`. UmeGui adds nothing (no transparent background, no scaled text, no theme), so its `Props` hold every value it needs. |
| `Id` | string | `U_Name` or `S_Name` (see Naming; letters, digits, `_`, `-` after the prefix). Becomes the instance `Name`. |
| `Style` | string \| table | A variant (`"Primary"`), several (`{ "Primary", "Small" }`), and/or style overrides (`{ "Primary", Fill = "Accent" }`). |
| `Props` | table | Raw instance properties on the root, applied last. Escape hatch; prefer styles. |
| `Children` | array | Child nodes, only on controls marked *children*. Array order is layout order. |
| `Grow` | number | Flex share: takes the free space in a row/column (ratio between growing siblings). |
| `Visible` | boolean | `false` hides the element. |
| `Tags` | table | Framework component tags with their attributes: `{ Utils_ButtonScale = { Utils_HoverScale = 1.04 } }`. They go on the pressable part when the control has one (`handle.Button`), else on the root, and survive export. An element a framework component drives gets its tag here, never from code. |
| `Attributes` | table | Attributes set on the root: `{ Main_SlideDirection = UDim2.fromScale(-1, 0) }`. |
| `Parent` | string | Template roots only: the `U_` element the exported prefab sits in, and where `view:Build` puts clones when no parent is given. |
| other | — | The control's params. |

Validation runs before every build and lists every problem with its path, e.g. `Root.Children[2].Children[3] (Intensity): unknown param "Valu" (known: …)`. Unknown keys, wrong types, missing required params, unknown controls/variants/style keys, Ids that break the naming rules and template keys that are not `PREFAB | Name` are errors.

---

## Control catalog

`?` = optional. *children* = takes `Children`. Every handle has `Instance`. Value controls have `Changed` (signal), `Get()`, `Set(v)`; **`Set` never fires `Changed`** — only user input does.

| Control | Params | Handle | Variants |
| --- | --- | --- | --- |
| `Window` *children* | `Title?`, `Logo?` (image), `ModeToggle?`, `Minimize?` (default on), `Close?` (default on), `Grip?` (default on) | `Closed`, `Minimized`, `SetTitle`, `SetMinimized` | — (size via `Style = { Width = 330 }`) |
| `Panel` *children* | — | — | `Padded`. Full-size filled root for plugin widgets. |
| `Header` *children* (right side) | `Text`, `Logo?` (image before the title, in its own colors), `Back?` (true or label), `Inline?` (that many leading children sit right after the title) | `BackClicked`, `SetText` | — |
| `Scroll` *children* | — | — | `Tight`, `Flush`, `List` (small inset, almost no gap, for rows), `Inset` (after `List`: sides inset like a `Bar` Stack, so rows line up with a card in a Bar above), `Overlay` (listed last: the scroll bar draws over the content and takes no space, so the content keeps its width when it starts to scroll; every plugin widget's page scroll uses it). Fills the free height of its column. Style keys `Padding` (top and bottom), `PaddingX` (sides) and `ScrollBarInset` (`"ScrollBar"` or `"None"`). |
| `Footer` *children* | — | — | — |
| `Dialog` *children* (under the message, before the buttons) | `Title`, `Text?`, `Input?` (starting text; shows a field, Enter confirms), `Placeholder?`, `ConfirmText?`, `CancelText?`, `Danger?`, `Dismissible?` (default on; off hides Cancel and ignores backdrop clicks) | `Confirmed(text?)`, `Cancelled`, `SetError(text?)`, `Field` | — . Card centred over a dimmed backdrop that blocks the gui; a backdrop click cancels. Use as a prefab built into the gui's top element (`view.RootHandle.Instance`) when needed, destroyed once answered. |
| `EmptyState` | `Text`, `Icon?` (icon name) | `SetText` | — . Message centred in the free height of its column over a large faded icon; show it in place of an empty list's Scroll. |
| `Section` *children* | `Text`, `Count?`, `Collapsible?` (default on), `Collapsed?` | `Toggled`, `SetCollapsed`, `SetText`, `SetCount`, `SetMenu(actions)` + `MenuAction(id)` (right-click menu on the title bar), `Button` (the title bar, e.g. to drag sections) | `Plain` (no fill until hovered, no line, chevron before the title; content lines up with the title). The filled title bar (fading to its bottom line) is the collapse button and the separator between stacked sections; a chevron shows the state. Stack sections in a `Flush` Scroll. |
| `Stack` *children* | `Direction?` (`"Vertical"` \| `"Horizontal"`), `Align?` (`"Start"` \| `"Center"` \| `"End"`), `Fill?` (equal widths in a row) | — | `None`, `Tight`, `Snug`, `Loose` (gap), `Buttons` (rows of buttons), `Bar` (padded like a tab bar, for a toolbar row along a panel edge) |
| `CheckItem` *children* (detail lines, shown while expanded) | `Text`, `Value?` (`"None"` \| `"Partial"` \| `"Checked"`), `Expanded?`, `Disabled?`, `Muted?` | `CheckClicked` (the script decides the value and Sets it), `ExpandToggled(expanded)`, `Get`, `Set(value)`, `SetDisabled`, `SetExpanded`, `SetMuted`, `SetText`, `SetIcon(image?, rectOffset?, rectSize?)` (a Studio class icon before the title), `SetMenu(actions)` + `MenuAction(id)` | `Small` (compact sub-item row). A list row: tri-state checkbox, title, chevron; the rest of the row expands it. |
| `Card` *children* | `Caption?`, `Text?`, `Status?`, `StatusTone?` (palette token) | `SetCaption`, `SetText`, `SetStatus(text, tone?)` | `Subtle`, `Filled` |
| `ListCard` | `Text`, `Subtext?`, `Actions?` (strings) | `Action(name)`, `SetText`, `SetSubtext` | `Subtle` |
| `ListBox` *children* | `Rows?` (most rows shown before it scrolls; the style's `Rows`, 6, by default) | — | — . A filled, outlined box of `ListItem` rows: as tall as its rows, from one up to `Rows` of them, then it keeps that height and scrolls. The height is counted from its visible rows (each `RowHeight` tall), so it is right in exports too. |
| `ListItem` | `Text`, `Selected?`, `Disabled?` | `Clicked`, `Button`, `SetText`, `SetSelected`, `SetDisabled` | — . One row of a pick list in a `ListBox`: left-aligned text, the box's fill until hovered, filled while selected. Scripts select the picked one. |
| `FileRow` | `Text`, `Subtext?` (its path), `Status?` (badge text), `StatusTone?` (palette token), `Added?`, `Removed?` (line counts; 0 hides one) | `SetText`, `SetSubtext`, `SetStatus(text?, tone?)` (nil hides the badge), `SetCounts(added?, removed?)`, `SetIcon(image?, rectOffset?, rectSize?)` (a Studio class icon before the name) | — . One file of a change list: the name over its path (both wrap, never shrink), a green +added and a red −removed line count, then a badge tinted with its tone (Added, Removed). Put many in a `List` Scroll. |
| `Label` | `Text`, `Align?`, `Wrap?` (default on) | `SetText`, `SetTone(token)`, `Get` | `Field`, `Caption`, `Heading`, `Title`, `Strong`, `Small`, `Dim`, `Muted`, `Success`, `Danger`, `Warning`, `Fixed` (never shrinks below its token size; the box grows instead, for long text in a Scroll) |
| `Divider` | `Direction?` (`"Vertical"`: a full-height line between the columns of a row) | — | `Strong` |
| `Button` | `Text`, `AutoWidth?`, `Disabled?`, `Selected?` | `Clicked`, `SetText`, `SetDisabled`, `SetSelected` | `Primary`, `Small`, `Danger`, `Ghost` |
| `IconButton` | `Icon` (text glyph, or an icon name with `Builder`, drawn as its image), `Text?` (label that slides out right of the icon while hovered or selected; view tabs in a header), `Disabled?`, `Selected?` | `Clicked`, `SetIcon`, `SetDisabled`, `SetSelected` | `Ghost`, `Builder`, `Small` (after `Builder`) |
| `Toggle` | `Label?`, `Value?`, `OffText?`, `OnText?` (`""` hides the word) | value: boolean, `SetIcon(image?, rectOffset?, rectSize?)` (an image before the label, e.g. a Studio class icon) | — |
| `Chips` | `Options`, `Value?`, `Add?` (a + button after the last pill) | value: string?, `SetOptions(list)`, `AddClicked`, `SetItemActions({ [option]: { action } })` + `ItemAction(option, actionId)` | — . A wrapping row of small pills; the selected one is filled. |
| `Slider` | `Label?`, `Value`, `Min?` (0), `Max?` (1), `Step?`, `Format?` (`"Percent"` or `"{} studs"`) | value: number; shown in a text field right of the label (typing a number sets it) | — |
| `RangeSlider` | `Label?`, `Value` (NumberRange), `Min?` (0), `Max?` (1), `Step?`, `Format?` (as Slider) | value: NumberRange; both ends shown in text fields right of the label | — . Two knobs; pressing the track drags the nearer one, which never passes the other. |
| `Segmented` | `Label?`, `Options`, `Value?` | value: string, `SetOptions(list)` (keeps the selected option; `Set` another when it is gone) | `Small` |
| `Dropdown` | `Label?`, `Options`, `Value?`, `Placeholder?` | value: string?, `SetOptions(list)`, `SetDisplay(richText?)` (box text other than the option), `SetItemActions({ [option]: { action } })` + `ItemAction(option, actionId)` (right-click menu; an action is a name or `{ Id, Text?, Icon?, Danger? }`) | `Small`. The menu opens below, or above when it does not fit, and keeps `MenuMargin` from the gui's edges. |
| `Input` | `Label?`, `Value?` (string or number), `Placeholder?`, `Numeric?`, `Icon?` (icon name, shown inside on the left, e.g. `magnifying-glass`) | value: string (number when `Numeric`), fires on focus lost, `Field` (the TextBox) | `Small` |
| `VectorInput` | `Label?`, `Value?` (Vector3) | value: Vector3 (three number fields X Y Z) | - |
| `Tabs` *children* (one page per option) | `Options`, `Value?`, `Shared?` (that many leading children sit under the bar on every page) | value: string (selected tab) | — (bar uses Segmented `Small`). Fills the free height of its column. |
| `Grid` *children* | `Columns?` (default 2), `MinCellWidth?` (columns follow the width: as many as fit cells this wide, at least 1) | `SetCells(handles)` (shows exactly these children in this order, moving them from another grid; cells left out are unparented, not destroyed), `SetLayout(columns?, minCellWidth?)` | `Tight`. Rows of column-wide cells; each cell is as tall as its child makes itself. Cells added together are laid out once, at the end of the frame's work. Scripts that keep their cells between refreshes reorder, move and hide them with `SetCells` instead of rebuilding. |
| `Tile` | `Text`, `Subtext?`, `LeftActions?`, `RightActions?` (icon names or `{ Id, Icon }`), `Selected?`, `AspectRatio?` (preview width / height, default 1) | `Clicked`, `Action(id)`, `Viewport` (ViewportFrame) + `Camera`, `SetText`, `SetSubtext`, `SetSelected`, `SetAspectRatio`, `SetMenu(actions)` + `MenuAction(id)` (right-click menu) | — . As tall as its preview's aspect ratio plus the caption. The caption is clipped to the tile's rounded corners (a CanvasGroup inside Content); the preview rounds itself and stays outside it, since a ViewportFrame in a CanvasGroup is not redrawn when a hidden tab shows it again. Corner actions never fire the tile's Clicked. |
| `Thumb` | `Text?`, `Subtext?`, `Image?`, `Favorite?` (true/false adds a heart; nil none), `AspectRatio?` (preview width / height, default 1), `Height?` (fixed preview height in pixels; wins over the ratio), `Selected?` | `Clicked`, `FavoriteClicked`, `Button`, `Preview`, `SetText`, `SetSubtext`, `SetImage`, `SetGradient(color?, transparency?)`, `SetFavorite`, `SetSelected`, `SetAspectRatio`, `SetHeight(height?)`, `SetGlow(transparency)` (the glow behind the image), `SetMenu(actions)` + `MenuAction(id)` | `Caption` (a smaller square image centred over a soft glow, name and subtext centred under it; no outline, the card fills in on hover), `Row` (filled card with no outline: small image over a glow on the left, texts right, one fixed height). `Banner` (scene rows: `Preview` fills the card behind white texts on a dark scrim fading out from the left, one fixed height; scripts draw into `Preview`). The glow (style `Glow`, palette token `Glow`: white in Night, dark in Light) keeps transparent images readable. Default: the name centred along the preview's top, outlined in the preview's colors. A light preview card for long lists (no CanvasGroup or ViewportFrame): put many in a `Grid`. The heart (a small round chip) shows while a favorite or hovered and never fires Clicked. |
| `Viewport` | `Text?`, `Subtext?` (caption under the preview; hidden while both are empty), `Status?` (message centred over the faded preview, e.g. while a model loads) | `Viewport` (ViewportFrame) + `Camera`, `Dragged(delta)` (pointer movement in pixels while dragging across the preview), `SetText`, `SetSubtext`, `SetStatus(text?)` | — . A 3D preview card that fills the free height of its column; scripts put models in `Viewport` and move `Camera` (the control never does). |
| `DropMarker` | `Direction?` (`"Vertical"` \| `"Horizontal"`) | `Show(position, length, direction)` (centre as an offset in its parent), `Hide` | — . The insertion line of a drag and drop: a rounded accent bar that fades out toward both ends, outlined in the background color. Moving between slots glides; showing after `Hide` snaps. |
| `Progress` | `Value?` (0 to 1), `Text?` (status line above the bar) | `Set(value)`, `Get`, `SetText` | — . Shows work a script does; no input, no Changed. |
| `Swatches` | `Colors` (list or theme set name), `Value?` | value: Color3? | — |
| `ColorPicker` | `Label?`, `Value?`, `Swatches?` (list or set name), `Inputs?` (RGB and Hex fields right of the chip) | value: Color3 | — |

Field marks: `Slider`, `RangeSlider`, `Toggle`, `Dropdown`, `Input`, `VectorInput` and `ColorPicker` build their label with `ctx.FieldTitle` and have `SetModified(bool)` (italic label plus a small restore button) and a `Restore` signal, for values changed from a preset or default.

Layout model: containers stack children top to bottom at full width. In a horizontal `Stack`, children size to their content, `Fill = true` shares the width, and `Grow` takes what is left (`{ Control = "Label", Text = "…", Grow = 1 }` pushes later siblings to the right edge).

---

## Buttons

**Never use `TextButton`.** `Primitives.Create` and validation reject it. Everything pressable is an `ImageButton`.

**In controls and plugin widgets** (`Guis/Plugin`) a button is an `ImageButton` with a `TextLabel` inside, always built with this structure, so every widget is built the same way (`ctx.Pressable(size, text?)` creates it):

```
ButtonContainer   Frame        the layout item: size, LayoutOrder, flex. Takes the node's Id as its Name.
└ Button          ImageButton  AnchorPoint 0.5,0.5 · Position 0.5,0.5 · Size 1,1
                               BackgroundTransparency 1 · ImageTransparency 1 · Image ""
  ├ Background    Frame        ZIndex 1, Size 1,1: the visible fill. UICorner, UIStroke, gradients go here.
  └ Content       Frame        ZIndex 2, Size 1,1: everything drawn on top
    └ ButtonText  TextLabel    AnchorPoint 0.5,0.5 · Position 0.5,0.5
```

- Colors and states drive `Background` (`Fill`, `Stroke`) and `ButtonText` (`Text`), never the ImageButton.
- Input (`Activated`, hover, press) and framework tags (`Utils_ButtonScale`, …) go on the ImageButton. Because it is centered in its container, press scaling zooms from the middle and never shifts the layout.
- Padding goes on `Content`. Icons, knobs, chevrons and separators are children of `Content`.
- Never put `AutomaticSize` on a ButtonContainer: the scale-sized Background/Content inflate it. Size a button to its text with `ctx.FitWidth(parts)` (measures ButtonText + Content padding with TextService) after styling it and whenever its text changes.
- Only the part meant to be clicked is the button. A toggle's pill is the button; its label and Off/On words are plain TextLabels that do nothing when clicked.
- Drag surfaces with no look of their own (slider tracks, color bars) are a bare transparent `ImageButton`.
- Handles of pressable controls expose the ImageButton as `handle.Button`; `handle.Instance` is the container.
- Buttons side by side are spaced by the `Spacing.Buttons` token: use `Style = "Buttons"` on a button-row Stack.
- Button texts are one line tall (`ctx.Typography(text, font, size, true)`), centered by their 0.5,0.5 anchor.

**In other guis** (System guis and a game's guis, built from `Primitive` nodes) the structure is optional. Use it, or a split like the System buttons' `Background_Back` / `Background_Front`, only where it helps: a press scale that must not shift the layout, a look kept apart from the hit area, a raised face over an edge. Otherwise build the button the way that suits the gui, as `System/CommandBar`'s icon buttons do (a bare `ImageButton` centred in a container).

---

## Surfaces

In controls and plugin widgets, every container with a look (fill, corners, outline) uses the same split as buttons, built by `ctx.Surface(size, autoHeight?)`:

```
<Id>          Frame   transparent root: the layout item (size, position, anchor, LayoutOrder, flex)
├ Background  Frame   ZIndex 1, Size 1,1: fill, UICorner, UIStroke, gradients
└ Content     Frame   ZIndex 2: list layout, padding, children (the control's Slot)
```

- Background and Content always stay separate frames; never put a layout or children in Background, or a look on Content.
- `autoHeight = true` makes Content grow with its children and the root follow it (cards); otherwise both fill the root.
- Used by `Window`, `Panel`, `Card`, `ListCard`, `Footer` and the `Segmented` box. Pure layout containers with no look (`Stack`, `Scroll`, `Section`, `Header`) stay a single transparent frame; a control that needs another structure (a `ScrollingFrame`, a clipping `CanvasGroup`) puts it inside Content.
- Other guis may keep their look on a single frame (`System/CommandBar`'s panel), or split it only where that helps, as with buttons.

---

## Layout

Every element a gui places is anchored at its centre: `AnchorPoint = Vector2.new(0.5, 0.5)`, at a position from its parent's middle (`UDim2.fromScale(0.5, 0.5)`, or an offset from it: `UDim2.new(0.5, -120, 0.5, 0)`). Only an axis pinned to an edge changes; the other stays 0.5. Elements a `UIListLayout` or `UIGridLayout` places keep the same anchors, so scale, size and press animations grow from the middle and nothing shifts.

| Pinned to | AnchorPoint | Position |
| --- | --- | --- |
| Top | `0.5, 0` | `UDim2.new(0.5, 0, 0, y)` |
| Bottom | `0.5, 1` | `UDim2.new(0.5, 0, 1, -y)` |
| Left | `0, 0.5` | `UDim2.new(0, x, 0.5, 0)` |
| Right | `1, 0.5` | `UDim2.new(1, -x, 0.5, 0)` |
| A corner | both edges' values (`0, 0` top left) | both edges' values |

---

## Text

**Every text is rich and scaled**: every `TextLabel`, `TextBox` and `TextButton`, `Primitive` nodes included, has `RichText` and `TextScaled` on, with its design size in a `UITextSizeConstraint` (`MaxTextSize`), so it shows at that size and only shrinks when its box is too small. Primitives defaults them for controls and rejects text that turns them off; a `Primitive` node sets them in its `Props` (below). ume-gui's own System guis, built before this rule, still have plain text.

- Style text only through `ctx.Typography(instance, font, size, lineHeight?)` or `ctx.Text(…, color)`. They set the font and size tokens and add a `UITextSizeConstraint` whose `MaxTextSize` is the token size, so scaled text renders at the design size and only shrinks when its box is too small. Do not set `FontFace` / `TextSize` directly.
- Boxes are sized by layout as usual (`AutomaticSize` on labels still works and wraps); button texts use `lineHeight = true`.
- A `Primitive` TextLabel, TextBox or TextButton gets nothing from UmeGui: set `RichText`, `TextScaled`, `FontFace`, `TextSize` and colour in its `Props`, and give it a `UITextSizeConstraint` child.
- Give a box room for its design size: one line tall, or every line when it wraps. `AutomaticSize` X still fits one line. A wrapped label whose line count varies gets its height from the code that writes it (`TextService:GetTextSize` at its design size and width), since `AutomaticSize` Y measures in screen pixels under a UIScale (a window's `S_ScreenScale`).
- `TextTruncate` doesn't cut scaled text, it shrinks it: size such a box for its longest text.
- Write `<`, `>` and `&` as `&lt;`, `&gt;` and `&amp;`.
- Text that grows with a press or hover scale: `MaxTextSize` is in screen pixels, so its box is exactly its design size tall and its `MaxTextSize` is 100, Roblox's limit.
- Three weights only, as font tokens: `Hint` = SemiBold (small text: Off/On, slider values, captions, subtitles, letters), `Body` = Bold (labels, field titles, button text), `Title` = ExtraBold (window, header, section and card titles). Styles name the token; a new style key for a smaller text is `<Part>Font = "Hint"`.

---

## Styles and tokens

Looks live only in the theme. **Controls never hold colors, sizes or fonts.**

- `Themes/<Theme>/Tokens.lua` — `Palette.Night` / `Palette.Light` colors, `Swatches` sets, `Font`, `TextSize`, `Icons`, `Radius`, `Size`, `Spacing`, `Stroke`, `Motion`, and optional `Gradients` (named `UmeGui_Gradient`s) and `Images` (named image ids) for a game theme's own controls.
- Icons are images, never a font: `Tokens.Icons` maps each icon name (`"trash-can"`, `"chevron-small-down"`) to a white-on-transparent image that controls tint like text (`ImageColor3` from a palette token). Every `Icon` param, `SetIcon` and menu action icon takes these names; an image id (`rbxassetid://…`) passes through, and an unknown name is a build error. A game theme can replace single icons through its own `Tokens.Icons`. The set is made outside this repo, by ume-gui's icon generator (names follow the Builder Icons names the guis used before).
- System outlines: every UIStroke on a container or button uses `StrokeThickness = "Thick"` (1.5 px) and the `BorderStrong` color (a soft light grey in Night, never pure white); light fills (`Inverse`, selected segments) are the same color so fill and outline read as one piece. `Border` is only for divider lines, disabled outlines and `Subtle` variants; `Thin` (1 px) only for divider lines. Knobs use `Knob` / `KnobStroke` (Night: black knob, light grey ring).
- `Themes/<Theme>/Styles/<Control>.lua` — `{ Default = {...}, <Variant> = {...} }`. Every key a variant or node may set must exist in `Default`.
- **Cascade**: `Default` → each variant in order → the node's style overrides → the node's `Props`.
- **Values**: a string is a token name, looked up in the group the control uses for that key (`Fill = "Surface"` → palette, `Radius = "Control"` → `Tokens.Radius`). Literals (`Color3`, numbers) pass through.
- `States = { Selected = {}, Hover = {}, Pressed = {}, Disabled = {} }` in a style changes keys while a state is on (later wins).
- `Tags = { Utils_ButtonScale = { Utils_HoverScale = 1 } }` adds framework component tags and attributes; they survive export, so guis animate the same in game.
- A button's look and its sounds are separate tags: `Utils_ButtonScale` plays no sound, so a button that clicks and hovers audibly also carries `Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" }`. `Utils_ScaleAnimation` picks ButtonScale's animation (a preset in ume's `Utils/Data/ButtonScalePresets.lua`); `System/_Primitives_ButtonsAnimations` shows every one, and `System/_Primitives_ButtonsColors` the button colors to build guis from.

To restyle every primary button: edit `Styles/Button.lua` → `Primary`. To change one button: `Style = { "Primary", Fill = "Accent" }` on that node. To add a variant: add it to the style file; nodes can use it immediately.

### Game themes

A game restyles everything without touching System: `src/themes/<Game>/init.lua` returns `{ Extends = "System", Tokens = { Palette = { Night = { Inverse = Color3.fromRGB(...) } } } }`, plus an optional `Styles/` folder listing only changed variants. Guis opt in with `Theme = "<Game>"`.

- A theme may ship its own `Controls/` folder. The engine looks a control up in the theme's own folders first (its base's after it), then in the shared `Controls`, so a game builds structures System lacks, or replaces a shared control for its own guis only, without editing `src/engine`. Each has its style in the theme's `Styles/`.
- A theme can stand alone (no `Extends`) when its guis share nothing with System; then it defines every style its guis use.
- `Gamepad.lua` lists the gamepad button icons by pad, icon style and `Enum.KeyCode` name (`Xbox.Color.ButtonA = "rbxassetid://…"`). A theme without one uses its base's. It is generated (`gui/repo.md`).

---

## Devices

Exported guis adapt per platform through framework components, and the Gui tool shows that in Studio:

- `Utils_PlatformSize`, `Utils_PlatformScale` and `Utils_HideOnPlatform` (node `Tags`) read one attribute per device, `Utils_<Device>Size` / `Scale` / `Visibility`. A missing or zero size or scale keeps the built one; an element shows on every device whose visibility isn't `false`.
- `Console_Hint` elements show only on Console (even when built hidden), unless their `Console_HintHidden` attribute is `true`: a module sets it on a hint with nothing to show (BackpackPlus's bumpers over an empty toolbar). Gamepad icons from the theme's `Gamepad.lua` show the picked pad on Console. In game, ume's Console module (`src/modules/Main/0_Console`) does the same: it shows `Console_Hint` elements only on Console and swaps their gamepad icons to the player's pad, from its copy of the System theme's `Gamepad.lua`.
- A button tagged `Utils_ButtonKey` is pressed by its keys (`Utils_GamepadKey`, `Utils_KeyboardKey`: `Enum.KeyCode` names) while it is shown, as a click presses it: it shrinks while held and activates on release. With several shown, the one on the gui with the highest `DisplayOrder` takes the key. In game ume's Interact module binds the keys and runs the button's callbacks (`Interact_Button`, `I.Interact.OnPress`); in the Gui tool the preview passes the pad and keyboard presses Studio gives the plugin to `Libs.PressKey`. A key's `Console_Hint` badge shows the same button.
- Devices are `"Desktop"`, `"Mobile"`, `"Console"`, `"VR"` (the framework's `I.Platform.Current`). A gui's `Devices` lists the ones the Gui tool offers; without it, Desktop plus every device its platform rules treat differently.

---

## Views

Building, reading and recolouring a view (`UmeGui.Build`, `view:Get`, `view:Build`, `SetMode`, `SetToken`, `Destroy`), `Export`, `GetErrors`, `ApplyDevice` and `GetDevices`: the engine's README (`src/engine/_meta/README.md` → API). Exports never change with a device.

---

## Extending

**New control** — in the game's theme: `src/themes/<Game>/Controls/<Name>.lua` plus `Styles/<Name>.lua`. A control every game should have goes to ume-gui instead (`gui/repo.md`):

```lua
--- @class UmeGui_Controls_<Name>
local Module = {

	--[[ Schema ]]

	Children = true,                        -- only if it hosts Children
	Params = { Text = "string", Value = "number?" },  -- "type", "type?", "a|b?"
}

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	-- ctx.Create(class, props), ctx.Color(inst, prop, token), ctx.Text(inst, font, size, color),
	-- ctx.Glyph(iconName, size, color?) for an icon (an ImageLabel) + ctx.Icon(iconName) to swap its Image,
	-- ctx.Corner / Stroke / Padding / List, ctx.Pressable(size, text?) + ctx.FitWidth(parts) for anything clickable, ctx.MeasureText(label) for a one-line width,
	-- ctx.States(targets, style) + ctx.Hover(button, states),
	-- ctx.Animate(inst, goals, instant?) / ctx.Tween for motion, ctx.Build(node, parent) for nested controls, ctx.Capture(onMove) for drags,
	-- ctx.Overlay(onClose) for menus, ctx.ContextMenu(actions, onPick) for a right-click menu at the pointer (styled by `Styles/Menu.lua`, which is not a control), ctx.Connect / ctx.Refresh, ctx.Signal.new()
	return { Instance = root, Slot = contentFrame }
end
```

- Read every visual value from `style`, through `ctx` so mode changes re-apply.
- Input behaviour only when `ctx.Interactive` (exports are not interactive); `ctx.Hover` and `ctx.Tween` already respect it.
- Animate only through `ctx.Animate` / `ctx.Tween` / `ctx.States`, never TweenService directly. Anything set during the build frame (defaults, state a tool restores right after a rebuild) is written at once, and every write cancels a tween still running on that property, so rebuilds and `Set` calls never flicker. Animations start once the scope has settled (one frame after it was built).
- Do not show state with `Rotation` (chevrons): it is not drawn inside a clipping `ScrollingFrame`, where most rows sit. Swap the glyph instead (`chevron-small-right` / `chevron-small-down`).
- Return `Slot` (where children go) or `AddChild(child, node)` when children need placement logic.
- Describe the control: in the theme's `_meta/README.md` for a game's own control, in the catalog above for a shared one.

**Primitives** — `Primitives.lua` holds the per-class defaults controls start from (`ctx.Create`); a gui's `Primitive` nodes get none (`CreatePlain`). Unknown or read-only properties and wrong types error with the node path; do not swallow them.

---

## Libs

- Mirrored files (`Libs/Mirror/`, generated: `gui/repo.md`) require `Libs.Runtime` (the `I` shim) instead of `UmePointer`, and their `@class` / `@alias` names become `UmeGui_<name>` so they never collide with the game's types. The other Libs (components, sounds and key presses in previews): the engine's README → Libs.

## Host API

The Ume plugin works on the place's UmeGui through seven functions: `Build`, `Export`, `GetGuiNames`, `GetGui`, `GetPreview`, `GetDevices` and `ApplyDevice`. They are the engine's contract with the plugin, changed only in ume-gui.
