# Party

Lobby parties of up to `MAX_PARTY` players, who join match rows and solo matches together. A player invites someone
in the same server who isn't in a party (only the leader invites once there is one); the invite stays open
`INVITE_SECONDS`. **Invite players** opens the `PartyInvite` box: everyone here who isn't in a party, each with
**Invite** (it turns to **Sent**). An invited player gets the `PartyInvited` box: who asked, **Join party** or **No
thanks** (closing it lets the invite run out). The leader can kick; when the leader leaves, the next member leads.
**Invite friends** opens Roblox's game invite. Party state lives in two Player attributes, so every client draws the `Party` panel
(members with their level, a crown on the leader, kick buttons) without its own remote. The panel hangs under a
tab with the party's count; it starts open on PC and console and folded on phones and tablets (it follows
`I.Platform.Current`), and a press on the tab opens or folds it.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Party` |
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server) |
| Uses | `I.WidgetManager`, `I.Interact`, `I.Friends`, `I.Platform` and the `Platform_Changed` Topic (client) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Invites, answers, leaving, kicking, the attributes |
| `Client.lua` | The `Party` panel |
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
| `GUI_NAME` | `"Party"` | The panel |
| `INVITE_GUI_NAME`, `INVITED_GUI_NAME` | `"PartyInvite"`, `"PartyInvited"` | The invite list, and the box an invited player answers (WidgetManager widgets) |

## In the place

Drives the `Party` panel: `S_Tab` (the count, its skin and chevron), `S_Panel` (open or folded), `U_Members` ›
`PREFAB | Member` (named by user id), `U_Invite`, `U_InviteFriends`, `U_Leave`.
Fills `PartyInvite` (`U_Players` › `PREFAB | Invitable`: `S_Avatar`, `S_Name`, `S_Invite`; `S_Empty`;
`S_InviteFriends`) and `PartyInvited` (`S_Avatar`, `S_Text`, `S_Accept`, `S_Decline`).
