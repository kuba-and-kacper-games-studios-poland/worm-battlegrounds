# Party

Lobby parties of up to `MAX_PARTY` players, who join match rows and solo matches together. A player invites someone
in the same server who isn't in a party (only the leader invites once there is one); the invite stays open
`INVITE_SECONDS`. A **+** card in the party column opens the `PartyInvite` box: everyone here who isn't in a party, each with
**Invite** (it turns to **Sent**). An invited player gets the `PartyInvited` box: who asked, **Join party** or **No
thanks** (closing it lets the invite run out). The leader can kick; when the leader leaves, the next member leads.
**Invite friends** in that box opens Roblox's game invite. Party state lives in two Player attributes, so every client draws the `Party` column
(the PARTY column at the left: a card per member with their avatar, name (their badges after it, `I.PlayerBadges.Show`) and level, a crown on the leader, Kick for
the leader, then a **+** card per free place for a player who may invite, and the red Leave button by the PARTY title
while in a party) without its own remote.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Party` |
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server) |
| Uses | `I.WidgetManager`, `I.Interact`, `I.Friends`, `I.PlayerBadges` (client) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Invites, answers, leaving, kicking, the attributes |
| `Client.lua` | The `Party` column |
| `Scripts/Client/Invites.lua` | The `PartyInvite` and `PartyInvited` boxes |
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
| `GUI_NAME` | `"Party"` | The party column |
| `INVITE_GUI_NAME`, `INVITED_GUI_NAME` | `"PartyInvite"`, `"PartyInvited"` | The invite list, and the box an invited player answers (WidgetManager widgets) |

## In the place

Drives the `Party` column: `U_Members` › `PREFAB | Member` (named by user id: `S_Avatar`, `S_Name` (the display name), `S_Username` (`@` and the user name), `S_Level`,
`S_Crown`, `S_Kick`) and `PREFAB | Invite` (the + cards), and `U_Party` › `S_Leave`.
Fills `PartyInvite` (`U_Players` › `PREFAB | Invitable`: `S_Avatar`, `S_Name`, `S_Username`, `S_Invite` with its `S_Text`,
greyed from its `Look_Sent*` attributes once sent; `S_Empty`; `S_InviteFriends`) and `PartyInvited` (`S_Avatar`, `S_Text`, `S_Accept`, `S_Decline`).
