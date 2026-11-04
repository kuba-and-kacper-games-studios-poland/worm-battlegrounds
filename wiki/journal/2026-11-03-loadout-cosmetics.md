---
title: "Loadout slots, items, skins, emotes and the emote shop"
date: 2026-11-03
status: open
kind: added
pages: ["Loadout & inventory", "Emotes", "Lobby", "Lobby & meta modules", "Data & networking"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/
  - worm-battlegrounds-game/src/modules/Main/2_Currency/Settings.lua
---

**What changed.**

- **Items:** every weapon, utility, skin and emote is an Inventory item (`Data/Items/<Category>/<Id>.lua`;
  categories Weapon, Utility, Skin, Emote, Other). Currencies are Coins and Diamonds (Cash is gone).
- **Loadout:** 3 slots; slot 4 for 2,500 coins or the Slot4 pass, slot 5 for 6,000 or Slot5. The Bazooka takes no
  slot. Pressing a slot opens the picker (owned weapons and utilities, with rarity, uses, cooldown and copies toward
  shiny); 10 copies make an item shiny. An item can't be in two slots.
- **Skins:** everyone gets Classic and the Wave emote. The Skins widget shows owned skins in a 3D preview with copies
  toward shiny and Equip; the lobby's skin button shows the worn one. 14 skin rows.
- **Emotes:** 9 rows with a level and a coin price; the Emote Shop sells them. The lobby's emote row (folded and
  unfolded by the smiley) and the match's emote wheel play them, at most once every 5 s; others see the emote's name
  over the worm for 2.5 s, or beside the name in the lobby's party list.

**Where.** `I.Loadout` (`Set`, `UnlockSlot`, `GetMatchLoadout`), remotes `Loadout_Set`, `Loadout_UnlockSlot`;
profile `Loadout = { Slots, CoinSlots = { Slot4, Slot5 } }`. `I.Cosmetics` (`Equip`, `BuyEmote`, `PlayEmote`,
`GetSkin`), remotes `Cosmetics_Equip`, `Cosmetics_BuyEmote`, `Cosmetics_PlayEmote`, `Cosmetics_EmotePlayed`; profile
`Cosmetics.EquippedSkin`.

**How to check.** In the Studio lobby, put Grenade in slot 1 (from the tutorial crate): the Loadout replicator's
`Slot1` reads Grenade, and the next match's bar shows it.

**For the wiki.** Loadout & inventory, Emotes. Placeholders: only the Classic worm model exists (every skin shows it),
and emotes show their name instead of an animation and voice line.
