# Map skies

Calm cartoon skies for the match maps, so the map stays the thing players look at: Picnic Plains (spring morning),
Volcano Isle (ember dusk), Rockslide Ridge (dusty highland), Desert (golden afternoon) and Mountains (crisp alpine
morning, for Echo Caverns' snowy mountain). Each one is a soft gradient with a few rounded clouds and low, hazed
shapes on the horizon in the map's own colours.

Everything is drawn by `skies.py`, the lobby sky's method (`art/lobby_sky`) with one theme class per map. No images
are downloaded.

## Build

```
python -I skies.py                              # every map's preview only (about 40 s)
python -I skies.py --faces                      # also the six 1024 faces and the unfolded cross
python -I skies.py --maps Desert --faces        # one map
python -I skies.py --size 512 --faces           # smaller faces
```

It writes `out/<MapId>/`: `sky_ft.png` … `sky_dn.png`, `preview_cross.png`, and `preview_view.png`, a wide view along
−Z (level, 70° vertical field of view, 16:9) that shows more than the match camera does. With `--faces` it prints the
worst seam ratio over the 12 cube edges (about 1 means seamless). Face orientations and the Roblox fold are the lobby
sky's (its README → Face convention).

## Composing for the match camera

The match camera always looks along −Z, level, with a 30° field of view (MatchCamera's `FOV`), so players see only a
narrow window of the sky around the horizon on the `SkyboxFt` side: about ±15° up and down and ±26° across on a 16:9
screen, whatever the pan or zoom. So:

- **The painting is tilted forward** by `Sky.HORIZON_DROP` (10°): its horizon sits under eye level on the `SkyboxFt`
  side, straight across the view, and rises toward `SkyboxBk`, which no match camera sees. A lower horizon shows more
  sky behind the map (the owner, 2026-11-25: "the bottom half is too long"). Dropping the elevation instead bends the
  horizon into an arch on screen.
- **The blue starts right over the horizon:** the haze band is the first few degrees, the sky's middle colour by
  about 10°, its top colour by about 30°. Clouds sit 8° to 18° up the painting, so they're in view.
- Anything tall (Volcano Isle's volcanoes, the Mountains' biggest peaks) stands toward the sides.

Build every shape once in a theme's `build()`, never with the random generator inside `paint()`: the paint runs once
per face, and random shapes there differ from face to face and break the seams.

The palettes and shapes are at the top of each theme class (`PicnicPlains`, `VolcanoIsle`, `RockslideRidge`,
`Desert`, `Mountains`).

## In the game

Atmosphere's `PROFILES` rows carry each map's `Sky` (the six faces' image ids, celestial bodies off), which goes on as
a lighting layer over the map's preset, with the Atmosphere's `Density`, `Haze` and `Glare` 0 and `Offset` 1 on the same layer
(Atmosphere's `MAP_SKY_ATMOSPHERE`): an Atmosphere with any density paints everything under the horizon in its own
colour, and its haze tints the sky even without density, which hid half the sky. Rolling Plains wears Picnic Plains' sky, Echo Caverns the Mountains sky. Rockslide
Ridge is an enclosed cave, so its sky shows only past the side walls and over the roof.

## Uploading

Decals to The Snail Studio group (566704940) through Open Cloud, from the approved upload folder
`art/sfx/out/upload/`. A Sky takes the image id, not the decal id (read it from the decal's `Texture` after
`InsertService:LoadAsset`).

The set in use (2026-11-25, tilted and with the blue lower; from `2026-11-25-skies-v2/`, titled "Snail <Map> Sky
<Face> v2", all 30 passed moderation):

| Map | Face | Decal | Image id |
| --- | --- | --- | --- |
| PicnicPlains | Ft | 134081701139161 | 126464635735668 |
| PicnicPlains | Bk | 109118111491039 | 121337561639918 |
| PicnicPlains | Lf | 75703404478485 | 117572288895021 |
| PicnicPlains | Rt | 120064342259503 | 105602696805183 |
| PicnicPlains | Up | 130883684770840 | 137807361860350 |
| PicnicPlains | Dn | 104909150185914 | 74008396460569 |
| VolcanoIsle | Ft | 100932318655485 | 133568701967211 |
| VolcanoIsle | Bk | 72465728634420 | 90205576169723 |
| VolcanoIsle | Lf | 103994305661570 | 73282958212064 |
| VolcanoIsle | Rt | 81384013316850 | 76596542266781 |
| VolcanoIsle | Up | 126171216502673 | 102639367163151 |
| VolcanoIsle | Dn | 140248079179752 | 128089118867016 |
| RockslideRidge | Ft | 78593844208182 | 133999400453106 |
| RockslideRidge | Bk | 82487336886990 | 103320266335414 |
| RockslideRidge | Lf | 130989871890690 | 136322873666391 |
| RockslideRidge | Rt | 138706481316133 | 140357849493459 |
| RockslideRidge | Up | 127569360570218 | 110602513746126 |
| RockslideRidge | Dn | 74221568532235 | 80043436557296 |
| Desert | Ft | 102330784106642 | 102365806436477 |
| Desert | Bk | 76728371667916 | 135129513740121 |
| Desert | Lf | 92633554578570 | 115442821608066 |
| Desert | Rt | 90403671127873 | 135581461397919 |
| Desert | Up | 114689035767551 | 92117620633408 |
| Desert | Dn | 79991206220769 | 81021285854766 |
| Mountains | Ft | 139491285679014 | 127431510175643 |
| Mountains | Bk | 75112211525964 | 126374831681029 |
| Mountains | Lf | 103201192098327 | 97924227413474 |
| Mountains | Rt | 122953116580000 | 116174505575380 |
| Mountains | Up | 70938292287044 | 120914019879607 |
| Mountains | Dn | 137370655884607 | 111141804188299 |

The first sets of that day (level horizon, a tall haze band) are replaced and unused: from `2026-11-25-skies/`, image
ids Picnic Plains Ft 79872244283439, Volcano Isle Ft 78680629130305, Rockslide Ridge Ft 127777375932284, Desert Ft
91795978502581 and Mountains Ft 134775140145734, with their other faces (titled "Snail <Map> Sky <Face>").

## Parallax layers

A skybox never moves or grows as the camera pans and zooms, so shapes painted in it look stuck to the screen. A map
with parallax layers keeps only a gradient in its skybox (`skies.py`'s `<Map>Gradient` theme), and its shapes stand in
the world behind it as flat pictures at their own depths (Atmosphere's `Parallax` rows, built on each client).

They're rendered in Blender in the maps' own brick look, then finished by `parallax.py`:

1. `desert_backdrop.blend`, scenes `DesertBackdrop`, `PlainsBackdrop` (Rolling Plains) and `MountainBackdrop` (Echo
   Caverns); its `voxel_lib` text block is `blender_voxel_lib.py`:
   `build_voxels` turns a list of landforms (mesa, butte, spire, bench, dune) into stepped brick columns, 5 studs
   across and 4 high (dunes 4 and 3); the `Sandstone` and `Sand` materials colour each brick row by strata, vary each
   brick a little, darken the seams and the steps (occlusion), and sand the tops; the `Cactus` boxes and voxel
   `Clouds` sit with them. A sun from the camera's side, upper left, matches the match's light.
2. `render_layer` renders a layer from the front with an orthographic camera tilted down 6° (so the stepped tops
   show), in tiles of 1024 px, with a transparent background, into `out/<Map>/parallax/raw/`. The clouds render one
   by one, front-on, under a cool sky light so their bellies read blue-grey.
3. `python -I parallax.py` hazes each layer toward the horizon's colour (more at its foot), softens only the far layer
   (1 px, premultiplied so edges stay clean; clouds and near layers stay sharp: the owner found more "too much"),
   samples the ground colour under each layer from its own bottom edge (or takes the theme's `SEA`, up to a layer's
   `sea_top`), writes `rows.json` (the layer rows) and a preview through the match camera
   (`preview.gif`, `preview_stills.png`).

Desert's layers (2026-11-25), from the play plane back: brick dunes and cacti 350 studs (2 tiles, 525 wide, and their
ground), voxel clouds 700 (4), brick mesas, buttes and spires 1100 (4 tiles, 500 wide, and their ground). In use,
from `art/sfx/out/upload/2026-11-25-desert-parallax-v2/` (titled "Snail Desert Backdrop <Layer> v2"), and the
gradient sky from `2026-11-25-desert-parallax/` ("Snail Desert Sky <Face> v3"); all passed moderation:

| Picture | Decal | Image id |
| --- | --- | --- |
| Sky Ft | 115228634526599 | 71270015180658 |
| Sky Bk | 106964768667396 | 98208496302416 |
| Sky Lf | 120294072913759 | 98114376317689 |
| Sky Rt | 101822430926426 | 126438811843569 |
| Sky Up | 116937242466259 | 76137748327422 |
| Sky Dn | 131907479534906 | 135538962182732 |
| Far 1 | 73405026038135 | 130661378778864 |
| Far 2 | 109308386312024 | 93069687422859 |
| Far 3 | 104939275162353 | 98922529645627 |
| Far 4 | 92885347886378 | 110765217904489 |
| Near 1 | 128641687384031 | 92808363681888 |
| Near 2 | 98556195635014 | 138039729329328 |
| Cloud 1 | 137595079941709 | 117350518482573 |
| Cloud 2 | 82656711639971 | 108381771125782 |
| Cloud 3 | 117313122827143 | 139012446744357 |
| Cloud 4 | 110149232230351 | 95169402656903 |

In use: the sharp set ("... sharp", from `2026-11-25-parallax-sharp/`, all three maps), only the far layer softened. The first, unblurred set of that day (titled without "v2", from `2026-11-25-desert-parallax/`) is replaced and unused.

Rolling Plains' and Echo Caverns' layers (2026-11-25; `python -I parallax.py RollingPlains EchoCaverns`), from
`art/sfx/out/upload/2026-11-25-parallax-rolling-echo/`, all passed moderation. Rolling Plains (scene `PlainsBackdrop`):
near small brick islands, the map's grass (40, 127, 71) capping its rock browns (`brick_material`'s `snow` with
`snow_rgb`), with blocky oaks and pines; a far line of low hazy islands (haze 0.3); over Picnic Plains' gradient sky
(`PicnicPlainsGradient`). The sea isn't in the pictures: the sea planes render as holdouts (transparent, hiding what's
under the waterline), and both layers' fills are one flat sea blue (the theme's `SEA`, 123, 180, 233), so the water
is a single colour to the horizon. Its far and near tiles were redone the same day (the `_v4` files in
`2026-11-25-rolling-islands/`): the first set, green hills all the way back, had too much grass in the wrong green,
and rendered seas left bands of different blues. All three maps' tables hold the sharp set (`2026-11-25-parallax-sharp/`),
whose far sea also reaches up over the far islands' feet (`sea_top` 24) so they don't float. Echo Caverns (scene `MountainBackdrop`): a far range of
grey-blue brick peaks, snow on their top third and lower in the middle, behind rounded foothills; near snowy rock hills
with snow-tipped pines; over the Mountains gradient sky (`MountainsGradient`). Both reuse Desert's four voxel clouds,
hazed to their own sky.

| Picture | Rolling Plains decal | Image id | Echo Caverns decal | Image id |
| --- | --- | --- | --- | --- |
| Sky Ft | 125656736787746 | 99363908139132 | 79347341178113 | 139125511340152 |
| Sky Bk | 71093944185015 | 137313082002092 | 136648159331625 | 79523563555922 |
| Sky Lf | 99472756909646 | 94095323195070 | 139351512944504 | 131048416551722 |
| Sky Rt | 98763944075666 | 130006245012592 | 136884310349987 | 77989498895287 |
| Sky Up | 75885095200814 | 103458071719063 | 119652866338081 | 126242536248773 |
| Sky Dn | 85573515682991 | 77273756312382 | 121949393883976 | 137571441310944 |
| Far 1 | 127333859724014 | 90492886631693 | 125294790907541 | 74510315412100 |
| Far 2 | 109612906132289 | 97779160747848 | 88080100714348 | 79426272421825 |
| Far 3 | 90968853850147 | 126654422829519 | 136621534511541 | 114325352282610 |
| Far 4 | 124828360958695 | 118309025375247 | 120286240302193 | 119966560497602 |
| Near 1 | 122130612951184 | 85231310851686 | 109664235413700 | 81484878649333 |
| Near 2 | 88405520223391 | 106383223101696 | 103193471311255 | 70830604089110 |
| Cloud 1 | 105814755706604 | 129166667994953 | 78880592692183 | 98672992888178 |
| Cloud 2 | 92096825526567 | 86974442104926 | 105182381262866 | 90974304724232 |
| Cloud 3 | 108643364987685 | 85010433092572 | 104636746521646 | 130289146969975 |
| Cloud 4 | 107392008806131 | 120459724898873 | 118935944817463 | 121409989482134 |

The Picnic Plains and Mountains skies with their shapes painted in (the tables above) are no longer used by Rolling
Plains or Echo Caverns; Picnic Plains, Volcano Isle and Rockslide Ridge, out of rotation, still have theirs.

The lobby's backdrop (2026-11-25; `python -I parallax.py Lobby`, scene `LobbyBackdrop`), drawn only on the loading
card's lobby scene: far snowy brick peaks (Echo Caverns' `MtnRock`) over grass-capped foothills, near a brick meadow
with oaks and pines, both green to their foot and filled with their own sampled grass (a layer's `fill`), over Picnic
Plains' gradient sky with Rolling Plains' four clouds (the same pictures, not uploaded again). From
`art/sfx/out/upload/2026-11-25-lobby-backdrop/`, all passed moderation:

| Picture | Decal | Image id |
| --- | --- | --- |
| Far 1 | 135010879147134 | 138969257928643 |
| Far 2 | 82270372572209 | 111750536991328 |
| Far 3 | 110666650815674 | 82666766422926 |
| Far 4 | 131792163320044 | 82800576469011 |
| Near 1 | 118576716708371 | 103337111307035 |
| Near 2 | 74704298412291 | 117186475164441 |
