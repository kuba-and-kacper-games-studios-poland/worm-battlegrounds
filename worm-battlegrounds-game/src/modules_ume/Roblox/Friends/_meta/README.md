# Friends

Friends in the same server, and the game invite prompt. The server keeps, for every player, the user ids and count of their Roblox friends who are in this server and mirrors them into the Replicator; the client reads them. A joining player is checked against everyone already in the server, a leaving player is removed from every list without web calls, and every pair of players is checked again periodically to pick up friendships made during the session (Roblox has no server event for that). Either side can open the invite prompt.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Friends` |
| Runs on | Server, Client |
| Exposes | `I.Friends` (server, client) |
| Uses | `SocialService`, `I.G_Player`, `I.Replicator`, `I.DoEvery`, `I.Topic`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The in-server friend lists (join check, leave cleanup, periodic check), the Replicator folder, asking a client to prompt |
| `Client.lua` | The invite prompt, reading the replicated list |
| `Settings.lua` | How often every pair of players is checked again |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `friends` command |
| `_meta/_types.lua` | `Friends_InviteOptions` |

## API

### Server: `I.Friends`

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptGameInvite(player, inviteOptions: Friends_InviteOptions?, invoke: boolean?)` | `boolean?` | Asks the player's client to open the invite prompt with these options (`PromptMessage`, `InviteUser`, `InviteMessageId`, `LaunchData`); the client builds the `ExperienceInviteOptions`. With `invoke`, waits (at most the Network invoke timeout) and returns whether it opened. |
| `GetActiveCount(player)` | `number?` | Friends of the player in this server |
| `GetActiveList(player)` | `{ string }?` | A copy of their user ids |
| `GetActivePlayers(player)` | `{ Player }?` | The same friends as `Player` instances |
| `IsFriendsWith(player, friend: Player)` | `boolean?` | Whether `friend` is in the player's in-server list |

### Client: `I.Friends`

| Function | Returns | What it does |
| --- | --- | --- |
| `PromptGameInvite(inviteOptions: Friends_InviteOptions \| ExperienceInviteOptions?)` | `boolean` | Opens the invite prompt |
| `IsFriendsWith(player: Player)` | `boolean` | Whether `player` is in the local player's replicated list |

## Network

### Server

**Topics**

- `Friends_DataUpdated @ (player: Player, friend: Player?)`: after the player's list changed; `friend` is the friend who joined or left when that is what changed it, `nil` for the player's own join check and the periodic check.

**Send: RemoteEvents**

- `Friends_PromptGameInvite @ (player: Player, inviteOptions: Friends_InviteOptions?)`

**Send: RemoteFunctions**

- `Friends_PromptGameInvite-Return @ (player: Player, inviteOptions: Friends_InviteOptions?)`: the `invoke` form; only an answer of `true` counts.

### Client

**Receive: RemoteEvents**

- `Friends_PromptGameInvite @ (inviteOptions: table?)`

**Receive: RemoteFunctions**

- `Friends_PromptGameInvite-Return @ (inviteOptions: table?)`: returns whether the prompt opened.

## Data

| Where | Key | What |
| --- | --- | --- |
| Replicator `Friends` folder | `ActiveCount` | Friends in this server |
| | `ActiveList` | Their user ids (strings), JSON-encoded |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `COUNT_CHECK_DELAY` | `30` | Seconds between periodic checks of every pair of players, up to `COUNT_CHECK_PLAYERS` players |
| `COUNT_CHECK_PLAYERS` | `10` | Player count the delay is tuned for (2 or more). Above it the delay grows with the number of pairs, so the check rate stays the same: 20 players about 127 s, 50 players about 816 s. |

## Commands

`friends` (server):

| Subcommand | Arguments |
| --- | --- |
| `prompt_invite`, `get_count`, `get_list` | `player` |
| `is_friends_with` | `player friend` |
