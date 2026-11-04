---
title: "First pass of every gui: 22 guis on the WormBattlegrounds theme"
date: 2026-11-03
status: open
kind: added
pages: ["Guis", "Lobby", "Match screen", "Currencies & crates", "Emotes", "Loadout & inventory"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/
  - worm-battlegrounds-gui/src/themes/WormBattlegrounds/
  - worm-battlegrounds-game/.claude/rules/game/practices.md
  - worm-battlegrounds-game/docs/game/lessons.md
---

**What changed.** Every gui on the Guis page now exists in the gui folder, with all its buttons, texts and containers,
the Ids and prefab names the page lists, a `_meta/README.md`, and a `Preview.lua` for the ones with lists or phases.
The look is a placeholder to be designed: dark purple panels, orange title banners, green buttons, Fredoka One, grid
icons where the art will go. Nothing is exported to StarterGui yet, and no game module drives them yet.

- **Lobby map:** `Lobby`, `MatchBoard`, `Party`, `Loadout`, `Crates`, `Currency` (System's, plus the coin and diamond
  bar), and the widgets `SoloSetup`, `CustomLobby`, `LoadoutPicker`, `CrateOpen`, `CrateOdds`, `Skins`, `EmoteShop`,
  `Shop`.
- **Match map:** `MatchHud`, `Results`, and the billboards `WormTag`, `DropMarker`, `DamagePop`.
- **Both:** `TutorialHint`, `TeleportGui`, `LobbyGui`. `Settings`, `Notify`, `WidgetManager_Message`,
  `WidgetManager_Confirmation` and `TopBar` still use System's copies (not copied yet).

**Where.** One folder per gui in `worm-battlegrounds-gui/src/guis/WormBattlegrounds/`. The theme
(`src/themes/WormBattlegrounds/`) holds the tokens (team colours `TeamRed`/`TeamBlue`/`TeamGreen`/`TeamYellow`, rarity
colours `Common` … `Legendary`, `Coin`, `Diamond`) and five game controls: `Widget`, `Box`, `Item`, `Cells`,
`Picture`.

**Differences from the Guis page.**
- `CustomLobby` picks the map from a grid of map cards (`U_Maps`, `PREFAB | MapChoice`) instead of a dropdown, and the
  mode and player count with buttons (`S_Deathmatch`, `S_Teams`, `S_Players2` … `S_Players8`): dropdowns don't work in
  exported guis.
- `MatchBoard` keeps the play part in `U_Play`, with `U_WaitingRoom` beside it in the same spot.
- `Crates`' cards show one button per currency (`S_PayCoins`, `S_PayDiamonds`); the free VIP crate is `S_Free` on the
  skin crate's card, and the tutorial crate is `U_TutorialCrate`.
- `MatchHud` adds `U_EmoteButton` (the smiley) and LB / RB hints (`S_PrevHint`, `S_NextHint`); `U_Touch` has
  `S_Left`, `S_Right`, `S_Jump`.
- `Results` can't be closed: `PreventClosing` is set on its ScreenGui after export (its README).
- `Currency`'s slots are named `Coins` and `Diamonds`; ume's Currency settings have only `Cash` so far.

**How to check.** In Studio, the Ume plugin's Gui tool, category `WormBattlegrounds`: every gui builds with no errors,
and the Preview settings fill the lists.

**For the wiki.** Guis page: note the differences above in the tables, and that the theme's controls are the building
blocks (the code folder's `game/practices.md` → Guis). Still open from the page's suggestions: rarity colours are now
theme tokens (suggestion `rarity-colours` is built in the theme, not yet answered), no team symbols, no controls-size
setting.
