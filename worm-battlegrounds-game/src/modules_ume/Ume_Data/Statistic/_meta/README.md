# Statistic

Saved per-player counters (Playtime by default), stored as BigNum strings in the profile, with an optional floor and cap. Other modules add to them and read them; the client sees the ones marked `ClientUpdate` through the Replicator. Statistics are defined in `src/global_data/Statistic/Statistic.lua`.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume_Data/Statistic` |
| Runs on | Server |
| Exposes | `I.Statistic` (server) |
| Uses | `I.Player`, `I.Replicator`, `I.Topic`, `I.BN`, `I.AdminPanel_CommandBar` |
| Saves | `Profile.Statistic.Standard` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile template, the Replicator folder, `Add` / `Subtract` / `Set` / `Get` |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `statistic` command |
| `_meta/_types.lua` | `Statistic_Statistic` (a definition) |

## API

### Server: `I.Statistic`

| Function | Returns | What it does |
| --- | --- | --- |
| `Add(player, statisticName: string, amount: string, sensitiveCap: boolean?)` | `boolean` | Adds `amount`. Past `MaxValue` (when `RespectMaxValue`) it adds up to the cap, or fails with `sensitiveCap`. |
| `Subtract(player, statisticName, amount, sensitiveCap: boolean?)` | `boolean` | Takes `amount` away, the same way against `MinValue` |
| `Set(player, statisticName, amount, sensitiveCap: boolean?)` | `boolean` | Sets the value, kept inside the range (or fails with `sensitiveCap`) |
| `Get(player, statisticName)` | `string?` | The value |
| `GetAll(player)` | `{ [string]: string }?` | A copy of every statistic |

## Usage

```lua
I.Statistic.Add(player, "Playtime", "60")
```

## Network

No remotes: values reach the client as Replicator attributes.

### Server

**Topics**

- `Statistic_Updated @ (player: Player, statisticName: string, value: string, amount: string)`: after a change, for statistics with `ServerUpdate`; `value` is the new value, `amount` the change after capping. `Add` and `Subtract` publish the amount added or taken away (never negative); `Set` publishes the signed difference, negative when the value went down.
- `Statistic_Updated-{statisticName} @ (player: Player, value: string, amount: string)`: for statistics with `ServerUpdateIndividual`.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Statistic.Standard[statisticName]` | The value, a BigNum string |
| Replicator `Statistic` folder | `{statisticName}` | The value, for statistics with `ClientUpdate` |
| `src/global_data/Statistic/Statistic.lua` | `[statisticName]` | `DefaultValue`, `MinValue` / `RespectMinValue`, `MaxValue` / `RespectMaxValue`, `ServerUpdate`, `ServerUpdateIndividual`, `ClientUpdate` |

The rows are checked when the module initializes, which errors when `DefaultValue` (or a respected `MinValue` / `MaxValue`) isn't an integer string, when a respected `MinValue` is above a respected `MaxValue`, or when a `ClientUpdate` statistic's name isn't a valid attribute name (letters, digits and `_`, at most 100 characters, not starting with `RBX`).

## Commands

`statistic` (server):

| Subcommand | Arguments |
| --- | --- |
| `add`, `subtract` | `player statName amount [sensitiveCap]` |
| `set` | `player statName amount [sensitiveCap]` |
| `get` | `player statName [formatting]` |
| `getAll` | `player [formatting]` |
