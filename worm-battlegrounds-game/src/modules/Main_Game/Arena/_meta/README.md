# Arena

The destructible arena a match is played on, all on the server. At start it caches every map template in
`SAssets.Arenas` that has what a map needs, and readies it once (markers hidden, terrain in the `Terrain` group);
`Load` clones a cached template into `Workspace.Ume.Arena`: its terrain is ordinary parts (long parts for the shapes, smaller ones for
details) in the `2022 Stud` material. `Carve` subtracts a cylinder running along Z from every terrain part it touches
(CSG, so craters are round and smooth), then drops each group of pieces that no longer reaches indestructible ground;
a dropped group falls with the server's physics and anchors again where it lands. Water and lava are a separate grid
of half-stud cells stepped at 8 fps, so they move like a stop-motion brick film: they flow into craters, spill out of
broken basins, level out (also under debris that dips into them, as if under pressure), and get pushed up by debris
landing in them. Each run of liquid merges with the same run in the rows above into one rectangle in the
`2022 Small Stud` material, so still water is a few big parts. It also sets up the collision groups worms and terrain
use, and the plane worms are held on, and tells others when a map is ready (`Arena_Loaded`). Roblox replicates every
part, so clients need no code. It creates no remotes or saved data.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Arena` |
| Runs on | Server |
| Exposes | `I.Arena` (server) |
| Uses | `I.Create`, `I.Dirs.SAssets`, `I.Dirs.UmeWorkspace`, `GeometryService`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The entry: `I.Arena`, `Load` (template, then liquid, then `Arena_Loaded`), `Carve` (one carve at a time: cut, liquid, debris), `GetHazard`, the Studio test load |
| `Settings.lua` | `Arena_Settings`: carving, debris and liquid numbers |
| `Scripts/Server/Loader.lua` | Registers the collision groups; creates `Workspace.Ume.Arena`; caches the templates at start (checks each, hides its markers, puts its terrain in the `Terrain` group); clones a template's `Terrain`, `Decor` and `Markers`, makes the `Plane`; holds the references the other handlers read |
| `Scripts/Server/Carver.lua` | The cylinder cut with `GeometryService:SubtractAsync` (`SplitApart`), copying name, attributes and collision group onto each piece |
| `Scripts/Server/Debris.lua` | Contacts between parts, the support search from each carved piece (held up by indestructible ground, or by enough floating parts), welding and dropping the rest, anchoring them when they land |
| `Scripts/Server/Props.lua` | The map's props (`Arena_Prop`: trees, bushes, rocks): after each blast, cuts the blast's cylinder through every part of the ones it reaches (CSG), throws each group of pieces no longer joined to the prop's base, drops the ones whose ground is gone, and fades what falls |
| `Scripts/Server/Liquid.lua` | The liquid grid: filling it from the markers over several frames, probing which cells terrain fills, the 8 fps step (falling, spreading, then pressure across each connected body), drawing the liquid as merged rectangles |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `arena` command |
| `_meta/_types.lua` | `Arena_LiquidRect`, one drawn rectangle of liquid |

## API

### Server: `I.Arena`

| Function | Returns | What it does |
| --- | --- | --- |
| `Load(mapId: string)` | `boolean` | Clears the arena, clones the cached `SAssets.Arenas.<mapId>` into it and fills its liquids. `false` and a warning when there's no such template; a template without `Terrain`, `Markers` or `Markers.Bounds` is skipped with a warning at start |
| `Carve(center: Vector3, radius: number)` | | Cuts a round hole through the terrain at `center` (its Z is ignored), wakes the liquid around it and drops what lost its support. Carves wait for each other and run in order |
| `GetBounds()` | `BasePart?` | The loaded map's `Bounds` marker |
| `GetMarkers()` | `Folder?` | The loaded map's `Markers` folder (`Bounds`, liquids) |
| `GetPlane()` | `Attachment?` | The attachment on the bounds' center whose axis runs along Z: a PlaneConstraint's `Attachment0` keeps a part on the plane |
| `GetLiquid(position: Vector3)` | `string?` | `"Water"`, `"Lava"` or `nil` at a position |
| `GetLandSpots(count: number, radius: number)` | `{ Vector3 }` | `count` random spots where a ball of `radius` stands on top of the terrain (flat enough, out of liquid), `LAND_SPOT_GAP` apart while there's room; fewer, or none, when the map has too little ground. Where bots and players who don't place start |
| `IsFree(position: Vector3, radius: number)` | `boolean` | Whether a ball of `radius` fits there: inside the bounds, out of liquid, touching no terrain (the drop's landing spots) |
| `GetHazard(position: Vector3)` | `string?` | What knocks a worm out there: `"Water"` or `"Lava"` in liquid, `"Bounds"` beside or below the play area (above it is fine), `nil` when safe |
| `IsSettled()` | `boolean` | Whether no carved-off debris is still falling |

## Usage

```lua
I.Arena.Load("PicnicPlains")
I.Arena.Carve(explosionPosition, 6)
if I.Arena.GetHazard(worm.Position) then
	-- the worm drowned, burned or left the arena
