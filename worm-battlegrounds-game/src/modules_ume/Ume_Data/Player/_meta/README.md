# Player

Player data and player lifecycle. On the server it loads each player's saved profile (ProfileStore, with session locking), builds their session table, checks that their client has loaded, and handles characters (first spawn, respawn, cleanup). On both sides it runs the join, leave and character callbacks other modules register, in priority order. Modules add their saved keys to `I.Player.ProfileTemplate` and their session keys to `I.Player.SessionTemplate` during `Init`.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume_Data/Player` |
| Runs on | Server, Client, Global |
| Exposes | `I.Player` (server), `I.G_Player` (both) |
| Uses | `I.ProfileStore`, `I.Topic`, `I.AdminPanel_CommandBar`, `I.TeleportToDefaultLobby` |
| Saves | Every module's profile keys, through the profile template |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profiles and sessions on join and leave (data is released after the leave callbacks, or after `REMOVING_CALLBACKS_TIMEOUT`), the client-loaded check, character spawning and cleanup, `I.Player` |
| `Client.lua` | Publishes the local character's added and removing Topics |
| `Global.lua` | The priority-ordered join, leave and character callbacks, `I.G_Player` |
| `Scripts/S_ProfileHandler.lua` | Opens and releases ProfileStore profiles per namespace |
| `Scripts/S_SessionHandler.lua` | Creates and clears session tables from the session template |
| `Templates/S_Profile.lua`, `S_Session.lua` | The empty templates modules fill in (`Player_ProfileData`, `Player_SessionData`) |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `player` command |
| `Settings.lua` | Character and loading timings, debug timing |

## API

### Server: `I.Player`

| Function or field | Returns | What it does |
| --- | --- | --- |
| `GetProfile(player, namespace: string?)` | `Player_Profile?` | The player's loaded ProfileStore profile for a namespace (`"Data"` when omitted): `.Data` holds that namespace's saved keys, and `:Save()` / `:MessageHandler()` are ProfileStore's. Warns and returns `nil` when it isn't loaded. |
| `Valid(player)` | `boolean` | The player's profile and session are loaded and their client has finished loading. Every server function that takes a `player` checks this first. |
| `RegisterProfile(namespace: string, template)` | `{ [string]: any }` | Adds a second saved profile namespace with its own template. Errors when it exists, when the framework has already started, or when the longest possible profile key (`PlayerProfile_<11-digit id>_<namespace>_<ProfileStoreName>`) would pass ProfileStore's 50 characters |
| `ResetData(player, authorized: boolean?)` | | Resets the player's saved data and sends them to the lobby (only when `authorized`) |
| `OverrideRespawnFunction(callback)` | | Replaces the default respawn (`LoadCharacterAsync`) with `callback(player, character)` |
| `Sessions[player]` | | The player's session table |
| `ProfileTemplate`, `ProfileTemplates` | | The default profile template, and every namespace's template |
| `SessionTemplate` | | The session template's data |

### Global: `I.G_Player`

Each takes `(priority: number, callback, ignoreExecTime: boolean?)`. Higher priorities run first; callbacks with the same priority run in registration order. Use the bands in `I.Priority` (`docs/reference/core-globals.md`): `Data` to check saved values, `Replicator` to create Replicator folders, `Setup` for per-player state others read, `Default` for gameplay, `Late` for dictionaries and debug. `First` and `Last` are the framework's: an `OnPlayerAdded` priority at or below `I.Priority.Last` warns, because it runs after the client was told it loaded and its Replicator folders would be missed. On the server the callback gets the player (and the character); on the client, the local player's events.

| Function | When the callback runs |
| --- | --- |
| `OnPlayerAdded` | A player joined and their data is loaded |
| `OnPlayerRemoving` | A player is leaving, before their profile is released. The release waits for these callbacks at most `REMOVING_CALLBACKS_TIMEOUT` seconds. |
| `OnCharacterAdded` | A character spawned (after its limbs loaded; a limb missing after `LIMB_WAIT_TIMEOUT` warns and doesn't hold it back) |
| `OnCharacterRemoving` | A character died or was removed |

## Usage

```lua
-- Server Init, DATA: this module's saved keys
--- @type Player_ProfileData
local _pt = I.Player.ProfileTemplate
_pt["Shop"] = { Bought = {} }

-- Server Init, INITIALIZATION
I.G_Player.OnPlayerAdded(I.Priority.Default, Module._setupPlayer)

-- Any server function
local profileData = I.Player.GetProfile(player).Data --- @type Player_ProfileData

-- Another namespace, and a forced save after a paid grant
local inventoryData = I.Player.GetProfile(player, "Inventory").Data
I.Player.GetProfile(player):Save()
```

The profile template is the only shape of saved data (`.claude/rules/ume/classes.md`, Profile data).

## Network

No remotes of its own.

### Server

**Topics**

- `_Player_PlayerAdded @ (player: Player)`
- `_Player_CharacterAdded @ (player: Player, character: Model)`, `_Player_CharacterRemoving @ (player: Player, character: Model)`

### Client

**Topics**

- `_Player_CharacterAdded @ (character: Model)`, `_Player_CharacterRemoving @ (character: Model)`

These drive `I.G_Player`; modules register through `I.G_Player` instead of subscribing. The leave callbacks run straight from `Players.PlayerRemoving`, so the server can wait for them before releasing data.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TASK_WAIT_AFTER_PLAYER_FUNCTION` | `false` | Yield a frame after each player callback |
| `CHARACTER_DESTROY_DELAY` | `30` | Seconds after death before a character is destroyed; `0` turns it off |
| `INITIAL_CHARACTER_AUTO_LOAD` | `true` | Spawn the first character when `Players.CharacterAutoLoads` is off |
| `CLIENT_LOAD_TIMEOUT_SECONDS` | `120` | Seconds to wait for the client to load before kicking |
| `REMOVING_CALLBACKS_TIMEOUT` | `10` | Seconds to wait for the leave callbacks before the player's data is released anyway |
| `LIMB_WAIT_TIMEOUT` | `10` | Seconds to wait for each limb of a new character before warning about it |
| `LIMB_TREES` | | Limb names per `HumanoidRigType` |
| `DEBUG_FUNCTIONS_RUNTIME`, `DEBUG_FUNCTIONS_THRESHOLD` | on in Studio, `0.1` | Log player callbacks slower than the threshold |

## Commands

`player` (server):

| Subcommand | Arguments |
| --- | --- |
| `reset_data` | `player [key]` |
