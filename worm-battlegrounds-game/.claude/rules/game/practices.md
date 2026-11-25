# Game practices

How this game uses ume and ume-gui, and its design decisions, for both folders. They win over the framework's rules
(`family/family.md` → Rules). Their stories: the code folder's `docs/game/lessons.md` (`family/docs.md`).

## Arena

- **Terrain is authored parts,** built like a hand-made map: long parts for the shapes, smaller ones for details, in
  SmoothPlastic with MaterialService's `2022 Stud` variant. Never Roblox Terrain, and never a grid of cells or
  one-stud blocks.
- **Blasts carve voxel craters with CSG:** `GeometryService:SubtractAsync` with a stepped circle running along Z
  (through the plane): one box per row of the 1-stud squares whose centers are in the blast (`CARVE_CELL`), lined up
  with the maps' grid, so craters step like voxels, never smooth curves. The terrain stays long parts; only the cut
  is stepped. `SplitApart` keeps every loose piece its own part. The server cuts every part a blast reaches at once
  and swaps them for their pieces in one frame.
- **Each client cuts the holes itself** (the owner's pick, 2026-11-09, as the server's holes looked replicated): the
  server announces a carve before cutting it (Arena's `Arena_Carve`), and every client cuts the same stepped hole on
  local pieces at once, hiding the real parts until the server's pieces replace them (each piece carries its carve's
  number, so a later hole is cut into an earlier carve's pieces as they arrive). The server's terrain stays the only
  one that collides and that queries see. A client's cut is only a guess: one that fails (a piece the server just cut,
  its shape not on that screen yet) is tried once more, then left to the server's pieces with no warning, and only the
  server warns when a cut fails (Arena's `Cutter.Subtract`, `CUT_RETRY_SECONDS`, 2026-11-17).
- **Cut-loose ground falls by the game's own gravity, locked to the plane** (the owner's pick, 2026-11-09, so players
  can build bridges): never Roblox physics. A loose group drops straight down without turning to where it first
  touches the terrain (lowest group first), or out of the arena, and stays there anchored; the server moves it, and
  each client hides the real parts and draws copies falling on its own frames (`Arena_Fall`), so no part has two
  writers (2026-11-17).
- **Ground is bedrock on the floor:** each island's waterline blocks carry `Arena_Indestructible` (a name from before
  blasts could cut it). Blasts cut bedrock like any terrain, so an island can be blasted down to the water; a bedrock
  piece holds up what touches it while its bottom still reaches the map's floor (the bottom of its lowest bedrock),
  and a piece cut loose falls. **Floating ledges float, but what's cut off them falls** (the studio's wiki: "blocks
  left floating fall down"): their parts carry `Arena_Floats`, each ledge is numbered at load (`Arena_Ledge`), and when
  a blast cuts one apart only its biggest piece keeps floating. Never mark a ledge block as bedrock to hold it up: it
  isn't on the floor, so it holds nothing.
