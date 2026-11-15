---
title: "No more favourite pop-ups"
date: 2026-11-15
status: open
kind: removed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/configs/place_loader.lua
---

**What changed.** The game no longer asks players to favourite it. The owner: "remove the favorite pop-up showing in
the game entirely, even after purchase". Two prompts are gone:

- one 90 seconds after a player's first join;
- one 30 seconds after their first purchase.

**Where.** `Favorite_Controller` is in the place loader's `ALWAYS_OFF` list, so it's off on every map. Its saved keys
(`FirstTimePromptShown`, `MarketplacePromptShown`) stay untouched. The ume `Favorite` module still loads; nothing calls
it.

**How to check.** Join, wait two minutes and buy something: no favourite prompt opens.

**For the wiki.** Architecture: the controllers that are off.
