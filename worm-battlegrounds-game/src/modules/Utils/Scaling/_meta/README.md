# Scaling

Balancing numbers from curves. A named value (a price, a reward, enemy health) is a definition: a curve kind (`Linear`, `Polynomial`, `Exponential`, `Piecewise`, `BandExponential`, `Power`, or a function), the input it reads from a context (`Level`, `Rarity`, `Difficulty`…), base, growth, exponent, add and multiply terms, scalars per input value, and a min and max. Values are calculated in fixed-point BigNum, so large numbers stay exact; `GetBreakdown` shows every step for tuning. The definition's `Round` (or `ROUNDING`) applies wherever a curve or the scalar step turns the value into a whole number. Every definition in `VALUES` is checked at start, and each one passed to `Register`: an unknown curve, a constant that doesn't parse as a number, an `Input` that isn't a key name, and `Pieces` / `Bands` that are missing, non-numeric or out of order warn with the value name. An unknown value name warns (`Value definition (name) is missing!`) and returns `nil`.

| | |
| --- | --- |
| Folder | `src/modules/Utils/Scaling` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Scaling` (both) |
| Uses | `I.BN` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The definitions registry, `Calculate`, `GetBreakdown` |
| `Scripts/Helpers.lua` | Fixed-point math and the curve kinds |
| `Settings.lua` | Precision, rounding, the built-in definitions |
| `_meta/_types.lua` | `Scaling_Context`, `Scaling_ValueDefinition` and the curve pieces |

## API

### Global: `I.Scaling`

| Function | Returns | What it does |
| --- | --- | --- |
| `Register(valueName: string, definition: Scaling_ValueDefinition)` | | Adds or replaces a named definition on this side only (server and client keep separate registries) and warns about problems in it |
| `GetDefinitions()` | `{ [string]: Scaling_ValueDefinition }` | Every definition |
| `GetDefinition(valueName)` | `Scaling_ValueDefinition?` | A copy of one definition; `nil` with a warning when it is missing |
| `Calculate(valueData: string \| Scaling_ValueDefinition, context: Scaling_Context?)` | `string?` | The value as a BigNum string; skips the breakdown terms, so each function input runs once. `nil` when the definition is missing |
| `GetBreakdown(valueData, context?)` | `Scaling_Result?` | The value with every intermediate step; `nil` when the definition is missing |

## Usage

```lua
local price = I.Scaling.Calculate("UpgradePrice", { Level = level })
```

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PRECISION` | `6` | Decimal places kept while calculating |
| `ROUNDING` | `"None"` | `None`, `Floor`, `Ceil` or `Round` on the result |
| `VALUES` | `Example` | Built-in definitions by name |
