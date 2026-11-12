---
title: "Bandage once every 4 turns, Medkit once every 6 with 2 uses (was 1)"
date: 2026-11-12
status: open
kind: changed
pages: ["Bandage", "Medkit", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/Bandage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Utilities/Medkit.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
---

**What changed.** The owner asked to limit the Bandage to once every 4 of the player's turns, and for the Medkit to
heal more with a longer wait. The Bandage (heals 40, 45 shiny, 2 uses) now has `Cooldown = 3`: used on a turn, it's
ready again 4 of the player's turns later. The Medkit (heals 100, 110 shiny) has `Cooldown = 5`, once every 6
turns, and 2 uses a match, up from 1, so its cooldown counts (the owner's pick). Utilities don't start the match on their cooldown, as strong weapons do: a heal is ready on the first turn,
and the wait starts when it's used.

**Where.** `Cooldown` in the two Arsenal rows (a new optional field on `Arsenal_UtilityData`) and the Medkit's `Uses`
(1 → 2); Combat's `Uses.Reset` and
the bots' `Sim._seat` put a starting cooldown only on weapons (`I.G_Arsenal.IsWeapon`). The HUD's loadout bar shows a
utility's cooldown the way it shows a weapon's (`Cooldown_<itemId>` in the Combat Replicator folder), and bots skip a
heal on cooldown (`I.Combat.CanUse`).

**How to check.** Use a Bandage: its slot shows 3 turns of cooldown, counting down on each of your turns, usable on the
4th. Not checked in play (the Studio test player had no utilities in its loadout).

**For the wiki.** Bandage and Medkit: a Cooldown row in each infobox (3 and 5 turns), the Medkit's uses 1 → 2,
and History lines.
