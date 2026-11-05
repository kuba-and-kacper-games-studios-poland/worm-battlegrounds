# WormBattlegroundsBrawl

The **GUI kit** look (draft 4, 2026-11-04), the game's look: windows in the sea gradient with a diamond pattern you only
notice up close, an orange border, a tilted yellow Hazard plate with the title breaking out of the top-left corner
and a slanted red close; buttons, cards and frames drawn as 9-slice skin images (the outline, light and lip are in
the picture); things on plain see-through black slots; framed reward tiles only for rewards being won; Londrina
Solid Black for every text, with an ink outline. The kit's sheets, research and pictures live in the game home
(Generated, below).

It extends the game's theme (`Extends = "WormBattlegrounds"`), so it keeps that theme's controls and styles and
changes only what's listed here. Every gui in `src/guis/WormBattlegrounds/` uses it
(`Theme = "WormBattlegroundsBrawl"`); the `WormBattlegrounds` theme is now only its base (`game/practices.md` →
Guis).

Sizes are pixels on a 1080 px tall screen. No text is under 32 px and nothing pressable under 96 px (about 15 pt
and a thumb wide on a phone).

Panels scale with the screen in position and size: guis place them by screen fractions (`UDim2.fromScale`), and the
game's ScreenScale module sizes their `S_ScreenScale` to the screen. Their size per device comes from ume's
`Utils_PlatformScale` tag: the kit is drawn for phones, so every panel it makes (`Widget`, a `Screen` `Box` or `Item`)
is tagged from the `PlatformScale` style key, 0.75 on Desktop and 1 elsewhere, and ScreenScale multiplies the
screen's scale by it. Guis that add their own `S_ScreenScale` (a `Primitive` UIScale) tag its panel the same way.

On phones and tablets (Mobile) a panel that would not fit gets a size of its own (`Utils_PlatformSize`, its list
scrolling instead) and, where its content needs room, a Mobile scale under 1 in its node's `Style`
(`PlatformScale = { Utils_MobileScale = 0.9 }`). Panels hang from a screen edge or corner, so a per-device size never
needs a per-device position.

## Colour by job

Yellow is the next thing to press: one per window, three at most on a screen. Every other button wears its job's
colour: blue for other actions, back and info (and Join in a list), green for every price, red for leaving and
closing, purple for modes and events, slate for side buttons and tabs at rest, grey for owned, locked or not ready.

## Tokens

