# DoEvery

Shared timers. `I.DoEvery.Get(seconds)` returns one signal per interval that fires every that many seconds, driven by a single Heartbeat connection, so modules that tick on the same interval share it instead of each running a loop.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume/DoEvery` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.DoEvery` |
| Uses | `RunService.Heartbeat`, `I.Signal`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The interval → signal registry and the Heartbeat loop that fires them, started once the framework has started |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `doevery` / `s_doevery` commands |
| `_meta/_types.lua` | `DoEvery_EventTable` |

## API

### Global: `I.DoEvery`

| Function | Returns | What it does |
| --- | --- | --- |
| `Every(interval: number, callback: (elapsed, ticks) -> (), phase: number?)` | `Signal_Connection?` | Connects `callback` to that interval's signal, each call in a `pcall` that warns on error. |
| `Get(interval: number, phase: number?)` | `Signal?` | The signal for that interval in seconds (and phase), created on first use. Warns and returns `nil` for a non-number, an interval ≤ 0, or a phase outside 0 to below `interval`. |

Each signal fires with `(elapsed: number, ticks: number)`: the real seconds since it last fired, and how many intervals passed. The loop adds each frame's time to every interval and fires its signal once when the interval has passed, keeping the remainder, so signals don't drift. After a long frame it fires once with `ticks` above 1 instead of firing on several frames in a row; code that counts time multiplies by `ticks` (Playtime_Controller does). `phase` shifts a signal's ticks by that many seconds, so heavy per-interval work can run on a different frame from other modules on the same interval.

## Usage

```lua
-- Module.Start, or a Main Loop
I.DoEvery.Get(1):Connect(Module._tick)

-- Counting time: use ticks so a long frame adds every missed second
I.DoEvery.Every(1, function(_elapsed: number, ticks: number)
	Module._addPlaytime(ticks)
end, 0.5)
```

## Commands

`doevery` (client) and `s_doevery` (server):

| Subcommand | Arguments |
| --- | --- |
| `trigger` | `interval` (one that has a signal, as `1` or `1@0.5` with a phase): fires it now with `ticks` 1 |
