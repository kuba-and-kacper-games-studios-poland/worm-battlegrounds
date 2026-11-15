---
title: "Seven shells get the artist's new art"
date: 2026-11-15
status: open
kind: changed
pages: ["Skins", "Garden Swirl", "Confetti Coil", "Saddlebag", "Hellfire Spiral", "Rampart", "Reactor Core", "Ossuary"]
files: []
---

**What changed.** The owner: "in workspace.New there are new snails, they have new shells, update existing shells from
our snails for the new updated ones". Seven shells now wear the artist's new art, blockier stepped swirls in each
set's colours: Garden Swirl (Classic), Confetti Coil (Clown), Saddlebag (Cowboy), Hellfire Spiral (Devil), Rampart
(Knight), Reactor Core (Robot) and Ossuary (Skeleton). Shadow Coil (Ninja), Treasure Hold (Pirate) and Bunker
(Soldier) were already the new art. The shells' shapes, ids, rarities and sets didn't change.

**Where.** In the place, not in code: each set snail's `Shell` in `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins`
kept its rigged mesh and got the new `SurfaceAppearance` (its own texture instead of the set's). Asset ids:
`art/skins/README.md` → Shell textures. The old ones are in `ServerStorage.!dump.Shells_Old_2026-11-15`, the artist's
snails in `ServerStorage.!dump.NewSnails_2026-11-15`.

**How to check.** The Style screen, a crate reveal or a match shows the new swirls on those seven shells.

**For the wiki.** Each shell's page picture and description. Still unsure: the crate reel pictures and the item
icons of those seven shells still show the old art until they're made and uploaded again.
