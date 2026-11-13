---
title: "Loadout up to 6 slots: slot 4 for 2,500 coins, slots 5 and 6 by game pass (149, 299)"
date: 2026-11-13
status: open
kind: changed
pages: ["Loadout", "Currencies & crates", "Match screen", "Lobby", "Meta modules", "Data & networking"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/global_data/Marketplace/GamePasses.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The owner's call (2026-11-13): "4th is for coins, and 5/6 is for robux". Before, slots 4 and 5 were
each Robux or coins (2,500 and 6,000), and slot 5 needed slot 4 first, so a Slot 5 pass bought first opened nothing.
Now:

| Slot | How it opens |
|---|---|
| 1–3 | Everyone |
| 4 | 2,500 coins only (the coin slot) |
| 5, 6 | The game passes Loadout Slot 5 (149 Robux, id 2088224515) and Loadout Slot 6 (299, id 2088944528) |

Each pass and the coin slot add one slot, **in any order**: a player with both passes and no coin slot has 5 slots,
and the coin slot then opens their 6th. A pass opens its slot the moment it's bought (before, only after rejoining).
The 6,000-coin price is gone; a profile that already bought slot 5 for coins keeps it.

The lobby's LOADOUT panel is a card wider: the Bazooka and slots 1–3 on top, slots 4–6 below, cards the same size.
The locked card shows the coin price while the coin slot is closed (pressing asks to pay coins), then the next pass's
live Robux price with a Robux icon (pressing opens Roblox's purchase prompt). The match's loadout bar holds 7 boxes
(the Bazooka and slots 1–6), picked with keys 1–7, wider by one box.

**Where.** Loadout's `MAX_SLOTS` 6, `COIN_SLOT_PRICE` "2500", `SLOT_PASSES` `{ "Slot5", "Slot6" }`,
`SLOTS_PER_ROW` 4, `COIN_ICON`, `ROBUX_ICON`; `GetUnlocked` counts base + coin slots + passes owned; `UnlockSlot` only
opens the coin slot; `Start` republishes on `Marketplace_GamePassPurchaseSucceeded-Slot5` / `-Slot6`. Profile
`Loadout.Slots` holds 6 ids and `Loadout.CoinSlots` is `{ Slot4 = false }`; the Replicator `Loadout` folder adds
`Slot6` and `CoinSlotOpen`. Marketplace rows `Slot4`/`Slot5` became `Slot5`/`Slot6` (the Creator Hub names too).
MatchHud's `SLOT_KEYS` adds `Seven`. The Shop lists "Loadout slot 5" and "Loadout slot 6".

**How to check.** In the lobby, a new player sees slot 4 locked at 2,500 coins; with it open, slot 5 shows the Robux
icon and 149. Buying a slot pass in a published test opens the next slot without rejoining. In a match with 6 slots
open, key 7 picks the sixth item. Checked in Studio on 2026-11-13: the panel with 3, 4 and 6 slots open, and the bar
with 7 boxes; a real purchase and phone screens weren't checked.

**For the wiki.** Loadout: slots 4–6 and how each opens, the panel's 4 + 3 rows, the 2026-11-13 History line; the
decided answer "Each of slots 4 and 5: Robux or coins, player's choice" is replaced, and the open question about free
slots at levels 20 and 40 should name slots 4–6. Currencies & crates → Game passes: Slot 5 (149) and Slot 6 (299),
each "One more loadout slot", no coin price for them; coins spend on slot 4 only. Match screen: 7 boxes, keys 1–7.
Supersedes the slot prices in 2026-11-13-products-and-passes-created (its ids and other prices still hold).
