# Rarity

Rarity tiers (Common to Secret): their names in order, roll weights, icons and gradient styles, and weighted random rolls with luck. Luck from 0 to 1000 moves each tier's weight from its `Min` toward its `Max`, making rare tiers likelier. `Rarity_Gradient` colours a gradient by rarity. `ApplyLook` writes a rarity on a label in its own text, font, gradient and outline (`RARITY_LOOKS`, the gui style's rarity looks), as the seed stands and the tree tags show it.

| | |
| --- | --- |
| Folder | `src/modules/Utils/Rarity` |
| Runs on | Global, Client |
| Exposes | `I.Rarity` (both) |
| Uses | `I.Gradient`, `I.Component` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The getters, the weighted rolls and `ApplyLook` |
| `Client.lua` | Registers `Rarity_Gradient` |
| `Settings.lua` | Names, weights, icons, gradient styles, label looks |
| `Components/Gradient.lua` | `Rarity_Gradient` |
| `_meta/_types.lua` | `Rarity_WeightRange`, `Rarity_GradientStyle`, `Rarity_Look` |

## API

### Global: `I.Rarity`

| Function | Returns | What it does |
| --- | --- | --- |
| `ApplyLook(label: TextLabel, glow: TextLabel?, rarityName)` | | Writes the rarity on `label` in its look: text, font, UIGradient colours and UIStroke colour; on `glow` (a copy behind it, with a UIStroke) the same text and font in the base colour, shown only for looks with `Glow`. An unknown rarity warns and leaves them as they are |
| `GetRarities()` | `{ string }` | Tier names in order (a copy) |
| `GetRarityIndex(rarityName)` | `number?` | The tier's position in `RARITY_NAMES` (1 = most common); warns when unknown |
| `GetRaritiesWeights()` | `{ [string]: Rarity_WeightRange }` | Every tier's `{ Min, Max }` (a copy) |
| `GetRarityWeight(rarityName)` | `Rarity_WeightRange?` | One tier's weights |
| `GetRarityIcon(rarityName)` | `string?` | Its icon |
| `GetGradient(rarityName)` | `Rarity_GradientStyle?` | `{ Rotation, AddGradientMove }` |
| `GetGradientRotation(rarityName)` | `number?` | |
| `GetAddGradientMove(rarityName)` | `boolean` | Whether the gradient also moves (`Utils_UIGradientMove`) |
| `GetChances(names: { string }?, weightTable: { [string]: Rarity_WeightRange }?, luck: number?)` | `{ [string]: number }` | Each name's chance (0-1) at that luck, the exact odds `GetRandomWeighted` rolls with; `names` and `weightTable` default to `RARITY_NAMES` and `RARITY_WEIGHTS`. Use it to show odds. |
| `GetRandomRarity(luck: number?)` | `string` | Rolls a tier from `RARITY_WEIGHTS` |
| `GetRandomWeighted(names: { string }, weightTable: { [string]: Rarity_WeightRange }, luck: number?)` | `string` | Rolls from your own names and weights |
| `GetLook(rarityName)` | `Rarity_Look?` | The rarity's look; warns when it has none |
| `GetTier(rarityName)` | `number?` | The rarity's tier: its place in `RARITY_NAMES` (Common 1 … Secret 14); warns and returns `nil` for an unknown rarity |
| `IsRarer(rarityA: string, rarityB: string)` | `boolean` | Whether `rarityA` comes after `rarityB` in `RARITY_NAMES`; `false` (with a warn) for an unknown tier |

## Usage

```lua
local rarity = I.Rarity.GetRandomRarity(playerLuck)
local odds = I.Rarity.GetChances(nil, nil, playerLuck) -- odds["Secret"]
if I.Rarity.IsRarer(rarity, "Epic") then
	-- announce it
end

-- A label (with a UIGradient and a UIStroke) and its glow copy
I.Rarity.ApplyLook(rarityLabel, rarityGlow, "Legendary")
```

## Settings

| Key | What |
| --- | --- |
| `RARITY_NAMES` | Tier names in order |
| `RARITY_WEIGHTS` | `[name] = { Min, Max }`: the weight at luck 0 and at luck 1000 |
| `RARITY_ICONS` | `[name] = asset id` |
| `RARITY_GRADIENTS` | `[name] = { Rotation, AddGradientMove }` |
| `RARITY_LOOKS` | `[name] = Rarity_Look`: `Text` (the name alone, no framing symbols: `"Rare"`, `"LEGENDARY"`, `"C E L E S T I A L"`…), `Font`, `Base` colour, gradient `Colors` (top to bottom; Secret's is a rainbow of seven), `Stroke` colour, `Glow`. Every rarity in `RARITY_NAMES` has one; Epic and up glow |

## Components

### `Rarity_Gradient` (`Components/Gradient.lua`)

Sets the gradient's colour (the `I.Gradient` gradient named `Rarity_<rarity>`) and rotation, and tags it `Utils_UIGradientMove`: it scrolls at the default speed when the rarity asks for it (`AddGradientMove`), and stays still at `Utils_MoveSpeed` 0 otherwise. The tag stays on when the rarity changes (the game's `practices.md` → A scrolling gradient keeps its tag). The place has no `Rarity_*` gradients yet, so every rarity falls back to plain white.

| | |
| --- | --- |
| Tag on | `UIGradient` |
| Side | Client (`RegisterOnLoaded`) |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Rarity_Rarity` | string | `"Common"` | The tier; changing it reapplies the style |
