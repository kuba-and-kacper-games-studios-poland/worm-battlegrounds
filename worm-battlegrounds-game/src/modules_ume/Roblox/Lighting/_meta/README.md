# Lighting

Layered, client-side lighting. Every lighting property (on `Lighting`, `Atmosphere`, `Sky`, the post effects) holds a stack of layers, each with a weight; the highest weight wins, and changes tween. A preset (made in the place with the Ume plugin's Lighting Manager, or a Lua file in `src/global_data/Lighting/Presets/`) sets the base layer (weight `1`); modules put their own layers on top at a higher weight (a cave, a cutscene, a buff) and clear them again without knowing what else is set. An overlay preset applies only the properties a preset authors, at a weight. The server asks a player's client to do the same.

**Layers.** Each layer has an id: `valueTable.Id` (or the `id` argument), defaulting to the weight as a string. Setting the same id again updates that layer; a different id adds another, so two modules that pick the same weight no longer overwrite or clear each other. At equal weights the layer added last wins. Clearing takes the same id.

**Presets in the place.** The client reads them at start, the way the Ume plugin's Lighting Manager keeps them: the active preset is Lighting itself (its properties and its Sky, Atmosphere and post effects), named by the `Lighting_Id` attribute of `Lighting.__config`; each stored preset is a folder `Lighting.Presets.<Id>` holding its own `__config` (Lighting's properties as attributes) and its instances. A post effect a preset has no instance for is off, and a missing Atmosphere has no density, as when the plugin switches to it; a preset without a Sky keeps the template's. A place preset replaces a Lua preset with the same name, and a place the Lighting Manager hasn't set up (no `Lighting.__config`) gives its lighting as `Default`. Make, edit and switch presets in the plugin (Ume Scene → Lighting), then save the place; the game takes them by Id (`SetActivePreset("Rain")`). Game scripts can't set `LightingStyle` or `PrioritizeLightingQuality`, so the game keeps the place's, whatever the preset says. `FogColor`, `FogStart` and `FogEnd` are kept and applied, but Roblox ignores them while an Atmosphere exists, and the module always makes one: fog is the Atmosphere's `Density` and `Haze`.

**Applying.** `UpdateActiveLighting` moves every property to its winning value. Each property is tweened on its own: a tween already heading to the same goal keeps playing, any other tween on that property is replaced, and other properties' tweens aren't touched. Properties the `tweenInfo` doesn't cover, and text properties such as Sky textures, are set at once. `ClockTime` wraps at 24 and takes the shortest way round unless a direction is given (`"Forward"` runs 1, 2, …, 23, 0; `"Backward"` the other way).

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Lighting` |
| Runs on | Client, Server |
| Exposes | `I.Lighting` (client, server) |
| Uses | `Lighting` (and its `__config` and `Presets`), `TweenService`, `I.Network`, `src/global_data/Lighting` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The client API: checks, presets and overlays, values, `UpdateActiveLighting`, the remotes |
| `Scripts/Client/Presets.lua` | Loads the Lua presets and the place's (the Lighting Manager's), checks and fills in every preset; keeps each preset's authored properties for overlays |
| `Scripts/Client/Layers.lua` | The layer stacks: adding, updating and removing layers, the winning value of a property |
| `Scripts/Client/Tweening.lua` | Tweens one property at a time, the per-property `TweenInfo` lookup, `ClockTime` wrapping |
| `Server.lua` | The same calls for one player, sent to their client |
| `Data/LightingProperties.lua` | Every effect and property the module manages, with its type |
| `Settings.lua` | The template, default and overwrite options |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `s_lighting` command |
| `Scripts/AdminPanel/CommandBar/Client.lua` | The `lighting` command and the autocomplete dictionaries |
| `_meta/_types.lua` | `Lighting_ValueTable`, `Lighting_Layer`, `Lighting_ClockTimeDirection`, `Lighting_PlayingTween` and preset shapes |

## API

`tweenInfo` is a `TweenInfo`, a name from `src/global_data/Lighting/Tweens.lua` (`"Fast"`, `"Medium"`, `"Slow"`), or a table: `{ [effectName]: TweenInfo | { [propertyName]: TweenInfo } }`, then `{ [propertyName]: TweenInfo }`. Properties the table doesn't name are set at once. Functions with `updateLighting` apply the change right away unless it is `false`; pass `false` to batch several changes and call `UpdateActiveLighting` once (that is also how a `ClockTime` direction is chosen).

### Client: `I.Lighting`

| Function | Returns | What it does |
| --- | --- | --- |
| `SetActivePreset(presetName: string, effectName: string?, propertyName: string?, tweenInfo, updateLighting: boolean?)` | | Makes the preset (or one effect or property of it) the base layer |
| `SetOverlayPreset(presetName, weight: number, tweenInfo, updateLighting?, id: string?)` | `boolean` | Puts the preset's authored properties on top at `weight`, as layers with `id` |
| `ClearOverlayPreset(presetName, weight, tweenInfo, updateLighting?, id: string?)` | `boolean` | Removes that overlay's layers |
| `SetValue(effectName: string, propertyName: string, valueTable: Lighting_ValueTable, tweenInfo, updateLighting?)` | `boolean` | Adds or updates the layer `valueTable.Id` at `valueTable.Weight` (`Value`, `false` included, and optional HSV shifts for colors) |
| `SetValueBulk(valuesTable, tweenInfo)` | `{ [string]: boolean }` | Many `SetValue`s (rows `{ effectName, propertyName, valueTable }`), then one update |
| `ClearValue(effectName, propertyName, weight: number, tweenInfo, updateLighting?, id: string?)` | `boolean` | Removes the layer `id` (default: the weight) |
| `ClearValueBulk(valuesTable, tweenInfo)` | `{ [string]: boolean }` | Many `ClearValue`s (rows `{ effectName, propertyName, weight, id? }`), then one update |
| `UpdateActiveLighting(tweenInfo, clockTimeDirection: Lighting_ClockTimeDirection?)` | `boolean` | Applies the winning value of every property, tweening to it; `clockTimeDirection` is `"Shortest"` (default), `"Forward"` or `"Backward"` |
| `GetValue(effectName, propertyName)` | `any`, `number?`, `string?` | The value the property resolves to, with the weight and id of its winning layer (the base layer has no id) |

### Server: `I.Lighting`

`UpdateActiveLighting(player, tweenInfo, invoke?, clockTimeDirection?)`, `SetActivePreset`, `SetValue`, `SetValueBulk`, `ClearValue(player, effectName, propertyName, weight, tweenInfo, updateLighting?, invoke?, id?)`, `ClearValueBulk`: the client functions with a `player` first and an `invoke: boolean?` after the client's arguments. Without `invoke` the request is fired and the function returns `nil`; with it the server waits for the client's result, at most the Network invoke timeout (10 seconds), and gets `false` (or `nil` for the bulk forms) when the client fails or doesn't answer.

## Usage

```lua
-- Client: darken while inside a cave, then restore
I.Lighting.SetValue("Lighting", "Brightness", { Value = 0.5, Weight = 10, Id = "Cave" }, "Medium")
I.Lighting.ClearValue("Lighting", "Brightness", 10, "Medium", nil, "Cave")

