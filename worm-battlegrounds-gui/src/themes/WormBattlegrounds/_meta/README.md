# WormBattlegrounds

The game's theme: Worms-style menus made chunkier for Roblox. Flat teal panels with a light bevel line inside a thick
navy outline, dark striped header bars with left-aligned upper-case titles, item tiles with a white name strip over a
sky-blue picture well, flat teal buttons with outlined capitals, yellow calls to action and Gotham. Nothing is raised:
no darker edge under a button or a panel, and no shadow.

It extends System (`Extends = "System"`): `Tokens.lua` lists only what differs and the engine merges it over System's,
and `Styles/` lists only the changed or added variants. Every gui in `src/guis/WormBattlegrounds/` uses it
(`Theme = "WormBattlegrounds"`), so restyling the game means changing this folder, not the guis.

Sizes are for a 1080 px tall screen. Each widget and each screen panel carries an `S_ScreenScale` UIScale that the
game's code sets to the screen's height / 1080 (×1.3 on Mobile screens shorter than 500 px).

## Tokens

| Group | What |
| --- | --- |
| `Palette.Night` | Teal frames (`Background`, its `Bevel` line), the dark `Header` bars, recessed rows (`Surface` + `Hover`, `Pressed`), buttons and tiles (`Tile` + `Hover`, `Pressed`, `TileBevel`), the tile's name `Strip` and picture `Well`, navy outlines (`Border`, `BorderStrong`), the selected look (`Inverse` + `Hover`, `Pressed`, `InverseText`); plus the game's: `Primary` (yellow, + `Hover`, `Pressed`, `PrimaryBevel`), `DangerBevel`, `Coin`, `Diamond`, `Vip`, `Health`, `Stamina`, `Power`, the teams (`TeamRed`, `TeamBlue`, `TeamGreen`, `TeamYellow`) and the rarities (`Common` … `Legendary`). The guis are Night only, so `Light` stays System's |
| `Font` | Gotham (`GothamSSm`): Medium `Hint`, Bold `Body`, Heavy `Title` |
| `TextSize` | System's sizes scaled for a game screen, plus `Display` (48: timers, countdowns, damage pops) |
| `Icons` | `Icons.lua`: the game's icon kit (`wb-*`) and the System icons it replaces (arrows, plus, the crate placeholder). Written by the kit's build script (Generated, below) |
| `Radius`, `Spacing`, `Stroke` | Small corners (6 px controls, 10 px windows), wider gaps, 3 px outlines (`Thick`), 2 px text outlines (`Text`) |
| `Size` | System's sizes scaled up, plus the game's: `Banner` (widget header), `Band` / `BandSmall` (box title bands), `Item` / `ItemTall` (item tiles), `BarSlot` (match loadout slots), `Tile` / `TileTall` (skins, game passes), `Avatar`, `ThumbnailWidth` / `ThumbnailHeight` (map pictures), `Glyph` (icons beside text) |

## Styles

A `Slab` record (keys of the `Slab` style) sets the flat framed surface under a control: `Button`, `Item` and `Box`
have one (a Box has a second, `Band`, for its title bar), `Widget` has two (`Panel` and `Banner`). A record merges
over the `Slab` style's Default.

