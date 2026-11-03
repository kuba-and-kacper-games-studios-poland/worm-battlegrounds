# AFKTeleport

The warning an idle player sees before ume's AFKTeleport module moves them to the lobby: a panel in the middle of the screen that counts down the seconds left and tells the player that any input keeps them in the server. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves, so no theme changes it, in BackpackPlus's look (`System/BackpackPlus`): a dark gradient panel with 12 px corners, a 3 px black outline and a white highlight fading down from its top edge, Source Sans text outlined in black, and the seconds in BackpackPlus's orange to yellow. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/AFKTeleport"` |
| Modes | Night only: its values are its own, the same in any mode |
| Devices | Desktop: no platform rules, the same panel on every device |
| Export | A ScreenGui named `AFKTeleport` in StarterGui, `Enabled = false`, `DisplayOrder = 10`, `ScreenInsets` `DeviceSafeInsets` |

To restyle it in a game, copy it into the game's own folders and change the values there, keeping its `Name` and Ids.

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Warning` | Frame | The panel, 22% of the screen at most and twice as wide as tall, centred: a title, the seconds left, what happens when they run out, and how to stay, 12 px in from the sides |
| `U_Warning` › `S_Time` | TextLabel (Source Sans Heavy, orange to yellow) | The seconds left before the teleport request; AFKTeleport writes the number |

## Driven by

ume's AFKTeleport module (`src/modules/Utils/AFKTeleport/Client.lua`) finds the exported gui as `I.UserInterface.UI["AFKTeleport"]` and `U_Warning` › `S_Time` inside it. It enables the ScreenGui for the last `WARNING_TIME` seconds before the idle player's teleport request, writes the seconds left into `S_Time` every timer tick, and disables it again on any input.

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `AFKTeleport`, disabled. A restyled copy keeps its `Name`, `U_Warning` and `S_Time`.
2. ume module: `Utils/AFKTeleport` (the client shows the warning, the server sends the idle player to the lobby). Its settings set the timing: `TELEPORT_REQUEST_TIME` (16 minutes idle), `WARNING_TIME` (the warning's last 30 seconds), `TIMER_INTERVAL` (1 s ticks), `TELEPORT_RETRY_TIME`.

### Input

| What | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Stay in the server | Any input | Any touch | Any button | AFKTeleport `Client.lua`: any input hides the warning and restarts the idle timer |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Shown | The ScreenGui | `Enabled` for the last `WARNING_TIME` seconds; no tween |
| The panel | `U_Warning` | Black `UIGradient` at 0.35 transparency, 12 px corners, a 3 px black `UIStroke` and a white highlight stroke fading down from the top |
| The seconds | `S_Time` | `UIGradient` `Color3.fromRGB(255, 115, 0)` to `Color3.fromRGB(255, 213, 0)`, rotation -90; AFKTeleport rewrites the number every tick |
