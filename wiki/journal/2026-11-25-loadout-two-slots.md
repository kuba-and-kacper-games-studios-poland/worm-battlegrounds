---
title: "Loadout: new players start with the Bazooka and one slot; the rest are bought"
date: 2026-11-25
status: open
kind: changed
pages: ["Loadout", "Shop"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
---

**What changed.** The owner: "keep only 2 slots for weapons (bazooka always there), and other slots for coins or robux
(each being more expensive)". A new player has the Bazooka's slot and one free slot (`BASE_SLOTS` 1, was 3). Slots 2
to 6 open in order, each for its own diamond price (diamonds since the same day's coins-to-diamonds change; written in
coins first): slot 2 375, slot 3 1,000, slot 4 2,500, slot 5 6,000, slot 6 12,500 (`DIAMOND_SLOT_PRICES`). Pressing a
locked slot asks first, with its price; a player who can't pay is offered the next slot pass for Robux instead.

Players from before keep the slots they had: once per profile, a player who played the tutorial match or has a weapon
in any slot keeps slots 2 and 3 for free (`KEPT_SLOTS` 2, the saved `SlotsKept`), so nobody loses an equipped weapon.

**Where.** Loadout's `BASE_SLOTS`, `DIAMOND_SLOT_PRICES`, `KEPT_SLOTS`, `SLOT_PASSES`; Server's `_keepSlots`, the
template's `CoinSlots` and `SlotsKept`, `UnlockSlot`; Panel's `_onSlotPressed`.

**Still open.** Only Slot5 and Slot6 have game passes. Passes for slots 2 to 4 (planned "Loadout Slot 2/3/4" at
R$39, 69, 99) need the Studio Assistant's `game-pass:write` permission to be created through Open Cloud; until then
those slots are diamonds only, and `SLOT_PASSES` lists the two passes that exist.

**How to check.** On a fresh Studio profile the loadout shows the Bazooka and one open slot, then a lock with 375
diamonds on slot 2 (diamonds since). An older profile shows its three slots open.

**For the wiki.** Loadout: the slot count, the price table, the kept slots for old players, a History line. Shop: the
slot passes.
