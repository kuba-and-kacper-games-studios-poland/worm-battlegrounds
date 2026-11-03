# Friends_Controller

The friends-in-server bonus. When a player's in-server friend count changes, the server works out their bonus, `BONUS_PER_FRIEND` per friend up to `MAX_BONUS`. The framework doesn't apply it: each game applies it at the `#TODO` in `Server.lua` (a currency multiplier or anything else). The client shows the same bonus, from the replicated friend count and the same settings, on every `Friends_Controller_BoostText` label.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Friends_Controller` |
| Runs on | Server, Client |
| Exposes | `I.Friends_Controller` (client) |
| Uses | `I.Friends` (counts, `Friends_DataUpdated`), `I.Replicator`, `I.Component` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Works out each player's friends bonus when their friend count changes; the game applies it at the `#TODO` |
| `Client.lua` | Works out the shown bonus and publishes it |
| `Settings.lua` | Bonus per friend and its cap |
| `Components/BoostText.lua` | `Friends_Controller_BoostText`, a label that shows the bonus |

## API

### Client: `I.Friends_Controller`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetBoostText()` | `string` | The bonus as the labels show it (`+20%`) |

## Network

No remotes: the client reads the friend count from the Replicator `Friends` folder.

### Client

**Topics**

- `Friends_Controller_BoostChanged @ (boostText: string)`: after the shown bonus was worked out again.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `BONUS_PER_FRIEND` | `0.1` | Bonus per friend in the server (`0.1` = 10%) |
| `MAX_BONUS` | `1` | Highest friends bonus (`1` = 100%) |

## Components

### `Friends_Controller_BoostText` (`Components/BoostText.lua`)

Shows the friends bonus, and follows `Friends_Controller_BoostChanged`, so labels added later (guis, cloned cards, streamed parts) show it too.

| | |
| --- | --- |
| Tag on | `TextLabel` |
| Side | Client (`RegisterOnLoaded`) |
