# Party

Lobby parties of up to `MAX_PARTY` players, who join match rows and solo matches together. A player invites someone
in the same server who isn't in a party (only the leader invites once there is one); the invite stays open
`INVITE_SECONDS`. A **+** card in the party column opens the `PartyInvite` box: everyone here who isn't in a party, each with
**Invite** (it turns to **Sent**). An invited player gets the `PartyInvited` box: who asked, **Join party** or **No
thanks** (B says No thanks; it has no close button, like the confirmation dialog). Another window opening over it (the + card's invite list) doesn't drop
it: the box comes back when that window closes, while the invite lasts (`INVITE_SECONDS`). The leader can kick; when the leader leaves, the next member leads.
**Invite friends** in that box opens Roblox's game invite. Party state lives in two Player attributes, so every client draws the `Party` column
(the PARTY column at the left: a card per member with their avatar in their prestige frame, a crown on the leader, Kick for
the leader (no name, username, badges or level since 2026-11-24: the owner moved them over each snail on the lobby's
stage, Lobby's nameplates), then a **+** card per free place for a player who may invite, and the red Leave button by the PARTY title
while in a party) without its own remote. In a custom lobby (MatchBoard's `I.MatchBoard.GetCustomRoom`, redrawn on its
`MatchBoard_RoomChanged` Topic) the column lists the lobby instead: its members in this server, the crown on its owner, no
Kick or Leave, and a **+** card per free place up to its size that opens the `CustomLobby` window (2026-11-16). While
the player picks a size on the custom lobby's create step (`I.MatchBoard.GetPickedSize`), the column already shows that
many places. More than `COLUMN_CARDS` cards fill a second column (`S_MembersRight`, a copy of `U_Members` the client
makes `SECOND_COLUMN_X` card widths to the right, 2026-11-17). Every card's rim (the card's `Stroke` picture, whitened, with an `S_Prestige`
UIGradient the client adds) shows the player's prestige frame (`I.G_Progression.ApplyFrame`).

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Party` |
| Runs on | Server, Client · Lobby map |
| Exposes | `I.Party` (server) |
| Uses | `I.WidgetManager`, `I.Interact`, `I.Friends`, `I.G_Progression` (the frames), `I.MatchBoard` and its `MatchBoard_RoomChanged` Topic (client) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Invites, answers, leaving, kicking, the attributes |
| `Client.lua` | The `Party` column: the party, or the player's custom lobby |
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
| `COLUMN_CARDS`, `SECOND_COLUMN_X` | `4`, `1.3` | The most cards one column holds, and how far right of it (in card widths) the second column stands |
| `INVITE_SECONDS` | `30` | How long an invite stays open |
| `GUI_NAME` | `"Party"` | The party column |
| `INVITE_GUI_NAME`, `INVITED_GUI_NAME` | `"PartyInvite"`, `"PartyInvited"` | The invite list, and the box an invited player answers (WidgetManager widgets) |
| `CUSTOM_GUI_NAME` | `"CustomLobby"` | The custom lobby's window, which a + card opens while the column lists a custom lobby |

The lobby stage's "+" bubbles over its free pods (Lobby's `Stage`) read `MAX_PARTY`, `INVITE_GUI_NAME` and
`CUSTOM_GUI_NAME` too, and open the same windows as the + cards.

## In the place

Drives the `Party` column: `U_Members` › `PREFAB | Member` (named by user id: `S_Avatar`, `S_Prestige` (the UIGradient
the client adds on the card's rim), `S_Crown`, `S_Kick`) and `PREFAB | Invite` (the + cards), and `U_Party` › `S_Leave`.
Fills `PartyInvite` (`U_Players` › `PREFAB | Invitable`: `S_Avatar`, `S_Name`, `S_Username`, `S_Invite` with its `S_Text`,
greyed from its `Look_Sent*` attributes once sent; `S_Empty`; `S_InviteFriends`) and `PartyInvited` (`S_Avatar`, `S_Text`, `S_Accept`, `S_Decline`).
