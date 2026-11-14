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

### Snails are balls their player's client drives (2026-11-03)

**Before.** The wiki planned stamina in the player's Replicator folder (`Match.Stamina`) and left open how the server
and the moving client talk.

**Why it changed.** Bots have snails too, and every client draws every snail's tag, so snail state is the snail's, not a
player's. The first walking test also showed two traps. A snail with grip stuck against walls and crater lips under
a strong walking force, so walking now drops the ball's friction to 0 and scales the force to its mass. And a snail
its client moved could pass through shallow water between two server frames, so hazards are checked along the path
since the last frame.

**Now.** `Snails` keeps each snail's state in attributes on its model; `SnailControl` gives the active snail to its
player's client while `CanMove` is set, charges `Stamina` on the server and snaps the snail back when it moves too
fast. Neither module has remotes.

**Rule.** `game/practices.md` → Snails.

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
every skin falls back to the Classic snail, emotes show their name. On 2026-11-13 the owner asked for the 5 diamond
packs and 4 game passes to be created, so Marketplace entries have their real ids now.

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

### Snails start on land, not over the sea (2026-11-05)

**Before.** Every snail parachuted in from the top of the map's `DropZone`, spread evenly along its whole width. On
the studio's Picnic Plains that width spans the gaps between islands, so bots (and players who didn't place) could
float down into the sea and drown before the first turn.

**Why it changed.** A start spot should never cost a snail. Players can now place their spot anywhere a snail fits,
so the evenly spread line was only left for those who don't pick.

**Now.** `I.Arena.GetLandSpots` casts a ray down every 2 studs, keeps flat enough ground out of liquid, and picks
random spots 16 studs apart while there's room; bots and players who didn't place start standing there, with no
parachute. The `DropZone` marker is gone. Rule: Snails → "A snail starts standing on land unless its player places it".

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

**Why it changed.** The owner wanted the lobby to read like Fortnite's: your snail standing in front, the game's
name on top, and few buttons, so nobody gets confused about what to press.

**Now.** The camera looks at the `LobbyStage` Model, where the player's snail stands in its skin. The screen keeps the
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

**Before.** Every map had one storey: islands at the liquid with small ledges above. Snails that didn't place started
on the highest ground in each column, and a prop stood while there was ground under the middle of its outline.

**Why it changed.** The owner wanted a second map, a desert with lava at the bottom and an oasis, and after the first
try ("not organic, looks forced") asked for two storeys: one main island, with long, big floating islands above it.
Its first playtest showed two limits: 15 of 16 start spots fell on the upper islands, since only the highest ground
was looked at, and a palm leaning over the pool was dropped after a blast elsewhere, since the middle of its outline
hung over water.

**Now.** The Desert (made in MapLab) is in the match pool beside Picnic Plains. `GetLandSpots` looks at every top in
each column, so snails start on both storeys, and keeps spots apart by distance, not by X alone. A prop stands while
there's ground under its pivot (a part-built prop's trunk). Rules: Snails → "A snail starts standing on land", Arena →
"Props break under blasts".

### Held weapons, and everyone sees the aim (2026-11-05)

**Before.** Snails held nothing: the weapon picked in the loadout bar was only an attribute (`HeldItem`). The aim line
showed only on the aiming player's screen; the others got `AimAngle` and `AimPower` and drew nothing from them, and
bots fired 1.5 to 3 seconds into their turn without any visible aim.

**Why it changed.** The owner asked for snails to hold their weapon where players can see it, toward the camera, for
the aim line to show for everyone when one player aims, and for bots to shoot slower.

**Now.** Combat's client `Held` handler puts a copy of the active snail's weapon model in its hands during its turn,
1.5 studs toward the camera, turned to its aim. Combat's `ShowAim` stamps each aim update with the server time
(`AimTime`), and MatchHud's `Aim` draws any other snail's line while the stamps keep coming. Bots think 2.5 to 4
seconds, then hold their weapon and swing their aim to the shot over 1.5 seconds before they fire. Rules: Snails →
"The active snail holds its weapon on the camera's side", "Everyone sees the active snail aim".

### Blasts that shake, rumble and throw the ground (2026-11-05)

**Before.** A blast was a neon ball that swelled and faded, with Roblox's classic explosion puff; bullets drew fading
lines. The camera stayed still and nothing vibrated. The game has no sounds yet.

**Why it changed.** The owner asked for the game's feel to be polished first, starting with the shot and the blast
every turn ends on, with screen shakes and haptics for phones.

**Now.** Combat's client `Effects` handler draws a blast as a white flash, a fireball, a light, and bursts of fire,
sparks and smoke (Roblox's own particle pictures until the studio makes its own), and throws chunks of the terrain and
props it hit in their colours (0.3 to 1 stud, in Arena's `Chip` collision group, so they bounce on the terrain and
lie there for 2.5 seconds but pass through snails and shots; the first version let them fall through everything). It shakes the camera with ume's CameraShake, which needed MatchCamera to update one
render step earlier (`Camera` instead of `Camera + 1`) so the shake lands on top of the view instead of being
overwritten. Phones and pads vibrate through the Haptic module's presets: a tick on the player's own shot, a thump
for blasts by size and distance, and a longer one when their snail is hurt. Rules: Snails → "Blasts are felt, not
only seen".

### Bedrock can be blasted down to the water (2026-11-05)

**Before.** Each island's waterline blocks (`Arena_Indestructible`, Y 4 to 8 on both maps) were never cut: the carver
skipped them and the debris search counted any of them as ground. Blasts could dig an island down to that layer
but never through it, so there was always a floor under the snails.

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

**Before.** The snail tag, the drop marker and the damage number were BillboardGuis of a fixed pixel size (SnailTag
240 × 200). On a 1080p screen that matched the hud, but on a 667 × 375 phone a tag was about half the screen's height,
while the hud panels around it shrank with the screen. The tag's health number was also squeezed to the bar's 18 px,
by a shortcut in `Snails/Scripts/Client/Tags.lua` that worked around ume-gui's `Progress` status label growing tall
under a UIScale.

**Why it changed.** A gui audit on phone sizes: the hud was fixed to scale with the screen, and the labels over the
snails had to follow, or they covered the arena on small screens.

**Now.** Each world label's root is laid out at its design size (SnailTag 240 × 240, DropMarker 240 × 100, DamagePop
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

**Before.** A shot was aimed by dragging back from the snail: the drag's direction was the angle, its length the
power, and dots showed the first part of the shot's path. The lobby had one yellow **Play** (a quick match into the
fullest public row) and **Modes**, a window with Play solo (hidden a window deeper), Custom lobby and two random team
rows, so a mode like Trios was often not on the board at all. Party invites were Roblox-style confirmations asked one
player at a time.

**Why it changed.** The owner asked for Worms' aiming (a crosshair for the direction, a held charge for the power,
both seen by everyone) and a lobby like RoWorld's (their screenshots): Play solo up front, the public matches listed,
bots filling any empty seat, and a friends-only party match with bots on or off (half the coins without bots).

**Now.** A crosshair sits 9 studs from the snail toward the mouse, finger or right stick; holding charges a
flame-coloured power cone, letting go fires, a full charge (1.6 s) fires by itself, and bots turn then charge the same
way. The lobby's one panel holds the welcome line, Play solo (Play with party in a party), Custom and one card per
public mode; the solo or party setup and the waiting room take its place. Invites are kit-style boxes: a list of
players to invite, and an invite to answer. A match server now loads its map before waiting for its players, so a
party whose last member is slow sees the arena instead of an empty sky. Rules: Snails → "Aiming is a crosshair and a
held charge", "Everyone sees the active snail aim"; Maps and placeholders → "The lobby is a 3D stage", "Matchmaking
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
growing and going from yellow to red, lit as the power fills; other players and bots draw the same. Rule: Snails → "Aiming is a crosshair and a held charge".

### Power from the muzzle, sized for the screen (2026-11-06)

**Before.** The power circles started a fixed gap from the snail's ball, not at the weapon, and the held weapon turned
toward the aim the server sent back (`AimAngle`), so on the shooter's own screen it trailed the crosshair. Crosshair
and circles were sized in studs, so they shrank as the camera zoomed out.

**Now.** Every weapon model's RootPart has a `Muzzle` attachment (measured from side captures of each model), and the
circles run from it to the crosshair. MatchHud's aim calls Combat's client `SetAim` every frame it draws, so the held
weapon turns with the crosshair at once and the muzzle is where the circles start that frame. Sizes are studs at
MatchCamera's `DISTANCE`, scaled by the camera's distance. The shot itself still leaves from `MUZZLE_GAP` past the
snail's ball (the server's `Fire`), not from the barrel's tip. Rule: Snails → "Aiming is a crosshair and a held charge".

### Worms become snails, and the shell breaks (2026-11-06)

**Before.** Every player and bot was a worm: the placeholder `Classic` skin (pink balls with eyes), the `Worms` and
`WormControl` modules, the `WormTag` billboard and the lobby stage's `Worm` marker.

**Why it changed.** The owner made a snail model, with its body and shell as separate parts, and the game becomes
Snail Battlegrounds. They wanted the shell to break once a snail is badly hurt.

**Now.** `Classic` is the owner's snail, scaled to the old worm's size, and every name in the code and the place says
snail (`Snails`, `SnailControl`, `SnailTag`, the `Snail` collision group and marker). The game's name stays Worm
Battlegrounds until the rename the owner planned for last. Below 50 health (`SHELL_BREAK_HEALTH`) each screen hides
the skin's `Shell` part and throws chips in its colours, from the `Health` attribute alone; healing back up shows it
again. Rule: Snails → "A snail's shell breaks below 50 health".

### Back to the studio's wiki, and a bot match behind the lobby (2026-11-07)

**Before.** The game had drifted from the studio's original wiki: a crosshair and held charge for aiming, sudden death
from round 4, cut-off pieces of a ledge kept floating when big enough, bots and players who didn't place started
standing on land, health bars coloured by health with no team outline and no timer over the active snail, and the
lobby sat on a 3D stage with the player's snail on a podium.

**Why it changed.** The owner compared the game with the studio's wiki as it came and asked for its design back,
except where they had chosen otherwise (the RoWorld-style play panel, one public match per mode, party matches,
snails). For the lobby they asked for a blurred bot match behind the guis, as RoWorld's lobby has.

**Now.** Aiming is a drag on PC and touch (its direction the angle, its length the power, in shares of the screen's
height), and the right stick with a rising and falling RT power bar on a pad; the crosshair and circles stay as the
angle marker and power bar. Sudden death starts after 10 rounds. A cut ledge keeps only its biggest piece. Every snail
parachutes in. Tags show health in the team's colour, an outline in the team's colour, and the turn's seconds over the
active snail for everyone else. The mouse at the screen's side pans. The lobby server copies a random arena far away,
and each client plays four bots on it (walking, aiming, shots under gravity, blasts with the Arsenal's damage and
knockback, ghosts), blurred through ume's Lighting layers, with the camera following the action. Rules: Arena →
"Floating ledges float, but what's cut off them falls"; Snails → "Every snail parachutes in", "Aiming is a drag";
Maps and placeholders → "The lobby plays a bot match behind its guis".

The first backdrop was too busy: a random arena, four weapons, quick turns under the match's gravity, and shots that
blew up at once when a bot stood under a floating ledge. The owner asked for a small, slow match on Picnic Plains with
the Bazooka, the Grenade and the jetpack. It now has its own gentle gravity, long thinking and resting between turns,
short jetpack hops (4 studs up, landing at about the same height: higher looked bad on the close camera), weaker
knockback, and bots that try several arcs for one no ledge overhead catches.

### A map built in Studio, and a yellow sea (2026-11-07)

