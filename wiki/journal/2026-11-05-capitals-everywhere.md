---
title: "Capitals everywhere: headings, titles and buttons stay in capitals"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Guis"]
files:
  - worm-battlegrounds-game/src/modules/Utils/TextCase/Client.lua
  - worm-battlegrounds-game/src/modules/Utils/TextCase/Components/Upper.lua
  - worm-battlegrounds-game/src/modules/Utils/TextCase/Components/Upper.comp.json
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Label.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Button.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Widget.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Box.lua
---

**What changed.** Every heading, title, button and window title in the game's guis is in capitals, including text the
game writes while you play. Before, only text drawn with the gui was in capitals, so the turn panel's wait, the waiting
room's countdown and vote button, the Results lines and the hints showed in mixed case under capitals titles.

**Where.** The theme's `Label`, `Button`, `Widget` and `Box` tag capitals text `TextCase_Upper`; the new TextCase module
(Utils) has the component that writes it in capitals whenever it changes, keeping rich text tags and escapes. Exported
again with the tag: MatchHud, TutorialHint, MatchBoard, Loadout, Results, Crates, CrateOdds, CrateOpen, CustomLobby,
Shop, EmoteShop, LoadoutPicker, PlayModes (and WormTag, for its own change).

**How to check.** Join a public match: "DEATHMATCH • PICNIC PLAINS", "MATCH STARTS IN 0:29", "VOTE TO START 0 / 1".
Play-tested: 115 tagged texts live, none in lower case but the touch arrows' `&lt;` and `&gt;`.

**For the wiki.** Guis: the kit's capitals rule (a style choice, nothing a player does). Probably a line, not a page.

**Merged.** A line on Guis, as the entry suggested.
