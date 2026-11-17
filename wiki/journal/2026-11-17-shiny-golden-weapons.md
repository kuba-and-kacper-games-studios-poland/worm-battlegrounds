---
title: "Golden weapons at 100 copies; Shiny and Golden look special everywhere"
date: 2026-11-17
status: open
kind: added
pages: ["Shiny", "Loadout", "Crates", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Variants.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Result.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LoadoutPicker/init.lua
---

**What changed.** A new tier above Shiny: owning **100 copies** of a weapon or utility makes it **Golden** (Shiny
stays at 10). Golden is a look only (the owner, 2026-11-17): a golden copy deals and boosts exactly as a shiny one
(×1.05 damage, a utility's `ShinyAmount`, SnailControl's `SHINY_BOOST`). Both now look special everywhere:

- **Held weapon, on every screen:** Shiny wears a pearly sheen (a ForceField copy of the model swaying pale cyan to
  pale pink), a cool-white outline and small star twinkles. Golden turns the model gold (dark details kept), with a
  bright gold sheen and outline, more and bigger twinkles and rising gold dust.
- **Shots:** a Shiny shot draws a thin prism line and sparkles beside its normal trail; a Golden one a thin gold line
  and dense gold glints.
- **Blasts:** the normal explosion always plays in full; a Shiny blast adds a ring of white-pink star sparks and the
  `Variant_Shiny` sound, a Golden one a gold shockwave ring, a shower of gold sparks, a ring of gold glints and
  `Variant_Golden`.
- **Cards:** the lobby's loadout slots and the INVENTORY picker show a Shiny item's card in a holo foil (rainbow
  colours scrolling, a sweeping sheen, twinkling sparkles) and a Golden one in a gold rim with a glint running round
  it; the slot's mark reads "Shiny" (pearly pink) or "Golden" (gold). Crate results do the same, and after Shiny the
  result counts on to Golden ("34 / 100 to golden"), with a "GOLDEN!" reveal (gold stars, `Variant_Golden`) on the
  100th copy. Snail pieces only go Shiny.
- **Fix:** a locked loadout slot's coin and price ("2,500") are centred under the lock as one (they hung to the
  right).

**Where.** `GOLDEN_COPIES = 100` in Loadout's and Crates' `Settings.lua` (beside `SHINY_COPIES = 10`); Crates'
`GOLDEN_CATEGORIES` (Weapon, Utility). `I.Loadout.GetMatchLoadout` returns a third table, the golden items; the match
card (`Matchmaking.GetCard`) and the participant (Match's `Roster`) carry `GoldenItems` beside `ShinyItems`. Combat's
server: `Blast.GetVariant(participantId, itemId)` ("Golden", "Shiny" or nil); a shot's `Variant`; the snail attribute
`HeldVariant` written with `HeldItem`; `Combat_Shot`'s options carry `Variant`; `Combat_Explosion`'s fourth argument
is now the variant (it was a `shiny` boolean). Every client's new `Combat/Scripts/Client/Variants.lua` draws the looks
from Combat's `VARIANT_LOOKS` (Vfx prefabs `Glint`, `Hit_Sparks`, `Ember`, `Explosion_Fire`, `Trail_Variety`, painted).
Cards: the Loadout and LoadoutPicker guis' `S_Foil` and `S_Gold` layers; Crates' `Result._dressCard`.

**How to check.** Give a test player 10 and then 100 copies of the Grenade (`inventory add_standard player Grenade 99`),
put it in the loadout: the slot shows the foil, then the gold rim and "Golden". In a match, hold it: every screen
shows the sheen, outline and twinkles (gold model and dust when golden); throw it: the accent trail, then the blast's
accents and sound over the normal explosion. Damage is the shiny ×1.05 either way. Open crates until an item reaches
100 copies: "GOLDEN!". Not yet checked in Studio.

**For the wiki.** Shiny (or a new Golden section): the 100-copy tier, looks only, what each looks like in the lobby,
in hand, in flight and in blasts. Loadout: the foil and rim on cards, the centred lock price. Crates: "n / 100 to
golden" and GOLDEN!. Arsenal: Golden deals as Shiny.

**Checked in Studio (2026-11-17).** Held Golden Bazooka: the SurfaceAppearance tint alone left its green picture green,
so a part with a SurfaceAppearance now also gets the see-through gold cover, and `GildCover` went 0.45 → 0.3; it reads
gold outdoors, darker in a cave. Golden blast: gold sparks over the normal explosion, no missing-prefab warnings.
