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
  one that collides and that queries see.
- **Cut-loose ground falls by the game's own gravity, locked to the plane** (the owner's pick, 2026-11-09, so players
  can build bridges): never Roblox physics. A loose group drops straight down without turning to where it first
  touches the terrain (lowest group first), or out of the arena, and stays there anchored; the server moves it and
  each client draws the same fall on its own frames (`Arena_Fall`).
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
  falls fades out. **Props stand behind the snails** (the testers and the owner, 2026-11-13: snails hid inside trees
  and rocks): at load each moves back until its front is half a snail's length behind the plane, its pivot still on
  the ground, and one too deep for that is flattened along Z, which the camera along −Z barely sees (Arena's
  `PROP_BEHIND_GAP`).
- **Maps are made in MapLab** (the game home's map kit, `assets/_tools/map-kit/`): the land drawn on the 1-stud grid
  and built into parts, props part-built, checked, then exported into the arena templates after the owner approves.
  A map the owner builds in Studio is imported where it stands (Rockslide Ridge): its parts renamed by look, in
  SmoothPlastic with `2022 Stud`, sorted into islands, ledges and backdrop, with its own markers.
- **Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`** (Terrain, Decor, Markers), their
  play plane (Bounds) at Z = 0, side by side along +X in 400-stud slots (MapLab's: X = (slot − 1) × 400) so none
  overlaps another, and cached by the Arena module at start. **Every map plays at X 0**, by the spawn: the Loader
  moves each template's Bounds there when it caches it (the owner, 2026-11-12: Volcano Isle, at X 1200, didn't show
  until the snails dropped, since streaming sends a player only what's within `StreamingTargetRadius` (1024) of
  their avatar, parked at the spawn, until their snail is their `ReplicationFocus`). A knockout hands the focus back
  to the parked avatar (Snails' `Health.Kill`): the ghost's ball ended up far below the arena, and with it as the focus
  a player watching on lost the whole map and the camera its bounds (2026-11-12). The drop picker, aims and shots read the plane as Z = 0,
  so a template dragged off it in Studio is put back on it at start, with a warning (Arena's Loader). Nothing starts
  in the bounds' top 20 studs (Arena's `START_TOP_GAP`), so a map's roof is never a spawn, and the liquid is drawn as
  deep as the map's bedrock, measured at load, never the bounds' depth: a map needs neither set by hand. Weapon models are authored in
  `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/` and cached by Arsenal (its README → In the place).
- **Liquids are a stop-motion stud simulation:** water and lava live in a grid of half-stud cells stepped at 8 fps
  and drawn as merged rectangles in `2022 Small Stud`, so they hop like a brick film. They are the only thing in the
  arena on a grid, and the cells stay fine (never one-stud or bigger blocks). The sea is drawn 50 studs past the
  map's sides, up to its level (Arena's `SEA_EDGE_WIDTH`, the owner, 2026-11-12: "not seen as cut out"), so the
  camera never shows where it ends; only drawn, since the grid stops at the sides and out there is out of bounds.
  A map may draw a liquid in Neon instead of the stud look, so it glows (its marker's `Arena_LiquidNeon`): Volcano
  Isle's lava, sea and pools, in 255, 81, 58 (the owner, 2026-11-12: "make lava part neon so it slightly glows").
- **Only the sea knocks snails out** (the owner's pick, 2026-11-08): the liquid whose marker starts at the bounds'
  bottom, raised by sudden death (Arena's `GetHazard`, `SEA_SLACK`), and since 2026-11-10 any liquid of its kind
  joined to it, so a pond the rising sea reaches becomes the sea (Arena's `Liquid.IsSea`, `SEA_MARK_STEPS`). A pond on
  its own, like Desert's oasis, is safe to fall in. **Lava turns the water it touches into obsidian** (2026-11-10), on
  a map holding both: those cells leave the liquid and become terrain parts that blasts cut like any ground (Arena's
  `Obsidian`). It's the one terrain built in code, merged from the liquid's half-stud cells, an exception to "Terrain
  is authored parts". **Shots fly on through any liquid, ponds too, slowed** (the owner's pick, 2026-11-10: "projectiles move
through water but slower"): water and lava never set a shot off; it bursts on what it touches under them, or by its
fuse (Combat's `SINK_*`). Only the spider bomb's crawl ends in liquid.

## Snails

- **A snail's state lives in attributes on its model** (`Health`, `Alive`, `Ghost`, `CanMove`, `Stamina`, `Active`…),
  written by the server and read by every client, so the snail modules need no remotes. Overrides `ume/values.md` →
  where a per-player value lives: snail state belongs to the snail, which bots have too, not to a player.
- **The active snail is moved by its player's client** through network ownership; the server only checks it (its path
  through the terrain, its speed, how high it climbs past a jump with its jetpack fuel, and its stamina) and takes
  the snail back. Anything the server does to a snail (knockback, a knockout) happens while the server owns it.
- **Every snail parachutes in** (the studio's wiki): a player's placed spot, or for bots and players who don't place,
  up to the Match module's `DROP_HEIGHT` over a spot from `I.Arena.GetLandSpots` (on top of the ground on any storey,
  never over liquid), clear of the terrain above it.
- **The snail is the studio's rig, animated on each client** (2026-11-09): the `Classic` skin has bones, hands and a
  `Handle`, and the `SnailRig` library plays its animations (idle, walk, hiding in its shell while it's thrown) from
  how its ball moves (Snails' `Motion`), never from the server. Only the skin's RootPart is welded to the ball. Its
  animations are published to The Snail Studio's group (2026-11-10; the ids are on the place's Animation instances
  under `Assets/Snails/Animations`), so live servers play them once the place with those ids is published. A hit
  snail ducks into its shell at once (Snails' `Motion` hears `Combat_Hit`), the hide sped up by SnailRig's
  `HIDE_PLAY_SPEED`. **A walking snail is never in its shell** (the owner, 2026-11-12, after bots walked hidden):
  the active snail's own jumps and falls don't hide it (Motion reads `Active`, since bots never get `CanMove`), it
  comes out the moment it walks, and the walk stops the shell's `Hide` and `Show` animations.
- **Every skin is a snail on Classic's skeleton** (2026-11-11, the artist's nine): the same bone names and frames,
  scaled 0.45, a skinned `Body` (accessories and Classic's hands in it) and `Shell`, Classic's `Handle`, so Classic's
  animations and SnailRig play on it unchanged (`art/skins`: the rigging, and why the shell is moved back by the
  Idle's offset). The rig's rest pose has the shell floating above the back and the hands held out, so a skin shown
  unanimated (a ViewportFrame) is held in its idle frame with `I.SnailRig.Pose`, never shown at rest.
- **The active snail holds its weapon in its hands, in the weapon's pose** (the row's `HoldPose`: the studio's Gun,
  MiniGun, Bazooka and ShotGun snails; other items in the Gun pose), welded to the rig's `Handle` at the model's
  `Grip`, and always on the camera's side: a snail facing left swaps its hands over. The hands and weapon pitch to the
  aim (up to 90° either way), and a snail standing still turns to face its aim (its player's screen; the server for
  bots), so the weapon never points back through it. A gun plays its pose's shot when it fires. It's drawn by each
  client from the snail's `HeldItem` (Combat's `Held` handler), never welded on the server.
- **Shooting is Worms Armageddon's: point, hold to charge, let go** (the owner's pick, 2026-11-10, replacing the
  2026-11-07 power-by-distance drag). The weapon always points from the snail at the mouse (a finger on touch, the
  right stick on a pad). Holding the mouse button, RT or the HUD's FIRE (touch) fills the power at one even rate,
  none to full in Combat's `CHARGE_SECONDS` (1.3, W:A's measured charge); letting go fires, and a full charge fires
  by itself. Guns, melee weapons and weapons placed at the feet fire on the press. Right click, Esc and the pad's
  `CancelAim` drop a charge. On touch a finger on the arena only points; FIRE shoots. The camera doesn't edge-pan
  while the button is held. The aim draws W:A's way, on the MatchHud gui's aim layer (`U_Aim`, under the rest of the
  HUD) in screen pixels, never as billboards in the world (overlapping billboards at one depth swap their draw order
  and flicker): a cone of circles, yellow through orange to red, blended into one seamless shape (each circle's
  gradient runs the cone's colours along the aim, no outlines: the owner's pick, 2026-11-12), straight along the aim from a fixed start, each growing in
  as the power passes it, then a gap and the crosshair (a ring with an X, spinning, in the aiming snail's `Color`: its
  team's, or its own in a free-for-all). Every length is in units, a stud at MatchCamera's starting distance, so the
  aim looks the same at any zoom (zoomed in, the cone starts past the snail's grown ball). The screen that draws an aim
  turns the held weapon with it at once (no wait for the server's copy). The turn running out never fires.
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
  shot ticks and a hit on their own snail thumps. The chunks of ground a blast throws are physics parts in Arena's
  `Chip` collision group: they bounce on the terrain, never on snails or shots, and fade after `DEBRIS_LIFETIME`.
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
  snails' spawn, landing, healing, splash and trail have theirs (Combat's and Snails' client `Effects`). Missiles and
  the black hole, variety and cluster grenades (their mini bomblets too) draw the studio's trails as they fly (Combat's
  `PROJECTILE_TRAILS`), and a launcher's shot blasts out of it (`LAUNCH_VFX`), and a
  jetpack its jet (Snails' `Trail_Jet`); a trail's attachments stand along Z, toward the camera, so it keeps its width.
- **Each place has its own mood, subtle and in the game's colours** (the owner's pick, 2026-11-10: "subtle, high
  quality, minimalistic but visible… worms type of colors, but in a professional way"): the Atmosphere module sets
  the lobby's or the map's lighting preset (`Lobby`, `Plains`, `Desert`, `Cave`, `Volcano`, in `Lighting.Presets`), a few
  ambient particles that drift with the match's wind, effects on liquid surfaces and a cave's ceiling, and reactions
  to what happens (leaves from blasted trees, splashes, landing dust, steam), all on each client and from Vfx prefabs
  made from the studio's existing emitters. A new map gets a `PROFILES` row (Atmosphere's Settings), and a preset
  of its own when no existing one fits. The match camera looks along −Z from 110 studs, so a map's sun keeps a high
  `GeographicLatitude` (its light comes from the camera's side); the lobby's stage camera looks along +Z, so its
  latitude is negative. Saturation stays well under the old 1.0 (0.2 to 0.35), and an effect seen on bright ground
  blends normally (`LightEmission` 0): additive smoke vanishes on sand.
- **The match camera shows every shot to its end** (the owner, 2026-11-10: "make sure all is shown, the camera
  works and is not confusing"): with the player's `CameraFollowsShot` on, it flies with a shot (led a little), glides
  to where a gun's bullets or a swing landed, follows a snail a blow sent flying or that fell, and holds on what
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
  replicated parts.
- **Shots fly in slow motion** (the tester's notes, 2026-11-08): the simulation runs at Combat's
  `PROJECTILE_TIME_SCALE` (0.5, half speed) along the same paths, so eyes can follow a shot. A thrown bomb's `Fuse`
  counts its own slowed flight time, so it bursts where it did at full speed; a placed one's (Dynamite) stays in real
  seconds. Anything that steps a shot (bots' predictions too) counts flight in the shot's own time.
- **Strong weapons start on their cooldown** (2026-11-08): a weapon with a `Cooldown` waits that many of the player's
  own turns before its first use too (Combat's `Uses.Reset`, mirrored in the bots' `Sim`), so nobody opens a match
  with the strongest weapons. Admin `give` and `refill` clear it, for testing. **Heals wait between uses** (the owner,
  2026-11-12): a utility's `Cooldown` starts at its first use, so it's ready on the first turn; the Bandage (40)
  waits 3 turns, once every 4 of the player's turns, and the Medkit (100) 5, once every 6, with 2 uses a match.
- **Server-moved shots glide on clients:** the spider bomb's crawl moves as a server part after landing; clients draw their models gliding after them (Combat's `CRAWL_GLIDE`), and the spider bomb walks
  up 1-stud steps rather than jumping them. Their throws fly on `Ballistics` like every other shot. Flying shots are
  drawn `PROJECTILE_DRAW_SCALE` (2) times their size, hits unchanged.
- **Every thrown shot flies like the rocket** (the testers, 2026-11-13: "same physic weight as rocket"): every Arc and
  Target weapon launches at the Bazooka's speeds (`MinSpeed` 20 to `MaxSpeed` 180, up from 150 for more power) and
  feels the wind, which pushes `WIND_ACCEL` (7) studs/s² per point, and each point harder the stronger the wind
  (`WIND_ACCEL_GROWTH`, the owner, 2026-11-13: "on wind 6… the projectile will get swept by the wind in another
  direction"): a shot into the wind lands visibly short, and in strong wind a steep shot is blown back over the
  shooter's head (at 6, steeper than about 64°). The
  wind stays for a whole round: Match rolls it again only once every snail in play has played on it, and a change
  gusts across the screen (Atmosphere's `WIND_CHANGE_BURST`) and flashes the HUD's number.
- **Teammates are never hurt by each other** (the testers, 2026-11-13): Combat's `Blast.Hit` skips a snail on the
  shooter's team (not the shooter: your own blows always hurt you), and an open black hole doesn't pull them.
- **The black hole grenade is thrown, and opens on a second press** (the testers, 2026-11-13): it opens on the first
  thing it touches, or wherever it is when its owner presses again, holds still for its `HoleTime` pulling snails in,
  then bursts. The variety grenade bursts into four mini variety grenades (its `Bomblets`' `Mini`), no longer worms.
- **Dynamite is placed, not thrown:** it drops at the snail's feet (`Aim = "Feet"`, no launch speed), the stamina bar
  fills again and the player keeps moving for its `Retreat` (3 s) before the server takes the snail back, and the fuse
  (3.5 s) goes off after that.
- **Bots play like players** (2026-11-08): they walk, climb, jump and fly their jetpack with SnailControl's speeds and
  stamina (Bots' `Move`), never step into the sea or down a drop that hurts, walk to a spot their shot lands from,
  close in to swing or place Dynamite and run, and heal when hurt. Their snails stay server-owned. A bot never passes
  a turn (2026-11-10): when its brain finds no plan it still fires the Bazooka toward the nearest enemy (Bots'
  `_fireAnyway`). The tutorial bot is the one exception (below).
- **The tutorial is a guided first match, then the crate** (the testers, 2026-11-13): a new player's first join sends
  them to a 1v1 against a bot that can't shoot (it raises the Bazooka, gives up and passes) and starts with 10 health
  (Bots' `HEALTH`), so any hit wins. The player plays first (Match keeps the roster's order) and starts about 30 studs
  from it near the map's middle (Match's `TUTORIAL_*`): the drop shows where to land, and only a pick there counts.
  The results show Rematch grey and dead, so the player goes back by hand; in the lobby the guide leads to the free
  crate, then to putting its two weapons in the loadout. Its map is Training Meadow, a small island made for it
  (MapLab, exported 2026-11-13), in no rotation.
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
  (`SKILLS`: the hand's error, the wind read, how far it looks, how much it minds the map), never deliberate misses.
  Nightmare is a secret difficulty, offered only in a custom lobby's Bots row (the owner's pick, 2026-11-08). Retraining, and teaching the bots something the game adds (a
  weapon, a map object, a hazard), happens only when the owner asks.
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
  with its head under a liquid that doesn't knock it out (Desert's oasis) loses 5 health (Match's `UNDERWATER_DAMAGE`,
  the head's top `UNDERWATER_HEAD_HEIGHT` over the ball), never going below 1: a pond weakens a snail, and something
  else has to finish it. Only its body under, its head above the surface, does nothing.
- **Getting hurt ends your turn, as in Worms** (the owner, 2026-11-12): while a snail's turn is on and its shot isn't
  away, any loss of health (a fall, a mine, a barrel, leftover fire) ends the turn at once, like its timer running
  out (Match's `Turns`, watching the snail's `Health`). Damage after the shot belongs to the shot's flight.
- **An emote turns the snail to face the camera, and a hit or a shot wins** (the owner, 2026-11-12): while it emotes,
  the snail eases round to face this screen's camera and back after (SnailRig's `FACE_TURN_EASE`, the whole rig
  turned about the ball's upright axis on each client), its held weapon hidden. A snail hidden in its shell (hit or
  thrown) can't emote, and a hit ends an emote at once; the player's screen doesn't send one then, and a screen that
  refuses it shows no bubble. Shooting ends it at once too: on the shooter's screen at the press, on every screen when
  the match enters its Flight (Combat's client `Held`).
- **Potions show on the snail, and on the player's screen on their turn** (the owner, 2026-11-12): a snail under the
  Speed or Low gravity potion streams its `Aura_*` Vfx prefab (cyan sparks, violet bubbles), and on the player's own
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
  `PlaySolo` and `MatchWaiting` (MatchBoard's setup, at the bottom centre, and waiting room, beside Party), `KnockedOut`
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
- **Dialogs in the new look stay simple** (the owner, 2026-11-11, on a confirmation built from the Loadout slot's
  slanted art scaled up, the EMOTES title plate and a red X: "its ugly. dont make it too complicated"): one rounded
  dark panel (fill 25, 25, 35, a dark outer line and the grey 130 line inside, `UIStroke`s scaled by
  `Utils_UIStroke`), white Londrina text, and the design's buttons at about their own size, tinted. A design picture
  made for a small card is never stretched into a big panel: its outline and corners grow with it. The confirmation
  (`WidgetManager_Confirmation`, the game's copy of System's) is the pattern.
- **The tutorial points with a spotlight** (the testers, 2026-11-13: "the screen is blacked out around where you
  need to click and like a lighter square with rounded corners"): the `TutorialHint` gui darkens everything but a
  rounded hole over what to press next (a gui button, the bot, the spot to land on), blocks presses outside it, and
  shows the step's hint in the confirmation dialog's dark panel beside it, worded for the player's device (Tutorial's
  `HINTS`, `TOUCH_HINTS`, `PAD_HINTS`). A new step of the tutorial is a target and a hint, never an arrow of its own.
- **Turns are announced, and the end of a turn tightens** (the owner's pick, 2026-11-10): as a turn starts a dark
  banner opens across the screen with the snail's avatar (its headshot, or the bot picture) and whose turn it is
  (MatchHud's `U_TurnCallout`, the owner: "make it look professional"): "Your turn!" in gold over orange lines for the
  player's own, with a sound and a haptic tap; anyone else's smaller, in white over lines in the snail's team colour,
  with how long until the player's own. The player hears when they're next. In the last seconds of their own turn the timer turns orange, then red, ticks faster and higher, and a
  red band pulses along the screen's sides (MatchHud's `TIMER_*`, `TICK_*`, `TENSION_PULSE_RATE`).
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
  (`Glow`, `Accent`, `Ambient`). **One crate per kind, paid in coins or diamonds** (the testers, 2026-11-13): the Weapon
  crate's diamonds roll what the Premium crate did, and the Premium row stays hidden so its id is known. A crate marked
  `Premium` shows it's premium by small touches (a gold tab, a halo, the violet
  backdrop, a PREMIUM tag, a pale-gold line), never another layout. Gui particles are `I.UIEmitter`'s. The sounds mix
  crisp clicks for the reel with the Great Strategy instruments for the melodies (`art/sfx/make_crates.py`).
- **Models that move in a ViewportFrame sit in a WorldModel inside it** (2026-11-11, measured on the ten-pack: the owner
  asked for it light on performance): moving even one part placed straight in a ViewportFrame redraws every mesh in
  it, about 25 ms a frame for ten crates, while the same crates moving in a WorldModel cost under 1 ms, and moving
  only the camera is nearly free. Code makes the WorldModel beside the viewport's Camera (Crates' stage and pedestal);
  a still model may sit in the ViewportFrame itself.
- **Rolling reels show the snails as pictures** (the owner's pick, 2026-11-11, measured on the crate reels): a model
  costs Roblox 3 to 4 ms the first time its ViewportFrame draws it (again after the viewport is hidden and shown), and
  a viewport that changed while it moved or was hidden isn't drawn until it changes again where it's seen. So a card
  that holds still shows a skin's snail live, posed (Crates' `SkinModels`, which draws a card's snail again once the
  card settles in sight), and a card that rolls shows the snail's picture, rendered in the same pose, framing and light
  (`art/skins` → Pictures) and uploaded only with the owner's approval. A new skin with a snail gets its picture too.
- **The pad goes through the Console module** (the owner's pick, 2026-11-10: "use 0_Console module for all gamepad
  related keybinds"): its `ACTIONS` setting is the one scheme (the module's README → Scheme), modules bind or read pad
  buttons only through `I.Console` (`Bind`, `IsAction`, `IsHeld`), never `Enum.KeyCode.Button*` of their own, and
  keyboard, mouse and touch stay with them. Start is Roblox's menu and never bound; A confirms, B backs out, LB / RB
  step weapons or tabs, RT charges and fires. A gui button a pad presses carries its action's first button as
  `Utils_GamepadKey` and a `Console_Hint` badge naming the action (`Console_Action`; the theme Button's `Hint`), and a
  screen of pad controls a hint strip of the same (MatchHud's `U_PadControls`); a pick list or panel that wants the
  selection asks for it (`I.Console.Focus`). The game's own glyphs (`art/console_glyphs`) stay local until the owner
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
  to play"): over the snail in a match, in its chat stack (`I.ChatBubbles.ShowIcon`), and in the lobby beside the
  player's name on their party card, the tail pointing at the name. Every screen plays the emote on the snail
  (`I.SnailRig.Emote`); until an emote's animation is published under its name, a stand-in motion made in code plays.
  Emote and bot pictures are the game's own drawn art (`art/emotes`, `art/bots`), uploaded to the group (2026-11-11).
- **Badges after a name are the server's, and every one shows** (the owner's pick, 2026-11-10: "if a player has
  multiple, display multiple"): the PlayerBadges server writes the `Badges` Player attribute (owner, developer by
  rank or role name in The Snail Studio's group, since its roles share rank 1, the AdminPanel's admins, Roblox staff, Video Stars, verified, Premium), and every
  name a player's badges belong after (SnailTag, the turn list, Party, Results) has an `S_Badges` frame beside it
  that `I.PlayerBadges.Show` lays out, shrinking the name first. Verified and Premium are Roblox's own glyphs
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
- **Capitals stay capitals:** text in a capitals style (headings, titles, buttons, window and box titles) shows in
  capitals whatever code writes, through the `TextCase_Upper` tag the theme adds and the TextCase module (Utils). Code
  writes plain sentences ("You play in 3 turns"), never its own `string.upper`. A gui whose code writes into
  capitals text is exported again when the theme's capitals change, so its export carries the tag.

## Maps and placeholders

- **Two places, one file, two maps:** the lobby place (players join it) and the match place, Arena (matches run in
  its reserved servers), are copies of the same place file, saved and published together, so Roblox's analytics
  count the lobby and the matches apart. Each boots its own map, `Lobby` or `Match`, by its place id
  (`core/.../configs/place_loader.lua`: `LOBBY_PLACE_ID`, `MATCH_PLACE_ID`, the same id as MatchBoard's
  `MATCH_PLACE_ID`). Each map loads the `Default` folders (shared by both) plus its own, and its module list leaves out
  the other map's modules (`MATCH_ONLY`, `LOBBY_ONLY`).
- **Every teleport between the places shows the card:** the server names the destination
  (`I.Transition.SetDestination`) right before a teleport, the `TeleportGui` card slides over the screen and Roblox
  carries it through the teleport; the next server's ReplicatedFirst script (`src/replicated_first/`, the code
  folder's only mount there) keeps it up until the player's client started, then slides it off. The place's own
  `LoadingScreen` plays only on joins from the website.
- **Studio plays the `Studio` map:** both maps' folders and modules on one server, the quick way to test a match. The
  Workspace attribute `Ume_StudioMapId = "Lobby"` tests the real trip instead: the lobby teleports to the match place,
  which a Studio test runs as last saved to Roblox, so save both places first. The map and match ride in the
  teleport's data there, since a Studio test gives reserved servers no id (ume's place loader reads it only in
  Studio); `"Match"` tests the match map alone. On the Studio map the lobby hands each match to `I.Match.Host`, and
  the `InMatch` Player attribute says which half a player is in: every screen, camera and hint that belongs to one
  half follows it instead of assuming its map. Studio saves nothing, so a playtest skips the whole tutorial (its match,
  the crate and the loadout steps) and opens on the lobby; the Workspace attribute `StudioTutorial` (true) plays it. A custom lobby picks its bots (Off to
  Nightmare) and its owner may start it alone with bots; without bots it needs 2 or more players, and Start alone
  shows "You can't start a custom lobby by yourself", a WidgetManager message (the owner, 2026-11-13).
- **The Workspace holds only the game:** `Ume` (spawn, asset folders, `Env`), `_Labs` (MapLab) and Roblox's own.
  Scratch and unused things go in `ServerStorage.!dump`. The template's baseplate (`Workspace.Ume.Env.Baseplate`)
  stays for building, but `Env` is tagged `Utils_MoveChildTo` (to ServerStorage), so the server moves it out when
  the game starts: nothing in play stands on it (avatars are parked anchored, the lobby's stage has its own ground).
- **Item ids are saved, so a renamed item keeps its id:** the Baseball bat became the Golf club on 2026-11-12 (its
  name, model, icon), and its id stays `BaseballBat` in the Inventory and Arsenal rows, so saved inventories and
  loadouts still find it.
- **Placeholders until the owner provides the real thing:** developer products and game passes keep `Id = 0`; weapon
  projectiles and effects are made in code, and skins without a snail of their own (FBI Agent, Prisoner, VIP, Wizard)
  fall back to the Classic snail. Each such spot has a `shortcut:` comment or a README line saying it's a placeholder.
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
  scale). Never a fixed pixel billboard: on a phone it covers half the screen. Its template lives with its module's
  assets, not in StarterGui (where Studio draws it at 0, 0, 0): `ReplicatedStorage_Assets/<Module>/PREFAB | <Gui>`, a
  Model with an invisible 1 × 1 × 1 `RootPart`, its `Attachment`, and the BillboardGui named `U_<Gui>`, which code
  clones alone and names `<Gui>`. Narrows `ume/place.md` (holder parts): the holder is the `PREFAB`, the gui `U_`.
- **Device sizes come from ume's platform tags:** a panel that differs per device carries `Utils_PlatformScale` (or
  `Utils_PlatformSize`), and ScreenScale multiplies the screen's scale by the device scale the tag keeps on the
  UIScale (`Utils_BaseScale`). No module or attribute of the game's own does per-device sizing. The GUI kit tags its
  panels 0.75 on Desktop, since it's drawn for phones.
- **Panels hang from a screen edge or corner** (the lobby's Party on the left, Loadout on the right, the public
  matches along the bottom with SOLO VS BOTS and CUSTOM at the bottom right, the STYLE, WEAPONS and SKINS menu and the
  currency at the top right), so a per-device size
  (`Utils_PlatformSize`) never needs a per-device position. On phones and tablets a panel too big for the screen gets a Mobile size, its list scrolling, and a Mobile scale under 1 only when
  its content needs the room; a heading that costs a phone too much hides there (`Utils_HideOnPlatform`).
- **Counts stay on one line:** a currency count gets the width of its longest text, and amounts from 10,000 up are
  written short by the slot (`Currency_ShortFrom`: "18.62k"), so a count never wraps.
- **The lobby is a party stage, as Fortnite's** (the owner's pick, 2026-11-09, replacing the bot match behind the
  guis): each client clones the stage prefab (`ReplicatedStorage_Assets/Lobby/PREFAB | Stage`, built by hand where it
  stands, beyond the baseplate; since 2026-11-12 the studio's meadow, `Spawn_New`, its four platforms the pods; its parts are SmoothPlastic, since this place's `2022 Stud` variants are) and holds the camera on its `Camera` marker, low and close; the player's snail
  stands on the front pod (`Pod_1`) in their equipped skin, and their party in this server on the pods around it in
  theirs (Lobby's `Stage` handler, from the `PartyId` and `EquippedSkin` Player attributes). Each client stands its
  own snails, so everyone is in front on their own screen; the pods are parts in the prefab, so the layout is moved
  in Studio. The
  screen is the studio's `LobbyInventory` (2026-11-09): Party, the Loadout slots, the STYLE / WEAPONS / SKINS menu,
  ACTIVE LOBBIES (a scrolling row of cards, one per public mode) and SOLO VS BOTS (**Play with party** in a party) with
  CUSTOM; no logo and no welcome line. The solo or party setup and the waiting room take the board's place, whose lobby
  rows and buttons slide down off the screen for them and back after (MatchBoard's `PLAY_*` settings, the owner's
  pick, 2026-11-12): the setup at the bottom centre (the owner's pick, 2026-11-12), the waiting room hanging from the
  bottom left beside Party; custom
  lobbies open in a window. Crates and Skins are full-screen widgets: while either is open the lobby's guis hide
  (Lobby's `FULL_SCREEN_WIDGETS` and `LOBBY_GUIS`).
- **Matchmaking fills with bots:** every public mode has a row on the board at all times, and its timer always runs
  (the owner's pick, 2026-11-09, so the lobby looks active): at 0 the match starts with whoever joined, bots in every
  empty seat (one player can play Trios), and a fresh row on another map takes its place, joined or not. A party can
  also play alone (friends only): with bots it pays like a public match, without bots half (MatchRewards'
  `PARTY_NO_BOTS_SHARE`).
- **A party's leader picks the match** (2026-11-10): members see Join, Solo vs bots and Custom greyed out (MatchBoard's
  `LOCKED_*`), and the server refuses their joins and lobbies. A custom lobby the leader makes takes the whole party
  in at once, and a party shares a team where it fits; a party bigger than a public row's team (three in Duos) joins
  it all the same, if the row has a seat for each, and spills onto the next team with room (the testers, 2026-11-13).
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
  (`I.Combat.GetArcs`, `PredictArc`), whose admin aim guide the server solves and sends to that player alone
  (`Combat_AimbotGuide`), and the movement checks' margins. What clients need to draw (shot flight, launch speeds,
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