**Before.** Every map came from MapLab, and each liquid had one colour in every map (Arena's `LIQUID_COLORS`).

**Why it changed.** The owner built a rocky map by hand in Studio and asked for it in the game as it stood, with
yellow water. Its look matches the wiki's planned Rockslide Ridge, which took its name.

**Now.** The map was imported where it was built: its parts renamed by colour, moved to SmoothPlastic with
`2022 Stud`, sorted into islands (standing on the floor, their floor parts bedrock), floating ledges and the backdrop
wall, with a `Sea` and `Bounds` marker. A liquid marker's `Arena_LiquidColor` colours its liquid on that map. Rule:
Arena → "Maps are made in MapLab" (the import line).

### Maps in slots, on one plane (2026-11-07)

**Before.** MapLab exported every map at the origin, so templates landed on top of each other; Desert had been moved
22.75 studs back by hand, and Rockslide Ridge stood where it was built, 270 studs back. The drop picker assumes the
play plane is Z = 0, so on both a landing pick missed where the mouse pointed.

**Why it changed.** The owner asked for the asset folders sorted, nothing overlapping and easy to view.

**Now.** Templates stand side by side along +X in 400-stud slots, MapLab's lab spacing (X = (slot − 1) × 400), all
with their Bounds at Z = 0, and MapLab's export puts a map in its slot. Rule: Arena → "Maps are authored in …".

### Billboard templates on holders (2026-11-07)

**Before.** The SnailTag, DamagePop and DropMarker exports sat in StarterGui, where Studio drew them at 0, 0, 0 over
the maps, and the Snails and Match servers moved them out of the gui loader's folder at start.

**Why it changed.** The owner wanted them out of the way and easy to fetch.

**Now.** Each lives with its module's assets as `PREFAB | <Gui>` (a Model with an invisible 1 × 1 × 1 `RootPart`, an
`Attachment`, the BillboardGui `U_<Gui>`), in `ReplicatedStorage_Assets/Snails` and `/Match`; clients clone the
billboard from `I.Dirs.Assets`, and the servers no longer move anything. Rule: Guis → "World labels scale with the
screen too".

### The server checks how high a snail climbs (2026-11-07)

**Before.** While a player moved their snail, the server checked only its speed (sideways and up) and the stamina it
walked. Nothing limited how high it climbed in a turn, and the jetpack's fuel was counted on the player's client alone,
so a changed client could rise about 70 studs a second for the whole turn, or drop through a ledge in one step.

**Why it changed.** An audit of the game's remotes and checks found it; the owner asked for the fix.

**Now.** SnailControl's server check (`Scripts/Server/Control.lua`) also casts a ray along the snail's path each frame
and takes it back when the path crosses the terrain, and it charges every stud the snail climbs above a jump's reach
from the ground it last stood on to the jetpack: `JETPACK_SPEED` studs per second of the `JetpackFuel` it was given,
plus `LIFT_GRACE`. Rule: Snails → "The active snail is moved by its player's client".

### Icons uploaded instead of kept local (2026-11-07)

**Before.** The first icon kit's pictures (weapons, utilities, emotes, coin, diamond, crate) and the Brawl kit's wind
stayed local previews in Studio's content folder (`rbxasset://textures/wb_guipreview/…`) until the owner approved
them, and a Studio update meant copying them in again.

**Why it changed.** A Studio update wiped them and every icon went blank; the owner chose to upload them rather than
copy them back.

**Now.** All 17 are on Roblox, and the themes' `Icons.lua` and the item, currency, crate and shop data use their
`rbxassetid://` ids (the kits' `uploaded.json`). Nothing in the game uses a local picture. Rule: Guis → "Pictures
drawn for the game stay local until the owner approves them".

### Spawns under the roof, water as deep as the ground (2026-11-07)

**Before.** Land spots were looked for from the top of the bounds down, and a drop could be placed anywhere inside
them; the liquid was drawn as deep as the bounds. On Rockslide Ridge, whose rock ceiling runs 10 studs under the top
of its 25-deep bounds, snails spawned on top of the roof, and its sea stood far out in front of the ground.

**Why it changed.** The owner saw both, and asked for a fix that no new map repeats.

**Now.** Nothing starts in the bounds' top 20 studs (Arena's `START_TOP_GAP`, the drop height): `GetLandSpots` looks
from there down, `IsFree` refuses it, and the drop picker's `DropMaxY` stops there. The liquid takes its depth from
the map's bedrock at load (the middle of its blocks' backs and fronts, Loader's `GetGroundDepth`). Neither needs a
value per map. Rule: Arena → "Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`".

### Projectiles on the game's own simulation (2026-11-07)

**Before.** Each shot was a server-owned Roblox physics ball (elasticity, a wind VectorForce, a PlaneConstraint),
checked by raycasts between frames and replicated to clients by Roblox's physics. Grenades bounced the way Roblox's
solver liked, shots in liquid passed through it and burst on the sea floor, and clients drew whatever replication
gave them.

**Why it changed.** The owner wanted the arcade feel of the original Worms (bounces, rolling, grenades that settle)
and shots that look smooth on every screen while the server stays the authority. FastCast2 was looked at: it's built
for thousands of fast 3D bullets and has no bouncing, rolling or settling, so the game has its own small 2D
simulation instead.

**Now.** Combat's `Ballistics` helper steps shots on both sides at 60 steps a second on the server's clock; the server
launches them (`Combat_Shot`), sends their state every 0.1 s and ends them; clients predict, rewind and replay on a
mismatch, and ease corrections out. Rule: Snails → "Shots fly by the game's own simulation, not Roblox physics".

### Aiming from the snail to the mouse (2026-11-07)

**Before.** The drag that came back from the studio's wiki measured everything from where the press began: its
direction was the angle and its length the power. The weapon didn't move until a press, the crosshair never lined up
with the mouse, and a drag toward the screen's side edge-panned the camera, so the view slid away mid-aim.

**Why it changed.** The owner found the positions wrong and wanted the weapon to follow the mouse.

**Now.** The weapon points from the snail toward the mouse every frame (through the arena's plane, so the crosshair
lies on that line), held or not; while the button or a finger is held, the power is the pointer's distance from the
snail on the screen (`MIN_PULL` to `MAX_PULL`); MatchCamera doesn't edge-pan while the left button is held. Rule:
Snails → "Aiming points from the snail at the mouse".

### The tester's round: guns, slow shots, placed Dynamite, the sea, bots that move (2026-11-08)

