---
title: "Chat bubbles over snails (style B, 3 at most) and player badges after names (7 kinds, all shown)"
date: 2026-11-10
status: open
kind: added
pages: ["Match screen", "Lobby", "Guis", "Chat"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/PlayerBadges/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/PlayerBadges/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/PlayerBadges/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/PlayerBadges/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ChatBubble/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/SnailTag/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
  - art/badges/build.py
  - art/badges/src/owner.svg
  - art/badges/src/developer.svg
  - art/badges/src/admin.svg
  - art/badges/src/staff.svg
  - art/badges/src/star.svg
---

**What changed.** Two things players see, both the owner's picks from a drafted look.

*Chat bubbles.* When a player chats, their message shows in a speech bubble over their snail: in a match over their
snail, above its name and health bar; in the lobby over their snail on the party stage (only party members stand
there). A player with no snail on your screen (or a knocked-out one) gets no bubble. Roblox's own chat bubbles are off.
The look is "style B": a white rounded bubble with a dark outline (rgb 25, 25, 42) and dark Londrina Solid text, at
most 170 px of text wide before it wraps, with a small tail under the newest one. Up to 3 bubbles stack over a snail,
the newest at the bottom; a 4th message pushes the oldest out. A bubble pops in, stays 4 s plus 0.06 s per letter (10 s
at most), then fades. Only player messages show, as Roblox filtered them for you; system messages don't.

*Badges.* After a player's name, every badge that applies shows, in this order: **Game owner** (gold crown: the owner
of The Snail Studio group, rank 255, or its LEAD role), **Developer** (green coin with a white wrench: rank 254 or more
in The Snail Studio, or its LEAD, Management or Build role), **Game admin** (red shield with a white check: the game's admin
list), **Roblox staff** (red tilted square: members of Roblox's official group), **Star creator** (purple coin with a
gold star: Roblox Video Stars), **Verified** (Roblox's own verified badge) and **Premium** (Roblox's own Premium
icon). They show on the name over each snail in a match, in the turn list, in the lobby's Party panel and on the
Results cards. Bots have none. A long name shrinks to fit its badges on one line.

**Where.** Bubbles: the `ChatBubbles` module (client), its `Settings.lua` (`TEXT_MAX_WIDTH` 170, `MAX_BUBBLES` 3,
`BUBBLE_SECONDS` 4, `BUBBLE_SECONDS_PER_LETTER` 0.06, `BUBBLE_MAX_SECONDS` 10, `POP_FROM` 0.6, `TAG_GAP` 6 px,
`STAGE_GAP` 0.6 studs) and the `ChatBubble` billboard gui (its holder `ReplicatedStorage_Assets/ChatBubbles/PREFAB |
ChatBubble`). The lobby's stage snails come from the new client API `I.Lobby.GetStageSnail`. Badges: the
`PlayerBadges` module: the server writes the `Badges` Player attribute (comma-separated ids `Owner`, `Developer`,
`Admin`, `Staff`, `Star`, `Verified`, `Premium`); `ServerSettings.lua` holds `STUDIO_GROUP` 566704940, `OWNER_RANK`
255, `DEVELOPER_RANK` 254, `OWNER_ROLES` { "LEAD" }, `DEVELOPER_ROLES` { "LEAD", "Management", "Build" }, `STAFF_GROUP` "Roblox" (1200769), `STAR_GROUP` "RobloxStars" (4199740); admins are
`I.AdminPanel.CanOpenDashboard` (the `CustomLevels` list in `src/global_data/AdminPanel/Permissions.lua`). The
client's `I.PlayerBadges.Show(label, userId)` draws them. The five pictures are the `art/badges` kit; Verified and
Premium are Roblox's text glyphs U+E000 and U+E001. No remotes in either module.

**How to check.** In a playtest, chat: a bubble pops over your snail above its name bar and fades after a few
seconds; send four quick messages and only the last three show. In the lobby with a party, a member's chat shows over
their stage snail. As the owner (DefinitelyNotBaxtrix) the name shows the crown, the wrench, the shield, and the
verified and Premium badges when they apply. The badge pictures show only in a Studio on the PC that ran
`art/badges/build.py --studio` until the owner approves and uploads them.

**For the wiki.** Guis (or Chat): a section on chat bubbles (where they show, how many, how long). A Badges table
(icon, name, who gets it) on the Guis or Lobby page, noting all of a player's badges show. Match screen: the turn
list and name tags show badges.

**Still unsure.** The badge pictures aren't uploaded yet (local only); the group's roles all share rank 1, so
the owner picked role names (2026-11-10): LEAD wears the crown and the wrench, Management and Build the wrench, Tester
neither. Checked in a Studio playtest: the owner's account (LEAD) gets `Owner,Developer,Admin,Premium`, all four
icons after the name on the Party card; a chat message shows a bubble over the stage snail.
