---
title: "Lobby and match screens polished by the gui maker; new emote panel"
date: 2026-11-11
status: open
kind: changed
pages: ["Lobby", "Party", "Loadout", "Emotes", "Match HUD", "Shop"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/EmoteShop/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/EmoteShop.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Settings.lua
---

**What changed.** A gui maker's polish of six screens (Studio's `Workspace.Changes1_Gui`) is in the game:

- **Coins and diamonds** (top right): each on its own dark chip in the Gacha design's style, white counts, an orange
  **+** that opens the Shop.
- **Party card:** the display name and "@username" to the right of the avatar, the level on a badge under it
  ("LV 1"); name badges still follow the name.
- **Loadout's locked slot:** a darker locked card, a coin and the price ("2,500"; was "2500 coins").
- **Active lobbies:** each card has a small map picture on the left, the player count in orange, a new timer icon.
  **SOLO VS BOTS** and **Custom** are new painted buttons.
- **Match HUD:** a new painted FIRE button (touch), new power and stamina bars (`BAR_FILL` 0.744 → 1), and a wider
  JUMP button (touch).
- **Emotes:** the emote shop is now an **EMOTES** panel in the lobby's right column, where Loadout is (Loadout hides
  while it's open): three cards across, each with its rarity badge, icon and name; an emote not owned yet shows a lock,
  its price in coins and the level it needs ("Any level" for the first two), and a tap buys it. A red X (or B, or the
  + again) closes it. It opens from the + in Loadout's emote row, as before.

**Where.** The gui tables above; `PANEL_WIDGETS = { EmoteShop = { "Loadout" } }` in Lobby's Settings; the emote cards
in Cosmetics' `Scripts/Client/EmoteShop.lua` (`PREFAB | EmoteCard`); Party writes `S_Username` (`@{player.Name}`);
Currency and EmoteShop left ScreenScale's `GUIS` (they lay themselves out by screen fractions). No remote, price or
saved data changed: buying still goes through `Cosmetics_BuyEmote`.

**How to check.** In the lobby: the coin and diamond chips top right; the Party card shows "@" and your user name;
slot 5 reads 2,500 with a coin; press + by EMOTES and the panel replaces Loadout; X closes it. In a match: the stamina
bar fills to its end at 100%.

**For the wiki.** Lobby: the new currency chips and lobby cards. Party: the username line and level badge. Loadout:
the locked slot's price. Emotes: the panel (where it opens, what a locked card shows, how to buy). Match HUD: the new
bars and FIRE. Still open: the emote panel's close button and the locked card's price and level lines aren't in the
gui maker's design (built from the game's other cards); the gui maker may want to restyle them.
