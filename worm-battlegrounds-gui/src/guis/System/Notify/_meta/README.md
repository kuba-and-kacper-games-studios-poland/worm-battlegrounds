# Notify

Notifications and messages: short notification lines stacked above the bottom of the screen, and chat-style messages (a sender's headshot and text over a band that fades out at both ends) below the top. It is made of `Primitive` nodes, plain Roblox instances that hold every value themselves, so no theme changes it. ume-gui owns it (`gui/repo.md`).

| | |
| --- | --- |
| Path | `"System/Notify"` |
| Modes | Night only |
| Devices | Desktop |
| Export | A ScreenGui named `Notify` in StarterGui: `Enabled` off, `DisplayOrder` -1, `ScreenInsets` `DeviceSafeInsets`, tagged `UserInterface_PreventHiding` (the UserInterface server enables it at start). Its root is a Folder, so both stacks go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Container-Notification` | Frame | 60% of the screen wide, its bottom 10% above the bottom edge; notifications stack up from the bottom (`ContainerLayout`) |
| `U_Container-Message` | Frame | 60% wide, 10% below the top edge; messages stack from the top down |

## Prefabs

### `PREFAB | Notification`

In `U_Container-Notification`. One line.

| Element | Class | What it is |
| --- | --- | --- |
| `S_MessageText` | TextLabel | The text, Source Sans Heavy, outlined; Notify colors its `UIGradient` with an `I.Gradient` gradient |

### `PREFAB | Message`

In `U_Container-Message`. One message, popped in by its `UIScale`.

| Element | Class | What it is |
| --- | --- | --- |
| `S_UserIcon` | ImageLabel | The sender's round headshot |
| `S_MessageText` | TextLabel | The message (`@username: message`), outlined |
| `S_Background` | Frame | The band behind it, `Color3.fromRGB(25, 40, 60)`, fading out at both ends |

## Driven by

ume's Notify module (`src/modules/Main/Notify`) finds this gui as `I.UserInterface.UI["Notify"]`, both containers inside it and their prefabs, and clones one per notification or message.

## Preview

`Preview.lua` (`UmeGui_Guis_System_Notify_Preview`) fills both containers in the Gui tool with example toasts, as ume's Notify shows them once their show tweens end: notifications with example texts, and user messages with a headshot, the name in Notify's default username colour and the message over their background. Without it the gui is two empty containers, since both toasts are prefabs.

| Setting | What it does |
| --- | --- |
| `S_Notifications` (Slider, 0 to 6) | How many notifications show |
| `S_Messages` (Slider, 0 to 4) | How many user messages show |

## Integration

### Setup

1. Export the gui with the Gui tool (**Export to StarterGui**): a ScreenGui named `Notify`, tagged `UserInterface_PreventHiding`. A restyled copy keeps its `Name`, both `U_Container-*` frames, both prefab names and their `S_` Ids.
2. ume module: `Main/Notify`. The server calls `I.Notify.ShowNotification` / `ShowMessage` (for one player or everyone); the client draws them. Its settings: `DEFAULT_NOTIFICATION_DURATION` (3 s), `DEFAULT_MESSAGE_DURATION` (6 s), `NOTIFICATION_DISPLAY_LIMIT` (15), `MESSAGE_DISPLAY_LIMIT` (6), `DEFAULT_NOTIFICATION_SOUND`, `DEFAULT_MESSAGE_SOUND`, `DEFAULT_USERNAME_COLOR`, `USERNAME_COLORS`.
3. Gradients: a notification's text takes the named gradient of `Utils/Gradient` (`I.Gradient.GetColor`), the default one when none is named.

### Input

None: notifications and messages leave on their own.

### Looks

| State | Element | Value |
| --- | --- | --- |
| A notification in | The clone's `UIScale` | From 0 to 1 over 0.15 s, Quad Out, with the notification sound (pitch 0.95 to 1) |
| A repeated notification | The toast on screen | Counts up instead of showing another |
| A notification's text | `S_MessageText` › `UIGradient` | The named gradient |
| A message in | `S_Background`, `S_UserIcon` | The band fades in over 0.2 s (Quad Out), the headshot scales from 0 over 0.2 s (Circular Out), the text types in letter by letter |
| A message's name | `S_MessageText` | `@name:` in the sender's `USERNAME_COLORS` colour, else `DEFAULT_USERNAME_COLOR` (`Color3.fromRGB(200, 200, 200)`) |
