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
  is stepped. `SplitApart` keeps every loose piece its own part; a group of pieces that no longer touches the ground
  falls and anchors again where it lands.
- **Ground is bedrock on the floor:** each island's waterline blocks carry `Arena_Indestructible` (a name from before
  blasts could cut it). Blasts cut bedrock like any terrain, so an island can be blasted down to the water; a bedrock
  piece holds up what touches it while its bottom still reaches the map's floor (the bottom of its lowest bedrock),
  and a piece cut loose falls. **Floating ledges float:** their parts carry `Arena_Floats`, and a cut-off group of
  them stays up while it covers `FLOAT_MIN_AREA`; smaller crumbs fall. Never mark a ledge block as bedrock to hold it
  up: it isn't on the floor, so it holds nothing.
- **Props break under blasts:** trees, bushes and rocks in a map's Decor are `Arena_Prop` Models built from parts
  (never collidable for worms). A blast cuts its hole through them with the same stepped cutter as the terrain, and
  the pieces no longer joined to the prop's base fly off; a prop whose ground is gone (under its trunk) falls. What
  falls fades out.
- **Maps are made in MapLab** (the game home's map kit, `assets/_tools/map-kit/`): the land drawn on the 1-stud grid
  and built into parts, props part-built, checked, then exported into the arena templates after the owner approves.
- **Maps are authored in `Workspace.Ume.ServerStorage_Assets/Arenas/<MapId>`** (Terrain, Decor, Markers), centred
  on the arena's plane at Z = 0, and cached by the Arena module at start. Weapon models are authored in
  `Workspace.Ume.ReplicatedStorage_Assets/Arsenal/` and cached by Arsenal (its README → In the place).
- **Liquids are a stop-motion stud simulation:** water and lava live in a grid of half-stud cells stepped at 8 fps
  and drawn as merged rectangles in `2022 Small Stud`, so they hop like a brick film. They are the only thing in the
  arena on a grid, and the cells stay fine (never one-stud or bigger blocks).

## Worms

- **A worm's state lives in attributes on its model** (`Health`, `Alive`, `Ghost`, `CanMove`, `Stamina`, `Active`…),
  written by the server and read by every client, so the worm modules need no remotes. Overrides `ume/values.md` →
  where a per-player value lives: worm state belongs to the worm, which bots have too, not to a player.
- **The active worm is moved by its player's client** through network ownership; the server only checks speed and
  stamina and takes the worm back. Anything the server does to a worm (knockback, a knockout) happens while the
  server owns it.
- **A worm starts standing on land unless its player places it:** bots and players who don't place start on
  `I.Arena.GetLandSpots` (on top of the ground on any storey, never over liquid); only a spot a player placed is
  dropped onto with the parachute.
- **The active worm holds its weapon on the camera's side** (+Z, in front of its body), turned to its aim, so every
  player sees it; it's drawn by each client from the worm's `HeldItem` (Combat's `Held` handler), never welded on
  the server.
- **Aiming is a crosshair and a held charge, as in Worms:** the crosshair sits a fixed distance from the worm in the
  aim's direction (it shows the direction only, never the shot's path), and holding the fire button charges the
  power, drawn as a row of circles from the held weapon's `Muzzle` attachment to the crosshair that light up as it
  fills. The crosshair and circles keep their size on the screen whatever the zoom, and the screen that draws an aim
  turns the held weapon with it at once (no wait for the server's copy). Held, the power
  bounces from none to full and back (Combat's `CHARGE_SECONDS` each way); only letting go fires, never a full charge
  or the turn running out. Guns and melee weapons fire on the press.
- **Everyone sees the active worm aim:** its crosshair and power show on every screen through its turn, players' and
  bots' alike, from the `AimAngle`, `AimPower` and `AimTime` attributes Combat's `ShowAim` writes. Bots turn their
  crosshair, then charge, before they fire.
- **Blasts are felt, not only seen:** Combat's client `Effects` shakes the camera with ume's CameraShake, on top of
  MatchCamera (which updates at the `Camera` render priority, one step before the shaker), and vibrates phones and
  pads through the Haptic module's `Combat_*` presets (`src/global_data/Haptic/Preset.lua`). How hard comes from the
  blast's size and its distance from the middle of the view, and nothing is felt outside a match. The player's own
  shot ticks and a hit on their own worm thumps. The chunks of ground a blast throws are physics parts in Arena's
  `Chip` collision group: they bounce on the terrain, never on worms or shots, and fade after `DEBRIS_LIFETIME`.
- **A walking worm has no grip:** its ball's friction is 0 while it walks, so it slides along walls and up slopes;
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
  the pictures get PrepKit's pixel-fix, are uploaded, and `Icons.lua` points at their `rbxassetid://` ids. The GUI
  kit is uploaded (2026-11-04); the first kit's item, emote and skin pictures (`wb_guipreview`) are still local.
  A Studio update installs a fresh content folder without them, and every gui showing one goes blank: copy them in
  again (`assets/_inbox/ui_kit/README.md` → Rebuilding), then restart Studio, which remembers a failed picture for
  the whole session.
- **The game's guis are built from the theme's controls** (`WormBattlegroundsBrawl`, over `WormBattlegrounds`),
  never from raw `Primitive` nodes holding their own colours and sizes (as ume-gui's System guis are): `Widget` for
  every WidgetManager widget, `Box` for panels and cards, `Item` for item cards, `Cells` for lists and grids code
  clones rows into, `Picture` for images, and the shared `Label`, `Button`, `Stack`, `Progress`. Restyling the game
  is a theme change (the gui folder's `src/themes/WormBattlegroundsBrawl/_meta/README.md`). Overrides
  `gui/format.md` → Buttons and Surfaces ("other guis, built from `Primitive` nodes").
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
  on the lobby; the Workspace attribute `StudioTutorial` (true) plays it.
- **The Workspace holds only the game:** `Ume` (spawn, asset folders, `Env`), `_Labs` (MapLab) and Roblox's own.
  Scratch and unused things go in `ServerStorage.!dump`. The template's baseplate (`Workspace.Ume.Env.Baseplate`)
  stays for building, but `Env` is tagged `Utils_MoveChildTo` (to ServerStorage), so the server moves it out when
  the game starts: nothing in play stands on it (avatars are parked anchored, the lobby stage has its own ground).
- **Placeholders until the owner provides the real thing:** developer products and game passes keep `Id = 0`; weapon
  projectiles, effects and skins other than Classic are made in code or fall back to the Classic worm. Each such spot
  has a `shortcut:` comment or a README line saying it's a placeholder. Never create products, passes or models on
  the owner's behalf.
- **Panels scale with the screen in position and size:** every game gui's panels are laid out for a 1920 × 1080
  screen. Their positions are screen fractions (`UDim2.fromScale`, never pixel offsets, which don't scale), and their
  size is an `S_ScreenScale` UIScale the ScreenScale module (Utils) sets: by height, by width on a screen narrower
  than 16:9, bigger on short phones, and never under 0.6 on PC and console (`MIN_SCALE`), even where the width would
  make it smaller, so text on a 1024 × 768 screen stays readable. Panels side by side are placed to fit at that floor.
  A new gui joins its `GUIS` list instead of scaling itself. A button or tile
  placed on the screen by itself gets its own `S_ScreenScale` (the kit's `Screen` param: the touch buttons, the emote
  button).
- **World labels scale with the screen too:** a billboard over the world (WormTag, DropMarker, DamagePop) lays its root
  out at its design size with an `S_ScreenScale`, and the code that clones it hands it to
  `I.ScreenScale.AddBillboard`, which sets that scale and the billboard's size to the root's times it (no device
  scale). Never a fixed pixel billboard: on a phone it covers half the screen.
- **Device sizes come from ume's platform tags:** a panel that differs per device carries `Utils_PlatformScale` (or
  `Utils_PlatformSize`), and ScreenScale multiplies the screen's scale by the device scale the tag keeps on the
  UIScale (`Utils_BaseScale`). No module or attribute of the game's own does per-device sizing. The GUI kit tags its
  panels 0.75 on Desktop, since it's drawn for phones.
- **Panels hang from a screen edge or corner** (top-left Party, bottom-left Loadout, the MatchBoard panel at the
  bottom just right of the centre (55 %), top-right currency and the Crates and Skins buttons), so a per-device size
  (`Utils_PlatformSize`) never needs a per-device position. On phones and tablets a panel too big for the screen gets a Mobile size, its list scrolling, and a Mobile scale under 1 only when
  its content needs the room; a heading that costs a phone too much hides there (`Utils_HideOnPlatform`). A panel
  that would cover another one on phones folds behind a tab there instead (Party: a "Party 2/4" tab over a panel as
  tall as its members, open on PC and console, folded on phones and tablets, opened by a press), and draws above what
  it covers when opened (Loadout and MatchBoard at `DisplayOrder` -1, under Party's 0 and the windows' 1).
- **Counts stay on one line:** a currency count gets the width of its longest text, and amounts from 10,000 up are
  written short by the slot (`Currency_ShortFrom`: "18.62k"), so a count never wraps.
- **The lobby is a 3D stage, not a backdrop picture:** the camera sits on the `LobbyStage` Model's `Camera` marker and
  the player's worm stands on its `Worm` marker (Lobby's README → In the place), with the lobby's guis see-through
  over it. Keep the screen to a few things: the logo at the top, Party, the Loadout bar, the corner buttons, and one
  panel at the bottom laid out like RoWorld's (the owner's reference, 2026-11-06): a welcome line, the yellow **Play
  solo** (**Play with party** in a party) and the public matches, one card per mode. The solo or party setup and the
  waiting room take that panel's place; custom lobbies, crates and skins open in a window.
- **Matchmaking fills with bots:** every public mode has a row on the board at all times, its timer starts when the
  first player joins, and at 0 the match starts with whoever joined, bots in every empty seat (one player can play
  Trios). A party can also play alone (friends only): with bots it pays like a public match, without bots half
  (MatchRewards' `PARTY_NO_BOTS_SHARE`).
- **Check guis shown together for overlaps** before calling a layout done: PC sizes from 1024 × 768 to 3840 × 2160,
  tablets, and phones down to 667 × 375.
