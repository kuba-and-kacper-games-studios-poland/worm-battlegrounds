---
title: "An XP bar under the diamonds in the lobby; the menu and the loadout column move down for it"
date: 2026-11-25
status: open
kind: added
pages: ["Levels & XP", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Nameplate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
---

**What changed.** The lobby shows the player's level at rest again, small, under the diamonds at the top right (the
owner's pick of four places, "under the diamonds"): the level-up replay's own thin bar ("make it this bar to keep it
consistent": the dark slot, faint ticks, the fill in the tier's colours with a bright edge) right under it, from the
diamonds plate's left edge to the +'s right edge ("longer and thinner than the diamond one"), halfway between the
diamonds and the menu, and a rank crest (the level in a dark middle, a rim in
the prestige tier's colours) on its left end. No text but
the level. It hides while the XP replay plays and shows the new level after it; it hides with the diamonds whenever a
window covers them. To make room (the owner: "you can lower all this to make the level bar fit"), the STYLE / WEAPONS /
SKINS menu and FREE WEAPONS moved down from Y 0.1 to 0.14, and the LOADOUT column's top from 0.2111 to 0.2511 with its
height 0.5176 → 0.4776, so its bottom (and EMOTES with all six slots open) reaches no further down than before; its
cards are about 8% smaller. Still unsure: with all six slots open, EMOTES' card ends at 0.728 of the screen's height
and the gear tile starts at 0.716, as before this change.

The stage's nameplates wear the same rank crest (the owner: "make sure this emblem is the same as the new gui
emblems"), painted in each player's tier colours, in place of the design's gold rounded square.

**Where.** The LevelPlate gui's `U_Rest` (a copy of the Currency gui's `U_Bar` row with stand-ins, so it lines up with
the diamonds plate on every screen shape: `S_RestTrack`, `S_RestFill`, `S_RestFillGradient`, `S_RestTierGradient`,
`S_RestLevel`); Progression's `REST_FILL_START` (0.14); Progression's client `_showRest`, called from `_showCurrent` (the `Level`, `XPIntoLevel`,
`XPForLevel` Replicator attributes).

**How to check.** In the lobby a long thin bar sits under the diamonds and the +, the crest and the level on its left
end, filled to `XPIntoLevel / XPForLevel`; the STYLE / WEAPONS / SKINS row starts below it (even gaps over and under it), and EMOTES stays above the gear tile.

**For the wiki.** Levels & XP and Lobby: where the level shows at rest (by the diamonds, and on the stage nameplates).

Narrows 2026-11-24-level-plate-hidden ("no level plate at rest"): the big plate still shows only for the replay.