**Before.** The Shotgun, Uzi and Minigun did nothing: their behaviour called `Projectiles.GetSnail`, which lives in
`Ballistics`, so every gun shot errored before its first bullet (`Combat::Fire … attempt to call a nil value`, only in
the Output). Shots flew at full speed, a full charge reached only about 73 studs with the Bazooka, shots sank and
fizzled in water and lava, every liquid knocked snails out (a dip in Desert's oasis too), the Dynamite was a thrown
1.6-stud stick, and bots stood where they landed all match.

**Why it changed.** A tester's notes, passed on by the owner: guns broken, max power too short, the grenade's blast
15% bigger, explosives that blow up in liquid, a 4× Dynamite placed on the snail with 3 seconds and fresh stamina to
run, shots 40% slower to follow by eye, only the rising sea deadly, and bots that move like players and use jetpacks.

**Now.** Guns call `Ballistics.GetSnail`. The simulation runs at `PROJECTILE_TIME_SCALE` 0.8 (same arcs, slower; 0.6 felt too floaty to the owner), and
arc weapons' `MaxSpeed` went up 25% (about 56% more reach at full power; the Bazooka 120 → 150). The Grenade's blast is
6.9. Explosive shots burst on touching any liquid. Dynamite is `Aim = "Feet"` with a `Retreat` of 3 s
(`I.SnailControl.Retreat`) and a 3.5 s fuse; its placed model is `Projectiles/Dynamite`, 4× the held one. Only the sea
kills (Arena's `GetHazard`, the liquid marker at the bounds' bottom). Bots walk, climb, jump and fly (`Bots/Scripts/
Server/Move.lua`), look for a spot their shot lands from, close in to swing or place Dynamite and run, and heal. The drop
phase is 10 s (was 15). Leaving a match sends a player once (a second send while the teleport runs is skipped), and a
teleport that can't start says so; the tutorial match counts as played when it ends, not only when it's left. Checked
in Studio: Minigun bullets, bot movement and climbs, Dynamite placed and blown, the oasis safe and the lava sea deadly,
the Studio map's Lobby button and replay. Live teleports (back to the lobby, party matches) couldn't be tested here.
Rules: Arena → "Only the sea knocks snails out"; Snails → "Shots fly in slow motion", "Dynamite is placed, not
thrown", "Bots play like players".

## Match sounds from the Creator Store (2026-11-08)

**Before.** The match was silent but for the music and gui clicks: no weapon, blast, snail or turn sounds.

**Why it changed.** The owner asked for sounds on everything that should have one, using Roblox ids that match,
without uploading anything.

**Now.** About 40 named sounds in `SoundsList.lua`, all free Creator Store ids checked to load in Studio (Roblox's
Pro Sound Effects and APM uploads where the search found them): `Fire_<itemId>` and `Use_<itemId>` from the server
when a weapon or utility is used, blasts and bounces from Combat's client, snail steps, jumps, landings, jetpack hum,
hurts, shell cracks and knockouts (splash, burn) from Snails' client, and turn chimes, the last-seconds tick, the
sudden-death siren and the win or lose sting from MatchHud. Roblox fades a positional sound out by 100 studs by
default, farther than the match camera sits, so world sounds carry Combat's `SOUND_ROLLOFF_MIN`/`MAX` (150/600). The
search can't filter by uploader and many results are rips from other games, so ids were picked by plain names and
checked one by one; the studio may want to swap some by ear. Rule: Maps and placeholders → "Match sounds are free
Creator Store ids, played by name".

## Bots with a brain, trained by self-play (2026-11-08)

**Before.** Bots ran fixed rules: a target by difficulty (Easy any, Medium the nearest, Hard the weakest), a grid
search for an arc that lands near it, then a deliberate miss often enough to match a `HIT_RATE` per difficulty
(Easy 0.3, Medium 0.6, Hard 0.85). They walked to a spot their shot landed from and closed in for a swing or
Dynamite on a chance (`CLOSE_IN_CHANCE`), but knew nothing of where they stood, friends, the sea or the terrain.

**Why it changed.** The owner asked for bots that get better by playing themselves, feel like real players the harder
they get, place themselves well on the map, use jetpacks, weapons and utilities properly, mind other players, play
well in teams, keep off ground that a blast would drop them through, blast the ground out from under enemies, and a
secret Nightmare difficulty that uses the map to the full.

**Now.** A planner (`Bots/Scripts/Server/Brain.lua`) lists the spots a bot's walk and jetpack reach, each with what
it knows of it (a deadly edge, its footing, low ground as sudden death nears, height, who sees it, friends and enemies
near), solves every weapon's shot at its targets and at the ground under them exactly for the wind it reads
(`Aim.lua`), simulates the best in full with Combat's own shot bodies, blasts, throws and the craters' drops
(`Predict.lua`, which needed `I.G_Combat.NewBody`/`StepBody` and `I.Arena.GetSeaLevel`), and scores what each does
with its difficulty's genome. Difficulty became skill (`SKILLS`): a hand that shakes and steadies as it walks its
shots in, how much of the wind it reads, how many spots, targets and aim points it weighs, how much it minds the map.
The genomes are trained by self-play (`Gym.lua`, `Sim.lua`): headless matches between a population of genomes on the
real maps, with crossover, mutation and an exam against the shipped genome; the `train-bots` skill is the procedure.
Bots pick their drop spot with their genome, and snails keep a `LastAttacker` attribute bots hold a grudge with.
Rule: Snails → "Bots think with a trained brain".

## Slow loads when players join together (2026-11-08)

**Before.** VoiceChat's client `Start` went through the players already in the server one by one and waited up to
30 s for each one's `VoiceChat` input (`player:WaitForChild(_localName, 30)`).

**Why it changed.** Live joins took about 90 s, while Studio loaded in under a second. The server gives a player their
voice input only after their data loads, and loads their data only once their client has finished starting every
module (the Player module's `_added`). Players who arrive together, a party teleported into a match most of all, each
waited for the others' inputs, which waited on their own loads: 30 s for each other player, so 90 s with three.

**Now.** Each wait runs on its own thread (`task.spawn(Module._watchPlayer, player)`). Rule: Loading → "A client's
Init and Start never wait on other players".

## Shots at half speed (2026-11-08)

**Before.** Shots flew at `PROJECTILE_TIME_SCALE` 0.8, and every `Fuse` ran in real seconds, so a thrown Grenade burst
after 2.4 s of its path instead of 3. Bots simulated 8 real seconds of each finalist shot.

**Why it changed.** The owner asked for shots 50% slower, with the same properties: only the simulation slower.

**Now.** `PROJECTILE_TIME_SCALE` is 0.5. A thrown bomb's fuse is divided by the scale (`Bouncer`, and bots'
`Predict._fly` the same way), so a 3 s Grenade fuse lasts 6 real seconds and bursts at the same point of its path as
at full speed; the placed Dynamite's fuse stays in real seconds, since it doesn't fly. Bots' `PREDICT_SECONDS` counts
the shot's own time (6.4, what 8 real seconds covered at 0.8), so their predictions see as far as before. Rule: Snails
→ "Shots fly in slow motion".

## Cooldowns from the start, worms, spider bomb, liquid and homing hint (2026-11-08)

**Before.** Cooldowns started only after an item was used, so strong weapons were free on the first turn. The variety
grenade let out four snails that crawled down-left, down-right, left and right as yellow balls. Flying shots were drawn
at their weapon models' held size. The spider bomb flew by Roblox physics (`Projectiles.Spawn` with a counter-force),
then crawled by snapping to the ground a whole stud at a time, and turned back and forth under its target. A homing
missile gave no hint that its first click picks a target. And when a carve cut terrain loose, the liquid grid kept the
falling piece's old cells as ground: Arena's `Debris._watch` refreshed only where it landed.

**Why it changed.** The owner's list: cooldowns from the match's start, worms that look like worms and dig down,
bigger projectiles, water that bugged out when terrain was destroyed, a buggy spider bomb with too short a throw that
couldn't walk 1-stud steps, and "click on target, then shoot" for the homing missile.

**Now.** `Uses.Reset` (and the bots' `Sim`) puts every item with a `Cooldown` on it at `Cooldown + 1`, as `Take` does.
The burst shot is `Worm` (`Projectiles/Worm`, a pink segmented worm built in the place, head first along its pivot's
look, eyes toward the camera); worms dig in a downward fan and drown in liquid. Clients draw flying models
`PROJECTILE_DRAW_SCALE` (2) times their size, placed items aside, and glide models of server-moved parts after them. The
spider bomb is thrown with `Projectiles.Launch` and `Fly` (no bounce, it lands on what it touches), `MaxSpeed` 100 → 125,
then crawls with `CRAWL_STEP_UP`, `CRAWL_STEP_DOWN` and `CRAWL_STOP`. `Debris._watch` refreshes the liquid where a
piece fell from too. MatchHud's power bar reads `TARGET_HINTS`. Rule: Snails → "Strong items start on their cooldown"
and "Server-moved shots glide on clients".

## The studio's screens and effects, ported 1:1 (2026-11-09)

**Before.** Every gui was built from the GUI kit's theme controls, and blasts, tracers and snail moments were
placeholder particles made in code (`BLAST_TEXTURES`).

**Why it changed.** The studio sent its own designs (`HUD`, `LobbyInventory`, `Gacha`, `Customise` in Studio's
`Workspace.New.Guis`), particle effects (`Particles_1`, `Particles_2`) and weapon icons, and the owner asked for them
"almost 1:1" and connected to the game's systems, replacing the old screens.

**Now.** A converter turns each design, node for node, into a UmeGui table of `Primitive` nodes after an annotation
pass on a clone (Ids, prefabs, `Look_*` attributes, button tags, the widget shape). Blocks the designs lack stay theme
controls in the same table. Effects are `PREFAB | <Name>` parts in `ReplicatedStorage_Assets/Vfx` played by the new
Vfx library. Things learned on the way:

- **UIStroke's `StrokeSizingMode` must be copied:** the designs' outlines are `ScaledSize` with thicknesses under 1;
  copied without the mode they become sub-pixel and vanish.
- **UmeGui numbers a node by its place in `Children`** when it has no `LayoutOrder`, which reshuffled list layouts; the
  converter always writes it.
- **Some of the designer's pictures draw blank in the game** (the crate, the player and coin icons, item icons) though
  they load: the game uses its own pictures there (the crate rows' `Picture`, the theme's `wb-coin`, MatchHud's
  `BOT_AVATAR`). Check new design pictures by drawing them in a play test.
- **A ScrollingFrame's scale `CanvasSize` follows its parent's size**, not its own window: the emote row's cards grew
  past the row until the canvas was set to 0 (it then falls back to the window).
- **A `Currency_Slot` needs its `Currency_UIScale` pointed at a UIScale after every export,** or its count stays at
  the design's text.

Rules: Guis → "The studio's screens are 1:1 `Primitive` ports"; Snails → "Effects are the studio's particle
prefabs".

## The rigged snail (2026-11-09)

**Before.** The snail was a static mesh (`Body` and `Shell`) welded part by part to its ball, and the held weapon
floated beside it at a fixed offset (Combat's `HELD_FORWARD`, `HELD_HEIGHT`, `HELD_DEPTH`), turned to the aim.

**Why it changed.** The studio sent its snail rigged, with hands and animations (`Workspace.New.Snails`): `Snail`
with Idle, Walk and two clips into and out of its shell (`1`, `2`), and four copies holding a weapon with its `Shoot`
clip (Gun for the Uzi, MiniGun, Bazooka, ShotGun), which the owner said are only there to carry the holding
animations. The owner asked for the rigged snail as the default, animated.

**Now.** `Classic` is the rig, scaled to the old snail's 0.45, with the weapon snails' `Handle` added, and the
`SnailRig` library animates it on each client. Things learned on the way:

- **Weld only the rig's root:** welding every skin part to the ball (as the static skin was) freezes the Motor6Ds and
  bones the animations move.
- **A pose holds a weapon forward, but aims go all round:** the weapon and its hands are pitched about the `Handle`
  each frame after the animations (`PreSimulation`, writing the Motor6D's and the hand bones' `Transform`), so one
  pose serves every angle. The Animator writes each animated joint every frame, so the offsets never pile up.
- **The studio holds weapons in the snail's right hand,** which faces away from the camera when the snail faces left:
  there the weapon and both hands are mirrored across the snail's middle, and a standing snail turns to face its aim.
- **A skinned mesh's part box isn't where it draws:** the rig's `Shell` part sits well above the drawn shell, so the
  skin was placed by its body and its foot, not by part positions.
- **Unpublished animations play in Studio only** (`RegisterKeyframeSequence`), so each sits as an `Animation` with its
  keyframes and an empty `AnimationId` until the owner publishes it.

Rules: Snails → "The snail is the studio's rig", "The active snail holds its weapon in its hands".

## Smooth holes and plane-locked falls (2026-11-09)

**Before.** The server cut a blast's terrain parts one after another, each `SubtractAsync` yielding, and swapped each
part for its pieces as it finished, so clients saw a hole open in steps, a replication late. Cut-loose ground was
welded and dropped on Roblox physics, so it tumbled in front of or behind the map and anchored where it settled.

**Why it changed.** The owner found the holes "not as smooth as it can be" and asked for falling chunks on the game's
own physics, locked to the map's axis, so players can make bridges.

**Now.** Arena's `Cutter` helper builds and cuts on both sides; the server cuts every part at once and swaps in one
frame; each client cuts the hole the moment `Arena_Carve` arrives; loose groups drop straight down on the plane.
Things learned on the way:

- **One CSG cut takes a few milliseconds; the wait was the yields in a row.** Cutting every part at once made the
  server's hole land in one frame.
- **Parent the pieces before removing the parts:** clients get both in the same frame, so the ground never shows a gap.
- **A later hole must be cut into an earlier carve's pieces:** with two blasts close together, the server's pieces
  for the first arrive after the client cut the second, so the client cuts them again at once and keeps its old pieces
  up until that's done.
- **`Workspace:Shapecast` works on unions and on parts with `CanQuery` off,** which is how a falling group finds where
  it lands, each group standing in its landing spot for a moment so the ones above land on it.

Rules: Arena → "Each client cuts the holes itself", "Cut-loose ground falls by the game's own gravity".

## A party stage in the lobby, and server-only code off the clients (2026-11-09)

**Before.** Behind the lobby's panels each client played its own blurred bot match, about 900 lines of client code. The
bots' trained genomes (`Data/Brains.lua`) and their skills sat in files every client received, as did the exact arc
solver behind the admin aim guide, which a client started from its own copy of the `Aimbot` attribute. The movement
checks' margins, the match payouts and the level curve were in client-visible settings, the server never checked a
snail stayed on the arena's plane, and a public server of the match place played a paid match for whoever joined it.

**Why it changed.** The owner wanted a Fortnite-style lobby where friends who join your party stand around you, and
asked that players can't read the game's sensitive code.

**Now.** The lobby is a stage with four pods (the old `LobbyStage`, now Lobby's `PREFAB | Stage`): you in front, your party around you in their skins (Lobby's
`Stage`, the new `EquippedSkin` Player attribute). Server-only settings and data use names ume hides
(`ServerSettings.lua`, `ServerData/`), the arc solver moved to the server (`I.Combat.GetArcs`, `PredictArc`), and the
server solves the aim guide and sends it to the admin's player alone. The server snaps back a snail off the plane,
and a stray match server sends everyone to the lobby.

Things learned on the way:

- **ume loads every module's `Settings.lua` on clients,** even a module with only a `Server.lua`, so hiding a module's
  scripts isn't enough: its settings and `Data/` replicate too.
- **A client reading its own Player attribute is no gate:** an exploiter sets it locally. Whatever it unlocks has to
  come from the server.
- **A back pod straight behind the front snail hides behind its shell:** the back pod stands on a tall pedestal, so
  all four snails show between the Party and Loadout panels. A camera high above, looking down, showed them too, but
  the owner found the view from above odd: it sits low and close now, and the pedestal is taller instead.
- **A stage loaded from the place loader's folders can't be seen while building:** it lives in ServerStorage. As a
  prefab in `ReplicatedStorage_Assets/Lobby`, it stands in the Workspace in Studio, edited by hand, and each client
  clones it.
- **The power and stamina bars' picture has its empty end drawn in:** its fill covers only the left 0.744 of it, so a
  gradient cut at the share stopped at 70% to the eye. The cut is now the share times `BAR_FILL`.

Rules: Maps and placeholders → "The lobby is a party stage"; Server and client.

## Shots aimed into the ground start on it (2026-11-10)

**Before.** A shot started a fixed distance from the snail's ball along the aim (`ROOT_SIZE / 2 + MUZZLE_GAP`, 2.1
studs), wherever that was. Aimed down at the ground under the snail, that point was inside the terrain.

**Why it changed.** Grenades and Bazooka shots aimed down went through about 5 studs of ground and burst under it.
`Ballistics` finds what a shot touches with a spherecast per step, and **a cast that starts inside a part never hits
that part**: the shot fell through the ground until it came out the other side.

**Now.** `Projectiles.GetStart` (`I.Combat.GetShotStart`) raycasts from the ball's middle along the aim and starts the
shot just short of the terrain or snail in the way, or `MUZZLE_GAP` past the ball when nothing is. `Fire` and the
bots' predictions (`Predict.GetShot`, `Aim.GetContact`) use it, so a bot foresees the same shot. Rule: Snails → "Shots
fly by the game's own simulation".

## A map dragged off the plane (2026-11-10)

**Before.** The arena plays wherever its template stands, and everything that turns the screen into the arena (the
drop picker, the aim, the shot simulation's plane) takes the plane as Z = 0, as the maps are authored.

**Why it changed.** In custom lobbies, which default to Picnic Plains, the aim was inverted, the drop couldn't be
picked, and invisible shots carved the bottom of the map. The `PicnicPlains` template in the place had been dragged in
Studio to Z −810.5, so the match played far off the plane every screen read. Nothing checked it, and other maps were
fine.

**Now.** Arena's `Loader._cacheTemplates` warns and moves a template back onto Z = 0 when its Bounds aren't on it, so
one dragged by accident still plays. Rule: Arena → "Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas`".

## Shots through water, bots for dropped players, the leader picks (2026-11-10)

**Before.** Any liquid, a pond too, blew up an explosive shot that touched it, and only the spear sank. A player who
dropped kept their seat for 60 seconds, skipping their turns, and their snail was then knocked out. A party member
could press Join, Solo and Custom like their leader.

**Why it changed.** The owner (2026-11-10): "in water you should be able to shoot through it, projectiles move through
water but slower". A drop on a phone shouldn't lose a team its snail, and a party's members shouldn't start matches
their leader didn't pick.

**Now.** `Ballistics.Step` slows a shot as it enters liquid and drags it while it's under (`SINK_*`); behaviours burst
it on what it touches there or by its fuse. A bot plays a dropped player's turns (Match's `Autopilot`), and the
player takes over again from their next turn. A party member's board buttons are greyed out, and a custom lobby takes
the leader's whole party in. Rules: Arena → "Shots fly on through any liquid"; Snails → "A dropped player's snail
plays on under a bot"; Maps and placeholders → "A party's leader picks the match".

## Turns announced, and fights that hit harder (2026-11-10)

**Before.** A turn started with a sound and the banner's text; the player's last seconds only ticked. A blast's
effects, the camera and the damage number looked the same for a scratch and a knockout. Turns waited on settling up to
8 seconds and bots thought for up to 2.2.

**Why it changed.** The owner approved a "your turn" and "fight feel" draft: players should feel their turn start and
run out, and a big blow should land. The first callout was drawn in the GUI kit's yellow Hazard plate; the owner
turned it down: "this is old style, the new style is MatchBoard or MatchHud".

**Now.** MatchHud plays a callout as each turn starts and tightens the last seconds (`U_Tension`, the timer's colours, faster ticks).
Combat's client stops the world for a beat on a big blow (`_hitStop`, `I.MatchCamera.Freeze`) and the camera punches in
on a knockout (`Combat_Hit`'s `knockout`, `I.MatchCamera.PunchIn`); damage numbers grow with the hit (`POP_TIERS`);
lobbed shots whistle as they fall and the camera leads flying shots. Settling and bots' thinking are shorter
(`SETTLE_HOLD`, `MAX_SETTLE`, `THINK_TIME`, `AIM_TIME`). Rules: Snails → "Big blows stop the world for a beat"; Guis →
"Turns are announced, and the end of a turn tightens", and "The studio's screens are 1:1 `Primitive` ports".

The second callout, two blocks on the timer's trapezoid frame (`U_TurnCallout`, `U_TurnCalloutOther`), was turned
down the same day: "the ui your turn looks bad, polish it up, make it look professional", and "add the player
avatar/bot icon". It became one banner as `Primitive` nodes, `U_TurnCallout`: a full-width dark band with accent
lines, the snail's avatar (`Teams.SetAvatar`), a gold or white gradient title and a line under it, opening, sliding
in and settling, then sliding on as it closes (MatchHud's `CALLOUT_*`).

## Ponds the sea reaches, obsidian, bots that always fire (2026-11-10)

**Before.** Only liquid at or just over the sea's level knocked snails out, so a pond the rising sea had flooded into
stayed safe above that level. Water and lava passed through each other. A bot whose brain found no plan let its turn
run out.

**Why it changed.** A pond the sea had flooded into looked like the sea but was safe to fall in; water and lava met
with nothing happening; a bot with no shot stood still for its whole turn. (The change came with no recorded owner
quote.)

**Now.** Arena's `Liquid._markSea` flood-fills the liquid of the sea's kind joined to the cells under its level (after
a build, `RaiseLiquid` and every `SEA_MARK_STEPS` steps), and `GetHazard` treats it as the sea (`Liquid.IsSea`). On a
map with both liquids, water touching lava turns solid each step and `Obsidian.Build` makes it terrain parts that
blasts cut. Bots fire the Bazooka toward the nearest enemy when they have no plan (`_fireAnyway`). Rules: Arena →
"Only the sea knocks snails out"; Snails → "Bots play like players".

## A mood for each place (2026-11-10)

**Before.** The lobby and every map shared the place's own lighting: colour correction saturation 1.0, a teal ambient
and a purple outdoor ambient, latitude 76 at 14:30. Nothing moved in the world between shots, a blast through a tree
only threw its pieces, and falls into water or lava only splashed when a snail was knocked out.

**Why it changed.** The owner asked for "some kind of atmosphere system, so each of the levels have different feeling
based on the theme", "subtle, high quality, minimalistic but visible", "not ultra realistic", keeping "worms type of
colors, but in a professional way": leaves from destroyed trees, lava bubbles, splashes when something falls in, the
particles in the style of the existing ones, and a lobby lighting that is "solid, universal, visible, peaceful". A
drawn plan of the four moods and six reactions was approved before building.

**Now.** The Atmosphere module (client only, no remotes) picks the mood from `InMatch` and the match's `MapId`, sets
its preset from `Lighting.Presets`, streams its `Ambient_` prefabs over the map's bounds with the wind's pull, plays
surface and ceiling effects on spots in view, deepens the light in sudden death, and reacts to Arena's `Arena_Carve`
and `Arena_Fall` and to chips, shots, props and snails crossing a liquid's surface (Arena's liquid parts now carry
`Arena_Liquid`). Tuning in a playtest taught two things: Rockslide Ridge first came out slate blue, because the bright
blue skybox lights shaded rock through `EnvironmentDiffuseScale` and the haze pulls toward the sky, so the cave keeps
that at 0.25 with a warm-grey haze; and the dust puffs cloned from the additive spawn smoke vanished on sand, so the
module's puffs blend normally. The music per mood was added to the same module by the sound work the same day. Rule:
Snails → "Each place has its own mood, subtle and in the game's colours".

## The game's own sounds and music (2026-11-10)

**Before.** Every sound was a free Creator Store id (the owner, 2026-11-08: "find roblox ids, no uploading"): a mix
of licensed effects, community uploads and a 3-note "ta ra ra ra ram" turn sting the owner disliked. The lobby and
every match played one placeholder `BGM` track and a separate `Ambient` loop; maps had no music of their own.

**Why it changed.** The owner asked for the game's own sounds, made like the farm game's, in "the roblox 2005
soundscape... Great Strategy is the vibe": the old rocket launcher for the bazooka, classic notifications, a death
sound, music per map that loops, is epic and isn't annoying, and a faster, more dynamic sudden death. They listened to
each round in a preview page before anything was uploaded. Rounds changed: GM-instrument themes were "not the style";
unique tunes per theme on the classic samples were "cool"; then the themes became Worms Armageddon-style level streams
(ambience and a quiet level song mixed as one), whose wind, sand and birds were first too loud, then whose melodies
"need to chill out"; Rockslide Ridge's busier take was kept ("epic"); the lobby became "really really subtle, but
iconic" over a plains ambience; the turn calls went "military" for a battle game.

**Now.** The kit in `art/sfx` builds everything from code (numpy, the classic Roblox sample pack, Roblox's 2009 sound
ids) and a preview page. 18 effects are Roblox's own 2009 sounds played from their ids (and the official OOF); 28
effects and 9 music pieces were uploaded to The Snail Studio through Open Cloud (all approved by moderation) under
plain titles. Studio's own import was tried first and lost its queue when a playtest reloaded the place; Open Cloud
needs the upload folder approved in Studio's Assistant Settings → MCP Permissions, which only the owner sets. Hooks
added: time up, the knockout ding, the sea rising, obsidian's hiss, a window opening, the teleport card's whoosh out
and in. Rules: Maps and placeholders → "Sounds are the classic 2005-2009 Roblox soundscape" and "The music is a level
stream".

## The camera follows every shot (2026-11-10)

**Before.** While it followed a shot in flight, the camera dropped its ceiling by adding `Vector3.yAxis * math.huge`
to the bounds' top. Zero times infinity is NaN, so the bounds' width became NaN, the sideways clamp failed, and the
view slid to the arena's middle while the rocket flew elsewhere (a playtest log: rocket at X 880, camera at 805).
`pan = goal - center` then stored that slide, and every clamp at a map's edge, as if the player had panned, so the
camera stayed off its blast and off the next snail. Guns and swings (hitscan) left no part to follow, so the camera
stayed on the shooter and then snapped to the next snail at full follow speed.

**Why it changed.** The owner: "we shoot and the camera does not follow the bullet, switches fast to another player.
Make sure all is shown, make sure the camera works and is not confusing."

**Now.** The clamp keeps the top as a number of its own, and the pan is measured from where the view sits with no
pan, so it's only what the player moved. The camera glides to where bullets landed (`Combat_Tracer`), holds where a
shot ended with no blast here, follows a snail a blow sent flying, and glides to the next snail. Checked in a Studio
match on Rockslide Ridge: the camera stays 5 to 10 studs ahead of the rocket, settles on the blast, and moves on after
it. Rule: Snails → "The match camera shows every shot to its end".

## One place for the pad (2026-11-10)

**Before.** Each module bound its own gamepad buttons with `Enum.KeyCode` names: SnailControl (D-pad, A, left stick),
MatchHud's LoadoutBar (LB, RB) and Aim (RT, B, right stick, LT), MatchCamera (right stick with LT) and the drop
picker (left stick, A). The Console module only showed `Console_Hint` elements and swapped their icons; the game's
guis had two hints (LB and RB as text). Nothing selected a gui on a pad, and Utils' ButtonPress ignored every key
while one was selected, so B, X and the shoulders did nothing once a player pressed View. LB and RB stepping onto a
utility used it, and stayed on it, so a pad could never reach the weapons after a utility.

**Why it changed.** The owner: "add console button hints and design everything to correctly work with gamepads ...
use 0_Console module for all gamepad related keybinds", after research into how popular Roblox games and console games
map pads (Start is Roblox's, A confirms, B backs out, shoulders switch, triggers fire).

**Now.** The Console module's `ACTIONS` setting is the scheme: every action's buttons, hint text and priority. Modules
bind through `I.Console.Bind` or read through `IsAction` / `IsHeld`; buttons that guis press (`Utils_ButtonKey`) are
`Gui` rows, and their hints name the action (`Console_Action`), so a hint shows the scheme's button and text for the
player's pad. The module also runs the selection on Console: View starts it where the player is, widgets with buttons
no key presses get it (their A button first), the lobby rests it on Solo vs bots, panels and the emote wheel hold it
(`Focus`), and B, which Roblox spends on clearing a selection, backs out. ButtonPress now skips only A while a gui is
selected. LB and RB step past utilities (Y uses one). The game's own glyphs were drawn as a kit (`art/console_glyphs`)
and stay local until the owner approves them; `HINT_STYLE` swaps them in. MatchHud's Aim still reads RT, B, the right
stick and LT itself until its hold-to-charge rework moves them to the scheme. Rule: Guis → "The pad goes through the
Console module".

## Chat bubbles and badges after names (2026-11-10)

**Before.** Chat showed only in Roblox's chat window and its own bubbles, which floated over the players' avatars,
parked out of sight under the map, never over their snails. Names (on the SnailTag, the turn list, Party, Results)
were plain text: nothing told the owner, the developers or Roblox staff apart.

**Why it changed.** The owner picked a drafted look, "Bubble Style B, and the icons are good", and asked: "if a player
has multiple, display multiple (so for example I'm a developer, a game owner, and I'm verified and also have premium,
display all of them)".

**Now.** The ChatBubbles client turns Roblox's bubbles off and listens to `MessageReceived` (Shop already uses
`OnIncomingMessage`, which takes one callback). A message becomes a bubble in the `ChatBubble` billboard over the
speaker's snail on this screen, found by the `InMatch` attribute: the match snail, standing over its SnailTag's
`S_Stack` (an Id added for this), or the lobby stage's snail (`I.Lobby.GetStageSnail`, the Lobby client's first API).
Bubbles are sized from `TextService:GetTextBoundsAsync`, but scaled text draws about 5% bigger than it measures, and a
box that fits exactly wraps "Watch the wind" onto two lines: the box gets 6% more room (`TEXT_ROOM`). The tail is a
square on its corner behind the body, with a white joint over the body's outline where they meet, so the outline runs
on down the tail with no picture.

Badges are the PlayerBadges server's: it writes a `Badges` Player attribute from `I.Group` (The Snail Studio's ranks,
Roblox's group, Video Stars), `I.AdminPanel.CanOpenDashboard`, `HasVerifiedBadge` and `MembershipType`. The studio's
group has five roles at rank 1 (Member, Tester, Build, Management, LEAD), so ranks can't tell a developer from a
member: the owner picked role names (`OWNER_ROLES` LEAD; `DEVELOPER_ROLES` LEAD, Management, Build) beside the ranks
(255 the crown, 254 and up the wrench). Roblox's verified and Premium glyphs (`U+E000`, `U+E001`) draw in the game's fonts (checked in Studio: the
verified badge keeps its blue, Premium takes the text colour), so only five icons were drawn, as a kit in
`art/badges` (SVGs, a build script, a preview), local until the owner approves them. Each name keeps an `S_Badges`
frame beside it; `I.PlayerBadges.Show` narrows the name by the badges' room and places them after its text. Narrowed
scaled text with `TextWrapped` broke names mid-word ("HungryN00 / B"), and turning wrapping off made Roblox stop
shrinking it, so the name's `UITextSizeConstraint` is lowered to the size that fits one line, measured once per text.
Rules: Guis → "Chat shows in bubbles over the snails, never Roblox's" and "Badges after a name are the server's, and
every one shows".

## Worms Armageddon's shot: hold to charge (2026-11-10)

**Before.** Since 2026-11-07 the power was how far the held mouse (or finger) was from the snail on the screen
(`MIN_PULL` to `MAX_PULL`), and letting go fired; a pad's RT bounced the power up and down. The power circles ran
from the weapon's muzzle to the crosshair's centre (`muzzle:Lerp(aimPoint, …)`), so the last one sat on the
crosshair, and since the muzzle is off the snail's centre the row was bent away from the line the mouse made.

**Why it changed.** The owner: make the shooting the same as in Worms Armageddon, hold to charge; the power bar
mustn't overlap the crosshair and must be straight with the mouse aim; the crosshair in the team's colour, or the
snail's own outside a team. Research (worms2d.info through the Wayback Machine, a native-size screenshot and a
gameplay video measured frame by frame) gave W:A's numbers: the charge is linear, about 1.3 s to full, and fires by
itself at full; the crosshair sits about 6 worm heights out (about 20 % of the screen's height), in the team's
colour; the power is a cone of about 14 discs growing from the weapon, dark red to pale yellow.

**Now.** Holding the mouse button, RT or FIRE (touch) charges for `CHARGE_SECONDS` (1.3), letting go fires, and a
full charge fires by itself; guns and melee weapons fire on the press. The crosshair is drawn from gui shapes (a ring
and an X, outlined, spinning), since the studio's picture is painted blue and can't take another colour, and it
sits 11 studs out. The 14 circles go straight along the aim from the muzzle's distance, and the last one's edge is
laid out each frame to stop `POWER_GAP` short of the crosshair at any zoom. Checked in a Studio match: a 0.9 s hold
fired on release, a held press fired by itself 1.34 s in, a right click mid-charge fired nothing, and the crosshair
took the snail's `Color`. Rule: Snails → "Shooting is Worms Armageddon's: point, hold to charge, let go".

**Then (2026-11-11).** The owner: the charge "feels choppy", then "it behaves weirdly, flickers; zoomed in it's very
small balls with a big distance, zoomed out it's cramped". The circles had popped in whole, one every 0.09 s; each
was its own on-top BillboardGui at the same depth, so overlapping ones swapped draw order frame to frame; the cone
started at the held weapon's muzzle, which moves a little every frame; and the crosshair's distance stayed in world
studs while the sizes followed the zoom. Now the aim is drawn on the HUD's `U_Aim` layer in pixels (ZIndex fixes the
order), from a fixed start, in units that scale with the screen and not the zoom, and each circle grows in from
nothing. Checked in Studio at the closest zoom (45 studs), the default and zoomed out: the cone and crosshair keep one
size and spacing; over 5 s of a turn the crosshair stayed shown every frame with no jumps.

## The crate opening, CS2's way (2026-11-11)

**Before.** Buying a crate opened the `CrateOpen` window over the GACHA screen: the crate shook for 1.2 s, then the
results appeared as the GUI kit's reward tiles, all at once. Every crate looked the same (one placeholder crate
picture), a premium crate felt like a coin crate, and nothing marked a rare drop.

**Why it changed.** The owner asked for an opening like CS:GO's: its layout in the game's own gui style, satisfying,
with sounds and effects, several reels for packs, crates with their own theme and real icons, a premium crate that
feels premium through small changes, big moments for rare drops and a drop of its own for each of the rarest items,
and a hybrid soundscape (refined clicks for the ticks, the Great Strategy instruments for the melodies). Research in
CS2's own UI code gave the numbers: a 38-card strip, `cubic-bezier(0.075, 0.82, 0.165, 1)` over 6 s, the line landing
10 % to 90 % across the winning card, a magnified centre window, legendaries never used as filler, and a gold ★ card
followed by a reel of the case's rare items. The owner approved a playable HTML draft (`art/crates/preview`) and then
said "Build it".

**Now.** The opening plays on the `Crates` gui itself: `Reveal` runs it, `Reel` builds and rolls the reels, `Showcase`
dresses the crate in its row's look, `Effects` draws every particle with `I.UIEmitter`, and `Drops` plays the black
hole, variety grenade, skeleton and low gravity potion drops. The pictures (`art/crates`) and 21 sounds
(`art/sfx/make_crates.py`) were uploaded to The Snail Studio group. Checked in a Studio playtest with the result forced:
x1, x3 and x10 layouts, the premium look, each legendary drop, the golden reel, Skip, Quick open and Open again
(through the server). Two things found there: a click placed by screen position has to be scaled from the capture
(1920 × 997) to the playtest's viewport (1586 × 824), since an unscaled one pressed CONTINUE and looked like the
opening closing itself; and the letterbox bars covered the crate's title and SKIP, so both draw over them now. Rule: Guis → "Crates open on the
GACHA screen, CS2's way".

## The gui maker's polish and the studio's trails (2026-11-11)

**Before.** The Currency bar and the emote shop were the GUI kit's theme controls; the lobby's locked slot, lobby
cards, SOLO VS BOTS and CUSTOM, the HUD's FIRE, power and stamina bars and jump, and the party card were the
2026-11-09 ports. Shots flew with no trail, and a jetpack showed none.

**Why it changed.** A gui maker polished six screens in Studio (`Workspace.Changes1_Gui`: Currency, Emotes, Loadout,
MatchBoard, MatchHud, Party) and the studio sent four trails (`Workspace.Trails_New`); the owner asked for both to be
plugged in and working. Their copies were made from the 2026-11-09 export, so laid over ours they would have dropped
everything added since (the aim cone, the turn callout, the tension band, pad hints, name badges), and every
component attribute in them was back at TagList+'s defaults (blank `Currency_Name`, no pad keys, the touch controls
shown on desktop, device scales 0).