| Group | What |
| --- | --- |
| `Palette.Night` | `Ink` (outlines, text outlines, drops, also `Border` / `BorderStrong`), `Background` (the sea's middle), `Slot` (black, see-through by style), `Well`, white `Text` with `TextDim` / `TextMuted`, `Pressed` (a skin's tint while held). Tones: `Accent` (cyan), `Price` / `Map` / `Success` (green), `Cream`, `Gold`, `Danger`, `Warning`, `Coin`, `Diamond`, `Vip`, and `GlowCommon` … `GlowLegendary` (the light behind a reward, also rarity text). The base theme's game colours (teams, bars) carry over |
| `Font` | Londrina Solid Black (`rbxassetid://113086061264643`, weight Heavy, a Creator Store font) for `Hint`, `Body` and `Title` |
| `TextSize` | `Caption` / `Small` 32, `Body` 36, `Button` 40, `Heading` 48, `Title` 64, `Display` 80, `Hero` 112 |
| `Radius` | 12 `Small`, 18 `Control` and `Card`, 24 `Window` |
| `Size` | Buttons `Control` 96, `ControlLarge` 112, `Hero` 144 (a slanted skin exists for each), `IconButton` 96; `Pill` 72; `Row` 160; things `Item` 152 / `ItemTall` 200, `BarSlot` 112, `Tile` 280 / `TileTall` 380; people and places `PlayerCard`, `Avatar` 96, `AvatarLarge` 128, `ThumbnailWidth` / `ThumbnailHeight` 192 × 108; `Glyph` 48, `IconLarge` 96; `Drop` 8 |
| `Spacing` | 8, 16, 24, 32, 48 (`XS` … `XL`), `Buttons` 24 |
| `Stroke` | `Thin` 3, `Thick` 4, `Heavy` 6, `Text` 4 |
| `Icons` | `Icons.lua` (Generated): the kit's pictures, and its skins as `wb-skin-<name>`, over the base theme's, plus `wb-robux` (Roblox's own Robux icon) |

## Styles

Style records merge over the base theme's, so each file lists only what changes.

| File | Variants |
| --- | --- |
| `Slab.lua` | Default adds the kit's keys: `Skin` (a `wb-skin-` icon name), `SkinScale` (0.5: the PNGs are 2×), `SkinTint`, `Drop` / `DropTransparency` (the ink drop under a raised skin), `Fill` / `FillTransparency` / `Inset` (the body), `Gradient` (a `ColorSequence` from the kit's library, top to bottom), `Fade` (the body's bottom transparency in its `UIGradient`), and the diamond `Pattern` at 96 % transparency |
| `Widget.lua` | Default (1000 × 700): the Hazard plate window: `Panel` (border, drop, sea gradient, pattern), the plate (`Plate`, `PlateWidth` / `PlateHeight` 460 × 112, `PlateRise` 64 above the window, `PlateX` −28, `PlateLip`, `Tilt` −3°, title 48), the close (`CloseWidth` / `CloseHeight` 118 × 96, `CloseOut` 30 past the right edge, `CloseY`), `PlatformScale` (Desktop 0.75). Sizes `Small` (760 × 540), `Large` (1400 × 880, 0.8 on Mobile), `Screen` (1600 × 920, 0.78 on Mobile). Colours `Royal` (premium, VIP) and `Ember` (events) |
| `Button.lua` | Default: a blue skin (`Skin`, `SelectedSkin`, `DisabledSkin` grey), 96 tall, text 40 lifted above the lip (`TextLift`), a drop, a bouncy press and sounds. Jobs: `Primary` (yellow and slanted: the skin names its height, `wb-skin-slant_yellow_{height}`), `Secondary` (blue), `Price` and `Confirm` (green), `Danger` (red), `Event` (purple), `Tab` (slate, blue when selected), `Muted` (grey). Sizes: `Small` (text 32), `Large` (112), `Hero` (144), `Square` (no side padding, for an icon). `Close` (the Hazard plate's slanted close) |
| `Box.lua` | Default: a slot (black, 30 % fading to 18 %, no outline), a cyan title. `Panel`: a window without the plate (the `frame_window` skin, the sea gradient, a `header_sea` band). `Hud`: a darker slot for the match's hud. `Pill`: the dark pill (currencies). `Card`: a raised slate card for people and places, with `Winner` (gold), `Event` (purple) and `Highlight` (blue). `Badge`: a notification pill on a button's corner (the `dot_red` skin stretched; FREE, a count). `PlatformScale` (Desktop 0.75) for a `Screen` box |
| `Item.lua` | Default: a thing on a slot, the picture over its name and one line. `Square`, `Small` (112), `Difficulty` (200 × 220, the line in the coins' colour). Rewards `Common` … `Legendary`: a framed tile, the rarity's stage inside (`Stage`), silver for common to rare and gold with light behind (`Glow`, rays) for epic and legendary |
| `Label.lua` | Default: the ink outline. `Heading`, `Title`, `Hero` (capitals, heavy outline). Tones `Accent`, `Map`, `Cream`, `Gold`, `Price` |
| `Picture.lua` | `Avatar`, `AvatarLarge` (a light well, the 6 px ink outline), `Thumbnail` (rounded, ink outline), `Icon` (a bare picture bigger than a glyph) |
| `Cells.lua` | `Players`, `Slots` (grids of player cards) |
| `Ribbon.lua` | From the first Brawl options, used by no gui now; `Blue` and `Red` name tokens this palette no longer has |

## Controls

The theme's own controls (`Controls/`), found before the base theme's. Their params are in each module's `Params`.

### Slab

The kit's surface, a Folder of parts sized to the frame it's built in: `Drop` (the skin again, ink, a few px lower),
`Body` (the fill or gradient, inset and rounded), `Pattern`, and the skin image on top, named `Face` so game code
that finds a piece's face still does. A skin is 9-sliced when `Skins.lua` has its centre, stretched whole otherwise.
`Slab.SetSkin(slab, name, scale, ctx)` swaps the skin on a built slab. Handle: `Skin`, `Drop`, `Body`. Game code
shows a slot as picked by recolouring its `Body` (`BackgroundColor3`, `BackgroundTransparency`), never `Face`.

### Button

The shared Button's structure with a skin behind the text. States: `Pressed` tints the skin, `Selected` and
`Disabled` swap it (`SelectedSkin`, `DisabledSkin`). `Icon`: a picture at the left, or alone in the middle when
`Text` is `""`. `AutoWidth` doesn't count the icon: don't use both. `Screen` gives one placed on the screen by itself
(the match's touch buttons) an `S_ScreenScale` and the `Utils_PlatformScale` tag from the style's `PlatformScale`.

Exports can't run the control, so its `Face` records its three skins for game code, which swaps `Face.Image` to show
a state:

| Attribute on `Face` | Image |
| --- | --- |
| `Kit_Image` | The skin at rest |
| `Kit_SelectedImage` | `SelectedSkin` (a picked tab, mode or size) |
| `Kit_DisabledImage` | `DisabledSkin` (owned, locked) |

### Widget

The Hazard plate window in WidgetManager's shape: `Bg_Bottom` holds the window slab, `Bg_Top` (rising `PlateRise`
above the window) the plate with `Title` and the close button, `Content` starts under the plate. Params `Title` and
`Close`; `SetTitle` on the handle. Tagged `Utils_PlatformScale` from the style's `PlatformScale`.

### Box

The base theme's `Box`, its look from this theme's `Slab`. With `Screen`, it's also tagged `Utils_PlatformScale` from
the style's `PlatformScale`.

### Item

A thing on a slot, or a reward tile with a rarity style: `Stage`, then `Rays` and `Glow` for the best, under the
frame skin; the picture (`S_Icon`) takes the height the name (`S_Name`) and the line (`S_Info`) leave. Children go
in an `Overlay` over the whole tile. `Screen` gives one placed on the screen by itself (the match's emote button) an
`S_ScreenScale` and the `Utils_PlatformScale` tag from the style's `PlatformScale`.

A reward tile (a rarity style) is built once and shows any rarity at runtime, so its `Rays` and `Glow` are always
built (shown only when its style glows), and its container records every rarity's look for game code (the crate
reveal):

| Attribute on the tile, for each `<Rarity>` (`Common` … `Legendary`) | Value |
| --- | --- |
| `Kit_<Rarity>_Frame` | The frame skin's image, for `Face` |
| `Kit_<Rarity>_Stage` | The stage's image, for `Stage` |
| `Kit_<Rarity>_Glow` | Whether `Rays` and `Glow` show |
| `Kit_<Rarity>_GlowColor` | Their `ImageColor3` |

### Ribbon

A slanted banner behind a big title, from the first Brawl options; no gui uses it now.

## Generated

- `Icons.lua` and `Skins.lua` are written by the kit's build script, made outside this repo (the game home's
  `assets/_inbox/ui_kit_brawl/`: `skins.py` and `banners.py` draw the SVGs, `build.py` renders them). `Skins.lua`
  holds each sliced skin's `SliceCenter` in its PNG's pixels. The kit was uploaded on 2026-11-04: every `Icons.lua`
  line is an `rbxassetid://`. A rebuild writes local previews (`rbxasset://textures/wb_brawlpreview/…`, which only
  the PC that built them shows) until the changed pictures are uploaded and the ids put back (the kit's README →
  Uploading).
- No `Gamepad.lua`: the theme uses System's gamepad icons.
