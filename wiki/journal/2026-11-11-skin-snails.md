---
title: "Nine skins get their own snails: Clown, Skeleton, Devil, Robot, Knight, Cowboy, Ninja, Pirate, Soldier"
date: 2026-11-11
status: open
kind: added
pages: ["Skins", "Cosmetics", "Snails"]
files:
  - art/skins/
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Skins.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
---

**What changed.** Nine skins no longer wear the Classic snail: each has the artist's own snail (the owner put them in
Studio's `Workspace.NewSnails` on 2026-11-11), rigged onto Classic's skeleton, so the same animations (idle, walk,
hiding in the shell, the weapon poses, the emotes' stand-ins) play on them. Wherever a skin shows, its snail shows:
the lobby's stage, a match, the Skins window's tiles. The Skins window's previews now hold every snail, Classic
included, in its idle pose (shell on its back, hands in front) instead of the rig's rest pose (shell floating above
the back, hands held out), and fill their tile's picture (Cosmetics' `PREVIEW_DISTANCE` 1.6 → 0.6, aimed at the
snail's middle): before, each snail was a speck at the top of its tile.

| Skin (item id) | Rarity | Look |
| --- | --- | --- |
| Clown (`Skin_Clown`) | Rare | Purple, clown face, red nose, top hat, coloured hair, a ruff |
| Skeleton (`Skin_Skeleton`) | Legendary | Bone white, skull eyes, a black crown |
| Devil (`Skin_Devil`) | Epic | Red, horns, bat wings, a spiked collar |
| Robot (`Skin_Robot`) | Epic | Steel grey, glowing blue eyes |
| Knight (`Skin_Knight`) | Rare | A helmet with a blue plume, a shield on the chest |
| Cowboy (`Skin_Cowboy`) | Uncommon | A cowboy hat with a star, a red neckerchief |
| Ninja (`Skin_Ninja`) | Rare | Black, a red headband |
| Pirate (`Skin_Pirate`) | Uncommon | A tricorn hat, a red scarf |
| Soldier (`Skin_Soldier`) | Uncommon | A green army helmet with a star, a green shell |

Each snail has Classic's hands, coloured like its body. FBI Agent, Prisoner, VIP and Wizard still wear the Classic
snail.

**Where.** The models are `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins.<Name>` in the place (named by each
Skin data row's `Model`, unchanged), each from a Model asset uploaded to The Snail Studio group: Clown 130854139219848,
Skeleton 100374251444878, Devil 139801998292141, Robot 135924497989440, Knight 113917564251489, Cowboy 98898262777789,
Ninja 104516934706418, Pirate 132412478886215, Soldier 128800771586905 (the artist's SurfaceAppearances on them). The
rigging pipeline is `art/skins` (`rig_skins.py`, Blender; README). New API: `I.SnailRig.Pose(skin, name?)`, used by
Cosmetics' `Skins._preview`. The artist's originals in `Workspace.NewSnails` are renamed after their skins.

**How to check.** Equip each skin (an admin gives it): the lobby's stage snail wears it and idles; in a match it walks,
hides in its shell when hit, holds and aims weapons, and its shell breaks below 50 health. The Skins window's tiles
show each snail with its shell on its back.

**For the wiki.** Skins: each of the nine's look (a picture of each), and that the other four still look like Classic.
Still unsure: the place is unsaved until the owner saves it; the crate opening's Skin crate cards show these snails
once the crate work picks them up.
