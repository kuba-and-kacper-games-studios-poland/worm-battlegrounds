# Interact

No-code interactions placed in the world. Tag a part, a button or a ProximityPrompt and set attributes naming a module and a function: touching the part, clicking the button or triggering the prompt calls `I[Interact_ModuleName][Interact_Function](...)` with the attributes' arguments. ProximityPrompts get a custom look from a named prompt style, with the key images of a named set of input mappings. On the client it also presses gui buttons from the keyboard and gamepad: it binds the keys that buttons tagged `Utils_ButtonKey` name, and a key press runs the button's callbacks as a click does (`OnPress`, and `Interact_Button`'s function).

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Interact` |
| Runs on | Server, Client, Global |
| Exposes | `I.Interact` (both; `OnPress` client only) |
| Uses | `I.Component`, `I.Debounce`, `I.Player`, `I.Utils` (`PressKey`), `src/global_data/Interact/PromptStyles`, `src/global_data/Interact/Mappings` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Registers `Interact_ServerArea`, `Interact_ServerPrompt` |
| `Client.lua` | Registers `Interact_ClientArea`, `Interact_Button`, `Interact_Prompt`; adds `OnPress` to `I.Interact` |
| `Global.lua` | `CreatePrompt`, and the input mappings prompt styles draw keys with (`GetMappings`, `GetGamepadImage`) |
| `Components/Area.lua` | Both area tags: a part that calls a function when touched |
| `Components/ServerPrompt.lua` | A ProximityPrompt that calls a server function when triggered |
| `Components/Button.lua` | A gui button that calls a function when clicked, or pressed by its key |
| `Scripts/Client/Press.lua` | `OnPress`, and the key binds: every key a `Utils_ButtonKey` button names, bound once at high priority, presses that button through `I.Utils.PressKey` and runs its `OnPress` callbacks when the release activates it |
| `Components/Prompt.lua` | Draws a ProximityPrompt with its style while it's shown |
| `Scripts/Helpers/Args.lua` | Reads the `Interact_Arg*` attributes and inserts the player for `Interact_PassPlayer` (areas and server prompts) |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `interact` command |
| `_meta/_types.lua` | `Interact_PromptStyle`, `Interact_Mapping`, `Interact_PressConnection` |

## API

### Global: `I.Interact`

| Function | Returns | What it does |
| --- | --- | --- |
| `CreatePrompt(style: string, mappings: string?, activationDistance: number?, actionText: string?, objectText: string?)` | `ProximityPrompt` | A custom-style prompt tagged `Interact_Prompt` with that style and those input mappings (`Default` when nil); parent it yourself |
| `GetMappings(mappingsName: string?)` | `Interact_Mapping` | The input mappings with that name; `Default` when the name is empty, and (with a warning) when no mappings have it |
| `GetGamepadImage(mappings: Interact_Mapping, keyCode: Enum.KeyCode)` | `string?` | A gamepad button's image from those mappings: on a PlayStation pad its `PlayStationButtonImage` when the mappings have one, otherwise its `GamepadButtonImage`; nil when neither has the key |

### Client: `I.Interact`

The Global functions, and:

| Function | Returns | What it does |
| --- | --- | --- |
| `OnPress(button: GuiButton, callback: () -> ())` | `Interact_PressConnection` | Calls `callback` when the button is activated (`Activated`: clicked, tapped or picked with a gamepad) and when its key presses it (`Utils_ButtonKey`), on the key's release; `Disconnect()` stops both. Use it instead of `Activated:Connect` or `MouseButton1Click:Connect` for a button that has, or may get, a key |

A key presses the shown button that names it on the gui with the highest `DisplayOrder` (`I.Utils.PressKey`), and is sunk then; with no such button the key goes on to the bindings below it (B still closes the backpack, A still jumps). Keys are bound at `Enum.ContextActionPriority.High`, as `Interact_Key_<KeyCode>` actions, the first time a button names them.

## Usage

```lua
local prompt = I.Interact.CreatePrompt("Default", "Enhanced", 10, "Open", "Chest")
prompt.Parent = chest.PrimaryPart

-- Client: a click, or the button's key, confirms
I.Interact.OnPress(confirmButton, Module._confirm)
```

## Components

The called function gets `Interact_Arg1`, `Interact_Arg2`, … in order (as many as are set). Areas and server prompts check once, when they start, that `I[Interact_ModuleName][Interact_Function]` is a function; when it isn't they warn (Studio highlights the instance) and stay inactive.

### `Interact_ServerArea` / `Interact_ClientArea` (`Components/Area.lua`)

Calls the function when a player's character touches the part, at most once per `Interact_Delay` (per player on the server). The server doesn't trust the touch alone: it counts only when the character is alive and its `HumanoidRootPart` is inside the part's box widened by `Interact_MaxDistance` studs.

| | |
| --- | --- |
| Tag on | `BasePart` |
| Side | `Interact_ServerArea`: server; `Interact_ClientArea`: client, for the local player |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Interact_ModuleName` | string | `""` | The `I` table to call into |
| `Interact_Function` | string | `""` | The function on it |
| `Interact_Delay` | number | `0.25` | Seconds between calls |
| `Interact_PassPlayer` | boolean | `false` | (server) Pass the touching player as an argument |
| `Interact_PassPlayerPos` | number | `1` | (server) Where among the arguments the player goes |
| `Interact_MaxDistance` | number | `8` | (server) How far outside the part's box, in studs, the character's root may be when the touch counts |
| `Interact_Arg1`… | any | | Arguments, in order |

### `Interact_ServerPrompt` (`Components/ServerPrompt.lua`)

Calls the server function when a player triggers the prompt (a deliberate press or hold), at most once per `Interact_Delay` per player. The trigger counts only when the character is alive and its `HumanoidRootPart` is within the prompt's `MaxActivationDistance` plus `Interact_MaxDistance` studs. Add `Interact_Prompt` as well for a custom look.

| | |
| --- | --- |
| Tag on | `ProximityPrompt` (under a part, an attachment or a model) |
| Side | Server |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Interact_ModuleName` | string | `""` | The `I` table to call into |
| `Interact_Function` | string | `""` | The function on it |
| `Interact_Delay` | number | `0.25` | Seconds between one player's calls |
| `Interact_PassPlayer` | boolean | `false` | Pass the triggering player as an argument |
| `Interact_PassPlayerPos` | number | `1` | Where among the arguments the player goes |
| `Interact_MaxDistance` | number | `8` | Studs past `MaxActivationDistance` the character's root may be |
| `Interact_Arg1`… | any | | Arguments, in order |

### `Interact_Button` (`Components/Button.lua`)

Calls the function when the button is clicked, or when its key presses it (`Utils_ButtonKey` on the same button), through `OnPress`.

| | |
| --- | --- |
| Tag on | `ImageButton` or `TextButton` |
| Side | Client |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Interact_ModuleName` | string | `""` | The `I` table to call into |
| `Interact_Function` | string | `""` | The function on it |
| `Interact_Arg1`… | any | | Arguments, in order |

### `Interact_Prompt` (`Components/Prompt.lua`)

Draws the prompt with its style's gui each time it's shown, and removes it when hidden.

| | |
| --- | --- |
| Tag on | `ProximityPrompt` with `Style = Custom` |
| Side | Client |
| Needs | A style module in `src/global_data/Interact/PromptStyles/` (`Default`, `Default_Shadow`; copy `Default.lua` for a new one) and a mappings module in `src/global_data/Interact/Mappings/` |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Interact_Style` | string | `""` | The prompt style's name |
| `Interact_Mappings` | string | `""` | The input mappings' name; empty uses `Default`. The style reads it each time the prompt shows |

#### Prompt styles

A style module returns `{ CreatePrompt = function(prompt, inputType, gui) }` (`Interact_PromptStyle`): it builds the prompt's BillboardGui into `gui` and returns a cleanup function, which runs when the prompt hides. It reads the prompt's `Interact_Mappings`, gets those mappings with `I.Interact.GetMappings`, and draws the key with them: gamepad buttons through `I.Interact.GetGamepadImage`, keyboard keys on `KeyCapImage` (a symbol from `KeyboardButtonImage` or `KeyboardButtonIconMapping`, a text from `KeyCodeToTextMapping`, else the key's own text), touch with `TouchTapImage`, and the hold ring with `RadialFillImage`.

#### Input mappings

Each module in `src/global_data/Interact/Mappings/` returns an `Interact_Mapping`:

| Key | What |
| --- | --- |
| `GamepadButtonImage` | `Enum.KeyCode` → image: the Xbox buttons, and the d-pad and sticks both pads share |
| `PlayStationButtonImage` | `Enum.KeyCode` → image for a PlayStation pad (Cross is `ButtonA`), used before `GamepadButtonImage`; leave a key out to use the Xbox image |
| `KeyboardButtonImage` | `Enum.KeyCode` → image for keys drawn as a symbol (Backspace, Return, Shift, Tab) |
| `KeyboardButtonIconMapping` | The key's text (`UserInputService:GetStringForKeyCode`) → image, for keys whose character is too small to read |
| `KeyCodeToTextMapping` | `Enum.KeyCode` → the text written on the key cap (Ctrl, Alt, F1 to F12) |
| `KeyCapImage`, `TouchTapImage`, `RadialFillImage` | The key cap, the touch hand and the hold ring |

| Mappings | What |
| --- | --- |
| `Default` | Roblox's own textures (`rbxasset://textures/ui/Controls/`), as Roblox's default prompt draws them: Xbox buttons on every pad |
| `Enhanced` | ume's redrawn images, uploaded to Roblox, with PlayStation 5 buttons for PlayStation pads. Sources and ids: the `icons/prompt-inputs` set in the maintainers' art tools, outside the repo |

A PlayStation pad is told apart by `UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)` returning `"ButtonCross"`.

## Commands

`interact` (server):

| Subcommand | Arguments |
| --- | --- |
| `create_test_prompt` | `player`, `promptName` (a prompt style), `[holdDuration]`, `[decayTime]`, `[mappingsName]` |
| `clear_spawned` | |
