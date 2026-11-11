# Worm Battlegrounds: crate opening

The kit of the crate opening (2026-11-11, approved and built into the game the same day): a CS:GO-style reel on the
GACHA screen, themed crates with drawn icons, reveals for each rarity and a drop of its own for each legendary, and its
sounds (`../sfx/make_crates.py`). Since the same day the opening drops the crates in as 3D models (approved from the
draft 2 preview, built into the game on 2026-11-11). Its pictures and models are uploaded (Uploading, below); the game's
side is the `Crates` module and gui (their READMEs).

| File | What |
| --- | --- |
| `make_icons.py` | The crate icons (Weapon, Premium, Utility, Skin, Starter) and the lobby's STYLE button: each crate a box in a parallel projection, its planks, plates, ribbons and emblems drawn in each face's own coordinates, with the game's ink outline. Writes `out/<Name>.svg` (512 × 512) |
| `make_models.py` | The five crates as 3D models in Blender (draft 2, approved 2026-11-11), in the game's model look (chunky bevelled parts, flat colours; the stud pattern is laid on by the game). Each crate is the same moving pieces with their origins on their hinges: `Base`, `Inner` (the glowing floor), `Front` and `Back`, and `Left` and `Right` carrying `HatchL` and `HatchR`. Run inside Blender (the MCP's code tool, or `blender --python make_models.py -- <out>`); with an out dir it writes `Crate_<Name>.glb` and `crates.blend`. `rebuild(segments=1)` makes the game's lighter meshes |
| `bake_models.py` | The crates for the game: `make_models.py`'s crates with one bevel step, each crate's colours and the Roblox stud pattern baked (Cycles, diffuse colour) into one 1024 × 1024 texture on one UV map, and its eight pieces (`Base`, `Inner`, `Front`, `Back`, `Left`, `Right`, `HatchL`, `HatchR`, unparented) exported as one FBX. Run inside Blender: `main(r"<this folder>/out/roblox")` → `Crate_<Name>.fbx`, `Crate_<Name>.png`, `stud.png` |
| `fx.py` | The opening's effect pictures as SVG (white parts are tinted in game): the pedestal and its ring, the beam, the premium halo, the gold card's star, a spark, a bone, a bubble, a ring, the black hole's core and its accretion disk (a 4 × 8 flipbook of 256 × 128 frames) |
| `build.py` | Draws the icons and the effect pictures through headless Chrome or Edge at twice their size, scales them down and gives them PrepKit's pixel-fix (colour bled into the clear pixels, so edges don't go dark when Roblox scales them). Writes `out/png/<Name>.png` |
| `standins.py` | Stand-ins for the preview only: One Punch, Baseball bat and Parachute pictures, and a portrait per crate skin. Not for the game (those items still use the placeholder) |
| `preview/crate3d.js` | The preview's 3D crates (three.js, the GLBs in `preview/3d/`), lit as a Roblox ViewportFrame lights things (ambient plus one directional light, no shadows): they drop in, wait for a tap, rattle, spring their hatches, drop their walls and send up a ball of light; one in front and two behind for x3, a pyramid of 1, 2, 3 and 4 for x10, and the legendary's golden crate. `Crate3D.freeze(ms)` holds the opening's clock for screenshots |
| `preview/crate-preview.html`, `app.js`, `fx.js` | The playable preview: the GACHA screen in the game's 1920 × 1080 units built from the design's own frame pictures, the opening for 1, 3 and 10 crates, the reveals, review controls (force a rarity or a legendary, Quick open, sound), the sound board and the icon sheet |
| `preview/prep_assets.py` | Packs the pictures, icons and sounds into `preview/assets.js`, copies the GLBs from `out/3d/` into `preview/3d/` and writes `preview/local.html`. Fetches the design's frames and the item icons from Roblox's thumbnail service into `preview/rbx/` |
| `preview/shots.mjs` | Real-time screenshots of an opening through Chrome's DevTools protocol (`shots/<name>_<ms>.jpg`), for checking motion frame by frame |
| `out/`, `preview/assets.js`, `local.html`, `rbx/`, `shots/`, `3d/` | Made by the scripts, not kept in the repo |

## Build

Python 3 with numpy and Pillow, ffmpeg, and the sound kit's `tools/` (README there). Node 22 or later and Chrome for
`shots.mjs`.

```bash
python -I make_icons.py                   # out/*.svg
python -I build.py                        # out/png/*.png, for uploading
# in Blender (5.x): rebuild(r"<this folder>/out/3d") from make_models.py   -> out/3d/Crate_*.glb, crates.blend
# in Blender (5.x): main(r"<this folder>/out/roblox") from bake_models.py   -> out/roblox/Crate_*.fbx, Crate_*.png
cd ../sfx && python -I make_crates.py     # ../sfx/out/crates: WB_<Name>.wav/.ogg and crates.json
cd ../crates/preview && python -I prep_assets.py
python -m http.server 8765 --bind 127.0.0.1   # then open http://localhost:8765/local.html
node shots.mjs x1epic "auto=1&force=Epic" 1500,4000,8500
```