**Now.** Their visual changes were ported into the gui tables node for node (a Studio serializer turns their
instances into `Primitive` nodes, spliced over the subtrees they changed), with our attributes, tags and later
additions kept; Currency and the emote shop became 1:1 ports. Things learned on the way:

- **Diff a designer's copy against the export it started from** (the commit they took it from), never against
  today's: only that tells their changes from ours.
- **Their bar picture fills its whole width,** so MatchHud's `BAR_FILL` went from 0.744 to 1.
- **`I.PlayerBadges.Show` needs a `UITextSizeConstraint` on the name:** their name label had lost it.
- **A panel that takes another's place hides it** (Lobby's `PANEL_WIDGETS`): the emote panel stands where Loadout is.
- **A Trail between attachments that line up with the motion draws nothing,** even with `FaceCamera`: the trail
  prefabs' attachments sit on X, and a shot flying along X collapsed them to a line. Their attachments are turned to
  Z (toward the camera), as `Trail_Snail`'s are, and shot trails ride a carrier part that follows the shot without
  turning.

Rules: Snails → "Effects are the studio's particle prefabs" (the trails); Guis → "The studio's screens are 1:1
`Primitive` ports" (Currency, EmoteShop).

## Emote bubbles and bot faces (2026-11-11)

**Before.** A played emote showed only its name ("Wave!") in plain text over the snail, or beside the party card in
the lobby, and nothing moved: the emotes have no animations yet. Every emote's icon was the placeholder crate, and
every bot's avatar was the same smiley.

