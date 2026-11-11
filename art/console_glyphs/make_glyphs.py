"""Worm Battlegrounds' gamepad button glyphs: Xbox and PlayStation, in the game's chunky look.

Every glyph is a list of layers built from a few shapes (circles, ellipses, rounded rectangles, polygons and round
strokes) on a 128 x 128 canvas. The same layers are written as an SVG (svg/<pad>/<KeyCode>.svg, the kit's sources)
and rasterised to PNG: with cairosvg from the SVG when it is installed, otherwise by this file's own Pillow renderer
from the same layers (4x supersampled), so both paths draw the same picture.

    python -I make_glyphs.py            # svg/, out/png/<pad>/<KeyCode>.png (256 px), out/png64/..., preview.html
    python -I make_glyphs.py --check    # also prints each PNG's size and how much of it is drawn
    python -I make_glyphs.py --lua ids.json   # after the upload: the Console module's "Glyph" icon style, as Lua

Files are named after Roblox's Enum.KeyCode names, as the Console module's GAMEPAD_ICONS are, so the uploaded ids drop
straight into a "Glyph" icon style there (README -> Uploading).
"""

from __future__ import annotations

import base64
import html
import json
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
SVG_DIR = HERE / "svg"
OUT_DIR = HERE / "out"
SIZE = 128  # the design canvas
PNG_SIZE = 256  # the upload size
SMALL_SIZE = 64  # a check of how it reads small
SUPERSAMPLE = 4

# --- Look -----------------------------------------------------------------------------------------------------------

OUTLINE = "#14121c"  # the dark outline round every body and letter
DROP = "#000000"  # the drop under every glyph
DROP_OPACITY = 0.45
DROP_Y = 6
BODY_OUTLINE = 7  # outline round a body
LETTER_OUTLINE = 5  # outline round a letter or symbol
LIP = 6  # the darker band along a body's bottom
LIGHT_OPACITY = 0.22  # the light on a body's top
WHITE = "#ffffff"

SLATE = ("#3b3e52", "#25273a")  # neutral bodies: fill, lip
WHITE_KEY = ("#f2f2f7", "#a9abbd")  # a pressed D-pad arm
XBOX_FACE = {
    "ButtonA": ("#3dbe3b", "#22801f"),
    "ButtonB": ("#ee3a38", "#a3201e"),
    "ButtonX": ("#2e8cf0", "#1a5db0"),
    "ButtonY": ("#ffc21c", "#c48a00"),
}
PS_SYMBOL = {
    "ButtonA": "#7fa8ff",  # cross, blue
    "ButtonB": "#ff5a64",  # circle, red
    "ButtonX": "#f27bd0",  # square, pink
    "ButtonY": "#3fd9a6",  # triangle, green
}

# --- Shapes ---------------------------------------------------------------------------------------------------------
# A shape is a dict: {"t": "circle"|"ellipse"|"rrect"|"poly"|"stroke", ...geometry, "fill"/"color"}.
# A layer is {"opacity": float, "shapes": [...]}: its shapes are drawn opaque together, then the layer at its opacity.


def circle(cx, cy, r, fill):
    return {"t": "circle", "cx": cx, "cy": cy, "r": r, "fill": fill}


def ellipse(cx, cy, rx, ry, fill):
    return {"t": "ellipse", "cx": cx, "cy": cy, "rx": rx, "ry": ry, "fill": fill}


def rrect(x, y, w, h, r, fill):
    return {"t": "rrect", "x": x, "y": y, "w": w, "h": h, "r": min(r, w / 2, h / 2), "fill": fill}


def poly(points, fill):
    return {"t": "poly", "pts": [tuple(p) for p in points], "fill": fill}


def stroke(points, width, color, closed=False):
    pts = [tuple(p) for p in points]
    if closed:
        pts = pts + [pts[0], pts[1]]
    return {"t": "stroke", "pts": pts, "w": width, "color": color}


def layer(shapes, opacity=1.0):
    return {"opacity": opacity, "shapes": shapes}


def grown(shape, by, fill):
    """The same shape grown by some units all round, in another colour (outlines, drops)."""
    s = dict(shape)
    t = s["t"]
    if t == "circle":
        s["r"] += by
    elif t == "ellipse":
        s["rx"] += by
        s["ry"] += by
    elif t == "rrect":
        s.update(x=s["x"] - by, y=s["y"] - by, w=s["w"] + 2 * by, h=s["h"] + 2 * by, r=s["r"] + by)
    elif t == "poly":
        s["grow"] = by
    elif t == "stroke":
        s["w"] += 2 * by
    if "fill" in s:
        s["fill"] = fill
    if "color" in s:
        s["color"] = fill
    return s


