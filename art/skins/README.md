# Worm Battlegrounds: snail skins

The artist's skin snails (the owner put them in Studio's `Workspace.NewSnails` on 2026-11-11: "rename them based on
our skins we have in the game, RIG them, use the same animations as we use for the default snail"), rigged onto the
`Classic` snail's skeleton, so Classic's animations (`Assets/Snails/Animations`), SnailRig's holding, aiming and
emotes, and every place a skin shows work on them unchanged.

| Skin | Look | Model asset |
| --- | --- | --- |
| `Clown` | Purple, clown face and red nose, top hat, coloured hair, ruff | 130854139219848 |
| `Skeleton` | Bone white, skull eyes, black crown | 100374251444878 |
| `Devil` | Red, horns, bat wings, spiked collar | 139801998292141 |
| `Robot` | Steel grey, glowing blue eyes | 135924497989440 |
| `Knight` | Helmet with a blue plume, a shield on the chest | 113917564251489 |
| `Cowboy` | Cowboy hat with a star, red neckerchief | 98898262777789 |
| `Ninja` | Black, red headband | 104516934706418 |
| `Pirate` | Tricorn hat, red scarf | 132412478886215 |
| `Soldier` | Green army helmet with a star, green shell | 128800771586905 |

Each asset is the FBX `rig_skins.py` writes, uploaded through Open Cloud as a Model to The Snail Studio group
(566704940) on 2026-11-11; all passed moderation. Unused: 93943702719808 (a first Cowboy, its bones turned the wrong
way), 124132385828371 and 125814457921265 (the first Devil and Robot, whose unweighted vertices stretched to the
world's origin in game). The textures are the artist's own SurfaceAppearances, already in the place.

## How a skin is made

- **The skeleton is Classic's.** Classic is one rig, scaled 0.45 in Studio, whose rest pose has the shell floating
  above the back and the hands held out to the sides: every animation moves the shell bone (`Bone.013`) onto the back
  and the hand bones (`Bone.014.L`, `Bone.014.R`) in front. The artist's bodies are Classic's body mesh at full size
  (2.22 times Classic's), at rest; their shells sit where Idle puts Classic's.
- **`Body`** is the body, the skin's accessories (hats, helmets, scarves, collars) and Classic's two hands, in one
  skinned mesh. The body is weighted by Blender's bone heat to the body bones (the root, tail, spine, head and
  eyestalks; a piece bone heat can't solve, like the Devil's wings, takes the nearest weighted vertex's weights, as an
  unweighted vertex flies to the world's origin in Roblox); each accessory takes the weights of the body under it, with the eyestalks' going to the head, so a hat
  stays on the head; each hand is all on its hand bone and coloured like the body where it rests (its UVs on one spot
  of the skin's texture).
- **`Shell`** is the shell, all on `Bone.013`, moved back by the Idle animation's shell offset, so the animations put
  it where the artist placed it.
- **In Studio** each uploaded model keeps its RootPart (the bones), `Body` and `Shell` on Motor6Ds, gains the artist's
  SurfaceAppearance on both, an `Animator`, Classic's invisible `Handle` and its Motor6D, and is scaled 0.45; it goes
  in `ReplicatedStorage.Ume.Assets.PlaceLoader.Default.Skins` under the name its Skin data row's `Model` gives.

## Rigging

1. In Studio, in Edit mode: select `Workspace.NewSnails`, File → Export Selection, save `newsnails/newsnails.obj` in a
   work folder; select the `Classic` skin, export `classic/classic.obj` there. (Studio's export only works in Edit
   mode; a playtest's datamodel fails with "Failed to export obj".)
2. `classic_bones.json` holds each Classic bone's CFrame relative to the RootPart (`GetComponents`, in Classic's 0.45
   scale) and its parent. Classic's skeleton changes only if the studio re-rigs it; then dump it again.
3. In Blender 5: load `rig_skins.py` and call `run(work_folder, out_folder)`. It writes `SnailSkin_<Skin>.fbx` per skin
   (Roblox's FBX settings: FBX unit scale, no leaf bones, no baked animation).
4. Stage the FBXs in `../sfx/out/upload/` and upload each as a Model (`POST /assets/v1/assets`, `assetType` Model, the
   group as creator); poll its operation for the asset id.
5. In Studio, load each with `InsertService:LoadAsset` and build the skin as above (the table's ids are what's built).

A redrawn skin is uploaded again as a new asset, and its id replaced in the table.

## Pieces

Since 2026-11-14 (the owner: "divide the actual skins we have to accessories") each skin is a set of pieces worn in any
mix: a hat, a neck piece, a body and a shell (the Cosmetics module's sets and pieces). `split_skins.py` cuts each
rigged skin's `Body` apart. The join in `rig_skins.py` kept one material per source object, so a piece is a set of the
Body's materials (`PIECES`); each keeps its vertices' weights, so a hat stays on any snail's head.

| Set (skin) | Hat | Neck | Body | Shell |
| --- | --- | --- | --- | --- |
| Garden (`Classic`) | | | Garden Pink | Garden Swirl |
| Big Top (`Clown`) | Ringmaster Topper (top hat, hair, nose) | Frilly Ruff (with its pom-poms) | Greasepaint | Confetti Coil |
| Wild West (`Cowboy`) | Ten-Gallon | Dusty Bandana | | Saddlebag |
| Inferno (`Devil`) | | Spiked Collar | Brimstone (horns and wings baked in) | Hellfire Spiral |
| Round Table (`Knight`) | Plumed Helm | Crest Shield | | Rampart |
| Shadow Clan (`Ninja`) | Red Hachimaki | | Midnight | Shadow Coil |
| High Seas (`Pirate`) | Captain's Tricorn | Sea Scarf | | Treasure Hold |
| Circuit (`Robot`) | | | Chrome Plating (collar baked in) | Reactor Core |
| Crypt (`Skeleton`) | Lich Crown | | Bare Bones | Ossuary |
| Frontline (`Soldier`) | Field Helmet | Camo Scarf | | Bunker |

A set with no body of its own is the pink body under its accessories: it wears Garden Pink.

1. Run it headless on the rigged FBXs (`../sfx/out/upload/SnailSkin_<Skin>.fbx`):
   `blender -b --factory-startup --python split_skins.py -- <in_dir> <out_dir>`. It writes
   `SnailPieces_<Skin>.fbx` (the skeleton, `Body`, `Shell`, and `Hat` and `Neck` where the skin has them), imports
   each again and checks the skeleton and every vertex against the source (2026-11-14: all nine OK, no vertex moved
   more than 0.0001 stud).
2. Upload each as a Model to The Snail Studio group, as Rigging → 4 (only once the owner approves). Uploaded
   2026-11-14 through the Studio MCP's Open Cloud (the owner: "Yes, upload them"); all nine passed moderation:

   | Skin | Model asset ("Snail Pieces <Skin>") |
   | --- | --- |
   | `Clown` | 102443823878387 |
   | `Cowboy` | 78037013744152 |
   | `Devil` | 96030442321872 |
   | `Knight` | 113878935618013 |
   | `Ninja` | 112850928049447 |
   | `Pirate` | 109474684191957 |
   | `Robot` | 132097841101555 |
   | `Skeleton` | 126745834516171 |
   | `Soldier` | 125188960180754 |

3. In Studio, rebuild each snail in `Assets.Skins` from its pieces' model: the same RootPart, `Shell`, `Handle`,
   `Animator` and SurfaceAppearance as now (every piece takes the set's SurfaceAppearance: they share one texture), the
   new `Body`, and `Hat` and `Neck` MeshParts on Motor6Ds from the RootPart, as `Body` is.

Step 3 was done on 2026-11-14 for all nine (the whole skins are in `ServerStorage.!dump.Skins_Whole_2026-11-14`):
each snail's `Body` replaced by the cut one and `Hat` and `Neck` added, each a MeshPart with the set's
SurfaceAppearance and a Motor6D inside it from the RootPart (C0 the part's place on the root, as `Body` and `Shell`
had), scaled with the snail (0.45). Every piece wears its own set's texture wherever it's worn.

## Pictures

The Crates reel cards show each snail as a picture while they roll (the owner's pick, 2026-11-11). A rolling reel can't
draw that many live snails; every still card shows its snail live. Each picture is the snail as a still card shows it:
posed in Idle's first frame, framed and lit as the Crates cards' `S_Model` viewport. The pictures are 320 × 256
transparent PNGs, made in Studio:

1. In a playtest, run `picture_booth.luau` in the client (Studio's MCP `execute_luau`, Client). It shows the ten snails
   six to a screen. Capture the screen with the booth black (`_G.SnailBooth.Paint(Color3.new(0, 0, 0))`) and white
   (`Paint(Color3.new(1, 1, 1))`), then `_G.SnailBooth.Screen(2)` and both again.
2. `python -I make_pictures.py skins <a_black> <a_white> <b_black> <b_white>`: the difference between each black and white
   capture gives the transparency. It writes `out/SnailSkin_<Model>.png` and copies them into `../sfx/out/upload/`.
3. Upload each as a Decal to The Snail Studio group (566704940) through Open Cloud (`POST /assets/v1/assets`), poll
   its operation, and read the image id in Studio (`InsertService:LoadAsset(decal)`, the Decal's `Texture`).
4. The image id went in the Crates module's `SKIN_PICTURES`, by model (replaced by `PIECE_PICTURES` on 2026-11-14).

Approved by the owner on 2026-11-11 ("Yes, upload them"); all ten passed moderation.

| Snail | Decal | Image id |
| --- | --- | --- |
| `Classic` ("Snail Skin Classic") | 114623271263896 | 86349344725414 |
| `Clown` ("Snail Skin Clown") | 100125734706100 | 81428353214751 |
| `Cowboy` ("Snail Skin Cowboy") | 79430738422489 | 81535697083664 |
| `Devil` ("Snail Skin Devil") | 71413904534385 | 129536958641848 |
| `Knight` ("Snail Skin Knight") | 103034927014487 | 86133641830063 |
| `Ninja` ("Snail Skin Ninja") | 102384588377402 | 91308817099254 |
| `Pirate` ("Snail Skin Pirate") | 79103218182234 | 92516621597215 |
| `Robot` ("Snail Skin Robot") | 109582869308311 | 127764579921216 |
| `Skeleton` ("Snail Skin Skeleton") | 91503535808891 | 103558601021448 |
| `Soldier` ("Snail Skin Soldier") | 117493378261322 | 122213949366505 |

A new or redrawn snail gets its picture made and uploaded the same way; until then its reel cards show the skin's item
picture.

### Piece pictures

Since the Skin crate rolls pieces (2026-11-14, the owner: "needs to show accessories not skins", the golden legendary
reel too), its reel cards show each piece's picture: the piece on the showcase snail (`GetShowcase`), framed by
`GetPieceShot` as the still card frames it (down on a hat, round to a shell).

1. In a playtest, run `piece_booth.luau` in the client as a LocalScript. It shows the 29 pieces six to a screen, in
   id order. For screens 1 to 5 set the LocalPlayer's `BoothCommand` attribute to `"<n>:black"`, capture, then
   `"<n>:white"`, capture.
2. `python -I make_pictures.py pieces <1_black> <1_white> … <5_black> <5_white>`: writes
   `out/SnailPiece_<PieceId>.png` (the order read from Cosmetics' `Data/Pieces`) and copies them into
   `../sfx/out/upload/`.
3. Upload and read the image ids as step 3 above; each goes in the Crates module's `PIECE_PICTURES`, by piece.

Approved by the owner on 2026-11-14 ("Yes, upload them"); all 29 passed moderation. Each decal is titled
"Snail Piece <Slot> <Name>".

| Piece | Decal | Image id |
| --- | --- | --- |
| `Body_BareBones` | 85882131940102 | 80074478434512 |
| `Body_Brimstone` | 74209501721401 | 118813170196729 |
| `Body_ChromePlating` | 126885280755684 | 76381636906404 |
| `Body_GardenPink` | 94135302416308 | 126070750650734 |
| `Body_Greasepaint` | 125935595408563 | 96633096951149 |
| `Body_Midnight` | 132533502544078 | 85311614692852 |
| `Hat_CaptainsTricorn` | 118502964475009 | 135056987354085 |
| `Hat_FieldHelmet` | 85462064483285 | 101309397217180 |
| `Hat_LichCrown` | 110157848124279 | 124834777223000 |
| `Hat_PlumedHelm` | 123450771504461 | 78178626354983 |
| `Hat_RedHachimaki` | 118178579447763 | 100345101852523 |
| `Hat_RingmasterTopper` | 90914105607264 | 125953884372128 |
| `Hat_TenGallon` | 79144235539414 | 81386367168512 |
| `Neck_CamoScarf` | 112724041064334 | 107784575265186 |
| `Neck_CrestShield` | 128258640365350 | 105632554660040 |
| `Neck_DustyBandana` | 135654146794340 | 132218634265014 |
| `Neck_FrillyRuff` | 116523003047658 | 132670623238992 |
| `Neck_SeaScarf` | 96230377902096 | 122537884582716 |
| `Neck_SpikedCollar` | 124140929786805 | 137220668967623 |
| `Shell_Bunker` | 116424824514734 | 87105334966971 |
| `Shell_ConfettiCoil` | 133568228528734 | 123134201536568 |
| `Shell_GardenSwirl` | 97481741796977 | 119322806304281 |
| `Shell_HellfireSpiral` | 113967879174529 | 114094632129242 |
| `Shell_Ossuary` | 82750232451610 | 84698625447586 |
| `Shell_Rampart` | 89766474338634 | 84063160787956 |
| `Shell_ReactorCore` | 102948953836929 | 85928308867368 |
| `Shell_Saddlebag` | 110775919372074 | 133177146785625 |
| `Shell_ShadowCoil` | 122322689050096 | 90964512918642 |
| `Shell_TreasureHold` | 140437959674038 | 131182469070766 |

The set snails' pictures above are no longer shown anywhere: the Skin crate rolls pieces.

| File | What |
| --- | --- |
| `rig_skins.py` | Imports the two OBJs, moves them into the rig's space, builds Classic's skeleton, rigs and exports each skin |
| `split_skins.py` | Cuts each rigged skin's Body into its body, hat and neck piece (Pieces), and checks the result |
| `classic_bones.json` | Classic's skeleton, read from the place |
| `picture_booth.luau` | The picture booth: the posed snails, framed and lit as the cards' live ones, six to a screen |
| `piece_booth.luau` | The pieces' picture booth: each piece on the showcase snail, framed as the cards' live ones |
| `make_pictures.py` | Turns a booth's black and white captures into the snails' or pieces' pictures |
| `out/` | Made by `make_pictures.py`, not kept in the repo |
