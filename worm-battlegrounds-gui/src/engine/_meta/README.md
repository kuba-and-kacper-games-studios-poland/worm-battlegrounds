# UmeGui

A table-driven gui framework. Each gui is a ModuleScript under `Guis/` that returns a table of nodes; the engine checks it, builds it from `Controls/` styled by `Themes/`, and returns a View that scripts drive by Id. The Ume plugin's Gui tool previews and exports a place's guis with it, and draws the plugin's own widgets (`Guis/Plugin`) with its bundled copy. Exported guis are static ScreenGuis that game scripts find by name.

| | |
| --- | --- |
| Folder | `src/engine` (in the place: the `UmeGui` ModuleScript; `src/themes` → `UmeGui.Themes`, `src/guis` → `UmeGui.Guis`) |
| Format | `.claude/rules/gui/format.md`: gui tables, node keys, the control catalog, styles, devices, views |
| Version | `Version.model.json` |

## API

`require(ServerStorage.UmeGui)` returns these. **Host** marks the host API, the functions the Ume plugin calls on a place's UmeGui; their contract is Host API in `gui/format.md`.

| Function | Returns | What it does |
| --- | --- | --- |
| `Build(gui: string \| UmeGui_Gui, options: UmeGui_BuildOptions?)` **Host** | `UmeGui_View` | Builds a gui (a path such as `"Plugin/Sync"`, or a table). Nothing is parented. Options: `Mode`, `Interactive`, `Tokens` |
| `Export(gui: string \| UmeGui_Gui, mode: UmeGui_Mode?)` **Host** | `ScreenGui` | A static copy in a ScreenGui named after the gui: no engine behaviour, framework tags kept, every prefab hidden as `PREFAB \| Name` in its `Parent` element. `Screen` props and `ScreenTags` go on the ScreenGui; a Folder root exports its children into it |
| `ApplyDevice(view: UmeGui_View, device: UmeGui_Device, pad: UmeGui_Pad?)` **Host** | | Shows a view as the game does on `Desktop`, `Mobile`, `Console` or `VR` (with `pad`'s gamepad icons on Console); prefab clones built later follow; another device restores what this one changed |
| `GetDevices(view: UmeGui_View)` **Host** | `{ UmeGui_Device }` | The gui's `Devices`, or Desktop plus every device its platform rules treat differently |
| `GetGuiNames()` **Host** | `{ string }` | Every gui path under `Guis/`, sorted; modules inside a gui module are skipped |
| `GetPreview(path: string)` **Host** | `UmeGui_PreviewModule?` | What a gui's `Preview` child returns, or nil |
| `GetGui(path: string)` **Host** | `UmeGui_Gui` | The table a gui module returns; the Gui tool reads its `Kind` and `Preview` size |
| `GetErrors(gui: string \| UmeGui_Gui)` | `{ string }` | Every schema problem, with its node path, without building; empty when valid |
| `GetThemeNames()` | `{ string }` | Every theme |
| `GetVersion()` | `string` | This UmeGui's version |

### View

| Member | What it is |
| --- | --- |
| `Root`, `RootHandle` | `Root` is the Folder named `Root` the gui sits in (a gui's own Folder root becomes it; since 4.0.0); `RootHandle` is the gui's top element's handle, and `RootHandle.Instance` that element |
| `Ids`, `Scoped` | Handles by `U_` Id, and by `U_` Id then `S_` Id |
| `Mode`, `Device`, `Pad`, `Interactive`, `Tokens` | The current state |
| `ModeChanged` | Fires after `SetMode` |
| `view:Get(id: string, scopedId: string?)` | A `U_` element's handle, or the `S_` element under it |
| `view:Build(templateName: string, parent?, params?)` | Builds a `PREFAB \| Name` clone into `parent` (or the template's `Parent`); returns a subview with its own `Get` and `Destroy` |
| `view:SetMode(mode: UmeGui_Mode)` | Recolors in place, no rebuild |
| `view:SetToken(tokenName: string, color: Color3?)` | A per-view palette override; nil restores |
| `view:Destroy()` | |

A handle always has `Instance`; pressable controls add `Button`, value controls `Changed`, `Get` and `Set` (`Set` never fires `Changed`). Each control's extra fields are in `Controls/_meta/README.md`.

## Engine

| File | What it owns |
| --- | --- |
| `init.lua` | The API above; finds guis under `Guis/` |
| `Engine/Build.lua` | Turns a gui table into instances and returns the View: Ids to handles, templates built on demand, live mode and token switching |
| `Engine/Validate.lua` | Checks a gui table before it is built and returns every problem with its node path |
| `Engine/Context.lua` | The toolkit every control's `Build` gets (`ctx`): theme-aware setters that re-apply on mode changes, sub-node building, states, tweens, input capture, overlays. One per build scope |
| `Engine/Style.lua` | The style cascade (`Default` → variants → node overrides) and token lookups |
| `Engine/States.lua` | A control's look across Selected, Hover, Pressed and Disabled, from the style's `States` |
| `Engine/Theme.lua` | Loads `Themes/<Name>` into one table of tokens and styles; `Extends` fills in from the base; a theme's own `Controls` are found before the shared ones; every theme has a `Gamepad` module (its own or its base's) |
| `Engine/Device.lua` | Applies what the framework's platform components (`Utils_PlatformSize`, `Utils_PlatformScale`, `Utils_HideOnPlatform`) and `Console_Hint` do in game, and the picked pad's icons; saves what it replaces |
| `Primitives.lua` | Creates raw instances: with per-class defaults for controls (`Create`), with Roblox's own defaults for a gui's `Primitive` nodes (`CreatePlain`); every property is checked against reflection, so a typo errors with its name. Rejects `TextButton`, and in controls text that turns `TextScaled` / `RichText` off |
| `Controls/*.lua` | One module per control (`Controls/_meta/README.md`) |
| `_meta/_types.lua` | Every `UmeGui_*` shape |

## Libs

The stateful side, used only by hosts: the Gui tool and the plugin's widgets start it once per session from the long-lived UmeGui, never from a live-reload clone. The engine itself only uses stateless mirror libraries (`GoodSignal`, `Create`'s reflection index).

| File | What it is |
| --- | --- |
| `Libs/init.lua` | `Start()` injects the mirrored libraries into the Runtime, starts sounds, registers the mirrored Utils components and starts the scaler scripts. `Stop()` removes the sounds' holder folder from CoreGui (a host calls it when it unloads); a later `Start()` or `Bind(root)` starts the sounds again, and the rest stays wired. `Bind(root)` lets them run on one gui; `SetSoundHost(host)` plays their sounds inside a plugin widget (a DockWidgetPluginGui, the only place Studio edit mode plays a plugin's sounds; nil goes back to `PlayLocalSound`), `SetSoundVolume(volume)` scales them (0 to 1, 1 by default); `PlayPress(button)` plays a press on a button in the bound guis (its click look and sound) without running it; `PressKey(keyCode, down)` presses or releases the keyed button (`Utils_ButtonKey`) a key belongs to in the bound guis, as a click would, and returns whether one took it (the Gui tool passes it the pad and keyboard presses Studio gives the plugin); `GetRuntime()` returns the shim. The place's own guis stay static in edit mode |
| `Libs/Runtime.lua` | The `I` shim the mirrored code runs against: `I.S` services (CollectionService scoped), the mirrored libraries, `I.Component`, `I.Sound` |
| `Libs/Component.lua` | A stand-in for the framework's `I.Component`: `Register(tag, module)`, `Get(instance, tag)`, `IsRegistered(tag)` |
| `Libs/Scope.lua` | Limits the components to bound guis: only instances under a bound root count as tagged (`Add`, `Remove`, `Contains`) |
| `Libs/Sound.lua` | A stand-in for `I.Sound`, fed by the mirrored sound lists; sounds are cached in one `__UmeGui_Sounds` folder under CoreGui (made by `Init`, destroyed by `Stop`, which also forgets the host) and each play is a short-lived clone: inside the host widget `SetHost` names, else played with `PlayLocalSound` (silent in edit mode). Nothing is written into the place |
| `Libs/Mirror/` | **Generated** by `scripts/Sync.ps1 Libs` from the paired game repo (its `.lua` files only); never edited by hand. Holds `BigNum`, `GoodSignal`, `Create`, `Color`, `UIEmitter`, `Sound` (the sound lists) and `Utils` (Settings, the ButtonScale animations in `Data/ButtonScalePresets.lua`, the Button and Visual components, `UIGrid`, the stroke and slice scalers, `GuiVisibility` and `ButtonPress`). The code is the game's, except the one line that loads `I` (from `Libs.Runtime`), and every `@class` / `@alias` is renamed `UmeGui_<name>` in annotations |

## Version

`Version.model.json` (a StringValue) is UmeGui's version, read by `GetVersion`. Bump the minor version when the API grows, the major version when the host API changes; tag releases `v<version>` (`gui/repo.md`).