def moved(shape, dx, dy):
    s = dict(shape)
    t = s["t"]
    if t in ("circle", "ellipse"):
        s["cx"] += dx
        s["cy"] += dy
    elif t == "rrect":
        s["x"] += dx
        s["y"] += dy
    else:
        s["pts"] = [(x + dx, y + dy) for x, y in s["pts"]]
    return s


def lipped(shape, fill):
    """The body's top face: the shape lifted off its bottom by LIP, so the lip shows under it."""
    s = dict(shape, fill=fill)
    if s["t"] == "circle":
        s["cy"] -= LIP / 2
        s["r"] -= LIP / 2
    elif s["t"] == "rrect":
        s["h"] -= LIP
        s["r"] = min(s["r"], s["w"] / 2, s["h"] / 2)
    return s


def light(shape):
    """A soft light on the top of a body."""
    if shape["t"] == "circle":
        r = shape["r"]
        return ellipse(shape["cx"], shape["cy"] - r * 0.36, r * 0.6, r * 0.32, WHITE)
    x, y, w, h = shape["x"], shape["y"], shape["w"], shape["h"]
    return rrect(x + w * 0.14, y + h * 0.1, w * 0.72, h * 0.3, h * 0.15, WHITE)


def body(shapes, colours):
    """Layers for a raised body: its drop, its outline, the lip, the face, the light."""
    fill, lip = colours
    return [
        layer([moved(grown(s, BODY_OUTLINE, DROP), 0, DROP_Y) for s in shapes], DROP_OPACITY),
        layer([grown(s, BODY_OUTLINE, OUTLINE) for s in shapes]),
        layer([dict(s, fill=lip) for s in shapes]),
        layer([lipped(s, fill) for s in shapes]),
        layer([light(s) for s in shapes if s["t"] in ("circle", "rrect")], LIGHT_OPACITY),
    ]


def mark(shapes, colour=WHITE, drop=True):
    """Layers for a mark on a body (a letter, a symbol, an arrow): a small drop, its outline, the mark."""
    layers = []
    if drop:
        layers.append(layer([moved(grown(s, LETTER_OUTLINE, DROP), 0, 3) for s in shapes], 0.35))
    layers.append(layer([grown(s, LETTER_OUTLINE, OUTLINE) for s in shapes]))
    layers.append(layer([dict(s, **({"fill": colour} if "fill" in s else {"color": colour})) for s in shapes]))
    return layers


# --- Letters --------------------------------------------------------------------------------------------------------
# Chunky stroke letters on a unit box (1 tall, y down), drawn with round caps and joins like Londrina Solid's.


def arc(cx, cy, r, a0, a1, n=14):
    return [(cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)), cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]


LETTERS = {
    "A": (0.86, [[(0, 1), (0.43, 0), (0.86, 1)], [(0.2, 0.66), (0.66, 0.66)]]),
    "B": (0.7, [[(0, 0), (0, 1)], [(0, 0), (0.4, 0)] + arc(0.4, 0.25, 0.25, -90, 90) + [(0, 0.5)], [(0, 0.5), (0.45, 0.5)] + arc(0.45, 0.75, 0.25, -90, 90) + [(0, 1)]]),
    "X": (0.8, [[(0, 0), (0.8, 1)], [(0.8, 0), (0, 1)]]),
    "Y": (0.84, [[(0, 0), (0.42, 0.5), (0.84, 0)], [(0.42, 0.5), (0.42, 1)]]),
    "L": (0.6, [[(0, 0), (0, 1), (0.6, 1)]]),
    "R": (0.7, [[(0, 1), (0, 0), (0.4, 0)] + arc(0.4, 0.26, 0.26, -90, 90) + [(0, 0.52)], [(0.32, 0.52), (0.7, 1)]]),
    "T": (0.8, [[(0, 0), (0.8, 0)], [(0.4, 0), (0.4, 1)]]),
    "S": (0.64, [arc(0.32, 0.26, 0.26, -20, -270) + arc(0.32, 0.76, 0.24, -90, 150)]),
    "1": (0.34, [[(0, 0.22), (0.34, 0), (0.34, 1)]]),
    "2": (0.66, [arc(0.33, 0.3, 0.3, 195, 375) + [(0, 1), (0.66, 1)]]),
    "3": (0.62, [arc(0.3, 0.26, 0.26, 200, 450) + arc(0.3, 0.75, 0.25, 270, 510)]),
}


