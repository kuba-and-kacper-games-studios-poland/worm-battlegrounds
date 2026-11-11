# PlayerBadges

Badges after a player's name (the owner's pick, 2026-11-10: "if a player has multiple, display multiple"). The
server decides who wears which and writes it to the player's `Badges` attribute, which every client reads; clients
never decide a badge. Every badge that applies shows, in this order: **Game owner** (a gold crown: rank 255 in The
Snail Studio's group, a role in `OWNER_ROLES`, or the user who owns the game), **Developer** (a green coin with a
wrench: `DEVELOPER_RANK` or above in that group, or a role in `DEVELOPER_ROLES`), **Game admin** (a red shield with a check: the AdminPanel's admins, `I.AdminPanel.CanOpenDashboard`),
**Roblox staff** (a red tilted square: in Roblox's official group), **Star creator** (a purple coin with a gold star:
in Roblox Video Stars), **Verified** (Roblox's own verified badge, `Player.HasVerifiedBadge`) and **Premium** (Roblox's
own Premium icon). The first five are the `art/badges` kit's pictures; Verified and Premium are Roblox's glyphs in the
game's text (`U+E000`, `U+E001`). Bots have none. The server reads them when a player joins (group ranks through
`I.Group`, once a session) and again when their Premium starts or ends or `Group_DataUpdated` says their place in one of
those groups changed.

On the client, `I.PlayerBadges.Show` puts them right after a name label's text: in the SnailTag over each snail, the
match HUD's turn list, the lobby's Party panel and the Results cards. Each badge is `BADGE_SIZE` of the name's height;
the name gives up their room (keeping its left edge, so a centred name centres with its badges) and its text shrinks
to fit on one line (its `UITextSizeConstraint`, from the text's width measured with TextService); past `MAX_SHARE` of
the name's width the badges shrink too. They follow the player's attribute until the label goes.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/PlayerBadges` |
| Runs on | Server, Client |
| Exposes | `I.PlayerBadges` (client) |
| Uses | `I.Group` (server: `GetRank`, `GetRole`, `IsMember`, `Group_DataUpdated`), `I.AdminPanel` (server: `CanOpenDashboard`), `I.G_Player`, `I.Player`, `I.Topic`, `TextService` (client) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Works out each player's badges and publishes the `Badges` attribute: on join (on a thread of its own), when `MembershipType` changes, and on `Group_DataUpdated` for the studio's, Roblox's and Video Stars' groups |
| `Client.lua` | `I.PlayerBadges.Show`: clones a badge per id into the name's `S_Badges`, lays them out after its text and keeps them in step with the player's attribute, the name's text and its size |
| `Settings.lua` | `PlayerBadges_Settings`: the attribute, the badges and their looks, the layout |
| `ServerSettings.lua` | `PlayerBadges_ServerSettings` (server only): the studio's group and ranks, Roblox's groups |
| `_meta/_types.lua` | `PlayerBadges_Badge` (a `BADGES` row), `PlayerBadges_Label` (a name showing badges) |

## API

### Client: `I.PlayerBadges`

| Function | Returns | What it does |
| --- | --- | --- |
| `Show(label: TextLabel, userId: number?)` | | Shows the player's badges after a name label's text, in the `S_Badges` frame beside it, and keeps them in step until the label is destroyed. No user id (a bot), or a player not in this server, shows none. Call it after writing the name; calling it again for the label refreshes it |

## Usage

```lua
-- Client: after writing a name
nameLabel.Text = player.DisplayName
I.PlayerBadges.Show(nameLabel, player.UserId)
```

## Network

No remotes: the server writes the `Badges` Player attribute, which replicates to every client.

## Data

| Where | Key | What |
| --- | --- | --- |
| Player attribute | `Badges` | The player's badge ids, comma separated, in `BADGES`' order (`"Owner,Developer,Admin,Verified,Premium"`); `""` with none. Written only by the server |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `ATTRIBUTE` | `"Badges"` | The Player attribute the server writes |
| `BADGES` | Owner, Developer, Admin, Staff, Star (pictures), Verified, Premium (glyphs) | Every badge in its order: `Id`, and `Image` (the picture's uploaded `rbxassetid://` id, from `art/badges`) or `Glyph` (`"\u{E000}"` verified, `"\u{E001}"` Premium) |
| `BADGE_SIZE`, `BADGE_GAP` | `0.85`, `0.12` | A badge's size and the gap before it, times the name label's height |
| `MAX_SHARE` | `0.4` | The most of the name's width the badges take: the name shrinks first, and past it the badges shrink too |
| `TEXT_ROOM` | `1.06` | Scaled text draws about 5% wider than TextService measures it: room kept when fitting a name on one line |

### Server settings

| Key | Default | What |
| --- | --- | --- |
| `STUDIO_GROUP` | `566704940` | The Snail Studio, which owns the game |
| `OWNER_RANK` | `255` | Its owner's rank: the crown (in a game a user owns, that user wears it instead) |
| `DEVELOPER_RANK` | `254` | The lowest rank wearing the wrench (Admin 254, the owner 255) |
| `OWNER_ROLES`, `DEVELOPER_ROLES` | `{ "LEAD" }`, `{ "LEAD", "Management", "Build" }` | The group's roles, by name, that wear the crown and the wrench whatever their rank: on 2026-11-10 Member, Tester, Build, Management and LEAD are all rank 1, so ranks can't tell them apart (the owner's pick). Tester wears neither |
| `STAFF_GROUP`, `STAR_GROUP` | `"Roblox"`, `"RobloxStars"` | Groups.lua's names for Roblox's official group (1200769) and Roblox Video Stars (4199740) |

## In the place

Each name label that shows badges has, beside it under the same parent, an `S_Badges` Frame holding a hidden
`PREFAB | Badge` ImageLabel with an `S_Glyph` TextLabel (the guis' README → Elements), and a `UITextSizeConstraint`
on the label itself. Pictures from Studio's content folder show only in a Studio on the PC that ran the kit's
`build.py --studio` until they're uploaded (`art/badges/README.md` → Uploading).
