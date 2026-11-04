# Game lessons

How this game settled the way it uses ume and ume-gui, and the design decisions behind it, one at a time. The rules are
in `.claude/rules/game/practices.md`; this page is the story behind each one.

## How to add a lesson

When a framework or design decision is made (often after something was built another way first), add it in the same
change:

1. The rule, short, in `.claude/rules/game/practices.md`, in the section it belongs to.
2. Its story here, newest last: how it was before, why it changed (or why it was chosen), how it is now, and the rule
   it became.

Keep the names real (modules, guis, tags, remotes), so a reader can find the code.

## Lessons

### The guis are built on the theme (2026-11-03)

**Before.** ume-gui's System guis are long tables of `Primitive` nodes, each holding its own colours, sizes and
fonts (`System/WidgetManager_Message` is 760 lines for one message box). Building the game's 22 guis that way would
spread every look across 22 files, and the first pass was to get every button, text and container in place before
designing the look.

**Why it changed.** `gui/code.md` asks for the same sizes and looks in every gui. Putting the looks in the theme
makes that true by construction and lets the styling pass happen in one folder.

**Now.** The `WormBattlegrounds` theme has five controls of its own (`Widget`, `Box`, `Item`, `Cells`, `Picture`)
and restyles `Button`, `Label` and `Progress`; each gui is a short table of those. Building them showed three
traps: value controls do nothing in exports, the shared `Grid` doesn't lay out rows cloned in game, and labels lose
their height in a `Box` inside a `Fill` row (and `Wrap = false` is refused).

**Rule.** `game/practices.md` → Guis.

### Two looks, drawn on slabs (2026-11-03)

**Before.** The first pass drew every panel and button as one flat filled frame with an outline, and labels sized
themselves with `AutomaticSize`, so their text showed at the wrong size under a widget's `S_ScreenScale`.

