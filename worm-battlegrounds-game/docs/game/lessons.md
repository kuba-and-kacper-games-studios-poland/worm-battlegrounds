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

### The first map's floating ledges hold on one block (2026-11-05)

**Before.** The greybox Picnic Plains stood on one indestructible seabed, and everything else touched it, so the
debris search (`Arena/Scripts/Server/Debris.lua`) always found ground.

**Why it changed.** The studio's real Picnic Plains has four floating ledges that touch nothing. With no
`Arena_Indestructible` part in them, the first blast on a ledge would drop the whole ledge into the sea. Marking a
ledge's biggest blocks would leave slabs no weapon can cut.

**Now.** Each island's waterline blocks are indestructible, and each ledge has one small rock block in its middle
marked too (`Arena_Indestructible`), so a ledge can be blasted away around it. The map is authored in
`Workspace.Ume.ServerStorage_Assets/Arenas/PicnicPlains` and cached by the Arena module at start. Rule: Arena →
"Ground is what's `Arena_Indestructible`".

### Worms start on land, not over the sea (2026-11-05)

**Before.** Every worm parachuted in from the top of the map's `DropZone`, spread evenly along its whole width. On
the studio's Picnic Plains that width spans the gaps between islands, so bots (and players who didn't place) could
float down into the sea and drown before the first turn.

**Why it changed.** A start spot should never cost a worm. Players can now place their spot anywhere a worm fits,
so the evenly spread line was only left for those who don't pick.

**Now.** `I.Arena.GetLandSpots` casts a ray down every 2 studs, keeps flat enough ground out of liquid, and picks
random spots 16 studs apart while there's room; bots and players who didn't place start standing there, with no
parachute. The `DropZone` marker is gone. Rule: Worms → "A worm starts standing on land unless its player places it".

### Ledges float instead of hanging on one block (2026-11-05)

**Before.** Each floating ledge of Picnic Plains held on one small `Arena_Indestructible` block in its middle (the
lesson above). On one ledge that block was a 1-stud dirt plate under a tree, and blasts around it left it hanging
uncut over the crater: it looked like destruction was broken.

**Why it changed.** Any block that can't be cut stays visible after the ground around it is gone, so there's no good
block to pick.

**Now.** Ledge parts carry `Arena_Floats` (carved pieces keep it), and the debris search counts a cut-off group as
held up when its floating parts cover at least `FLOAT_MIN_AREA` (24 square studs); smaller crumbs fall. No ledge block
is indestructible. In the same change, trees, bushes and rocks became `Arena_Prop`s that blasts throw and that fall
when their ground goes (`Arena/Scripts/Server/Props.lua`). Rules: Arena → "Floating ledges float", "Props react to
blasts".

### The lobby became a stage with one Play button (2026-11-05)

**Before.** The lobby was a flat sky-blue backdrop covered in panels: Party, a Loadout window, a Play panel with Play
solo, three public match cards and Custom lobby, a Crates panel with every crate's buttons and Skins, plus a Shop
button in the top bar. New players had too many things to press.

**Why it changed.** The owner wanted the lobby to read like Fortnite's: your worm standing in front, the game's
name on top, and few buttons, so nobody gets confused about what to press.

**Now.** The camera looks at the `LobbyStage` Model, where the player's worm stands in its skin. The screen keeps the
logo, one yellow **Play** (the quick match) with **Modes** beside it, Party, a slim Loadout bar and two corner
buttons; solo, the public match list, custom lobbies and the crates moved into windows. The top bar's Shop button is
gone (the currency bar's + opens the shop). Rule: Maps and placeholders → "The lobby is a 3D stage".

### Picnic Plains rebuilt in MapLab, and props that break (2026-11-05)

**Before.** The studio's Picnic Plains had ragged outlines, one-stud spikes and uneven dark dirt, some edges off the
stud grid, and mesh trees, bushes and rocks that a blast could only throw whole.

**Why it changed.** The owner wanted the land to fit the destruction (every edge on the grid, layers that make
sense), a way to make more maps the same way, and props that break like the land does.

**Now.** Maps are made in MapLab, the game home's map kit: the land is a picture on the 1-stud grid, cleaned and
packed into merged parts, checked, and exported into `Arenas` only after the owner approves. Props are part-built
Models in the meshes' look (piles of bevelled blocks), free of the grid, and a blast cuts its hole through them; the
pieces no longer joined to the base fly off and fade (`Arena/Scripts/Server/Props.lua`). Rules: Arena → "Props break
under blasts", "Maps are made in MapLab".

### The Desert, a map with two storeys (2026-11-05)

**Before.** Every map had one storey: islands at the liquid with small ledges above. Worms that didn't place started
on the highest ground in each column, and a prop stood while there was ground under the middle of its outline.

**Why it changed.** The owner wanted a second map, a desert with lava at the bottom and an oasis, and after the first
try ("not organic, looks forced") asked for two storeys: one main island, with long, big floating islands above it.
Its first playtest showed two limits: 15 of 16 start spots fell on the upper islands, since only the highest ground
was looked at, and a palm leaning over the pool was dropped after a blast elsewhere, since the middle of its outline
hung over water.

**Now.** The Desert (made in MapLab) is in the match pool beside Picnic Plains. `GetLandSpots` looks at every top in
each column, so worms start on both storeys, and keeps spots apart by distance, not by X alone. A prop stands while
there's ground under its pivot (a part-built prop's trunk). Rules: Worms → "A worm starts standing on land", Arena →
"Props break under blasts".

