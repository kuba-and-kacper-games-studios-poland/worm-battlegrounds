# Arena

The destructible arena a match is played on, all on the server. `Load` clones a map's hand-built template from
`SAssets.Arenas` into `Workspace.Ume.Arena`: its terrain is ordinary parts (long parts for the shapes, smaller ones for
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
| `Scripts/Server/Loader.lua` | Registers the collision groups; creates `Workspace.Ume.Arena`; clones a template's `Terrain`, `Decor` and `Markers`, hides the markers, puts the terrain in the `Terrain` group, makes the `Plane`; holds the references the other handlers read |
| `Scripts/Server/Carver.lua` | The cylinder cut with `GeometryService:SubtractAsync` (`SplitApart`), copying name, attributes and collision group onto each piece |
| `Scripts/Server/Debris.lua` | Contacts between parts, the support search from each carved piece, welding and dropping floating groups, anchoring them when they land |
| `Scripts/Server/Liquid.lua` | The liquid grid: filling it from the markers over several frames, probing which cells terrain fills, the 8 fps step (falling, spreading, then pressure across each connected body), drawing the liquid as merged rectangles |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `arena` command |
| `_meta/_types.lua` | `Arena_LiquidRect`, one drawn rectangle of liquid |

## API

### Server: `I.Arena`

| Function | Returns | What it does |
| --- | --- | --- |
| `Load(mapId: string)` | `boolean` | Clears the arena, clones `SAssets.Arenas.<mapId>` into it and fills its liquids. `false` and a warning when the template is missing or has no `Terrain`, `Markers` or `Markers.Bounds` |
| `Carve(center: Vector3, radius: number)` | | Cuts a round hole through the terrain at `center` (its Z is ignored), wakes the liquid around it and drops what lost its support. Carves wait for each other and run in order |
| `GetBounds()` | `BasePart?` | The loaded map's `Bounds` marker |
| `GetMarkers()` | `Folder?` | The loaded map's `Markers` folder (`Bounds`, `DropZone`, liquids) |
| `GetPlane()` | `Attachment?` | The attachment on the bounds' center whose axis runs along Z: a PlaneConstraint's `Attachment0` keeps a part on the plane |
| `GetLiquid(position: Vector3)` | `string?` | `"Water"`, `"Lava"` or `nil` at a position |
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
| `LIQUID_KINDS` | `{ "Water", "Lava" }` | The liquid kinds, in the order of their ids in the grid |
| `LIQUID_SPREAD` | `{ Water = 12, Lava = 3 }` | How many cells a cell moves sideways in one step, toward the nearest way down along its row |
| `LIQUID_PRESSURE` | `{ Water = 8, Lava = 2 }` | How many of its highest cells one connected body moves each step into lower free cells beside it, so it levels through gaps and under debris |
| `LIQUID_COLORS` | Water `40, 140, 230`, Lava `255, 96, 20` | The blocks' colours |
| `LIQUID_TRANSPARENCY` | Water `0.2`, Lava `0` | The blocks' transparency |
| `COLLISION_GROUPS` | `Terrain`, `Worm`, `Ghost` | Collision groups registered at start, each with the groups it doesn't collide with: worms pass through each other and through `Default` parts (avatars, props), ghosts through everything |
| `STUDIO_TEST_MAP` | `"PicnicPlains"` | Shortcut: the map loaded when a Studio test starts, until the Match module loads maps; remove it then |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Arena` | Created at start. Holds the loaded map's `Terrain` (its parts in the `Terrain` collision group), `Decor` and `Markers`, plus `Liquid` (the drawn rectangles), the probe part the liquid uses, and `Plane` (an invisible part at the bounds' center holding the `Plane` attachment) |
| `SAssets.Arenas.<MapId>` | A map template (staged under `ServerStorage.Ume.Assets.PlaceLoader.<Folder>.Arenas`). A Model with the folders below |
| `<MapId>.Terrain` | The map's parts, anchored. `Arena_Indestructible = true` marks ground blasts never cut, which holds everything else up: every map needs some |
| `<MapId>.Decor` | Parts behind the plane, never carved |
| `<MapId>.Markers.Bounds` | The play area: the liquid grid covers it, the cutter is its depth, debris below it is removed |
| `<MapId>.Markers.DropZone` | Where worms drop in (read by later modules) |
| `<MapId>.Markers.<any>` with `Arena_Liquid` | A box filled with that liquid at load (`"Water"` or `"Lava"`); the grid reaches up to the highest one |

The arena plays on the X–Y plane; terrain parts should share the bounds' depth on Z. The greybox `PicnicPlains`
template lives in the place only (two islands on an indestructible seabed, a bridge on a post, a raised pond).

## Commands

`arena` (server, level 255):

| Subcommand | Arguments |
| --- | --- |
| `load` | `mapId` |
| `carve` | `x`, `y`, `radius` |