def text(word, cx, cy, height, gap=0.22):
    """Stroke shapes for a word centred on a point, its letters `height` tall."""
    sw = height * 0.24
    widths = [LETTERS[c][0] for c in word]
    total = (sum(widths) + gap * (len(word) - 1)) * height
    x = cx - total / 2
    y = cy - height / 2
    shapes = []
    for c, w in zip(word, widths):
        for line in LETTERS[c][1]:
            shapes.append(stroke([(x + px * height, y + py * height) for px, py in line], sw, WHITE))
        x += (w + gap) * height
    return shapes


# --- Glyphs ---------------------------------------------------------------------------------------------------------


def face_xbox(key, letter):
    disc = circle(64, 60, 47, None)
    return body([disc], XBOX_FACE[key]) + mark(text(letter, 64, 57, 46))


def face_ps(key):
    disc = circle(64, 60, 47, None)
    colour = PS_SYMBOL[key]
    w = 11
    if key == "ButtonA":
        shapes = [stroke([(44, 37), (84, 77)], w, colour), stroke([(84, 37), (44, 77)], w, colour)]
    elif key == "ButtonB":
        shapes = [stroke(arc(64, 57, 21, 0, 360, 36), w, colour, closed=True)]
    elif key == "ButtonX":
        shapes = [stroke([(45, 38), (83, 38), (83, 76), (45, 76)], w, colour, closed=True)]
    else:
        shapes = [stroke([(64, 34), (86, 72), (42, 72)], w, colour, closed=True)]
    return body([disc], SLATE) + mark(shapes, colour)


def bumper(label):
    return body([rrect(12, 32, 104, 58, 29, None)], SLATE) + mark(text(label, 64, 59, 34))


def trigger(label):
    return body([rrect(20, 14, 88, 92, 30, None)], SLATE) + mark(text(label, 64, 56, 36))


def stick(label, pressed=False):
    cy = 70 if pressed else 64
    layers = body([circle(64, cy, 40, None)], SLATE)
    # The stick's dished top
    layers.append(layer([circle(64, cy - 3, 28, "#2f3245")]))
    layers += mark(text(label, 64, cy - 3, 28 if len(label) == 1 else 24))
    if pressed:
        # A press arrow coming down onto the stick
        layers += mark([poly([(45, 7), (83, 7), (64, 29)], WHITE)])
    return layers


DPAD_ARMS = {
    "DPadUp": rrect(46, 12, 36, 50, 9, None),
    "DPadDown": rrect(46, 62, 36, 46, 9, None),
    "DPadLeft": rrect(14, 44, 50, 36, 9, None),
    "DPadRight": rrect(64, 44, 50, 36, 9, None),
}
DPAD_ARROWS = {
    "DPadUp": [(64, 20), (74, 34), (54, 34)],
    "DPadDown": [(64, 100), (54, 86), (74, 86)],
    "DPadLeft": [(22, 62), (36, 52), (36, 72)],
    "DPadRight": [(106, 62), (92, 72), (92, 52)],
}


def dpad(pressed=None):
    bars = [rrect(14, 44, 100, 36, 9, None), rrect(46, 12, 36, 98, 9, None)]
    layers = body(bars, SLATE)
    if pressed:
        arm = DPAD_ARMS[pressed]
        layers.append(layer([dict(arm, fill=WHITE_KEY[0])]))
        layers.append(layer([poly(DPAD_ARROWS[pressed], "#22222e")]))
        return layers
    layers += mark([poly(points, WHITE) for points in DPAD_ARROWS.values()], drop=False)
    return layers


def small_button(icon_shapes):
    return body([circle(64, 62, 40, None)], SLATE) + mark(icon_shapes)


def view_icon():
    w = 7
    back = stroke([(44, 46), (72, 46), (72, 66), (44, 66)], w, WHITE, closed=True)
    front = stroke([(56, 56), (84, 56), (84, 78), (56, 78)], w, WHITE, closed=True)
    return [back, front]


def menu_icon(x0=46, x1=82, ys=(48, 61, 74), w=7):
    return [stroke([(x0, y), (x1, y)], w, WHITE) for y in ys]


def options():
    pill = rrect(40, 8, 48, 104, 24, None)
    return body([pill], SLATE) + mark(menu_icon(54, 74, (44, 57, 70), 7))