### Held weapons, and everyone sees the aim (2026-11-05)

**Before.** Worms held nothing: the weapon picked in the loadout bar was only an attribute (`HeldItem`). The aim line
showed only on the aiming player's screen; the others got `AimAngle` and `AimPower` and drew nothing from them, and
bots fired 1.5 to 3 seconds into their turn without any visible aim.

**Why it changed.** The owner asked for worms to hold their weapon where players can see it, toward the camera, for
the aim line to show for everyone when one player aims, and for bots to shoot slower.

**Now.** Combat's client `Held` handler puts a copy of the active worm's weapon model in its hands during its turn,
1.5 studs toward the camera, turned to its aim. Combat's `ShowAim` stamps each aim update with the server time
(`AimTime`), and MatchHud's `Aim` draws any other worm's line while the stamps keep coming. Bots think 2.5 to 4
seconds, then hold their weapon and swing their aim to the shot over 1.5 seconds before they fire. Rules: Worms →
"The active worm holds its weapon on the camera's side", "Everyone sees the active worm aim".

### Blasts that shake, rumble and throw the ground (2026-11-05)

**Before.** A blast was a neon ball that swelled and faded, with Roblox's classic explosion puff; bullets drew fading
lines. The camera stayed still and nothing vibrated. The game has no sounds yet.

**Why it changed.** The owner asked for the game's feel to be polished first, starting with the shot and the blast
every turn ends on, with screen shakes and haptics for phones.

**Now.** Combat's client `Effects` handler draws a blast as a white flash, a fireball, a light, and bursts of fire,
sparks and smoke (Roblox's own particle pictures until the studio makes its own), and throws chunks of the terrain and
props it hit in their colours (0.3 to 1 stud, in Arena's `Chip` collision group, so they bounce on the terrain and
lie there for 2.5 seconds but pass through worms and shots; the first version let them fall through everything). It shakes the camera with ume's CameraShake, which needed MatchCamera to update one
render step earlier (`Camera` instead of `Camera + 1`) so the shake lands on top of the view instead of being
overwritten. Phones and pads vibrate through the Haptic module's presets: a tick on the player's own shot, a thump
for blasts by size and distance, and a longer one when their worm is hurt. Rules: Worms → "Blasts are felt, not
only seen".

### Bedrock can be blasted down to the water (2026-11-05)

**Before.** Each island's waterline blocks (`Arena_Indestructible`, Y 4 to 8 on both maps) were never cut: the carver
skipped them and the debris search counted any of them as ground. Blasts could dig an island down to that layer
but never through it, so there was always a floor under the worms.

**Why it changed.** The owner asked for the bottom layer to be destructible too, so shots can open an island to the
water. In the same change, sudden death starts sooner and gentler: from round 4 the water rises half a stud every
turn, and from round 8, when the match drags on, two studs (it used to start at round 10 at two studs).

**Now.** `Arena/Scripts/Server/Carver.lua` cuts bedrock like any terrain. The loader notes the map's floor (the
bottom of its lowest bedrock part), and the debris search (`Debris.lua`) counts a bedrock piece as ground only while
its bottom still reaches that floor, so a piece cut loose falls into the sea. The attribute keeps its old name, so
the maps and MapLab need no change. Sudden death is Match's `SUDDEN_DEATH_ROUND` / `SUDDEN_DEATH_RISE` and
`SUDDEN_DEATH_FAST_ROUND` / `SUDDEN_DEATH_FAST_RISE`. Rule: Arena → "Ground is bedrock on the floor".

### Craters are stepped like voxels (2026-11-05)

**Before.** Blasts subtracted a cylinder (CSG), so every crater was a smooth round bowl. The lesson "The arena is parts
carved by CSG" picked that on purpose: a grid "would also make every crater stepped".

**Why it changed.** The maps are drawn on the 1-stud grid, and the owner wants destruction to look voxelized on them
too, not smooth.

