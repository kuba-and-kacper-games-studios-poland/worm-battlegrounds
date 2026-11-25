---
title: "Weapon bar shows only owned items; no match sounds in the lobby; crate notice"
date: 2026-11-24
status: open
kind: fixed
pages: ["Match", "Crates", "Shop"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/BattleIntro.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
---

**What changed.**

- **The match's weapon bar shows only the items the player has.** A player with only the Bazooka sees one centred
  box. Before, empty "+" boxes filled the bar up to seven (`LoadoutBar._rebuild`).
- **No match intro, turn calls or drop ticks in the lobby.** This was found on the Studio map, where a match goes on
  beside the lobby after the player leaves it. The next round's intro played its fanfare (`Match_BattleBegins`) and
  shook the lobby camera, which made the stage snail twitch. The intro (`BattleIntro`), the turn callout's sounds
  (`Turn._onTurnStarted`, `_onSuddenDeath`) and the drop's ticks (`Panels._tick`) now play only while the player's
  `InMatch` attribute is set. On live servers each match has its own server, so players there likely never heard it.
- **A crate the server won't open says why on the crates screen.** Before, a "HEY! You can't open that crate right
  now" message box closed the crates screen.
  - A red notice pops over the crate for 2 s: "Not enough coins!", "Not enough diamonds!" or "Can't open that right
    now". The crates screen stays open.
  - Short of diamonds, the shop opens 1 s after the notice.
  - Where: the Crates gui's `S_Notice` (a bigger copy of the STANDARD plate); Crates `Panel._onRefused` and
    `_showNotice`; the settings `SHORT_*_MESSAGE`, `NOTICE_*` and `SHOP_GUI_NAME`.

**How to check.** In a match with only the Bazooka equipped, the bar shows one box. With 0 coins, press a coin price
on the crates screen: the notice pops and the screen stays open. Press a diamond price: the notice, then the shop.

**For the wiki.** Match: the weapon bar lists only what you carry. Crates: what happens when you can't afford a crate.
