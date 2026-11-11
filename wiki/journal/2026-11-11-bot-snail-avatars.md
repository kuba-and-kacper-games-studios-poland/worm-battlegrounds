---
title: "Bots get the default snail's headshot"
date: 2026-11-11
status: open
kind: changed
pages: ["Bots", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Teams.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
  - art/bots/
---

**What changed.** Bots no longer show the smiley placeholder as their avatar: every bot shows the default snail's
voxel headshot (classic pink, smiling), rendered like a player's Roblox headshot, in the team panels, the turn list,
the turn callout and, new, the results screen (bots showed the design's default picture there). Eight personality
headshots were drawn first (glasses, army helmet, sunglasses, pirate, cowboy, ninja, king, viking); the owner chose
one default snail for now and personalities later, for rare bots with their own skins and avatars.

**Where.** MatchHud's `BOT_AVATAR` (was the smiley 75798902746408, now `rbxasset://textures/wb_bots/Bot_Default.png`),
`Teams.SetAvatar` (now used by `Results.lua` too). Pictures: `art/bots` (`make_bot_heads.py`, Blender; the eight
personalities stay in the kit for the rare bots).

**How to check.** In a solo match vs bots, every bot's avatar is the pink snail's headshot, in the team panel, the
turn list and the results.

**For the wiki.** Bots: their avatar. Match HUD: bot avatars in the panels and results. Still unsure: the picture is
local (`rbxasset://textures/wb_bots/`) until the owner approves it and it's uploaded; until then it draws blank on
other PCs and live servers. Planned: rare bots with their own skins and avatars.
