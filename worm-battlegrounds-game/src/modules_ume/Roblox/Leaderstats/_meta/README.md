# Leaderstats

The values in Roblox's player list. Every player gets a `leaderstats` folder when they join; modules add, set and remove values in it by name. A value's optional priority (a `Priority` NumberValue inside it) puts higher-priority values earlier in the list.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Leaderstats` |
| Runs on | Server |
| Exposes | `I.Leaderstats` (server) |
| Uses | `I.G_Player`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The `leaderstats` folder per player, adding, setting and removing values |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `leaderstats` command |

## API

### Server: `I.Leaderstats`

| Function | Returns | What it does |
| --- | --- | --- |
| `AddValue(player, valueName: string, baseValue: string \| number, valueClass: "StringValue" \| "NumberValue" \| "IntValue", priority: number?)` | `boolean` | Adds a value; `false` when it already exists |
| `SetValue(player, valueName, value: string \| number)` | `boolean` | Changes an existing value |
| `RemoveValue(player, valueName)` | `boolean` | Removes it |

Values are coerced to the class: a `StringValue` takes `tostring(value)`, a `NumberValue` and an `IntValue` take `tonumber(value)` (`false` when that fails). An `IntValue` floors the number and caps it to the 64-bit range it can hold (about ±9.2e18; NaN is refused), so a big currency should use a `StringValue`.

## Usage

```lua
-- OnPlayerAdded
I.Leaderstats.AddValue(player, "Cash", "0", "StringValue", 10)
I.Leaderstats.SetValue(player, "Cash", cash)
```

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `leaderstats` (Folder) | each `Player` | The player-list values; each may hold a `Priority` NumberValue |

## Commands

`leaderstats` (server):

| Subcommand | Arguments |
| --- | --- |
| `add_value` | `player valueName baseValue valueClass` |
| `remove_value` | `player valueName` |
| `set_value` | `player valueName value` |
