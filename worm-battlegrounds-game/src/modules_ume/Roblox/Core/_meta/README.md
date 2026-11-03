# Core

Retrying `StarterGui` core calls on the client. Calls such as `SetCore("ResetButtonCallback", …)` fail until the CoreScripts are ready; `I.Core.Call` keeps retrying one call in its own thread until it works, so modules can call it from `Init`. It retries every frame for the first few seconds, then every half second, and gives up with a warning after a minute.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Core` |
| Runs on | Client |
| Exposes | `I.Core` (client) |
| Uses | `StarterGui`, `RunService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | `Call` and its retry loop |
| `Settings.lua` | How long and how often a call retries, and whether failures are logged |

## API

### Client: `I.Core`

| Function | Returns | What it does |
| --- | --- | --- |
| `Call(method: string, ...)` | | Calls `StarterGui[method](StarterGui, ...)` in a new thread, retrying until it succeeds: every Heartbeat for `FAST_RETRY_SECONDS`, then every `SLOW_RETRY_INTERVAL` seconds. After `MAX_RETRY_SECONDS` it warns with the last error and stops. Doesn't return the call's result. |

## Usage

```lua
I.Core.Call("SetCoreGuiEnabled", Enum.CoreGuiType.Backpack, false)
I.Core.Call("SetCore", "ResetButtonCallback", false)
```

## Settings

| Key | Default | What |
| --- | --- | --- |
| `FAST_RETRY_SECONDS` | `5` | Seconds a failing call retries every frame |
| `SLOW_RETRY_INTERVAL` | `0.5` | Seconds between retries after that |
| `MAX_RETRY_SECONDS` | `60` | Seconds before a call that never succeeded gives up |
| `FAILED_CALL_LOG` | `true` | Print the first failure of each call, in Studio only |