**Why it changed.** The owner asked for icons for the emotes ("for wave a hand waving in the color of the snail"),
shown over the player in a message bubble while the snail plays the emote, for everyone, beside the player's name in
the lobby, with placeholder animations until the real ones arrive; and for the bots, headshots of snails with
personalities ("snail in glasses, snail military").

**Now.** The emote icons are drawn in the game's icon style (`art/emotes`); the first Flex icon, a bent pink arm,
read as something else, and became a dumbbell in the snail's pink grip. The bubble is ChatBubbles' own (an
`S_Icon` in its bubble and a public `ShowIcon` / `BuildIconBubble`), so it stacks with chat over the snail. SnailRig
gained `Emote`: an `Animation` named after the emote plays when it exists, else a stand-in moves the body bone and the
hands after the animations each frame, taking last frame's offsets off first so a bone no animation moves never
builds them up. The bots' headshots are voxel busts of the game's snail rendered in Blender (`art/bots`): eight
personalities were drawn, then the owner chose one default snail for every bot for now ("we gonna do it later in a
way where we have custom rare bots"). Rule: Guis → "An emote shows its icon in a speech bubble and plays on the snail".

## The crates in 3D (2026-11-11)

**Before.** The opening started with the crate's drawn picture coming to the middle of the GACHA screen, rattling and
bursting, and a legendary went from the gold card straight to the golden reel.

**Why it changed.** The owner liked the opening's style and asked for 3D crates in its place: models in a
ViewportFrame in the style of the game's models (the snail as the reference), TAP TO OPEN at the bottom, hatches opening
first and then the crate, a smooth hand-over to the reels; three crates for x3 and ten for x10, opened by one tap; and
for a legendary, another crate, the same one with effects, tapped open again. They approved a three.js draft of the
models and the motion (`art/crates/preview/crate3d.js`) with "Yes, build it".

**Now.** `Stage3D` clones the row's model into the gui's `U_Stage` viewport and animates it in code: each piece turns
about its hinge every frame (`HINGES`), the light is a Neon ball (a ViewportFrame has no glow or lights of its own), and
the 2D effects are placed at points projected from the viewport's camera. `Result` was split out of `Reveal`, which
had passed 1000 lines. Two lessons from getting the models in:

- **A baked texture came out black but for the glow:** a Blender image made in code (`bpy.data.images.new`) makes its
  pixels again when it is rendered, so the stud pattern was lost. It is saved as a PNG and loaded back before baking,
  and the bake keeps what is already in the target (`use_clear` off) so each piece adds its part.
- **A model's pivot sat 14 studs under its floor:** an imported MeshPart keeps the pivot the FBX gave it
  (`PivotOffset`), and with a `PrimaryPart` set that wins over the Model's `WorldPivot`. Each part's `PivotOffset` is set
  so the pivot is the middle of the floor. FBXs also come in at 100 times their size (metres read as centimetres) and
  turned to Roblox's axes (Blender x, y, z → −x, z, y).

The models' textures load the first time they are seen, so the first opening showed grey crates: `Stage3D.Start`
preloads the `Crates` folder. Checked in a Studio playtest: x1, x3 and x10, the tutorial crate on the real buy path,
the golden crate before a legendary (with the golden reel, and with a single legendary's rising card), and Quick open.

The owner then asked for the same model on the shop's pedestal, and found three things off: the reveal card's picture sat high with empty space under it (the card was laid out for a name under the picture, and the big card shows none), long names ran past the reel cards' slanted edges (the name box was wider than the card at its foot), and the black hole didn't look like the draft. That last one was a layer order: the result layer, with its tint, draws over the reels' layer, so the drop's near-black tint hid the reels it was swallowing. The drop no longer tints (the backdrop is dark already), and it shrinks the whole reels' layer into the hole with a UIScale, since a rotated layer would stop the reels from clipping their strips.

Then: "the 10 crates opening is heavy on performance". Measured in a playtest, ten crates added about 25 ms a frame in
every step, even while they only bobbed, waiting for the tap. Each crate is only about 4,500 triangles, and a test in
the playtest found the cause: moving any part placed straight in a ViewportFrame (even one) redraws every mesh in it,
about 27 ms for ten crates; moving only the camera costs almost nothing, and the same ten crates moving inside a
WorldModel in the viewport cost under 1 ms. The crates (and the pedestal's) now sit in a WorldModel; on top of that a
ten-pack shares one set of effects and drops the balls of light. Lighter models were not needed. Rule: Guis → "Models
that move in a ViewportFrame sit in a WorldModel inside it".
Rule: Guis → "Crates open on the GACHA screen, CS2's way".

## The confirmation dialog, kept simple (2026-11-11)

The owner asked for the "You sure?" dialog (System's blue-bannered card) to fit the game's new screens. The first try
was built only from the screens' own pictures: the Loadout slot's slanted dark panel as the card, the EMOTES title plate
over its top edge, the red kick button as a close on its corner, and the crate shop's slanted buttons. The owner: "its
ugly. dont make it too complicated". The slot's picture is drawn for a card a tenth of the size, so stretched into a
dialog its grey outline and rounded corners grew several times thicker than anywhere else, and the plate and the corner
button made the card busy. The remake is one rounded dark panel drawn with Roblox's own fill, `UICorner` and two
`UIStroke`s in the screens' colours (scaled with the screen by `Utils_UIStroke`), the title and the question in white
Londrina, and only the buttons from the design pictures, near the size they were drawn at, tinted green and red. DECLINE
closes it, so the X went too (B presses DECLINE on a pad).
Rule: Guis → "Dialogs in the new look stay simple".

## Skins on Classic's skeleton (2026-11-11)

The owner put nine skin snails in `Workspace.NewSnails` ("rename them based on our skins... RIG them, use the same
animations as we use for the default snail") and asked for their snails in the Skin crate's cards. They came static:
separate MeshParts (body, shell, hats and the like) with the artist's SurfaceAppearances, no bones, no hands. Their
bodies are Classic's body mesh at full size (Classic is the same rig scaled 0.45), so each was rigged onto a copy of
Classic's skeleton in Blender and uploaded as a skinned FBX. Four things learned:

- **Classic's rest pose isn't how it looks:** its shell floats above its back and its hands stick out to the sides;
  every animation moves the shell bone 5.3 studs (at full size) onto the back and the hands in front. The artist
  modelled the shells where Idle puts Classic's, so each shell is moved back by Idle's offset before it is bound, and
  anything showing a snail without animating it holds it in Idle's first frame (`I.SnailRig.Pose`). The Skins
  window's previews were too small to show it (each snail a speck at the top of its tile); they now fill the tile.
- **Roblox's FBX import turns every bone 180° about its own length:** the first upload's bones stood in the right
  places but their axes were flipped, which would play every animation mirrored. The bones are built turned back by
  that much, and come in matching Classic's to a millionth.
- **Studio's OBJ export (`PluginManager():ExportSelection`) fails in a playtest's datamodel** ("Failed to export
  obj") and works in Edit mode; it opens its save dialog in the background, which can be filled through its window
  handle without touching the mouse. EditableMesh, the other way to read a mesh, needs the experience's Mesh APIs
  setting, which is the owner's.
- **An unweighted vertex flies to the world's origin:** bone heat left the Devil's wings and parts of the Robot
  unweighted, and in game each stretched a spike from the snail across the screen. Such vertices now take the nearest
  weighted vertex's weights.
- **No hands came with the skins:** Classic's hands are added to each body mesh, their UVs on one spot of the skin's
  texture with the body's colour where the hands rest, so the Robot's are steel and the Devil's red.

Rule: Snails → "Every skin is a snail on Classic's skeleton".

## The skins' snails on the crate cards (2026-11-11)

The owner asked for the skins' snails in ViewportFrames on the GACHA screen's cards, "same in the rolling animation".
The odds list, the result cards and the big card took them easily: one posed snail per card, framed as the Skins
window frames it. The rolling reels didn't, and measuring them in Studio taught three things about ViewportFrames:

- **A model costs Roblox 3 to 4 ms the first time its viewport draws it,** whatever its textures, pose or bones, and
  again whenever the viewport is hidden and shown or the model is taken out and put back. In a WorldModel adding one
  costs about 7 ms, in one hitch (70 at once: a 200 ms frame); moving it afterwards is nearly free.
- **A viewport whose content changed is drawn only once it holds still where it's seen.** One that moves with a reel
  strip, or is hidden at the time, stays blank (or keeps its old picture) until it changes again in sight. So the
  reels' first tries, viewports riding the strips, left whole columns blank; a still viewport whose camera follows
  the strip does draw every frame, cheaply, but swapping snails in and out as cards pass cost 11 to 25 ms a frame on
  the ten-pack. Even the result cards that fly into place came up empty until their cameras were nudged.
- **So the reels show pictures.** The owner picked them over a hitch every opening: each snail rendered once in Studio
  in the cards' pose, framing and light (a booth captured on black and on white gives the transparency), uploaded
  with the owner's OK, and shown in the reel cards' `S_Icon`. The ten-pack rolls about 1 ms dearer than with the old
  icons. Still cards stay live, and the Crates module draws a card's snail again once the card settles in sight.

Rule: Guis → "Rolling reels show the snails as pictures".

## Pictures blank on live servers (2026-11-11)

The owner found icons and the wind blank in the live game while Studio showed them. Two causes turned up:

- **15 pictures were still local:** the emote icons, the bot avatar and the player badges pointed at
  `rbxasset://textures/wb_*`, a copy in this PC's Studio. They were uploaded to The Snail Studio group that day.
- **Most uploaded pictures belong to a person, not the group.** The code uses 529 image ids. 345 were uploaded by
  Studio's Assistant under the signed-in user (viridianscape: the 2026-11-07 icons, the wind), 145 by the studio's
  designer (Otron_TV), 25 by the group, and a few by other creators. The game is the group's. Roblox lets a creator's
  own games use their pictures whatever their privacy, but another owner's game needs the picture Open Use or a
  permission grant for its universe. So a person's picture can load in their Studio and still be blank live. The fix
  is a Use grant for the game's universe on those pictures, or re-uploading them under the group.

Rule: Guis → "Pictures drawn for the game stay local until the owner approves them" (they go up under the group).

## Light snails thrown on the game's own physics (2026-11-12)

**Before.** Snails walked, jumped and were thrown on Roblox physics at full gravity: a blow was an impulse on the
ball, so throws were short and heavy, and the bots predicted them with a shortcut.

**Why it changed.** The owner asked for snails that feel like Worms: lighter, thrown further and higher by a blow
depending on its angle, falling slower, and not on Roblox physics.

**Now.** Snails feel 0.55 of gravity (Snails' `GRAVITY_SCALE`): the ball's `Lift` is always on, and `JUMP_SPEED`
went from 44 to 33 so a jump stays about 5 studs. A blow throws the snail on a Combat Ballistics body (the shots'
own simulation): the server anchors the ball and steps the flight on its clock; every client builds the same flight
from the snail's `FlightFrom`, `FlightVelocity` and `FlightStart` attributes and moves the ball itself before each
frame. Things learned on the way:

- **An anchored part keeps the speed it's given,** so the flight writes its speed on the ball, and everything that
  reads `AssemblyLinearVelocity` (the match's settling, the shell hide, trails, sounds, the camera's chase) works
  unchanged.
- **Network ownership can't be set on an anchored part:** a second pellet hitting a snail already in flight, or a
  knockout mid-flight, threw "Network Ownership API cannot be called on Anchored parts". Every owner call checks
  `Anchored` first.
- **A helper that reads another module's settings reads them in its functions,** not at require time: Snails
  starts before `I.Settings["Combat"]` is there, and the whole module failed to load.
- **Studio's command bar (and the MCP's Luau) gets its own copy of the framework,** so `I.*` calls from it act on a
  module nobody started. Test through the place's own instances instead: attributes, and remotes found by their
  `Network_Name` attribute.

Measured in a Studio match with bots: throws flew 0.2 to 0.9 s, landed back on physics with the ball unanchored, and
each screen moved the ball about 0.2 studs a frame with no still frames.

Rule: Snails → "Snails are light, and a thrown snail flies the game's own physics".

## Emotes face the camera; potions show (2026-11-12)

**Now.** While it emotes a snail eases round to face the camera (SnailRig turns the root bone and the weapon's
`Handle` Motor6D about the ball's upright axis, last of everything each frame, and takes the turn off first the next
frame, so it never builds up). A hit ends the emote and a hidden snail refuses one. A snail under a potion streams
its `Aura_*` prefab, and the player's own turn tints the screen's edges (`PotionVignette`). Checked in a Studio match
by setting the potion attributes on the player's snail: both auras streamed and the vignette showed pink.

Rules: Snails → "An emote turns the snail to face the camera, and a hit wins", "Potions show on the snail…".

## The studio's New_Guis ported 1:1 (2026-11-12)

**Before.** The match setup, the waiting room, the knocked-out dialog, the results, the invite box, the custom lobby,
the shop and the teleport card were the GUI kit's theme controls, and the HUD's power and stamina bars were cut with
one gradient on the bar alone.

**Why it changed.** The studio made designs for all of them (`Workspace.New_Guis` in the dev place: `PlaySolo`,
`MatchWaiting`, `KnockedOut`, `MatchOver`, `InvitePlayers`, `CustomLobby`, `CustomLobbyPlayers`, `Shop`, `Loading`)
and a `PowerSlider` for the bars, to be ported 1:1 as the earlier screens were.

**Now.** Each design is a `Primitive` port with the old Ids, prefabs and button tags kept, so the code only changed
where an element changed kind (a kit button's `Button` child became the ImageButton itself) or a look moved into
`Look_*` attributes. Things learned on the way:

- **Serialize the design in Studio, assemble on disk.** A Luau serializer run through the Studio MCP turns a design
  into node text (Props, Ids, tags and attributes from a per-path spec), and the result comes back in chunks; a small
  script fills a gui shell with it. Hand-copying nine designs would have drifted.
- **Code synced ahead of the export breaks the playtest.** The code looked for ImageButtons and an `S_BarMask` the
  old exports didn't have (`Turn:443` every frame). Sync and export together, then playtest.
- **The PowerSlider is the old bar's pictures**, laid out differently: the bar is `ScaleType` `Fit` and its texture
  mask has to be cut by the same `UIGradient` edge, or the texture stays full while the bar empties. The picture spans
  the whole box, so `BAR_FILL` stays 1.
- **The setup and waiting room keep hanging beside Party,** not where the designs drew them (the middle), so the
  lobby's stage stays clear (the rule from 2026-11-09).
- **A design's text is a sample.** The solo win reward now shows a number, `SOLO_WIN_COINS` in MatchBoard's Settings,
  which repeats MatchRewards' server-only `SOLO_COINS` by hand: change both together.
- **Studio's capture is scaled.** `user_mouse_input` takes viewport pixels below the top bar inset, while
  `screen_capture` returns a smaller picture of the whole viewport: convert before clicking. Pictures that were never
  loaded in the session draw blank for a second or two.

Checked in a Studio playtest: the client log had no errors; Solo vs bots opened the Play Solo panel and Hard set the
win reward to 60. The panel's ✕ didn't respond to a click sent without first moving the pointer over it; with the pointer over it first,
as a mouse does, it closes the panel.

Rule: Gui → "The studio's screens are 1:1 `Primitive` ports".

## The lobby's Play Solo at the bottom centre, the board sliding away (2026-11-12)

The owner asked for the Play Solo panel at the bottom centre (the same height), for the lobby rows and the SOLO VS
BOTS and CUSTOM buttons to slide off the screen instead of vanishing, for the lobby's emote cloud to sit lower, and
for the EMOTES row to lose its fold button.

- **The setup no longer hangs beside Party.** That rule (2026-11-09) kept the stage clear; the owner now prefers the
  panel centred, over the lower half of the front pod. The waiting room stays beside Party.
- **The board slides as a whole screen.** Board's `_slidePlay` tweens every child of `U_Play` down past the bottom
  edge and hides `U_Play` once they're gone, so nothing off-screen takes a press or the pad's selection. It reads the
  parts' rest positions at start, so the gui's layout stays the only place they're set.
- **A skinned snail's bounding box is its rest pose.** The Shell part sits high above the back until the animations
  put it in place, so `GetBoundingBox` put the lobby's bubbles 0.86 studs too high. The Body (eyestalks included) is
  the snail's real top in every skin.
- **Emotes have no equipped state.** Every owned emote is in the lobby row and on the wheel, so the row has nothing to
  fold.
- **Studio's capture leaves out BillboardGuis** (snail tags, chat bubbles), so their placement is checked by numbers.

Checked in a Studio playtest: the panel opened at the bottom centre while the board slid away, ✕ brought it back,
the row showed Wave then +, the bubble's offset was 3.49 studs (was 4.35), and the client log had no errors.

Rule: Lobby → "The lobby is a party stage, as Fortnite's".

## A calmer wind and a seamless power cone (2026-11-12)

The owner found the wind streaks too much, and the power cone's circles dark and patchy as they changed colour.

- **The wind is fewer and fainter, not smaller.** `WIND_RATE` 40 → 18 and a new `WIND_OPACITY` (0.6) on the prefab's
  transparency; size and speed stay, so a strong wind still reads as strong.
- **A map's bounds can come after its markers.** Mood refreshed the area when the markers arrived and when the mood
  changed; with the bounds late, neither saw them, and the match played with no wind or ambient particles. It now
  waits for them.
- **Overlapping circles blend when their colours run along the cone.** Shading each circle top to bottom (tried first,
  with a thin outline) made a string of beads; giving each circle's gradient the cone's colours from its back edge to
  its front, turned with the aim, makes them one shape. No outlines: the owner wanted it seamless.

Checked in a Studio match on Picnic Plains: the cone at 59 % power was one smooth yellow-to-orange shape, the streaks
showed from the first turn, and the client log had no errors.

Rules: Match → the aim's look; Atmosphere's README → Settings.

## Hurt ends the turn; the jetpack's shell; heal cooldowns (2026-11-12)

The owner found the snail's shell swinging while it flew the jetpack, the Bazooka pose lost on landing, a "-0" on the
turn timer, and asked for Worms' rule that getting hurt ends your turn, and for the Bandage and Medkit to wait
between uses.

- **The walk ran in the air.** Motion picked `Walk` from the ball's sideways speed alone, so a jetpack flight (8 studs
  a second sideways) played SnailRig's code walk: the shell swaying 8° and the body bobbing, with the Handle and
  weapon riding it. The walk now needs the ball on the ground, with SnailControl's spherecast.
- **A snail in its shell kept aiming its weapon.** `_aimHands` posed the hands and Handle over the `Hide` and `Show`
  animations, so the weapon floated beside the shell. It's hidden in the shell now, like during an emote.
- **Hurt ends the turn on the server, from `Health`.** Fall damage goes through `Health.Damage` and fires no
  `Combat_Hit`, so Match's turn loop watches the active snail's `Health` attribute until the shot is away. After a
  hurt landing the turn passes, so the weapon is put away with it: the "not held" pose after a damaging fall is now the
  turn ending.
- **`math.max(math.ceil(x), 0)` gives −0** for x between −1 and 0 (`math.ceil` keeps the sign), which `tostring`
  writes "-0". Clamp first: `math.ceil(math.max(x, 0))`.
- **Heals wait after use, not before.** The weapons' rule (strong items start on their cooldown) would have kept a
  Bandage away for the first 3 turns, so Uses.Reset and the bots' Sim put a starting cooldown on weapons only. The
  Medkit went from 1 use to 2, since a cooldown on a one-use item never counts.

Checked in a Studio match on Picnic Plains: Idle and the Bazooka pose through a jetpack flight with no Walk, a
13-damage landing passing the turn to a bot, no "-0" over 40 s of turns ending, and no client errors. The heal
cooldowns weren't tried in play (the test player had no utilities).

Rules: Snails → getting hurt ends your turn, strong weapons start on their cooldown; SnailRig's and Snails' READMEs.

## A calmer camera, a settling turn and pond damage (2026-11-12)

The owner found the camera too rapid and sometimes losing a grenade, and asked for their own camera moves to win for
5 s, a 3 s wait after hits, turns that wait for snails in the air (with a 5 s stall and a 20 s limit), touch drag and
pinch, and pond damage. Worms has none (its water drowns), so ponds took Worms Armageddon's poison: 5 a turn, every
turn, never below 1.

- **The camera chased ghosts.** A knocked-out snail's ball is anchored with its last speed still on it (32 studs a
  second), so `_getFlyingSnail` took it for a snail a blow threw, and right after every blast the camera raced across
  the map to the ghost. Only snails with `Alive` are chased now. Most of the "too rapid" was this.
- **Exponential easing whips over long moves.** Its speed is the distance times the rate, so crossing a map started at
  hundreds of studs a second. A critically damped spring with a top speed (Unity's SmoothDamp) eases in and out.
  Capping shots too made the camera lose a shot launched far away; shots and hand moves go uncapped.
- **The spring's lag matters for shots.** Tracking a moving point, it trails by speed times its smooth time, so the
  smooth time is 1 / the old rate (not 2 /), and the dead zone keeps a bouncing grenade from shaking the view.
- **Edge pan in tests.** Studio's test mouse sits at (-1, -1), which the edge pan read as the left edge: with the new
  hand-held view, it parked the camera at the map's left side for the whole match. A mouse outside the window, or a
  view that can't go further, no longer counts.
- **Touch from raw inputs.** One finger had to pan unless it points the aim, which Roblox's `TouchPan` (two fingers)
  couldn't do, so the camera tracks its own touches that began off the guis.
- **Settle on calm, not on a clock.** Calm needs no movement, no health change and every snail landed; a stall
  timer (nothing moving or hurting for 5 s) covers a snail stuck off the ground, and 20 s caps it.

Checked in Studio bot matches on Picnic Plains: every shot stayed on screen (at most 45 % from the middle), the
camera's fastest move fell from about 1,200 to 136 studs a second, a drag held the view 5 s into the next turn before
it glided over, and the Settle phase lasted 3.0 to 3.4 s after shots. Touch and pond damage weren't tried in play.

Rules: Snails → the match camera, the next turn waits, ponds hurt; MatchCamera's and Match's READMEs.

## Free look on your own turn, and a sea past the map's sides (2026-11-12)

The owner couldn't move the view down to the map's bottom while zoomed in, and saw the water end at the map's sides
when panning or zooming out.

- **The leash shrank with the zoom.** On the player's own turn the pan was held within 70 % of half the view's height
  of their snail (2026-11-10), so the further in they zoomed, the less they could look around: about 8 studs at the
  closest zoom. The bounds' own clamp was already right for any zoom. The pan now reaches anywhere in the arena and
  still eases back while the snail moves, as in Worms. Their snail can leave the screen now.
- **A separate part beside the sea shows a seam.** The first try drew a 50-stud part past each side, which met the
  sea's last block face to face: both are see-through, so their two end faces showed through the front as a darker
  strip. The sea's own blocks at the sides are stretched instead (no face where the map ends), and only where land
  stands at a side (Picnic Plains' bedrock from Y 4) does a block outside top the sea up to its level, against land.

Checked in a Studio bot match on Picnic Plains: zoomed fully in on the player's turn, a right-drag took the view to
the bounds' bottom (Y −8), 20 studs under the snail; zoomed out at the right edge, the sea ran on past the screen
with no seam. The sea's blocks reach X −191 to 191 (the bounds are ±141), up to Y 6.5 at the sides.

Rules: Snails → the match camera; Arena → liquids; MatchCamera's and Arena's READMEs.

## Volcano Isle, a lava sea that glows (2026-11-12)

The owner asked for a new map and suggested a volcano with a more complicated layout and small passages. Volcano Isle
was made in MapLab like the Desert: a volcano between two rocky islets, a shelf floating over each islet, a rock
between, a crater lake at the top, and a lava tube through the volcano's base with a magma chamber on it.

- **In a side-on map, a passage with two mouths cuts the land above it off.** The tube runs from one porch to the
  other, so the whole cone over it is a floating ledge (`Ledge_3`), like Rockslide Ridge's ceiling: a blast that
  splits it keeps its biggest piece up and drops the rest. Caves with one mouth (at the volcano's feet and in the
  islets' faces) cut nothing off. The flat picture made the tube read as "a mountain on a slit"; the owner judged it
  in Studio and kept it.
- **The sea is lava, and it glows.** The owner: "change bottom water to lava, so a lava rises not water, make lava
  part neon so it slightly glows, 255, 81, 58". Lava was only ever drawn in the stud look, so the marker's new
  `Arena_LiquidNeon` draws a map's liquid in Neon instead, without touching other maps (Desert's lava keeps its
  studs). The sea is the liquid that knocks snails out, so on this map falling in the lava kills, and the crater and
  chamber pools are ponds: they only hurt a snail whose head is under (Match's `UNDERWATER_DAMAGE`), until rising
  lava joins them in sudden death.

Checked in a Studio bot match on Volcano Isle: it loads with 7 terrain groups and 13 neon lava blocks reaching
X 1009 to 1391 (50 studs past each side), the Volcano preset and the stand-in music play, and nothing new shows in
the Output. In play, Neon with the preset's bloom renders the lava much lighter than its colour (about 255, 180, 150
on screen).

Rules: Arena → liquids; Snails → each place's mood; Arena's, Atmosphere's and MatchBoard's READMEs.

## Every map plays at X 0: streaming hid Volcano Isle until the drop (2026-11-12)

The owner: "the volcano is not rendering until bots appear, like until everyone places and the game starts". The
place streams (`StreamingEnabled`, `StreamingTargetRadius` 1024), so a client gets only the parts within 1024 studs
of its focus. Until a player's snail spawns and becomes their `ReplicationFocus` (Snails' `Bodies`), the focus is
their avatar, parked at the spawn (0, 0.5, 0). The templates stand in MapLab's 400-stud slots and each match played
where its template stood: Picnic Plains at 0 and Rockslide Ridge at 800 (x 655 to 945) were in reach, Volcano Isle
at 1200 (x 1059 to 1341) wasn't, so its players saw an empty arena through the whole drop.

The owner suggested moving every map to one point, or turning streaming off or up. The Loader now moves each template
so its Bounds stand at X 0 when it caches it: every match plays by the spawn, however many slots MapLab adds, and the
templates keep their slots in Studio so they never overlap there. Streaming stays as it is: off, every client would load the
whole place at join, and a bigger radius only moves the limit to the next slot.

Checked in a Studio Match playtest on Volcano Isle: through the Drop phase the client had all 479 terrain parts, at
X −134 to 138; the match played on. The custom lobby's map pictures were stretched into their buttons, now cropped
(the owner: "not stretched but like fit, so they can be slightly cut off").

Rules: Arena → maps are authored; Arena's README.

### The camera leads every turn, blows punch, and the shell stays (2026-11-12)

The owner asked for the camera to go to the snail whose turn it is at every turn's start, "even if player is moving
it by himself", for high shots to sit near the top of the screen with the map in view, for a zoom that moves with the
action, for more punch in the shakes, for less bounce on thrown snails, for bots not to walk hidden in their shell,
and for the shell never to break.

- **The forced glide.** `Match_TurnStarted` drops the blast's hold, the hand's view and the pan, and until the view
  reaches the active snail (or `TRAVEL_MAX` runs out) MatchCamera's `_addPan` ignores every hand move. Checked with the
  right mouse button held and dragged across four turn starts: the view still reached each snail, or the edge clamp.
- **High shots and the breathing zoom.** A shot keeps the view's height from its take-off until it climbs past
  `SHOT_TOP` of the half screen, and the zoom is the player's times a "breath": up to fit a high shot, a little on the
  glide to the next snail, in for a moment at a blast. The player's zoom itself never changes.
- **Shakes.** One CameraShake layer read as a wobble; a short rough jolt under a longer rumble reads as a hit. Hits
  and gunshots shake too, by the same distance rule as blasts. MatchCamera never rolls the view, so a test measures a
  shake by the camera's roll.
- **The shell while walking.** Motion hid a snail moving faster than `HIDE_SPEED` without `CanMove`, and only a
  near-stop brought it out. Bots never get `CanMove`, so their own jumps hid them, and they kept walking hidden. The
  turn (`Active`) now tells a snail's own moves from a throw, walking brings the active snail out, and SnailRig's walk
  stops `Hide` and `Show` so they never play together. The shell break below 50 health is gone with its settings and
  sound.
- **A knocked-out player lost the map.** Found while testing: the ghost's ball ended up about 1,000,000 studs below
  the arena and stayed the player's `ReplicationFocus`, so streaming dropped the whole map on their screen. The camera
  froze (no `Bounds`) and Arena's client `Carver` errored on every blast. A knockout now sets the focus back to the
  parked avatar, by every map at X 0. What moves the ghost's ball down there wasn't found.

Rules: MatchCamera, Blasts are felt, The snail is the studio's rig, The shell always stays, Every map plays at X 0.

### The bots train on the PC (2026-11-13)

The owner asked whether the bots could train on the PC instead of in Studio, now that shots and thrown snails run on
the game's own simulation. Not everything does (walking and the jetpack are still Roblox physics, craters are CSG and
every collision is a Roblox cast), but the gym never walks: its stand-in snails teleport. So the repo's `bot-gym/` runs
the gym's own code in Lune and stands in only for the engine: the instance tree, Workspace's casts and overlaps,
collision groups, `SubtractAsync` on boxes, and `task` on a virtual clock. The owner's pick: build it, compare it with
Studio, and train on the PC if they agree.

- **Comparing them.** Studio's MCP Luau runs in its own VM, with a fresh `I` that never started, so a probe has to live
  in the game: the Bots module's `Parity.lua`, which Studio and the PC run unchanged. Its report is lines of text, and
  both sides hash blocks of lines, so only the blocks that differ cross between Studio and the PC (a StringValue holds
  fewer than 200,000 characters, so Studio's report is in parts).
- **Vector3 is 32-bit.** With 64-bit numbers a third of the shots differed by a rounding step (45 damage against 44).
  Rounding every Vector3 and CFrame position through a 32-bit float made 2,544 of 2,592 shots identical.
- **A cast down a seam.** A ray exactly on the line where two parts meet touches both: Roblox counts a touched edge as
  a hit, and when two parts' tops are level, which one it reports is its own pick. The probe reads its columns a
  quarter stud off the grid.
- **The exam favoured the champion.** It always sat in the first seat, which moves first, and the shipped genome
  played against itself scored 0.83 against 0.58 a seat in Studio. Who sits first now swaps every two matches.
- **What's left.** Bouncing shots drift by hundredths of a stud and a few chaotic ones go elsewhere; Rockslide Ridge,
  built off the stud grid, carves a little differently. Over whole matches the two agree within noise (hits 44.5 %
  in Studio, 47 % on the PC), so the champion still sits its last exam in Studio.

Rules: Bots think with a trained brain; `bot-gym/README.md`.

### A self-hit sent the match to the lobby (2026-11-13)

The owner played a custom deathmatch alone with three Easy bots, and on their turn everyone went back to the lobby;
Output said `Bodies:333: attempt to index nil with 'AssemblyLinearVelocity'`, and once `Control:92` on `Position`.
It happened when they fired the Bazooka straight down at full power: their own snail vanished.

- **The cause.** A blast throws a snail on the game's own flight, with its ball anchored. The shot ends the turn while
  it's still flying, and `ClearTurnEffects` sets the ball's `Lift` back from `root.AssemblyMass`. An anchored
  assembly's mass is infinite, so the Lift became an infinite force; when the flight landed and the ball was
  unanchored, the force made its position NaN, and Roblox deleted the part and its model. The next look at the snail
  errored, `Play` failed, and Match sent everyone to the lobby.
- **Wrong leads first:** the sea, the Leave button, the AFK teleport, NaN in the flight itself, debris and props, the
  plane constraint. A probe that logged every step of the flight into a StringValue ring found the infinite Lift.
- **The fix.** Every force or impulse on a snail's ball reads the ball's own mass, `root:GetMass()`, which is the
  same anchored or not (Snails' `Health`, its admin command, SnailControl's `Effects` and `Control`, Combat's
  `Blast`). A piercing shot that stops in the terrain no longer pushes the snails it passed with a zero speed's
  `.Unit` (NaN) either (Combat's `Rocket`).

Rules: Snails are light, and a thrown snail flies the game's own physics.

### Smarter bots: digging, cover, walls and air shots (2026-11-13)

The owner asked for bots that shoot toward or dig to enemies they can't reach instead of firing above themselves,
walk to cover, never jump into walls or fly into ceilings, mind ponds, hurt teammates only when it wins, and a
Nightmare that shoots while flying.

- **Pressure, not a miss.** A shot that hurts nobody used to be worth nothing, so the brain's fallback was any shot,
  often straight up. Now it's worth the genome's `Pressure` by how near an enemy it lands, and with no arc reaching
  anyone the bot aims at the terrain along the way to each target, from `DIG_MIN` out.
- **Winning pays for a friend's hurt.** Knocking out the last enemy adds `WIN_VALUE`, so team damage is weighed
  against the match, not alone.
- **Moving reads the walls.** Spots are reached step by step with casts up, along and down (`Move.CanStep`), flights
  pick a height clear of ceilings, and a wall is given up after `WALL_JUMPS` tries.
- **Nightmare flies and shoots** (`AirShots`), and hunts players a little over bots (`Hunt`).
- **Training on the PC** (10 generations of 16, 64 matches each, 48-match exams, seed 11): Medium and Hard found
  better genomes, Easy tied and Nightmare's champion lost, so those two keep their shipped weights.

Rules: Bots think with a trained brain.

## The spider bomb's snail ladder, icon buttons, a HUD under the top bar, new bot loadouts (2026-11-13)

The owner: the spider bomb "sometimes gets bugged mid-air"; "change header leave game and mute music to be an custom
svg icon"; on phones "the roblox core gui, the topbar one is covering the players in match on the left side and
turn/wind"; and bots should carry the spider bomb, the black hole grenade (Nightmare only) and the potions ("optional
and only one per bot").

- **A crawler must not see snails.** The crawl found walls and ground with the projectiles' cast, which hits snails.
  A snail in the way (4.1 studs tall, over a 2.6-stud ball) was a wall to climb, but not ground to stand on, so the
  spider climbed it, dropped, climbed again and hovered beside it until its time ran out. The crawl now casts like
  snails stand (the `Snail` group with `RespectCanCollide`), which also matches the PC gym, whose stand-in snails
  live elsewhere. It climbs only a wall in front of its own body and stops under a ceiling. The step lives in
  `Projectiles.GetCrawlStep` so the bots foresee the crawl with the same code.
- **Icons beat text in the top bar.** The text buttons grew wide enough to reach the turn timer. One music button
  (notes, crossed out while muted) now serves the lobby and matches; the match adds Leave game after it.
- **Inset the HUD, don't move its blocks.** `CoreUISafeInsets` on Mobile lays the whole HUD out under Roblox's top bar
  (58 px in Studio), so no block needs a per-device position and nothing overlaps what used to sit below it.
- **Potions as part of a spot.** A bot's potion isn't a separate decision: a spot only the potion reaches carries it,
  costs the genome's `Ammo`, and the bot drinks it before walking there. No new genome key until training says one
  is worth it.

Rules: Panels hang from a screen edge (the HUD under the top bar), The top bar's buttons are icons, Bots think with a
trained brain (their loadouts).

## Bots that play tricks, taunt, and drop apart (2026-11-13)

The owner: train every difficulty, "focus on the nightmare the most, to be super op": jetpack shots from the air
where landing costs nothing or the trade is worth it, grenade bounces and other projectile tricks, more use of the
wind; bots spawning on top of each other ("3 bots are in the same place"); and taunting with emotes.

- **The spawn bug was a weight, not a cast.** Each bot scored the drop's spots with its genome, and Hard's trained
  `Crowd` came out negative: Hard bots liked company, and the drop offered only one spot per snail. A hard rule
  (`START_GAP`) now sits under the genome's taste, and the drop offers six spots per snail so there's room to choose.
  Trained weights decide trade-offs; they must never be the only thing between the game and an obvious bug.
- **A trick is a spot or an aim point, scored by the same simulation.** High air spots are only spots with a `Fall`;
  bank shots are only more aim points, flown in full and judged by where they burst. No genome key was added: the
  genome already weighs self-damage, knockouts and damage, so training decides when the trade pays.
- **Bounces into the sea needed the throw to bounce.** Predict landed thrown snails where they first touched, so a
  blow that bounces an enemy off its ledge looked harmless. It now follows Snails' flight rules (bounce over Combat's
  `REST_SPEED`, then a short slide off edges).
- **The gym's wind must hold for a round, as the game's does.** It rolled a new wind every turn, so bots never
  trained on a round's settled wind.
- **Taunts reuse the player's emote path.** `Cosmetics_EmotePlayed` carries a bot's snail id where a player's carries
  a UserId, and the client's emote and bubble code takes either: no second remote, no second drawing path.
- **Windows Python writes CRLF** in text mode; edit repo files with `newline=''` or the whole file shows as changed.

Rules: Bots think with a trained brain (tricks, taunts, spawns).

## Small holes stay safe, map lava burns (2026-11-13)

The owner: a hole in the ground kills on Desert and Lakeside ("it shouldn't"), so "if the hole is big enough it insta
kills you, but if there's a smaller hole the water is good, also small puddles shouldn't insta kill you"; and Volcano
Isle's lava on the map (not the rising sea) should burn: move for 2 s, the turn ends, then 5–10 health a second for a
few seconds.

- **Two rules made any low water deadly.** `GetHazard` knocked out in any liquid at or below the sea level plus
  `SEA_SLACK`, and the sea mark seeded from every cell of the sea's kind under that level, so lake water that flowed
  into a low crater was marked as the sea and flooded the whole lake with it. The sea now seeds only from the grid's
  sides and floor, and knocks out only where it's open.
- **"Open" is the surface's width, not the row's.** Measuring free cells across the snail's own row failed under the
  islands: maps stand on a sea layer under their bedrock, and a hole cut through it opened into a row as wide as the
  map. The width is measured at the surface over the snail (up the liquid in its column), so a hole is as wide as
  the hole. A snail below the land's floor is in the sea under the islands and goes out there.
- **Test liquid rules in the PC gym, not by hand.** A scratch Lune script booted the gym's engine, carved stacks of
  craters on every map and printed each column's liquid and hazards: it showed the lake-floor case before any Studio
  run. Teleporting a player's snail in a Studio test doesn't stick (its client owns it on its turn); a bot's does.
- **One burn per dip.** Re-burning every time the burn ended trapped a snail in a pool: every tick ended its next turn
  before it could walk out.
- **A pcall must look the method up inside.** `pcall(service.UnionAsync, service, …)` errors before the pcall when
  the method is missing, as in the gym's GeometryService; the merged cutter crashed every gym carve until the lookup
  moved into a function.

Rules: Only the open sea knocks snails out; Lava on the map burns.

## One lava colour (2026-11-14)

The owner: "change the global lava color to `#b3592f`". Arena's `LIQUID_COLORS` Lava had been 255, 96, 20, but the
two lava maps never showed it: Volcano Isle's markers (and Rockslide Ridge's redo in MapLab) gave their lava 255, 81,
58 through `Arena_LiquidColor`. So the global colour changed and the maps' own lava colour went (the exported Volcano
Isle's markers, both maps' `map.json`, MapLab's preview default), and Desert's lava, which had none, follows too.

- **Neon isn't its colour on screen.** In Neon (`Arena_LiquidNeon`) the lab drew #b3592f as about #ffa016, much
  brighter; the stud look shows the colour itself.

Rules: Liquids are a stop-motion stud simulation.

## The studio's maps, depth, and a grid of maps (2026-11-14)

The studio sent two new maps and two fixes as Studio builds (`Workspace.New`): a plain, an underground rock map, a
rebuilt Rockslide Ridge with hanging rocks and walled sides, and Lakeside Showdown with pits and small floating
islands. The owner also asked for depth on every map ("so the maps gets depth but stays relatively the same"), lava on
Rockslide Ridge, and then for the maps to stand "better like 4 per row" in Studio, with a plan for the old versions
so nothing overlaps and nothing stacks high.

- **Import hand-built maps through their front view.** MapLab rasterizes what the camera sees (the frontmost part
  over each stud, `Kit.raster`) and keeps hand-built props part for part (`Kit.dumpProps`); then the map's own
  `generate.py` fixes what the game needs: columns left hanging a few studs over the floor go down to it, slots too
  narrow for a snail close, crumbs under `FLOAT_MIN_AREA` go.
- **Depth without moving the plane.** Each map's front juts toward the camera in slabs of a few levels (MapLab's
  `jut`, at most 1.5 studs so the cutter still goes through); the backs stay at the map's depth, so nothing that plays
  moves.
- **A redo can change how a map kills.** Rockslide Ridge's lava between its pillars is 5 to 14 studs across, under
  `SEA_MIN_WIDTH` (16), so falling in burns instead of knocking out until sudden death raises it.
- **One line of templates runs into everything.** At 400 studs a slot, eight maps reached X 2800, into the lab, and
  the lab's old versions stood 140 studs apart above their map, 53 of them up to Y 7500. Now templates, the lab and
  the old versions each stand in a block four wide that grows back (−Z), and the Loader puts every template on the
  plane at X 0, Z 0 instead of warning about one off it.
- **Checks near a tolerance depend on where they run.** Two planks of the studio's picnic table were 0.02 studs apart,
  exactly MapLab's z-fighting tolerance: the check passed in the lab at X 5400 and failed at the origin, where the
  export builds. Fix the prop, not the check.

Rules: Maps are made in MapLab; Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`.