end
```

## Network

No remotes: clients see the arena through Roblox's replication of its parts.

### Server

**Topics**

- `Arena_Loaded @ (mapId: string)`: a map's template is in place and its liquids are filled.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `CARVE_DEPTH_MARGIN` | `2` | How much longer than the bounds are deep the cutter is, so it cuts all the way through |
| `CONTACT_MARGIN` | `0.15` | How far apart, in studs, two pieces may sit and still hold each other up |
| `SUPPORT_SEARCH_LIMIT` | `400` | The most parts one support search walks before it counts the group as grounded |
| `FLOAT_MIN_AREA` | `24` | A cut-off group stays up when its `Arena_Floats` parts cover at least this many square studs on the plane; smaller crumbs fall |
| `PROP_SUPPORT_DEPTH` | `1.5` | How far under a prop's base the ground may be before the prop falls |
| `PROP_BASE_HEIGHT` | `0.6` | After a cut, the pieces still joined (boxes within `CONTACT_MARGIN`) to a part starting at most this far above the prop's base stand; the rest is thrown |
| `PROP_KNOCK_SPEED`, `PROP_KNOCK_SPIN` | `35`, `6` | How fast a blast throws what it cuts off a prop, or a one-part prop it reaches (away from the blast and up), and the most it spins it (radians per second) |
| `PROP_FADE_DELAY`, `PROP_FADE_TWEENINFO` | `3`, 1 s Quad In | How long a fallen prop lies, then its fade before it's removed |
| `SETTLE_SPEED` | `0.5` | A falling group slower than this (studs per second) is landing |
| `SETTLE_HOLD` | `0.5` | Seconds it must stay that slow to count as landed |
| `DEBRIS_SETTLE_TIME` | `4` | Seconds after which a falling group anchors anyway |
| `DEBRIS_KILL_DEPTH` | `20` | How far below the bounds a falling group is removed |
| `LIQUID_CELL` | `0.5` | A liquid cell's width and height, in studs |
| `LIQUID_FPS` | `8` | Liquid steps per second |
| `LIQUID_VARIANT` | `"2022 Small Stud"` | MaterialService variant the liquid parts use: one stud per half-stud cell (terrain keeps its own) |
| `LIQUID_FALL` | `6` | How many cells a falling cell drops in one step |
| `LIQUID_PROBE_SCALE` | `0.5` | A cell is solid when terrain reaches into a box this share of its size around its center |
| `LIQUID_BUILD_ROWS_PER_FRAME` | `8` | How many grid rows a map's load probes before it gives the server a frame |
| `LAND_SPOT_STEP`, `LAND_SPOT_GAP` | `2`, `16` | `GetLandSpots` looks for ground every 2 studs along the arena and keeps spots 16 studs apart while there's room |
| `LAND_SPOT_MIN_NORMAL` | `0.7` | The steepest ground a land spot may be on (the lowest Y of its normal; 1 is flat) |
| `LIQUID_KINDS` | `{ "Water", "Lava" }` | The liquid kinds, in the order of their ids in the grid |
| `LIQUID_SPREAD` | `{ Water = 12, Lava = 3 }` | How many cells a cell moves sideways in one step, toward the nearest way down along its row |
| `LIQUID_PRESSURE` | `{ Water = 8, Lava = 2 }` | How many of its highest cells one connected body moves each step into lower free cells beside it, so it levels through gaps and under debris |
| `LIQUID_COLORS` | Water `40, 140, 230`, Lava `255, 96, 20` | The blocks' colours |
| `LIQUID_TRANSPARENCY` | Water `0.2`, Lava `0` | The blocks' transparency |
| `COLLISION_GROUPS` | `Terrain`, `Worm`, `Ghost` | Collision groups registered at start, each with the groups it doesn't collide with: worms pass through each other and through `Default` parts (avatars, props), ghosts through everything |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Arena` | Created at start. Holds the loaded map's `Terrain` (its parts in the `Terrain` collision group), `Decor` and `Markers`, plus `Liquid` (the drawn rectangles), the probe part the liquid uses, and `Plane` (an invisible part at the bounds' center holding the `Plane` attachment) |
| `SAssets.Arenas.<MapId>` | A map template, authored in `Workspace.Ume.ServerStorage_Assets/Arenas/`, which the Utils module moves into `ServerStorage.Ume.Assets` (`I.Dirs.SAssets`) when the game starts. A Model with the folders below |
| `<MapId>.Terrain` | The map's parts, anchored. `Arena_Indestructible = true` marks ground blasts never cut, which holds everything else up: every map needs some. `Arena_Floats = true` marks floating terrain (ledges): a cut-off group of it stays up while it's big enough (`FLOAT_MIN_AREA`). Carved pieces keep both |
| `<MapId>.Decor` | Parts never carved and touching nothing (no collision, queries or touches): the backdrop wall, trees, bushes. A Model or part with `Arena_Prop = true` stands on the terrain. A blast cuts its hole through a Model prop's parts and throws the pieces it frees from the base; a one-part prop (a mesh) it reaches is thrown whole; a prop falls when the ground under its base goes. What falls or flies fades out after `PROP_FADE_DELAY` |
| `<MapId>.Markers.Bounds` | The play area: the liquid grid covers it, the cutter is its depth, debris below it is removed |
| `<MapId>.Markers.<any>` with `Arena_Liquid` | A box filled with that liquid at load (`"Water"` or `"Lava"`); the grid reaches up to the highest one |

