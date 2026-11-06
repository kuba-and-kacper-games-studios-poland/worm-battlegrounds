---
title: "Lobby panel like RoWorld's: Play solo up front, one public match per mode"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: changed
pages: ["Lobby", "Match modes & maps"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Cells.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** Before: the lobby had a yellow Play (quick match into the fullest public row) and Modes, a window
with Play solo (a second window), Custom lobby and the public rows, where the team rows were two random picks (Trios
was often missing). Now one panel at the bottom, laid out like RoWorld's: "Welcome, Name", the yellow **Play solo**
with **Custom** beside it, and **Public matches**: four purple cards, Deathmatch (4 players), Duos (4), Trios (6) and
Quads (8), each always there, with its players ("1 / 6"), its timer and **Join**. Play solo shows the setup in the
same spot: Easy, Medium or Hard bots, a line about them, what the match pays ("Only a win pays coins") and Start; Back
returns. Joining a card shows the waiting room there (match, countdown, players, Vote to start, Leave match). A card's
30-second timer starts when its first player joins; at 0 the match starts with whoever joined and bots fill every
empty seat, so one player can play Trios with two bot teammates. A started card is replaced by a fresh one of the same
mode. Mode names are now short: Deathmatch, Duos, Trios, Quads. The Modes and old Play solo windows are no longer
opened (their guis are still in the repo).

**Where.** `PUBLIC_ROWS` (replaces `DEATHMATCH_SIZES`, `TEAM_ROWS`, `TEAM_OPTIONS`), `MODE_NAMES`, `DIFFICULTY_TEXT`,
`REWARD_TEXT`, `ROW_SECONDS` 30 in MatchBoard's Settings. Gui: `U_Play` (`S_Welcome`, `S_Solo`, `S_Custom`, `U_Rows`
with the theme's `Matches` grid), `U_Setup`, `U_WaitingRoom`. Remotes unchanged: `MatchBoard_Join`, `MatchBoard_Vote`,
`MatchBoard_Leave`, `MatchBoard_PlaySolo`.

**How to check.** Studio playtest: the lobby shows the panel with four cards. Join Trios alone: after 30 s the match
starts as you and 2 bots against 3 bots (checked 2026-11-06).

**For the wiki.** Lobby: the new panel and the setup; drop the quick Play and the Modes window. Match modes & maps:
the four always-open public modes, bots filling empty seats when the timer ends. The stage camera (`LobbyStage`'s
`Camera` marker) moved 5 studs closer and tilts about 11° down, so the worm stands above the panel instead of behind
it; that's a place edit, in the place once it's saved.

**From.** The owner's request with RoWorld screenshots (2026-11-06).
