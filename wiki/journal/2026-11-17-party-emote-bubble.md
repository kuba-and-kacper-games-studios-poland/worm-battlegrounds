---
title: "Lobby emote bubble over the party card's avatar, clear of the name and badges"
date: 2026-11-17
status: open
kind: fixed
pages: ["Emotes", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
---

**What changed.** In the lobby a played emote's speech bubble pops up over the top right corner of the player's
avatar on their party card, its tail pointing down at the picture. Before, it sat where the name's text ended, which is
where the badges start, and covered them; in a custom lobby the panel's shrink pulled it onto the name. It now lives
inside the avatar, so the panel's layout and scale carry it, and it shows on the second column's compact cards too.

**Where.** `_showCardBubble` in Cosmetics' client `Emotes.lua`; `CARD_BUBBLE_ANCHOR` (0.84, 0.1) of the avatar and
`CARD_BUBBLE_SIZE` 0.62 of its height replace `CARD_BUBBLE_GAP`. It turns the avatar's `ClipsDescendants` off (the
Party gui's `S_Avatar` had it on from the design).

**How to check.** In the lobby, play an emote from the EMOTES panel: the bubble stands over the avatar's corner, the
name and badges uncovered, in a party and in a custom lobby of 8.

**For the wiki.** Emotes: where the bubble shows in the lobby.
