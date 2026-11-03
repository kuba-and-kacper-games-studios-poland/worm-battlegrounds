# Date

Formats Unix timestamps and date tables with template tokens (`YYYY-MM-DD hh:mm`), in local time or UTC.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Date` |
| Exposes | `I.Date` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |
| `_meta/_types.lua` | The date table |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Date.UnixToDateLocal(unixTime: number, format: string)` | `string` | Formats a Unix timestamp in local time using template tokens (see `UnixToDate`). |
| `I.Date.UnixToDateUTC(unixTime: number, format: string)` | `string` | Formats a Unix timestamp in UTC using template tokens (see `UnixToDate`). |
| `I.Date.UnixToDate(dateData: Date_DateTable, format: string)` | `string` | Formats a date table with template tokens. Tokens are matched longest first in one pass. Year: YYYY, YY. Month: MMMM (January), MMM (Jan), MM (01), M (1). Day: DDDD (Monday), DDD (Mon), DD (01), D (1). Hour: HH / H (24h), hh / h (12h). Minute: mm, m. Second: ss, s. Period: A (AM), a (am). |

## Usage

```lua
local text: string = I.Date.UnixToDateLocal(os.time(), "DD MMM YYYY")
```

## Types

In `_meta/_types.lua`: `Date_DateTable`.
