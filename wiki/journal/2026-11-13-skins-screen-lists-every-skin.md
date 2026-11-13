---
title: "The Skins screen lists every skin in the live lobby"
date: 2026-11-13
status: open
kind: fixed
pages: ["Skins", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Skins.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/_meta/README.md
---

**What changed.** In the live lobby, the STYLE → Skins screen stopped after two tiles: one owned skin (Knight) and a
locked Wizard. Every other skin, owned ones too, was missing, so skins from crates couldn't be picked. Now all 14
skins show, the owned ones first and then the locked ones.

**Where.** `Module._preview` in Cosmetics' client `Skins` handler. A skin with no model of its own (FBI Agent,
Prisoner, VIP, Wizard) falls back to the Classic snail. That fallback read `I.Settings["Snails"].DEFAULT_SKIN`, but
Snails is a match-only module (`MATCH_ONLY` in `core/.../configs/place_loader.lua`), so on the Lobby map it is nil.
The error stopped the tile loop at the first such skin. The fallback now uses Cosmetics' own `DEFAULT_SKIN` row
(`I.G_Cosmetics.GetSkin("Skin_Classic").Model`), as the lobby's stage already did. Studio's default `Studio` map
loads both maps' modules, which is why the bug only showed in the real lobby.

**How to check.** In Studio set the Workspace attribute `Ume_StudioMapId` to `"Lobby"`, play, own a few skins and
open STYLE. All 14 tiles show, Wizard, VIP, FBI Agent and Prisoner as Classic snails under the lock.

**For the wiki.** Nothing changes on the pages: the Skins screen works as they already describe. Add a History line
on the Skins page if it lists fixes.
