# Platform

Which device each player is on: `Desktop`, `Mobile`, `Console` or `VR`. The client works it out from the last input it saw (checked every `INPUT_CHECK_DELAY` seconds), keeps it in `I.Platform.Current` and the last kind of input in `I.Platform.LastInput`, and tells the server its platform once the player has loaded and again on every change. The server keeps the last reported platform of each player, republishes changes, and answers `I.Platform.Get` from it without asking the client.

The server's value is reported by the client, so an exploiter can send any listed platform. Use it only for presentation (layouts, tutorials, analytics), never for gameplay rules such as aim assist, matchmaking pools or rewards.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Platform` |
| Runs on | Client, Server |
| Exposes | `I.Platform` (client, server) |
| Uses | `UserInputService`, `I.DoEvery`, `I.Topic`, `I.Network`, `I.Player`, `I.G_Player` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Detecting the platform from input, `Current`, `LastInput`, reporting the platform |
| `Server.lua` | Each player's last reported platform, republishing changes, `Get` |
| `Settings.lua` | The platform names and the check interval |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `platform` command |

## API

### Client: `I.Platform`

| Field | Type | What it is |
| --- | --- | --- |
| `Current` | `"Desktop" \| "Mobile" \| "Console" \| "VR"` | The local player's platform, kept up to date |
| `LastInput` | `"Keyboard" \| "Touchscreen" \| "Gamepad"` | The kind of input used last (mouse counts as `Keyboard`); `"Keyboard"` until the first input |

### Server: `I.Platform`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(player)` | `"Desktop" \| "Mobile" \| "Console" \| "VR"` | The platform the player's client last reported (doesn't yield); `"Desktop"` until it has reported one |

## Usage

```lua
-- Client
if I.Platform.Current == "Console" then ... end
I.Topic.Subscribe("Platform_Changed", Module._onPlatformChanged) -- (platform: string)
I.Topic.Subscribe("Platform_InputChanged", Module._refreshGlyphs) -- (lastInput: string)

-- Server
local platform: string = I.Platform.Get(player)
```

## Network

### Server

**Topics**

- `Platform_Changed @ (player: Player, platform: string)`: a loaded player's reported platform changed, their first report after loading included.

**Receive: RemoteEvents**

- `Platform_Changed @ (player: Player, platform: string)`: the client's platform. At most 5 calls per second per player; ignored until the player is loaded, and when the platform isn't listed or didn't change.

### Client

**Topics**

- `Platform_Changed @ (platform: string)`: the platform changed, and once more after the player loaded.
- `Platform_InputChanged @ (lastInput: string)`: `LastInput` changed.

**Send: RemoteEvents**

- `Platform_Changed @ (platform: string)`: once after the player loaded (`I.OnLoaded` at `I.Priority.Setup`), then on every change.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PLATFORMS` | `VR`, `Console`, `Mobile`, `Desktop` | Every platform name |
| `INPUT_CHECK_DELAY` | `5` | Seconds between checks of the last input |

## Commands

`platform` (server):

| Subcommand | Arguments |
| --- | --- |
| `get` | `player` |
| `get_all` | |
