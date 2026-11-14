# Arena

The destructible arena a match is played on, run by the server. At start it caches every map template in
`SAssets.Arenas` that has what a map needs, and readies it once (markers hidden, terrain in the `Terrain` group);
`Load` clones a cached template into `Workspace.Ume.Arena`: its terrain is ordinary parts (long parts for the shapes, smaller ones for
details) in the `2022 Stud` material. `Carve` subtracts a stepped circle running along Z from every terrain part it
touches (CSG with one box per row of the 1-stud squares whose centers are in the blast, so craters step like voxels on
the maps' grid), bedrock included, every part at once and swapped for its pieces in one frame, then drops each group
of pieces that no longer reaches bedrock standing on the map's floor. A dropped group falls by the game's own
gravity, straight down on the arena's plane and never turning, to where it first touches the terrain (or out of the
arena), and stays there anchored, so fallen pieces can bridge gaps. Every client cuts each hole itself the moment the
server announces it (`Arena_Carve`), on local pieces it shows in place of the real parts until the server's pieces
arrive, and draws each fall on its own frames (`Arena_Fall`). Water and lava are a separate grid
of half-stud cells stepped at 8 fps, so they move like a stop-motion brick film: they flow into craters, spill out of
broken basins, level out (also under debris that dips into them, as if under pressure), and get pushed up by debris
landing in them. Each run of liquid merges with the same run in the rows above into one rectangle in the
`2022 Small Stud` material, so still water is a few big parts. On a map holding both water and lava (from its
markers), each step the water cells touching lava (above, below or beside) leave the liquid and turn solid, built into
`Obsidian` terrain parts in the map's `Terrain` that blasts cut like any ground (Desert's oasis, where sudden death's
lava reaches it). The liquid joined to the sea counts as the sea: after a build, after `RaiseLiquid` and every
`SEA_MARK_STEPS` steps, the liquid of the sea's kind at or under its level along the grid's sides and floor, and all
of that kind touching it, is marked, so a pond the rising sea reaches is the sea's (water pooled low in a hole on the
land isn't). Only the open sea knocks snails out (`GetHazard`): the sea within `SEA_SLACK` of its level under a surface
`SEA_MIN_WIDTH` studs across, or under the land's floor; a small hole it seeps into is safe, a crater as wide as a
Black hole grenade's floods into sea. It also sets up the collision groups snails and terrain
use, and the plane snails are held on, and tells others when a map is ready (`Arena_Loaded`). It has no saved data.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Arena` |
| Runs on | Server, Client |
| Exposes | `I.Arena` (server) |
| Uses | `I.Create`, `I.Dirs.SAssets`, `I.Dirs.UmeWorkspace`, `I.Network`, `GeometryService`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.Arena`, `Load` (template, then liquid, then `Arena_Loaded`), `Carve` (numbers it and tells clients, then one carve at a time: cut, liquid, debris), `GetHazard`, the Studio test load |
| `Client.lua` | The client entry: starts the client handlers on `Workspace.Ume.Arena` |
| `Settings.lua` | `Arena_Settings`: carving, debris and liquid numbers |
| `Scripts/Server/Loader.lua` | Registers the collision groups; creates `Workspace.Ume.Arena`; caches the templates at start (checks each, moves it so its Bounds stand at X 0 on the plane, Z 0, hides its markers, puts its terrain in the `Terrain` group); clones a template's `Terrain`, `Decor` and `Markers`, notes its floor (the bottom of its lowest bedrock), makes the `Plane`; holds the references the other handlers read |
| `Scripts/Helpers/Cutter.lua` | Shared by both sides: `Build`, the blast's stepped shape (one box per row of the `CARVE_CELL` squares whose centers are within the radius, which the queries use), `Merge`, those boxes merged into one cutter (`UnionAsync`; cutting with one part is several times faster, measured 2026-11-13: a 14-stud blast over 36 parts from 0.86 s to 0.32 s; the boxes themselves where it can't, as in the PC gym), and `Subtract`, the cut with `GeometryService:SubtractAsync` (`SplitApart`; precise collision on the server, box collision for a client's pieces, which never collide), copying name, attributes and collision group onto each piece |
| `Scripts/Server/Carver.lua` | A carve on the server: cuts every anchored terrain part the cutter reaches, bedrock included, all at once, then parents every piece (marked `Arena_Carve`, the carve's number) before it removes any part, so clients never see a gap |
| `Scripts/Server/Debris.lua` | Contacts between parts, the support search from each carved piece (held up by bedrock whose bottom still reaches the floor; a cut ledge keeps only its biggest piece), numbering the ledges at load, and the falls: each loose group (lowest first) is swept straight down to where it lands, then moved there by gravity every frame and left anchored, or removed below the arena; the liquid looks again where a group landed and where it fell from |
| `Scripts/Server/Props.lua` | The map's props (`Arena_Prop`: trees, bushes, rocks): at load each moves back along Z until its front is `PROP_BEHIND_GAP` behind the play plane (its pivot kept `PROP_GROUND_MARGIN` in from the ground's back), and one still too deep for that is flattened along Z about its pivot until it fits (`_flatten`), so snails always pass in front of trees and rocks; after each blast, cuts the blast's stepped shape (Cutter's `Build`) through every part of the ones it reaches (CSG), throws each group of pieces no longer joined to the prop's base, drops the ones whose ground is gone, and fades what falls |
| `Scripts/Server/Liquid.lua` | The liquid grid: filling it from the markers over several frames, probing which cells terrain fills, the 8 fps step (falling, spreading, then pressure across each connected body, then on a map with both water and lava the water touching lava turning to obsidian), marking the liquid joined to the sea (`IsSea(position)`), where it's open (`IsOpenSea(position)`: the width of the surface over a position, which `GetHazard` reads), drawing the liquid as merged rectangles, the sea reaching `SEA_EDGE_WIDTH` past the map's sides |
| `Scripts/Server/Obsidian.lua` | `Build`: the cells that turned to obsidian, merged like the liquid (each row's runs with the same run in the row below) into `Obsidian` parts in the map's `Terrain`: `OBSIDIAN_COLOR`, SmoothPlastic with `OBSIDIAN_VARIANT`, anchored, in the `Terrain` group |
| `Scripts/Client/Carver.lua` | The hole on this screen: on `Arena_Carve` it cuts the terrain parts there itself (one carve at a time), hides each part (`LocalTransparencyModifier`) and shows its local pieces in `Predicted`; a server piece arriving from an earlier carve is cut again at once by the later ones; the local pieces go when the server removes their part, or after `PREDICT_TIMEOUT` when it never does |
| `Scripts/Client/Falling.lua` | On `Arena_Fall`, moves the group down every frame by the same gravity on the server's clock, so it falls smoothly |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `arena` command |
| `_meta/_types.lua` | `Arena_LiquidRect`, one drawn rectangle of liquid (or of obsidian); `Arena_PendingCarve` and `Arena_Prediction`, the client's carves waiting on the server and its hidden parts |

## API

### Server: `I.Arena`

| Function | Returns | What it does |
| --- | --- | --- |
| `Load(mapId: string)` | `boolean` | Clears the arena, clones the cached `SAssets.Arenas.<mapId>` into it and fills its liquids. `false` and a warning when there's no such template; a template without `Terrain`, `Markers` or `Markers.Bounds` is skipped with a warning at start |
| `Carve(center: Vector3, radius: number)` | | Tells every client at once (`Arena_Carve`), then cuts a round hole, stepped on the 1-stud grid, through the terrain at `center` (its Z is ignored), wakes the liquid around it and drops what lost its support. Carves wait for each other and run in order (yields) |
| `RaiseLiquid(rowsToFill: number)` | | Fills the lowest grid rows that still have room with the sea's liquid (water on a map without a sea), raising the sea level, marks the sea again and wakes the liquid: sudden death's rising sea |
| `GetBounds()` | `BasePart?` | The loaded map's `Bounds` marker |
| `GetMarkers()` | `Folder?` | The loaded map's `Markers` folder (`Bounds`, liquids) |
| `GetPlane()` | `Attachment?` | The attachment on the bounds' center whose axis runs along Z: a PlaneConstraint's `Attachment0` keeps a part on the plane |
| `GetLiquid(position: Vector3)` | `string?` | `"Water"`, `"Lava"` or `nil` at a position |
| `GetLandSpots(count: number, radius: number)` | `{ Vector3 }` | `count` random spots where a ball of `radius` stands on top of the terrain on any storey (under a floating ledge too; flat enough, out of liquid, below the bounds' top `START_TOP_GAP`), `LAND_SPOT_GAP` apart while there's room; fewer, or none, when the map has too little ground. Where bots and players who don't place start |
| `IsFree(position: Vector3, radius: number)` | `boolean` | Whether a ball of `radius` fits there for a snail to start from: inside the bounds below their top `START_TOP_GAP`, out of liquid (lava under it too), touching no terrain (the drop's spots) |
| `IsInLava(position: Vector3, radius: number)` | `boolean` | Whether a ball of `radius` centered there dips into lava, even a cell of it under the ball (Snails' burn, the bots' lava sense) |
| `GetLiquidKind()` | `string?` | The loaded map's sea liquid, `"Water"` or `"Lava"`; `nil` when it has no sea |
| `GetSeaLevel()` | `number` | The sea's surface height, raised by sudden death (`-math.huge` on a map without a sea) |
| `GetHazard(position: Vector3)` | `string?` | What knocks a snail out there: `"Water"` or `"Lava"` in the open sea (joined to the sea, no higher than its level plus `SEA_SLACK`, under a surface `SEA_MIN_WIDTH` studs across or more, or under the land's floor), `"Bounds"` beside or below the play area (above it is fine), `nil` when safe (a pond, a puddle, a small hole the sea seeped into, lava on the map, which burns instead) |
| `IsSettled()` | `boolean` | Whether no carved-off debris is still falling |

## Usage

```lua
I.Arena.Load("PicnicPlains")
I.Arena.Carve(explosionPosition, 6)
if I.Arena.GetHazard(snail.Position) then
	-- the snail drowned, burned or left the arena
end
```

## Network

### Server

**Topics**

- `Arena_Loaded @ (mapId: string)`: a map's template is in place and its liquids are filled.

**Send: RemoteEvents**

- `Arena_Carve @ (carveId: number, center: Vector3, radius: number)`: to every client when a carve is asked for, before it's cut; its pieces carry `Arena_Carve = carveId`.
- `Arena_Fall @ (group: { BasePart }, drop: number, started: number)`: to every client when a loose group starts to fall `drop` studs straight down at server time `started`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `CARVE_DEPTH_MARGIN` | `2` | How much longer than the bounds are deep the cutter is, so it cuts all the way through |
| `CARVE_CELL` | `1` | The grid blasts cut on, in studs, lined up with the maps' 1-stud grid: a blast takes every square whose center is within its radius, so craters are stepped |
| `CONTACT_MARGIN` | `0.15` | How far apart, in studs, two pieces may sit and still hold each other up, and how far above the floor a bedrock piece may end and still stand on it |
| `SUPPORT_SEARCH_LIMIT` | `400` | The most parts one support search walks before it counts the group as grounded |
| `PREDICT_TIMEOUT` | `3` | How long a hole a client cut on its own waits for the server's pieces, in seconds, before it's undone |
| `PROP_SUPPORT_DEPTH` | `1.5` | How far under a prop's base the ground may be before the prop falls |
| `PROP_BEHIND_GAP`, `PROP_GROUND_MARGIN` | `2.5`, `0.5` | At load a prop moves back until its front is this far behind the plane (half a snail's length, so a snail facing the camera clears it too), its pivot kept this far in from the ground's back; a prop still too deep is flattened along Z until its front is there |
| `PROP_BASE_HEIGHT` | `0.6` | After a cut, the pieces still joined (boxes within `CONTACT_MARGIN`) to a part starting at most this far above the prop's base stand; the rest is thrown |
| `PROP_KNOCK_SPEED`, `PROP_KNOCK_SPIN` | `35`, `6` | How fast a blast throws what it cuts off a prop, or a one-part prop it reaches (away from the blast and up), and the most it spins it (radians per second) |
| `PROP_FADE_DELAY`, `PROP_FADE_TWEENINFO` | `3`, 1 s Quad In | How long a fallen prop lies, then its fade before it's removed |
| `DEBRIS_KILL_DEPTH` | `20` | A falling group with no terrain under it falls this far below the bounds, then is removed |
| `LIQUID_CELL` | `0.5` | A liquid cell's width and height, in studs |
| `LIQUID_FPS` | `8` | Liquid steps per second |
| `LIQUID_VARIANT` | `"2022 Small Stud"` | MaterialService variant the liquid parts use: one stud per half-stud cell (terrain keeps its own) |
| `LIQUID_FALL` | `6` | How many cells a falling cell drops in one step |
| `LIQUID_PROBE_SCALE` | `0.5` | A cell is solid when terrain reaches into a box this share of its size around its center |
| `LIQUID_BUILD_ROWS_PER_FRAME` | `8` | How many grid rows a map's load probes before it gives the server a frame |
| `SEA_SLACK`, `SEA_MIN_WIDTH` | `1`, `16` | Liquid knocks snails out only in the open sea (liquid joined to the sea, whose marker starts at the bounds' bottom, raised by sudden death), up to `SEA_SLACK` studs above its level as it ripples, where the surface over it is at least `SEA_MIN_WIDTH` studs across (or under the land's floor). A pond (Desert's oasis, Lakeside's lake), a puddle or a small crater the sea seeps into is safe; a Dynamite or Black hole crater it floods isn't |
| `SEA_EDGE_WIDTH` | `120` (from 50 on 2026-11-13, as the match camera now goes half a view past the sides) | How far the sea is drawn past the map's left and right sides, up to its level, so the camera never shows where it ends: the sea's blocks at the sides reach out, and a block outside tops it up where land stands at a side. Only drawn: the grid stops at the sides, and out there is out of bounds |
| `SEA_MARK_STEPS` | `8` | Every this many liquid steps (and after a build and each `RaiseLiquid`) the liquid joined to the sea is marked again |
| `OBSIDIAN_COLOR`, `OBSIDIAN_VARIANT` | `(38, 28, 52)`, `"2022 Stud"` | The obsidian parts lava makes of the water it touches: their colour and MaterialService variant (on SmoothPlastic, like the terrain) |
| `LAND_SPOT_STEP`, `LAND_SPOT_GAP` | `2`, `16` | `GetLandSpots` looks for ground every 2 studs along the arena, on every storey, and keeps spots 16 studs apart while there's room |
| `LAND_SPOT_MIN_NORMAL` | `0.7` | The steepest ground a land spot may be on (the lowest Y of its normal; 1 is flat) |
| `START_TOP_GAP` | `20` | Nothing starts in the bounds' top 20 studs (land spots, drop picks): land that high has no room to parachute onto (Match's `DROP_HEIGHT`), and is a map's roof, like Rockslide Ridge's rock ceiling |
| `LIQUID_KINDS` | `{ "Water", "Lava" }` | The liquid kinds, in the order of their ids in the grid |
| `LIQUID_SPREAD` | `{ Water = 12, Lava = 3 }` | How many cells a cell moves sideways in one step, toward the nearest way down along its row |
| `LIQUID_PRESSURE` | `{ Water = 8, Lava = 2 }` | How many of its highest cells one connected body moves each step into lower free cells beside it, so it levels through gaps and under debris |
| `LIQUID_COLORS` | Water `40, 140, 230`, Lava `179, 89, 47` | The blocks' colours, unless the map's marker has `Arena_LiquidColor` |
| `LIQUID_TRANSPARENCY` | Water `0.2`, Lava `0` | The blocks' transparency |
| `COLLISION_GROUPS` | `Terrain`, `Snail`, `Projectile`, `Ghost`, `Chip` | Collision groups registered at start, each with the groups it doesn't collide with: snails pass through each other and through `Default` parts (avatars, props), ghosts through everything, the chunks blasts throw (Combat's client effects) collide with terrain only |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Arena` | Created at start. Holds the loaded map's `Terrain` (its parts in the `Terrain` collision group, and the `Obsidian` parts lava makes of water), `Decor` and `Markers`, plus `Liquid` (the drawn rectangles, each with an `Arena_Liquid` attribute naming its kind, which Atmosphere's effects read), the probe part the liquid uses, and `Plane` (an invisible part at the bounds' center holding the `Plane` attachment). Each client adds `Predicted`, its local pieces of holes the server hasn't cut yet |
| `SAssets.Arenas.<MapId>` | A map template, authored in `Workspace.Ume.ServerStorage_Assets/Arenas/`, which the Utils module moves into `ServerStorage.Ume.Assets` (`I.Dirs.SAssets`) when the game starts. A Model with the folders below |
| `<MapId>.Terrain` | The map's parts, anchored. `Arena_Indestructible = true` marks the map's bedrock (the name is from before blasts could cut it): blasts cut it like
any terrain, and a piece of it whose bottom still reaches the map's floor (the bottom of its lowest bedrock part) holds
up everything it touches, while a piece cut loose from the floor falls. Every map needs some. `Arena_Floats = true` marks floating terrain (ledges). At load each group of touching ledge parts gets its own number, `Arena_Ledge`; when a blast cuts a ledge apart, its biggest piece keeps floating and every other piece falls (and is plain ground where it lands). Carved pieces keep these attributes |
| `<MapId>.Decor` | Parts never carved and touching nothing (no collision, queries or touches): the backdrop wall, trees, bushes. A Model or part with `Arena_Prop = true` stands on the terrain. A blast cuts its hole through a Model prop's parts and throws the pieces it frees from the base; a one-part prop (a mesh) it reaches is thrown whole; a prop falls when the ground under its base goes (under its pivot: a part-built prop's trunk, so a tree leaning over a drop stays up). What falls or flies fades out after `PROP_FADE_DELAY` |
| `<MapId>.Markers.Bounds` | The play area: the liquid grid covers it (as deep as the ground, below), the cutter is its depth, debris below it is removed, and nothing starts in its top `START_TOP_GAP` |
| `<MapId>.Markers.<any>` with `Arena_Liquid` | A box filled with that liquid at load (`"Water"` or `"Lava"`); the grid reaches up to the highest one. An optional `Arena_LiquidColor` (Color3) colours that liquid on this map instead of `LIQUID_COLORS`, and `Arena_LiquidNeon` (true) draws it in Neon instead of the stud look, so it glows |

The arena plays on the X–Y plane at Z = 0 (snails spawn and the drop picks there); terrain parts should share the
bounds' depth on Z. The liquid is drawn as deep as the map's ground, measured at load: from the middle of its bedrock
blocks' backs to the middle of their fronts (Loader's `GetGroundDepth`, the bounds' depth on a map without bedrock),
so it never sticks out in front of the ground or behind it (about Z −5 to 5 on every map, their land 10 studs deep). In Studio the templates stand in MapLab's grid, so none overlaps another: four to a row, 500 studs apart, each row
300 studs behind the last (X = column × 500, Z = −row × 300, in slot order): `PicnicPlains` at X 0, `Desert` 500,
`RockslideRidge` 1000, `VolcanoIsle` 1500 on Z 0; `TutorialMeadow` 0, `LakesideShowdown` 500, `RollingPlains` 1000,
`EchoCaverns` 1500 on Z −300. Each carries `MapLab_Slot` and `MapLab_Version`. A match plays at X 0 on the plane
whatever the slot: the Loader moves each template so its Bounds stand at X 0 and Z 0 when it caches it, by the spawn,
since until a player's snail drops streaming sends them only what's within `StreamingTargetRadius` (1024) of their
parked avatar (Volcano Isle, at X 1200 then, didn't show before). Inside `Terrain` and `Decor`, folders only organize
the map: everything reads their descendants, and carved pieces go to `Terrain` itself. Every map is made in MapLab (the
game home's map kit), and every map's land has the depth effect: its front is cut into rows of slabs that jut toward
the camera, up to 1.4 studs, in front of the plane. The templates each map replaced are kept in the place's
`Workspace._Labs.MapLab._Iterations` (`<MapId>_arena_<n>`); Picnic Plains' greybox in `ServerStorage.!dump`. The
x below are from the map's middle, where it plays.

`PicnicPlains` (the first map, built by the studio, cleaned and rebuilt in MapLab) is three islands at the waterline
and four floating ledges over a 282-stud sea (`Terrain/Island_1`–`3`, `Ledge_1`–`4`, left to right, 728 parts on the
1-stud grid named `Grass`, `Dirt`, `DarkDirt`, `Stone`, `DarkStone`; `Decor/Backdrop` (101 parts), `Trees`,
`Bushes`, `Rocks`): each island's bedrock (Y 4 to 8, half in the sea, whose surface is at Y 6.5) is a `DarkStone`
part with `Arena_Indestructible`, every ledge part has `Arena_Floats`, and its 18 trees, bushes and rocks are
part-built `Arena_Prop` Models (parts named `Trunk`, `Leaves`, `Needles`, `Spot`, `Bush`, `Rock`). Every map's
backdrop eases down to its liquid at the ends instead of standing as a straight wall (2026-11-12).
`Desert` is two storeys over lava: one main island standing on the lava (`Terrain/Island_1`, x −109 to 112, its
`DarkStone` bedrock from Y 4 to 8 with `Arena_Indestructible`) with an oasis pool, and two long floating islands
above it (`Ledge_1`, x −128 to −35, `Ledge_2`, x −6 to 123, every part with `Arena_Floats`); 705 parts named `Sand`,
`DarkSand`, `Sandstone`, `DarkSandstone`, `Clay`, `DarkStone`, and 70 backdrop parts. Markers: `Lava` (Y −8 to 4,
across the map: the sea, which knocks snails out and sudden death raises) and `Oasis` (`Water`, x −30 to 0, Y 16 to
23), so the oasis water the lava reaches turns to obsidian. Its 24 props are part-built `Arena_Prop` Models in
`Decor/Cacti`, `Trees` (palms), `Bushes`, `Rocks` (parts named `Cactus`, `Flower`, `Trunk`, `Ring`, `Leaves`,
`Coconut`, `Twig`, `Bush`, `Rock`).
`RockslideRidge` (redone 2026-11-14 after the studio's rebuild; before, the owner's own Studio build) is a cave over a
lava sea: `Terrain/Island_1` is both walls and the ceiling (x −145 to 145, up to Y 98), closing the sides and hanging
stalactites over the arena; six rock pillars stand in the lava (`Island_2`–`7`) with stalagmites on their tops and
shelves, and six rock slabs float in the middle (`Ledge_1`–`6`, with `Arena_Floats`). 646 parts named `Rock`,
`LightRock`, `Strata`, `Bedrock` (the bedrock from Y −5 to 3 with `Arena_Indestructible`), 60 `Decor/Backdrop` parts
(a dark back wall filling the cave behind the ceiling and the walls, so no sky shows through) and no props.
Markers: `Sea` (`Lava`, Y −5 to 15, `Arena_LiquidNeon`) and `Bounds` (290 × 111 × 11). The lava between the pillars
is 5 to 14 studs across at its surface, under `SEA_MIN_WIDTH`, so it burns rather than knocks out until sudden death
raises it.
`VolcanoIsle` is a volcano over a sea of lava: three islands standing on it (`Terrain/Island_1`, the west islet, x
−133 to −96; `Island_2`, the volcano's base, x −76 to 84; `Island_3`, the east islet, x 103 to 136; their
`DarkStone` bedrock from Y 4 to 8 with `Arena_Indestructible`) and four floating ledges with `Arena_Floats`: a basalt
shelf over each islet (`Ledge_1`, Y 51 to 62; `Ledge_4`, Y 54 to 66), a small rock between the west islet and the
volcano (`Ledge_2`), and the volcano's cone (`Ledge_3`, x −42 to 44, Y 34 to 73, 195 parts), which floats over a lava
tube running right through the volcano from porch to porch (Y 26 to 36), through a magma chamber. A cave with one
mouth sits at each of the volcano's feet and in each islet's face toward it. 621 parts named `Ash`, `Basalt`,
`DarkBasalt`, `Scoria` (lining the passages), `Ember` (round the lava), `DarkStone`, and 57 backdrop parts. Markers:
`Sea` (Y −8 to 6.5, the sea, which knocks snails out and sudden death raises), `Crater` (x −2 to 10, Y 63 to 67) and
`Chamber` (x −3 to 3, Y 27 to 28), all `Lava` in Arena's own colour with `Arena_LiquidNeon`. Its 17 props are
part-built `Arena_Prop` Models in `Decor/Trees` (dead trees), `Bushes`, `Rocks` (rocks and basalt columns).
`TutorialMeadow`, the tutorial's map and in no rotation, is one small grassy island in a calm sea
(`Terrain/Island_1`, x −86 to 87, its `DarkStone` bedrock from Y 4 to 8 with `Arena_Indestructible`): a tall hill in
the west (top about Y 28), a lower one in the east (about Y 24) and a meadow between them, x −34 to 34 at Y 18 to 19,
where the tutorial's player and bot start. No ledges, no ponds. 253 parts named `Grass`, `Dirt`, `DarkDirt`, `Stone`,
`DarkStone`, and 53 `Decor/Backdrop` parts (low hills). Markers: `Sea` (`Water`, Y −8 to 6.5) and `Bounds` (200 × 80
× 11). Its 7 props are part-built `Arena_Prop` Models (an oak, two pines and a birch, two bushes, a rock).
`LakesideShowdown` is a lake between two grassy banks: one wide island standing on the sea (`Terrain/Island_1`, x
−135 to 137, its `DarkStone` bedrock from Y 4 to 8 with `Arena_Indestructible`), a rolling bank on each side (tops
about Y 33) down to a sandy beach (Y 22), with flat-bottomed pits dug in them (5 deep at x −78 and −53; on the right a
shoulder 3 deep at x 69 stepping into a pit 12 deep at x 77), and between them a deep lake bowl (x −39 to 38, floor
Y 11). The beaches and the lake bed are sand 2 to 4 studs deep over a stud of `DarkSand`. Six floating ledges with
`Arena_Floats`, left to right: four small floating islands over the banks (`Ledge_1`, x −122 to −102; `Ledge_2`, x
−65 to −47; `Ledge_5`, x 47 to 65; `Ledge_6`, x 102 to 122; Y 48 to 79) and the two lily pads on the lake (`Ledge_3`,
x −28 to −10; `Ledge_4`, x 10 to 28; Y 20 to 22, half under the water). 635 parts named `Grass`, `Dirt`, `DarkDirt`,
`Stone`, `DarkStone`, `Sand`, `DarkSand`, `LilyPad`, `DarkLilyPad`, and 54 `Decor/Backdrop` parts (a forest
treeline). Markers: `Sea` (`Water`, Y −8 to 6.5), `Lake` (`Water`, Y 11 to 21, a pond) and `Bounds` (282 × 114 ×
11). Its 26 props are part-built `Arena_Prop` Models in `Decor/Trees`, `Bushes`, `Rocks` and `Flowers`: big oaks
between the floating islands, oaks and logs under the outer ones, cattails at the water's edge, ferns, grass and
flowers, a plant on each floating island, and a water lily on each pad (parts named `Flower`; the cattails' heads
`Head`).
`RollingPlains` (the studio's Studio build, imported into MapLab) is the widest map, 406 studs: one island from side
to side (`Terrain/Island_1`), a long grassy plain on rock with dark strata lines, a raised shoulder at each end (tops
about Y 31 and 29) and a rock arch in the middle. 602 parts named `Grass`, `DarkGrass`, `Rock`, `Strata`, `Bedrock`
(the bedrock from Y −8 to 0 with `Arena_Indestructible`), and 79 `Decor/Backdrop` parts (rolling hills). Markers:
`Sea` (`Water`, Y −8 to −4, inside the rock, so no water shows until sudden death raises it) and `Bounds` (406 × 114
× 11). Its 47 props are `Arena_Prop` Models in `Decor/Trees`, `Bushes`, `Rocks`, `Flowers` and `Picnic`: 44 MapLab
ones (big oaks on the shoulders, an acacia, a pine, a log, ferns, grass tufts, flowers, bushes, rocks) and the
studio's picnic set, rebuilt part for part (`PicnicTable`, `PicnicBlanket`, `Basket`).
`EchoCaverns` (the studio's Studio build, imported into MapLab) is a cavern under a snow-capped rock dome over a
water sea: six islands standing on its bed (`Terrain/Island_1`–`6`; `Island_3` is the dome and the right wall, x −95
to 148, up to Y 81), stalactites hanging from the dome over rock columns and leaning slabs, no ledges. 921 parts
named `Rock`, `LightRock`, `DarkRock`, `DarkStone`, `Cap`, `Snow`, `Strata`, `Clay`, `Bedrock` (the bedrock from Y
−8 to 0 with `Arena_Indestructible`), and 80 `Decor/Backdrop` parts (a dark back wall under the dome, so no sky shows
through). Markers: `Sea` (`Water`, Y −8 to −2, Arena's own colour) and
`Bounds` (296 × 114 × 11). The water between the islands is ponds except x 0 to 18, the one stretch of open sea. Its
21 props are the studio's, rebuilt part for part (`GrassTuft` in `Decor/Grass`, `RockPile` in `Decor/Rocks`).

## Commands

`arena` (server, level 255):

| Subcommand | Arguments |
| --- | --- |
| `load` | `mapId` |
| `carve` | `x`, `y`, `radius` |
