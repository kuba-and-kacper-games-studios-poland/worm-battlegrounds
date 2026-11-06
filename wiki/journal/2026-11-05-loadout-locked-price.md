---
title: "Loadout: a locked slot shows only its price, at full size"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby", "Loadout"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/Preview.lua
---

**What changed.** The next locked loadout slot (slot 4, then 5) shows only its price on its dark cover, "2500 coins"
over two lines at full size. It used to say "Locked" with the price under it; the two didn't fit the slot, so the
price spilled out of the cover and shrank to a few pixels. The dark cover and the coin colour already say it's for
sale, and pressing it still asks whether to open it with coins.

**Where.** Loadout gui, `PREFAB | Slot` › `S_Lock`: the `Hud` box style (small padding), only `S_Price` (Grow 1); the
"Locked" label is gone. Loadout's `Panel.lua` still writes `{price} coins` from `SLOT_PRICES` (`2500`, `6000`).

**How to check.** In the lobby with 3 slots open, the fourth reads "2500 coins" in gold, inside its cover.

**For the wiki.** Loadout: how a locked slot looks (price only) if the page describes it.
