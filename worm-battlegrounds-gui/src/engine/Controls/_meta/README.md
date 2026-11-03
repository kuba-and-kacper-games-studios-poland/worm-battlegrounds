# Controls

The shared controls the engine builds nodes from, one module each. A control declares its schema (`Children`, `Params`) and a `Build(node, style, ctx)` that returns a handle; it reads every look from its style through `ctx`, so mode changes re-apply. The engine finds a control by name, in the gui's theme's own `Controls/` first, then here.

Params, signals, setters and variants of every control are in the control catalog of `.claude/rules/gui/format.md`; each section below says what the control is, how it is built, what its handle holds beyond `Instance`, and where its style is. Styles are in `src/themes/System/Styles/<Control>.lua` (`Menu.lua` styles the right-click menu `ctx.ContextMenu` opens; it isn't a control).

Built with: **Pressable** is the button structure (`ctx.Pressable`: ButtonContainer › Button › Background + Content › ButtonText); **Surface** is the look split (`ctx.Surface`: root › Background + Content). Both are in `gui/format.md` (Buttons, Surfaces).

## Button

A text button, full width unless `AutoWidth` sizes it to its text. Built with Pressable. Handle: `Button` (the ImageButton), `Clicked`.

## Card

An outlined box with a small caption, a value line and a status on the right; children stack below the value line. Built with Surface (auto height). Handle: `Slot`.

## CheckItem

A list row: a tri-state checkbox, a title and a chevron; the rest of the row expands it to show its children (detail lines). The checkbox fires `CheckClicked` and the script sets the value. Built with Surface, a Pressable row and glyphs; right-click menu through `ctx.ContextMenu`. Handle: `Slot`, `CheckClicked`, `ExpandToggled`, `MenuAction`.

## Chips

A wrapping row of pills, one per option (each a `Button`); the selected one is filled. `Add` puts a + `IconButton` after the last. Handle: `Changed`, `AddClicked`, `ItemAction`.

## ColorPicker

A color field: label, a preview chip, optional swatches, and Hue / Saturation / Brightness bars dragged with `ctx.Capture`; `Inputs` adds RGB and Hex fields. Label from `ctx.FieldTitle`. Handle: `Changed`, `Restore`.

## Dialog

A card with a soft shadow centred over a dimmed backdrop (an ImageButton that blocks the gui): title, optional message and text field, then Cancel and confirm. Children sit under the message. Built with Surface. Build it as a prefab into the gui's root and destroy it once answered. Handle: `Slot`, `Field` (the TextBox, with `Input`), `Confirmed`, `Cancelled`.

## Divider

A full-width line, or a full-height one with `Direction = "Vertical"`. A single Frame.

## DropMarker

The insertion line of a drag and drop: a rounded accent bar fading out toward both ends, outlined in the background color. A Frame with a UICorner and UIGradient; the script places it with `Show`.

## Dropdown

A select box with an optional label; clicking opens a menu of options over the whole gui (`ctx.Overlay`, a ScrollingFrame), below or above the box. Options can carry a right-click menu. Built with Pressable; label from `ctx.FieldTitle`. Handle: `Changed`, `ItemAction`, `Restore`.

## EmptyState

A message centred in the free height of its column over a large faded icon (`ctx.Glyph`), shown in place of an empty list.

## FileRow

One file of a change list: an optional class icon, the name over its path (both wrap), green and red line counts and a status badge. Built with Surface.

## Footer

The bottom area of a window or panel: a top divider, then its children stacked with padding. Built with Surface. Handle: `Slot`.

## Grid

Rows of equal-width columns filled left to right; each cell is as tall as its child. `MinCellWidth` lets the column count follow the width. Handle: `Slot`.

## Header

A page title row with an optional Back button (an `IconButton`), a logo and a divider below; children sit on the right end (or after the title with `Inline`). Handle: `Slot`, `BackClicked`.

## IconButton

A square button showing one glyph: a text glyph, or with `Builder` an icon image from `Tokens.Icons`. `Text` slides a label out while hovered or selected (tab buttons in a header). With the `Wide` variant (buttons stretched by a `Fill` row) the button keeps its size: on hover the glyph slides left and the label fades in beside it. Built with Pressable and `ctx.Glyph`. Handle: `Button`, `Clicked`.

## Input

A one-line text field with an optional label and an icon inside on the left; `Changed` fires when editing ends; `Numeric` only takes numbers. Built with Surface; label from `ctx.FieldTitle`. Handle: `Field` (the TextBox), `Changed`, `Restore`.

## Label

A line of text that wraps to its width; variants pick the role. `Fixed` keeps its token size and grows the box. A single TextLabel.

## ListCard

A list row in an outlined box: a title, a dim subtitle and action buttons on the right. Built with Surface. Handle: `Action`.

## ListBox

A filled, outlined box holding a list, usually of ListItems. Built with Surface (auto height); its Content holds a ScrollingFrame whose height is counted from its visible rows, between one row and `Rows` rows: `AddChild` places each row and refits at once, and removing or hiding a row refits after the change. Past `Rows` it scrolls. Counting instead of measuring keeps it right unparented and in exports; AutomaticSize would ignore a UISizeConstraint. Handle: `Slot` (the ScrollingFrame), `AddChild`.

## ListItem

One row of a pick list in a ListBox: text on the left, the box's fill until hovered, filled while selected. Built with Pressable (ButtonText left-aligned). Handle: `Button`, `Clicked`.

## Panel

A filled area that covers its parent and stacks children: the root of a plugin widget. Built with Surface. Handle: `Slot`.

## Progress

A bar with an optional status line above it; `Set` moves the fill. No input.

## RangeSlider

A labelled slider with two knobs picking a NumberRange; both ends show in text fields. The track is dragged with `ctx.Capture`. Built with Surface; label from `ctx.FieldTitle`. Handle: `Changed`, `Restore`.

## Scroll

A vertically scrolling column that fills the free height of its column. A ScrollingFrame. Handle: `Slot` (the ScrollingFrame).

## Section

A titled group with an optional count. The filled title bar (Pressable) collapses it and separates stacked sections; a chevron glyph shows the state. Right-click menu on the bar. Handle: `Slot`, `Button` (the title bar), `Toggled`, `MenuAction`.

## Segmented

A row of equal-width options with one selected, with an optional label. A Surface box with a CanvasGroup clipping Pressable segments. Handle: `Changed`.

## Slider

A labelled slider with its value in a text field; `Format` and `Step` shape it. The track is dragged with `ctx.Capture`. Built with Surface; label from `ctx.FieldTitle`. Handle: `Changed`, `Restore`.

## Stack

Lays children out in a column or a row; in a row `Fill` shares the width and `Grow` takes what is left. Handle: `Slot`.

## Swatches

A row of color tiles (Pressable) spread across the width; the selected one is ringed. `Colors` is a list or a theme swatch set. Handle: `Changed`.

## Tabs

A tab bar (a `Segmented`) over one page per option; only the selected page shows. `Shared` keeps leading children under the bar on every page. Handle: `Changed`.

## Thumb

A light pressable preview card for long lists: an image or a gradient, a name, an optional heart and a right-click menu; no CanvasGroup or ViewportFrame, so hundreds stay cheap. The style's `Layout` places the parts (Overlay, Caption, Row, Banner). Built with Pressable and glyphs. Handle: `Button`, `Preview` (the frame scripts draw into), `Clicked`, `FavoriteClicked`, `MenuAction`.

## Tile

A clickable preview tile: a ViewportFrame with its own Camera, a caption clipped by a CanvasGroup, and icon actions in the top corners. Built with Pressable. Handle: `Button`, `Viewport`, `Camera`, `Clicked`, `Action`, `MenuAction`.

## Toggle

An Off/On pill switch with an optional label; only the pill is the button. Built with Pressable; label from `ctx.FieldTitle`. Handle: `Button`, `Changed`, `Restore`.

## VectorInput

A labelled row of three number fields holding a Vector3. Label from `ctx.FieldTitle`. Handle: `Changed`, `Restore`.

## Viewport

A 3D preview card filling the free height of its column: a ViewportFrame with its own Camera, a caption and a status message; dragging across it fires `Dragged`. Built with Surface and `ctx.Capture`. Handle: `Viewport`, `Camera`, `Dragged`.

## Window

A floating window: title bar (logo, title, Light / Night switch, minimize, close), a body column for children, and a grip along the bottom. Built with Surface. Handle: `Slot`, `Closed`, `Minimized`.
