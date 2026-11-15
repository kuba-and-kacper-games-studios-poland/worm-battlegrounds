---
title: "The studio's pictures for the shop's packs and passes, and a new coin and diamond"
date: 2026-11-15
status: open
kind: changed
pages: ["Shop", "Coins", "Diamonds", "VIP", "Double Coins"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/2_Currency/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Shop/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/EmoteShop/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegrounds/Icons.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Icons.lua

---

**What changed.** The studio drew the shop's pictures: each diamond pack has its own (Handful two diamonds,
Pouch three, Bag a pile, Chest a sack, Vault an open chest), and each pass too (VIP a crown, Double Coins two coins
with "2X", Loadout slot 5 and 6 slot frames numbered 4 and 5, as the owner chose). Their coin (with a snail) and
diamond replace the older coin and diamond pictures everywhere: the currency bar, the shop's balances, the crates,
the emote shop, the loadout's coin slot and the themes.

**Where.** Shop's `PACKS` and `PASSES` (`Icon`); Currency's `CURRENCIES` (`IconId`); the themes' `wb-coin` and
`wb-diamond`. Ids: coin 123804836570291, diamond 98200575516825; packs 108852031784319, 72342194438233,
85100866314854, 81930520222703, 108392197531787; VIP 84847875031526, Double Coins 76651166150720, slot 5
129986633237298, slot 6 90605961046404 (the game home's `assets/ui/icons/shop/uploaded.json`).

**How to check.** Open the shop: five different pack pictures, four pass pictures, a diamond and a snail coin on the
balances; the lobby's currency bar shows the same coin and diamond.

**For the wiki.** Coins and Diamonds: their icon (the infobox picture); Shop: the pack and pass pictures. The pack
pictures go by size (pack1 to pack5), so "Bag" shows a pile and "Chest" a sack; the owner chose to keep them so.
