# WidgetManager

One menu at a time. Every full-screen widget (a `ScreenGui` from `I.UserInterface`) opens through WidgetManager: opening one closes the current one, a queue holds widgets waiting for their turn, and opening plays a tween preset and the `Window_Open` sound (UI group) while the background blurs, dims and widens its field of view. It also has two utility widgets, a message and a confirmation dialog; they queue behind each other instead of replacing the one on screen. The server can drive a player's widgets through its own `I.WidgetManager`.

| | |
| --- | --- |
| Folder | `src/modules/Main/WidgetManager` |
| Runs on | Client, Server |
| Exposes | `I.WidgetManager` (client, server) |
| Uses | `I.UserInterface`, `I.Lighting` (blur), `I.Buff` (the `FOV` buff), `I.Topic`, `I.Network`, `I.DoEvery`, `I.Component`, `I.Interact` (the utility widgets' buttons) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Opening (with its sound), closing, the queue, tweens, blur and field of view, `I.WidgetManager` |
| `Server.lua` | Creates the remotes the server uses to drive a client, and the server `I.WidgetManager` that fires them |
| `Settings.lua` | Utility widgets, field of view, blur and dim |
| `Data/TweenPresets.lua` | Open tweens by name (`Default`, `Rise`) |
| `Scripts/MessageWidget.lua` | The `WidgetManager_Message` widget |
| `Scripts/ConfirmationWidget.lua` | The `WidgetManager_Confirmation` widget |
| `Scripts/UtilityQueue.lua` | The first-in, first-out queue of messages and confirmations waiting for the one on screen |
| `Scripts/Dim.lua` | The background dim |
| `Components/TogglePart.lua` | Opens a widget while the player stands in a part |
| `Scripts/AdminPanel/CommandBar/Server.lua`, `Client.lua` | The `widget_manager` command and its dictionaries |
| `_meta/_types.lua` | Tween presets, confirmation callback, the handlers' context |

## API

### Client: `I.WidgetManager`

`widgetName` is a gui name in `I.UserInterface.UI`; `tweenName` a `Data/TweenPresets` name. Left out, the widget's own tween plays: the `WidgetManager_Tween` attribute on its `U_Widget`, else `"Default"`.

| Function | Returns | What it does |
| --- | --- | --- |
| `Open(widgetName: string, tweenName: string?)` | `boolean` | Closes the current widget and opens this one with its tween |
| `OpenQueue(widgetName, tweenName?)` | `boolean` | Opens it, or queues it until the current one closes |
| `Toggle(widgetName, tweenName?)` | `boolean` | Opens or closes it |
| `Close(widgetName)` | `boolean` | Closes it, then opens the next queued widget |
| `CloseCurrent()` | `boolean` | Closes whatever is open |
| `OpenPreviouslyOpened()` | `boolean` | Reopens the widget a utility widget replaced, or closes the current one |
| `GetCurrent()` | `ScreenGui?` | The open widget |
| `ShowMessage(message: string)` | `boolean` | Opens the message widget with that text, or queues it behind the message or confirmation on screen; `false` when the widget is missing or couldn't open |
| `ShowConfirmation(message: string, onAccept: WidgetManager_ConfirmationCallback?, onDecline: WidgetManager_ConfirmationCallback?)` | `boolean` | The same for the confirmation widget; `onAccept` runs on Accept, `onDecline` on Decline or when the widget closes any other way (another widget opening, `Close`, `CloseCurrent`) |

A widget is a gui whose frame named `U_Widget` WidgetManager tweens in and out; the `widget_manager` command lists only guis that have one. A `U_Widget` can name the tween it opens with in a `WidgetManager_Tween` attribute (the Upgrades widget rises with `Rise`), so it plays however the widget is opened. A widget with a `PreventClosing` attribute set to `true` isn't closed by another opening.

Messages and confirmations show one at a time, in the order they were asked for: Accept or Decline shows the next one, and the widget they replaced comes back after the last. When one is closed some other way, the next one shows a frame later, over whatever is open then. A confirmation's callbacks run on the client only: when Accept leads to a server action (a purchase, a sale), the server still checks the cost and ownership itself.

The message's OK button and the confirmation's Accept and Decline buttons answer through `I.Interact.OnPress`: a click, or the key the gui gives the button (`Utils_ButtonKey`), does the same. UmeGui's System widgets give A (Cross) to OK and Accept, X (Square) to Decline, and B (Circle) to the close button, whose `Interact_Button` calls `CloseCurrent`.

### Server: `I.WidgetManager`

Each call fires the matching remote to that player's client and returns nothing; the client decides whether it opens.

| Function | Returns | What it does |
| --- | --- | --- |
| `Toggle(player, widgetName, tweenName?)` | | Client `Toggle` |
| `Open(player, widgetName, tweenName?)` | | Client `Open` |
| `OpenQueue(player, widgetName, tweenName?)` | | Client `OpenQueue` |
| `Close(player, widgetName)` | | Client `Close` |
| `CloseCurrent(player)` | | Client `CloseCurrent` |
| `ShowMessage(player, message)` | | Client `ShowMessage` |

## Usage

```lua
I.WidgetManager.Open("Shop")
I.WidgetManager.ShowConfirmation("Sell all items?", Module._sellAll, Module._keepItems)

-- Server
I.WidgetManager.Open(player, "Shop")
```

## Network

### Server

**Send: RemoteEvents**

- `WidgetManager_Toggle`, `WidgetManager_Open`, `WidgetManager_OpenQueue` `@ (player: Player, widgetName: string, tweenName: string?)`
- `WidgetManager_Close @ (player: Player, widgetName: string)`, `WidgetManager_CloseCurrent @ (player: Player)`, `WidgetManager_ShowMessage @ (player: Player, message: string)`: fired by the server `I.WidgetManager`

**Send: RemoteFunctions**

- The same names with `-Return` (plus `WidgetManager_OpenPreviouslyOpened-Return @ (player: Player)`), returning the client function's result; used by the command, which reports a failure when the client returns anything but `true` or doesn't answer within the Network invoke timeout.

### Client

**Topics**

- `WidgetManager_Opened @ (widgetName: string)`, `WidgetManager_Closed @ (widgetName: string)`

**Receive: RemoteEvents**

- `WidgetManager_Toggle`, `WidgetManager_Open`, `WidgetManager_OpenQueue` `@ (widgetName: string, tweenName: string?)`, `WidgetManager_Close @ (widgetName: string)`, `WidgetManager_CloseCurrent @ ()`, `WidgetManager_ShowMessage @ (message: string)`

**Receive: RemoteFunctions**

- The `-Return` forms of the above, and `WidgetManager_OpenPreviouslyOpened-Return @ ()`

## Data

| Where | Key | What |
| --- | --- | --- |
| `Data/TweenPresets.lua` | `[tweenName]` | `Info` (TweenInfo), `PreTranslate(widget)`, `PostTranslate` (goal). `Default`: 0.15 s Sine Out from 0.5, 0.47. `Rise`: 0.45 s Back Out from 0.5, 0.58, so the widget overshoots and settles |
| `U_Widget` | `WidgetManager_Tween` (string attribute) | The tween the widget opens with when the caller names none |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `UTILITY_WIDGETS` | `WidgetManager_Message`, `WidgetManager_Confirmation` | Widgets that open on top and hand back to the previous one |
| `BACKGROUND_FOV`, `FOV_INCREASE` | `true`, `5` | Add to the `FOV` buff (value `Widget`) while a widget is open |
| `BACKGROUND_BLUR`, `BLUR_AMOUNT`, `BLUR_WEIGHT`, `BLUR_TWEENINFO` | `true`, `14`, `999`, … | Blur (a Lighting value at that weight) |
| `BACKGROUND_DIM`, `DIM_TRANSPARENCY`, `DIM_ORDER`, `DIM_TWEENINFO` | `true`, `0.5`, `-1`, … | Dim behind the widget |

## Components

### `WidgetManager_TogglePart` (`Components/TogglePart.lua`)

Opens the widget when the local character enters the part (checked every 0.15 s; it keeps trying while the character stays inside) and closes it on leaving. Every part tagged for the same widget counts as one zone: walking between them keeps the widget open, and it closes only when the character has left them all, and only when a zone opened it (a widget the player opened by hand stays open).

| | |
| --- | --- |
| Tag on | `BasePart` |
| Side | Client |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `WidgetManager_WidgetName` | string | `""` | The widget to open |

## Commands

`widget_manager` (server, on a player's client): `toggle`, `open`, `open_queue`, `open_previously_opened`, `close`, `close_current`, `show_message`.
