# TopBar

The game's buttons in Roblox's top bar, left and right of Roblox's own. The bar and the button are a gui, UmeGui's `System/TopBar`, exported to StarterGui as the `TopBar` ScreenGui; this module finds it, keeps the bar on the bottom of Roblox's top bar inset, hides it while the Roblox menu is open, and clones a button from its prefab for every `AddButton`. Each button is an object with an icon, a text, a callback and optionally a gamepad key, whose hint shows next to the icon on Console. TopBar_Controller adds the game's buttons; any client module can add its own.

| | |
| --- | --- |
| Folder | `src/modules/Main/TopBar` |
| Runs on | Client |
| Exposes | `I.TopBar` (client) |
| Uses | `I.UserInterface`, `I.Interact` (`OnPress`), `I.Utils` (`ConnectPress`), `I.Console` (`GetIcon`), `I.S.GuiService`, `I.S.TweenService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The `TopBar` gui, the bar's position, showing and hiding it, adding buttons |
| `Components/Button.lua` | One button (`TopBar_Button`): its icon, text, padding, callback, gamepad key and highlight. An internal class, not a tagged component |
| `Settings.lua` | The buttons' padding, icon size and key hint style, the highlight's transparencies and tweens |

## API

### Client: `I.TopBar`

| Function | Returns | What it does |
| --- | --- | --- |
| `Show()` | | Shows the top bar (once the Roblox menu closes, when it is open) |
| `Hide()` | | Hides the top bar |
| `AddButton(side: "Left" \| "Right")` | `TopBar_Button` | Adds a blank button to that side (Left when the side is invalid) and returns it |
| `IsShown()` | `boolean` | Whether the top bar is shown (it still hides while the Roblox menu is open) |

### Button: `TopBar_Button`

| Method | Returns | What it does |
| --- | --- | --- |
| `button:SetLayoutOrder(layoutOrder: number)` | | Sets its order inside its side |
| `button:SetPadding(paddingLeft: number?, paddingRight: number?)` | `UIPadding` | Sets the horizontal padding inside it (`BUTTON_PADDING` on a side left out) |
| `button:RemovePadding()` | | Removes that padding |
| `button:SetText(text: string)` | `TextLabel` | Shows a text; adds the default padding when it had no text yet |
| `button:RemoveText()` | | Hides the text, and removes the padding when no icon is left |
| `button:SetIcon(iconId: string \| number, size: number?)` | `ImageLabel` | Shows a square icon; `size` is the share of the button's height (`ICON_SIZE` by default) |
| `button:RemoveIcon()` | | Hides the icon, and removes the padding when no text is left |
| `button:SetCallback(callback: () -> ())` | `Interact_PressConnection?` | Replaces what it runs when activated (clicked, tapped or picked with a gamepad) or pressed by its key (`I.Interact.OnPress`) |
| `button:RemoveCallback()` | | Disconnects that callback |
| `button:SetGamepadKey(keyCode: Enum.KeyCode)` | `ImageLabel` | Lets that gamepad button press it as a click does (`Utils_ButtonKey`: the highlight fades in while it is held, the callback runs on release) and shows the button's icon (`KEY_HINT_STYLE`) after its icon and text, on Console only (`Console_Hint`, swapped to the player's pad by the Console module). The button is padded while the hint shows |
| `button:RemoveGamepadKey()` | | Takes the key and its hint off |
| `button:Destroy()` | | Removes the button |

## Usage

```lua
local button = I.TopBar.AddButton("Left")
button:SetLayoutOrder(1)
button:SetIcon("rbxassetid://83230059633723")
button:SetCallback(I.BackpackPlus.Toggle)
button:SetGamepadKey(Enum.KeyCode.DPadUp)
```

## Network

No remotes: the top bar is client-only.

## Settings

| Key | Default | What |
| --- | --- | --- |
| **Button** | | |
| `BUTTON_PADDING` | `12` | Pixels on each side of a button's content while it has a text |
| `ICON_SIZE` | `0.6` | Icon size as a share of the button's height |
| `KEY_HINT_STYLE` | `"Color"` | The icon style of a key hint, from the Console module's `GAMEPAD_ICONS` |
| **Highlight** | | |
| `HOVER_TRANSPARENCY`, `PRESS_TRANSPARENCY` | `0.925`, `0.85` | The highlight while a button is hovered, and while it is pressed |
| `PRESS_TWEENINFO`, `RELEASE_TWEENINFO` | `0.075` s, `0.14` s, Linear | Fading the highlight in (hover, press) and back out (leave, release) |

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `TopBar` (ScreenGui) | `StarterGui`, exported from UmeGui's `System/TopBar` with the Ume plugin's Gui tool | Tagged `UserInterface_PreventHiding`, so it shows from the start. The module needs `U_Bar`, `U_Left`, `U_Right` and the hidden `PREFAB \| Button` (with `S_Content`, `S_Padding`, `S_Icon`, `S_Text`, `S_KeyHint`, `S_Highlight`) inside it; ume-gui's `src/guis/System/TopBar/_meta/README.md` describes them |
