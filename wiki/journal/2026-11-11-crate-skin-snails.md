---
title: "Crates show the skins' snails: live 3D on still cards, pictures of the snails on rolling reels"
date: 2026-11-11
status: open
kind: changed
pages: ["Crates", "Skins"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/SkinModels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Odds.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - art/skins/picture_booth.luau
  - art/skins/make_pictures.py
---

**What changed.** On the GACHA screen a skin with its own snail shows that snail on its cards, in place of the skin's
placeholder picture (the owner: "make sure the skins display here (viewport frames) instead of the placeholder icons -
same in the rolling animation").

- **Still cards show the snail live**, in 3D, posed in its idle frame and framed as the Skins window frames it: the odds
  list, a 3-pack's and a 10-pack's result cards, the big reveal card, and the legendary's rising card.
- **Rolling reel cards show a picture of that same snail**: the x1 band and its lens, the x3 bands, the x10 columns and
  the golden reel. The owner picked this over live 3D on the reels ("Snail pictures"). A live snail costs Roblox 3 to
  4 ms the first time it's drawn, and a ViewportFrame isn't redrawn while it moves. Live 3D reels cost 11 to 25 ms a
  frame on the 10-pack and still left columns blank, where the pictures are as light as the old icons (about +1 ms).
- Skins without a snail of their own (FBI Agent, Prisoner, VIP, Wizard) keep their item picture everywhere.

**Where.**
- `SkinModels.lua`: `Put`, `Release`, the pool, and the redraw loop, which draws a card's snail again once the card
  holds still where it's seen (`SKIN_REDRAW_FRAMES`, 2 frames). Roblox left a card that flew in, or came back into
  view, with an empty picture box.
- `Reel.FillCard`: a reel card shows `SKIN_PICTURES[model]` in `S_Icon`.
- Settings `SKIN_PICTURES`: six image ids by snail model.
- The gui's `PREFAB | Card` and `PREFAB | OddsItem` each have an `S_Model` ViewportFrame.
- The pictures come from `art/skins` (README → Pictures): a booth in a playtest, a black and a white capture, and
  `make_pictures.py`.

**Uploaded** (The Snail Studio group, Decals, all passed moderation):
- Classic: decal 114623271263896, image 86349344725414
- Cowboy: decal 79430738422489, image 81535697083664
- Devil: decal 71413904534385, image 129536958641848
- Knight: decal 103034927014487, image 86133641830063
- Ninja: decal 102384588377402, image 91308817099254
- Skeleton: decal 91503535808891, image 103558601021448

**How to check.** Open a Skin crate x10: every column's cards show snail pictures as they roll, and the ten result cards
show live snails. x1 shows the pictures above the names and in the lens, then the big card is live. The Skeleton's
golden reveal card is live too.

**For the wiki.** Crates: the cards show each skin's snail (live when still, a picture while rolling). Skins: the crate
cards show the same snails as the Skins window.

**From.** The owner's request through the main session, 2026-11-11.

Still unsure: the Soldier, Pirate, Clown and Robot pictures are made but not uploaded (this session's permission check
refused those four uploads), so their reel cards still show the item picture until their ids are added to
`SKIN_PICTURES`. The place is unsaved until the owner saves it.