def share():
    pill = rrect(40, 8, 48, 104, 24, None)
    arrow = [stroke([(64, 74), (64, 34)], 8, WHITE), stroke([(51, 47), (64, 34), (77, 47)], 8, WHITE)]
    return body([pill], SLATE) + mark(arrow)


def touchpad():
    pad = rrect(8, 26, 112, 72, 16, None)
    return body([pad], SLATE) + mark([circle(64, 58, 9, WHITE)]) + mark([stroke([(36, 82), (92, 82)], 5, WHITE)], drop=False)


def glyphs():
    xbox = {
        "ButtonA": face_xbox("ButtonA", "A"),
        "ButtonB": face_xbox("ButtonB", "B"),
        "ButtonX": face_xbox("ButtonX", "X"),
        "ButtonY": face_xbox("ButtonY", "Y"),
        "ButtonL1": bumper("LB"),
        "ButtonR1": bumper("RB"),
        "ButtonL2": trigger("LT"),
        "ButtonR2": trigger("RT"),
        "Thumbstick1": stick("L"),
        "Thumbstick2": stick("R"),
        "ButtonL3": stick("L", pressed=True),
        "ButtonR3": stick("R", pressed=True),
        "DPad": dpad(),
        "DPadUp": dpad("DPadUp"),
        "DPadDown": dpad("DPadDown"),
        "DPadLeft": dpad("DPadLeft"),
        "DPadRight": dpad("DPadRight"),
        "ButtonSelect": small_button(view_icon()),
        "ButtonStart": small_button(menu_icon()),
    }
    playstation = {
        "ButtonA": face_ps("ButtonA"),
        "ButtonB": face_ps("ButtonB"),
        "ButtonX": face_ps("ButtonX"),
        "ButtonY": face_ps("ButtonY"),
        "ButtonL1": bumper("L1"),
        "ButtonR1": bumper("R1"),
        "ButtonL2": trigger("L2"),
        "ButtonR2": trigger("R2"),
        "Thumbstick1": stick("L"),
        "Thumbstick2": stick("R"),
        "ButtonL3": stick("L3", pressed=True),
        "ButtonR3": stick("R3", pressed=True),
        "DPad": dpad(),
        "DPadUp": dpad("DPadUp"),
        "DPadDown": dpad("DPadDown"),
        "DPadLeft": dpad("DPadLeft"),
        "DPadRight": dpad("DPadRight"),
        # Roblox names the touchpad press ButtonSelect on a PlayStation pad, and Options ButtonStart
        "ButtonSelect": touchpad(),
        "ButtonStart": options(),
        "ButtonShare": share(),
    }
    return {"Xbox": xbox, "PlayStation": playstation}


# What each glyph is, for the preview
NAMES = {
    "Xbox": {"ButtonSelect": "View", "ButtonStart": "Menu", "ButtonL1": "LB", "ButtonR1": "RB", "ButtonL2": "LT", "ButtonR2": "RT", "ButtonL3": "LS click", "ButtonR3": "RS click"},
    "PlayStation": {"ButtonA": "Cross", "ButtonB": "Circle", "ButtonX": "Square", "ButtonY": "Triangle", "ButtonSelect": "Touchpad", "ButtonStart": "Options", "ButtonShare": "Share", "ButtonL3": "L3", "ButtonR3": "R3"},
}

# --- SVG ------------------------------------------------------------------------------------------------------------