**Now.** The terrain is still long parts and the cut is still CSG; only the cutter changed. `Carver.BuildCutter` makes
one box per row of the `CARVE_CELL` (1-stud) squares whose centers are within the blast's radius, lined up with the
maps' grid, and `SubtractAsync` takes them all at once. Props use the same cutter. A test in Studio cut a 60-stud part
in 11 ms with a radius of 6 (12 boxes) and 24 ms with 14 (28 boxes), against about 10 ms for the old cylinder, with
clean pieces and no slivers. The crater can reach half a square past the radius, so the liquid refresh around a carve
covers that too. Rule: Arena → "Blasts carve voxel craters with CSG".

### World labels scale with the screen (2026-11-05)

**Before.** The worm tag, the drop marker and the damage number were BillboardGuis of a fixed pixel size (WormTag
240 × 200). On a 1080p screen that matched the hud, but on a 667 × 375 phone a tag was about half the screen's height,
while the hud panels around it shrank with the screen. The tag's health number was also squeezed to the bar's 18 px,
by a shortcut in `Worms/Scripts/Client/Tags.lua` that worked around ume-gui's `Progress` status label growing tall
under a UIScale.

**Why it changed.** A gui audit on phone sizes: the hud was fixed to scale with the screen, and the labels over the
worms had to follow, or they covered the arena on small screens.

**Now.** Each world label's root is laid out at its design size (WormTag 240 × 240, DropMarker 240 × 100, DamagePop
160 × 100) with an `S_ScreenScale`, and the code that clones it calls `I.ScreenScale.AddBillboard`, which sets that
scale to the screen's and the billboard's size to the root's times it, refitting when the screen changes. The kit
theme has its own `Progress` control whose status line is one line tall, so the health number is big and centred
(`Health` style) and the shortcut is gone. Rule: Maps and placeholders → "World labels scale with the screen too".

### Capitals that stay capitals, and a floor for small PC screens (2026-11-05)

**Before.** The kit's capitals styles (headings, titles, buttons) upper-cased their text only when the gui was built.
Text game code wrote later showed as written, so the turn panel read "YOUR TURN!" on one turn and "Your turn in 3
turns" on the next, and the waiting room's countdown and vote button were mixed case under capitals titles. On a PC
at 1024 × 768 the screen scale was 0.533 (the width rule), times the kit's 0.75 on Desktop: most hud text was about 10
to 12 px.

**Why it changed.** A gui audit asked for clearer guis. The owner chose capitals everywhere, and a floor on the
screen scale for small PC windows.

**Now.** The theme's `Label`, `Button`, `Widget` and `Box` tag capitals text `TextCase_Upper`, and the TextCase module
(Utils) writes it in capitals whenever it changes, keeping rich text tags and escapes; guis whose code writes into
such text were exported again to carry the tag. ScreenScale never goes under `MIN_SCALE` 0.6 off Mobile. The floor
wins over the width rule, which made the lobby's bottom row collide at 1024 × 768 (the Loadout card over Play by
28 px), so Play and the waiting room moved to 55 % across: clear on every screen checked, phones included, where they
had overlapped by 7 px. Rules: Guis → "Capitals stay capitals"; Maps and placeholders → "Panels scale with the screen
in position and size", "Panels hang from a screen edge or corner".

### Party folds on phones, and counts stay on one line (2026-11-05)

**Before.** Party was a fixed 380-tall box whose header and two button rows took all of it, so the member list got no
height and no members showed, on every screen. On a 667 × 375 phone the panel touched the Loadout card and the lobby's
logo ran under Party and the currency bar. The coin count was a narrow centred label, so "100" wrapped onto two lines.

**Why it changed.** The gui audit's batch 4. The owner chose: the panel grows with its members on PC, folds to a tab on
phones, and the phone logo shrinks to fit.

**Now.** Party is a slate tab ("Party 2/4") over a `Panel` box as tall as its members and buttons. Party's code opens it
on PC and console, folds it on phones and tablets (`I.Platform.Current`, again on `Platform_Changed`), and a press
toggles it; the tab shows the kit's selected skin and an upturned chevron while open. Loadout and MatchBoard dropped to
`DisplayOrder` -1 so an opened panel draws over them. The logo is 0.4 on Mobile and the corner buttons sit at 16.5 %
down, clear of the currency bar. Each count is 104 wide and left-aligned, and the slot writes 10,000 and up short
(`Currency_ShortFrom`). Rules: Maps and placeholders → "Panels hang from a screen edge or corner", "Counts stay on one
line".

### Worms-style aiming, and a RoWorld-style lobby (2026-11-06)

