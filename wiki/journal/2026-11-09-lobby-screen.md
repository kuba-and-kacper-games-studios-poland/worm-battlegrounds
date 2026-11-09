---
title: "Lobby screen becomes the studio's LobbyInventory design"
date: 2026-11-09
status: open
kind: changed
pages: ["Lobby", "Loadout", "Party", "Matchmaking"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LoadoutPicker/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
---

**What changed.** The lobby screen is the studio's `LobbyInventory` design, ported almost 1:1:

- **Top right:** a STYLE / WEAPONS / SKINS menu (under the currency bar) in place of the Crates and Skins corner
  buttons. STYLE opens the Skins screen; WEAPONS and SKINS open the Crates screen on that crate. The badge ("FREE" or a
  count) sits on WEAPONS.
- **Left:** PARTY: a card per member (avatar, name, "Lv N", crown on the leader, Kick for the leader), then "+" cards
  for free places that open the invite box. The phone fold-behind-a-tab is gone. "Invite friends" is inside the invite
  box.
- **Right:** LOADOUT: cards numbered 1 to 6 (the Bazooka is 1), each with picture, name in rarity colour and
  copies ("x5"); empty slots show "+", the next locked one shows its price ("2500 coins", "6000 coins"). Below it the
  EMOTES row (smiley, owned emotes, + for the shop).
- **INVENTORY** (the loadout picker): every weapon and utility, owned first; unowned ones greyed under a lock. Uses and
  cooldown show on hover. EMPTY empties the slot.
- **Bottom:** ACTIVE LOBBIES: a row of cards, one per public mode (mode, "n/size players", map, timer, Join / Join
  teams), and at the bottom right CUSTOM and **SOLO VS BOTS** ("Play with party" in a party). The solo/party setup and
  the waiting room still take the board's place.
- Removed: the logo at the top and the "Welcome" line.
- The STYLE and Crates screens cover the whole screen; the lobby's panels hide while either is open
  (Lobby's `FULL_SCREEN_WIDGETS`, `LOBBY_GUIS`).

**How to check.** Studio play test 2026-11-09: every panel filled, the menu opened Crates and Skins (the lobby hid
behind them), a slot opened the picker, Solo vs bots started a match; no errors. Not checked: phones, 4:3 screens.

**For the wiki.** Lobby: the new layout and menu. Loadout: numbered cards, copies, the picker's locked items and
hover info. Party: invite cards. Matchmaking: the "Solo vs bots" name.
