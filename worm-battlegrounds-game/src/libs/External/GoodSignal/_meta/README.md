# GoodSignal

A fast Lua signal (stravant's GoodSignal): connect, fire, wait, once. Topic, DoEvery and Component use it.

| | |
| --- | --- |
| Folder | `src/libs/External/GoodSignal` |
| Exposes | `I.Signal` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Signal and Connection |
| `_meta/_types.lua` | `Signal`, `Signal_Connection` |

## API

### Signal

| Function | Returns | What it does |
| --- | --- | --- |
| `Signal.new()` | `Signal` | Returns a new signal metatable. |
| `Signal:Connect(callback: (...any) -> ())` | `Signal_Connection` | Connects function to execute when the signal is fired. |
| `Signal:DisconnectAll()` |  | Disconnects all connections from signal. |
| `Signal:Fire(...: any)` |  | Fires signal with any amount of params. |
| `Signal:Wait()` |  | Halts current thread until the signal is fired. |
| `Signal:Once(callback: (...any) -> ())` | `Signal_Connection` | Fires given function once and disconnects it. |

### Connection

| Function | Returns | What it does |
| --- | --- | --- |
| `connection:Disconnect()` |  | Unhook connection from the signal. Idempotent - repeated calls are a no-op. |

## Usage

```lua
local changed = I.Signal.new()
changed:Connect(print)
changed:Fire("hello")
```

## Types

In `_meta/_types.lua`: `Signal_Connection`, `Signal`.
