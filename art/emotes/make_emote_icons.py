"""The emotes' icons, in the game's icon style (bold shapes, the ink outline, flat colours with a light edge): what the
emote does, drawn with the snail's own pink, its purple spots and its beaded eyestalks. They show on the EmoteShop
cards and in the bubble over a snail that plays the emote. python -I make_emote_icons.py

Each icon is an SVG on a 256 x 256 grid; out/Emote_<Id>.svg and, drawn by Chrome or Edge through the crate kit's
build.py, out/Emote_<Id>.png (256 x 256, transparent, pixel-fixed) and out/sheet.png. Nothing here uploads anything.
"""

import math
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

INK = "#1b1530"
PINK = "#f6a6d6"
PINK_DARK = "#e07fbf"
PINK_LIGHT = "#ffd3ec"
SPOT = "#9b4fd0"
BEAD = "#2a2378"
OW = 9  # the ink outline's width


def svg(body, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">'
            f'<defs>{defs}</defs>{body}</svg>')


def outlined(shapes, fill, extra=""):
    """Shapes merged into one silhouette: all drawn thick in ink first, then all filled on top."""
    ink = "".join(s.replace("FILL", INK).replace("/>", f' stroke="{INK}" stroke-width="{OW * 2}" stroke-linejoin="round"/>') for s in shapes)
    paint = "".join(s.replace("FILL", fill) for s in shapes)
    return ink + paint + extra


def rrect(x, y, w, h, r, rot=0, cx=None, cy=None):
    t = f' transform="rotate({rot} {cx if cx is not None else x + w / 2} {cy if cy is not None else y + h / 2})"' if rot else ""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="FILL"{t}/>'


def ellipse(cx, cy, rx, ry, rot=0):
    t = f' transform="rotate({rot} {cx} {cy})"' if rot else ""
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="FILL"{t}/>'


def path(d):
    return f'<path d="{d}" fill="FILL"/>'


def arc_stroke(d, width=10, colour=INK):
    return f'<path d="{d}" fill="none" stroke="{colour}" stroke-width="{width}" stroke-linecap="round"/>'


def spot(cx, cy, r=7):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{SPOT}"/><circle cx="{cx - r * 0.3}" cy="{cy - r * 0.3}" r="{r * 0.35}" fill="#c99bf0"/>'


# ------------------------------------------------------------------------------------------------------- hands


def hand(fingers_spread=True):
    """An open snail hand: a round palm, four fingers and a thumb, upright, its wrist at the bottom (centre 128)."""
    shapes = [ellipse(128, 150, 50, 52)]
    for i, rot in enumerate((-22, -7, 8, 23) if fingers_spread else (-6, -2, 2, 6)):
        x = 96 + i * 21
        shapes.append(rrect(x - 13, 50 + abs(i - 1.5) * 9, 26, 84, 13, rot, x, 140))
    shapes.append(rrect(54, 128, 64, 28, 14, -38, 112, 146))
    shapes.append(rrect(108, 178, 44, 50, 14))
    return shapes


def wave():
    shapes = hand()
    body = ('<g transform="translate(14 6) scale(0.9) rotate(-14 128 170)">' + outlined(shapes, PINK, spot(128, 158, 8) + spot(108, 178, 5))
            + "</g>")
    body += arc_stroke("M 196 56 Q 220 86 210 124", 11) + arc_stroke("M 216 34 Q 248 82 234 136", 9)
    return svg(body)


def thumbs_up():
    shapes = [rrect(70, 108, 116, 96, 34),  # the fist
              rrect(96, 34, 42, 100, 21, -8, 117, 120),  # the thumb
              rrect(170, 120, 22, 70, 11)]  # the cuff of the fingers' tips
    extra = "".join(arc_stroke(f"M {150} {y} L {188} {y}", 8) for y in (134, 158, 182))
    extra += spot(104, 166, 8) + f'<rect x="80" y="116" width="12" height="40" rx="6" fill="{PINK_LIGHT}"/>'
    body = outlined(shapes, PINK, extra)
    # sparkle
    body += star(206, 64, 22, "#ffd84a") + star(52, 70, 13, "#ffffff")
    return svg(body)


