---
title: "Diamond packs and game passes created on Roblox, with real ids"
date: 2026-11-13
status: open
kind: added
pages: ["Currencies & crates", "Loadout", "Data & networking", "Meta modules", "Build plan"]
files:
  - worm-battlegrounds-game/src/global_data/Marketplace/Products.lua
  - worm-battlegrounds-game/src/global_data/Marketplace/GamePasses.lua
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.** The 5 diamond packs (developer products) and the 4 game passes now exist on the Creator Hub, in
the experience "[DEV] WB" (universe 10774518479), at the wiki's prices. Their ids replace the `Id = 0` placeholders,
so the shop shows live prices instead of "-".

| Entry | Name on Roblox | Id | Robux |
|---|---|---|---|
| `Diamonds_Handful` | Handful of Diamonds | 3730916908 | 99 |
| `Diamonds_Pouch` | Pouch of Diamonds | 3730917013 | 199 |
| `Diamonds_Bag` | Bag of Diamonds | 3730917086 | 399 |
| `Diamonds_Chest` | Chest of Diamonds | 3730917175 | 599 |
| `Diamonds_Vault` | Vault of Diamonds | 3730917219 | 899 |
| `VIP` | VIP | 2090714510 | 199 |
| `DoubleCoins` | Double Coins | 2089574514 | 349 |
| `Slot5` | Loadout Slot 5 | 2088224515 | 149 |
| `Slot6` | Loadout Slot 6 | 2088944528 | 299 |

Managed pricing (regional prices and price optimization) is **off** on all 9, so every player pays the prices above.
None has an icon yet (Roblox's default image). The two loadout passes were first made as Slot 4 (149) and Slot 5 (299),
then renamed the same day to Slot 5 and Slot 6 (same ids and prices) when slot 4 became coins only: see
2026-11-13-loadout-coin-slot-and-pass-slots.

**Where.** The `Id` of each row in `Products.lua` and `GamePasses.lua`; the placeholder rule in `game/practices.md`
→ Maps and placeholders now says products and passes are real.

**How to check.** Open the shop in a published test: each pack and pass shows its price, not "-". Buying a pack
adds its diamonds; the Creator Hub's Developer products and Passes pages list the ids above.

**For the wiki.** Currencies & crates: drop the private "Placeholder in the build" note; prices are now real, not a
proposal. Build plan: P11 is done. Data & networking and Meta modules: the rows that say "Ids are 0" now name the
real ids. Still unsure: the "Vault (10% off)" label with a crossed-out 999 and the crates' "10% off" 10-packs (the
honest-labels suggestion on Currencies & crates) are still open.
