---
title: "Mode icons on the lobby's buttons, cards and setup windows"
date: 2026-11-17
status: open
kind: added
pages: ["Lobby", "Game modes", "Solo vs bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
  - art/modes/icons.py
  - art/modes/build.py
---

**What changed.** Every way to play has an icon, drawn in the weapon icons' look (the owner asked for that style, and
for a better die before upload). They show left of the text on SOLO VS BOTS (a robot head; a party hat in a party),
LOCAL (a couch with a gamepad) and CUSTOM (a panel of sliders), on each public match card (Deathmatch a bullseye, Duo,
Trio and Quads two to four snails), before the setup window's title (robot, party hat or couch) and the custom
lobby's title (sliders), and the Random map card shows a die. Teams and Tutorial icons are uploaded but have no place
yet.

**Where.** MatchBoard's `MODE_ICONS` (the ones that change: Deathmatch, Duo, Trio, Quads, Bots, Party, Local), set by
Board (`S_ModeIcon` on each card, `S_SoloIcon`) and Setup (`S_TitleIcon`, `S_RandomIcon` on Random). LOCAL, CUSTOM and
the custom lobby's titles carry theirs in the gui (`ModeIcon`). The pictures: `art/modes` (icons.py draws them,
build.py renders them with the pixel fix); the decals and image ids are in its README (all approved at upload,
2026-11-17).

**How to check.** In the lobby each button and card shows its icon; Solo vs bots, Local and Custom open windows with
their icon before the title, and Random's card shows the die.

**For the wiki.** Lobby: a screenshot with the icons; Game modes: each mode's icon beside its name.