def star(cx, cy, r, colour):
    pts = []
    for i in range(8):
        rr = r if i % 2 == 0 else r * 0.38
        a = math.pi / 4 * i - math.pi / 2
        pts.append(f"{cx + rr * math.cos(a):.1f},{cy + rr * math.sin(a):.1f}")
    return f'<polygon points="{" ".join(pts)}" fill="{colour}" stroke="{INK}" stroke-width="6" stroke-linejoin="round"/>'


def flex():
    """A dumbbell held up at a tilt, with a burst of effort round it."""
    plate, plate_dark, bar = "#4b5266", "#363b4c", "#c9d0d8"
    shapes = [rrect(56, 116, 144, 24, 12),  # the bar
              rrect(30, 78, 34, 100, 12), rrect(58, 92, 26, 72, 10),  # the left plates
              rrect(192, 78, 34, 100, 12), rrect(172, 92, 26, 72, 10)]  # the right plates
    grip = rrect(104, 108, 48, 40, 14)  # the snail's pink grip in the middle
    extra = (f'<rect x="38" y="88" width="8" height="78" rx="4" fill="#6f7891"/><rect x="200" y="88" width="8" height="78" rx="4" fill="#6f7891"/>'
             f'<rect x="64" y="121" width="128" height="6" rx="3" fill="#eef2f6"/>')
    body = '<g transform="rotate(-12 128 128)">' + outlined(shapes[:1], bar) + outlined(shapes[1:], plate, extra)
    body += outlined([grip], PINK, spot(128, 128, 7)) + "</g>"
    body += arc_stroke("M 60 54 L 46 32", 9) + arc_stroke("M 92 44 L 90 18", 9) + arc_stroke("M 196 214 L 212 236", 9)
    body += star(212, 52, 20, "#ffd84a") + star(48, 210, 14, "#ffffff")
    return svg(body)


# ------------------------------------------------------------------------------------------------------ faces


def snail_head(extra_eyes, mouth, after=""):
    """The snail's head from the front: a tall rounded head with two beaded eyestalks."""
    head = [path("M 58 246 L 58 132 Q 58 62 128 62 Q 198 62 198 132 L 198 246 Z")]
    stalks = ""
    for side in (-1, 1):
        x0, x1 = 128 + side * 26, 128 + side * 50
        stalks += (f'<line x1="{x0}" y1="72" x2="{x1}" y2="12" stroke="{INK}" stroke-width="26" stroke-linecap="round"/>'
                   f'<line x1="{x0}" y1="72" x2="{x1}" y2="12" stroke="{PINK}" stroke-width="10" stroke-linecap="round"/>')
        for t in (0.35, 0.72, 1.0):
            bx, by = x0 + (x1 - x0) * t, 72 + (12 - 72) * t
            stalks += f'<circle cx="{bx:.1f}" cy="{by:.1f}" r="9" fill="{BEAD}" stroke="{INK}" stroke-width="4"/>'
    spots = spot(80, 214, 8) + spot(182, 196, 6) + spot(168, 236, 5)
    shade = f'<path d="M 182 108 Q 194 132 192 246 L 174 246 Q 178 140 166 112 Z" fill="{PINK_DARK}" opacity="0.55"/>'
    return svg(stalks + outlined(head, PINK, shade + spots + extra_eyes + mouth + after))


def eye(cx, cy, look=(0, 0), r=(24, 30)):
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="{r[0]}" ry="{r[1]}" fill="#ffffff" stroke="{INK}" stroke-width="7"/>'
            f'<rect x="{cx - 8 + look[0]}" y="{cy - 15 + look[1]}" width="16" height="28" rx="3" fill="{INK}"/>')


def happy_eye(cx, cy):
    return arc_stroke(f"M {cx - 22} {cy + 8} Q {cx} {cy - 22} {cx + 22} {cy + 8}", 11)


def tear(cx, cy, s=1.0):
    return (f'<path d="M {cx} {cy - 22 * s} Q {cx + 15 * s} {cy} {cx} {cy + 12 * s} Q {cx - 15 * s} {cy} {cx} {cy - 22 * s} Z" '
            f'fill="#5cc8ff" stroke="{INK}" stroke-width="6" stroke-linejoin="round"/>')


