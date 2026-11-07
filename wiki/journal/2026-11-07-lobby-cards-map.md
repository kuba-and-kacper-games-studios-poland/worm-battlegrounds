---
title: "Lobby cards show their map and Join teams; the waiting room names the full mode"
date: 2026-11-07
status: open
kind: changed
pages: ["Lobby", "Guis"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Cells.lua
---

**What changed.** From the studio's wiki's match rows: each public card now shows its map's name under the mode, and
team cards say **Join teams** (Deathmatch keeps **Join**). Mode names read Deathmatch, Duo, Trio, Quads on the cards
(were Duos, Trios), and in full in the waiting room ("Duo team deathmatch • Picnic Plains"). The four cards, one per
mode, stay as the owner chose. The map pictures the wiki asks for aren't there: there's no art for them yet.

**Where.** `_refresh` in `MatchBoard/Scripts/Client/Board.lua`; `MODE_NAMES` and the new `MATCH_NAMES` in MatchBoard's
Settings. MatchBoard gui: `PREFAB | Row` › `S_Map` (the gui must be exported again in Studio for it to exist).

**How to check.** In the lobby, the Trio card reads "Trio", its map, and JOIN TEAMS; joining it shows "Trio team
deathmatch • Picnic Plains". Checked 2026-11-07 in Studio after exporting MatchBoard: the four cards read Deathmatch, Duo, Trio, Quads with their map, and Join or Join teams; the button is sized for "Join teams" (the template's text), so both labels read at one size. A later look showed the
wider button squeezed the cards ("Deathmatch" wrapped, the timer hid behind the button), so each card now has two
lines: the mode, players and timer across the top, the map and a small Join under them; the cards grew from 152 to
200 tall (the theme's `Matches` cells) and the panel from 700 to 800 (700 on phones and tablets, the list scrolling).
Checked in a Studio playtest: every mode name at full size, every timer showing, nothing overlapping.

**For the wiki.** Lobby → Bottom: play: the cards' map name and Join teams; After joining a match: the full mode name.
