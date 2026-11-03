# Format

Formats numbers and number strings for display by named format types (`default`, `time`), one value or a whole table at once.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Format` |
| Exposes | `I.Format` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The format types and the functions |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Format.Table(t: { [any]: any }, formatType: string?)` |  | Formats every number and string in the table in place, recursing into nested tables. |
| `I.Format.GetFormatFunctionNames()` | `{ string }` | Returns the names of every format type. |
| `I.Format.Text(value: any, formatType: string?)` | `string` | Formats a number or string with the given format type (`default` when unknown or omitted). Other value types are returned through `tostring`. |

## Usage

```lua
label.Text = I.Format.Text(amount)
timer.Text = I.Format.Text(secondsLeft, "time")
```
