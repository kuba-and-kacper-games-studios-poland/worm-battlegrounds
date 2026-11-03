# Debounce

Named cooldowns. `Run` starts a cooldown and says whether one was already running, so a guard is one line. A cooldown is local (this script's side, any key) or, on the server, per player for the session. All cooldowns are timed with `os.clock` and end when the server (or client) does.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Debounce` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Debounce` (both) |
| Uses | `I.Player` (session), `I.DoEvery`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The local and session cooldown stores, `Run` / `Clear` / `IsActive` / `GetTime`, a loop that clears ended local cooldowns |
| `Settings.lua` | How often ended local cooldowns are cleared |

## API

### Global: `I.Debounce`

`debounceName` can be any value; it is turned into a string. On the server, passing a `player` stores the cooldown in that player's session; without one, and on the client, it is local. On the server, a passed `player` that isn't valid (data not loaded yet, or left) fails closed: `Run` and `IsActive` return `true` and nothing is stored.

| Function | Returns | What it does |
| --- | --- | --- |
| `Run(debounceName, delay: number, player: Player?)` | `boolean`, `number` | `true` and the seconds left when the cooldown was already running (nothing changes); otherwise starts it for `delay` seconds and returns `false, 0` |
| `Clear(debounceName, player?)` | | Ends the cooldown early, e.g. to refund it when the guarded action failed |
| `IsActive(debounceName, player?)` | `boolean` | Whether the cooldown is running |
| `GetTime(debounceName, player?)` | `number` | Seconds left, `0` when it isn't running (or the player isn't valid) |

## Usage

```lua
-- Server: one claim per 5 seconds, with a message when it's too soon
local isActive: boolean
local timeLeft: number
isActive, timeLeft = I.Debounce.Run("Claim", 5, player)
if isActive then
	return false, `Try again in {math.ceil(timeLeft)}s`
end

-- Refund the cooldown when the claim failed
I.Debounce.Clear("Claim", player)
```

## Network

### Server

**Receive: RemoteFunctions**

- `Debounce_IsActive @ (player: Player, debounceName: string)`, `Debounce_GetTime @ (player: Player, debounceName: string)`: a client asking about its own session cooldowns (`I.Network.Invoke`).

## Data

| Where | Key | What |
| --- | --- | --- |
| Session | `Debounce.Active[debounceName]` | End time (`os.clock`) of a session cooldown |
| Profile | `Debounce.Active` | Still stamped on the profile template so saved profiles keep their shape; nothing reads or writes it since global cooldowns were removed |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `INACTIVE_CLEAR_DELAY` | `60` | Seconds between sweeps that remove ended local cooldowns |