## The design

- **From CS2's own UI code:** a strip of 38 cards running right to left under a fixed line, on CS2's curve
  (`cubic-bezier(.075,.82,.165,1)`, 6 s); the line stops 10 % to 90 % across the winning card, so near misses happen
  by themselves; a sharp, slightly magnified centre window over a dimmed strip; legendaries never appear as filler,
  the gold star card shows only when won, then a golden reel picks which one.
- **Packs:** three stacked reels on one line (x3), ten columns falling past a horizontal line (x10); the rarest result
  stops last; the winners leave their reels for a row or a 5 × 2 grid, named one by one, the best last with a BEST
  ribbon and a summary by rarity.
- **Themes:** each crate's colour is its glow, rays, pedestal ring and ambient particles (embers, glints, bubbles,
  sparkles). Premium: violet backdrop, cyan and gold, a turning halo, a gold tab with a sheen; diamond prices turn
  the buy buttons blue with a gold rim on any crate.
- **Legendary drops:** Black hole grenade (the screen sucked into a black hole, an implosion, an accretion disk behind
  the card), Variety grenade (confetti and bouncing smileys, a rainbow), Skeleton skin (lightning, bones, green ghost
  flames), Low gravity potion (everything floating, bubbles rising).

## Uploading

The PNGs from `build.py` are staged in `../sfx/out/upload/` (the folder Studio's MCP may upload from) and uploaded
through Open Cloud as Decals to The Snail Studio group (566704940), titled after the file ("Crate Weapon", "Crate Fx
Pedestal Ring"); each decal's image id is read in Studio (`InsertService:LoadAsset`, the Decal's `Texture`). The
2026-11-11 set, by image id:

| Picture | Image id | Used by |
| --- | --- | --- |
| `Crate_Weapon` | 100039001608184 | The Weapon crate's `Picture`; the lobby's WEAPONS icon |
| `Crate_Premium` | 112183136204952 | The Premium crate's `Picture` |
| `Crate_Utility` | 111692496235544 | The Utility crate's `Picture` |
| `Crate_Skin` | 130190991872708 | The Skin crate's `Picture`; the lobby's SKINS icon |
| `Crate_Starter` | 136889158399800 | The Tutorial crate's `Picture` |
| `Menu_Style` | 130223906536662 | The lobby's STYLE icon |
| `Fx_Pedestal`, `Fx_PedestalRing` | 131050769890918, 85318843739807 | The Crates gui's `S_Pedestal`, `S_PedestalRing` |
| `Fx_Beam`, `Fx_Halo` | 137258172142357, 81751017155102 | `S_Beam`, `S_Halo` |
| `Fx_Star` | 112882352576448 | The gold card's `S_Star` |
| `Fx_Disk`, `Fx_Core` | 136082094315438, 121240356917502 | The black hole's `S_Disk` (flipbook) and `S_Core` |
| `Fx_Spark`, `Fx_Ring`, `Fx_Bone`, `Fx_Bubble` | 97296507263981, 134479561564722, 108730143339514, 138788798394435 | The Crates module's `FX_TEXTURES` |

### The 3D crates

`bake_models.py`'s FBXs and textures are staged in `../sfx/out/upload/` as `CrateModel_<Name>.fbx` and `.png`, and
uploaded through Open Cloud to the same group: each FBX as a Model, each texture as a Decal (its image id read as
above). All passed moderation on 2026-11-11.

| Crate | Model asset | Texture decal | Texture image id |
| --- | --- | --- | --- |
| Weapon | 73323979176816 | 130090390243898 | 116918883694049 |
| Premium | 119024943700934 | 103424589954885 | 115971865577120 |
| Utility | 117489702367144 | 83401386551085 | 135260262766812 |
| Skin | 105165043939816 | 107637117976841 | 75260511643482 |
| Starter | 102933455772099 | 111277090333513 | 89670239182867 |

In the place, each model's eight MeshParts make `PREFAB | Crate_<Name>` in `Workspace.Ume.ReplicatedStorage_Assets.Crates`
(the `Crates` module's README → In the place). An imported FBX comes in at 100 times its size (Blender metres read as
centimetres) and turned to Roblox's axes (Blender x, y, z → Roblox −x, z, y: the crate's front faces −Z), so each part
is divided by 100, takes its texture as `TextureID` (`Inner` is Neon with none), and gets its `PivotOffset` set so the
model's pivot is the middle of its floor: a MeshPart keeps the pivot the import gave it, which wins over the Model's
`WorldPivot`.

A redrawn picture or model is uploaded again as a new asset, and its id replaced where the tables say.
