---
title: "Weapon, emote and currency icons uploaded: they show for everyone"
date: 2026-11-07
status: open
kind: fixed
pages: ["Guis", "Arsenal"]
files:
  - worm-battlegrounds-gui/src/themes/WormBattlegrounds/Icons.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Icons.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/
  - worm-battlegrounds-game/src/modules/Main/2_Currency/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Settings.lua
---

**What changed.** The first icon kit's 16 pictures and the Brawl kit's wind picture were local files in Studio's own
content folder (`rbxasset://textures/wb_guipreview/…`, `…/wb_brawlpreview/wind_…`), shown only on the PC that built
them. A Studio update wiped them, so every weapon, utility, emote, skin, crate, coin and diamond icon went blank. They
are now uploaded to Roblox (after PrepKit's pixel-fix) and everything points at the ids, so they show on every device
and survive Studio updates.

| Picture | Asset id |
| --- | --- |
| airstrike | 115087563446330 |
| arrow_down | 114953173843830 |
| arrow_right | 138975877289841 |
| bazooka | 134208977158560 |
| black_hole_grenade | 89182342013631 |
| cluster_bomb | 75424706546346 |
| coin | 108986846988315 |
| crate | 121731184312632 |
| crown | 92114882349999 |
| diamond | 76353040161236 |
| grenade | 127460985028992 |
| jetpack | 138428323433864 |
| plus | 105170609946702 |
| shotgun | 98515712319931 |
| smiley | 75798902746408 |
| stripes | 81566977120567 |
| wind | 107516600117967 |

**Where.** The themes' `Icons.lua`; the `IconId`s in the Inventory item data (weapons, utilities, emotes, skins),
Currency's `Settings.lua`, Arsenal's rows, the crates and the Shop's `Settings.lua`. The CrateOpen, Loadout and
MatchHud exports in the place were made again so their baked pictures use the ids. The ids are also in the game
home's `assets/_inbox/ui_kit/uploaded.json` and `ui_kit_brawl/uploaded.json`.

**How to check.** In a playtest the Loadout bar shows the smiley, the Bazooka and the coin; the currency bar shows the
coin and diamond; the match's turn panel shows the wind. No script or gui holds a `rbxasset://textures/wb_` path.

**For the wiki.** Guis: the note that the first kit's item, emote and skin pictures and the wind are local and blank
on other PCs no longer holds. Arsenal: the note that weapon pictures show only on the PC that built them, likewise.
Items without their own picture still show the crate placeholder.
