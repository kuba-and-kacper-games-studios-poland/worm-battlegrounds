---
title: "Bots taunt with emotes after a knockout or a big hit"
date: 2026-11-13
status: open
kind: added
pages: ["Emotes", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
---

**What changed.** Bots now taunt (the owner: "make bots use emotes and taunt you when they kill you or damage you").
1.2 s after a bot's shot knocks out a snail not on its team, its snail plays one of Taunt, Laugh, Flex, Dance,
Backflip or Victory trumpet; after a shot that takes 20 or more health from one player (and knocks nobody out), one of
Laugh, Thumbs up, Flex or Taunt, 60 % of the time. It shows like a player's emote: the animation on the snail and the
icon in a thought cloud over it. A bot playing a dropped player's snail doesn't taunt.

**Where.** Bots' `TAUNT_KILL`, `TAUNT_HIT`, `TAUNT_DAMAGE` (20), `TAUNT_CHANCE` (0.6), `TAUNT_DELAY` (1.2);
`Server._onShotFired`, `_onShotResolved`, `_onDied`, `_taunt` (on Combat's `Combat_ShotFired` and
`Combat_ShotResolved` and Snails' `Snails_Died` Topics). Cosmetics' new `I.Cosmetics.PlaySnailEmote(snailId, emoteId)`
(the `EMOTE_COOLDOWN` per snail) fires the existing `Cosmetics_EmotePlayed` remote with the snail's id (`B_<n>`) in
place of a UserId; the client's `Emotes._onEmotePlayed` and `I.ChatBubbles.ShowIcon` take either.

**How to check.** Play Solo vs bots and let a bot hit you for 20+ or knock someone out: a second later its snail turns
to the camera, plays the emote, and the emote's icon pops up over it.

**For the wiki.** Emotes: bots use them to taunt. Match modules: Bots' taunts, Cosmetics' `PlaySnailEmote`.
