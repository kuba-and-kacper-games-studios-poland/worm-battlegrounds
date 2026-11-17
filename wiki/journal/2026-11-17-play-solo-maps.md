---
title: "Play solo and Play with party: pick the map (or Random)"
date: 2026-11-17
status: open
kind: added
pages: ["Solo vs bots", "Maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Helpers/Rotation.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** The solo and party setup gets a map strip over it: Random, then the rotation's maps for the match's
size, as the custom lobby's map cards with their pictures. Before, the server picked a random map without saying. For a
1v1 that's Desert, Fluffy Fallout, Rolling Plains, Echo Caverns and Volcano Isle.

**Where.** `MatchBoard_PlaySolo` and `MatchBoard_PlayParty` carry a `mapId` (a rotation map for the size, or
"Random"); `Launch.GetMap(size, askedId)` takes it only when it fits. `Rotation.GetPlaySize` is the one size rule.

**For the wiki.** Solo vs bots: picking the map.

**Changed after the owner's second look (same day).** "They don't fit, they overlap… even structure is different"
from the draft: the setup is no longer the PlaySolo panel with a map strip floating over it. Solo, party and local play
open the custom lobby's window (its art, red ✕, map cards, player and bot buttons, yellow START), centred under the top
bar like the custom lobby's (both at 0.564 down, clear of the top-right menu, which covered the custom lobby's ✕): MAP
(Random first), PLAYERS (local play only, 2 to 8), BOTS (OFF only for a party or local play), the reward line with
the game's coin, START. MatchBoard's `U_Setup` (`S_MapList`, `S_PlayersRow`, `S_None`…`S_Hard`), `Setup.lua` (marks
picks with `Custom.SetPicked`); CustomLobby's `U_Create` and `U_Room` positions. For the wiki: one screenshot of the
window now covers Play solo, Play with party and Local play.
