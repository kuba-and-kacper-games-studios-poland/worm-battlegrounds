---
title: "Emote icons, the bot avatar and the player badges uploaded, so they show on live servers"
date: 2026-11-11
status: open
kind: fixed
pages: ["Emotes", "Bots", "Badges"]
files:
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_*.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/PlayerBadges/Settings.lua
  - art/emotes/README.md
  - art/bots/README.md
  - art/badges/README.md
---

**What changed.** The nine emote icons, the bot avatar and the five player badges were local pictures
(`rbxasset://textures/wb_emotes/`, `wb_bots/`, `wb_badges/`), so on live servers they were blank. They're now uploaded
to The Snail Studio group (566704940) as Decals, all passed moderation, and the code uses their image ids. The emote
bubble, the emote wheel and shop, the bots' avatars (team panels, turn list, turn callout, results) and the badges
after names now show in the live game.

**Where.** Each emote row's `IconId` (`Emote_<Id>.lua`); MatchHud's `BOT_AVATAR`; PlayerBadges' `BADGES` `Image`s.
The decal and image ids are in each kit's README (`art/emotes`, `art/bots`, `art/badges`).

**How to check.** No `rbxasset://textures/wb_` is left in the code. In a live server, the emote icons, a bot's avatar
and a player's badges show.

**For the wiki.** Nothing players read changes, apart from these pictures now showing live.

Still unsure: most of the game's other pictures (the item icons, the wind and more: 345 uploaded under the user
viridianscape by Studio's Assistant, 145 under the studio designer Otron_TV) belong to a person while the game belongs
to the group. If they are Restricted they stay blank live until the game's universe (10774518479) is given permission
to use them, or they're uploaded again under the group. The place's code must be published again for these ids to
reach live servers.
