# Currency

Player currencies (the game's Coins and Diamonds), saved as BigNum strings in the profile. Only the server writes: `Add`, `Subtract` and `Set` change the saved amount, mirror it into the player's Replicator folder and publish `Currency_Changed`. The client reads those attributes and publishes the same Topic locally, and `Currency_Slot` labels show the amount, with orbs flying in on gains.

| | |
| --- | --- |
| Folder | `src/modules/Main/2_Currency` |
| Runs on | Server, Client, Global |
| Exposes | `I.Currency` (server, client), `I.G_Currency` (both) |
| Uses | `I.Player`, `I.Replicator`, `I.Topic`, `I.BN`, `I.Component`, `I.UserInterface`, `I.UIEmitter` |
| Saves | `Profile.Currency.Currencies` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile template, currency checks, the Replicator folder, `Add` / `Subtract` / `Set` and the server getters |
| `Client.lua` | Reads the Replicator folder, publishes changes as Topics, registers `Currency_Slot` |
| `Global.lua` | `GetCurrencyIcon` |
| `Settings.lua` | One entry per currency in `CURRENCIES` |
| `Components/Slot.lua` | `Currency_Slot`, a TextLabel that shows one currency |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `currency` command |
| `Scripts/AdminPanel/Dashboard/Server.lua` | The Currency sections of every player's page on the admin dashboard |

## API

Amounts are integer strings (`"1500"`, or `tostring(bn)` of a BigNum) everywhere. Lua numbers and scientific or decimal strings (`"2.5e+12"`) are rejected with a warn.

### Server: `I.Currency`

| Function | Returns | What it does |
| --- | --- | --- |
| `Add(player, currencyName: string, amount: string, spawnOrbs: boolean?)` | `boolean` | Adds `amount`, capped at `MaxValue` when `RespectMaxValue`. `spawnOrbs` makes the player's `Currency_Slot` labels fly orbs in. |
| `Subtract(player, currencyName, amount, force: boolean?)` | `boolean` | Takes `amount` away, floored at `MinValue` when `RespectMinValue` (else at 0); never raises a balance that is already below that floor. Without `force`, fails when the player doesn't have enough. |
| `Set(player, currencyName, amount)` | `boolean` | Sets the amount, kept inside the currency's range |
| `Get(player, currencyName)` | `string?` | Current amount |
| `GetTotal` / `GetTotalSpent` / `GetHighestOwned (player, currencyName)` | `string?` | Lifetime earned / spent / highest held |
| `GetAll` / `GetAllTotal` / `GetAllTotalSpent` / `GetAllTotalOwned (player)` | `{ [string]: string }` | The same for every currency |
| `HasEnough(player, currencyName, amount)` | `boolean` | Current amount ≥ `amount` |

### Client: `I.Currency`

The same getters without `player`, read from the local player's Replicator folder: `Get`, `GetTotal`, `GetTotalSpent`, `GetHighestOwned`, `GetAll`, `GetAllTotal`, `GetAllTotalSpent`, `GetAllTotalOwned`, `HasEnough`. The client can't change amounts.

### Global: `I.G_Currency`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetCurrencyIcon(currencyName: string)` | `string?` | The currency's `IconId` |

## Usage

```lua
-- Server: charge for an item
if I.Currency.Subtract(player, "Cash", price) then
	-- give the item
end

-- Client: follow one currency
I.Topic.Subscribe("Currency_Changed-Cash", Module._onCashChanged) -- (amount: string)
```

## Network

No remotes: values reach the client as Replicator attributes.

### Server

**Topics**

- `Currency_Changed @ (player: Player, currencyName: string, amount: string, newAmount: string, delta: string)`: `amount` is the amount passed to `Add` / `Subtract` / `Set`, `newAmount` the saved amount after it, `delta` the change actually applied (signed, after caps and floors; `"0"` when nothing changed). Published when `ServerUpdate` is on.
- `Currency_Changed-{currencyName} @ (player: Player, amount: string, newAmount: string, delta: string)`: the same without `currencyName`. Registered and published only when `ServerUpdateIndividual` is on.

### Client

**Topics**

- `Currency_Changed @ (currencyName: string, amount: string)`: `amount` is the new total. Published when `ClientUpdate` is on.
- `Currency_Changed-{currencyName} @ (amount: string)`: only when `ClientUpdateIndividual` is on.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Currency.Currencies[name]` | `{ Amount, TotalEarned, TotalSpent, HighestOwned }` (`Currency_CurrencyData`) |
| Replicator `Currency` folder | `{name}` | Current amount |
| | `{name}-Total` / `{name}-TotalSpent` / `{name}-HighestOwned` | Lifetime earned / spent / highest held |
| | `{name}-SpawnOrbs` | A random number written by `Add(…, true)`; `Currency_Slot` flies orbs in when it changes |

Attributes are written only for currencies with `ClientUpdate` on, through `I.Replicator.Set`.

On join, a saved field that holds a whole number as a Lua number or a scientific string (`1500`, `"2.5e+12"`) is rewritten as the same integer string. Any other value that isn't an integer string is reset to its default (`DefaultValue`, or `"0"` for `TotalEarned` / `TotalSpent`), with a warn that shows the old value. `Amount` is then kept inside the currency's range.

## Settings

`CURRENCIES[name]` (`Currency_CurrencySettings`):

| Key | Coins / Diamonds | What |
| --- | --- | --- |
| `DefaultValue` | `"0"` | Amount a new player starts with |
| `IconId` | the local coin and diamond icons (`rbxasset://textures/wb_guipreview/…`) | Returned by `GetCurrencyIcon` |
| `MinValue`, `RespectMinValue` | `"0"`, `true` | Floor, and whether it's enforced |
| `MaxValue`, `RespectMaxValue` | `"0"`, `false` | Cap, and whether it's enforced |
| `ServerUpdate`, `ServerUpdateIndividual` | `true`, `false` | Server Topics (see Network) |
| `ClientUpdate`, `ClientUpdateIndividual` | `true`, `true` | Replicator attributes and client Topics |

## Components

### `Currency_Slot` (`Components/Slot.lua`)

Shows one currency on a label and tweens it to each new amount. Copies in `StarterGui` and `ReplicatedStorage` get no
component (`IgnoreAncestors`), only the live ones in `PlayerGui`. With `SpawnOrbs`, gains fly in as orbs and the label pulses.

| | |
| --- | --- |
| Tag on | `TextLabel` |
| Side | Client (`RegisterOnLoaded`) |
| Needs | The `Currency` ScreenGui with a `U_OrbsContainer`, only when `SpawnOrbs` is on |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Currency_Name` | string | `""` | Which currency (a key of `CURRENCIES`) |
| `Currency_CustomFormat` | string | `""` | `string.format` pattern for the shown value, e.g. `"$%s"`; empty uses the plain value |
| `Currency_ShortFrom` | number | `0` | Abbreviates from this amount up (`18.6k`, `1.24m`); `0` abbreviates only past 15 digits and writes the rest in full with commas |
| `Currency_SpawnOrbs` | boolean | `false` | Fly orbs in on `Add(…, true)` |

| ObjectValue child | Points to | What |
| --- | --- | --- |
| `Currency_UIScale` | `UIScale` | Pulsed while orbs arrive: the slot eases it every frame only until it settles, so an idle slot runs nothing |

## Commands

`currency` (server):

| Subcommand | Arguments |
| --- | --- |
| `add` | `player currencyName amount [spawnOrbs]` |
| `subtract`, `set` | `player currencyName amount` |
| `get`, `get_total`, `get_total_spent`, `get_highest_owned` | `player currencyName [formatting]` |
| `get_all`, `get_all_total`, `get_all_total_spent`, `get_all_total_owned` | `player [formatting]` |
| `has_enough` | `player currencyName amount` |

## Dashboard

A Player panel, `Currency` (level 255), on the AdminPanel's dashboard: two sections on every player's page.

| Section | Blocks |
| --- | --- |
| Currency | One Info per currency in `CURRENCIES` (sorted): the player's amount (`I.Currency.Get`) |
| Add currency | One Input per currency, `Add <Currency>`: adds the typed amount to the player (`I.Currency.Add`) |
