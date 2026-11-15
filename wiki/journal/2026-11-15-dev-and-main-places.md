---
title: "The game runs in a dev experience and the main one: place ids picked by universe"
date: 2026-11-15
status: open
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/configs/place_loader.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
---

**What changed.** The owner moved development to a dev experience; the game is published to the main one later. The
same place file now runs in both, each with its own lobby and match place:

| Experience | Universe | Lobby place | Match place (Arena) |
| --- | --- | --- | --- |
| Snail Battlegrounds (main) | 10774518479 | 83410278033601 | 118265066788984 |
| [DEV] Snail Lobby / [DEV] Snail Arena | 10776882453 | 82550122321970 | 75433175788458 |

The place loader's config picks the pair by `game.GameId` (`EXPERIENCES`, `MAIN_UNIVERSE_ID`); a place file in
neither (unpublished, GameId 0) plays as the main game. `LOBBY_PLACE_ID` and `MATCH_PLACE_ID` are now that pair, and
the config exposes the match place as `MatchPlaceId`. MatchBoard teleports matches to `I.Config.PlaceLoader.MatchPlaceId`;
its own `MATCH_PLACE_ID` setting is gone. So the dev lobby sends matches to the dev Arena, and the main lobby to the
main Arena.

**Where.** `EXPERIENCES` at the top of `place_loader.lua`, `MatchPlaceId` in its General section; `Module` in
MatchBoard's `Launch.lua` (the `I.Teleport` call).

**How to check.** In the dev experience, a match from the lobby lands in [DEV] Snail Arena (75433175788458) and the
match's end returns to [DEV] Snail Lobby; in the main game the same goes to its own places. Checked in the dev
place's Studio: the config picks 82550122321970 and 75433175788458 (GameId 10776882453), and the Lobby map boots on
82550122321970. Teleports only run on live servers, so the trip to the dev Arena is still to be seen there.

**For the wiki.** Architecture: the places section (the two experiences and their ids, picked by universe), and the
teleport table's `MATCH_PLACE_ID`, now the config's `MatchPlaceId`. Meta modules: MatchBoard's settings no longer list
`MATCH_PLACE_ID`. Still unsure: each experience has its own DataStores (dev saves are apart), and the developer
products and passes in `src/global_data/Marketplace/` belong to the main universe, so buying in the dev experience
fails until it has its own.