def laugh():
    eyes = happy_eye(100, 128) + happy_eye(156, 128)
    mouth = (f'<path d="M 92 158 Q 128 162 164 158 Q 160 214 128 214 Q 96 214 92 158 Z" fill="#7d1f3d" stroke="{INK}" stroke-width="8" stroke-linejoin="round"/>'
             f'<path d="M 104 196 Q 128 180 152 196 Q 142 210 128 210 Q 114 210 104 196 Z" fill="#ff7aa8"/>'
             f'<rect x="102" y="160" width="52" height="12" rx="4" fill="#ffffff"/>')
    after = tear(56, 140, 0.9) + tear(200, 140, 0.9)
    return snail_head(eyes, mouth, after)


def taunt():
    eyes = eye(100, 128, (4, 2)) + arc_stroke("M 138 124 L 170 134 L 138 144", 10)
    mouth = (f'<path d="M 100 172 Q 128 186 160 168" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>'
             f'<path d="M 120 176 Q 122 214 138 214 Q 152 212 150 174 Z" fill="#ff5f8f" stroke="{INK}" stroke-width="7" stroke-linejoin="round"/>'
             f'<line x1="135" y1="182" x2="136" y2="204" stroke="#d9406f" stroke-width="4" stroke-linecap="round"/>')
    return snail_head(eyes, mouth)


def cry():
    eyes = eye(100, 126, (0, -6)) + eye(156, 126, (0, -6))
    brows = arc_stroke("M 80 100 L 114 88", 9) + arc_stroke("M 176 100 L 142 88", 9)
    mouth = arc_stroke("M 104 196 Q 128 172 152 196", 10)
    streams = (f'<path d="M 90 150 Q 86 190 92 246 L 108 246 Q 104 190 108 150 Z" fill="#5cc8ff" stroke="{INK}" stroke-width="6"/>'
               f'<path d="M 148 150 Q 152 190 146 246 L 162 246 Q 168 190 166 150 Z" fill="#5cc8ff" stroke="{INK}" stroke-width="6"/>')
    return snail_head(eyes + brows, mouth, streams + tear(46, 168, 0.8) + tear(212, 176, 0.7))


# ----------------------------------------------------------------------------------------------- the others


def note(x, y, colour, s=1.0, double=False):
    """A quaver (or two beamed together) with its stem up."""
    if double:
        shapes = [ellipse(x - 14 * s, y + 2 * s, 22 * s, 16 * s, -20), ellipse(x + 64 * s, y - 14 * s, 22 * s, 16 * s, -20),
                  path(f"M {x - 4 * s} {y - 96 * s} L {x + 83 * s} {y - 114 * s} L {x + 83 * s} {y - 88 * s} L {x - 4 * s} {y - 70 * s} Z"),
                  rrect(x - 4 * s, y - 100 * s, 9 * s, 100 * s, 4), rrect(x + 74 * s, y - 116 * s, 9 * s, 100 * s, 4)]
        return outlined(shapes, colour)
    head = ellipse(x - 14 * s, y + 2 * s, 22 * s, 16 * s, -20)
    stem = rrect(x - 4 * s, y - 92 * s, 9 * s, 94 * s, 4)
    flag = path(f"M {x + 4 * s} {y - 92 * s} Q {x + 40 * s} {y - 70 * s} {x + 30 * s} {y - 34 * s} Q {x + 26 * s} {y - 60 * s} {x + 4 * s} {y - 64 * s} Z")
    return outlined([head, stem, flag], colour)


def dance():
    body = note(70, 214, "#b48aff", 1.0, double=True) + note(196, 150, "#5cd6ff", 0.8)
    body += star(196, 210, 18, "#ffd84a") + star(44, 70, 14, "#ffffff") + star(150, 44, 11, "#ffd84a")
    return svg(body)


