---
title: "Emotes get icons, a speech bubble and stand-in animations"
date: 2026-11-11
status: open
kind: changed
pages: ["Emotes", "Lobby", "Chat"]
files:
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Settings.lua
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ChatBubble/init.lua
  - art/emotes/
---

**What changed.**

- **Icons:** every emote has its own icon (all nine showed the placeholder crate): Wave (a pink snail hand waving),
  Thumbs up (a pink fist), Laugh (the snail laughing with tears of joy), Dance (music notes), Flex (a dumbbell in the
  snail's pink grip), Taunt (winking, tongue out), Cry (streams of tears), Backflip (a loop arrow round the shell),
  Victory trumpet (a gold trumpet). They show on the emote shop's cards, the lobby's emote row and the match's wheel.
- **The bubble:** playing an emote pops its icon up in a speech bubble, in the chat bubbles' look (white, ink outline,
  tail), for everyone: over the snail in a match, in the same stack as its chat, for 3.5 s; in the lobby beside the
  player's name on their party card, its tail pointing at the name, for 3 s. It replaces the "Wave!" name label.
- **The animation:** the snail plays the emote on every screen (in a match, and on the lobby's stage). The real
  animations aren't made yet, so each emote plays a stand-in motion made in code: a wave of the near hand, a thumbs
  up with a hop, a laughing shake, a dance sway, flexing hands, a lean-in taunt, a sob, a full backflip, a trumpet
  victory bounce. An animation published under the emote's name later replaces its stand-in with no code change.

**Where.** Inventory rows' `IconId` (`rbxasset://textures/wb_emotes/Emote_<Id>.png`, local until approved); Cosmetics'
`_onEmotePlayed` and `_showCardBubble`, `EMOTE_SECONDS` 2.5 → 3, `CARD_BUBBLE_GAP` 8; ChatBubbles' new client API
`I.ChatBubbles.ShowIcon(userId, image)` and `BuildIconBubble(image, tailLeft?)`, `ICON_SIZE` 64 × 58, `ICON_SECONDS`
3.5; the ChatBubble gui's new `S_Icon`; SnailRig's `I.SnailRig.Emote(skin, emoteId, seconds)` (README → Emotes). No
new remote: `Cosmetics_EmotePlayed` already reached everyone.

**How to check.** In the lobby, press an emote in the emote row: your stage snail plays it and the icon pops up
beside your name on your party card; in a match, pick one on the wheel: the icon pops over your snail and it plays
the motion, seen by the others too.

**For the wiki.** Emotes: each emote's icon, the bubble, the stand-in motions until the animations exist. Lobby and
Chat: the emote bubble beside party names and over snails. Still unsure: the icons are local pictures until the owner
approves and they're uploaded.
