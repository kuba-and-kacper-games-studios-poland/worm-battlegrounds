# Buff

Stackable modifiers. A buff (WalkSpeed, JumpHeight, FOV, a game's own) is a set of named values combined into one sum (added by default, or multiplied, or the largest, per the buff's `Mode`); modules set their own value under their own name (`"Pet"`, `"Gamepass"`) and read the sum, so several sources stack without knowing about each other. Server buffs are per player and kept for the session; client buffs are local. Buffs are defined in `src/global_data/Buff/Buff.lua`.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume_Data/Buff` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Buff` (both) |
| Uses | `I.Player` (session data), `I.Replicator`, `I.Topic`, `I.Network`, `I.BN`, `I.Table`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Buff entries and their checks, setting values (timed or not), combining, the once-a-second sweep of expired timed values, Topics, the Replicator folder, the debug remotes |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `buff` / `s_buff` commands |
| `_meta/_types.lua` | `Buff_BuffData` (a definition), `Buff_BuffTable` (values and sum), `Buff_State` (a player's or the client's buffs) |

## API

On the server every function takes the `player` as its last argument; on the client it is left out.

### Global: `I.Buff`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(buffName: string, valueName: string, value: number \| string \| nil, player: Player?)` | `boolean` | Sets one source's value and recalculates the sum. `nil` removes the value; the `Standard` value resets to the buff's default instead. A number buff takes numbers, a string buff takes integer strings (BigNum). |
| `SetTimed(buffName, valueName, value: number \| string, duration: number, player?)` | `boolean` | `Set` for the session only, removed again after `duration` seconds (checked once a second). Setting the same value again, timed or not, replaces its duration. |
| `Recalculate(buffName, player?)` | | Combines the buff again and publishes it |
| `RecalculateAll(player?)` | | The same for every buff |
| `GetSum(buffName, player?)` | `number \| string \| nil` | The buff's total |
| `GetValue(buffName, valueName, player?)` | `number \| string \| nil` | One source's value |
| `GetValues(buffName, player?)` | `{ [string]: number \| string }?` | Every source's value |
| `GetAll(player?)` | `{ [string]: Buff_BuffTable }` | Every buff, values and sum |
| `GetAllSums(player?)` | `{ [string]: number \| string }` | Every buff's sum |
| `GetAllValues(player?)` | `{ [string]: { [string]: number \| string } }` | Every buff's values |

A buff whose default is a number combines as numbers; one whose default is a string combines as BigNum strings. At start, a definition whose `DefaultValue` is neither a number nor an integer string, or whose `Mode` isn't `Add`, `Multiply` or `Max`, errors.

## Usage

```lua
-- Server: a gamepass adds 8 walk speed
I.Buff.Set("WalkSpeed", "Gamepass", 8, player)

-- Server: a potion adds 4 for 30 seconds
I.Buff.SetTimed("WalkSpeed", "Potion", 4, 30, player)
local speed = I.Buff.GetSum("WalkSpeed", player)

-- Client: react to the local FOV buff
I.Topic.Subscribe("Buff_Updated-FOV", Module._onFovChanged) -- (sum: number | string)
```

## Network

### Server

**Topics**

- `Buff_Updated @ (player: Player, buffName: string, sum: string | number)`: after a recalculation, for buffs with `ServerUpdate`.
- `Buff_Updated-{buffName} @ (player: Player, sum: string | number)`: for buffs with `ServerUpdateIndividual`.

**Receive: RemoteFunctions**

- `Buff_GetSum @ (player: Player, buffName: string)`, `Buff_GetValue @ (player: Player, buffName: string, valueName: string)`, `Buff_GetValues @ (player: Player, buffName: string)`, `Buff_GetAll @ (player: Player)`, `Buff_GetAllSums @ (player: Player)`, `Buff_GetAllValues @ (player: Player)`: the server's buffs for the asking player (used by the `buff` command). Answer only players with command permission 255; anyone else gets `nil`.

**Send: RemoteFunctions**

- `Buff_Set @ (player: Player, buffName: string, valueName: string, amount: number | string?)` and the six `Buff_Get*` functions: read or change a client's local buffs (used by the `s_buff from_client` command).

### Client

**Topics**

- `Buff_Updated @ (buffName: string, sum: string | number)`: for buffs with `ClientUpdate`.
- `Buff_Updated-{buffName} @ (sum: string | number)`: for buffs with `ClientUpdateIndividual`.

These fire only for the client's own buffs. A buff the server sets reaches the client as an attribute on the
player's Replicator `Buff` folder (with `ClientUpdate`, Data below): follow it with that folder's `AttributeChanged`.

**Receive: RemoteFunctions**

- `Buff_Set @ (buffName: string, valueName: string, amount: number | string?)`, `Buff_GetSum @ (buffName: string)`, `Buff_GetValue @ (buffName: string, valueName: string)`, `Buff_GetValues @ (buffName: string)`, `Buff_GetAll @ ()`, `Buff_GetAllSums @ ()`, `Buff_GetAllValues @ ()`

**Send: RemoteFunctions**

- The six `Buff_Get*` functions, from the `buff` command.

## Data

| Where | Key | What |
| --- | --- | --- |
| Session | `Buff.Current[buffName]` | `{ Values, Sum }` (`Buff_BuffTable`); not saved |
| Session | `Buff.Expiry[buffName][valueName]` | When a timed value is removed (`os.clock`); not saved |
| Replicator `Buff` folder | `{buffName}` | The server buff's sum, for buffs with `ClientUpdate` |
| `src/global_data/Buff/Buff.lua` | `Server[buffName]`, `Client[buffName]` | Definitions: `DefaultValue` (its type decides number or BigNum), `Mode` (`Add` by default, `Multiply`, `Max`), `ServerUpdate`, `ServerUpdateIndividual`, `ClientUpdate`, `ClientUpdateIndividual` |

## Commands

`buff` (client) and `s_buff` (server):

| Subcommand | Arguments |
| --- | --- |
| `set` | `buffName valueName [value]` |
| `get_sum`, `get_values` | `buffName [formatting]` |
| `get_value` | `buffName valueName [formatting]` |
| `get_all`, `get_all_sums`, `get_all_values` | `[formatting]` |
| `from_client` | (`s_buff` only) the same subcommands, run on that player's client |

`s_buff` takes a `player` before the other arguments. The server keeps its value-name autocomplete current only in Studio, so a live server doesn't rebuild a command dictionary on every `Set`; there `valueName` can be typed freely.
