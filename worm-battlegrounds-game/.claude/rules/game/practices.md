# Game practices

How this game uses ume and ume-gui, and its design decisions, for both folders. They win over the framework's rules
(`family/family.md` → Rules). Their stories: the code folder's `docs/game/lessons.md` (`family/docs.md`).

## Arena

- **Terrain is authored parts,** built like a hand-made map: long parts for the shapes, smaller ones for details, in
  SmoothPlastic with MaterialService's `2022 Stud` variant. Never Roblox Terrain, and never a grid of cells or
  one-stud blocks.
- **Blasts carve with CSG:** `GeometryService:SubtractAsync` with a cylinder whose axis runs along Z (through the
  plane), so craters are smooth and round. `SplitApart` keeps every loose piece its own part; a group of pieces that
  no longer touches the ground falls and anchors again where it lands.
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
- **A walking worm has no grip:** its ball's friction is 0 while it walks, so it slides along walls and up slopes;
  at rest it grips again (`ROOT_FRICTION`).

## Guis

- **The look is Worms-style, made chunkier for Roblox, and flat:** teal frames with a light bevel line inside a thick
  navy outline, dark striped header bars with left-aligned upper-case titles, item tiles with a white name strip over
  a sky-blue picture well, flat teal buttons with outlined capitals, yellow calls to action, Gotham. The theme's
  README describes it.
- **No bottom lip:** no darker edge or depth under a button, tile or container, and no drop shadow. Every surface is
  one flat face with its outline (the theme's `Slab`).
- **Pictures drawn for the game stay local until the owner approves them:** the icon kit (the game home's
  `assets/_inbox/ui_kit/`) renders them into Studio's content folder (`rbxasset://textures/wb_guipreview/…`) and
  writes the theme's `Icons.lua`. Nothing is uploaded to Roblox before the owner says so.
- **The game's guis are built from the `WormBattlegrounds` theme's controls,** never from raw `Primitive` nodes
  holding their own colours and sizes (as ume-gui's System guis are): `Widget` for every WidgetManager widget, `Box`
  for panels and cards, `Item` for item cards, `Cells` for lists and grids code clones rows into, `Picture` for
  images, and the shared `Label`, `Button`, `Stack`, `Progress`. Restyling the game is a theme change (the gui
  folder's `src/themes/WormBattlegrounds/_meta/README.md`). Overrides `gui/format.md` → Buttons and Surfaces ("other
  guis, built from `Primitive` nodes").
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

## Maps and placeholders

- **Two maps in one place:** `Lobby` and `Match` (`core/.../configs/place_loader.lua`). Each loads the `Default`
  folders (shared by both) plus its own, and its module list leaves out the other map's modules (`MATCH_ONLY`,
  `LOBBY_ONLY`).
- **Studio plays the `Studio` map:** both maps' folders and modules on one server, since Studio can't teleport. The
  lobby hands each match to `I.Match.Host`, and the `InMatch` Player attribute says which half a player is in: every
  screen, camera and hint that belongs to one half follows it instead of assuming its map. A Workspace attribute
  `Ume_StudioMapId` (`Lobby` or `Match`) tests one map alone.
- **Placeholders until the owner provides the real thing:** developer products and game passes keep `Id = 0`; weapon
  projectiles, effects and skins other than Classic are made in code or fall back to the Classic worm. Each such spot
  has a `shortcut:` comment or a README line saying it's a placeholder. Never create products, passes or models on
  the owner's behalf.
- **Panels scale with the screen through ScreenScale:** every game gui's panels are laid out for a 1080 px tall
  screen with an `S_ScreenScale` UIScale, and the ScreenScale module (Utils) sets them all; a new gui joins its
  `GUIS` list instead of scaling itself.