- **Props break under blasts:** trees, bushes and rocks in a map's Decor are `Arena_Prop` Models built from parts
  (never collidable for snails). A blast cuts its hole through them with the same stepped cutter as the terrain, and
  the pieces no longer joined to the prop's base fly off; a prop whose ground is gone (under its trunk) falls. What
  falls fades out. **Props break on every screen at once** (the owner, 2026-11-17: "when the terrain explodes its
  sloppy a bit"): each client cuts the props a blast reaches itself, with the server's prop cutter and split (Arena's
  `PropCut`), hides the cut parts and throws what the cut frees at once; the server cuts every reached prop part at
  once beside the terrain's carve, keeps only the standing pieces (the prop takes the carve's number, `Arena_Carve`),
  and keeps what fell or flew off, unmoved, until every screen has faded it (`PROP_REMOVE_MARGIN`). **Prop pieces fly,
  fall and fade on the game's own motion, drawn by each client** (Arena's `Thrown`), never Roblox physics and nothing
  replicated per frame; a prop whose ground is gone drops the distance the server gives (`Arena_PropFall`), with the
  ground under it when that falls too. **Cutters are reused:** a blast moves its side's spare cutter boxes into place
  (Arena's Cutter `Build` / `Release`), never makes new ones, and the merged cutter is never parented (GeometryService
  cuts anywhere, and a parented union replicates its mesh). **Props stand behind the snails** (the testers and the owner, 2026-11-13: snails hid inside trees
  and rocks): at load each moves back until its front is half a snail's length behind the plane, its pivot still on
  the ground, and one too deep for that is flattened along Z, which the camera along −Z barely sees (Arena's
  `PROP_BEHIND_GAP`). **A prop a snail stands inside turns see-through** (the owner, 2026-11-15: "the prop gets
  transparent when snail is inside of it"): each client fades it while any snail is within its box on the plane
  (Arena's `PropSeeThrough`, `PROP_SEE_THROUGH`), never on the server.
- **Backdrops only where they make sense** (the owner, 2026-11-15: "only for caves, water etc."): a cave's back wall,
  or a block behind a pond so its water looks held (MapLab's `backdrop.only`); no distant hills or mesas behind open
  land. Mirage Mesa, Lakeside Showdown and Training Meadow lost theirs that day.
- **Maps are made in MapLab** (the game home's map kit, `assets/_tools/map-kit/`): the land drawn on the 1-stud grid
  and built into parts, props part-built, checked, then exported into the arena templates after the owner approves.
  A map the studio or the owner builds in Studio is imported into MapLab (Rolling Plains, Echo Caverns and the redone
  Rockslide Ridge, 2026-11-14): its front view rasterized onto the grid (`Kit.raster`), its hand-built props kept part
  for part (`Kit.dumpProps`). A finished MapLab build made outside this place goes in as it was built (the owner's
  pick, 2026-11-15: Desert, Volcano Isle, Echo Caverns, Picnic Plains and Rolling Plains from `Workspace.New`), with
  small fixes only: its stud parts SmoothPlastic, its props never collidable and standing on their ground. **Every map's land has depth** (the owner, 2026-11-14: "so the maps gets depth but stays
  relatively the same"): its front is cut into rows of slabs that jut toward the camera by a few levels, at most 1.5
  studs (MapLab's `jut`), less on grassy and sandy maps, more on rocky ones; the play plane doesn't move.
- **Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`** (Terrain, Decor, Markers), standing in
  MapLab's grid in Studio so none overlaps another: four to a row, 500 studs apart, each row 300 studs behind the last
  (X = column × 500, Z = −row × 300, by slot; the owner, 2026-11-14: "better like 4 per row", never one line on and
  on, nothing stacked high), and cached by the Arena module at start. **Every map plays at X 0 on the plane (Z = 0)**,
  by the spawn: the Loader moves each template's Bounds there when it caches it (the owner, 2026-11-12: Volcano Isle, at X 1200, didn't show
  until the snails dropped, since streaming sends a player only what's within `StreamingTargetRadius` (1024) of
  their avatar, parked at the spawn, until their snail is their `ReplicationFocus`). A knockout hands the focus back
  to the parked avatar (Snails' `Health.Kill`): the ghost's ball ended up far below the arena, and with it as the focus
  a player watching on lost the whole map and the camera its bounds (2026-11-12). The drop picker, aims and shots read
  the plane as Z = 0, which the Loader's move gives every template, the grid's back rows too. Nothing starts
  in the bounds' top 20 studs (Arena's `START_TOP_GAP`), so a map's roof is never a spawn, and the liquid is drawn as
  deep as the map's bedrock, measured at load, never the bounds' depth: a map needs neither set by hand. Weapon models are authored in
  `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/` and cached by Arsenal (its README → In the place).
- **A map's atmosphere effects are its `Vfx` folder** (2026-11-25, the studio's `BiomeVfx`: lava embers and smoke on
  Volcano Isle and Rockslide Ridge, clouds, sunbeams and falling leaves on Picnic Plains): invisible anchored parts
  that never collide, touch or block queries, holding the emitters, beside Terrain, Decor and Markers, so the loader
  clones and moves them with the map. Never in Terrain (blasts cut it) or Decor (props break).
- **Liquids are a stop-motion stud simulation:** water and lava live in a grid of half-stud cells stepped at 8 fps
  and drawn as merged rectangles in `2022 Small Stud`, so they hop like a brick film. They are the only thing in the
  arena on a grid, and the cells stay fine (never one-stud or bigger blocks). The sea is drawn 50 studs past the
  map's sides, up to its level (Arena's `SEA_EDGE_WIDTH`, the owner, 2026-11-12: "not seen as cut out"), so the
  camera never shows where it ends; only drawn, since the grid stops at the sides and out there is out of bounds.
  A map may draw a liquid in Neon instead of the stud look, so it glows (its marker's `Arena_LiquidNeon`): Volcano
  Isle's lava, sea and pools (the owner, 2026-11-12: "make lava part neon so it slightly glows"). **Lava is one
  colour everywhere,** Arena's `LIQUID_COLORS` 179, 89, 47 (#b3592f, the owner, 2026-11-14): no map gives its lava a
  colour of its own. Neon draws it much brighter on screen (about #ffa016 in Studio).
- **Only the open sea knocks snails out** (the owner's pick, 2026-11-08): the liquid whose marker starts at the
  bounds' bottom, raised by sudden death (Arena's `GetHazard`, `SEA_SLACK`), and since 2026-11-10 any liquid of its
  kind joined to it, so a pond the rising sea reaches becomes the sea (Arena's `Liquid.IsSea`, `SEA_MARK_STEPS`, seeded
  from the grid's sides and floor only). Since 2026-11-13 (the owner: "if the hole is big enough it insta kills you,
  but if there's a smaller hole the water is good"), only where it's open: the surface over the snail is at least
  `SEA_MIN_WIDTH` (16) studs across, or the snail is under the land's floor (a hole cut through the land drops it into
  the sea below). A pond on its own (Mirage Mesa's oasis, Lakeside's lake), a puddle, or a crater up to a Grenade's that
  the sea seeps into is safe to fall in; a Dynamite or Black hole crater it floods is the sea. **Past the map's sides
  everything falls into the sea** (the owner, 2026-11-15: "do not disappear but fell into the water normally"): a
  snail or shot beside the play area flies on and goes out only once it falls to the sea's level, where the sea is
  drawn (Arena's `GetHazard`); on a map with no sea, at the play area's bottom.
- **Lava on the map burns** (the owner, 2026-11-13: "you can move for 2s and then your turn ends and you'll loose
  like 5-10hp every second for few seconds"): lava that doesn't knock a snail out (Volcano Isle's chamber and crater
  pools, the lava sea in a small hole, Rockslide Ridge's lava between its pillars, 5 to 14 studs across: the owner's
  pick, 2026-11-14, "Keep the burn") sets it `Burning` with a flame aura; 2 s later it loses 8 health (its turn goes on: hurt no
  longer ends a turn), then 8 more each second, 24 in all (Snails' `BURN_*`, `Hazards`). One burn per dip: staying in
  the pool or dipping again while it burns adds nothing, so a snail left in lava walks out on its next turn. Bots
  avoid standing or landing in lava and count the burn on snails a shot throws in (Bots' `Move`, `Predict`). **Lava turns the water it touches into obsidian** (2026-11-10), on
  a map holding both: those cells leave the liquid and become terrain parts that blasts cut like any ground (Arena's
  `Obsidian`). It's the one terrain built in code, merged from the liquid's half-stud cells, an exception to "Terrain
  is authored parts". **Shots fly on through any liquid, ponds too, slowed** (the owner's pick, 2026-11-10: "projectiles move
through water but slower"): water and lava never set a shot off; it bursts on what it touches under them, or by its
fuse (Combat's `SINK_*`). Only the spider bomb's crawl ends in liquid. **The open sea takes a shot at once** (the
owner, 2026-11-15: "make the turn end when the projectiles hit the outer water that instakills you"): wherever Arena's
`GetHazard` would knock a snail out, a shot is gone without a blast as it splashes in (Combat's `Projectiles.IsGone`,
mirrored in the bots' `Predict`); ponds still only slow it.

## Snails

- **A snail's state lives in attributes on its model** (`Health`, `Alive`, `Ghost`, `CanMove`, `Stamina`, `Active`…),
  written by the server and read by every client, so the snail modules need no remotes. Overrides `ume/values.md` →
  where a per-player value lives: snail state belongs to the snail, which bots have too, not to a player.
- **The active snail is moved by its player's client** through network ownership; the server only checks it (its path
  through the terrain, its speed, how high it climbs past a jump with its jetpack fuel, and its stamina) and takes
  the snail back. Anything the server does to a snail (knockback, a knockout) happens while the server owns it.
- **Every snail parachutes in** (the studio's wiki): a player's placed spot, or for bots and players who don't place,
  up to the Match module's `DROP_HEIGHT` over a spot from `I.Arena.GetLandSpots` (on top of the ground on any storey,
  never over liquid), clear of the terrain above it. **No snail keeps its parachute past the landing** (the owner,
  2026-11-15: a snail that came down by Volcano Isle's chamber pool kept it open and couldn't move): a parachute
  closes when the snail lands or touches water or lava (SnailControl's `Effects`), and the landing closes any still
  open before the first turn (Match's `Phases._land`, which counts a snail dropped onto ground as down).
- **The snail is the studio's rig, animated on each client** (2026-11-09): the `Classic` skin has bones, hands and a
  `Handle`, and the `SnailRig` library plays its animations (idle, walk, hiding in its shell while it's thrown) from
  how its ball moves (Snails' `Motion`), never from the server. Only the skin's RootPart is welded to the ball. Its
  animations are published to The Snail Studio's group (2026-11-10; the ids are on the place's Animation instances
  under `Assets/Snails/Animations`), so live servers play them once the place with those ids is published. A hit
  snail ducks into its shell at once (Snails' `Motion` hears `Combat_Hit`), the hide sped up by SnailRig's
  `HIDE_PLAY_SPEED`. **A walking snail is never in its shell** (the owner, 2026-11-12, after bots walked hidden):
  the active snail's own jumps and falls don't hide it (Motion reads `Active`, since bots never get `CanMove`), it
  comes out the moment it walks, and the walk stops the shell's `Hide` and `Show` animations.
- **A snail is dressed piece by piece, never as a whole skin** (the owner, 2026-11-14: "divide the actual skins we
  have to accessories"): four slots, a hat, a neck piece, a body and a shell, worn in any mix (Cosmetics'
  `Outfit`), no snail colours. Each artist skin is a set of pieces with names of their own around the set's theme
  (Wild West: the Ten-Gallon, the Dusty Bandana, the Saddlebag shell), each piece the set's rarity, and the Skin crate
  rolls pieces, each set's chance shared by its pieces. A player who owned a skin got its set's pieces once, with the
  skin's copies, and wears what they wore (Cosmetics' `PiecesGiven`): an exception to `ume/classes.md` → Profile data
  ("no function that repairs or reshapes saved data"), since the owner asked that no one lose a skin. Every screen
  builds its snail with `I.G_Cosmetics.BuildSnail`, from the set snails' parts (art/skins → Pieces). **The Style
  screen is a showroom** (the owner, 2026-11-14: "drag to rotate the snail all around… the camera angle changes, zooms
  in a bit"): the player's name under the snail, never a set count; a drag spins it all the way round, and the camera
  eases to the slot opened or picked (round to the shell, down onto the hat). **New pieces are called NEW** until the
  player leaves the deck that shows them (the crate cards' red NEW! tag, on the lobby's STYLE button, the decks and
  the tiles; Cosmetics' `SeenPieces`).
- **Every skin is a snail on Classic's skeleton** (2026-11-11, the artist's nine): the same bone names and frames,
  scaled 0.45, a skinned `Body` (Classic's hands in it; the accessories too until the pieces are uploaded), `Shell`,
  `Hat` and `Neck`, Classic's `Handle`, so Classic's
  animations and SnailRig play on it unchanged (`art/skins`: the rigging, and why the shell is moved back by the
  Idle's offset). The rig's rest pose has the shell floating above the back and the hands held out, so a skin shown
  unanimated (a ViewportFrame) is held in its idle frame with `I.SnailRig.Pose`, never shown at rest.
- **The active snail holds its weapon in its hands, in the weapon's pose** (the row's `HoldPose`: the studio's Gun,
  MiniGun, Bazooka and ShotGun snails; other items in the Gun pose), welded to the rig's `Handle` at the model's
  `Grip`, and always on the camera's side: a snail facing left swaps its hands over. The hands and weapon pitch to the
  aim (up to 90° either way), and a snail standing still turns to face its aim (its player's screen; the server for
  bots), so the weapon never points back through it. A gun plays its pose's shot when it fires. It's drawn by each
  client from the snail's `HeldItem` (Combat's `Held` handler), never welded on the server.
- **Shiny and Golden copies look special everywhere; Golden is a look only** (the owner, 2026-11-17): 10 copies make
  an item Shiny (×1.05 damage, `ShinyAmount`, `SHINY_BOOST`), 100 make it Golden, which deals and boosts as Shiny. The
  match card and participant carry `ShinyItems` and `GoldenItems` (and `ItemLooks`, below); the server writes the held copy's look on the snail
  (`HeldVariant`, after `HeldItem`), a shot's in its `Combat_Shot` options (`Variant`) and a blast's in
  `Combat_Explosion`, and every client draws it (Combat's `Variants`, `VARIANT_LOOKS`) over the normal effects, which
  always play in full: a pearly sheen, outline and twinkles on a Shiny weapon, polished gold, a brighter sheen and
  rising dust on a Golden one, a prism or gold line along their shots and star or gold sparks and rings in their blasts,
  with `Variant_Shiny` and `Variant_Golden`. **Levels open the starter weapons' looks** (the owner, 2026-11-24: crates
  never drop them): Shiny Grenade 10, Shiny Shotgun 20, Shiny Bazooka 30, Golden Grenade 60, Golden Shotgun 75, Golden
  Bazooka 90 (Progression's `WEAPON_REWARDS`), worked out from the level, never saved or given as copies; each one plays
  its unlock over the lobby's replay, as good as a crate opening, and says what it does ("+5% damage": the owner, "so
  players dont feel scammed"); the lobby stage's snails hold their Bazooka in its look too. Gilding is one function,
  `I.G_Arsenal.Gild`, for matches, the unlock card and the stage. The looks come from the studio's Vfx prefabs painted in code, materials
  (ForceField, Metal), Highlights and the model's own parts, never new pictures. Cards show it in the gui: an `S_Foil`
  or `S_Gold` layer moved by `Utils_UIGradientMove` / `Utils_Motion` tags, which code only shows or hides.
  **Players pick the look each weapon wears** (the owner's pick of three designs, 2026-11-25: "a tab that opens up on
  the left side… the gui needs to be as easy to use as possible"): pressing the Bazooka's card or a slot's card opens
  the weapon picker and the look tab beside the card (the Bazooka too: "it opens the loadout as any other weapon"), left of the loadout column, three copies of the slot card (Normal, Shiny, Golden) showing
  the weapon in each look, the worn one in the selected outline and tagged EQUIPPED (a gold rim hides an outline), a
  look not had yet locked with how it opens. While the picker is open the loadout column and the tab draw over its dim
  (the owner: "should not be greyed out") and EMOTES hides. Pictures,
  not words, carry the choice, and the tab shows only for a weapon with a look past Normal, so a new player never
  meets it. Any look up to the best owned (Loadout's `LOOKS`, `Loadout_SetLook`), saved per weapon until a better look
  opens, which then shows instead; every place that draws a weapon follows the pick (`I.G_Loadout.GetWornLook`: the
  loadout, the picker, the lobby stage, and the match through the card's `ItemLooks`). **Only the look changes:** the
  damage follows the best look owned (`ShinyItems`), so a Golden weapon worn as Normal still deals +5% (proposed with
  the designs; the owner picked without changing it).
- **Aiming is drag, lock, FIRE** (the owner's pick, 2026-11-24, after players' reviews called hold-to-charge
  confusing, mobile players most; it replaces 2026-11-10's Worms Armageddon hold-to-charge, researched in the session's
  "Mobile artillery aiming controls" report). **The crosshair goes under the pointer, Ring: point** (the owner's
  pick, 2026-11-25, from the aim drafts page, replacing the day before's trackpad drag): a press on the arena (the
  mouse button, a finger) puts it there and a drag moves it with the pointer: its way from the snail is the angle and
  its distance the power, up to the power ring round the snail (full power). Letting go locks the aim; **FIRE**, over the weapon bar on every device (or F,
  Enter, the pad's RT), shoots it. Dragged back to no power, or Esc / the pad's B, clears it. **Each snail keeps its
  aim into its next turn**; its first starts at half power, 45° toward its nearest enemy. The right stick moves the
  crosshair the same way, finer for a gentle lean. Guns and swings use the angle only; a weapon placed at the feet
  fires on FIRE with no aim. **A homing missile locks its target, then aims its launch** (the owner, 2026-11-25: its
  launch had fired at the bazooka's last hidden aim): the first press places the target (a finger drags it until it
  lifts), then the launch is dragged like an arced weapon's, and NEW TARGET (a copy of the lobby's
  LOCAL button, left of FIRE) lets go of the target. **No path shows outside the tutorial** (the owner, 2026-11-25:
  "the dots are making the game too easy", removing the short preview dots of 2026-11-24); **the 24 Nov preview is
  back, exactly** (the owner, the same evening: "very hard to predict the trajectory… the first aim dots… it was
  perfect", after dots past the crosshair were tried): 9 dots from the snail over a fifth of a full-power flight, no
  wind, stopped by the first thing in the way, shrinking, fading and in the power's colour (MatchHud's `PREVIEW_*`).
  It's the tested look: don't halve, thin or recolour it without the owner. The tutorial shows the same dots;
  only the admin aimbot shows the whole path. The aim draws on the MatchHud gui's aim layer (`U_Aim`, under the rest of the HUD) in screen pixels,
  never as billboards in the world (overlapping billboards at one depth swap their draw order and flicker), and
  it stays light (the owner, 2026-11-24: "too much bloated… more subtle"): no power bar, a small crosshair (a
  ring with an X, spinning, in the power's colour since 2026-11-25) whose distance from the snail is the power, a faint ring
  for full power, and over the crosshair the power and angle ("62% · 41°"). **The power is a wedge, ShellShock
  Live's way** (the owner, 2026-11-25: "without the bar it feels empty", then a ShellShock screenshot, "make it similar
  to that"): a soft triangle from the snail, its point at the snail's end, widening to the crosshair's ring, in the
  power's colour (yellow at little, red at full: "make it change color based on the power"), on the player's own aim
  and on every other screen (MatchHud's `S_PowerWedge`, `POWER_WEDGE_SPREAD`), drawn from two frames each cut along
  its diagonal by a gradient's hard step, never a picture. **A homing missile's target has a mark of its own,** bigger than the crosshair: a red ring
  and lit dot with lock-on brackets that turn and close in as it's placed (MatchHud's `S_TargetMark`, `TARGET_*`), so
  it never reads as an aim. Every length is in units, a stud at MatchCamera's starting distance,
  so the aim zooms with the map, but within limits (the owner's pick, 2026-11-24: MatchHud's `AIM_ZOOM_SCALE`), the power ring
  with it. The screen
  that draws an aim turns the held weapon with it at once. The turn running out never fires.
- **Everyone sees the active snail aim:** its angle marker and power show on every screen through its turn, players'
  and bots' alike, from the `AimAngle`, `AimPower` and `AimTime` attributes Combat's `ShowAim` writes. Bots turn their
  marker, then fill their power, before they fire.
- **Blasts are felt, not only seen:** Combat's client `Effects` shakes the camera with ume's CameraShake, on top of
  MatchCamera (which updates at the `Camera` render priority, one step before the shaker), and vibrates phones and
  pads through the Haptic module's `Combat_*` presets (`src/global_data/Haptic/Preset.lua`). How hard comes from the
  blast's size and its distance from the middle of the view, and nothing is felt outside a match. **Every blow
  punches** (the owner, 2026-11-12: "add screen shake on explosions and stuff like that to add more punch"): a shake
  is a sharp jolt then a rumble (`SHAKE_KICK`, `SHAKE_MAGNITUDE`), a hit on a snail adds its own by the damage, more
  on a knockout (`HIT_SHAKE_DAMAGE`, `KNOCKOUT_SHAKE`), and a gunshot kicks the view (`GUN_SHAKE`). The player's own
  shot ticks and a hit on their own snail thumps. The chunks of ground a blast throws come from a pool on each client
  and fly on the game's own motion (Combat's `DEBRIS_*`, 2026-11-17): they bounce off the terrain only, never on snails
  or shots, and fade after `DEBRIS_LIFETIME`.
- **Big blows stop the world for a beat** (the owner's pick, 2026-11-10): a hit of Combat's `HITSTOP_DAMAGE` or more
  freezes the effects' particles and thrown chunks and holds the camera for a moment on every screen (`HITSTOP_*`,
  `I.MatchCamera.Freeze`), longer for a knockout, when the camera also punches in on the snail
  (`I.MatchCamera.PunchIn`). It's drawn by each client from `Combat_Hit`'s `knockout`; the simulation and the server
  never stop. Bigger hits pop bigger, warmer damage numbers (Snails' `POP_TIERS`).
- **The shell always stays on the snail** (the owner, 2026-11-12, removing the break below 50 health from
  2026-11-06): no screen hides a skin's `Shell` part while the snail is in play.
- **A knocked-out snail's ghost is drawn by each screen** (2026-11-10): the server only sets `Alive` false and
  `Ghost` true (before `Health` drops to 0, so a screen that hears the health change already sees a ghost) and anchors the ball; every client
  floats it up glowing and fades it out (Snails' `Ghost` handler), and Match waits `GHOST_TIME` so it's seen before
  the next turn.
- **Effects are the studio's particle prefabs, played by the Vfx library** (2026-11-09): each effect is a part named
  `PREFAB | <Name>` in `Workspace.Ume.ReplicatedStorage_Assets/Vfx` (from the studio's `Particles_1` and
  `Particles_2`), its emitters disabled, with `EmitCount`, `EmitDelay` and `EmitDuration` attributes saying how each
  fires. Code plays one by name (`I.Vfx.Play(name, cframe, parent, scale?)`), clones a trail (`I.Vfx.AddTrail`), and
  never builds particles of its own. Blasts pick theirs by size (Combat's `BLAST_VFX`); guns, the punch and the
  snails' spawn, landing, healing, splash and trail have theirs (Combat's and Snails' client `Effects`). Missiles, the
  Grenade, the spider bomb and the black hole, variety and cluster grenades (their mini bomblets and the variety's worms
  too) draw the studio's trails as they fly (Combat's `PROJECTILE_TRAILS`: the Grenade's and the spider bomb's
  `Trail_Fog` since 2026-11-16), and a launcher's shot blasts out of it (`LAUNCH_VFX`), and a jetpack its jet (Snails'
  `Trail_Jet`) over the studio's booster flames (`JET_EXHAUST_VFX`, `Jet_Booster`); a trail's attachments stand along Z,
  toward the camera, so it keeps its width. Every snail a blow hurts throws the studio's damage sparks (Combat's
  `HIT_VFX`, `Hit_Sparks`, bigger for a harder blow, 2026-11-16).
- **Each place has its own mood, subtle and in the game's colours** (the owner's pick, 2026-11-10: "subtle, high
  quality, minimalistic but visible… worms type of colors, but in a professional way"): the Atmosphere module sets
  the lobby's or the map's lighting preset (`Lobby`, `Plains`, `Desert`, `Cave`, `Volcano`, in `Lighting.Presets`), a few
  ambient particles that drift with the match's wind, effects on liquid surfaces and a cave's ceiling, and reactions
  to what happens (leaves from blasted trees, splashes, landing dust, steam), all on each client and from Vfx prefabs
  made from the studio's existing emitters. A new map gets a `PROFILES` row (Atmosphere's Settings), and a preset
  of its own when no existing one fits. The match camera looks along −Z from 110 studs, so a map's sun keeps a high
  `GeographicLatitude` (its light comes from the camera's side); the lobby's stage camera looks along +Z, so its
  latitude is negative. Saturation stays well under the old 1.0 (0.2 to 0.35), and an effect seen on bright ground
  blends normally (`LightEmission` 0): additive smoke vanishes on sand. **A map may have a sky of its own, painted as
  a calm background** (the owner, 2026-11-25: "they should be just a background, so players focus on the main
  level"): its row's `Sky` goes on as a lighting layer over the preset's, so maps sharing a preset keep their own
  skies, with the Atmosphere's density, haze and glare 0 and offset 1 on the same layer (Atmosphere's `MAP_SKY_ATMOSPHERE`): any
  density paints everything under the horizon in the Atmosphere's colour, and the level match camera then showed
  half a screen of fog (the owner: "the bottom half is too long"). Skies are drawn by `art/map_skies` for the match
  camera's fixed window (the `SkyboxFt` side, ±15° up and down and ±26° across, at its 30° field of view): tilted
  forward so their horizon sits under eye level, blue from just over the horizon, soft cartoon shapes, anything tall
  kept to the sides, never photos. Picnic Plains, Volcano Isle, Rockslide Ridge, Desert and Echo Caverns (Mountains) have one; Rolling Plains
  wears Picnic Plains' (2026-11-25). **A map's shapes stand behind it as parallax layers, its sky a gradient only**
  (the owner, 2026-11-25: "when we zoom in and out the clouds and skybox stay in the same place… creates a weird
  illusion"): a skybox never moves or grows, so mesas, hills and clouds are flat pictures standing far behind the
  play plane (its row's `Parallax`: a far range about 1100 studs back, clouds 700, near hills 350), which the
  camera's own perspective moves; each client builds them (Atmosphere's `Parallax`). They're **rendered in Blender in
  the maps' own brick look** (the owner, on flat painted ones: "looks like an excel drawing more than an artwork"):
  stepped brick strata, blocky props, voxel clouds, lit from the camera's side, hazed more the farther back they
  stand, and only the farthest layer slightly softened (the owner: "the blur is too much", 2026-11-25; clouds and
  near layers stay sharp). Water is one flat colour behind the layers, reaching up over far islands' feet so nothing
  floats. Desert, Rolling Plains and Echo
  Caverns have them.
- **The match camera shows every shot to its end** (the owner, 2026-11-10: "make sure all is shown, the camera
  works and is not confusing"): with the player's `CameraFollowsShot` on, it flies with a shot (led a little), glides
  to where a gun's bullets struck a snail or the map or a swing landed (a gun that hit nothing leaves it be: the
  owner, 2026-11-15), follows a snail a blow sent flying or that fell, and holds on what
  happened until the next turn starts, then glides (never snaps) to the next snail (MatchCamera's `TRAVEL_*`,
  `CHASE_*`, `BLAST_HOLD`). The player's pan is only what they moved; the arena's edges limit the view but never
  build up into the pan. **It moves calmly** (the owner, 2026-11-12: "too rapid… doesn't track the grenade"): every
  move eases in and out on a damped spring capped at `MAX_SPEED`, and a shot, or a snail a blow threw, moves the view
  only once it leaves the middle of the screen (`DEAD_ZONE`); only shots and hand moves go faster than the cap. **The
  player's hand wins** outside their own turn before the shot: a drag, a finger, the stick or the screen's edge leaves
  what the camera follows, and it stays where they put it while they hold the pan and until 5 s after their last move
  (`MANUAL_HOLD`), then glides back. **Every turn starts on its snail** (the owner, 2026-11-12: "always at the start of
  turn move the camera towards the one that is playing"): a new turn, the first too, ends the blast's hold and the
  hand's, and the camera glides to the snail whose turn it is, **forced** (the owner: "move the camera even if player
  is moving it by himself"): the hand moves nothing until the view gets there (at most `TRAVEL_MAX`). **High shots
  ride near the screen's top** and **the zoom breathes** (the owner, 2026-11-12: "so also the map is visible… zoom
  in/out to add more dynamic feeling"): a shot climbs to `SHOT_TOP` of the half screen before the view rises, from
  its take-off height, the view zooming out to fit it and the map under it (`SHOT_ZOOM_OUT`), a little on each glide
  to the next snail (`TRAVEL_ZOOM_*`), and in for a moment at a blast (`BLAST_KICK`). On their own turn before the shot the pan reaches anywhere in the arena at any zoom, and eases back to their
  snail while it moves (the owner, 2026-11-12: zoomed in, the view couldn't go down to the map's bottom; it had been
  kept within 70 % of half a screen of the snail). **On touch** one finger drags the view (on the player's own turn before the shot it points the aim instead) and
  two fingers drag and pinch-zoom, read from raw touches, not Roblox's `TouchPan` and `TouchPinch`.
- **Shots fly by the game's own simulation, not Roblox physics:** Combat's `Ballistics` (Scripts/Helpers) steps every
  flying shot the same on the server and every client, on the server's clock, with Worms' arcade rules (bounces that
  lose speed along the ground, resting and rolling off ledges, shots slowed through liquid). A shot starts on the
  terrain or snail it's aimed into, never inside it (Combat's `GetShotStart`, which bots' predictions use too). The server is
  the authority (launch, states every 0.1 s, end; it alone decides blasts), and each client simulates its own copy for
  smooth flight, rewinding to the server's state when it drifts. Never give a flying shot Roblox physics or move it by
  replicated parts. **What moves on the server's clock is drawn on `I.Match.GetDrawTime()`** (the owner, 2026-11-15:
  rockets stopped for a few frames mid-air live), never `GetServerTimeNow()` read each frame: a client's estimate of
  the server's clock is corrected now and then, and drawing on it froze shots, thrown snails and falling ground for a
  moment; the draw clock runs at the local clock's rate and eases toward the server's. **Whatever moves something the
  camera follows runs before the camera** (2026-11-15, a thrown snail and its tag stuttered): bound with
  `BindToRenderStep` under `Enum.RenderPriority.Camera` (Combat's `Shots` and `Flight`, Snails' `Flight` and `Gear`),
  never on `PreRender` or `RenderStepped`, which run after every bound step, the camera's included, so the camera aims
  at where it was a frame before.
- **Shots fly in slow motion** (the tester's notes, 2026-11-08): the simulation runs at Combat's
  `PROJECTILE_TIME_SCALE` (0.5, half speed) along the same paths, so eyes can follow a shot. A thrown bomb's `Fuse`
  counts its own slowed flight time, so it bursts where it did at full speed; a placed one's (Dynamite) stays in real
  seconds. Anything that steps a shot (bots' predictions too) counts flight in the shot's own time.
- **Strong weapons start on their cooldown** (2026-11-08): a weapon with a `Cooldown` waits that many of the player's
  own turns before its first use too (Combat's `Uses.Reset`, mirrored in the bots' `Sim`), so nobody opens a match
  with the strongest weapons. One Punch waits 5 (the owner, 2026-11-13: "only accessible after 5 turns"), usable from
  the player's 6th turn, and the black hole grenade too (the owner, 2026-11-15). Bots obey it like players: their
  brain only sees what `I.Combat.CanUse` allows, and the server refuses any other shot. Admin `give` and `refill` clear it, for testing. **Heals wait between uses** (the owner,
  2026-11-12): a utility's `Cooldown` starts at its first use, so it's ready on the first turn; the Bandage (40)
  waits 3 turns, once every 4 of the player's turns, and the Medkit (100) 5, once every 6, with 2 uses a match.
- **Server-moved shots glide on clients:** the spider bomb's crawl moves as a server part after landing; clients draw their models gliding after them (Combat's `CRAWL_GLIDE`), and the spider bomb walks
  up 1-stud steps rather than jumping them. Their throws fly on `Ballistics` like every other shot. Flying shots are
  drawn `PROJECTILE_DRAW_SCALE` (2) times their size, hits unchanged.
- **Every thrown shot flies like the rocket** (the testers, 2026-11-13: "same physic weight as rocket"): every Arc and
  Target weapon launches at the Bazooka's speeds (`MinSpeed` 20 to `MaxSpeed` 180, up from 150 for more power) and
  feels the wind (the spider bomb's throw and bomblets too, the owner, 2026-11-13; **wind blows only in a custom lobby or
  local play that turns it on**, the owner, 2026-11-24: their WIND OFF / ON, off by default, the metadata's `Wind`;
  everywhere else it stays 0 and the HUD hides its plate, Match's `WindOn`), which pushes `WIND_ACCEL` (3.5) studs/s² per point, and each point harder the stronger the wind
  (`WIND_ACCEL_GROWTH`, the owner, 2026-11-13: "on wind 6… the projectile will get swept by the wind in another
  direction"): a shot into the wind lands visibly short, and in strong wind a steep shot is blown back over the
  shooter's head (at 12, steeper than about 64°). **The wind runs from −20 to 20** (Match's `WIND_MAX`, the owner,
  2026-11-15: "10 becomes 20 and the strength is more spread out"): 20 pushes as 10 did before, so the two settings
  were halved and quartered. **Each wind blows for two rounds** (`WIND_ROUNDS`, the owner, 2026-11-15: "make the wind
  last for 2 turns for everyone"): Match rolls a new one on the first turn of every second round, never the one
  before, mostly −5 to 5 and strong wind rarely (`WIND_WEIGHTS`: about 65% of rolls within ±5, ±20 about 0.3%), and a
  change gusts across the screen (Atmosphere's `WIND_CHANGE_BURST`) and flashes the HUD's number.
- **Teammates are never hurt by each other** (the testers, 2026-11-13): Combat's `Blast.Hit` skips a snail on the
  shooter's team (not the shooter: your own blows always hurt you), and an open black hole doesn't pull them.
- **The black hole grenade is thrown, and opens on a second press** (the testers, 2026-11-13): it opens on the first
  thing it touches, or wherever it is when its owner presses again, holds still for its `HoleTime`, then bursts.
  **Snails stick to it, it never throws them** (the owner, 2026-11-13: "does not knock people out but sticks to
  them… they slowly move towards it if they're on ground, they like slide towards it"): open, it draws every snail in
  its `PullRadius` in slowly (Combat's `BLACK_HOLE_DRAG_SPEED`), sliding along the ground or drifting through the air,
  holds each one stuck at its middle (`I.Snails.Drag`), bursts with no knockback, and lets them drop.
- **Every screen draws the black hole the same** (2026-11-16): a snail it drags through the air drifts along a path
  written once on the snail (Snails' `Drag*` attributes and `Helpers/Drag`, easing in over `DRAG_EASE`), which each
  client draws before the camera on `I.Match.GetDrawTime()`, as throws are, never the anchored ball's replicated steps
  (they looked choppy on other screens). An open hole draws a vortex on every screen (Combat's `Combat_HoleOpened`,
  the `Vortex` handler): `VORTEX_ARMS` carriers of its trail orbit its middle, closing in and spinning faster, since a
  still hole draws no trail, with its open, hum, collapse and burst sounds. It pulls harder since that day:
  `BLACK_HOLE_DRAG_SPEED` 16 (was 10), its `PullRadius` 24 (was 20), and only a snail on about the hole's level, with
nothing in the way, slides; one under a hole higher up, or stopped by a step, drifts up through the air (Snails'
`DRAG_SLIDE_MAX_RISE`, `DRAG_SLIDE_STUCK`).
- **The homing missile locks on, then dives** (2026-11-16): after its `LockDelay` it stalls for its `LockPause` (0.2 s)
  with its nose turning to the target, flashes and beeps (Combat's `HOMING_LOCK_VFX`, `Homing_Lock`), then dives with
  a whoosh, the jet trail and sparks (`HOMING_DIVE_TRAIL`, `HOMING_DIVE_SPARKS`), speeding up from `HomingSpeed` 70 (was
  60) to `HomingMaxSpeed` 150 by `HomingAccel` 160 and turning at most `HomingTurn` 5 radians a second, growing by
  `HomingTurnGrowth` 10 each second, so it bends into its target instead of snapping onto it. Ballistics steers it the
  same on the server, every client and the bots' `Predict`.
- **A blast hurts at once; the crater follows** (the owner, 2026-11-13: the black hole "updates the terrain after a
  lag… and deals damage after a lag"): Blast hurts every snail the moment it shows, while the server cuts the crater,
  and throws them only once it's cut. Craters cut with one merged cutter (Arena's `Cutter.Merge`), and a client's own
  pieces skip precise collision, so its hole shows in the blast's frame. The variety grenade bursts into four mini variety grenades (its `Bomblets`' `Mini`), and **each mini digs on
  like a worm** where it bursts (the owner, 2026-11-16: "verity should burst into digging worms", undoing the testers'
  minis-only burst of 2026-11-13; its `Bomblets`' `Hatch` and its `Snails` row), drawn as the mini itself, not a worm
  (the owner, 2026-11-17: "instead of worms do smaller verity grenades… just replace the model"): it squeaks as it dives in and
  crunches as it digs (Combat's `SNAIL_DIG_SOUND_EVERY`), and the bomb sounds its burst (the row's `BurstSound`, the
  Cluster bomb's `Cluster_Split` too).
- **A thrown shot leaves the snail moving until it bursts** (the owner, 2026-11-15: "throw it and run away"): after an
  `Arc` or `Target` shot the player keeps moving their snail with the stamina it has left; the shot's blast, a hit on
  that snail or an open black hole drawing it takes the snail back first (Combat's `Blast._takeBack`), so the server
  owns it before anything throws it, and Match at the shot's end. Guns and swings end the move at once. The HUD's
  timer stays on the time left, dimmed (MatchHud's `TIMER_SPENT_COLOR`), from the shot to the turn's end.
- **One jetpack a match, on fuel** (the owner, 2026-11-15): the Jetpack's single use puts it on with SnailControl's
  `JETPACK_FUEL` (6 s) of flight that lasts from turn to turn (`JetpackFuel`) until it's spent, then it comes off and
  the bar's slot locks. Flying spends fuel, never stamina; the flying client reports what's left
  (`SnailControl_Fuel`) and the server takes at least what its climb burned. **It rests the turn after it flew**
  (the owner, 2026-11-15: "1 turn cooldown"): a snail that burned fuel on its turn (`JetpackFlew`) can't fly its next
  one (`JetpackRest`, set as that turn starts), its fuel kept; bots obey it too. While the jetpack is on, its fuel
  shows on a bar over the health and stamina bars at the bottom left (MatchHud's `U_Stamina` › `U_Fuel`, the stamina bar's twin in orange: "Jetpack
  75%", or "Jetpack next turn" while it rests), drawn from the client's own count as it burns. **It's strapped to the shell and goes on at once** (2026-11-16): the
  studio's twin-tank jetpack follows the skin's shell bone through every animation (Snails' `GEAR.Jetpack` `Bone` and
  `BoneOffset`, scaled by `GEAR_SKIN_SCALE`), its back tank on the back of the shell and its jet under it
  (`JET_TRAIL_OFFSET`), and picking it on the bar puts it on with no press on the screen (the owner's pick, MatchHud's
  `USE_ON_SELECT`).
- **Utilities are held, then used** (the owner, 2026-11-15: "when you click it it equips and the worm is holding
  it, and when you click on screen it's used"): picking a Medkit, a Bandage, a potion or the Parachute
  puts it in the snail's hands (`HeldItem`, no aim); the next press on the screen uses it (MatchHud's
  `LoadoutBar.UseHeld`, any press, a finger's too; RT on a pad), and the snail takes back the weapon it held before, or
  the Bazooka when that one has no uses left or cools down. The Jetpack is used the moment it's picked since
  2026-11-16 (the owner, MatchHud's `USE_ON_SELECT`).
- **A new player takes the Bazooka and one weapon** (the owner, 2026-11-25: "keep only 2 slots for weapons (bazooka
  always there), and other slots for coins or robux (each being more expensive)"): Loadout's `BASE_SLOTS` is 1; slots
  2 to 6 open in order, each for its own, rising price in diamonds (Loadout's `DIAMOND_SLOT_PRICES`), and slots 3 to 6
  for Robux too, each its own developer product (the owner, 2026-11-25: R$39, 69, 99, 149, Loadout's `SLOT_PRODUCTS`),
  which the slot's question offers when the player can't pay. The two slot game passes from before are no longer
  sold; their owners keep the slot each gave. Players from before keep the 3 they had (Loadout's
  `KEPT_SLOTS`, decided once per profile from their played tutorial or a filled slot), so nobody loses an equipped
  weapon.
- **Used-up items lock on the bar** (the owner, 2026-11-15): a slot with no uses left for the match shows a lock over
  its darkened icon (MatchHud's `BarSlot` › `S_Lock`), as a cooling one is darkened.
- **A cooling slot counts its turns and charges up** (the owner, 2026-11-25: "now its just a number and it looks
  bad"; then "a bunch of text", so since that day each text has one place, as on the loadout's cards: the key a key
  cap top left, the uses left a dark pill top right, the name along the bottom, kept while it cools): its turns left
  in a round badge ringed in the charge's blue in the top right corner, in the uses pill's place (no TURNS word), the
  icon greyed but seen in the middle (the owner: "not centered… we cant see the icon… put it in the corner"), never more
  than the item's `Cooldown`, its card filling in blue from the bottom as the turns pass (the card's own fill picture cut by a
  gradient, `S_Charge`), and a white flash of the card as it's ready again (`S_ReadyFlash`).
- **Dynamite is placed, not thrown:** it drops at the snail's feet (`Aim = "Feet"`, no launch speed), the stamina bar
  fills again and the player keeps moving for its `Retreat` (3 s) before the server takes the snail back, and the fuse
  (3.5 s) goes off after that.
- **Bots play like players** (2026-11-08): they walk, climb, jump and fly their jetpack with SnailControl's speeds and
  stamina (Bots' `Move`), never step into the sea or down a drop that hurts, walk to a spot their shot lands from,
  close in to swing or place Dynamite and run, and heal when hurt. Their snails stay server-owned. A bot never passes
  a turn (2026-11-10): when its brain finds no plan it still fires the Bazooka toward the nearest enemy (Bots'
  `_fireAnyway`).
- **The tutorial is a short fight, then one weapon** (the owner, 2026-11-24: "VERY VERY SIMPLE", replacing 2026-11-15's
  whole match with a step per round, and its Grenade and wind steps; 2026-11-25: a move step first, and "lets not
  make so our rocket kills the worm in one hit... so there is the battle"): a new
  player's first join sends them to a 1v1 against a bot, with the Bazooka alone whatever their loadout (Match's
  `TUTORIAL_LOADOUT`), no wind and no clocks (Match's `TUTORIAL_DROP_SECONDS`, `TUTORIAL_TURN_SECONDS`; the HUD hides
  them). They land on the lit spot (about 30 studs from the bot near the map's middle, 8 studs over the land, any press
  on it counts: Match's `TUTORIAL_*`); on their first turn walk to a ring a few studs toward the bot ("Move here", with
  how to walk on their device under it: Tutorial's `MOVE_*`, `MOVE_TIPS`), then drag to aim and press FIRE, turn after
  turn: the bot has a snail's full health (Bots' `HEALTH` gives it none of its own since 2026-11-25; 10 before, so one
  hit won), and the bot shoots back gently (the owner, 2026-11-25: "shoots you few times - but most of the times misses - but
  shoots around you", replacing shots away into the water): its Bazooka lands near the player, past the blast, and from
  its second turn now and then on them, never twice in a row and never below `TUTORIAL_HIT_SAFE` health (Bots'
  `_tutorialShot`, `TUTORIAL_*`), so a miss just comes round again. The player plays first (Match keeps the roster's order), and they aim with the same
  preview dots as every match (the owner, 2026-11-25: "so player is not confused that he has it here and does not have
  it in the main game", replacing the whole path line of 2026-11-15). The match ends on a win card in place of the
  results ("You won!" or "Nice try!", one CONTINUE back to the lobby: the `TutorialWin` gui) and gives the Grenade and
  the Shotgun; in the lobby the picker opens by itself once, and equipping either finishes the tutorial. Only then are
  its 50 diamonds paid, flying into the diamonds slot (Tutorial's `MATCH_DIAMONDS`). END TUTORIAL on the top bar, in
  Leave game's place through the match, asks first, then ends the whole tutorial with the weapons and the diamonds.
  Its map is Training Meadow, a small island made for it (MapLab, exported 2026-11-13), in no rotation.
- **After the tutorial the lobby shows where to play with others, briefly** (the owner, 2026-11-25: "subtle and
  professional... shouldnt be annoying and should disable after a while"; then "maybe the JOIN buttons glowing", since
  an arrow at the PUBLIC MATCHES title invited clicks on the title): each JOIN on the board glows (its `S_Glow`, pulsing)
  with one small line beside the title, a few seconds after each lobby arrival, for a few seconds, under no window,
  until the player has played a real match (Tutorial's `PUBLIC_*`). Never an arrow at something that isn't pressable.
- **A dropped player's snail plays on under a bot** (2026-11-10): it's never knocked out for being away. A bot plays
  its turns with the player's loadout (Match's `Autopilot`, Bots' `TAKEOVER_DIFFICULTY`), taking over mid-turn too,
  and the player, back from the lobby's rejoin offer, plays from their snail's next turn as the bot left it. Only the
  Leave button forfeits.
- **Bots think with a trained brain** (2026-11-08): each turn the Bots module's brain plans with the game's own
  simulation (Combat's shot bodies, blasts, throws, craters and the sea) and scores every plan with its difficulty's
  genome (`ServerData/Brains.lua`), which self-play trains (the gym, the `train-bots` skill). **Runs play on the PC**
  (the owner's pick, 2026-11-13): the repo's `bot-gym/` runs the gym's own code in Lune with stand-ins for the engine
  calls, on every core at once, and Studio sits the champion's last exam before it ships. The Bots module's parity
  probe checks the two play alike; run it after changing what the stand-ins replace (Combat's casts, the Arena's
  carving, debris or liquid). Difficulty is skill
  (`SKILLS`: the hand's error, the wind read, how far it looks, how much it minds the map), never deliberate misses
  (the tutorial's bot alone picks near misses on purpose, 2026-11-25).
  Nightmare is a secret difficulty, offered only in a custom lobby's Bots row (the owner's pick, 2026-11-08). Retraining, and teaching the bots something the game adds (a
  weapon, a map object, a hazard), happens only when the owner asks. **Bots' loadouts** (the owner, 2026-11-13): the
  spider bomb from Medium up (Bots' `LOADOUTS`), and **no disabled item** (the owner, 2026-11-25): Dynamite, the
  black hole grenade, the Spartan spear, One Punch and the potions left every loadout, so bots roll no potion now
  (`POTIONS` holds only none), and the brain's potion and Dynamite plans stay for a player's snail a bot takes over.
  **Bots play tricks and taunt** (the owner, 2026-11-13: "make them play like pros"): Hard and Nightmare also shoot
  hovering on their jetpack (no higher than a safe fall), and bank grenades off the ground and walls into targets their direct arc can't
  reach (a skill's `Banks`); every brain sees a blow bounce and slide an enemy off its ledge into the sea (Predict's
  throw follows Snails' flight). A bot's knockout of an enemy, or a hit of 20 or more on a player, plays an emote on
  its snail (Bots' `TAUNT_*`, Cosmetics' `PlaySnailEmote`). **Snails drop apart, never on pre-set spots** (the owner,
  2026-11-13: "3 bots are in the same place"): the drop draws `DROP_SPOT_CHOICES` random land spots per snail, no bot
  takes one within `START_GAP` of a spot taken, and players who don't place start on a free one. **Bots never spend
  their own health** (the owner, 2026-11-15: "remove that the bots sacrifice their hp"): no plan that hurts or knocks
  out the bot itself, or walks it into a pond, while any other is left (Bots' `Harm`, `CLEAN_SEARCH`), except a shot
  that wins the match. **Bots move like players** (the owner, 2026-11-15: "more realistic… so their moves are not
  restricted"): after a thrown shot every bot walks on with the stamina it has left to the spot it likes best, clear
  of its own blast (Bots' `GetRetreat`), and a bot whose target went out after it planned (sudden death's sea) plans
  again before it fires. **Nightmare plays like the best players** (the owner, 2026-11-15, picking from the bots'
  next ideas): it opens the black hole in the air over its targets with a second press (`AirPops`), weighs the next
  turn with each plan (its own next shot, the enemies' replies: `Lookahead`), remembers how much each player deals and
  how far they walk this match (`Memory`), and goes for the enemy whose turn is next (`Tempo`); its hand is steadier
  and it checks its best shots still work a hair off (`Sure`). It carried the Spartan spear, One Punch and the black
  hole grenade until they were disabled (2026-11-25).
- **A walking snail has no grip:** its ball's friction is 0 while it walks, so it slides along walls and up slopes;
  at rest it grips again (`ROOT_FRICTION`).
- **Snails are light, and a thrown snail flies the game's own physics** (the owner, 2026-11-12: "more like worms…
  fly further, higher… fall slower… not use the roblox physics"): snails feel Snails' `GRAVITY_SCALE` (0.55) of
  gravity (the ball's `Lift` holds up the rest; `JUMP_SPEED` keeps a jump about 5 studs high). A knock throws the
  snail on a Combat Ballistics body, never an impulse on Roblox physics: the server anchors the ball and steps the
  flight, writing its speed on the anchored ball, and every client draws the same flight from the snail's `Flight*`
  attributes before each frame (Snails' `Flight`), so no remote. It bounces softly (`FLIGHT_BOUNCE` 0.2, lowered from 0.3 on 2026-11-12: the owner, "decrease the bouncing") and lands back on
  Roblox physics once it rests on the ground. Walking stays Roblox physics on the owner's client. Anything that hands
  a ball to a player or takes it back checks it isn't anchored first. Forces and impulses on the ball read its own
  mass, `root:GetMass()`, never `AssemblyMass`, which is infinite while it's anchored mid-flight (2026-11-13: an
  infinite `Lift` set at a turn's end turned the ball NaN when it landed, Roblox deleted it, and the match went back
  to the lobby).
- **Thrown bombs burst when they stop** (the owner, 2026-11-12): a thrown bomb with a fuse (the Grenade) goes off as
  soon as it comes to rest on the ground, or when its fuse runs out first; placed Dynamite still waits for its fuse.
- **The next turn waits for the arena to settle** (the owner, 2026-11-12): after a shot or anyone getting hurt, 3 s
  of calm before the next snail (Match's `HIT_HOLD`), so everyone sees what happened; calm means every snail at rest
  on the ground or in a liquid (none in the air), no debris falling, no shot and no health changing. Something that
  never settles moves on after 5 s of nothing moving or getting hurt (`STALL_SECONDS`: a snail stuck off the ground, a
  mine that never goes off), and 20 s of settling always does (`MAX_SETTLE`). A new hazard (mines, fire) keeps the
  turn waiting by hurting or moving snails, or by joining the calm check in Match's `Turns._settle`.
- **Ponds hurt like Worms' poison** (the owner, 2026-11-12): at the end of every turn, whoever's it was, each snail
  with its head under a liquid that doesn't knock it out (Mirage Mesa's oasis) loses 5 health (Match's `UNDERWATER_DAMAGE`,
  the head's top `UNDERWATER_HEAD_HEIGHT` over the ball), never going below 1: a pond weakens a snail, and something
  else has to finish it. Only its body under, its head above the surface, does nothing.
- **Getting hurt doesn't end your turn** (the owner, 2026-11-15, replacing 2026-11-12's Worms rule): a turn ends only
  with its shot or its timer; a fall, lava or a mine only hurts. A hurt still holds the settle after the turn
  (Match's `Turns`).
- **An emote turns the snail to face the camera, and a hit or a shot wins** (the owner, 2026-11-12): while it emotes,
  the snail eases round to face this screen's camera and back after (SnailRig's `FACE_TURN_EASE`, the whole rig
  turned about the ball's upright axis on each client), its held weapon hidden. A snail hidden in its shell (hit or
  thrown) can't emote, and a hit ends an emote at once; the player's screen doesn't send one then, and a screen that
  refuses it shows no bubble. Shooting ends it at once too: on the shooter's screen at the press, on every screen when
  the match enters its Flight (Combat's client `Held`). **An emote plays whole** (the owner, 2026-11-24: the wave
  played in the lobby's bazooka pose): the poses over the walk stop while it plays and pick up where they were after
  (SnailRig's `MUTED_PRIORITIES`), and on the lobby's stage its cloud stands over the nameplate, never on the name.
- **Potions show on the snail, and on the player's screen on their turn** (the owner, 2026-11-12): a snail under the
  Speed or Low gravity potion streams its `Aura_*` Vfx prefab (since 2026-11-16 the studio's Speed and Low Gravity effects, their trails too), and on the player's own
  turn the `PotionVignette` gui tints the screen's edges cyan, violet, or pink for both (Snails' `POTION_*`).

## Guis

- **The look is the owner's GUI kit (draft 4, adopted 2026-11-04):** windows in a sea-teal gradient with a faint
  diamond pattern, an orange border, a tilted yellow Hazard plate title and a slanted red close; buttons, cards and
  reward frames are 9-slice skin pictures with their outline, light, lip and drop drawn in; things sit on plain
  see-through black slots; framed reward tiles only for rewards being won; Londrina Solid Black for every text. Every
  gui uses the `WormBattlegroundsBrawl` theme, which extends `WormBattlegrounds` (its README describes the kit). The
  gui folder's `brawl-gui` skill makes new guis in it.
- **Yellow leads the eye:** a yellow button is the next thing to press, one per window and three at most on a screen;
  every other button wears its job's colour (blue other actions, green prices, red leave and close, purple modes,
  slate tabs, grey owned or locked).
- **Picked and owned states come from the kit, not from recolouring a face:** a button swaps its skin from the
  attributes on its `Face` (`Kit_Image`, `Kit_SelectedImage`, `Kit_DisabledImage`), a slot shows it's picked by its
  `Body` fill, a rarity is a text colour (`I.Rarity.GetLook(rarity).Base`), and a reward tile takes its rarity's
  frame, stage and light from its `Kit_<Rarity>_*` attributes. Exports can't run the theme's controls, so code reads
  what the controls recorded (the theme's README → Button, Item).
- **Pictures drawn for the game stay local until the owner approves them:** a kit (the game home's
  `assets/_inbox/ui_kit_brawl/`) renders them into Studio's content folder (`rbxasset://textures/wb_brawlpreview/…`)
  and writes the theme's `Icons.lua` and `Skins.lua`. Nothing is uploaded to Roblox before the owner says so; then
  the pictures get PrepKit's pixel-fix, are uploaded, and `Icons.lua` points at their `rbxassetid://` ids. Both kits
  are uploaded: the GUI kit on 2026-11-04, the first kit's item, emote, currency and crate pictures and the wind on
  2026-11-07, after a Studio update had wiped their local copies and blanked every icon. The emote, bot and badge
  pictures followed on 2026-11-11 (the owner: "in live game the icons, wind etc is not working"). The game uses no
  local picture now. A new one shows only on the PC that built it, blanks after the next Studio update, and never
  shows on live servers until it's uploaded (each kit's README → Uploading). **Pictures go up under The Snail Studio
  group** (566704940, the game's owner), through Open Cloud, never under a person's account. Studio's Assistant
  uploads under the signed-in user, as the 2026-11-07 icons and the wind were (viridianscape): such a picture loads
  in that user's Studio but may not on the group's live servers.
- **Weapon and item pictures are drawn in the weapon icons' look** (the owner, 2026-11-17: "check how our weapon icons
  look, make the style similar", on flat sticker icons): chunky objects with a thick ink outline, three tones on every
  face (a light top, the colour, a dark bottom), the brick studs on their faces, metal parts in light grey and a soft
  gloss on the upper left. **UI icons are white ink-outlined glyphs** (2026-11-24, the studio's `LobbyRework` design,
  overriding that rule for buttons and modes): one solid white shape with a thick ink outline round it, no colour or
  gloss (`art/ui_glyphs`, uploaded that day): the mode icons, LOCAL, CUSTOM, PLAY SOLO, the STYLE, WEAPONS and SKINS
  tiles and FREE WEAPONS. A new button or mode icon is a glyph there; Quads alone keeps its `art/modes` icon.
- **The game's guis are built from the theme's controls** (`WormBattlegroundsBrawl`, over `WormBattlegrounds`),
  never from raw `Primitive` nodes holding their own colours and sizes (as ume-gui's System guis are): `Widget` for
  every WidgetManager widget, `Box` for panels and cards, `Item` for item cards, `Cells` for lists and grids code
  clones rows into, `Picture` for images, and the shared `Label`, `Button`, `Stack`, `Progress`. Restyling the game
  is a theme change (the gui folder's `src/themes/WormBattlegroundsBrawl/_meta/README.md`). Overrides
  `gui/format.md` → Buttons and Surfaces ("other guis, built from `Primitive` nodes").
- **The studio's screens are 1:1 `Primitive` ports** (the owner's pick, 2026-11-09): the match HUD (`MatchHud`,
  `SnailTag`, `DamagePop`), the lobby (`Lobby`, `Party`, `Loadout`, `LoadoutPicker`, `MatchBoard`), `Crates` and
  `Skins` are the studio's `HUD`, `LobbyInventory`, `Gacha` and `Customise` designs (and since 2026-11-11 `Currency` and
  `EmoteShop`, the gui maker's) converted node for node into
  `Primitive` nodes (their pictures, fonts and screen-fraction layout), with U_/S_ Ids, prefabs for lists, button tags
  and WidgetManager's widget shape added. Since 2026-11-12 the studio's `New_Guis` designs are ported the same way:
  `PlaySolo` (MatchBoard's setup until 2026-11-17, when it took the custom lobby's window) and `MatchWaiting` (its own gui since 2026-11-15, the public
  match's waiting room at the bottom middle of the match server's screen), `KnockedOut`
  (MatchHud's `U_KnockedOut`), `MatchOver` (`Results`), `InvitePlayers` (`PartyInvite`), `CustomLobby` and
  `CustomLobbyPlayers` (`CustomLobby`'s two steps), `Shop`, and `Loading` (`TeleportGui`); the HUD's power and
  stamina bars are the studio's `PowerSlider` (the same pictures, the bar `Fit`, its mask cut with it). They override
  the rule above and the GUI kit's look rules (yellow leads the eye, kit picked states) for these guis: a picked or
  locked look is copied from the design into `Look_*` attributes on the prefab or button, which code swaps. Blocks
  the designs lack (MatchHud's drop and waiting dialogs, the kill feed, the emote wheel) stay theme controls in the
  same table (`Theme = "WormBattlegroundsBrawl"`). They lay themselves out by screen fractions with aspect-ratio
  constraints, so they need no `S_ScreenScale` and aren't in ScreenScale's `GUIS` (MatchHud stays, for its kept
  blocks). A block added to these screens since is built from the design's own pictures and fonts as `Primitive`
  nodes, never as a theme control (the turn callout and the tension band, 2026-11-10: the owner, on the GUI kit's
  Hazard plate, "this is old style, the new style is MatchBoard or MatchHud").
- **A new piece is a copy of one the game already has** (the owner, 2026-11-17, on the polish pass's first build:
  "make sure the colors, transparencies and overall style is the same as our guis in game… the guis are weird, they
  don't fit, they overlap"): find the nearest piece on the screens the player already sees and copy it, its
  pictures, sizes and colours, never a one-off panel, ring or colour. A timer is the turn timer's plate, a banner the
  turn callout, a setup window the custom lobby's, a second button a copy of its neighbour's, a top-bar plate a
  currency slot's, hints the HUD's pad-hint lines. Check a new piece in a play test beside what shows with it (the
  notifications at the bottom middle, the top-right menu, the waiting room, the turn callout) before calling it done.
- **Dialogs in the new look stay simple** (the owner, 2026-11-11, on a confirmation built from the Loadout slot's
  slanted art scaled up, the EMOTES title plate and a red X: "its ugly. dont make it too complicated"): one rounded
  dark panel (fill 25, 25, 35, a dark outer line and the grey 130 line inside, `UIStroke`s scaled by
  `Utils_UIStroke`), white Londrina text, and the design's buttons at about their own size, tinted. A design picture
  made for a small card is never stretched into a big panel: its outline and corners grow with it. The confirmation
  (`WidgetManager_Confirmation`, the game's copy of System's) is the pattern; the party invite popup (`PartyInvited`)
  follows it since 2026-11-13 (the owner: "it's using the old ui version").
- **The tutorial points with a red arrow, never a blackout** (the testers, 2026-11-15: "no blackout just red arrow";
  the owner, 2026-11-24: "more subtle"): the `TutorialHint` gui points the snail tag's own turn arrow at what to do
  next, bobbing toward it, with a hint of two or three words in the HUD's white outlined text (48 px, no panel), worded
  for the player's device (Tutorial's `HINTS`, `TOUCH_HINTS`, `PAD_HINTS`); a soft white ring marks only a spot in the
  world (the drop's lit spot), and "Drag to aim" shows alone under the snail with a touch point sliding as a drag
  would. The bot's turns show nothing, and the guide hides while another window covers it. Nothing else is darkened
  or blocked. A new step of the tutorial is a target and a hint.
- **Turns are announced, and the end of a turn tightens** (the owner's pick, 2026-11-10): as a turn starts a dark
  banner opens across the screen with the snail's avatar (its headshot, or the bot picture) and whose turn it is
  (MatchHud's `U_TurnCallout`, the owner: "make it look professional"): "Your turn!" in gold over orange lines for the
  player's own, with a sound and a haptic tap; anyone else's smaller, in white over lines in the snail's team colour,
  with how long until the player's own. The player hears when they're next. In the last seconds of their own turn the timer turns orange, then red, ticks faster and higher, and a
  red band pulses along the screen's sides (MatchHud's `TIMER_*`, `TICK_*`, `TENSION_PULSE_RATE`). **Sudden death is
  announced on the same banner** (2026-11-16): once the turn's own callout is gone it reads "Water is rising..." or
  "Lava is rising..." (Match's `SeaKind`), no avatar, its lines in the liquid's colour and its title filling with it
  from the bottom, and every sudden-death turn's line adds "The water rises" (MatchHud's `SUDDEN_DEATH_*`).
  **The banner is a calm strip, not a bar across the screen** (the owner, 2026-11-24: "too heavy and too sloppy… text
  almost overlaps icon… make it more beautiful and subtle"): 0.62 of the screen wide and 0.09 high at 0.3, its band 40 %
  see-through and fading out over its outer thirds, thin lines, the avatar a quarter of the banner's height clear of
  the text, light outlines, and a calm settle (MatchHud's `CALLOUT_*`); on phones and tablets 0.72 × 0.15
  (`Utils_PlatformSize`), so the name stays readable and clear of the turn list.
- **On phones the turn panel keeps out of the aim** (the owner, 2026-11-25: "it can overlap with the shooting area"):
  the timer and wind sit at the top of the HUD at 0.8 of their size (MatchHud's `TURN_MOBILE_POSITION`, the gui's
  `Utils_MobileSize`), and "Your turn!" under the timer is left out there (the callout and the turn arrow say it);
  other snails' names and the wait line stay.
- **Screen-wide effects cover the whole device, not the safe area** (the owner, 2026-11-25, on the round intro's dark
  edges stopping in a box on phones, then "make sure all vignettes and borders like that are stretched out to the
  full display size"): every gui that draws over the whole screen (the HUD, `PotionVignette`, `TeleportGui`,
  `LobbyGui`, WidgetManager's dim) has `ScreenInsets` `None` and `ClipToDeviceSafeArea` off, and an edge effect
  runs past the screen, solid out there, so a phone's notch side is never a light strip (BattleIntro's
  `_coverScreen`, `INTRO_COVER_BLEED`). A new full-screen effect does the same.
- **Only the player's own snail wears the full tag** (the owner, 2026-11-16: "small minimalistic hp and nickname"): on
  each screen every other snail's SnailTag shows its name and health bar only, at Snails' `OTHER_TAG_SCALE` (0.7, an
  `S_SmallScale` UIScale on its `Overhead`), no level or badges; the turn arrow and timer keep their size. Once the
  active snail acts only its arrow hides; the tag and its health stay up. **No tag shows a level** (the owner,
  2026-11-24). **On the player's own turn their tag is the turn arrow alone** (2026-11-24), no name, badges or health
  bar, close over the snail (Snails' `OWN_TURN_TAG_OFFSET`), the arrow up all turn and bobbing only upward, never into
  the bar; the full tag is back after. **The player's
  health and stamina are at the bottom left** in the stamina bar's look (MatchHud's `U_Bars`: health over stamina,
  the jetpack's fuel over both), above the phone's walk buttons and the pad's hint strip.
- **Crates open on the GACHA screen, CS2's way** (the owner's pick, 2026-11-11: "use our gui style but use the layout
  of cs go crate opening"): the shop makes way and the opening plays on the `Crates` gui itself, never in a window of
  its own (`CrateOpen` is unused). The bought crates drop in as 3D models in a ViewportFrame (the owner, 2026-11-11:
  "instead of the 3d icon floating crate - do a 3d model there"), one, three (one in front, two behind) or ten, wait
  for one tap, and open hatches first, then walls, into a ball of light that flashes into a reel of item cards under a
  fixed line on CS2's curve, landing anywhere across the winning card; packs as stacked bands (x3) or columns (x10),
  the rarest stopping last; a legendary first lands as a gold ★ card, then a golden crate (the same model lit gold) is
  tapped open, a golden reel picks which and its own drop plays (Crates' `LEGENDARY_DROPS`: a new legendary gets a
  drop of its own there, or the plain legendary reveal). The crate models are `PREFAB | Crate_<Name>` in
  `ReplicatedStorage_Assets/Crates`, named by the row's `Model` (the shop's pedestal shows the same model, never a
  picture), in the snail's model look (chunky bevelled parts, flat colours, the stud baked into one texture,
  `art/crates/bake_models.py`); their pieces turn on hinges in code, so a new crate keeps the eight piece names and the
  pivot in the middle of its floor. A ten-pack shares one set of effects and has no per-crate balls of light (Crates'
  `STAGE_LIGHT_COUNT`). A crate's colour and particles are its data row's look
  (`Glow`, `Accent`, `Ambient`). **One crate per kind, paid in diamonds** (the testers, 2026-11-13: one crate; coins or
  diamonds until coins went on 2026-11-25): one row of buttons, 50, 150, 500 diamonds for 1, 3 or 10. VIP's free daily
  crate is its x1, shown alone where paid random items are restricted (diamonds are sold for Robux, so diamond crates
  are hidden there by policy). The Premium row stays hidden so its id is known. A crate marked
  `Premium` shows it's premium by small touches (a gold tab, a halo, the violet
  backdrop, a PREMIUM tag, a pale-gold line), never another layout. Gui particles are `I.UIEmitter`'s. The sounds mix
  crisp clicks for the reel with the Great Strategy instruments for the melodies (`art/sfx/make_crates.py`).
- **Joining the studio's group opens a free crate, once** (the owner, 2026-11-16): a gold FREE WEAPONS tile in the
  lobby (left of STYLE, since 2026-11-17; since 2026-11-24 a wide tile in the menu's own row, FREE WEAPONS on one line
  at STYLE's text size: the FreeCrate gui holds a copy of the Lobby's `U_Menu` row with stand-ins for its three tiles, so
  it lands a menu gap left of STYLE on every screen shape, and its picture is the menu tile's own, both ends kept and the
  flat middle stretched between them) and the `FreeCrate` badge on the crates screen open a dialog that sells it with
  pictures, not text (the owner, 2026-11-17: "less text more visual"): the crate turning in light with rays and
  twinkles, LIKE (the player is only asked: no game can check it) and JOIN The Snail Studio (566704940, the Group
  list's `SnailStudio`) as two picture tiles. CLAIM lights once they're in and opens one
  Weapon crate on the crates screen like a bought one (Crates' `GROUP_CRATE`, paid with `"GroupReward"`); the server
  allows it once a player (`Crates.GroupCrateClaimed`) and only to members (`I.Crates.CanClaimGroupCrate`).
- **Every match's XP plays back in the lobby** (the owner, 2026-11-17: "when we come back to lobby we want to see the
  progress bar filling and all that"): a match gives XP in lines (MatchRewards' `XP_PER_MATCH`, `XP_WIN`,
  `XP_PER_KNOCKOUT`), which the server saves for the lobby (Progression's `Replay`, in the profile so it survives the
  teleport) and the lobby plays once: the `LevelPlate` gui's plate (its diamond, bar, XP and next unlock) pops up in
  the middle, the lines pop in, the bar fills with rising ticks and sparks, each level-up bursts and shows what it
  opened. Any press skips it. **No level plate at rest** (the owner, 2026-11-24: "we don't need to see 14 and LEVEL
  14"): the plate shows only for the replay and has no LEVEL title; the level stands on the stage's nameplates. **A
  small XP bar stays by the diamonds** (the owner's pick, 2026-11-25, of four places): a small rank crest in front of the
  diamonds plate and a thin bar under it, no text but the level, laid out as a copy of the Currency gui's row so it
  lines up on every screen. It's the replay's own thin bar under the diamonds ("make it this bar to keep it
  consistent"), as wide as the plate and its + ("longer and thinner than the diamond one"), the gaps over and under it even (the owner: "you can lower all this to make the
  level bar fit"): the STYLE / WEAPONS / SKINS menu (and FREE WEAPONS' copy of its row) stands at Y 0.14 and the
  LOADOUT column's top at 0.2511, its bottom where it was (0.7287), so a full column never reaches further down.
  **The replay is a rank-up, told in pictures** (the owner, 2026-11-25: "too much ugly text… needs to feel like
  leveling up in a high end competition", "based on level it gets better"): it takes the lobby (`I.Lobby.SetTakeover`
  hides every lobby gui but the diamonds and itself, and the nameplates), and shows a rank crest on rays, a thin sharp
  XP bar ("too bubbly") painted in the tier's own colours, the next reward as a card with its picture, and the XP as
  tiles with pictures, never lines of text. **Each prestige tier looks richer** (Progression's `REPLAY_TIER_LOOKS`):
  Rookie bare, then rays, a second ray layer and more stars up to Mythic's turning rainbow. A tile's picture never
  looks pressable or off-theme (the play triangle read as a button, the rocket as a spaceship: a match is the gamepad). **A level's number always fits its badge:** every badge that
  holds a level (the crest, the unlock's diamond, Results' diamond, the nameplate's badge) has a text box inside its
  shape for three digits ("100" spilled over the borders).
- **A knocked-out player sees who did it, what they earned and how to play on** (the owner, 2026-11-24, "RoWorld
  style"): MatchHud's `U_KnockedOut` in the dialog look names the killer (picture in their team colour, name, weapon)
  or the cause, then the place, diamonds, XP and stats, with PLAY AGAIN, SPECTATE and LOBBY. So a team's rewards are paid
  the moment its last snail goes out (MatchRewards' `MatchRewards_Earned`), not at the match's end, and PLAY AGAIN
  (public and solo only) goes by way of the lobby, which seats the player in another match like it from their
  profile's `Match.PlayAgain`; never a teleport straight from one match server to another.
- **Diamonds paid fly into the diamonds slot, as Brawl Stars plays trophies** (the owner, 2026-11-24: "like Brawl Stars
  with the trophies"; coins until 2026-11-25): what a match or the tutorial paid joins the replay
  (`I.Progression.AddReplayDiamonds`) and plays before the XP: "+amount" pops up over the player's stage snail, then a
  diamond per `DIAMONDS_PER_ICON` (at most `DIAMOND_ICONS_MAX`) bursts out and flies into the diamonds slot, which holds
  the old count and counts up as each lands (Progression's `Payout`). The server pays at once; only the slot's text
  waits. The diamonds burst out with `Diamond_Burst` and each landing clinks with `Diamond_Collect`, higher each time
  (the kit's 25 Nov sounds, approved and uploaded 2026-11-25). **Bought diamonds celebrate once the shop closes** (the
  owner, 2026-11-25: "make it satisfying - add like fanfares… a blue gem vignette… make it feel REALLY good"): every
  diamonds counter (the shop's own too) holds the count from before the purchase while the shop is open, and on closing the packs bought play the same
  payout, more diamonds for a bigger pack, the gift's pop with "+amount", the level-up fanfare on the last landing and
  the potion vignette breathing gem blue round the screen, flashing as they land (Progression's `PURCHASE_*`,
  `I.Progression.PlayPurchase`). Nothing plays while the shop is open. It's built from what the game has: no new gui,
  picture or sound.
- **Rank shows as a frame round the player's picture** (the owner, 2026-11-17: "prestige frame things… makes the
  player feel like he is improving"): Progression's `FRAME_TIERS` (Bronze 5 to Mythic 100) paint a gradient over the
  picture's rim (`I.G_Progression.ApplyFrame`), shining from Gold, spinning at Mythic: the party cards and the level
  plate. Frames are rank only, never sold. In a match the portraits keep their team colours.
- **Models that move in a ViewportFrame sit in a WorldModel inside it** (2026-11-11, measured on the ten-pack: the owner
  asked for it light on performance): moving even one part placed straight in a ViewportFrame redraws every mesh in
  it, about 25 ms a frame for ten crates, while the same crates moving in a WorldModel cost under 1 ms, and moving
  only the camera is nearly free. Code makes the WorldModel beside the viewport's Camera (Crates' stage and pedestal);
  a still model may sit in the ViewportFrame itself.
- **A piece's card names its slot on a tab in its corner** (the owner, 2026-11-24: "put it like under the gui… so its
  integral part of it"): HAT, NECK, BODY or SHELL on a tab in the card's rarity colour, made from the card's own fill
  cut to the top-left corner along its slant and drawn under its border (the Crates gui's `S_SlotTab`, `S_Slot`;
  Crates' `SkinModels.ShowSlot`), on the odds list, the reels and the results. Never a box floating over the card.
  Every card's snail is centred in its view (Cosmetics' `GetPieceShot` slides the camera to the posed bones' middle).
- **Rolling reels show the snails as pictures** (the owner's pick, 2026-11-11, measured on the crate reels): a model
  costs Roblox 3 to 4 ms the first time its ViewportFrame draws it (again after the viewport is hidden and shown), and
  a viewport that changed while it moved or was hidden isn't drawn until it changes again where it's seen. So a card
  that holds still shows a skin's snail live, posed (Crates' `SkinModels`, which draws a card's snail again once the
  card settles in sight), and a card that rolls shows the piece's picture, rendered in the same pose, framing and light
  (`art/skins` → Piece pictures, since 2026-11-14: the owner, "needs to show accessories not skins") and uploaded only
  with the owner's approval. A new piece gets its picture too.
- **The pad goes through the Console module** (the owner's pick, 2026-11-10: "use 0_Console module for all gamepad
  related keybinds"): its `ACTIONS` setting is the one scheme (the module's README → Scheme), modules bind or read pad
  buttons only through `I.Console` (`Bind`, `IsAction`, `IsHeld`), never `Enum.KeyCode.Button*` of their own, and
  keyboard, mouse and touch stay with them. Start is Roblox's menu and never bound; A confirms, B backs out, LB / RB
  step weapons or tabs, the right stick aims and RT fires the locked aim. A gui button a pad presses carries its action's first button as
  `Utils_GamepadKey` and a `Console_Hint` badge naming the action (`Console_Action`; the theme Button's `Hint`), and a
  screen of pad controls a hint strip of the same (MatchHud's `U_PadControls`); a pick list or panel that wants the
  selection asks for it (`I.Console.Focus`). **In the lobby and open windows a pad drives a free cursor** (the owner,
  2026-11-17: "in lobby we want a free cursor"): the Console module's `Cursor` (a white ring and dot drawn in code, no
  picture) moves with the left stick, speeding up when held and slowing over buttons; the button under it is Roblox's
  `GuiService.SelectedObject`, so A, B and the shortcuts work as with the selection; the right stick scrolls the list
  under it and the D-pad hops the selection with the cursor following. A module never moves the cursor itself:
  `I.Console.Focus` and `SetHome` send it. In a match it shows only while a widget is open. The game's own glyphs (`art/console_glyphs`) stay local until the owner
  approves them; then `HINT_STYLE` names their uploaded style.
- **Chat shows in bubbles over the snails, never Roblox's** (the owner's pick, 2026-11-10: "Bubble Style B"): each
  client turns Roblox's bubble chat off and shows every player message it receives (the filtered
  `TextChatMessage.Text`, through `MessageReceived`: TextChatService's `OnIncomingMessage` is Shop's VIP tag) in a
  `ChatBubble` billboard over the speaker's snail on this screen: in a match over its SnailTag's `S_Stack`, never on
  it, and in the lobby over their snail on the stage (`I.Lobby.GetStageSnail`). White rounded bubbles with the ink
  outline and Londrina text, sized to their text by TextService, three at most, the newest lowest with the tail
  (ChatBubbles' README). No snail on this screen, no bubble.
- **An emote shows its icon in a speech bubble and plays on the snail** (the owner's pick, 2026-11-11: "the icons are
  going to appear over the player in a message bubble type of way when player clicks the emote + animation is going
  to play"): over the snail in a match, in its chat stack (`I.ChatBubbles.ShowIcon`), and in the lobby over the
  avatar's top right corner on their party card, the tail down at the picture (2026-11-17: it covered the name). Every
  screen plays the emote on the snail (`I.SnailRig.Emote`); until an emote's animation is published under its name, a
  stand-in motion made in code plays. Emote pictures are the studio's (since 2026-11-17, replacing `art/emotes`' drawn
  set; sources in the game home's `assets/ui/icons/emotes/`), bot pictures the game's own (`art/bots`), all uploaded
  to the group.
- **Emotes are a hold-to-open wheel in a match** (the owner, 2026-11-17: "make the in game emotes menu better"): T or
  X held, point, let go; a quick tap replays the last; one slice per emote in the emote shop's order, locked ones
  greyed with their level (Cosmetics' `Emotes`). The emote button opens it to pick from with a click or tap.
- **The drop picks the spot under the pointer, as it always did; only its look changed** (the owner, 2026-11-17:
  "the old one was good - i just wanted to change it visually", after a ring projected onto the land under the
  pointer, with snapping into islands, confused them): the spot is the point on the plane under the mouse, a tap or
  the stick, and a click places it only where a snail fits (Match's `DropPicker`, as before 2026-11-17). The look is
  new: every snail's spot shows the DropMarker pin, its tip on a small target on the spot (the aim crosshair's ring in
  its colour and a dot: the owner, 2026-11-17, "make it subtle"), in its colour with its picture and name; the player's
  own follows the pointer until placed, faded where a snail doesn't fit, others' are faded until placed, and a placed
  pin drops in and its target pops in with `Drop_Place`. The drop's timer is the turn timer's plate ("0:15"), red for its last
  seconds. Never put the target somewhere other than under the pointer.
- **New players see their controls** (the owner, 2026-11-17: "add some hints… based on the device"): the
  `ControlHints` list for the device in use shows while waiting and during the drop, for a player's first
  `HINTS_MATCHES` matches (the `MatchesPlayed` statistic), never in the tutorial. It's a short list at the bottom left
  in the HUD's pad-hint look, never a panel at the bottom middle, where notifications and the waiting room show (the
  owner, 2026-11-17: "they overlay different notifications and guis"). Its labels are one or two words (Walk, Jump /
  Fly, Shoot…) so they show at one size, and the tip line over it tells the holds.
- **Round HUD shapes come from frames:** the emote wheel's slices are built from UIStroke, UICorner and UIGradient
  half-plane cuts (a CanvasGroup's gradient for the second cut), never new pictures.
- **Badges after a name are the server's, and every one shows** (the owner's pick, 2026-11-10: "if a player has
  multiple, display multiple"): the PlayerBadges server writes the `Badges` Player attribute (owner, developer by
  rank or role name in The Snail Studio's group, since its roles share rank 1, the AdminPanel's admins, Roblox staff, Video Stars, verified, Premium), and every
  name a player's badges belong after (the player's own SnailTag, the turn list, Results) has an `S_Badges` frame beside it
  that `I.PlayerBadges.Show` lays out, shrinking the name first. The lobby shows no badges: its names are the stage's
  nameplates (2026-11-24). Verified and Premium are Roblox's own glyphs
  (`U+E000`, `U+E001`, which the game's fonts draw); the rest are the `art/badges` kit's pictures, uploaded to
  the group (2026-11-11), one `Image` each in PlayerBadges' `BADGES`.
- **No value controls in a game gui** (`Dropdown`, `Segmented`, `Slider`, `Toggle`, `Input`): exports are static, so
  they do nothing in game. Use buttons the module selects. Preview modules may use them in their `Settings`.
- **Lists code fills use `Cells`,** not the shared `Grid`: `Grid` lays its cells out in code, which exports don't run.
- **Never `Wrap = false` on a `Label`:** scaled text must wrap, and the export refuses it.
- **No `Box` with labels inside a `Fill` row** (`Stack` with `Fill = true`): the labels get no height. Lay such
  content out in a horizontal `Stack` inside one `Box`. `Fill` rows of buttons are fine.
- **No scale-sized frame inside a scale-sized child of an auto-height frame:** Roblox then grows the auto-height frame
  to its parent's full height. Look parts under a `Box` stay direct children (the theme's `Slab` has a Folder root for
  this).
- **Text outlines follow the letters:** a UIStroke on text sets `ApplyStrokeMode = Contextual`, since `ctx.Stroke`
  outlines the box.
- **Every text outline has one of two weights** (the owner, 2026-11-24: "make sure all strokes are working with each
  other… they look too thick and sloppy - find a golden balance"): a dark `UIStroke` on text is ScaledSize 0.06 on a
  title of 40 px or more and 0.07 on every other label, in every gui, the world's billboards too. Never a 3 px outline
  turned into a fraction of the label's size (the ported designs' 0.1667 on 18 px names, 0.125 on 24 px): small text
  ended up the heaviest. Coloured outlines that are part of a look, picture outlines and pixel strokes keep their own.
  The turn callout, the first piece in this weight, is lighter still (0.045 and 0.05). **A marker's own outlines match its text's**
  (the owner, 2026-11-25, on the drop pin: "fit to the text size stroke"): the dark lines round a pin's head, point,
  ring and dot are as thick as its name's outline (about 2.7 px at the DropMarker's design size), each a `ScaledSize`
  fraction of its own frame so it scales with the billboard, never a fixed 4 px.
- **The design's dark tiles and panels read solid** (the owner, 2026-11-24, on the "+" slots: "make it like in the
  reference"): the studio's navy fill pictures (`Main`, tinted 25, 25, 35) are partly see-through, solid only over the
  design's dark backdrop, so every one in the lobby's guis and windows and the match HUD (but its team portraits and turn
  list, whose pictures code swaps) is drawn three times (two `MainFill` copies over
  it) and the grey 130 outline twice (`StrokeFill`) where no code recolours that outline. Code that recolours a tile
  still reads `Main` and `Stroke` (the first by name); a recoloured outline gets no copy.
- **Showrooms are dark rooms with the thing lit in the middle** (the owner, 2026-11-24, on the Style screen and the
  crates' pedestal: "make it look professional"): the Style screen darkens the room behind its panels (`Shade`) and
  lights the snail from behind (`Backlight`), the camera centring the posed snail as it's seen (its bones, not the rig's
  rest-pose parts); the crate stands on a pedestal drawn from shapes (a dark cylinder, a lit top with a rim, the ring in
  the crate's colour, lamps evenly round its side), never a picture with uneven studs. The stage's nameplates and "+"
  bubbles hide while a full-screen window covers the lobby (Lobby's `Stage.SetLabelsShown`). The lobby's bottom bar keeps
  PUBLIC MATCHES a fixed gap left of the buttons on any screen shape (MatchBoard's `BottomBar`), its cards a gap apart.
- **The match setups take the whole screen** (the owner, 2026-11-25: "lets remove Local and Custom buttons... one small
  square button with game settings gear", then "hide other uis, center it and make the background darker... make it
  looks good and consistent"): the board's gear tile (the Loadout's EMOTES tile with the top bar's settings gear in the
  glyphs' look) opens PLAY WITH FRIENDS (`FriendsMatch`, LOCAL and CUSTOM as two big buttons, each with a line saying
  what it is), and it, the custom lobby and the solo, party and local setup all open the same way: the lobby's guis and
  the stage's labels hidden (Lobby's `FULL_SCREEN_WIDGETS`), the window in the middle of the screen, and a darker dim
  behind it (WidgetManager's `WidgetManager_Dim` on `U_Widget`, 0.3 against the usual 0.5). A new setup window does
  the same. **PLAY SOLO picks only the difficulty** (the owner, 2026-11-25: "select random map and also we only
  have difficulty choice"): three cards in the map card's look, each with its glyph (a smile, a frown, a skull:
  MatchBoard's `DIFFICULTY_ICONS`), the win reward and PLAY; a solo match always plays a random rotation map. A party
  and local play keep the map list and bot buttons.
- **Text on a card never sits on its picture** (the owner, 2026-11-15, on the loadout: "the texts are not
  readable"): the picture keeps the middle, the texts take the corners and a band along the bottom, every one in the
  heavy font with a black `UIStroke` (the label weight, 0.07, since 2026-11-24), on one line (a long name shrinks rather than wrap).
  The loadout's slot cards are the pattern: number top left, copies top right, the name under the picture.
- **A text and its picture centred as one** (a price and its coin, 2026-11-17) is a centred label as wide as its
  place, the picture placed by code from `TextBounds` (Loadout's `_centrePrice`): an AutomaticSize X label measures at
  its TextSize and doesn't grow with screen-fraction layouts.
- **Capitals stay capitals:** text in a capitals style (headings, titles, buttons, window and box titles) shows in
  capitals whatever code writes, through the `TextCase_Upper` tag the theme adds and the TextCase module (Utils). Code
  writes plain sentences ("You play in 3 turns"), never its own `string.upper`. A gui whose code writes into
  capitals text is exported again when the theme's capitals change, so its export carries the tag.

## Maps and placeholders

- **Two places, one file, two maps:** the lobby place (players join it) and the match place, Arena (matches run in
  its reserved servers), are copies of the same place file, saved and published together, so Roblox's analytics
  count the lobby and the matches apart. Each boots its own map, `Lobby` or `Match`, by its place id
  (`core/.../configs/place_loader.lua`: `LOBBY_PLACE_ID`, `MATCH_PLACE_ID`; MatchBoard teleports to the config's
  `MatchPlaceId`). Each map loads the `Default` folders (shared by both) plus its own, and its module list leaves out
  the other map's modules (`MATCH_ONLY`, `LOBBY_ONLY`), so a module that runs on both never reads the other map's
  modules or settings unguarded (Atmosphere's wind read Match's `WIND_MAX` in the lobby, 2026-11-15), and a module of
  one map never reads the other's at all: what it needs from there is a copy in its own settings, or travels in the
  match's metadata (2026-11-24: MatchBoard read Match's `WAITING_SECONDS` and the waiting room MatchBoard's `MAPS`,
  which broke every public Join and waiting room live, while Studio's map, which loads both, played fine).
- **Built in the dev experience, published to the main one** (the owner, 2026-11-15): the same place file runs in
  both, and the place loader's `EXPERIENCES` picks the lobby and match place ids by universe (`game.GameId`): the main
  game (10774518479: lobby 83410278033601, Arena 118265066788984) and the dev copy (10776882453: [DEV] Snail Lobby
  82550122321970, [DEV] Snail Arena 75433175788458). A file in neither plays as the main game. Each experience has its
  own DataStores; products and passes, and group pictures with restricted permissions, are the main game's.
- **Live servers keep the players' saves; Studio has its own stores** (the owner, 2026-11-15: "so no-one will lose
  their data"): ume's `IsProductionReady` is on (`core/game_instance/Start/configs/general.lua`), and outside Studio,
  in both experiences, the start task renames the store names to `UmeTesting_-1` (`tasks/config.lua`, ume's
  `Production` changed by the game), the name every player's save has been under since the game went live: profiles
  `PlayerProfile_<userId>_<namespace>_UmeTesting_-1` in the `PlayerProfiles` DataStore, leaderboards ending in
  `_UmeTesting_-1`. Studio uses the place loader's `UmeTesting_-2` (`configs/place_loader.lua`), so tests never touch
  live saves. Never point live servers at a new store name: every player would start over. Framework files changed by
  the game: set all three again whenever a newer ume replaces `core/`.
- **Every teleport between the places shows the card:** the server names the destination
  (`I.Transition.SetDestination`) right before a teleport, the `TeleportGui` card comes over the screen and Roblox
  carries it through the teleport; the next server's ReplicatedFirst script (`src/replicated_first/`, the code
  folder's only mount there) keeps it up until the player's client started, then reveals the map. The place's own
  `LoadingScreen` plays only on joins from the website. **The card is the destination map's own scene** (the owner,
  2026-11-25: "each map you join is different… needs to be really seamless… not that much grey screen"): its
  Atmosphere `Sky` and `Parallax` rows drawn as gui layers through the match camera's numbers (`TransitionMotion` in
  `src/replicated_first/`, shared by both sides), so they slide at true depth speeds; a map adds only its accent
  colour and weather (Transition's `LOOKS`), and a new map's card comes from its Atmosphere row. Layer tiles repeat end
  to end (the owner spotted a gap when the camera ran past them). The scene whips in, sways while it loads, whips
  through the rotation while a Join finds its match, holds through the teleport (Roblox gets a fresh settled copy
  every half second) and flies through into the map on arrival. Its clock and progress ride in its attributes, so the
  copy carries on where it was. The title stands on the scene and only a slim bar runs along the bottom, its top edge
  the progress line (the owner, on a plate under the title: "too much grey on the screen"). **The card writes its own capitals** (`string.upper`), an exception to "Capitals stay
  capitals": Roblox carries it to the next server before TextCase runs there, which flipped its case mid-teleport. `I.TeleportToServer` (a Join into an open public match, a rejoin) sets
  only the `TeleportOptions` property it's given, a job id or an access code (2026-11-16: Roblox refuses nil on the
  other, so every such teleport failed): a framework file changed by the game (`tasks/place_loader/Teleport.lua`), set
  again when a newer ume replaces `core/`.
- **Studio plays the `Studio` map:** both maps' folders and modules on one server, the quick way to test a match. The
  Workspace attribute `Ume_StudioMapId = "Lobby"` tests the real trip instead: the lobby teleports to the match place,
  which a Studio test runs as last saved to Roblox, so save both places first. The map and match ride in the
  teleport's data there, since a Studio test gives reserved servers no id (ume's place loader reads it only in
  Studio); `"Match"` tests the match map alone. On the Studio map the lobby hands each match to `I.Match.Host`, and
  the `InMatch` Player attribute says which half a player is in: every screen, camera and hint that belongs to one
  half follows it instead of assuming its map. A playtest skips the whole tutorial (its match and the loadout steps)
  and opens on the lobby; the Workspace attribute `StudioTutorial` (true) plays it. Studio saves to its own store
  (`UmeTesting_-2`), and a skip saves the tutorial as done there, so a tester who played with it off has to have their
  profile's `Tutorial` flags (`MatchDone`, `CrateOpened`, `Done`) set back to false to see it again (2026-11-24). A custom lobby picks its bots (Off to
  Nightmare) and its owner may start it alone with bots; without bots it needs 2 or more players, and Start alone
  shows "You can't start a custom lobby by yourself", a WidgetManager message (the owner, 2026-11-13).
- **Only the rotation's maps play outside custom lobbies** (the owner, 2026-11-15): new public matches, Solo and Party pick
  from MatchBoard's `MAP_POOL` by each map's `Sizes`; the other built maps stay in the game for custom lobbies only
  (`CUSTOM_MAP_POOL`). Taking a map out of rotation never removes it. **Three maps only while the maps are tested**
  (the owner, 2026-11-25: "we are keeping only 3 maps in game for now"): Echo Caverns (now a snowy mountain), Desert
  and Rolling Plains, in both pools; the rest stay built, in neither.
- **The Workspace holds only the game:** `Ume` (spawn, asset folders, `Env`; the spawn, `Ume.BaseSpawn` at 0, 0.5, 0 under every map, and its decal are tagged `HideOnPlay`, since it showed through the new Desert's lava: the owner, 2026-11-15) and Roblox's own.
  Scratch and unused things go in `ServerStorage.!dump`. **MapLab's workbench stays out of the place** (the owner,
  2026-11-25: `_Labs`, its old map versions in all, was 90 % of the Workspace's parts, and every server loaded it):
  it lives in the owner's saved `_Labs` file, put back in Studio to build a map and taken out again before the place
  is saved. The template's baseplate (`Workspace.Ume.Env.Baseplate`)
  stays for building, but `Env` is tagged `Utils_MoveChildTo` (to ServerStorage), so the server moves it out when
  the game starts: nothing in play stands on it (avatars are parked anchored, the lobby's stage has its own ground).
- **Item ids are saved, so a renamed item keeps its id:** the Baseball bat became the Golf club on 2026-11-12 (its
  name, model, icon), and its id stays `BaseballBat` in the Inventory and Arsenal rows, so saved inventories and
  loadouts still find it. **A cut item is disabled, never deleted** (the owner, 2026-11-25): its row's
  `Disabled = true` keeps it out of the loadout picker for players who don't own it, and no crate's `Odds` names it;
  players who own it keep, equip and use it. Disabled since that day: Black Hole Grenade, Dynamite, Minigun, One
  Punch, Spartan Spear, Parachute, Speed Potion and Low Gravity Potion.
- **The game never asks players to favourite it** (the owner, 2026-11-15: "remove the favorite pop-up showing in the
  game entirely, even after purchase"): the template's Favorite_Controller is off on every map (the place loader's
  `ALWAYS_OFF`).
- **Developer products and game passes are real** since 2026-11-13: the owner had them created on the Creator Hub,
  and their ids are in `src/global_data/Marketplace/`. Robux prices live only on the Creator Hub (Managed pricing off).
  **A Robux price is the number alone, beside a Robux picture** (the owner, 2026-11-15: "the prices are displayed
  incorrectly, the text on prices is too small"): read it with `GetProductPrice(…, false)`, never with the `\u{E002}`
  glyph (the game's font draws it as a small ring, and the extra character wrapped "199" onto two lines), and show
  Roblox's own icon, `rbxasset://textures/ui/common/robux@3x.png`, in an ImageLabel beside it, the row as tall as
  its button.
- **Diamonds are the one currency** (the owner, 2026-11-25: "we remove the coins… keep one currency - diamonds"):
  earned in matches and the tutorial, sold for Robux, spent on crates, emotes and loadout slots. Every coin amount
  became half as many diamonds (the crates' rate, 100 coins or 50 diamonds; halves rounded up), and each player's
  saved coins turn into diamonds once, at that rate, as their data loads (Currency's `CONVERSIONS`): an exception to
  `ume/classes.md` → Profile data, since the owner asked that no one lose what they earned. Saved keys named for coins
  keep their names (Loadout's `CoinSlots`, the `DoubleCoins` pass id, now Double Diamonds).
- **The diamond is the studio's picture** (2026-11-15, the game home's `assets/ui/icons/shop/`), the same everywhere:
  Currency's `IconId`, the themes' `wb-diamond`, and every gui and setting that draws one. A new picture replaces every
  copy in the same change.
- **Placeholders until the owner provides the real thing:** weapon
  projectiles and effects are made in code, the skins without a snail of their own (FBI Agent, Prisoner, VIP, Wizard)
  have no pieces until their art exists. **Nothing that isn't in the game is granted** (the owner, 2026-11-25: "if
  we're missing something and it's not in the game don't grant it"): no level gives those skins now (Progression's
  `LEVEL_REWARDS` is empty), and once they're made the players past their levels get them then; VIP still gives its own. Each such spot has a `shortcut:` comment or a README line saying it's a placeholder.
  Never create products, passes or models on the owner's behalf.
- **Sounds are the classic 2005-2009 Roblox soundscape, the studio's own, played by name** (the owner's pick,
  2026-11-10, replacing 2026-11-08's free Creator Store ids: "use the roblox 2005 soundscape... Great Strategy is the
  vibe"): every id lives once in `src/global_data/Sound/SoundsList.lua` under its name (`Fire_<itemId>`,
  `Use_<itemId>`, `Explosion_*`, `Snail_*`, `Turn_*`, `Match_*`, `Music_<MapId>`), and code plays the name (match
  sounds in `SFX`, the interface's in `UI`, music in `Music`). They come from the repo's sound kit (`art/sfx`):
  Roblox's own 2009 sounds played straight from their ids, sounds built from them, and calls and music played on the
  classic Roblox tracker samples. The owner hears them in the kit's preview first; only approved ones are uploaded,
  to The Snail Studio group through Open Cloud, under plain titles ("Snail Turn Bugle": no weapon words, no other
  game's names), as the kit's README → Uploading says. Sounds in the world play where they happen within Combat's
  `SOUND_ROLLOFF_MIN`/`MAX` (the camera sits 45 to 200 studs away, past Roblox's default 100-stud fade); turn and
  result sounds are 2D. A new weapon or utility gets its `Fire_` or `Use_` row in the same change, a classic id until
  the kit has its own.
- **The music is a level stream, as Worms Armageddon's** (the owner's pick, 2026-11-10): each map's track is its
  ambience and a light song that sounds like the place, mixed as one, mostly one instrument at a time playing a bit of
  the tune; its sudden-death version is faster and driving, and Rockslide Ridge stays epic all through (the owner:
  "keep it as it is"). The lobby plays the game's signature tune, barely there, over a meadow. Atmosphere's moods pick
  the track (`Music`, `SuddenDeathMusic`) and BGM_Controller crossfades them; no separate ambient sound plays.
- **Panels scale with the screen in position and size:** every game gui's panels are laid out for a 1920 × 1080
  screen. Their positions are screen fractions (`UDim2.fromScale`, never pixel offsets, which don't scale), and their
  size is an `S_ScreenScale` UIScale the ScreenScale module (Utils) sets: by height, by width on a screen narrower
  than 16:9, bigger on short phones, and never under 0.6 on PC and console (`MIN_SCALE`), even where the width would
  make it smaller, so text on a 1024 × 768 screen stays readable. Panels side by side are placed to fit at that floor.
  A new gui joins its `GUIS` list instead of scaling itself. A button or tile
  placed on the screen by itself gets its own `S_ScreenScale` (the kit's `Screen` param: the touch buttons, the emote
  button).
- **World labels scale with the screen too:** a billboard over the world (SnailTag, DropMarker, DamagePop) lays its root
  out at its design size with an `S_ScreenScale`, and the code that clones it hands it to
  `I.ScreenScale.AddBillboard`, which sets that scale and the billboard's size to the root's times it (no device
  scale). Never a fixed pixel billboard: on a phone it covers half the screen. The lobby stage's nameplates and "+"
  bubbles are sized in studs instead (2026-11-24), so they scale with the stage, as its snails do. Its template lives with its module's
  assets, not in StarterGui (where Studio draws it at 0, 0, 0): `ReplicatedStorage_Assets/<Module>/PREFAB | <Gui>`, a
  Model with an invisible 1 × 1 × 1 `RootPart`, its `Attachment`, and the BillboardGui named `U_<Gui>`, which code
  clones alone and names `<Gui>`. Narrows `ume/place.md` (holder parts): the holder is the `PREFAB`, the gui `U_`.
- **Device sizes come from ume's platform tags:** a panel that differs per device carries `Utils_PlatformScale` (or
  `Utils_PlatformSize`), and ScreenScale multiplies the screen's scale by the device scale the tag keeps on the
  UIScale (`Utils_BaseScale`). No module or attribute of the game's own does per-device sizing. The GUI kit tags its
  panels 0.75 on Desktop, since it's drawn for phones.
- **Panels hang from a screen edge or corner** (the lobby's Party on the left, Loadout on the right, the public
  matches along the bottom with PLAY SOLO and the gear tile at the bottom right, the STYLE, WEAPONS and SKINS menu and the
  currency at the top right), so a per-device size
  (`Utils_PlatformSize`) never needs a per-device position. On phones and tablets a panel too big for the screen gets a Mobile size, its list scrolling, and a Mobile scale under 1 only when
  its content needs the room; a heading that costs a phone too much hides there (`Utils_HideOnPlatform`).
  **The match HUD sits below Roblox's top bar on phones and tablets** (the owner, 2026-11-13: the bar covered the
  left team panel and the turn and wind), **and reaches the screen's edges** (the owner, 2026-11-25, on a phone where
  the safe area's notch sides boxed the whole HUD in: "we need it to be on the edges"): its ScreenGui ignores the
  safe area (`ScreenInsets` `None`, consoles keep `DeviceSafeInsets`) and MatchHud pads only its top by the top
  bar's height on Mobile (`U_Inset`), so the whole screen lays out under the bar, never a per-device position.
- **The top bar's buttons are icons** (the owner, 2026-11-13): the Settings gear, the music button (notes, crossed out
  while muted) in the lobby and in matches, then Leave game in matches, white glyphs from the repo's `art/topbar` kit.
- **Counts stay on one line:** a currency count gets the width of its longest text, and amounts from 10,000 up are
  written short by the slot (`Currency_ShortFrom`: "18.62k"), so a count never wraps.
- **The lobby is a party stage, as Fortnite's** (the owner's pick, 2026-11-09, replacing the bot match behind the
  guis): each client clones the stage prefab (`ReplicatedStorage_Assets/Lobby/PREFAB | Stage`, built by hand where it
  stands, beyond the baseplate; since 2026-11-12 the studio's meadow, `Spawn_New`, and since 2026-11-15 the owner's `NewSpawn` (the same meadow, the back pod the fourth player's, raised over the front one so its snail shows over the front snail's head: the owner, 2026-11-15), its four pods; its parts are SmoothPlastic, since this place's `2022 Stud` variants are) and holds the camera on its `Camera` marker, low and close; the player's snail
  stands on the front pod (`Pod_1`) in their equipped skin, 1.9 times its match size (Lobby's `STAGE_SNAIL_SCALE`: 1.5, the owner, 2026-11-15; 1.9 on 2026-11-24, "the snails are a bit bigger, near each other"), and their party in this server on the pods around it in
  theirs (Lobby's `Stage` handler, from the `PartyId` and `EquippedSkin` Player attributes). Each client stands its
  own snails, so everyone is in front on their own screen; the pods are parts in the prefab, so the layout is moved
  in Studio. **The stage is a calm background, Fortnite's way** (the owner, 2026-11-24: "the rest is just a
  background"): small pads (the player's front pad glowing cyan with a light, the free ones smaller, darker and faded),
  the camera low and flat, the meadow cleared of its decorations, lanterns, fences, hedges, path, waterfall, clouds and
  brick cliffs, with stepped Lego hills behind it (its `Backdrop`) and a tree framing each side, so the snails carry
  the colour. Nothing on the stage competes with them; what was taken out is in `ServerStorage.!dump`. **Names and
  levels stand over the snails** (2026-11-24): each stage snail wears the studio's nameplate (its level in a badge, the
  display name over the @username, the party's smaller than the player's own: Lobby's `NAMEPLATE_*`), never the party
  cards or a plate at the top; each free pod floats a faded "+" bubble, a small copy of the party column's + card
  (the owner: "like this but even more realistic and faded and smaller"), that opens the invite. The
  screen is the studio's `LobbyInventory` (2026-11-09), its board the studio's `LobbyRework` since 2026-11-24: Party, the Loadout slots, the STYLE / WEAPONS / SKINS menu,
  PUBLIC MATCHES (a scrolling row of cards, one per public mode) and PLAY SOLO (**Play with party** in a party) with
  a square gear tile over it (since 2026-11-25, in LOCAL's and CUSTOM's place), each button, card and setup title with its mode icon; no logo and no welcome line. **The Loadout is a column two cards wide** hanging from the right edge under
  the menu, its LOADOUT and EMOTES headings right-aligned, EMOTES right under the last row of cards shown, and
  **EMOTES is one button with Wave's icon** that opens the EMOTES panel
  (`EmoteShop`, its right edge on the column's), where an owned emote plays when pressed (the owner, 2026-11-15). **A lobby card is the map's picture with its match on it** (the owner, 2026-11-15: "make the image much much bigger, in the background fading out to the right, but keep it readable"):
  the map's picture over the whole card (cut to its slanted frame), fading out before Join, the mode big with its icon, and a band with the map's name;
  since 2026-11-24 the board is the studio's `LobbyRework` and the card shows the players seated in its mode's filling
  match on every server again ("it updates every 3 seconds or so, 40/60, 20/50", MatchBoard's `CARD_REFRESH_SECONDS`,
  undoing 2026-11-15's "hide how many players are playing"), and the timer at the top right counts down to that match's
  start, or to the card's next map while none fills (the owner, 2026-11-16: "show the timer back"). Three cards:
  Deathmatch, Duo and Trio (the owner, 2026-11-24: "we want only 3 segments"). A design's outline picture cut off at
  its edges is drawn again as the fill picture in ink, eight copies nudged 3 design pixels round it, never a stretched
  copy; and every ported node gets an explicit `LayoutOrder`, since UmeGui renumbers the ones without. The solo, party or local setup takes the board's place, whose lobby rows and buttons slide down off the screen for
  it and back after (MatchBoard's `PLAY_*` settings, the owner's pick, 2026-11-12). Since 2026-11-17 it's the custom
  lobby's window (the owner: "make it look good… consistent with our guis", after a PlaySolo panel with a map strip
  over it overlapped): its art, map cards (Random, then the rotation's maps for the match's size), player and bot
  buttons and START, centred under the top bar as the custom lobby's window is, clear of the top-right menu; custom
  lobbies open in that window too. **Every lobby window is a WidgetManager widget, so it blurs and dims the stage
  behind it** (the owner, 2026-11-17: the custom lobby "makes the screen fade and blur, but the local one does not"):
  the solo, party and local setup is its own widget, `MatchSetup`, never a frame inside the board's gui. **A window
  hides the lobby pieces it would overlap** (the owner, 2026-11-17: "the guis are overlapping when we click weapon
  selection - make sure they hide"): Crates, Skins and Shop cover the screen, so every lobby gui hides
  (`FULL_SCREEN_WIDGETS`); a window in a panel's place hides that panel, and the weapon picker's tall window hides the
  top row (the menu with FREE WEAPONS, the diamonds) and the board, keeping Party and the Loadout column
  (`PANEL_WIDGETS`); the free crate's dialog (`FreeCrateDialog`) is a widget too and does the same. A new lobby window
  gets its row there. The FREE CRATE badge makes way while a crate opens on the
  crates screen (Crates' `GroupReward.SetOpening`). **A custom lobby stands on eight pods** (the owner, 2026-11-16):
  while the player is in one, the stage swaps its pods for `PREFAB | CustomPods` (three in front, two raised behind
  them, three higher at the back, packed close), stands the lobby's members on them and backs the camera off until
  they all fit (Lobby's `STAGE_FIT_MARGIN`, `STAGE_CAMERA_EASE`); the Party column lists the lobby then (its members,
  the owner's crown, + cards up to its size that open CustomLobby; from 5 cards a second column, and
  the size picked on the create step shows before the lobby exists: 2026-11-17), and the lobby's member list ends in
  open slots. The custom lobby's window takes the stage like the solo setup: the board slides away and the loadout
  hides while it shows, and player counts the picked map isn't made for fade out (the server refuses them too).
  **Every stage snail holds the Bazooka and strikes a pose** (the owner, 2026-11-16: "make it feel organic and
  natural"): one of Lobby's `STAGE_POSES` at random, never the one it had, picked again when the members change or the
  player comes back from a match; a pose without an uploaded id is skipped. **The stage camera never swoops in**
  (the owner, 2026-11-17: "the camera at first tweaks, like it comes from somewhere else"): it's set on its marker at
  once and eases only toward a new framing, from where it was held (Lobby's `Stage`), never from the live camera,
  which Roblox moves as the avatar loads.
- **Public matches are global** (the owner, 2026-11-15, replacing the per-server rows and timers of 2026-11-09):
  each public mode has one card, and Join sends the player and their party here straight to a match server.
  **Each mode fills one match at a time, its frontier** (2026-11-24, after two players pressing JOIN a few seconds
  apart each got an empty match of their own): one MemoryStore key per mode (Matchmaking's `Frontier` map) names the
  match every lobby's card shows and every Join seats players in. When it's full, closed or gone, the lobby opens the
  next match in the store first (pending: its server isn't up yet), then takes the frontier for it in one
  `UpdateAsync`, only while the frontier still holds what it found; the lobby that loses closes its own and joins the
  winner's. A group seated in a pending match waits for its server's `AccessCode` ("Match found! Joining...") before
  it teleports. Never open a public match the store doesn't know about yet. **Each card's map is the same on every
  server for 30 seconds** (the owner, 2026-11-16: "when I click on join it changes the map, the map should stay
  globally for 30s"): MatchBoard's `Rotation` works it out from the server clock (`MAP_SECONDS`, a shuffle of the
  rotation per mode), so no server stores it and a Join never moves it; a new match opens on that map, and while a
  match fills the card shows that match's map. The open matches live in MemoryStore (the Matchmaking module), and
  **no match may ever hold more players than its size**: every seat is claimed in one `UpdateAsync`, which checks the
  room and takes the seats in the same step, and the match server closes its entry the same way, so the roster it
  closes with is final; it also sends back anyone who arrives without a seat. Never write a match's seats with
  `SetAsync` or from a value read earlier. **The waiting room is on the match server** (Match's `WaitingRoom`, the
  `MatchWaiting` gui at the bottom middle): 30 seconds for others to join (the owner, 2026-11-24, so more real players
  find it before bots fill it; Match's and MatchBoard's `WAITING_SECONDS`, or the start the lobby that opened it
  promised, at least 8 seconds once the server is up), until everyone there pressed Ready, or 4 seconds after its last
  seat is taken (Match's `FULL_START_SECONDS`, 2026-11-24), then bots fill every empty seat (one player can play Trios). A party can also play alone (friends only): with bots it
  pays like a public match, without bots half (MatchRewards' `PARTY_NO_BOTS_SHARE`).
- **Every match starts with all its snails** (the owner, 2026-11-15: "if someone hasn't loaded yet because of a bad
  device, bot will play for him"): a seated player who hasn't arrived or loaded is seated from the card their lobby
  made (Matchmaking's `GetCard`: name, loadout, outfit), and a bot plays their snail, as for a dropped player, until
  their data has loaded; they're never out for arriving late.
- **The drop always runs its whole 15 seconds** (the owner, 2026-11-15, Match's `DROP_SECONDS`): placing doesn't end
  it, so players can move their spot until the time is up. Only the tutorial's ends once its player placed. **A solo
  match's drop is 7 seconds** (the owner, 2026-11-25: "since we playing with bots we dont need to wait for anyone",
  Match's `SOLO_DROP_SECONDS`).
- **A party's leader picks the match** (2026-11-10): members see Join, Play solo and Custom greyed out (MatchBoard's
  `LOCKED_*`), and the server refuses their joins and lobbies. A custom lobby the leader makes takes the whole party
  in at once, and a party shares a team where it fits; a party bigger than a public match's team (three in Duos) joins
  it all the same, if the match has a seat for each, and spills onto the next team with room (the testers, 2026-11-13).
- **Local play is friends on one screen** (the owner, 2026-11-17: "he is sitting with his friends at his home"): the
  lobby's LOCAL button (in PLAY WITH FRIENDS since 2026-11-25) opens the setup in its local form (2 to 8 players, bots, the map). Each local player is a guest
  snail of the host's (`P_<hostId>_<n>`, the host's `UserId`, "Player n"), played from the host's screen with one
  controller passed round; before each local turn the HUD's turn callout names whose it is, in their snail's colour,
  and holds until a press (Match's `HandOff`, named before the turn shows so nothing else pops over it; the turn's
  timer hides meanwhile). Which snail a player plays is asked, never assumed: `I.Match.GetControlledId(player)` on the
  server and `I.Match.GetMyParticipantId()` / `I.Snails.GetMine()` on the client follow the active one, so every
  request about "my snail" goes through them. Local matches pay nothing and count toward no statistic. One pad each
  waits for a check that a second pad shows up as its own on Xbox.
- **Check guis shown together for overlaps** before calling a layout done: PC sizes from 1024 × 768 to 3840 × 2160,
  tablets, and phones down to 667 × 375.

## Server and client

- **Clients get only the code and values they run** (the owner, 2026-11-09: "people cannot look into our sensitive
  code"). Everything outside ume's hidden names replicates to every player, and ume loads every module's
  `Settings.lua` on clients too, even a server-only module's. So server-only values live in files whose names ume's
  hiding catches (`ume/structure.md` → Hidden server code): a server-only module's settings are its
  `ServerSettings.lua` and its data `ServerData/` (Bots, MatchRewards, Progression); a module both sides run splits
  its server-only keys into `ServerSettings.lua` beside `Settings.lua` (Combat's aim guide solver, SnailControl's
  checks). Code requires them by name (`FindFirstChild("ServerSettings")`), and `I.Settings` doesn't hold them.
  Overrides `ume/settings.md` (a module's settings are `Settings.lua`) for these files.
- **Anything that would help a cheater runs on the server:** the bots' brain and genomes, the aim solver
  (`I.Combat.GetArcs`, `PredictArc`), whose admin aimbot the server solves (with the bots' prediction) and sends to
  that player alone (`Combat_AimbotTargets`: only which snails they can hit), and the movement checks' margins. What clients need to draw (shot flight, launch speeds,
  Arsenal rows) stays shared. A client check of a Player attribute is never a gate: the server decides what it sends.
- **A match place server plays only a match a lobby sent it:** one with no metadata outside Studio (a public server
  joined directly) plays nothing and sends everyone to the lobby (Match's `Connection.IsStray`).

## Loading

- **A client's Init and Start never wait on other players,** or on anything the server makes once a player has
  loaded (their data, Replicator folders, `I.G_Player.OnPlayerAdded` instances). The server loads a player's data
  only after their client has finished starting every module, so such a wait holds up the load of everyone who joins
  together. Wait on a thread of its own (`task.spawn`), or in `I.OnLoaded`.
- **Every asset loads in the background from the start** (the owner, 2026-11-13: "when player opens new guis, or
  opens weapon cases… he gets the background and icons/models instantly"): the client's `AssetsPreload` module
  (`Main/0_AssetsPreload`) preloads every gui, the asset ids in the game's data and settings, and the asset folder, on
  a thread of its own. A new gui, data row with an icon, or asset folder is picked up with no change there; a picture
  code builds from anything else (a string it puts together, a player's thumbnail) isn't.
- **Clients wait until the framework has fully arrived, on live servers too** (the owner, 2026-11-15, after matches
  sometimes started with no camera): a match server is fresh, so players join while it's still starting and the
  framework's module tree reaches them in pieces. The replication gate (`core/game_instance/Start/tasks/replication_gate.lua`)
  holds the client until everything in the server's manifest has arrived (extras allowed: remotes made later), up to
  60 s, then kicks. A framework file changed by the game: overrides ume's Studio-only gate until ume takes it in.
