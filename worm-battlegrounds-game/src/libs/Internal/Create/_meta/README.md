# Create

Creates instances from a property table, checking every property against the API dump (it exists, it's writable, the value has the right type) and setting `Parent` last.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Create` |
| Exposes | `I.Create` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The factory |
| `Scripts/PropertyIndex.lua` | A class's properties |
| `Scripts/ValueMatchesProperty.lua` | Whether a value fits a property's type |
| `_meta/_types.lua` | Property info |

## API

`I.Create(className: string)` returns a factory: `(properties: { [string]: any }, attributes: { [string]: any }?) -> Instance`. An unknown or read-only property, or a value of the wrong type, errors.

## Usage

```lua
local folder = I.Create("Folder")({ Name = "Remotes", Parent = script.Parent }, { Ume_Unprotected = true })
```

## Types

In `_meta/_types.lua`: `Create_PropertyInfo`, `Create_Factory`.
