# TopBar

The bar of game buttons every game gets in Roblox's top bar, next to Roblox's own buttons: round dark buttons on the left and the right, each with an icon, a text or both. The gui is the bar and one button prefab; ume's TopBar module clones the buttons into it at runtime and keeps the bar lined up with Roblox's top bar. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves, so no theme changes it. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/TopBar"` |
| Kind | `Default` |
| Modes | Night only: its values are its own, the same in any mode |
| Devices | Desktop, Console: on Console a button with a gamepad key shows it after its icon (`S_KeyHint`) |
| Export | A ScreenGui named `TopBar` in StarterGui (the Gui tool's **Export to StarterGui**): `ScreenInsets` `TopbarSafeInsets`, `SafeAreaCompatibility` `FullscreenExtension`, `ClipToDeviceSafeArea` on, `DisplayOrder` 1000000, tagged `UserInterface_PreventHiding` so it shows from the start |

To restyle it in a game, copy it into the game's own folders and change the values there, keeping its `Name` (`TopBar`), its Ids and the prefab's name: the TopBar module finds them by those names. Export the copy instead of this one.

## Elements

| Element | Class | What it is |
| --- | --- | --- |
| `U_Bar` | Frame | The bar: full width, 48 px tall, 8 px in from the left and 16 px from the right. Built 10 px down (the bottom of a 58 px top bar); the TopBar module moves it to `GuiService.TopbarInset.Height` minus its height |
| `U_Left` | Frame | The left half: buttons from the left edge, 8 px apart, in `LayoutOrder` |
| `U_Right` | Frame | The right half: buttons from the right edge, 8 px apart, in `LayoutOrder` |

## Prefabs

### `PREFAB | Button`

In `U_Left`. An ImageButton 44 × 44 px that grows wider with its content (AutomaticSize X), tagged `Utils_ButtonSound` (`Button_Click`, `Button_Hover`). Its round `Background` is `Color3.fromRGB(18, 18, 20)` at 0.08 transparency.

| Element | Class | What it is |
| --- | --- | --- |
| `S_Content` | Frame | Lays the icon and the text out side by side, centred, 6 px apart |
| `S_Padding` | UIPadding | Inside `S_Content`: none until the button has a text, then 12 px each side |
| `S_Icon` | ImageLabel | The square icon, 0.6 of the button's height; hidden until the button has one |
| `S_Text` | TextLabel | The text, Builder Sans ExtraBold 18, white; hidden until the button has one |
| `S_KeyHint` | ImageLabel | The gamepad key that presses the button, square like `S_Icon` and after the text; hidden until the button has a key, and then shown on Console only |
| `S_Highlight` | Frame | A white circle 4 px inside the edge, over the content, clear at rest; the TopBar module fades it in while the button is hovered or pressed |

## Driven by

ume's TopBar module (`src/modules/Main/TopBar`) finds this gui as `I.UserInterface.UI["TopBar"]`, moves `U_Bar` to the bottom of Roblox's top bar inset, hides the gui while the Roblox menu is open, and clones `PREFAB | Button` into `U_Left` or `U_Right` for every `I.TopBar.AddButton`. A button's `SetGamepadKey` tags it `Utils_ButtonKey` and gives `S_KeyHint` the key's icon and the `Console_Hint` tag, so the Console module shows it on Console. ume's TopBar_Controller adds the game's buttons through it: the backpack button carries D-pad up.

## Preview

`Preview.lua` (`UmeGui_Guis_System_TopBar_Preview`) fills the bar in the Gui tool with example buttons, as the TopBar module adds them, and fades their highlight in on hover and press with the module's values (the gui itself is static: in game the module does this). The first button carries D-pad up like the backpack button: its hint shows on the Console device, and pressing D-pad up presses it (its click sound). Clicking a button runs nothing in the preview.

| Setting | What it does |
| --- | --- |
| `S_Left` (Slider, 0 to 4) | How many example buttons the left side shows, each with an icon |
| `S_Right` (Slider, 0 to 4) | How many the right side shows |
| `S_Text` (Input) | The text the right side's buttons carry next to their icon, padded 12 px each side; empty leaves only icons |

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `TopBar`, tagged `UserInterface_PreventHiding`. A restyled copy keeps its `Name`, `U_Bar`, `U_Left`, `U_Right`, the prefab's name and its `S_` Ids.
2. ume modules: `Main/TopBar` (the bar and its buttons, `I.TopBar.AddButton`), `Main_Controllers/TopBar_Controller` (the game's buttons). A button's gamepad key needs `Roblox/Interact` and `Utils/Utils` (the key press) and `Main/0_Console` (its hint's icon). Settings: TopBar `BUTTON_PADDING`, `ICON_SIZE`, `KEY_HINT_STYLE`, `HOVER_TRANSPARENCY`, `PRESS_TRANSPARENCY`.

### Input

| What | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Press a button | Click it | Tap it | Its key (`button:SetGamepadKey`): D-pad up on the backpack button | TopBar `Components/Button.lua` (`I.Interact.OnPress`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| A button | `Background` | A circle, `Color3.fromRGB(18, 18, 20)` at 0.08 transparency; a pill once a text or a key hint widens it |
| Hover, press | `S_Highlight` | Transparency 0.925, 0.85, fading in over 0.075 s and out over 0.14 s (Linear); a key press fades it the same way |
| A key hint | `S_KeyHint` | The key's icon in the Console module's `Color` style, after the icon and text, on Console only; the button is padded 12 px while it shows |