def fmt(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def poly_points(pts):
    return " ".join(f"{fmt(x)},{fmt(y)}" for x, y in pts)


def svg_shape(s):
    t = s["t"]
    if t == "circle":
        return f'<circle cx="{fmt(s["cx"])}" cy="{fmt(s["cy"])}" r="{fmt(s["r"])}" fill="{s["fill"]}"/>'
    if t == "ellipse":
        return f'<ellipse cx="{fmt(s["cx"])}" cy="{fmt(s["cy"])}" rx="{fmt(s["rx"])}" ry="{fmt(s["ry"])}" fill="{s["fill"]}"/>'
    if t == "rrect":
        return f'<rect x="{fmt(s["x"])}" y="{fmt(s["y"])}" width="{fmt(s["w"])}" height="{fmt(s["h"])}" rx="{fmt(s["r"])}" fill="{s["fill"]}"/>'
    if t == "poly":
        grow = s.get("grow", 0)
        extra = f' stroke="{s["fill"]}" stroke-width="{fmt(grow * 2)}" stroke-linejoin="round"' if grow else ""
        return f'<polygon points="{poly_points(s["pts"])}" fill="{s["fill"]}"{extra}/>'
    return f'<polyline points="{poly_points(s["pts"])}" fill="none" stroke="{s["color"]}" stroke-width="{fmt(s["w"])}" stroke-linecap="round" stroke-linejoin="round"/>'


def to_svg(layers, title):
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" width="{SIZE}" height="{SIZE}">', f"<title>{html.escape(title)}</title>"]
    for item in layers:
        if not item["shapes"]:
            continue
        opacity = f' opacity="{fmt(item["opacity"])}"' if item["opacity"] < 1 else ""
        parts.append(f"<g{opacity}>" + "".join(svg_shape(s) for s in item["shapes"]) + "</g>")
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


# --- PNG ------------------------------------------------------------------------------------------------------------


def hex_rgb(colour):
    colour = colour.lstrip("#")
    return tuple(int(colour[i : i + 2], 16) for i in (0, 2, 4))


def draw_shape(draw, s, k):
    t = s["t"]
    if t == "circle":
        cx, cy, r = s["cx"] * k, s["cy"] * k, s["r"] * k
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=hex_rgb(s["fill"]))
    elif t == "ellipse":
        cx, cy, rx, ry = s["cx"] * k, s["cy"] * k, s["rx"] * k, s["ry"] * k
        draw.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=hex_rgb(s["fill"]))
    elif t == "rrect":
        x, y, w, h, r = s["x"] * k, s["y"] * k, s["w"] * k, s["h"] * k, s["r"] * k
        draw.rounded_rectangle((x, y, x + w, y + h), radius=r, fill=hex_rgb(s["fill"]))
    elif t == "poly":
        pts = [(x * k, y * k) for x, y in s["pts"]]
        colour = hex_rgb(s["fill"])
        draw.polygon(pts, fill=colour)
        grow = s.get("grow", 0) * k
        if grow:
            round_line(draw, pts + [pts[0]], grow * 2, colour)
    else:
        round_line(draw, [(x * k, y * k) for x, y in s["pts"]], s["w"] * k, hex_rgb(s["color"]))


def round_line(draw, pts, width, colour):
    """A polyline with round caps and joins: Pillow's line plus a disc at every point."""
    draw.line(pts, fill=colour, width=max(1, round(width)), joint="curve")
    r = width / 2
    for x, y in pts:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=colour)


def render(layers, size):
    k = size * SUPERSAMPLE / SIZE
    big = size * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    for item in layers:
        if not item["shapes"]:
            continue
        sheet = Image.new("RGBA", (big, big), (0, 0, 0, 0))
        draw = ImageDraw.Draw(sheet)
        for s in item["shapes"]:
            draw_shape(draw, s, k)
        if item["opacity"] < 1:
            alpha = sheet.getchannel("A").point(lambda a, o=item["opacity"]: round(a * o))
            sheet.putalpha(alpha)
        image = Image.alpha_composite(image, sheet)
    return image.resize((size, size), Image.LANCZOS)


def render_png(svg_path, layers, size, out_path):
    try:
        import cairosvg  # optional: renders the SVG file itself

        cairosvg.svg2png(url=str(svg_path), write_to=str(out_path), output_width=size, output_height=size)
        return "cairosvg"
    except ImportError:
        render(layers, size).save(out_path)
        return "pillow"


# --- Preview --------------------------------------------------------------------------------------------------------


