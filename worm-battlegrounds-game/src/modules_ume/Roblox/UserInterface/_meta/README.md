# UserInterface

Every `ScreenGui` the game uses, by name. At start the server moves everything in `StarterGui` into the framework's replicated storage, disabled except guis tagged `UserInterface_PreventHiding`; each client moves them into its `PlayerGui` with `ResetOnSpawn` turned off (nothing is left in `StarterGui` to restore them after a respawn) and keeps them in `I.UserInterface.UI[name]`, which is how modules find their gui (`moduleGui = I.UserInterface.UI["Shop"]`). Guis built at runtime are added the same way. Gui names must be unique: when a second gui uses a stored name it replaces the first in `UI`, and the client warns with both full names.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/UserInterface` |
| Runs on | Server, Client |
| Exposes | `I.UserInterface` (client) |
| Uses | `StarterGui`, `I.Topic`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Moves `StarterGui` into the storage folder and disables guis that may be hidden |
| `Client.lua` | Moves guis into `PlayerGui`, `UI`, adding, removing and showing guis |
| `Components/PreventHiding.comp.json` | The `UserInterface_PreventHiding` tag (handled by `Server.lua`) |
| `Scripts/AdminPanel/CommandBar/Server.lua`, `Client.lua` | The `ui` command and its gui-name dictionary |

## API

### Client: `I.UserInterface`

| Function or field | Returns | What it does |
| --- | --- | --- |
| `UI[guiName]` | `ScreenGui` | Every stored gui, by name |
| `Add(...: ScreenGui \| Folder \| table)` | | Moves the guis (a Folder's children, or a list such as `Add({ guiA, guiB })`) into `PlayerGui` and stores them; publishes `UserInterface_UIAdded` for each |
| `Remove(guiName: string, destroy: boolean?)` | | Forgets the gui, and destroys it with `destroy`; publishes `UserInterface_UIRemoved` |
| `ChangeVisibility(guiName, state: boolean)` | | Sets the gui's `Enabled` |

## Usage

```lua
-- Client, _getElements
moduleGui = I.UserInterface.UI["Shop"]
```

## Network

### Server

**Send: RemoteEvents**

- `UserInterface_ChangeVisibility @ (player: Player, guiName: string, visibility: boolean)`: sent by the `ui` command, which doesn't wait for an answer.

### Client

**Topics**

- `UserInterface_UIAdded @ (gui: ScreenGui)`, `UserInterface_UIRemoved @ (guiName: string)`

**Receive: RemoteEvents**

- `UserInterface_ChangeVisibility @ (guiName: string, visibility: boolean)`: runs `ChangeVisibility`.

## Components

### `UserInterface_PreventHiding` (no script)

Keeps a gui enabled when the server disables the others at start. Exported UmeGui guis can carry it (`ScreenTags`).

| | |
| --- | --- |
| Tag on | `ScreenGui` in `StarterGui` |
| Side | Server, read once at start by `Server.lua` |

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `UserInterface` (CanvasGroup) | the framework's replicated folder (`I.Dirs.UmeReplicated`) | Holds every gui moved out of `StarterGui` until clients take them |

## Commands

`ui` (server): `change_visibility player guiName state`.
