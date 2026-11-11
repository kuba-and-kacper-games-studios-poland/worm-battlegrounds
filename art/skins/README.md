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

## Pictures

The Crates reel cards show each snail as a picture while they roll (the owner's pick, 2026-11-11). A rolling reel can't
draw that many live snails; every still card shows its snail live. Each picture is the snail as a still card shows it:
posed in Idle's first frame, framed and lit as the Crates cards' `S_Model` viewport. The pictures are 320 × 256
transparent PNGs, made in Studio:

1. In a playtest, run `picture_booth.luau` in the client (Studio's MCP `execute_luau`, Client). It shows the ten snails
   six to a screen. Capture the screen with the booth black (`_G.SnailBooth.Paint(Color3.new(0, 0, 0))`) and white
   (`Paint(Color3.new(1, 1, 1))`), then `_G.SnailBooth.Screen(2)` and both again.
2. `python -I make_pictures.py <a_black> <a_white> <b_black> <b_white>`: the difference between each black and white
   capture gives the transparency. It writes `out/SnailSkin_<Model>.png` and copies them into `../sfx/out/upload/`.
3. Upload each as a Decal to The Snail Studio group (566704940) through Open Cloud (`POST /assets/v1/assets`), poll
   its operation, and read the image id in Studio (`InsertService:LoadAsset(decal)`, the Decal's `Texture`).
4. The image id goes in the Crates module's `SKIN_PICTURES`, by model.

Approved by the owner on 2026-11-11 ("Yes, upload them"); all six uploaded passed moderation.

| Snail | Decal | Image id |
| --- | --- | --- |
| `Classic` ("Snail Skin Classic") | 114623271263896 | 86349344725414 |
| `Cowboy` ("Snail Skin Cowboy") | 79430738422489 | 81535697083664 |
| `Devil` ("Snail Skin Devil") | 71413904534385 | 129536958641848 |
| `Knight` ("Snail Skin Knight") | 103034927014487 | 86133641830063 |
| `Ninja` ("Snail Skin Ninja") | 102384588377402 | 91308817099254 |
| `Skeleton` ("Snail Skin Skeleton") | 91503535808891 | 103558601021448 |

Not uploaded yet: `Soldier`, `Pirate`, `Clown` and `Robot` (made, and staged in `../sfx/out/upload/`). Until they are,
their reel cards show the skin's item picture. A new or redrawn snail gets its picture made and uploaded the same way.

| File | What |
| --- | --- |
| `rig_skins.py` | Imports the two OBJs, moves them into the rig's space, builds Classic's skeleton, rigs and exports each skin |
| `classic_bones.json` | Classic's skeleton, read from the place |
| `picture_booth.luau` | The picture booth: the posed snails, framed and lit as the cards' live ones, six to a screen |
| `make_pictures.py` | Turns the booth's black and white captures into the snails' pictures |
| `out/` | Made by `make_pictures.py`, not kept in the repo |