The arena plays on the X–Y plane at Z = 0 (worms spawn and the drop picks there); terrain parts should share the
bounds' depth on Z. Inside `Terrain` and `Decor`, folders only organize the map: everything reads their descendants, and carved pieces go
to `Terrain` itself. `PicnicPlains` (the first map, built by the studio, cleaned and rebuilt with MapLab, the game home's map kit) is
three islands at the waterline and four floating ledges over a 282-stud sea (`Terrain/Island_1`–`3`,
`Ledge_1`–`4`, left to right, 537 parts on the 1-stud grid named `Grass`, `Dirt`, `DarkDirt`, `Stone`, `DarkStone`;
`Decor/Backdrop`, `Trees`, `Bushes`, `Rocks`): each island's bedrock under Y 8 is one `DarkStone` part with
`Arena_Indestructible`, every ledge part has `Arena_Floats`, and its 18 trees, bushes and rocks are part-built
`Arena_Prop` Models (parts named `Trunk`, `Leaves`, `Needles`, `Spot`, `Bush`, `Rock`). The template it replaced is
kept in the place's `Workspace._Labs.MapLab._Iterations` (`PicnicPlains_arena_1`); the greybox before it in
`ServerStorage.!dump`.

## Commands

`arena` (server, level 255):

| Subcommand | Arguments |
| --- | --- |
| `load` | `mapId` |
| `carve` | `x`, `y`, `radius` |
