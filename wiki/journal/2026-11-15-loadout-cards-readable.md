---
title: "Loadout cards: outlined name, copies and number around the picture"
date: 2026-11-15
status: open
kind: changed
pages: ["Loadout", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
---

**What changed.** The owner: "re-style how the text and amount look on the loadout in the menu on the right, the
texts are not readable". The lobby's LOADOUT cards had the item's name and copies ("x12") in the middle, over the
picture, thin and with no outline. Now the picture keeps the middle, the slot number sits top left, the copies top
right (Shiny under them), and the name in its rarity's colour in a band along the bottom; all heavy and outlined in
black. A locked card shows its price bigger, under the lock, with the coin or Robux icon left of it.

**Where.** The Loadout gui's `PREFAB | Slot`: `S_Number`, `S_Amount`, `S_Shiny`, `S_Name`, `S_Icon`, and `S_Lock` ›
`LockIcon`, `S_Price` › `CurrencyIcon`. The code that fills them (Loadout's `Panel._refresh`) is unchanged.

**How to check.** In the lobby, put a Medkit in a slot: "Medkit" in red with a black outline under the red medkit,
"x12" top right, the slot number top left.

**For the wiki.** Loadout: a screenshot of the panel would be out of date. A long name ("Black Hole Grenade") still
shrinks to fit the card.
