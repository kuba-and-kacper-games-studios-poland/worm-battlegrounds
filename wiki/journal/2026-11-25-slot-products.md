---
title: "Loadout slots 3 to 6 for Robux: developer products R$39 / 69 / 99 / 149"
date: 2026-11-25
status: open
kind: changed
pages: ["Loadout", "Shop"]
files:
  - worm-battlegrounds-game/src/global_data/Marketplace/Products.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Settings.lua
---

**What changed.** Loadout slots 3, 4, 5 and 6 can each be opened with Robux, as developer products made on the Creator
Hub that day (the owner): Loadout Slot 3 (id 3736173219, R$39), Loadout Slot 4 (3736173750, R$69), Loadout Slot 5
(3736173966, R$99), Loadout Slot 6 (3736174180, R$149), managed pricing off like the diamond packs. Slot 2 opens with
diamonds only (375). Pressing the next locked slot asks "Open slot 3 for 1,000 diamonds? (or R$ 39)"; without the
diamonds it offers "Open slot 3 now with Robux for R$ 39?" and prompts that slot's product, which is sold only while
it's the player's next slot. Diamonds still open every slot. The two slot game passes (Loadout slot 5 and 6) are no
longer sold, in the shop or on the slot; players who bought one keep its slot. The Creator Hub's developer products
now match the code: the five diamond packs and the four slots.

**Where.** `LoadoutSlot3` to `LoadoutSlot6` in `src/global_data/Marketplace/Products.lua` (`Requirements`: the next
slot; `Reward`: `I.Loadout.AddBoughtSlot`, saved as `Robux<n>` in the profile's `Loadout.CoinSlots`); Loadout's
`SLOT_PRODUCTS` and `AddBoughtSlot`; the panel's question (`_onSlotPressed`, `_getProductPrice`); Shop's `PASSES` without
the slot passes. `SLOT_PASSES` stays, counted for their owners.

**How to check.** In the lobby with too few diamonds, press the locked slot: both questions name R$ 39 for slot 3,
and ACCEPT on the second opens Roblox's purchase prompt. Checked in Studio up to the second question; the grant was
checked by calling slot 3's Reward on the server (2 slots open → 3, then slot 4's product the next on offer), and that
test slot was taken off the Studio profile after. A real purchase wasn't made.

**For the wiki.** Loadout: slot prices in diamonds, and Robux for slots 3 to 6. Shop: the slot passes are gone.
