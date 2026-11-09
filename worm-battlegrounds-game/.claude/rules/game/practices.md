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
  falls fades out.
- **Maps are made in MapLab** (the game home's map kit, `assets/_tools/map-kit/`): the land drawn on the 1-stud grid
  and built into parts, props part-built, checked, then exported into the arena templates after the owner approves.
  A map the owner builds in Studio is imported where it stands (Rockslide Ridge): its parts renamed by look, in
  SmoothPlastic with `2022 Stud`, sorted into islands, ledges and backdrop, with its own markers.
- **Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`** (Terrain, Decor, Markers), their
  play plane (Bounds) at Z = 0, side by side along +X in 400-stud slots (MapLab's: X = (slot − 1) × 400) so none
  overlaps another, and cached by the Arena module at start. The drop picker reads the plane as Z = 0. Nothing starts
  in the bounds' top 20 studs (Arena's `START_TOP_GAP`), so a map's roof is never a spawn, and the liquid is drawn as
  deep as the map's bedrock, measured at load, never the bounds' depth: a map needs neither set by hand. Weapon models are authored in
  `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/` and cached by Arsenal (its README → In the place).
- **Liquids are a stop-motion stud simulation:** water and lava live in a grid of half-stud cells stepped at 8 fps
  and drawn as merged rectangles in `2022 Small Stud`, so they hop like a brick film. They are the only thing in the
  arena on a grid, and the cells stay fine (never one-stud or bigger blocks).
- **Only the sea knocks snails out** (the owner's pick, 2026-11-08): the liquid whose marker starts at the bounds'
  bottom, raised by sudden death (Arena's `GetHazard`, `SEA_SLACK`). A pond higher up, like Desert's oasis, is safe to
  fall in. Any liquid, ponds too, sets off an explosive shot that touches it.

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
  animations stay unpublished until the owner publishes them: Studio plays their keyframes, live servers nothing.
- **The active snail holds its weapon in its hands, in the weapon's pose** (the row's `HoldPose`: the studio's Gun,
  MiniGun, Bazooka and ShotGun snails; other items in the Gun pose), welded to the rig's `Handle` at the model's
  `Grip`, and always on the camera's side: a snail facing left swaps its hands over. The hands and weapon pitch to the
  aim (up to 90° either way), and a snail standing still turns to face its aim (its player's screen; the server for
  bots), so the weapon never points back through it. A gun plays its pose's shot when it fires. It's drawn by each
  client from the snail's `HeldItem` (Combat's `Held` handler), never welded on the server.
- **Aiming points from the snail at the mouse** (the owner's pick, 2026-11-07, after the drag measured from the
  press felt off): on PC the weapon follows the mouse from the snail even before a press; holding the button (or a
  finger on touch) sets the power by how far the pointer is from the snail on the screen, in shares of the screen's
  height so it feels the same on every screen, and letting go fires (on touch, letting go keeps the aim and its power,
  and the HUD's FIRE button fires it, since 2026-11-09). The camera doesn't edge-pan while the button is
  held. On a pad the right stick aims and a held RT runs the power bar
  up and down (Combat's `CHARGE_SECONDS` each way). The aim shows as an angle marker (the studio's crosshair picture, MatchHud's
  `CROSSHAIR_IMAGE`, a fixed distance from the snail, the direction only, never the shot's path) and a power bar (a row of circles from the held weapon's
  `Muzzle` attachment to it, lit as the power fills). Both keep their size on the screen whatever the zoom, and the
  screen that draws an aim turns the held weapon with it at once (no wait for the server's copy). Only letting go
  (or FIRE on touch) fires, never the turn running out.
- **Everyone sees the active snail aim:** its angle marker and power show on every screen through its turn, players'
  and bots' alike, from the `AimAngle`, `AimPower` and `AimTime` attributes Combat's `ShowAim` writes. Bots turn their
  marker, then fill their power, before they fire.
- **Blasts are felt, not only seen:** Combat's client `Effects` shakes the camera with ume's CameraShake, on top of
  MatchCamera (which updates at the `Camera` render priority, one step before the shaker), and vibrates phones and
  pads through the Haptic module's `Combat_*` presets (`src/global_data/Haptic/Preset.lua`). How hard comes from the
  blast's size and its distance from the middle of the view, and nothing is felt outside a match. The player's own
  shot ticks and a hit on their own snail thumps. The chunks of ground a blast throws are physics parts in Arena's
  `Chip` collision group: they bounce on the terrain, never on snails or shots, and fade after `DEBRIS_LIFETIME`.
- **A snail's shell breaks below 50 health:** each screen hides the skin's `Shell` part (its
  `LocalTransparencyModifier`, so the server's ghost see-through can't bring it back) while `Health` is under the
  Snails module's `SHELL_BREAK_HEALTH`, and throws chips in its colours as it breaks; healing back up shows it again.
  It's driven by the `Health` attribute alone, with no remote. A skin without a `Shell` part never breaks.
- **Effects are the studio's particle prefabs, played by the Vfx library** (2026-11-09): each effect is a part named
  `PREFAB | <Name>` in `Workspace.Ume.ReplicatedStorage_Assets/Vfx` (from the studio's `Particles_1` and
  `Particles_2`), its emitters disabled, with `EmitCount`, `EmitDelay` and `EmitDuration` attributes saying how each
  fires. Code plays one by name (`I.Vfx.Play(name, cframe, parent, scale?)`), clones a trail (`I.Vfx.AddTrail`), and
  never builds particles of its own. Blasts pick theirs by size (Combat's `BLAST_VFX`); guns, the punch and the
  snails' spawn, landing, healing, splash and trail have theirs (Combat's and Snails' client `Effects`).
- **Shots fly by the game's own simulation, not Roblox physics:** Combat's `Ballistics` (Scripts/Helpers) steps every
  flying shot the same on the server and every client, on the server's clock, with Worms' arcade rules (bounces that
  lose speed along the ground, resting and rolling off ledges, explosive shots that blow up as they touch liquid). The server is
  the authority (launch, states every 0.1 s, end; it alone decides blasts), and each client simulates its own copy for
  smooth flight, rewinding to the server's state when it drifts. Never give a flying shot Roblox physics or move it by
  replicated parts.
- **Shots fly in slow motion** (the tester's notes, 2026-11-08): the simulation runs at Combat's
  `PROJECTILE_TIME_SCALE` (0.5, half speed) along the same paths, so eyes can follow a shot. A thrown bomb's `Fuse`
  counts its own slowed flight time, so it bursts where it did at full speed; a placed one's (Dynamite) stays in real
  seconds. Anything that steps a shot (bots' predictions too) counts flight in the shot's own time. Only the piercing spear sinks in liquid; every other shot blows up there.
- **Strong items start on their cooldown** (2026-11-08): an item with a `Cooldown` waits that many of the player's
  own turns before its first use too (Combat's `Uses.Reset`, mirrored in the bots' `Sim`), so nobody opens a match
  with the strongest weapons. Admin `give` and `refill` clear it, for testing.
- **Server-moved shots glide on clients:** the spider bomb's crawl and the variety grenade's worms move as server
  parts after landing; clients draw their models gliding after them (Combat's `CRAWL_GLIDE`), and the spider bomb walks
  up 1-stud steps rather than jumping them. Their throws fly on `Ballistics` like every other shot. Flying shots are
  drawn `PROJECTILE_DRAW_SCALE` (2) times their size, hits unchanged.
- **Dynamite is placed, not thrown:** it drops at the snail's feet (`Aim = "Feet"`, no launch speed), the stamina bar
  fills again and the player keeps moving for its `Retreat` (3 s) before the server takes the snail back, and the fuse
  (3.5 s) goes off after that.
- **Bots play like players** (2026-11-08): they walk, climb, jump and fly their jetpack with SnailControl's speeds and
  stamina (Bots' `Move`), never step into the sea or down a drop that hurts, walk to a spot their shot lands from,
  close in to swing or place Dynamite and run, and heal when hurt. Their snails stay server-owned.
- **Bots think with a trained brain** (2026-11-08): each turn the Bots module's brain plans with the game's own
  simulation (Combat's shot bodies, blasts, throws, craters and the sea) and scores every plan with its difficulty's
  genome (`ServerData/Brains.lua`), which self-play in Studio trains (the gym, the `train-bots` skill). Difficulty is skill
  (`SKILLS`: the hand's error, the wind read, how far it looks, how much it minds the map), never deliberate misses.
  Nightmare is a secret difficulty, offered only in a custom lobby's Bots row (the owner's pick, 2026-11-08). Retraining, and teaching the bots something the game adds (a
  weapon, a map object, a hazard), happens only when the owner asks.
- **A walking snail has no grip:** its ball's friction is 0 while it walks, so it slides along walls and up slopes;
  at rest it grips again (`ROOT_FRICTION`).

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
  2026-11-07, after a Studio update had wiped their local copies and blanked every icon. The game uses no local
  picture now; a new one shows only on the PC that built it, and blanks after the next Studio update, until it's
  uploaded (each kit's README → Uploading).
- **The game's guis are built from the theme's controls** (`WormBattlegroundsBrawl`, over `WormBattlegrounds`),
  never from raw `Primitive` nodes holding their own colours and sizes (as ume-gui's System guis are): `Widget` for
  every WidgetManager widget, `Box` for panels and cards, `Item` for item cards, `Cells` for lists and grids code
  clones rows into, `Picture` for images, and the shared `Label`, `Button`, `Stack`, `Progress`. Restyling the game
  is a theme change (the gui folder's `src/themes/WormBattlegroundsBrawl/_meta/README.md`). Overrides
  `gui/format.md` → Buttons and Surfaces ("other guis, built from `Primitive` nodes").
- **The studio's screens are 1:1 `Primitive` ports** (the owner's pick, 2026-11-09): the match HUD (`MatchHud`,
  `SnailTag`, `DamagePop`), the lobby (`Lobby`, `Party`, `Loadout`, `LoadoutPicker`, `MatchBoard`), `Crates` and
  `Skins` are the studio's `HUD`, `LobbyInventory`, `Gacha` and `Customise` designs converted node for node into
  `Primitive` nodes (their pictures, fonts and screen-fraction layout), with U_/S_ Ids, prefabs for lists, button tags
  and WidgetManager's widget shape added. They override the rule above and the GUI kit's look rules (yellow leads
  the eye, kit picked states) for these guis: a picked or locked look is copied from the design into `Look_*`
  attributes on the prefab or button, which code swaps. Blocks the designs lack (the drop, knocked-out and waiting
  dialogs, the kill feed, the emote wheel, the match setup and waiting room) stay theme controls in the same table
  (`Theme = "WormBattlegroundsBrawl"`). They lay themselves out by screen fractions with aspect-ratio constraints, so
  they need no `S_ScreenScale` and aren't in ScreenScale's `GUIS` (MatchHud and MatchBoard stay, for their kept
  blocks).
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
  writes plain sentences ("Your turn in 3 turns"), never its own `string.upper`. A gui whose code writes into
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
  half follows it instead of assuming its map. Studio saves nothing, so a playtest skips the tutorial match and opens
  on the lobby; the Workspace attribute `StudioTutorial` (true) plays it. A custom lobby picks its bots (Off to
  Nightmare) and its owner may start it alone with bots, which is how one tester plays it in Studio; without bots it needs
  2 or more players.
- **The Workspace holds only the game:** `Ume` (spawn, asset folders, `Env`), `_Labs` (MapLab) and Roblox's own.
  Scratch and unused things go in `ServerStorage.!dump`. The template's baseplate (`Workspace.Ume.Env.Baseplate`)
  stays for building, but `Env` is tagged `Utils_MoveChildTo` (to ServerStorage), so the server moves it out when
  the game starts: nothing in play stands on it (avatars are parked anchored, the lobby's stage has its own ground).
- **Placeholders until the owner provides the real thing:** developer products and game passes keep `Id = 0`; weapon
  projectiles, effects and skins other than Classic are made in code or fall back to the Classic snail. Each such spot
  has a `shortcut:` comment or a README line saying it's a placeholder. Never create products, passes or models on
  the owner's behalf.
- **Match sounds are free Creator Store ids, played by name** (the owner, 2026-11-08: "find roblox ids, no
  uploading"): every id lives once in `src/global_data/Sound/SoundsList.lua` under its name (`Fire_<itemId>`,
  `Use_<itemId>`, `Explosion_*`, `Snail_*`, `Turn_*`, `Match_*`), checked to load in Studio, and code plays the
  name in the `SFX` group. Prefer Roblox's licensed uploads (creators `ProSoundEffects`, `APMOfficial`, `Roblox`) and
  plain sound effects over rips from other games or memes. Sounds in the world play where they happen within Combat's
  `SOUND_ROLLOFF_MIN`/`MAX` (the camera sits 45 to 200 studs away, past Roblox's default 100-stud fade); turn and
  result sounds are 2D. A new weapon or utility gets its `Fire_` or `Use_` row in the same change. They're
  placeholders until the studio's own sounds: swapping one is a one-line id change.
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
  stands, beyond the baseplate) and holds the camera on its `Camera` marker, low and close; the player's snail
  stands on the front pod (`Pod_1`) in their equipped skin, and their party in this server on the pods around it in
  theirs (Lobby's `Stage` handler, from the `PartyId` and `EquippedSkin` Player attributes). Each client stands its
  own snails, so everyone is in front on their own screen; the pods are parts in the prefab, so the layout is moved
  in Studio. The
  screen is the studio's `LobbyInventory` (2026-11-09): Party, the Loadout slots, the STYLE / WEAPONS / SKINS menu,
  ACTIVE LOBBIES (a scrolling row of cards, one per public mode) and SOLO VS BOTS (**Play with party** in a party) with
  CUSTOM; no logo and no welcome line. The solo or party setup and the waiting room take the board's place, hanging
  from the bottom left beside Party so the stage's front pod stays in sight; custom
  lobbies open in a window. Crates and Skins are full-screen widgets: while either is open the lobby's guis hide
  (Lobby's `FULL_SCREEN_WIDGETS` and `LOBBY_GUIS`).
- **Matchmaking fills with bots:** every public mode has a row on the board at all times, and its timer always runs
  (the owner's pick, 2026-11-09, so the lobby looks active): at 0 the match starts with whoever joined, bots in every
  empty seat (one player can play Trios), and a fresh row on another map takes its place, joined or not. A party can
  also play alone (friends only): with bots it pays like a public match, without bots half (MatchRewards'
  `PARTY_NO_BOTS_SHARE`).
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
