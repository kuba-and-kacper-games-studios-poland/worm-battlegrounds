# Time

Formats durations in seconds (`1h 05m`, `01:05:00`) from templates.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Time` |
| Exposes | `I.Time` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Time.FormatClean(s: number \| string, formatTemplates: { string }?)` | `string` | Formats seconds with the template matching the largest unit present. `formatTemplates` overrides [1] days, [2] hours, [3] minutes, [4] seconds (defaults: "Dt:HHl:MMl:SSl", "HHt:MMl:SSl", "MMt:SSl", "MMt:SSt"). |
| `I.Time.Format(s: number \| string, format: string)` | `string` | Formats whole seconds (negative values count as 0) with template tokens. `t` tokens are the total amount of that unit, `l` tokens are the remainder after larger units. Days: DDt, Dt. Hours: HHt, Ht, HHl, Hl. Minutes: MMt, Mt, MMl, Ml. Seconds: SSt, St, SSl, Sl. Doubled letters are zero-padded to two digits. |
