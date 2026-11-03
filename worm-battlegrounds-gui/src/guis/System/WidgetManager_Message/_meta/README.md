# WidgetManager_Message

The message dialog of ume's WidgetManager: the confirmation dialog's card (a blue title banner with an icon, `Hey!` and a red close button) with a message and one green `OK!` button. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves, so no theme changes it. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/WidgetManager_Message"` |
| Modes | Night only |
| Devices | Desktop, Mobile and Console: on Mobile the card is 10% bigger, 88% of the screen's width and 44% of its height at most (`Utils_PlatformSize`); on Console the close button's X hides (`Utils_HideOnPlatform`) and the gamepad hints show (`Console_Hint`) |
| Export | A ScreenGui named `WidgetManager_Message` in StarterGui: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Widget` and a `MouseLockFix` (a modal ImageButton that frees the mouse from shift lock while it shows) go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame | The card, 80% of the screen's width and 40% of its height at most (88% and 44% on Mobile), 1.75 times as wide as tall; WidgetManager tweens it in and out. Its close button (`CloseButton`) is tagged `Interact_Button` to call `WidgetManager.CloseCurrent`; on Console its X text hides |
| `U_Widget` › `S_CloseHint` | ImageLabel | B (Circle) in the close button's X place, on its red background, on Console only: the B's white border (`WhiteBorder`) tinted black by its `UIGradient`, like the X's UIStroke, with the white B (`White`) in front as `Front`; B closes the widget |
| `U_Widget` › `S_MessageText` | TextLabel | The message, Source Sans Heavy up to 48 px, outlined |
| `U_Widget` › `S_AcceptButton` | ImageButton | `OK!`: closes the message and shows the next one |
| `U_Widget` › `S_AcceptHint` | ImageLabel | An A (Cross) badge on the OK button's top right corner, on Console only; A presses it |

## Console

The gamepad hints are ImageLabels tagged `Console_Hint` and built hidden, with the System theme's Xbox icons: `WhiteBorder` and `White` for the close button's B, `ColorThick` (Color with a heavier light rim) for the key badges. The buttons carry their keys (`Utils_ButtonKey`): B (Circle) on the close button, A (Cross) on OK. In game ume's Interact module binds them, so a key presses its button as a click does, and ume's Console module (`src/modules/Main/0_Console`) shows the hints on Console and swaps them to the player's pad. The close button keeps its red background; only its X text hides (`Utils_HideOnPlatform`, `Utils_ConsoleVisibility` false) and the B shows in its place. The key badges sit on their buttons' top right corners, 70% of the button's height. In the Gui tool, the Device switch's Console shows them, its Pad switch shows the PlayStation icons, and pressing a pad or keyboard key presses the button that carries it.

## Driven by

ume's WidgetManager (`src/modules/Main/WidgetManager/Scripts/MessageWidget.lua`) finds this gui as `I.UserInterface.UI["WidgetManager_Message"]` and the `S_` elements above, for `I.WidgetManager.ShowMessage`; it wires OK with `I.Interact.OnPress`, so its key dismisses it as a click does. `Client.lua` opens it like any widget, through its `U_Widget`.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `WidgetManager_Message`, disabled. A restyled copy keeps its `Name`, `U_Widget`, the close button (`CloseButton`, tagged `Interact_Button` with `Interact_Function` `CloseCurrent` and `Interact_ModuleName` `WidgetManager`), every `S_` Id and the buttons' `Utils_ButtonKey` tags.
2. ume modules: `Main/WidgetManager` opens it (`I.WidgetManager.ShowMessage(message)`) and answers its buttons through `I.Interact.OnPress`; `Roblox/Interact` and `Utils/Utils` press the keyed buttons; `Main/0_Console` shows the gamepad hints. WidgetManager's settings set the blur, dim and field of view while it is open.

### Input

| What | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| OK | Click **OK** | Tap | A / Cross | `Utils_ButtonKey` on `S_AcceptButton` |
| Close | Click the X | Tap | B / Circle | `Utils_ButtonKey` and `Interact_Button` on `CloseButton` |

No keyboard keys yet; a keyboard key is the same tag's `Utils_KeyboardKey`.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Opening | `U_Widget` | WidgetManager tweens its position in, blurs and dims the background and widens the field of view |
| Corners | The panel (`Bg_Bottom` › `Background` and its `EffectGroup`) | Rounded 8 px at 1080p, `UDim.new(0.02, 0)` of its shorter side, so it keeps that look at every size; the banner covers the top two, so only the bottom corners show. Its outline and highlight strokes keep the default round joins so they follow the curve; the banner and buttons stay square, with mitred strokes |
| Hover, press | The buttons (`Utils_ButtonScale`) | Scale 1.04, 0.95; a key press shrinks them the same way |
| The OK button | `S_AcceptButton` fills | `UIGradient` `Color3.fromRGB(50, 195, 24)` to `Color3.fromRGB(154, 255, 23)`, rotation -90 |
| The close button | `CloseButton` fill | `UIGradient` `Color3.fromRGB(226, 0, 0)` to `Color3.fromRGB(255, 100, 48)`, rotation -90 |
| The title bar | `Bg_Top` | `UIGradient` `Color3.fromRGB(0, 55, 255)` to `Color3.fromRGB(0, 200, 255)`, rotation -90 |
| Gamepad hints | `S_CloseHint`, `S_AcceptHint` | Console only, swapped to the player's pad: the close button's X becomes a white B over its black border; the badges are `ColorThick` |