-- Client: move the clock to 1 AM, running forward through the day
I.Lighting.SetValue("Lighting", "ClockTime", { Value = 1, Weight = 5, Id = "Time" }, nil, false)
I.Lighting.UpdateActiveLighting("Slow", "Forward")
```

## Network

### Server

**Send: RemoteEvents**

- `Lighting_UpdateActiveLighting`, `Lighting_SetActivePreset`, `Lighting_SetValue`, `Lighting_SetValueBulk`, `Lighting_ClearValue`, `Lighting_ClearValueBulk`, each `@ (player: Player, …)` with the client function's arguments.

**Send: RemoteFunctions**

- The same six names with `-Return`, for the `invoke` form.

### Client

**Receive: RemoteEvents**

- `Lighting_UpdateActiveLighting @ (tweenInfo: string | TweenInfo | table?, clockTimeDirection: string?)`
- `Lighting_SetActivePreset @ (presetName: string, effectName: string?, propertyName: string?, tweenInfo: string | TweenInfo | table?, updateLighting: boolean?)`
- `Lighting_SetValue @ (effectName: string, propertyName: string, valueTable: table, tweenInfo: string | TweenInfo | table?, updateLighting: boolean?)`
- `Lighting_SetValueBulk @ (valuesTable: table, tweenInfo: string | TweenInfo | table?)`
- `Lighting_ClearValue @ (effectName: string, propertyName: string, weight: number, tweenInfo: string | TweenInfo | table?, updateLighting: boolean?, id: string?)`
- `Lighting_ClearValueBulk @ (valuesTable: table, tweenInfo: string | TweenInfo | table?)`

**Receive: RemoteFunctions**

- The same six with `-Return`, returning the client function's result.

## Data

| Where | Key | What |
| --- | --- | --- |
| `src/global_data/Lighting/Presets/<Preset>.lua` | effect → property → value | A preset (`Default`, `Roblox`) |
| `Lighting.__config` (place) | `Lighting_Id` | The Id of the preset Lighting shows (the Lighting Manager's active preset) |
| `Lighting.Presets.<Id>` (place) | `__config` attributes, effect instances | A stored preset: Lighting's properties as attributes (`Lighting_Id`, the Lighting Manager's `Lighting_Landscape` and `LightingStyle` and `PrioritizeLightingQuality` are ignored), its Sky, Atmosphere and post effects |
| `src/global_data/Lighting/Tweens.lua` | `[name]` | Named `TweenInfo`s |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TEMPLATE_LIGHTING_ID` | `"Roblox"` | Preset every other preset is checked against |
| `DEFAULT_LIGHTING_ID` | `"Default"` | Preset applied at start (and the one the place's lighting becomes when the Lighting Manager hasn't set it up) |
| `OVERWRITE_DEFAULT_LIGHTING` | `true` | Read the place's presets over Lua presets with the same name |
| `PLACE_CONFIG_NAME`, `PLACE_PRESETS_FOLDER`, `PLACE_ID_ATTRIBUTE` | `"__config"`, `"Presets"`, `"Lighting_Id"` | The names the Lighting Manager uses in the place; keep them as the plugin has them |

## Commands

| Command | Side | Variants |
| --- | --- | --- |
| `s_lighting` | server, run on a player's client | `set_active_preset` (the client checks the preset name), `set_value`, `clear_value` |
| `lighting` | client | `dump [all]`: each property's layers, winning first (only properties with layers above the base preset, or every property with `all`) |

The client also fills the autocomplete dictionaries (presets, tweens, effects, properties).
