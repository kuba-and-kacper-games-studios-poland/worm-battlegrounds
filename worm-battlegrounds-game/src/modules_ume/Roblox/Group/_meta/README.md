# Group

Roblox groups by name. Groups are listed in `src/global_data/Group/Groups.lua` (`Default` is the game's own group); every function takes a group name from that list or a group id, always passed explicitly (there is no `Default` fallback). The server reads each player's membership, role and rank when they join, mirrors it into the Replicator, and reads it again after a join prompt (through the groups proxy when it is enabled and HTTP requests are on). The client reads the mirrored values.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Group` |
| Runs on | Server, Client, Global |
| Exposes | `I.Group` (server, client), `I.G_Group` (both) |
| Uses | `GroupService`, `HttpService`, `I.G_Player`, `I.Replicator`, `I.Debounce`, `I.Topic`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Membership data on join and on request, the proxy request, the Replicator folder, the join prompt, the remotes clients ask through |
| `Client.lua` | The join prompt (asks the server to refresh after it), the replicated membership getters |
| `Global.lua` | Group ids, names, info, allies and enemies |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `group` command |
| `_meta/_types.lua` | `Group_StoredData`, `Group_ProxyRole`, `Group_GroupInfo` and its owner and role tables |
| `src/global_data/Group/S_Proxy.lua` | The groups proxy: on or off, its URL, the highest rank its answer is trusted for. Server only: the `S_` prefix hides it from clients. |

## API

`groupName` is a name from `Groups.lua` or a group id (a positive whole number). It is required: a missing or unknown group warns and returns `nil`.

### Server: `I.Group`

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptJoin(player, groupName)` | | Asks the player's client to open the join prompt |
| `UpdateData(player, groupName, useProxy: boolean?)` | | Reads the player's membership again (with `useProxy`, prefers the proxy's answer) and updates the Replicator and `Group_DataUpdated` |
| `IsMember(player, groupName)` | `boolean?` | Whether the player is in the group; reads it first when the group wasn't fetched yet |
| `GetRole(player, groupName)` | `string?` | Their role name |
| `GetRank(player, groupName)` | `number?` | Their rank in the group |

### Client: `I.Group`

`IsMember`, `GetRole` and `GetRank` are the same getters without `player`: they read the local player's replicated values (`nil` for a group the server hasn't fetched). Call them after the framework loaded (`I.OnLoaded`).

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptJoin(groupName)` | `Enum.GroupMembershipStatus?` | Opens the join prompt, then asks the server to update the player's data |
| `IsMember(groupName)`, `GetRole(groupName)`, `GetRank(groupName)` | `boolean?`, `string?`, `number?` | The replicated membership, role and rank |
| `GetChangedSignal(groupName)` | `RBXScriptSignal?` | Fires when the local player's rank in the group changes (joining, leaving, a new role) |

### Global: `I.G_Group`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetId(groupName)` | `number?` | The id of a listed group, or the id passed in; warns when missing or not valid |
| `GetName(groupId)` | `string?` | The name a group id is listed under |
| `GetInfo(groupName)` | `Group_GroupInfo?` | Name, description, emblem, owner and roles |
| `GetAllies(groupName)`, `GetEnemies(groupName)` | `StandardPages?` | Allied and enemy groups |

## Network

### Server

**Topics**

- `Group_DataUpdated @ (player: Player, groupName: string | number)`: after a player's membership was read (first read, or a role change).

**Receive: RemoteEvents**

- `Group_RequestUpdateData @ (player: Player, groupName: string | number)`: the client asks for a refresh after a join prompt. Listed groups only, at most 1 call per second; one proxy request per player every 10 seconds updates every listed group.

**Receive: RemoteFunctions**

- `Group_IsMember`, `Group_GetRole`, `Group_GetRank` `@ (player: Player, groupName: string | number)`: at most 10 calls per second per remote. A group the server hasn't fetched for the player is read once, and at most 5 such groups per player per session; after that they return `nil`.

**Send: RemoteEvents**

- `Group_PromptJoin @ (player: Player, groupId: number)`

### Client

**Receive: RemoteEvents**

- `Group_PromptJoin @ (groupId: number)`

**Send: RemoteEvents**

- `Group_RequestUpdateData @ (groupName: string | number)`

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Group` folder | `{groupId}_IsMember`, `{groupId}_Role`, `{groupId}_Rank` (and the same under the listed name) | The player's membership in every fetched group |
| `src/global_data/Group/Groups.lua` | `[groupName] = groupId` | The groups the game knows; `Default` is its own |
| `src/global_data/Group/S_Proxy.lua` | `Enabled`, `Url`, `MaxRank` | The groups proxy (default `true`, `groups.roproxy.com`, `10`) |

## Commands

`group` (server): `get_id`, `get_name`, `get_info`, `get_allies`, `get_enemies`, `prompt_join`, `is_member`, `get_role`, `get_rank`, `update_data`.