**Why it changed.** The styling pass compares two looks, Dark refined and Brick toy, and both want raised surfaces:
a face over a darker edge. Building them showed two traps. A Box that grows with its content (`AutomaticSize` Y) grew
to fill the screen once its background held a scale-sized frame inside another one (Roblox counts such nested frames
at their parent's full height). And `ctx.Stroke` outlines the label's box, so outlined text showed as empty boxes.

**Now.** The theme has a `Slab` control (edge, face, shade, shine, shadow, studs) whose root is a Folder; `Button`,
`Item`, `Box` and `Widget` draw on it, and a Box puts its slab straight in its root. The theme's own `Label` has a
fixed height, its `Stack` sizes labels in a row to their text, and every text outline is `Contextual`. The Brick toy
look is a theme of its own (`WormBattlegrounds-Brick`) that extends the game's and only changes tokens and styles.

**Rule.** `game/practices.md` → Guis.

### A Worms-style look, flat (2026-11-03)

**Before.** Dark refined and Brick toy were both rejected: they read as generic styling that could be any game's. The
owner wants the original Worms menus, made more Roblox.

**Why it changed.** Worms' menus have a clear language: flat teal frames with a light inner bevel, dark header bars
with left-aligned upper-case titles, tabs, square tiles with a white title strip over a picture. A first pass kept a
raised lip under every button and container (a darker edge plus a drop shadow), and the owner turned that down too:
Worms' frames are flat.

**Now.** The `Slab` control draws one flat face with its outline, an optional tiled pattern (the header stripes) and
a bevel line inside its edge; its depth, edge and shadow keys are gone. `Box` puts its title on a striped band,
`Widget` insets a striped header bar, `Item` is a tile with a name strip and a picture well, and `Button` and `Label`
can upper-case their text. The pictures come from an icon kit of hand-drawn SVGs in the game home's
`assets/_inbox/ui_kit/`, rendered into Studio's local content folder and listed in the theme's `Icons.lua` until the
owner approves them for upload. `WormBattlegrounds-Brick` is no longer used.

**Rule.** `game/practices.md` → Guis.

### The arena is parts carved by CSG (2026-11-03)

**Before.** The wiki's plan drew the terrain from a grid of 2-stud cells, greedy-meshed into merged parts and carved
cell by cell, with falling blocks written back into the grid.

**Why it changed.** The owner wants maps built the way real Roblox maps are: long parts for the shapes, smaller parts
for details, so shapes aren't limited to a grid. A grid would also make every crater stepped. A test in Studio showed
`GeometryService:SubtractAsync` cuts a cylinder out of a long part in about 10 ms and, with `SplitApart`, returns each
loose piece as its own part, keeping the stud material. The same test showed overlap queries don't report plain parts
that only touch at a face, so contacts are checked with a slightly enlarged copy of each piece.

**Now.** The `Arena` module clones a hand-built template, carves blasts with a cylinder along Z, and drops any group of
pieces that lost contact with the ground, anchoring it again where it lands. Only the liquids use a grid: a cell
simulation stepped at 8 fps and drawn as stud parts, for a stop-motion look. Its first cells were 2 studs, which the
owner found too blocky; they are half a stud now, in the `2022 Small Stud` material, and each run of liquid merges
with the rows above it into one rectangle, since one transparent part per row showed stripes.

**Rule.** `game/practices.md` → Arena.

### Worms are balls their player's client drives (2026-11-03)

**Before.** The wiki planned stamina in the player's Replicator folder (`Match.Stamina`) and left open how the server
and the moving client talk.

**Why it changed.** Bots have worms too, and every client draws every worm's tag, so worm state is the worm's, not a
player's. The first walking test also showed two traps. A worm with grip stuck against walls and crater lips under
a strong walking force, so walking now drops the ball's friction to 0 and scales the force to its mass. And a worm
its client moved could pass through shallow water between two server frames, so hazards are checked along the path
since the last frame.

**Now.** `Worms` keeps each worm's state in attributes on its model; `WormControl` gives the active worm to its
player's client while `CanMove` is set, charges `Stamina` on the server and snaps the worm back when it moves too
fast. Neither module has remotes.

**Rule.** `game/practices.md` → Worms.

### One place, two maps (2026-11-03)

**Before.** The template loads one map, and the wiki planned a separate lobby place and match place.

**Why it changed.** Matches run on reserved servers of the same place, so both maps sharing one place keeps one
codebase, one set of DataStores and one publish. ume's place loader already picks a map per server.

**Now.** `place_loader.lua` has a `Lobby` and a `Match` map, each with the `Default` folders plus its own, and lists of
modules each map leaves out. MatchBoard teleports to a reserved server with the `Match` map id; Studio tests pick one
with the `Ume_StudioMapId` Workspace attribute.

**Rule.** `game/practices.md` → Maps and placeholders.

### Studio plays the lobby and the match together (2026-11-04)

**Before.** A Studio test loaded one map: the lobby printed the match it would have started, and the Match map played
a stand-in match. The tutorial match, rows, parties and the way back to the lobby could only be tried after
publishing.

**Why it changed.** The owner wanted to play the whole game in Studio: the lobby, then a bot match, then back.

**Now.** A third map, `Studio`, loads both maps' folders and modules. MatchBoard's launch calls `I.Match.Host`
instead of teleporting, the match sends its players back with the `InMatch` Player attribute, and the lobby's
panels, the HUD, the camera, Results, the top bar buttons and the tutorial hints follow that attribute. Studio boots
it unless `Ume_StudioMapId` names another map.

**Rule.** `game/practices.md` → Maps and placeholders.

### Placeholders, not purchases (2026-11-03)

**Before.** The plan named products, passes, weapon models and particle effects that don't exist yet.

**Why it changed.** The owner asked that nothing be created on Roblox for them during the build: products and
passes stay at id 0, and models and effects are stand-ins.

**Now.** Marketplace entries have `Id = 0` (Marketplace warns about each at start), projectiles are plain parts,
every skin falls back to the Classic worm, emotes show their name.

**Rule.** `game/practices.md` → Maps and placeholders.

### The Brawl look became a kit first (2026-11-04)

**Before.** The first Brawl Stars-style options (Shop, Results, MatchBoard on `WormBattlegroundsBrawl`) restyled
whole screens in one pass: flat frames with a lip, a top band and a drop built from Frames and UIStrokes, Fredoka
One, royal-blue panels. The owner rejected them the same day: uneven strokes, odd buttons, text out of line, layouts
and sizes that weren't friendly to play with.

**Why it changed.** One aspect at a time, reviewed, instead of whole screens at once. A kit of primitives drawn once
(buttons, windows, slots, reward frames, a gradient library) makes every gui match by construction, and pictures
drawn with gradients look like the reference games where Frames and strokes couldn't.

**Now.** The kit (game home `assets/_inbox/ui_kit_brawl/`: `skins.py`, `banners.py`, `build.py`) draws 9-slice SVG
skins, renders them to 2× PNGs in Studio's content folder and writes the theme's `Icons.lua` and `Skins.lua`. The
theme's `Slab` draws those skins; `Widget` is the Hazard plate window the owner picked; every gui has a `01_Brawl`
option on it. The kit's rules came with it: yellow only for the next step, colours by job, things on slots, reward
tiles only for rewards, no text under 32 px. They are the two Brawl rules in `practices.md` → Guis.

### Panels got smaller on a PC and stopped overlapping (2026-11-04)

**Before.** ScreenScale scaled every panel by the screen's height alone. The GUI kit's panels, drawn big for phones,
looked oversized on a PC, and on a 4:3 or 5:4 screen the lobby's side-by-side panels (MatchBoard, Crates, Loadout)
ran into each other. The tutorial hint sat on the Play panel, and in a match the kill feed and emote button never
scaled, so on a 4K screen the bar grew into them.

**Why it changed.** The owner asked for the guis scaled down on PCs and checked against the guis shown with them.

**Now.** ScreenScale takes the smaller of height / 1080 and width / 1920. Panels are placed by screen fractions, so
position scales along with size. The PC size comes from ume's `Utils_PlatformScale` tag (the kit tags its panels
0.75 on Desktop), which ScreenScale multiplies in through the UIScale's `Utils_BaseScale`. A first try used an
attribute of ScreenScale's own; the owner asked for ume's platform tags instead, since they already do per-device
sizes. The lobby and match options were measured at PC sizes from 1024 × 768 to 3840 × 2160 and rearranged until
nothing overlapped. Phones and tablets still overlap: the lobby's panels are taller than a phone's screen.

