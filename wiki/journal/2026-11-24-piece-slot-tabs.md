---
title: "Crate cards name a piece's slot on a corner tab; card snails centred"
date: 2026-11-24
status: open
kind: added
pages: ["Crates", "Style", "Skins"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/SkinModels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Odds.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Global.lua
---

**What changed.** Every snail piece's card on the crates screen names the slot the piece goes in: HAT, NECK, BODY or
SHELL. The owner picked a text tag over icons, then asked for it to be part of the card.

- **The tab.** It sits in the card's top-left corner, in the card's rarity colour, and follows the card's slant. The
  card's border is drawn over it, so it reads as part of the card.
  - It's built from copies of the card's own fill picture: tinted copies (`Fill`), and dark copies moved right (`Cut`)
    so the tab's right edge slants too.
  - The word is drawn over the snail, so a crown or eye stalks never cover it.
  - Elements: the Crates gui's `S_SlotTab` and `S_Slot`, on both `PREFAB | OddsItem` and `PREFAB | Card`.
  - Code: `SkinModels.ShowSlot(card, itemId, color)`, called by `Odds._addItem` and `Reel.FillCard`.
  - Weapons, utilities and the gold "???" card show no tab.
- **Where it shows:** the odds list, the rolling reels and the result cards.
- **The snails are centred in every piece card.** Cosmetics' `GetPieceShot` keeps each slot's angle and distance
  (`PIECE_SHOTS`), then slides the camera until the posed snail's bones are in the middle of the view. Before, the
  shell's and body's snails sat off to one side. This covers the crate cards and the Style screen's tiles.
- **The odds card's snail viewport** moved down a little (`S_Model` Y 0.02 → 0.07), clear of the tab.

**How to check.** Open the crates screen on SKINS: each card shows its slot on a tab in its rarity colour, and each
snail is centred. Open a skin crate: the reel and result cards carry the same tab.

**For the wiki.** Crates: piece cards show their slot. Style: the tiles' snails are centred.
