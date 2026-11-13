---
title: "The turn list shows every player's avatar, the snail only for bots"
date: 2026-11-13
status: open
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Teams.lua
---

**What changed.** The turn list's picture is the player's Roblox headshot for every player, and the bot picture only for bots (the `IsBot` attribute). Before, a player with a user id of 0 or less (Studio test players) showed the bot snail.

**Where.** MatchHud's `Teams.SetAvatar`.

**How to check.** In a match the playing player's picture is their avatar. Still unsure this was the testers' "worm": if they still see a snail for a player, it's another spot.

**For the wiki.** Match screen: the turn list's pictures.

**From.** The testers: "when its your turn show avatar of player which turn it is instead of worm".
