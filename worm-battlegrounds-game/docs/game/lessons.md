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
every skin falls back to the Classic snail, emotes show their name.

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
