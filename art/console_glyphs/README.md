# Worm Battlegrounds: console button glyphs

The game's own gamepad button pictures, for Xbox and PlayStation, drawn for the hints in its guis (the code folder's
`src/modules/Main/0_Console`, `Console_Hint`). Made from code: every glyph is a few shapes in `make_glyphs.py`, written
as an SVG and rendered to PNG. Nothing is uploaded: the game shows the System theme's uploaded icons until the owner
approves these (the game's `practices.md` → Guis: pictures stay local until approved).

The look: chunky, rounded marks with a dark outline (`#14121c`), a lip along the bottom, a soft light on top and a
drop under them, like the game's GUI kit and Londrina Solid. Letters are round-capped strokes. Xbox's face buttons are
their own green, red, blue and yellow with a white letter; PlayStation's are slate with the symbol in its colour (the
cross blue, the circle red, the square pink, the triangle green). Everything else (bumpers, triggers, sticks, the
D-pad, View, Menu, Options, Share, the touchpad) is neutral slate with white marks, so no team colour is implied. They
are drawn on a 128 canvas and read at 32 to 48 px on dark, light, sand and sea backgrounds (`preview.html`).

| File | What |
| --- | --- |
| `make_glyphs.py` | The glyphs (shapes, letters, colours), the SVG writer, the PNG renderer, the preview page and the Lua for the upload |
| `svg/xbox/<KeyCode>.svg`, `svg/playstation/<KeyCode>.svg` | The sources, one per `Enum.KeyCode` name (`ButtonA` … `DPadRight`, `Thumbstick1`, `ButtonSelect`, `ButtonStart`; PlayStation also `ButtonShare`) |
| `out/png/<pad>/<KeyCode>.png` | 256 × 256 PNGs, the upload size (build output, not kept) |
| `out/png64/<pad>/<KeyCode>.png` | 64 × 64, how they read small (build output) |
| `out/glyphs.json` | The glyph list per pad (build output) |
| `preview.html` | Every glyph as its SVG at 96 px and its PNG at 48 and 32 px, on dark, light, sand and sea (build output) |

Names follow Roblox: on a PlayStation pad `ButtonA` is Cross, `ButtonB` Circle, `ButtonX` Square, `ButtonY` Triangle,
`ButtonSelect` the touchpad press and `ButtonStart` Options; on Xbox `ButtonSelect` is View and `ButtonStart` Menu.
`ButtonStart` is Roblox's own menu button: the game never binds it, so its glyph is only for completeness.

## Build

Python 3 with Pillow. When `cairosvg` is installed it renders the PNGs from the SVG files; otherwise the script's own
Pillow renderer draws the same shapes, 4× supersampled (checked against Edge's rendering of the SVGs: the same
picture).

```bash
python -I make_glyphs.py            # svg/, out/, preview.html
python -I make_glyphs.py --check    # also each PNG's size and how much of it is drawn
```

Change a glyph in `make_glyphs.py` (`glyphs()` lists them, the colours are at the top), never in its SVG: the next
build writes the SVGs again.

## Uploading

Only when the owner approves them:

1. Upload `out/png/<pad>/*.png` to The Snail Studio group (566704940) as Decals or Images with plain titles
   ("Pad Xbox A", "Pad PlayStation Cross"), the way the other kits are uploaded.
2. Write the ids in a JSON file, `{"Xbox/ButtonA": 123, "PlayStation/ButtonB": 456, ...}`, and run
   `python -I make_glyphs.py --lua ids.json`: it prints a `Glyph` icon style for each pad.
3. In the code folder's `src/modules/Main/0_Console/Settings.lua`, add each pad's `Glyph` table to `GAMEPAD_ICONS` and
   set `HINT_STYLE = "Glyph"`. Every hint that names an action (`Console_Action`) then shows the game's glyphs; the
   System guis' hints keep their own icons.
