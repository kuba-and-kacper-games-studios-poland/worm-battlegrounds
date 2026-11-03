# CommandBar

The console for ume's AdminPanel module (its command bar): one panel above the bottom of the screen, with the scrolling output, a dimmed close X in its top right corner, and the input line under a hairline with a dimmed execute arrow at its right end; the autocomplete list rises from the input. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves: a near-black panel (`Color3.fromRGB(14, 14, 16)` at 0.1 transparency) with 12 px corners and a 1 px white border at 0.9, Roboto Mono text with no outlines, and the bold white X and > icons. It adds a header along the top that drags the console (kept on screen), resize handles on every edge and corner (Desktop only), and a `UIGradient` on the panel and one on its border, both off.

A game's own copy keeps its `Name`, every Id and the three prefab names, which the AdminPanel module finds.

| | |
| --- | --- |
| Path | `"System/CommandBar"` |
| Theme | `System` (nothing in it reads the theme yet) |
| Modes | Night only: its values are its own, the same in any mode |
| Devices | Desktop and Mobile (1.5 times larger on Mobile, `Utils_PlatformScale`) |
| Export | A ScreenGui named `CommandBar` in StarterGui: `Enabled` off, `DisplayOrder` 9999, `ScreenInsets` `DeviceSafeInsets`, with a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) |

## Elements

`U_CommandBar` is the console panel, half the screen wide and three times as wide as tall, centred 15% above the bottom edge. Its look is on the panel itself: `BackgroundColor3`, a `UICorner`, a `UIStroke` border with a `UIGradient` inside, and a `UIGradient` of its own. The layout is fixed in pixels at the top and bottom, so a resize only changes how much output shows: the header takes the top 40 px, with a `HeaderDivider` hairline under it; `Bottom` holds the input in the bottom 54 px (its 26 px line centred 27 px above the bottom edge), under a `Divider` hairline 54 px up, drawn over the output (ZIndex 2) so the suggestions rising from it are too; and the output fills what is between (14 px in from the left, 8 px under the header's hairline, 6 px above the input's). Under `U_CommandBar`:

