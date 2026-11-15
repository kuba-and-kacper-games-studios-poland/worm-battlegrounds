---
title: "Shop prices show the number beside a Robux icon, at full button size"
date: 2026-11-15
status: open
kind: fixed
pages: ["Shop", "Loadout"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Shop/init.lua

---

**What changed.** The owner: "the prices are displayed incorrectly, the text on prices is too small". The shop's
prices carried Marketplace's Robux glyph, drawn as a small ring in the game's font, in a label so narrow that "199"
wrapped to two lines, and the Robux picture beside it was blank. Now every price button shows Roblox's own Robux icon
and the number alone (with thousands separators), both as tall as the button, on one line. The lobby's locked
loadout slot shows a pass's price the same way. Prices in Studio (Creator Hub, unchanged): packs 99, 199, 399, 599,
899; VIP 199, Double Coins 349, slot 5 149, slot 6 299.

**Where.** Shop's `Client._showPrice` and Loadout's `Panel._getPassPrice` call `I.G_Marketplace.GetProductPrice(…,
false)`; the Robux picture is `rbxasset://textures/ui/common/robux@3x.png` (the Shop gui's `RobuxIcon` and
`S_RobuxIcon`, Loadout's `ROBUX_ICON`). The Shop gui's `Price` rows fill 84 % of each button.

**How to check.** Open the shop from the currency bar's +: every button reads the Robux icon then "199" on one line.

**For the wiki.** Shop: nothing about prices changes, only how they look; a screenshot would be out of date.
