# Tool

Tools with pluggable scripts. The server gives players tools, from a model in `UmeServer.Tools` (by name) or an existing `Tool`, each with its own UUID, and attaches **tool scripts**: modules in `src/global_data/Tool/<ScriptName>/` with a `Server.lua` and a `Client.lua` whose `Equipped`, `Unequipped`, `Activated`, `Deactivated` and `Destroy` run on both sides. One tool can carry several scripts, changed at runtime; a script added to a tool in hand gets `Equipped` right away. Client scripts and client Topics get the same UUID as the server, so a client can send it in a remote and the server finds the tool with `I.Tool.Get`. Activation reaches the server from the client, so each server script's `Activated` is limited by a cooldown. A given tool can't be dropped, and leaves the player only through `Remove` (or `RemoveAll` when the character is removed).

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Tool` |
| Runs on | Server, Client |
| Exposes | `I.Tool` (server) |
| Uses | `I.Player` (session), `I.G_Player`, `I.Topic`, `I.Create`, `I.AdminPanel_CommandBar`, `I.Obfuscate`, `src/global_data/Tool` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Tool models, giving and removing tools, each tool's equip tracking and Topics, the `I.Tool` table |
| `Scripts/Server/ToolScripts.lua` | Server tool scripts: loading them, attaching and detaching them, their equip and activate state, the activation cooldown |
| `Client.lua` | Runs the tool scripts' client functions, client Topics |
| `Settings.lua` | The default activation cooldown |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `tool` command |
| `_meta/_types.lua` | The `Tool` session data, the tool script modules |

## API

### Server: `I.Tool`

| Function | Returns | What it does |
| --- | --- | --- |
| `Add(player, newTool: string \| Tool, scriptsNames: { string }?, setUUID: string?)` | `string?` | Gives the tool (a model name or a `Tool`) with these scripts; returns its UUID |
| `Remove(player, toolUUID: string)` | `boolean` | Removes the tool from the backpack or character |
| `RemoveAll(player)` | `boolean`, `{ string }?` | Removes every tool; returns their UUIDs |
| `SetScripts(player, toolUUID, scriptsNames: { string }?)` | `boolean` | Replaces the tool's scripts |
| `AddScripts` / `RemoveScripts(player, toolUUID, scriptsNames: { string })` | `boolean` | Adds or removes scripts |
| `RemoveAllScripts(player, toolUUID)` | `boolean` | Removes every script |
| `GetScripts(player, toolUUID)` | `{ string }?` | The tool's scripts |
| `GetEquipped(player)` | `Tool` | The tool in the player's hand |
| `Get(player, toolUUID)` | `Tool` | A tool by UUID |
| `GetAll(player)` | `{ string }` | Every tool UUID |
| `GetAllScripts(player)` | `{ [string]: { string } }?` | UUID → scripts |
| `Has(player, toolUUID)` | `boolean` | Whether the player has it |

## Usage

```lua
local uuid = I.Tool.Add(player, "Sword", { "Melee" })
I.Tool.AddScripts(player, uuid, { "Fire" })
```

## Network

No remotes: the tool's attributes carry its UUID and scripts to the client.

### Server

**Topics**

- `Tool_Added`, `Tool_Removed`, `Tool_Equipped`, `Tool_Unequipped` `@ (player: Player, tool: Tool, toolUUID: string)`: once per tool, scripts or not. `Tool_Equipped` is skipped while the player is dead; `Tool_Unequipped` also fires when the equipped tool is removed.

### Client

**Topics**

- `Tool_Added`, `Tool_Removed`, `Tool_Equipped`, `Tool_Unequipped` `@ (tool: Tool, toolUUID: string)`: `toolUUID` is the server UUID (a random one for a tool the server didn't give).

## Data

| Where | Key | What |
| --- | --- | --- |
| Session | `Tool.CurrentlyEquipped`, `Tool.CreatedTools`, `Tool.ToolsData` | The equipped tool, every tool by UUID, per-tool data for the tool scripts |
| `src/global_data/Tool/<ScriptName>/Server.lua`, `Client.lua` | `Init`, `Equipped`, `Unequipped`, `Activated`, `Deactivated`, `Destroy` | A tool script (`Example` is the template) |
| `src/global_data/Tool/<ScriptName>/Server.lua` | `Cooldown` | Least seconds between two server `Activated` calls of that script; `DEFAULT_ACTIVATION_COOLDOWN` when it isn't set. Activations sooner than that are dropped, and their `Deactivated` with them. |

`Activated`, `Deactivated`, `Equipped` and `Unequipped` on the server follow what the client does with its tool, so treat them as client input: check range, state and costs on the server before acting.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEFAULT_ACTIVATION_COOLDOWN` | `0.01` | Cooldown, in seconds, of a server tool script that doesn't set `Cooldown` |

## In the place

| Instance | Where | Attributes |
| --- | --- | --- |
| Tool models | `UmeServer.Tools` (Configuration) | Models `Add` clones by name |
| each given `Tool` | the player's backpack or character | `Tool_ServerUUID`, `Tool_Scripts` (comma list). Set locally on the client: `Tool_ClientUUID` (the UUID client scripts get), `Tool_Equipped_<script>_Client`, `Tool_Activated_<script>_Client`, `Tool_Inactive_Client`. `CanBeDropped` is turned off. |

## Commands

`tool` (server): `add`, `remove`, `remove_all`, `scripts` (`set`, `get`, …), `equipped`, `all_uuids`, `all_scripts`, `has`.
