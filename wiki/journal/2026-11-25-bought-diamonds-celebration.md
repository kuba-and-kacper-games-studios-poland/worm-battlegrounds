---
title: "Bought diamonds fly in with a fanfare once the shop closes"
date: 2026-11-25
status: open
kind: added
pages: ["Shop", "Diamonds", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/Client/Payout.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
---

**What changed.** Buying a diamond pack in the shop (Handful 250, Pouch 500, Bag 1,000, Chest 1,500, Vault 2,500, for
Robux) now celebrates once the player closes the shop (the owner: "make it satisfying - add like fanfares… a blue gem
vignette… make it feel REALLY good"). While the shop is open every diamonds counter (the shop's own and the lobby's at
the top right) keeps the count from before the purchase. On closing, "+amount" pops up over the player's snail on the lobby stage with the gift-claim sound,
the diamonds burst out of the snail and fly into the counter, which counts up as each lands with a rising clink, the
last one lands on the level-up fanfare, and the screen's edges glow a soft gem blue, breathing while they fly and
flashing as they land. Bigger packs throw more diamonds: 20 for 250, 28 for 500, 40 for 1,000, 49 for 1,500, 63 for
2,500. Several packs bought before closing play together. Nothing plays while the shop is still open; a pack Roblox
grants late (outside the shop) plays at once.

**Where.** The Shop client hears Marketplace's `Marketplace_ProductPurchaseSucceeded` (no new remote) and calls the
Progression client's new `I.Progression.HoldPurchase(amount, before)` and, on `WidgetManager_Closed` for `Shop`,
`I.Progression.PlayPurchase(amount)`. The payout is the match payout's (`Payout.Play`, with a `Progression_PayoutLook`),
and the vignette is the `PotionVignette` gui borrowed in the lobby (`Payout.SetVignette`). Settings in Progression:
`PURCHASE_ICONS_PER_ROOT` 1.25 (count = 1.25 × √amount), `PURCHASE_ICONS_MIN` 20, `PURCHASE_ICONS_MAX` 64,
`PURCHASE_DELAY` 0.35 s, `PURCHASE_POP_SOUND` `Free_Claim`, `PURCHASE_LAND_SOUND` `Level_Up`,
`PURCHASE_VIGNETTE_COLOR` 60, 140, 255, `PURCHASE_VIGNETTE_BREATH` 0.1 / 0.45. No new pictures or sounds.

**How to check.** In a Studio test open the shop, run the admin command `shop buy_pack <you> Diamonds_Vault` (it grants
the pack and tells the screen as a real receipt would): the shop's counter stays put; close the shop and the payout plays
and the counter lands on the new total. Checked in Studio on 2026-11-25: Vault then Handful held at 3,518 and landed on
6,268.

**For the wiki.** Shop (or Diamonds): buying a pack plays a celebration when the shop closes, the counter waits for it,
and bigger packs throw more diamonds; a History line for 25 Nov.