**Before.** A shot was aimed by dragging back from the worm: the drag's direction was the angle, its length the
power, and dots showed the first part of the shot's path. The lobby had one yellow **Play** (a quick match into the
fullest public row) and **Modes**, a window with Play solo (hidden a window deeper), Custom lobby and two random team
rows, so a mode like Trios was often not on the board at all. Party invites were Roblox-style confirmations asked one
player at a time.

**Why it changed.** The owner asked for Worms' aiming (a crosshair for the direction, a held charge for the power,
both seen by everyone) and a lobby like RoWorld's (their screenshots): Play solo up front, the public matches listed,
bots filling any empty seat, and a friends-only party match with bots on or off (half the coins without bots).

**Now.** A crosshair sits 9 studs from the worm toward the mouse, finger or right stick; holding charges a
flame-coloured power cone, letting go fires, a full charge (1.6 s) fires by itself, and bots turn then charge the same
way. The lobby's one panel holds the welcome line, Play solo (Play with party in a party), Custom and one card per
public mode; the solo or party setup and the waiting room take its place. Invites are kit-style boxes: a list of
players to invite, and an invite to answer. A match server now loads its map before waiting for its players, so a
party whose last member is slow sees the arena instead of an empty sky. Rules: Worms → "Aiming is a crosshair and a
held charge", "Everyone sees the active worm aim"; Maps and placeholders → "The lobby is a 3D stage", "Matchmaking
fills with bots".

### Two places, and Studio teleports that carry the match (2026-11-06)

**Before.** One place held both maps: a lobby server reserved a server of the same place, and the match server found
its map in ume's MemoryStore by its reserved-server id. Studio couldn't teleport, so the Studio map played the lobby
and its matches on one server.

**What we found.** Studio tests can teleport now (`TeleportAsync`, same experience), but `ReserveServerAsync` gives
an empty reserved-server id there and the new server's `PrivateServerId` is empty, so `I.Teleport` failed writing the
map (`InvalidParameter: The key field is required`), and needed the MemoryStore even when Studio has no API access.
The new server also runs the destination place as last saved to Roblox, not the open session.

**Why it changed.** The owner wants Roblox's analytics for the lobby and the matches apart (where players leave, what
breaks), so the lobby and the matches get a place each, copies of one file.

**Now.** The place loader's config boots `Lobby` on `LOBBY_PLACE_ID` and `Match` on `MATCH_PLACE_ID` (Arena,
118265066788984; both places share one `MAP_CONFIGS`); MatchBoard teleports to its `MATCH_PLACE_ID`. In ume's place loader, `I.Teleport` without a
reserved-server id sends `{ Ume_Map = { MapId, Metadata } }` as teleport data, and `Map.FetchMapId` in Studio reads it
from the first player's join data (waiting up to 10 s for one), since teleport data passes through the client and
only Studio may trust it. That is a framework change, to take to ume. Checked in Studio on 2026-11-06: Play solo in
the lobby place teleported to Arena, which booted `Match` with the solo match; when it ended, the player went back to
the lobby place's `Lobby`. Rule: Maps and placeholders → "Two places, one
file, two maps", "Studio plays the `Studio` map".

### The charge bounces, and power is circles (2026-11-06)

**Before.** Holding the fire button charged a flame-coloured cone, and a full charge fired by itself.

**Why it changed.** The owner wanted only the player's release to fire: a charge left at full kept firing shots the
player hadn't chosen. They also wanted the power drawn as circles, like Worms', not a flat band.

**Now.** Held, the power bounces from none to full and back (`CHARGE_SECONDS` each way) until it's let go, and a turn
that runs out while charging drops it (Combat refuses a shot outside the `Turn` phase). The power is `POWER_DOTS`
circles drawn over the arena (like the crosshair, so props never hide them) from the muzzle to the crosshair,
growing and going from yellow to red, lit as the power fills; other players and bots draw the same. Rule: Worms → "Aiming is a crosshair and a held charge".

### Power from the muzzle, sized for the screen (2026-11-06)

**Before.** The power circles started a fixed gap from the worm's ball, not at the weapon, and the held weapon turned
toward the aim the server sent back (`AimAngle`), so on the shooter's own screen it trailed the crosshair. Crosshair
and circles were sized in studs, so they shrank as the camera zoomed out.

**Now.** Every weapon model's RootPart has a `Muzzle` attachment (measured from side captures of each model), and the
circles run from it to the crosshair. MatchHud's aim calls Combat's client `SetAim` every frame it draws, so the held
weapon turns with the crosshair at once and the muzzle is where the circles start that frame. Sizes are studs at
MatchCamera's `DISTANCE`, scaled by the camera's distance. The shot itself still leaves from `MUZZLE_GAP` past the
worm's ball (the server's `Fire`), not from the barrel's tip. Rule: Worms → "Aiming is a crosshair and a held charge".
