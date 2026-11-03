# Prompt

The default ProximityPrompt every game gets: Roblox's own prompt, built as Roblox's sample in the `ProximityPromptStyle` docs builds it (the same prompt ume's Interact Default style draws). It is made of `Primitive` nodes, plain Roblox instances with Roblox's defaults and only the values Roblox sets, so no theme changes it: a game copies it into its own folders, gives it its own `Name` and changes the values there. It is the `Default` prompt style of ume's Interact module. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/Prompt"` |
| Kind | `Prompt` |
| Modes | Night only: its values are its own, the same in any mode |
| Mappings | `Default`: the input mappings it prefers, Roblox's own textures (ume's `src/global_data/Interact/Mappings`) |
| Devices | Desktop, Console, Mobile: the inputs a prompt shows (a keyboard key, a gamepad button, the touch hand) |
| Export | A BillboardGui named `Default`, the prompt style name (`Interact_Style`), always on top, in `ReplicatedStorage.Ume.Assets.ProximityPrompts`, where ume's prompt styles clone it from (the Gui tool's **Export prompt style**) |

## Elements

`U_Prompt` fills the prompt's BillboardGui. Under it, the `S_` parts a prompt style script drives, named after Roblox's:

| Element | Class | What it is |
| --- | --- | --- |
| `S_Frame` | Frame | The card, centred along the top and as wide as its content (AutomaticSize X): `Color3.new(0.07, 0.07, 0.07)` at 0.2 transparency, default corners |
| `S_ListLayout`, `S_Padding` | UIListLayout, UIPadding | Lays the key square and the texts out in a row; 15 px after the texts with an object name, 24 without, 0 without texts |
| `S_InputFrame` › `S_ResizeableInputFrame` | Frame | The square on the left (as tall as the card); the inner frame grows from its centre while held (`S_InputFrameScaler`, a UIScale) |
| `S_RoundFrame` | Frame | The 48 px circle behind the key, a Frame's default grey at 0.5 transparency |
| `S_ButtonImage` | ImageLabel | The key cap, `key_single.png`, 28 × 30. A style draws a gamepad button (24 × 24) or the touch hand (25 × 31) in it instead |
| `S_ButtonIcon` | ImageLabel | A keyboard key's symbol (Backspace, Shift), 36 × 36 over the key cap in place of `S_ButtonText`; hidden until a key has one |
| `S_ButtonText` | TextLabel | The key (`E`), Gotham Medium 14, white |
| `S_CircularProgressBar` | Frame | The hold ring, 58 px, shown only while a hold is under way (at rest its clear halves would still draw a pixel's edge): two clipped halves of `RadialFill.png` (`S_LeftImage`, `S_RightImage`) turned by `S_LeftGradient` and `S_RightGradient` |
| `S_TextFrame` | Frame | Holds both texts, as wide as the longer one |
| `S_ActionText` | TextLabel | The action, Gotham Medium 19, white, 9 px below the middle (in the middle without an object name) |
| `S_ObjectText` | TextLabel | The object's name, Gotham Medium 14, grey 0.7, 10 px above the middle |
| `S_InteractButton` | ImageButton | Takes clicks and touches on the whole prompt |

## Driven by

ume's Interact module (`src/modules_ume/Roblox/Interact`) draws a prompt tagged `Interact_Prompt` with the style its `Interact_Style` names; each style is a script in `src/global_data/Interact/PromptStyles/` that fills in the texts and key and plays the hold, trigger and release. Planned (ume): a style script that drives this export by its `S_` names, so exported prompts work in game as they are.

## Preview

`Preview.lua` (`UmeGui_Guis_System_Prompt_Preview`) plays Roblox's default prompt in the Gui tool. It fills in the texts and key, sets the action's drop and the space after the texts as Roblox does, and wires `S_InteractButton`, with Roblox's tweens:

- **Press** with a hold: the ring shows and fills over the hold, the key grows to 1.33, the texts fade and slide under it (`S_ListLayout` padding to -0.25), and the card clears.
- **Trigger** (a finished hold, or a press without one): everything fades out.
- **Release**: everything comes back to the gui's own values; the ring hides once it has emptied.

It draws the key from ume's Interact input mappings, read from the place (`ServerScriptService.Instance.GlobalData.Interact.Mappings`) each time the preview loads, as ume's prompt styles do. The Gui tool's **Device** switch picks the input, as a player's device does: Desktop shows the keyboard key on the key cap (its symbol in `S_ButtonIcon`, its mapped text, or the typed key), Console the gamepad button in the **Pad** switch's look (a PlayStation pad uses the mappings' PlayStation image when they have one), Mobile the touch hand. The ring uses the mappings' `RadialFillImage`. In a place without ume's mappings (ume-rbx's), it shows the typed key on the gui's own cap on every device.

| Setting | What it does |
| --- | --- |
| `S_Action` (Input) | The action text |
| `S_Object` (Input) | The object's name; empty centres the action |
| `S_Mappings` (Dropdown) | The input mappings to draw with; starts at the gui's `Mappings` (`Default` when it names none, as ume's Interact does) |
| `S_KeyboardKey` (Dropdown) | The keyboard key on Desktop: **Typed key**, or a key the mappings draw (Backspace, Shift, Quote, F4…) |
| `S_Key` (Input) | The typed key's text on the key cap (12 px for keys longer than two letters) |
| `S_GamepadKey` (Dropdown) | The gamepad button on Console, from the buttons the mappings draw (ButtonX first, as a ProximityPrompt's default) |
| `S_HoldDuration` (Slider, 0 to 5 s) | How long a press must last; 0 triggers at once, without the ring |

## Integration

### Setup

1. Export it with the Gui tool's **Export prompt style**: a BillboardGui named after the prompt style (`Default`) in `ReplicatedStorage.Ume.Assets.ProximityPrompts`. A game's own style is a copy with its own `Name`.
2. ume module: `Roblox/Interact`. A ProximityPrompt gets the look with `Style = Custom`, the tag `Interact_Prompt` and `Interact_Style` set to the style's name (`I.Interact.CreatePrompt` does all three); `Interact_Mappings` picks the input mappings (`src/global_data/Interact/Mappings`). Adding `Interact_ServerPrompt` makes it call a server function.

### Input

| What | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Trigger the prompt | The prompt's `KeyboardKeyCode` (E by default), or click it | Tap it (`S_InteractButton`) | The prompt's `GamepadKeyCode` (ButtonX by default) | Roblox's ProximityPrompt; the style draws the key from the mappings |
| Hold | Keep it down for the prompt's `HoldDuration` | | | |

### Looks

| State | Element | Value |
| --- | --- | --- |
| At rest | `S_Frame` | `Color3.new(0.07, 0.07, 0.07)` at 0.2 transparency |
| Held | `S_CircularProgressBar`, `S_InputFrameScaler`, the texts | The ring fills over the hold, the key grows to 1.33, the texts fade and slide under it, the card clears |
| Triggered | Everything | Fades out |
| Released | Everything | Back to the gui's own values; the ring hides once it has emptied |
