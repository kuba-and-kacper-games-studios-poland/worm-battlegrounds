# Random

Random numbers from one shared `Random` object.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Random` |
| Exposes | `I.Random` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Random.Float(min: number?, max: number?)` | `number?` | Returns a random float in [min, max]. Defaults to [0, 1]; a lone argument is the upper bound. |
| `I.Random.Int(min: number?, max: number?)` | `number?` | Returns a random integer in [min, max]. Defaults to 0 or 1; a lone argument is the upper bound. |
