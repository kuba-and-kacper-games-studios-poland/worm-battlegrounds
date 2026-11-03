# Number

Number helpers: lerp and range mapping, safe conversion, integer and number string checks, and a log scale that fits huge values into an OrderedDataStore.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Number` |
| Exposes | `I.Number` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Number.Lerp(a: number, b: number, t: number)` | `number` | Linearly interpolates from `a` to `b` with `t` clamped to [0, 1]. |
| `I.Number.Normalize(value: number, inputMin: number, inputMax: number, outputMin: number, outputMax: number)` | `number` | Clamps `value` to the input range and maps it onto the output range. Reversed ranges are supported on both sides. |
| `I.Number.ToNumberOr(value: any, default: number)` | `number` | Converts `value` with `tonumber` and returns it when it is finite, otherwise `default`. |
| `I.Number.IsIntegerString(s: string)` | `boolean` | Returns whether `s` is a base-10 integer string with an optional leading minus. |
| `I.Number.IsNumberString(s: string)` | `boolean` | Returns whether `s` is a base-10 number string that may include a fractional part. |
| `I.Number.ToLogScale(value: string)` | `number` | Encodes a positive integer string as `floor(log(value) / log(1.0000000001))`, for storing huge values in an OrderedDataStore. Zero, empty, and non-integer strings encode to 0. One also encodes to 0. |
| `I.Number.FromLogScale(stored: number)` | `string` | Decodes a `ToLogScale` integer back to an approximate positive integer string. Zero and invalid inputs return "0". The tail digits are padded with zeros, so huge values are not exact. |

## Usage

```lua
if not I.Number.IsIntegerString(amount) then return false end
```