| Element | Class | What game code does with it |
| --- | --- | --- |
| `S_Header` | ImageButton | The drag handle: a bare transparent button over the top 40 px, under the close button, holding `Title` ("Commands", Builder Sans SemiBold 15 px in an opaque grey, `183, 183, 184` (as bright as white at 0.3 over the panel), 14 px in from the left, on the close button's line). Pressing and moving it drags the console |
| `S_CloseButton` | ImageButton | Closes the command bar: the X icon (`rbxassetid://99947214964059`), 16 px, at half transparency in the top right corner, centred on the header's line, `Utils_ButtonScale` (1.1 hovered, 0.9 pressed). Centred in `CloseButtonContainer` (ZIndex 2, over the header), which places it |
| `S_ResizeTop`, `S_ResizeBottom`, `S_ResizeLeft`, `S_ResizeRight` | ImageButton | Resize handles: bare transparent strips 16 px thick along each edge, 10 px of them outside the panel and 6 inside, and stopping where the corner squares start |
| `S_ResizeTopLeft`, `S_ResizeTopRight`, `S_ResizeBottomLeft`, `S_ResizeBottomRight` | ImageButton | Resize handles: 24 px squares on the corners, 10 px outside the panel each way and 14 inside. All eight sit in `ResizeHandles` (ZIndex 5, over everything), centred on the panel and 10 px bigger on every side, so a press just outside an edge grabs it too; `Utils_HideOnPlatform` hides it on Console, Mobile and VR |
| `EdgeGlow` › `Segment` | Frame | The glow on an edge (ZIndex 4, `Interactable` off): a white bar with round ends (60 × 1.5 px in the table; the driver gives it the border's thickness and fits it to the edge), its `UIGradient` fading its outer 30% at each end. Starts at transparency 1 (hidden) |
| `EdgeGlow` › `Corner` | Frame | The glow on a corner: a ring as round as the panel's corners (24 px, 12 px `UICorner`) with a white `UIStroke` (1.5 px in the table; the driver gives it the border's thickness), whose `UIGradient` lights only the quarter that lies on the corner (opaque to 0.19, gone by 0.27 of its diagonal). Starts at transparency 1 |
| `S_OutputScrollingFrame` | ScrollingFrame | The output, with a thin faint scroll bar; Command clones `PREFAB \| OutputFrame` into it |
| `S_InputBox` | TextBox | Takes the typing; its own text is clear |
| `S_DisplayBox` | TextBox | Shows the typed command with its colors, errors and the autocomplete ghost |
| `S_SelectionBox` | TextBox | Draws the selected part of the text |
| `S_CursorPosBox`, `S_SuggestionPosBox` | TextBox | Clear boxes Command only measures, to place the caret and the suggestions |
| `S_Cursor` | Frame | The blinking caret, a white underscore 10 × 2 px |
| `S_SuggestionsContainer` | Frame | The autocomplete list, its bottom 14 px above the input line; Command clones `PREFAB \| SuggestionText` and `PREFAB \| SuggestionSeparator` into it |
| `S_SuggestionsContainerBackground` | Frame | The card behind the list (`Color3.fromRGB(24, 24, 28)`, 8 px corners); Command sizes and moves it with the list |
| `S_ExecuteButton` | ImageButton | Runs the typed command: the > icon (`rbxassetid://99734108657425`), 18 px, at 0.4 transparency at the input's right end, `Utils_ButtonScale`. Centred in `ExecuteButtonContainer` |

The text boxes sit in `Bottom` › `InputContainer`, one 26 px line 14 px in from the left, in a clipping Frame, `TextBoxesContainer`; all five use Roboto Mono Medium 17 px.

## Prefabs

Each sits hidden in the ScreenGui; Command finds them by name and clones them. They are System/CommandBar's.

| Prefab | What it is |
| --- | --- |
| `PREFAB \| OutputFrame` | One output line, as wide as the output and as tall as its wrapped text: `OutputText`, Roboto Mono 16 px, `Color3.fromRGB(225, 225, 230)` |
| `PREFAB \| SuggestionText` | One autocomplete entry, Roboto Mono Medium 16 px, 10 px in from each side |
| `PREFAB \| SuggestionSeparator` | A 1 px white hairline at 0.9 transparency between suggestions of different kinds |

## Driven by

ume's AdminPanel module (`src/modules_ume/Ume/AdminPanel` in ume) finds this gui as `I.UserInterface.UI["CommandBar"]` (`Scripts/CommandBar/Client/Bootstrap.lua`), then `U_CommandBar` and every `S_` element and prefab inside it by recursive name lookups. Its `Scripts/Client/Window.lua`, a port of this gui's `Window.lua`, drags the console by `S_Header` and resizes it by the handles in play. **Ctrl** + **[** (`COMMAND_BAR_KEYS`) or `/cmd` in chat opens it, for players at `OPEN_PERMISSION_LEVEL` (1, a member of the admin group) or above, and the same keys close it. Dashboard results are written into its output too.

## Preview

`Preview.lua`'s `S_Outputs` (0 to 18, default 6) fills the output with that many `PREFAB | OutputFrame` lines, written as the AdminPanel module prints them (`Scripts/CommandBar/Client/Control.lua`, `PrintToOutput`): a timestamp at 0.5 transparency, then the command's alias in `OutputCommand` green (`rgb(65,225,65)`), or `OutputError` red (`rgb(255,50,50)`) for a failed one, and `>>` before the result. The first line is a dimmed hint on its own, the rest cycle through `OUTPUTS` (help, give, grow, a failed tp, speed), their timestamps counting up from 14:02:07 by about 5.5 s. The output scrolls to the newest line. The empty autocomplete box (`S_SuggestionsContainer` and its background) is hidden, as the module keeps it until something is typed, so it covers no line.

It also drags and resizes the console as the game should, through `Window.lua`, a module inside this gui that the Dashboard's Preview uses too (`Window.Bind(console, MIN_SIZE)`, with `MIN_SIZE` 360 × 150 px): the header drags it, the edge and corner handles resize it on Desktop, and the edge glow shows where a press grabs. The AdminPanel module's README (Windows) has how. The console starts with a `UIAspectRatioConstraint` (3:1), which the first resize removes, so it then takes the size the pointer gives it.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `CommandBar`, disabled. If System/CommandBar was exported before, this one replaces it. A restyled copy keeps its `Name`, `U_CommandBar`, every `S_` Id and the three prefab names.
2. ume module: `Ume/AdminPanel` (`Scripts/CommandBar/Client/Bootstrap.lua` finds it, `Connections.lua` wires the input, `Scripts/Client/Window.lua` drags and resizes it). Its settings: `TOGGLE_COMMAND` (`/cmd` in chat), `OPEN_PERMISSION_LEVEL` (1), `COMMAND_BAR_MIN_SIZE`, `COLORS`, `ARGS_COLORS`, `SELECTION_TEXT_COLOR`, `SELECTION_BACKGROUND_COLOR`, `SUGGESTIONS_LIMIT`.

### Input

| What | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open or close | **Ctrl** + **[** (`COMMAND_BAR_KEYS`, also while typing in it), or `/cmd` in chat; the X closes | `/cmd` in chat; tap the X | | AdminPanel `Client.lua` (`_onKeyPressed`), `Scripts/CommandBar/Server/ChatCommand.lua` (`/cmd`, made on the server so the message stays out of chat), `Connections.lua` |
| Type a command | `/` focuses the input while it is open | Tap the input | | |
| Run it | Enter, or click the > | Tap the > | | |
| Move the console | Press the header and drag | Press the header and drag | None | AdminPanel `Window.lua`; this gui's `Window.lua` in the Preview |
| Resize it | Press an edge or corner and drag (Desktop only) | None: the handles are hidden | None | AdminPanel `Window.lua`; this gui's `Window.lua` in the Preview |
| Autocomplete | Tab takes the selected suggestion; Up and Down move through the suggestions | | | |
| History | Up and Down, with no suggestions shown | | | |

### Looks

| State | Element | Value |
| --- | --- | --- |
| The panel (System) | `U_CommandBar` | `Color3.fromRGB(14, 14, 16)` at 0.1 transparency, 12 px corners, a 1 px white border at 0.9; its two gradients off |
| The X and the > at rest | `S_CloseButton`, `S_ExecuteButton` | Image transparency 0.5 and 0.4; white |
| Hover, press | `S_CloseButton`, `S_ExecuteButton` (`Utils_ButtonScale`) | Scale 1.1, 0.9 |
| Selected text | `S_SelectionBox` | Text `rgb(0, 0, 0)` on `rgb(193, 196, 255)` (`SELECTION_TEXT_COLOR`, `SELECTION_BACKGROUND_COLOR`) |
| Typed command | `S_DisplayBox` | Rich text in Command's `COLORS` and `ARGS_COLORS` |
| The caret | `S_Cursor` | A white 10 × 2 px underscore that blinks |
| An output line | `PREFAB \| OutputFrame` › `OutputText` | `Color3.fromRGB(225, 225, 230)`, Roboto Mono 16 |
| The mouse near an edge (Desktop) | `EdgeGlow` › `Segment` | A white bar up to 60 px long under the cursor, as thick as the border and over it, fully opaque, its ends fading; fades in and out over 0.1 s `Quad` `Out` |
| The mouse near a corner (Desktop) | `EdgeGlow` › `Corner` | A white arc on the corner's curve, as thick as the border, fully opaque; fades the same |
