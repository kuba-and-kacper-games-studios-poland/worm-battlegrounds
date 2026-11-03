# Notify

Toasts on the player's screen: short **notifications** (a message with an optional gradient and sound) and **messages** from a user (avatar, name in their colour, text). Both stack up to a display limit and fade after their duration; a notification repeated while it is still on screen adds to its counter (`Coins collected x3`) and restarts its timer instead of showing another toast. Message text and names are escaped, so `<`, `>` and `&` show as typed instead of breaking the rich text. The client shows them; the server sends them to one player or to everyone, and filters text a player wrote (`ShowUserMessage`, `FilterText`) before others see it.

| | |
| --- | --- |
| Folder | `src/modules/Main/Notify` |
| Runs on | Client, Server |
| Exposes | `I.Notify` (client, server) |
| Uses | `I.UserInterface` (the `Notify` gui), `I.Gradient`, `I.Sound`, `I.RichText`, `I.Network`, `TextService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Building, stacking and removing toasts |
| `Server.lua` | Sends toasts to a player or everyone, filters player-written text |
| `Settings.lua` | Durations, sounds, limits, username colours |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `notify` command |
| `_meta/_types.lua` | `Notify_StackedNotification` (a notification on screen with its counter) |

## API

### Client: `I.Notify`

| Function | Returns | What it does |
| --- | --- | --- |
| `ShowNotification(message: string, gradientId: string?, duration: number?, soundId: string?)` | | Shows a notification toast, or adds to the counter of the same message still on screen |
| `ShowMessage(userId: number, username: string, message: string, duration: number?, soundId: string?)` | | Shows a user message toast |

### Server: `I.Notify`

`ShowNotification` and `ShowMessage` are the same with a `player` first; `nil` sends to every player. They send the text as given: text a player typed goes through `ShowUserMessage` or `FilterText`.

| Function | Returns | What it does |
| --- | --- | --- |
| `ShowNotification(player: Player?, message, gradientId?, duration?, soundId?)` | | |
| `ShowMessage(player: Player?, userId, username, message, duration?, soundId?)` | | |
| `ShowUserMessage(sender: Player, text: string, target: Player?, duration: number?, soundId: string?)` | `boolean` | Filters `text` for broadcast as `sender`, then shows it as their message to `target` (or everyone); `false` and nothing shown when filtering fails |
| `FilterText(sender: Player, text: string)` | `string?` | `text` filtered by Roblox for everyone to see (`TextService:FilterStringAsync`, `GetNonChatStringForBroadcastAsync`); `nil` when it fails. `sender` must be in this server |

## Usage

```lua
I.Notify.ShowNotification(player, "Daily reward claimed!", "Gold")
I.Notify.ShowNotification(nil, "Event starts in 5 minutes")
I.Notify.ShowUserMessage(player, typedText)
```

## Network

### Server

**Send: RemoteEvents**

- `Notify_ShowNotification @ (player: Player, message: string, gradientId: string?, duration: number?, soundId: string?)`, or to all players
- `Notify_ShowMessage @ (player: Player, userId: number, username: string, message: string, duration: number?, soundId: string?)`, or to all players

### Client

**Receive: RemoteEvents**

- `Notify_ShowNotification @ (message: string, gradientId: string?, duration: number?, soundId: string?)`
- `Notify_ShowMessage @ (userId: number, username: string, message: string, duration: number?, soundId: string?)`

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_NOTIFICATION_DURATION`, `DEFAULT_NOTIFICATION_SOUND`, `NOTIFICATION_DISPLAY_LIMIT` | `3`, `"Notification"`, `15` | Notifications |
| `DEFAULT_MESSAGE_DURATION`, `DEFAULT_MESSAGE_SOUND`, `MESSAGE_DISPLAY_LIMIT` | `6`, `"Notification"`, `6` | Messages |
| `DEFAULT_USERNAME_COLOR` | grey | Name colour in messages |
| `USERNAME_COLORS` | | Name colour per user id |

## Commands

`notify` (server), permission level 255. Both subcommands filter the typed text as the player who ran them, so they show nothing in a server that player isn't in (including the other servers of a global run).

| Subcommand | Arguments |
| --- | --- |
| `notification` | `[player]`, `message`, `[gradientId]`, `[duration]`, `[soundId]` |
| `message` | `message`, `[duration]`, `[soundId]` |