**Rule.** `game/practices.md` → Maps and placeholders (the ScreenScale bullets).

### Phones got their own sizes, from ume's platform tags (2026-11-04)

**Before.** The lobby's panels were taller than a phone's screen and ran into each other, the big windows (Shop,
Results) rose past its top, and in a match the tutorial hint covered the turn panel. The touch buttons were fixed
pixel sizes.

**Why it changed.** The owner asked for the phone layout after the PC one, using ume's platform tags for device
sizes.

**Now.** Panels hang from screen edges and corners, and on Mobile the lobby panels get their own sizes
(`Utils_PlatformSize`) and, where content needs room, a scale of 0.9 (`Utils_PlatformScale`); Large and Screen
windows are 0.8 and 0.78, the hint 0.55, the turn panel 0.6. The touch buttons scale like panels (the kit's `Button`
`Screen`): sizing them by the screen's height alone left their pixel padding as it was and hid their text. Nothing
overlaps at 7 phone, 5 tablet and 11 PC sizes.

**Rule.** `game/practices.md` → Maps and placeholders (the screen and device bullets).

### The kit became the game's look (2026-11-04)

**Before.** The kit lived in `01_Brawl` design options beside the game's flat `WormBattlegrounds` guis. Game code
showed a picked tab, difficulty or slot by recolouring the piece's `Face` frame, and rarity with `I.Rarity.ApplyLook`
on outlines.

**Why it changed.** The owner moved the options into the game's guis, exported them and asked for the game to work
with them.

**Now.** Every gui in `src/guis/WormBattlegrounds/` is its `01_Brawl` option. On the kit `Face` is the skin image and
exports can't run the theme's controls, so the controls record what code needs as attributes: a button's three skins
on its `Face` (`Kit_Image`, `Kit_SelectedImage`, `Kit_DisabledImage`), a reward tile's frame, stage and light per
rarity on the tile (`Kit_<Rarity>_*`). Code swaps those images, fills a picked slot's `Body`, and colours rarity
text with the rarity's `Base` colour: `ApplyLook` needs a `UIGradient` that no label has. A play test opened the
lobby, the crate reveal, the picker, Solo, the Custom lobby and the Shop, and played a tutorial match, with no
errors. The tutorial hint drew over windows (`DisplayOrder` 10) and covered the picker's subtitle, so it now sits
under them.

**Rule.** `game/practices.md` → Guis (the look, yellow leads the eye, picked and owned states).