def preview(sets):
    rows = []
    for pad, items in sets.items():
        cells = []
        for key in items:
            svg = (SVG_DIR / pad.lower() / f"{key}.svg").read_text(encoding="utf-8")
            svg = svg.split("\n", 1)[1] if svg.startswith("<?xml") else svg
            label = NAMES[pad].get(key, key.replace("Button", "").replace("Thumbstick1", "Left stick").replace("Thumbstick2", "Right stick"))
            # Embedded, so the page works wherever it's opened
            png = "data:image/png;base64," + base64.b64encode((OUT_DIR / "png64" / pad.lower() / f"{key}.png").read_bytes()).decode()
            cells.append(
                f'<figure><div class="big">{svg}</div><div class="sizes"><img src="{png}" width="48" height="48" alt=""><img src="{png}" width="32" height="32" alt=""></div><figcaption><b>{html.escape(label)}</b><code>{key}</code></figcaption></figure>'
            )
        rows.append(f'<section><h2>{pad}</h2><div class="grid">{"".join(cells)}</div></section>')
    body = "".join(rows)
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Console Glyphs</title>
<style>
:root {{ --bg: #16151d; --card: #22212c; --text: #f2f2f7; --dim: #a9abbd; }}
body {{ margin: 0; font: 15px/1.4 system-ui, sans-serif; background: var(--bg); color: var(--text); }}
header, section {{ max-width: 1180px; margin: 0 auto; padding: 16px; }}
h1 {{ margin: 8px 0 4px; font-size: 26px; }} h2 {{ margin: 24px 0 8px; font-size: 20px; }}
p {{ color: var(--dim); margin: 0; }}
.switch {{ margin-top: 12px; display: flex; gap: 8px; flex-wrap: wrap; }}
.switch button {{ font: inherit; padding: 6px 12px; border-radius: 8px; border: 2px solid #3b3e52; background: var(--card); color: var(--text); cursor: pointer; }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 12px; }}
figure {{ margin: 0; padding: 12px 8px; border-radius: 12px; background: var(--card); text-align: center; }}
.big svg {{ width: 96px; height: 96px; display: block; margin: 0 auto; }}
.sizes {{ display: flex; gap: 10px; justify-content: center; align-items: end; margin-top: 8px; min-height: 48px; }}
figcaption {{ margin-top: 6px; display: grid; gap: 2px; }} code {{ color: var(--dim); font-size: 12px; }}
body.light {{ --bg: #eef0f5; --card: #ffffff; --text: #1d1c26; --dim: #5b5d70; }}
body.sand {{ --bg: #e9c98f; --card: #f3dcae; --text: #3a2a12; --dim: #6b5530; }}
body.sea {{ --bg: #1f6f7a; --card: #2a8794; --text: #ffffff; --dim: #d6f2f5; }}
</style></head>
<body>
<header><h1>Worm Battlegrounds console glyphs</h1>
<p>Each glyph at 96 px (the SVG), then its PNG (rendered at 64 px) at 48 and 32 px, the hint sizes in game. Local only: nothing here is uploaded.</p>
<div class="switch"><button onclick="document.body.className=''">Dark</button><button onclick="document.body.className='light'">Light</button><button onclick="document.body.className='sand'">Sand</button><button onclick="document.body.className='sea'">Sea</button></div></header>
{body}
</body></html>
"""


# --- Main -----------------------------------------------------------------------------------------------------------


def lua_style(ids_path):
    """Prints the Glyph icon style of both pads for the Console module's GAMEPAD_ICONS, from the uploaded ids
    ({"Xbox/ButtonA": 123, ...}); a glyph with no id is left out, so its button keeps the Color style's icon."""
    ids = json.loads(Path(ids_path).read_text(encoding="utf-8"))
    for pad, items in glyphs().items():
        print(f"-- {pad} = {{ ..., add:")
        print("			Glyph = {")
        for key in items:
            asset = ids.get(f"{pad}/{key}")
            if asset:
                print(f'				{key} = "rbxassetid://{asset}",')
        print("			},")


def main():
    if "--lua" in sys.argv:
        lua_style(sys.argv[sys.argv.index("--lua") + 1])
        return
    check = "--check" in sys.argv
    sets = glyphs()
    renderer = None
    manifest = {}
    for pad, items in sets.items():
        svg_dir = SVG_DIR / pad.lower()
        png_dir = OUT_DIR / "png" / pad.lower()
        small_dir = OUT_DIR / "png64" / pad.lower()
        for folder in (svg_dir, png_dir, small_dir):
            folder.mkdir(parents=True, exist_ok=True)
        manifest[pad] = []
        for key, layers in items.items():
            svg_path = svg_dir / f"{key}.svg"
            svg_path.write_text(to_svg(layers, f"{pad} {NAMES[pad].get(key, key)}"), encoding="utf-8")
            renderer = render_png(svg_path, layers, PNG_SIZE, png_dir / f"{key}.png")
            render_png(svg_path, layers, SMALL_SIZE, small_dir / f"{key}.png")
            manifest[pad].append(key)
            if check:
                image = Image.open(png_dir / f"{key}.png")
                drawn = 1 - image.getchannel("A").histogram()[0] / (PNG_SIZE * PNG_SIZE)
                print(f"{pad:12} {key:13} {image.size[0]}x{image.size[1]} drawn {drawn:5.1%}")
    (OUT_DIR / "glyphs.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    (HERE / "preview.html").write_text(preview(sets), encoding="utf-8")
    count = sum(len(v) for v in manifest.values())
    print(f"{count} glyphs: svg/, out/png (256 px, {renderer}), out/png64, preview.html")


if __name__ == "__main__":
    main()
