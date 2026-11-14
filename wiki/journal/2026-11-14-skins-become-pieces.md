---
title: "Skins become pieces: hats, neck pieces, bodies and shells; the Style screen as card decks"
date: 2026-11-14
status: open
kind: changed
pages: ["Skins", "Style", "Crates", "Skin crate"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Skins.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/SkinsStage.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Data/Sets/
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Data/Pieces/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Hat/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Neck/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Body/
  - worm-battlegrounds-game/src/modules/Main/1_Inventory/Data/Items/Shell/
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Data/Crates/Skin.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/SkinModels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Reel.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Skins/init.lua
  - art/skins/split_skins.py
---

**What changed.** A snail no longer wears one whole skin. It wears four pieces, one per slot, in any mix: a hat, a
neck piece, a body and a shell. Each of the ten skins became a set of pieces with their own names (ids in brackets):

| Set (old skin) | Rarity | Hat | Neck | Body | Shell |
| --- | --- | --- | --- | --- | --- |
| Garden (Classic) | Common | | | Garden Pink (`Body_GardenPink`) | Garden Swirl (`Shell_GardenSwirl`) |
| Big Top (Clown) | Rare | Ringmaster Topper | Frilly Ruff | Greasepaint | Confetti Coil |
| Wild West (Cowboy) | Uncommon | Ten-Gallon | Dusty Bandana | | Saddlebag |
| Inferno (Devil) | Epic | | Spiked Collar | Brimstone | Hellfire Spiral |
| Round Table (Knight) | Rare | Plumed Helm | Crest Shield | | Rampart |
| Shadow Clan (Ninja) | Rare | Red Hachimaki | | Midnight | Shadow Coil |
| High Seas (Pirate) | Uncommon | Captain's Tricorn | Sea Scarf | | Treasure Hold |
| Circuit (Robot) | Epic | | | Chrome Plating | Reactor Core |
| Crypt (Skeleton) | Legendary | Lich Crown | | Bare Bones | Ossuary |
| Frontline (Soldier) | Uncommon | Field Helmet | Camo Scarf | | Bunker |

Ids are the slot and the name without spaces (`Hat_TenGallon`, `Neck_DustyBandana`, `Shell_Saddlebag`). Everyone
starts with Garden Pink and Garden Swirl (`STARTER_ITEMS`) and can wear no hat and no neck piece. Snail colours are
gone.

**Players who owned skins.** On their first join after the change, each skin they own gives every piece of its set as
many copies as the skin had (10 copies make a piece shiny, as before), and the skin they wore becomes the pieces they
wear (`Cosmetics.PiecesGiven`). The skins stay in their inventory. FBI Agent, Prisoner, VIP and Wizard have no snail
yet, so they give nothing until their art exists; they're still the level 25, 50 and 100 rewards and the VIP pass's.

**The Skin crate** rolls pieces now: each set's old chance is shared by its pieces (Wild West, High Seas and Frontline
20 % each, 6.67 % a piece; Shadow Clan, Round Table and Big Top 10 %; Inferno 7 %; Circuit 2 %; Crypt 1 %). Prices are
unchanged. The Crypt's three pieces get the Skeleton's legendary drop.

**The Style screen** (the `Skins` gui) is card decks: a deck per slot on the left (HATS, NECK, BODY, SHELLS) showing
how many are owned, the worn piece and three pieces on cards that fan out when it opens; the snail in the middle on a
pedestal with the player's name under it ("Drag to spin": a drag turns it all the way round), the camera easing to the
slot opened or picked (round to the shell, down onto the hat, in on the neck piece); the open slot's pieces on the
right, locked ones showing "SKIN CRATE"; and a detail bar with EQUIP, WORN or GET (opens the Skin crate).

**NEW tags.** An owned piece the player hasn't seen is NEW: a red NEW! tag (the crate cards') on the lobby's STYLE
button, on its deck and on its tile. Leaving the deck, or closing the screen, sees its pieces (`Cosmetics.SeenPieces`,
remote `Cosmetics_See`). Starter pieces are never NEW; pieces from a converted skin or a crate are.

**Models.** The cut pieces (`art/skins/split_skins.py`) were uploaded to the group on 2026-11-14 (ids in
`art/skins/README.md`) and every set snail in the place rebuilt from them, so any mix shows, each piece in its own
set's texture. Both guis (Skins, Lobby) are exported. The place still needs saving and publishing for live servers.

**Crate cards show the piece.** The Skin crate's still cards (results, odds) show a live snail framed on the piece
(down on a hat, round to a shell), and the rolling reels, the golden legendary reel too, show each piece's own
picture (Crates' `PIECE_PICTURES`, by piece id, in place of the whole-skin `SKIN_PICTURES`). The 29 pictures were
uploaded to the group as decals on 2026-11-14 ("Snail Piece <Slot> <Name>"; the decal and image ids in
`art/skins/README.md` → Piece pictures), all approved by moderation.

**How to check.** Checked in a Studio playtest on 2026-11-14: a profile owning 3 Cowboy and 12 Ninja skins, wearing
Cowboy, got 3 of each Wild West piece and 12 of each Shadow Clan piece and wore the Wild West pieces on Garden Pink;
equipping refuses an unowned piece; a Midnight body with the Ten-Gallon, Sea Scarf and Hellfire Spiral shows on the
Style screen and the lobby stage; leaving HATS cleared its NEW tags. Open a Skin crate: a piece comes out. A ten-pack's reels roll hats, scarves and shells as pictures, and a golden reel built from
the Skeleton pieces shows the Lich Crown, Bare Bones and Ossuary pictures.

**For the wiki.** Skins page: becomes pieces and sets (the table above). Style page: the new screen. Skin crate: the new
odds. A History line for the change.