| File | Variants |
| --- | --- |
| `Slab.lua` | Default: `Fill`, `Stroke` / `StrokeThickness` (the outline), `Radius`, `Bevel` / `BevelColor` / `BevelInset` (a light line inside the face's edge; 0 is none), `Pattern` / `PatternTransparency` / `PatternSize` (an icon tiled over the face: the header stripes) |
| `Button.lua` | Default: a `Tile` slab with a 2 px bevel, upper-case outlined text (`Upper`, `TextStroke`), the game's press scale and `Button_Click` / `Button_Hover` sounds; Selected is light aqua with navy text. `Small` (no outline). `Primary`: yellow with navy text. `Danger`: red. `Close`: the widgets' red X |
| `Label.lua` | Default: one line tall (`Lines`), no outline. `Heading`, `Title` (upper-case, outlined), `Display` (big outlined numbers), `Paragraph` (four lines tall), `Outlined` (badges over pictures), `Coin`, `Diamond` (tones) |
| `Progress.lua` | Default: an 18 px bar. `Stamina`, `Power`, `Health` (fills) |
| `Widget.lua` | Default (900 × 620), `Small` (640 × 460), `Large` (1240 × 820). Keys: the `Panel` slab, `HeaderInset`, the `Banner` slab with `BannerHeight` / `BannerWidth`, the title's colour, font, size, outline, `TitleUpper` and `TitleAlign`, the close button's `CloseSize` / `CloseStyle` / `CloseTags` |
| `Box.lua` | Default: a `Surface` slab that grows with its content, and a striped `Header` band (`Band`, `BandHeight`, `BandInset`, `BandPadding`) under its title (`TitleUpper`, `TitleAlign`). `Panel`: a screen panel (the teal `Background` slab with its bevel, a taller band). `Fixed`: keeps its node's size, or fills its column's free height |
| `Item.lua` | Default: a 150 × 190 `Tile` slab with a bevel, the name on a white strip (`StripFill`, `StripHeight`), the picture in a sky-blue well (`IconFill`, `IconScale`, `Tint`). `Square` (150 × 150), `Small` (`BarSlot` square). `Common` … `Legendary`: the outline in the rarity's colour |
| `Cells.lua` | Default: rows in a column. `Grid` (Item tiles), `Squares` (square tiles), `Tiles` (`Tile` cards). `Fixed`: keeps its node's size instead of filling its column |
| `Picture.lua` | Default: an `Item`-size picture framed in a sky-blue well, the kit's crate until the art exists. `Avatar` (round, light aqua), `Thumbnail` (map picture), `Glyph` (a bare icon) |

## Controls

The game's own controls (`Controls/`), found before the shared ones. Their params are in each module's `Params`.

### Slab

The flat framed surface the other controls draw on: the `Face` (fill, corner, outline), an optional `Pattern` tiled
over it, and the `Bevel` line just inside its edge. Its root is a Folder, so the parts size to the frame it's built
in. Controls build it with `ctx.Build({ Control = "Slab", Style = style.Slab }, parent)`. Handle: `Face`, `Stroke`,
`Bevel` (the bevel's UIStroke), for state colours.

### Button

The shared Button's params and handle (`Clicked`, `SetText`, `SetDisabled`, `SetSelected`), drawn on a slab: the
states recolour the face, outline, bevel, text and text outline. With `Upper` the text is upper-cased, keeping its
`&lt;`-style escapes.

### Label

The shared Label's params and handle (`SetText`, `SetTone`, `Get`), with a fixed height (`Lines` × one line at its
size) instead of `AutomaticSize`, which measures in screen pixels under `S_ScreenScale`, an optional text outline and
`Upper`.

### Stack

The shared Stack, except that a label in a horizontal row is sized to its text's width (measured once at build),
for the same reason.

### Widget

WidgetManager's widget shape as one node: `Root = { Control = "Widget", Id = "U_Widget", Title = "Shop", Children = { … } }`.
It builds the `U_Widget` frame (centred, its style's size) with `S_ScreenScale`, `Bg_Bottom` (the `Panel` slab),
`Bg_Top` (the striped `Banner` slab inset from the top edge, with the left-aligned upper-case title and `CloseButton`
on the right, a `Close` Button tagged to close through WidgetManager or B), `Content` (padded column under the header:
the node's children) and a `MouseLockFix` exported beside it (`handle.Siblings`). `Close = false` leaves the close
button out. Handle: `SetTitle(text)`.

### Box

A group on a slab (`ctx.Surface`, with the slab in place of `Background`): an optional `Title` on a striped band
across its top, over a padded, centred column of children. `Screen = true` adds an `S_ScreenScale` UIScale for a
panel placed on the screen; give that Box a `U_` Id.

### Item

A pressable tile for one thing (`ctx.Pressable`) on a slab: `S_Name` (`Text`) on the white strip, `S_Icon` (the
picture: an icon name or an image id; the kit's crate until the art exists) in the well, and `S_Info` (`Subtext`)
under it, each hidden when not given. Children go in an `Overlay` frame over the tile, placed by their `Props`
(badges: copies, lock, shiny, cooldown). Handle: `Button`, `Clicked`. Code reaches the parts with
`FindFirstChild("S_Name", true)`.

### Cells

A container game code clones prefabs into, laid out by Roblox's own `UIListLayout` or `UIGridLayout`, so clones line
up in game as in the preview (the shared `Grid` lays cells out in code, which exports don't run). A ScrollingFrame
unless `Scroll = false`; `Direction = "Horizontal"` for a row. Children are kept before the clones (sort by
`LayoutOrder`).

### Picture

An image that isn't a button (`Image`: an icon name or an image id), framed by its style.

## Generated

- `Icons.lua` is written by the icon kit's build script, made outside this repo (the game home's
  `assets/_inbox/ui_kit/`). Until the owner approves the kit and it's uploaded, its images are local previews:
  `rbxasset://textures/wb_guipreview/<name>_<hash>.png`, files in Studio's own content folder that only this PC's
  Studio shows. After the upload each line becomes an `rbxassetid://`.
- No `Gamepad.lua`: the theme uses System's gamepad icons.
