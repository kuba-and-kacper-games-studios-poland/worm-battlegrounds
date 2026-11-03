# RichText

Wraps text in RichText tags from a params table (colour, size, font, weight, stroke…).

| | |
| --- | --- |
| Folder | `src/libs/Internal/RichText` |
| Exposes | `I.RichText` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The formatter |
| `_meta/_types.lua` | The params table |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.RichText.Format(input: string?, params: RichText_Table?)` | `string` | Wraps `input` in rich text tags built from `params` (font, stroke, mark, then style tags). |

## Types

In `_meta/_types.lua`: `RichText_Table`.
