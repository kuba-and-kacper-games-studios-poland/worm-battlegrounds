# Party

Lobby parties of up to `MAX_PARTY` players, who join match rows and solo matches together. A player invites someone
in the same server who isn't in a party (only the leader invites once there is one); the invite stays open
`INVITE_SECONDS`. The leader can kick; when the leader leaves, the next member leads. **Invite friends** opens
Roblox's game invite. Party state lives in two Player attributes, so every client draws the `Party` panel
(members with their level, a crown on the leader, kick buttons) without its own remote.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Party` |
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server) |
| Uses | `I.WidgetManager`, `I.Interact`, `I.Friends` (client) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Invites, answers, leaving, kicking, the attributes |
| `Client.lua` | The `Party` panel, invites and their confirmation |
| `Settings.lua` | `Party_Settings` |

## API

### Server: `I.Party`

| Function | Returns | What it does |
| --- | --- | --- |
| `Leave(player)` | | Takes the player out of their party; a party left with one player ends |
| `GetParty(player)` | `string?` | The player's party id |
| `GetMembers(partyId: string)` | `{ Player }` | The party's players in this server |
| `IsLeader(player)` | `boolean` | Whether the player leads their party (or has none) |

## Network

### Server

**Receive: RemoteEvents**

- `Party_Invite @ (player: Player, target: Player)`
- `Party_Answer @ (player: Player, fromUserId: number, accept: boolean)`
- `Party_Leave @ (player: Player)`
- `Party_Kick @ (player: Player, target: Player)`: leader only

**Send: RemoteEvents**

- `Party_Invited @ (fromUserId: number)`: to the invited player

## Data

| Where | Key | What |
| --- | --- | --- |
| Player attribute | `PartyId` | The party's id, or nil |
| Player attribute | `PartyLeader` | Whether the player leads it |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MAX_PARTY` | `4` | The most players in a party |
| `INVITE_SECONDS` | `30` | How long an invite stays open |
| `GUI_NAME` | `"Party"` | The panel |

## In the place

Drives the `Party` panel: `U_Members` › `PREFAB | Member` (named by user id), `U_Invite`, `U_InviteFriends`, `U_Leave`.
**Invite** is a shortcut for now: it asks about each player in the server in turn with a confirmation.