def backflip():
    # a loop of arrow round the middle, three quarters of a turn, with its head at the top
    r_out, r_in = 92, 58
    a0, a1 = math.radians(-60), math.radians(210)
    def pt(r, a):
        return f"{128 + r * math.cos(a):.1f} {136 + r * math.sin(a):.1f}"
    d = (f"M {pt(r_out, a0)} A {r_out} {r_out} 0 1 1 {pt(r_out, a1)} L {pt(r_in, a1)} "
         f"A {r_in} {r_in} 0 1 0 {pt(r_in, a0)} Z")
    tip_a = a0
    tx, ty = 128 + 75 * math.cos(tip_a), 136 + 75 * math.sin(tip_a)
    head = path(f"M {tx - 52:.1f} {ty - 20:.1f} L {tx + 28:.1f} {ty - 38:.1f} L {tx + 6:.1f} {ty + 44:.1f} Z")
    body = outlined([path(d), head], "#ffb43a", f'<path d="M {pt(84, math.radians(140))} A 84 84 0 0 1 {pt(84, math.radians(200))}" fill="none" stroke="#ffe28a" stroke-width="8" stroke-linecap="round"/>')
    # the snail's shell spinning in the loop
    body += (f'<circle cx="128" cy="136" r="34" fill="#f1d29a" stroke="{INK}" stroke-width="8"/>'
             + arc_stroke("M 128 136 m -4 0 a 6 6 0 1 1 10 4 a 14 14 0 1 1 -20 -10 a 22 22 0 1 1 30 18", 7, "#9a5b2c"))
    return svg(body)


def victory_trumpet():
    gold, gold_dark = "#f6c429", "#c9951a"
    # drawn level, then tilted up to the right: the mouthpiece, the pipe with its loop under, three valves, the bell
    shapes = [rrect(22, 120, 34, 22, 9),  # the mouthpiece
              rrect(46, 116, 120, 30, 15),  # the pipe
              rrect(70, 136, 92, 46, 23),  # the loop under the pipe
              rrect(84, 82, 20, 42, 6), rrect(110, 82, 20, 42, 6), rrect(136, 82, 20, 42, 6),  # the valves
              path("M 150 114 L 214 70 Q 236 128 214 186 L 150 148 Z")]  # the bell
    extra = (f'<rect x="94" y="152" width="58" height="14" rx="7" fill="#2d2533" opacity="0.35"/>'
             f'<path d="M 60 124 L 158 124" stroke="#fff1a8" stroke-width="7" stroke-linecap="round"/>'
             f'<ellipse cx="216" cy="128" rx="16" ry="58" fill="{gold_dark}" stroke="{INK}" stroke-width="7"/>'
             f'<ellipse cx="216" cy="128" rx="8" ry="40" fill="#8a6410"/>')
    for vx in (94, 120, 146):
        extra += f'<rect x="{vx - 13}" y="74" width="26" height="12" rx="5" fill="#fff1a8" stroke="{INK}" stroke-width="6"/>'
    body = '<g transform="rotate(-24 128 140) translate(-4 14)">' + outlined(shapes, gold, extra) + "</g>"
    body += note(70, 236, "#5cd6ff", 0.55) + note(196, 60, "#b48aff", 0.5) + star(44, 50, 14, "#ffffff") + star(226, 214, 12, "#ffd84a")
    return svg(body)


ICONS = {
    "Emote_Wave": wave,
    "Emote_ThumbsUp": thumbs_up,
    "Emote_Laugh": laugh,
    "Emote_Dance": dance,
    "Emote_Flex": flex,
    "Emote_Taunt": taunt,
    "Emote_Cry": cry,
    "Emote_Backflip": backflip,
    "Emote_VictoryTrumpet": victory_trumpet,
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    sys.path.insert(0, str(HERE.parent / "crates"))
    argv = sys.argv[:]
    import build  # noqa: E402 (the crate kit's renderer: draw and pixel_fix)
    sys.argv = argv
    from PIL import Image
    pngs = []
    with tempfile.TemporaryDirectory() as temp:
        for name, fn in ICONS.items():
            text = fn()
            (OUT / f"{name}.svg").write_text(text, encoding="utf-8")
            im = build.pixel_fix(build.draw(text, 256, 256, temp))
            im.save(OUT / f"{name}.png")
            pngs.append(im)
            print(f"{name}.png")
    sheet = Image.new("RGBA", (5 * 276, 2 * 276), (44, 48, 62, 255))
    for i, im in enumerate(pngs):
        sheet.alpha_composite(im, (10 + (i % 5) * 276, 10 + (i // 5) * 276))
    sheet.save(OUT / "sheet.png")


if __name__ == "__main__":
    main()
