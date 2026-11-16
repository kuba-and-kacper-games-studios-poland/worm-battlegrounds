---
title: "Tutorial: the loadout picker opens by itself for each starter weapon"
date: 2026-11-16
status: open
kind: changed
pages: ["Tutorial", "Loadout"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
---

**What changed.** Back in the lobby after the tutorial match, the guide no longer waits for the player to press a
loadout slot: it opens the INVENTORY picker (`LoadoutPicker`) for the first free slot by itself, with the "Pick the
Grenade" hint pointing at the card. Once the Grenade is in, it opens again for the next free slot, for the Shotgun. It
opens once per starter weapon, and only while no other window is open (a rejoin offer, crates, skins). A player who
closes it is pointed at the slot again ("press a slot"), and it doesn't come back for that weapon.

**Why.** The onboarding funnel showed 1,019 players reach step 7 (Equip, the "press a slot" hint) but only 274 reach
step 8 (Pick, the picker open): 73% never pressed the slot. A Studio playtest showed pressing it works, so the hint
was being skipped, not broken.

**Where.** `LobbyHints._tick` (the `autoOpened` set, one entry per starter weapon); `LobbyHints._getFreeSlot` now
returns the slot number. The new client `I.Loadout.OpenPicker(slot)` (`Panel.OpenPicker`) opens the picker with that
slot selected, as pressing it does. No new remote.

**Funnel.** The steps don't change: Equip (7) is still logged on the frame the picker opens, then Pick (8) and
Equipped (9) as before. Funnel numbers before and after this change don't compare at step 8.

**How to check.** In a playtest with `StudioTutorial` on, play the tutorial match: back in the lobby the picker is open
with the Grenade ringed; pick it, and the picker opens again for the Shotgun with slot 2 selected. Close it instead, and
it stays closed while the arrow points at the slot.

**For the wiki.** Tutorial: the lobby step (the picker opens by itself, once per weapon). Loadout: the client
`OpenPicker`, if the page lists the API.

**Still unsure.** Not checked on a phone-sized screen or with a pad.
