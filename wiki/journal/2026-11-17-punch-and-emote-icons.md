---
title: "One Punch gets its icon; the studio's emote icons replace the drawn ones"
date: 2026-11-17
status: open
kind: changed
pages: ["Emotes", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/OnePunch.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Weapon/OnePunch.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Wave.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_ThumbsUp.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Laugh.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Dance.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Flex.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Taunt.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Cry.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_Backflip.lua
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Emote/Emote_VictoryTrumpet.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - art/emotes/README.md
---

**What changed.** One Punch had no picture: the loadout bar showed its model, and inventory cards showed the crate
placeholder. It now has the studio's fist icon (a chunky fist with brick studs). All nine emotes also got the
studio's own drawings of the same ideas, replacing the game's drawn set from 2026-11-11: Wave (a waving hand), Thumbs
Up, Laugh, Dance (music notes), Flex (a dumbbell, without the old pink grip and burst), Taunt (wink and tongue), Cry,
Backflip (a looping gold arrow) and Victory Trumpet. The Parachute still has no picture, since the studio hasn't sent
one yet, and keeps the crate placeholder.

**Where.** One Punch: `Icon` on the Arsenal row and `IconId` on the Inventory row, both `rbxassetid://137342798424801`
(decal 87913262433501, "Item Fist"). Emotes: each `Emote_<Id>` Inventory row's `IconId`. The new image ids, with
their decals, are in `art/emotes/README.md`: Wave 132166182456244, ThumbsUp 82202842734013, Laugh 123552394630328,
Dance 133815758839610, Flex 116083563568263, Taunt 104017914329926, Cry 94837384430812, Backflip 94262936265193,
VictoryTrumpet 111511858190336. Wave's id is also written into the Loadout gui's EMOTES button (`S_Shop` › `Icon`) and
the MatchHud gui's emote button and wheel slice (`S_Icon`, which code overwrites from the rows). All were uploaded to
The Snail Studio group and passed moderation at upload.

**How to check.** In a match, One Punch's slot on the loadout bar shows the fist. The lobby's EMOTES button, the
EMOTES panel, the emote wheel and the emote bubbles show the new drawings.

**For the wiki.** Arsenal: One Punch's icon. Emotes: the new icon for each emote (the Flex description changes from a
dumbbell in the snail's grip to a plain dumbbell).
