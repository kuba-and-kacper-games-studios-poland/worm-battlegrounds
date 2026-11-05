---
title: "Lobby redesign: a 3D stage, one Play button, crates in a window"
date: 2026-11-05
status: open
kind: changed
pages: ["Lobby", "Lobby & meta modules", "Guis", "Currencies & crates", "Shop"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Skins.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/PlayModes/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Box.lua
---

**What changed.** The lobby no longer sits on a flat sky-blue background. The camera looks at a 3D stage where the
player's worm stands on a podium in its equipped skin, among Picnic Plains trees, with hills and clouds behind. On
screen:

- **Top centre:** the game's name, "WORM BATTLEGROUNDS", in gold. It's a text placeholder until there's a logo.
- **Top right:** the coins and diamonds bar (moved from the top middle), and under it two buttons, **Crates** and
  **Skins**.
- **Bottom centre:** one yellow **Play** button and a blue **Modes** button. Play is a quick match: it joins the open
  public match with the most players that still has room, a deathmatch on a tie. Modes opens a window with
  **Play solo**, **Custom lobby** and the list of public matches with Join.
- **Bottom left:** Loadout is a slim dark bar like the match's loadout bar. It has the emote row, then the Bazooka
  and the slots in one row (two rows on phones). Empty slots show a +, and locked slots show only the lock and price.
- **Top left:** Party, unchanged.

The crates moved from a side panel into a **Crates** window (two crates to a row), and Skins moved to the corner. The
top bar's **Shop** button is gone; the currency bar's + still opens the shop. The Crates button has a red badge: **FREE** while a free crate waits (the tutorial crate, or a VIP's daily skin crate), otherwise how many crates the player's coins can open (the cheapest coin crate: 350 coins and a 100-coin crate shows 3), **9+** past 9, and hidden when coins don't cover one. The tutorial's "Open your free crate!" hint and its arrow are gone; the loadout hint and arrow stay.

**Where.**

- The stage is the Model `LobbyStage` in `ServerStorage.Ume.PlaceLoader_Workspace/Lobby`, placed at 400 studs up and
  1200 out along Z. Its markers are `Markers/Camera` and `Markers/Worm`.
- `Lobby/Scripts/Client/Stage.lua` holds the camera there outside matches (field of view `STAGE_FOV` 40). It builds
  the worm from `EquippedSkin` into `Workspace.Ume.Lobby`.
- The quick match is `Module._quickJoin` in `MatchBoard/Scripts/Client/Board.lua`. It fires `MatchBoard_Join` with
  the row id, and the server checks it as before.
- The new gui `PlayModes` holds `U_Solo`, `U_Custom` and `U_Rows` with `PREFAB | Row`.
- `Crates` is now a WidgetManager window. `Lobby` › `U_OpenCrates` and `U_Skins` open the Crates and Skins windows.
- The badge is `U_OpenCrates` › `S_Badge` › `S_Count`, a new `Badge` Box style in the kit theme. `_refreshBadge` in
  `Crates/Scripts/Client/Panel.lua` fills it on `Currency_Changed` and Replicator changes; `BADGE_FREE` ("FREE") and
  `BADGE_MAX` (9) are Crates settings. The tutorial's `HINTS.Crate` was removed.

**How to check.** Play the Studio map. The view is the worm on its podium, with the name at the top. Play shows the
waiting room "Deathmatch · Picnic Plains, 1 / 4 players". Modes opens the window with Play solo, Custom lobby and
the public matches. Crates opens the crates window. The top bar has only the settings button. A new player's Crates button shows FREE; after
the free crate, 350 coins shows 3 and 1000 or more shows 9+.

**For the wiki.**

- Lobby: describe the stage and the new layout (name, corner buttons, Play and Modes, Loadout bar), what the quick
  match picks, and that crates and skins open from the corner.
- Guis: the `PlayModes` window, `Crates` as a window, the Lobby gui's new elements.
- Shop: it opens only from the currency bar's +.
- Currencies & crates: the Crates button's badge (FREE, how many crates the coins open, 9+).

Still unsure:

- The stage and the logo are placeholders until the owner's art exists.
- The waiting room is still the large 720 × 860 panel, and it covers the worm while the player waits.
- The layout wasn't checked on phone and tablet screens.
