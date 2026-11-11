---
title: "Emote icons show in a thought cloud over the snail's head"
date: 2026-11-11
status: open
kind: fixed
pages: ["Emotes", "Lobby", "Chat"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ChatBubble/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
---

Supersedes the over-the-snail part of `2026-11-11-emote-icons-and-bubbles` (the speech bubble over the snail in a
match); its icons, its party-card bubble in the lobby and its stand-in motions still hold.

**What changed.** A played emote's icon pops up over the snail's head in a **thought cloud**, as Worms draws one: a
white cloud of puffs with the chat bubbles' ink outline, the icon in the middle, and a trail of two small puffs down
to the head. It shows for everyone, for 3.5 s (`ICON_SECONDS`), in a match and now also over the snail on the lobby's
stage (before, the lobby showed only the bubble beside the party card's name, which stays). It sits in the snail's
chat stack: a newer message or emote goes under it and takes the trail.

**Fixed.** The icon never showed over the snail: the ChatBubble gui's icon element (`S_Icon`) had never been exported
into the place, so building the bubble errored. The gui (with the new cloud) is exported into its holder.

**Where.** The ChatBubble gui's new prefab `PREFAB | Thought` (96 × 104: `S_Icon` 44 px, `S_Trail`, `S_Pop`), in
`Workspace.Ume.ReplicatedStorage_Assets/ChatBubbles/PREFAB | ChatBubble` › `U_ChatBubble`; `I.ChatBubbles.ShowIcon`
now builds it (`_buildThought`, `_setTrail` in ChatBubbles' `Client.lua`); Cosmetics' `_onEmotePlayed` calls
`ShowIcon` on every screen.

**How to check.** In the lobby, press an emote in the emote row: the cloud with its icon pops over your stage snail
(and the bubble beside your name), then fades. In a match, pick one on the wheel: the cloud pops over your snail,
above its name and health bar.

**For the wiki.** Emotes: the thought cloud, with a picture. Still unsure: the icons are local pictures
(`rbxasset://textures/wb_emotes/`) until the owner approves and they're uploaded, so on another PC or a live server
the cloud shows empty.
