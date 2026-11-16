---
title: "Free Weapon crate for joining The Snail Studio group (once per player)"
date: 2026-11-16
status: open
kind: added
pages: ["Crates", "Shop", "Lobby"]
files:
  - worm-battlegrounds-game/src/global_data/Group/Groups.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/GroupReward.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
---

**What changed.** On the crates screen a yellow FREE CRATE badge (with a red 1) opens a dialog: FREE WEAPON CRATE,
the crate in 3D, step 1 "LIKE THE GAME" (only asked, no game can check it), step 2 "JOIN THE GROUP" (The Snail Studio)
with JOIN, then CLAIM CRATE. CLAIM is grey until the player is in the group ("Join The Snail Studio group first, then
claim your free crate!"), then green; it opens one Weapon crate on the crates screen like a bought one. Each player
gets it once; the badge goes away after.

**Where.** Group id: `Groups.lua` `SnailStudio` = 566704940. Crates settings `GROUP_CRATE` (`"Weapon"`),
`GROUP_NAME` (`"SnailStudio"`), `GROUP_GUI_NAME` (`"FreeCrate"`), `GROUP_JOIN_FIRST`. Saved: profile
`Crates.GroupCrateClaimed` (new profile key, `false` by default), mirrored to the client as Replicator `Crates` ›
`GroupCrateClaimed`. Remote: `Crates_Open` (RemoteFunction, client to server) accepts `payWith = "GroupReward"` for one
`GROUP_CRATE` while `I.Crates.CanClaimGroupCrate(player)` (unclaimed and a member). New gui `FreeCrate` (ScreenGui,
DisplayOrder 2), driven by `Crates/Scripts/Client/GroupReward.lua`.

**How to check.** In the lobby, open the crates screen: the badge shows; CLAIM says to join first; after joining the
group, CLAIM opens a Weapon crate and the badge is gone, also after rejoining. Not checked in Studio; the FreeCrate gui
must be exported to StarterGui for it to show.

**For the wiki.** Crates (and Shop, if it lists ways to get crates): the free group crate.
