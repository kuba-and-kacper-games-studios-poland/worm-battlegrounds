"""Crate and menu icons (draft, not approved yet): python -I make_icons.py [<out>]

Each crate is a box seen from the front-left and above (a parallel projection), so planks, brackets, ribbons and
emblems are drawn flat in each face's own coordinates and mapped onto it: they sit on the faces with real depth. The
look follows the game's item icons: a thick dark ink outline, bright paint with a light top and a darker side, chunky
studs and plates. 512 x 512, transparent.
"""

import os
import sys

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
INK = "#141821"
S = 512

# Screen directions of the box's width, depth and height axes
WV = (0.95, 0.16)
DV = (0.50, -0.30)
HV = (0.0, -1.0)


def add(*ps):
    return (sum(p[0] for p in ps), sum(p[1] for p in ps))


def mul(p, k):
    return (p[0] * k, p[1] * k)


class Box:
    def __init__(self, w=1.0, h=0.78, d=0.62, margin=44, lift=0.0):
        self.w, self.h, self.d = w, h, d
        corners = [self.raw(a, b, c) for a in (0, w) for b in (0, h) for c in (0, d)]
        xs, ys = [p[0] for p in corners], [p[1] for p in corners]
        span = max(max(xs) - min(xs), max(ys) - min(ys))
        self.s = (S - 2 * margin) / span
        self.o = (S / 2 - (min(xs) + max(xs)) / 2 * self.s, S / 2 - (min(ys) + max(ys)) / 2 * self.s + lift)

    def raw(self, a, b, c):
        return add(mul(WV, a), mul(HV, b), mul(DV, c))

    def p(self, a, b, c):
        r = self.raw(a, b, c)
        return (self.o[0] + r[0] * self.s, self.o[1] + r[1] * self.s)

    def mat(self, face):
        """SVG matrix mapping a face's local units (100 per box unit, y downwards from its top/front edge)."""
        k = self.s / 100
        if face == "front":
            e = self.p(0, self.h, 0)
            a, c = mul(WV, k), mul((-HV[0], -HV[1]), k)
        elif face == "side":
            e = self.p(self.w, self.h, 0)
            a, c = mul(DV, k), mul((-HV[0], -HV[1]), k)
        else:  # top: x along width, y back into depth
            e = self.p(0, self.h, 0)
            a, c = mul(WV, k), mul(DV, k)
        return f"matrix({a[0]:.4f} {a[1]:.4f} {c[0]:.4f} {c[1]:.4f} {e[0]:.2f} {e[1]:.2f})"

    def size(self, face):
        return {"front": (self.w * 100, self.h * 100), "side": (self.d * 100, self.h * 100),
                "top": (self.w * 100, self.d * 100)}[face]

    def poly(self, pts):
        return " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)

    def faces(self):
        w, h, d = self.w, self.h, self.d
        return {
            "front": [self.p(0, 0, 0), self.p(w, 0, 0), self.p(w, h, 0), self.p(0, h, 0)],
            "side": [self.p(w, 0, 0), self.p(w, 0, d), self.p(w, h, d), self.p(w, h, 0)],
            "top": [self.p(0, h, 0), self.p(w, h, 0), self.p(w, h, d), self.p(0, h, d)],
        }

    def silhouette(self):
        w, h, d = self.w, self.h, self.d
        return [self.p(0, 0, 0), self.p(w, 0, 0), self.p(w, 0, d), self.p(w, h, d), self.p(0, h, d), self.p(0, h, 0)]


NS = 'vector-effect="non-scaling-stroke"'


def stroke(width, color=INK, extra=""):
    return f'stroke="{color}" stroke-width="{width}" stroke-linejoin="round" stroke-linecap="round" {NS} {extra}'


def face_group(box, face, body, clip_id):
    fw, fh = box.size(face)
    return (f'<g transform="{box.mat(face)}"><clipPath id="{clip_id}"><rect x="0" y="0" width="{fw:.2f}" '
            f'height="{fh:.2f}"/></clipPath><g clip-path="url(#{clip_id})">{body}</g></g>')


def shade(fw, fh, gid, a0, a1, horizontal=False):
    x2, y2 = ("1", "0") if horizontal else ("0", "1")
    return (f'<linearGradient id="{gid}" x1="0" y1="0" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="#fff" '
            f'stop-opacity="{a0}"/><stop offset="0.55" stop-color="#fff" stop-opacity="0"/><stop offset="1" '
            f'stop-color="#000" stop-opacity="{a1}"/></linearGradient><rect width="{fw}" height="{fh}" '
            f'fill="url(#{gid})"/>')


def bolt(x, y, r=2.6, fill="#d7dde6"):
    return (f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" {stroke(2.2)}/>'
            f'<circle cx="{x - r * 0.3}" cy="{y - r * 0.3}" r="{r * 0.35}" fill="#fff" opacity="0.9"/>')


# --- face painters ---------------------------------------------------------------------------------------------------

def planks(fw, fh, colors, count, vertical=False, grain="#000", seed=1):
    """Boards across a face with gaps and a little grain."""
    out = []
    n = count
    for i in range(n):
        c = colors[(i * 7 + seed) % len(colors)]
        if vertical:
            x0, x1 = fw * i / n, fw * (i + 1) / n
            out.append(f'<rect x="{x0:.2f}" y="0" width="{x1 - x0:.2f}" height="{fh}" fill="{c}"/>')
            out.append(f'<line x1="{x0:.2f}" y1="0" x2="{x0:.2f}" y2="{fh}" {stroke(2.4)} opacity="0.75"/>')
        else:
            y0, y1 = fh * i / n, fh * (i + 1) / n
            out.append(f'<rect x="0" y="{y0:.2f}" width="{fw}" height="{y1 - y0:.2f}" fill="{c}"/>')
            out.append(f'<line x1="0" y1="{y0:.2f}" x2="{fw}" y2="{y0:.2f}" {stroke(2.4)} opacity="0.75"/>')
            for g in range(2):
                gy = y0 + (y1 - y0) * (0.35 + 0.3 * g)
                gx = (seed * 13 + i * 29 + g * 41) % 60
                out.append(f'<path d="M{gx:.1f} {gy:.2f} q 8 -1.4 16 0 t 16 0" fill="none" stroke="{grain}" '
                           f'stroke-opacity="0.18" stroke-width="1.4" {NS}/>')
    return "".join(out)


def frame(fw, fh, t, fill, light, dark):
    """A border of boards round a face (the crate's frame), lit on top and left."""
    return (f'<path d="M0 0 H{fw} V{fh} H0 Z M{t} {t} V{fh - t} H{fw - t} V{t} Z" fill="{fill}" fill-rule="evenodd" '
            f'{stroke(3)}/>'
            f'<rect x="1" y="1" width="{fw - 2}" height="{t * 0.28:.2f}" fill="{light}" opacity="0.8"/>'
            f'<rect x="1" y="{fh - t * 0.3:.2f}" width="{fw - 2}" height="{t * 0.28:.2f}" fill="{dark}" opacity="0.6"/>'
            f'<rect x="{t:.2f}" y="{t:.2f}" width="{fw - 2 * t:.2f}" height="{fh - 2 * t:.2f}" fill="none" {stroke(3)}/>')


def bracket(fw, fh, corner, size, plate="#aab4c3", light="#e9eef5", dark="#6c7686"):
    """An L-shaped steel corner plate with two bolts."""
    s, t = size, size * 0.42
    x0 = 0 if "l" in corner else fw
    y0 = 0 if "t" in corner else fh
    sx = 1 if "l" in corner else -1
    sy = 1 if "t" in corner else -1
    pts = [(x0, y0), (x0 + sx * s, y0), (x0 + sx * s, y0 + sy * t), (x0 + sx * t, y0 + sy * t),
           (x0 + sx * t, y0 + sy * s), (x0, y0 + sy * s)]
    d = "M" + " L".join(f"{x:.2f} {y:.2f}" for x, y in pts) + " Z"
    hi = f'<path d="M{x0:.2f} {y0 + sy * 1.5:.2f} H{x0 + sx * (s - 1.5):.2f}" stroke="{light}" stroke-width="2.4" {NS}/>'
    return (f'<path d="{d}" fill="{plate}" {stroke(3)}/>{hi}' + bolt(x0 + sx * t * 0.5, y0 + sy * s * 0.72, 2.3)
            + bolt(x0 + sx * s * 0.72, y0 + sy * t * 0.5, 2.3))


def hazard(fw, y, h, a="#ffcc2e", b="#20232b"):
    out = [f'<rect x="0" y="{y}" width="{fw}" height="{h}" fill="{a}"/>']
    step = h * 1.3
    x = -h
    while x < fw + h:
        out.append(f'<path d="M{x:.2f} {y + h} L{x + h * 0.65:.2f} {y} H{x + h * 0.65 + step / 2:.2f} '
                   f'L{x + step / 2:.2f} {y + h} Z" fill="{b}"/>')
        x += step
    out.append(f'<rect x="0" y="{y}" width="{fw}" height="{h}" fill="none" {stroke(2.6)}/>')
    return "".join(out)


# --- emblems (drawn in a 100 x 100 box, placed on a face) ------------------------------------------------------------

def place(fw, fh, size, body, cx=None, cy=None):
    cx = fw / 2 if cx is None else cx
    cy = fh / 2 if cy is None else cy
    k = size / 100
    return f'<g transform="translate({cx - 50 * k:.2f} {cy - 50 * k:.2f}) scale({k:.4f})">{body}</g>'


def emblem_crosshair(col="#ffcf3a"):
    return (f'<circle cx="50" cy="50" r="40" fill="#1f2a1c" opacity="0.35"/>'
            f'<circle cx="50" cy="50" r="31" fill="none" stroke="{INK}" stroke-width="20" {NS}/>'
            f'<circle cx="50" cy="50" r="31" fill="none" stroke="{col}" stroke-width="10" {NS}/>'
            + "".join(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="3" fill="{col}" {stroke(3.5)}/>'
                      for x, y, w, h in ((44, 4, 12, 30), (44, 66, 12, 30), (4, 44, 30, 12), (66, 44, 30, 12)))
            + f'<circle cx="50" cy="50" r="8" fill="{col}" {stroke(3.5)}/>')


def emblem_diamond():
    return (f'<path d="M22 36 L36 18 H64 L78 36 L50 86 Z" fill="#4fd8ff" {stroke(4.2)}/>'
            f'<path d="M22 36 H78" fill="none" {stroke(2.6)}/>'
            f'<path d="M36 18 L44 36 L50 86 M64 18 L56 36 L50 86 M44 36 L50 18 L56 36" fill="none" {stroke(2.2)}/>'
            f'<path d="M36 18 L44 36 H22 Z" fill="#bff3ff"/><path d="M50 18 L56 36 H44 Z" fill="#e8fbff"/>'
            f'<path d="M64 18 L78 36 H56 Z" fill="#7fe4ff"/><path d="M22 36 H44 L50 86 Z" fill="#9becff"/>'
            f'<path d="M56 36 H78 L50 86 Z" fill="#20a8e0"/>'
            f'<path d="M22 36 L36 18 H64 L78 36 L50 86 Z" fill="none" {stroke(4.2)}/>'
            f'<path d="M30 30 L38 22" stroke="#fff" stroke-width="3" stroke-linecap="round" {NS}/>')


def emblem_gear(col="#f4fbff"):
    teeth = "".join(f'<rect x="43" y="6" width="14" height="20" rx="2.5" fill="{col}" {stroke(3.2)} '
                    f'transform="rotate({a} 50 50)"/>' for a in range(0, 360, 45))
    return (teeth + f'<circle cx="50" cy="50" r="30" fill="{col}" {stroke(3.6)}/>'
            f'<path d="M44 34 H56 V44 H66 V56 H56 V66 H44 V56 H34 V44 H44 Z" fill="#ff5a4e" {stroke(3.2)}/>')


def emblem_shell(a="#ffd84d", b="#ff9f1c"):
    return (f'<circle cx="52" cy="54" r="38" fill="{a}" {stroke(4.4)}/>'
            f'<path d="M52 54 m0 -6 a6 6 0 1 1 -6 6 a12 12 0 0 1 12 -12 a18 18 0 0 1 18 18 a24 24 0 0 1 -24 24 '
            f'a30 30 0 0 1 -30 -30" fill="none" stroke="{b}" stroke-width="7" stroke-linecap="round" {NS}/>'
            f'<path d="M52 54 m0 -6 a6 6 0 1 1 -6 6 a12 12 0 0 1 12 -12 a18 18 0 0 1 18 18 a24 24 0 0 1 -24 24 '
            f'a30 30 0 0 1 -30 -30" fill="none" {stroke(2.4)}/>'
            f'<path d="M30 36 q8 -12 22 -14" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" '
            f'opacity="0.8" {NS}/>')


def emblem_star(col="#9be15d"):
    import math
    pts = []
    for i in range(10):
        r = 44 if i % 2 == 0 else 19
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((50 + r * math.cos(a), 52 + r * math.sin(a)))
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"
    return f'<path d="{d}" fill="{col}" {stroke(4.4)}/><path d="M36 30 L44 22" stroke="#fff" stroke-width="3.4" ' \
           f'stroke-linecap="round" opacity="0.85" {NS}/>'


# --- crates ----------------------------------------------------------------------------------------------------------

def svg(body, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {S} {S}" width="{S}" height="{S}">'
            f'<defs>{defs}</defs>{body}</svg>')


def outline(box, width=13):
    f = box.faces()
    w, h, d = box.w, box.h, box.d
    inner = (f'<polyline points="{box.poly([box.p(0, h, 0), box.p(w, h, 0), box.p(w, 0, 0)])}" fill="none" '
             f'stroke="{INK}" stroke-width="6.5" stroke-linejoin="round" stroke-linecap="round"/>'
             f'<line x1="{box.p(w, h, 0)[0]:.1f}" y1="{box.p(w, h, 0)[1]:.1f}" x2="{box.p(w, h, d)[0]:.1f}" '
             f'y2="{box.p(w, h, d)[1]:.1f}" stroke="{INK}" stroke-width="6.5" stroke-linecap="round"/>')
    sil = (f'<polygon points="{box.poly(box.silhouette())}" fill="none" stroke="{INK}" stroke-width="{width}" '
           f'stroke-linejoin="round"/>')
    # a rim of light along the top's front and left edges
    rim = (f'<polyline points="{box.poly([box.p(0, 0.02, 0), box.p(0, h - 0.01, 0), box.p(w - 0.02, h - 0.005, 0)])}" '
           f'fill="none" stroke="#fff" stroke-opacity="0.35" stroke-width="3" stroke-linejoin="round"/>')
    return inner + rim + sil


def crate(name, paint, front_fn, side_fn, top_fn, extra_fn=None, h=0.78, d=0.62, lift=0.0, margin=44):
    box = Box(h=h, d=d, lift=lift, margin=margin)
    parts = []
    for face, fn in (("side", side_fn), ("top", top_fn), ("front", front_fn)):
        fw, fh = box.size(face)
        parts.append(face_group(box, face, fn(fw, fh, face), f"{name}_{face}"))
    body = "".join(parts) + outline(box) + (extra_fn(box) if extra_fn else "")
    return svg(body)


# Weapon crate: an olive army crate, steel corner plates, a yellow stencilled crosshair
def weapon():
    olive = ["#7d9a3c", "#86a443", "#77933a"]
    olive_d = ["#5f7a2b", "#66812f", "#5a7428"]
    olive_t = ["#a7c45a", "#b0cc62", "#9fbd54"]

    def front(fw, fh, f):
        return (planks(fw, fh, olive, 4, seed=2) + frame(fw, fh, 9, "#6d8a33", "#c3dc77", "#3e521c")
                + place(fw, fh, 50, emblem_crosshair())
                + "".join(bracket(fw, fh, c, 17) for c in ("tl", "tr", "bl", "br"))
                + shade(fw, fh, "wsh_f", 0.10, 0.22))

    def side(fw, fh, f):
        return (planks(fw, fh, olive_d, 4, seed=5) + frame(fw, fh, 8, "#56702a", "#9db456", "#2e3d14")
                + "".join(bracket(fw, fh, c, 15, plate="#8e98a8") for c in ("tl", "bl"))
                + f'<rect x="{fw * 0.3:.1f}" y="{fh * 0.42:.1f}" width="{fw * 0.4:.1f}" height="9" rx="4.5" '
                  f'fill="#b9c2cf" {stroke(3)}/>'
                + shade(fw, fh, "wsh_s", 0.0, 0.35, True))

    def top(fw, fh, f):
        return (planks(fw, fh, olive_t, 3, seed=7) + frame(fw, fh, 8, "#9ab74e", "#e3f59a", "#5d7a26")
                + "".join(bracket(fw, fh, c, 15, plate="#c7cfda") for c in ("tl", "tr", "bl", "br"))
                + shade(fw, fh, "wsh_t", 0.25, 0.08))

    return crate("weapon", None, front, side, top)


# Premium crate: an obsidian chest with gold trim, a glowing cyan seam and a cut diamond
def premium():
    def gold_trim(fw, fh, t):
        return (f'<path d="M0 0 H{fw} V{fh} H0 Z M{t} {t} V{fh - t} H{fw - t} V{t} Z" fill="url(#gold)" '
                f'fill-rule="evenodd" {stroke(3)}/>'
                f'<rect x="{t:.2f}" y="{t:.2f}" width="{fw - 2 * t:.2f}" height="{fh - 2 * t:.2f}" fill="none" '
                f'{stroke(3)}/>'
                f'<rect x="1.5" y="1.5" width="{fw - 3}" height="{fh - 3}" fill="none" stroke="#fff6c4" '
                f'stroke-width="1.6" stroke-opacity="0.8" {NS}/>')

    def gem(x, y, r, col="#ff3d7f"):
        return (f'<path d="M{x} {y - r} L{x + r} {y} L{x} {y + r} L{x - r} {y} Z" fill="{col}" {stroke(2.6)}/>'
                f'<path d="M{x} {y - r} L{x + r * 0.45} {y} L{x} {y + r * 0.2} L{x - r * 0.45} {y} Z" fill="#fff" '
                f'opacity="0.55"/>')

    def front(fw, fh, f):
        seam = fh * 0.3
        return (f'<rect width="{fw}" height="{fh}" fill="url(#obsidian)"/>'
                + "".join(f'<path d="M{x} 0 L{x + 30} {fh}" stroke="#fff" stroke-opacity="0.06" stroke-width="7" '
                          f'{NS}/>' for x in (10, 40, 70))
                + f'<rect x="0" y="{seam - 2.2:.1f}" width="{fw}" height="4.4" fill="#7ff0ff"/>'
                + f'<rect x="0" y="{seam - 5:.1f}" width="{fw}" height="10" fill="#38d9ff" opacity="0.35"/>'
                + f'<line x1="0" y1="{seam - 2.2:.1f}" x2="{fw}" y2="{seam - 2.2:.1f}" {stroke(2.4)}/>'
                + f'<line x1="0" y1="{seam + 2.2:.1f}" x2="{fw}" y2="{seam + 2.2:.1f}" {stroke(2.4)}/>'
                + gold_trim(fw, fh, 7)
                + place(fw, fh, 46, emblem_diamond(), cy=fh * 0.62)
                + f'<rect x="{fw / 2 - 9:.1f}" y="{seam - 7:.1f}" width="18" height="12" rx="3" fill="url(#gold)" '
                  f'{stroke(3)}/><circle cx="{fw / 2:.1f}" cy="{seam - 1:.1f}" r="2.4" fill="{INK}"/>'
                + "".join(f'<path d="M{x} {y} h{sx * 13} l{-sx * 13} {sy * 13} Z" fill="url(#gold)" {stroke(2.6)}/>'
                          for x, y, sx, sy in ((0, 0, 1, 1), (fw, 0, -1, 1), (0, fh, 1, -1), (fw, fh, -1, -1)))
                + shade(fw, fh, "psh_f", 0.08, 0.3))

    def side(fw, fh, f):
        seam = fh * 0.3
        return (f'<rect width="{fw}" height="{fh}" fill="#141a33"/>'
                + f'<rect x="0" y="{seam - 2.2:.1f}" width="{fw}" height="4.4" fill="#5fe6ff"/>'
                + f'<line x1="0" y1="{seam - 2.2:.1f}" x2="{fw}" y2="{seam - 2.2:.1f}" {stroke(2.4)}/>'
                + f'<line x1="0" y1="{seam + 2.2:.1f}" x2="{fw}" y2="{seam + 2.2:.1f}" {stroke(2.4)}/>'
                + gold_trim(fw, fh, 6.5) + gem(fw / 2, fh * 0.64, 7, "#38d9ff")
                + shade(fw, fh, "psh_s", 0.0, 0.42, True))

    def top(fw, fh, f):
        return (f'<rect width="{fw}" height="{fh}" fill="url(#obsidianTop)"/>' + gold_trim(fw, fh, 7)
                + f'<path d="M{fw / 2 - 18:.1f} {fh / 2:.1f} L{fw / 2:.1f} {fh / 2 - 13:.1f} L{fw / 2 + 18:.1f} '
                  f'{fh / 2:.1f} L{fw / 2:.1f} {fh / 2 + 13:.1f} Z" fill="url(#gold)" {stroke(3)}/>'
                + gem(fw / 2, fh / 2, 8.5, "#ff3d7f") + gem(fw * 0.2, fh / 2, 4.2, "#38d9ff")
                + gem(fw * 0.8, fh / 2, 4.2, "#38d9ff") + shade(fw, fh, "psh_t", 0.3, 0.05))

    defs = ('<linearGradient id="gold" x1="0" y1="0" x2="0.3" y2="1"><stop offset="0" stop-color="#fff2a8"/>'
            '<stop offset="0.35" stop-color="#ffd24a"/><stop offset="0.7" stop-color="#e59a12"/>'
            '<stop offset="1" stop-color="#b86a06"/></linearGradient>'
            '<linearGradient id="obsidian" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2d3a6e"/>'
            '<stop offset="0.5" stop-color="#1b2148"/><stop offset="1" stop-color="#120f2c"/></linearGradient>'
            '<linearGradient id="obsidianTop" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4a5aa0"/>'
            '<stop offset="1" stop-color="#262d63"/></linearGradient>')
    def glints(box):
        out = ""
        for (a, b, c), r in (((0, box.h, 0), 15), ((box.w, box.h, box.d), 11), ((box.w, 0.0, 0), 9)):
            x, y = box.p(a, b, c)
            out += (f'<path d="M{x} {y - r} Q{x} {y} {x + r} {y} Q{x} {y} {x} {y + r} Q{x} {y} {x - r} {y} '
                    f'Q{x} {y} {x} {y - r} Z" fill="#fffbe0"/>')
        return out
    out = crate("premium", None, front, side, top, extra_fn=glints)
    return out.replace("<defs>", "<defs>" + defs, 1)


# Utility crate: a teal steel supply case, ribbed, with a hazard band, latches and a gear-and-plus stencil
def utility():
    def ribs(fw, fh, base, light, dark, n):
        out = [f'<rect width="{fw}" height="{fh}" fill="{base}"/>']
        for i in range(n):
            x = fw * (i + 0.5) / n
            out.append(f'<rect x="{x - 3:.2f}" y="10" width="6" height="{fh - 26:.2f}" rx="3" fill="{light}" '
                       f'{stroke(2.4)}/>')
            out.append(f'<rect x="{x - 3:.2f}" y="{fh - 18:.2f}" width="6" height="2" fill="{dark}"/>')
        return "".join(out)

    def front(fw, fh, f):
        return (ribs(fw, fh, "#22b59a", "#4fd8bb", "#0c6b5a", 9) + hazard(fw, fh - 14, 10)
                + f'<rect x="0" y="0" width="{fw}" height="9" fill="#1b9a83" {stroke(3)}/>'
                + f'<rect x="{fw / 2 - 26:.1f}" y="{fh / 2 - 26:.1f}" width="52" height="46" rx="10" fill="#0f6e5d" '
                  f'{stroke(3.4)}/>'
                + place(fw, fh, 40, emblem_gear(), cy=fh / 2 - 3)
                + "".join(f'<rect x="{x:.1f}" y="3" width="11" height="15" rx="2.5" fill="#d6dee8" {stroke(3)}/>'
                          f'<rect x="{x + 3:.1f}" y="12" width="5" height="3" fill="{INK}"/>'
                          for x in (fw * 0.16, fw * 0.84 - 11))
                + shade(fw, fh, "ush_f", 0.12, 0.25))

    def side(fw, fh, f):
        return (ribs(fw, fh, "#178a75", "#2fb497", "#08463b", 5) + hazard(fw, fh - 14, 10, "#d9a920", "#16181e")
                + f'<rect x="0" y="0" width="{fw}" height="9" fill="#127463" {stroke(3)}/>'
                + f'<path d="M{fw * 0.28:.1f} {fh * 0.36:.1f} v-6 h{fw * 0.44:.1f} v6" fill="none" {stroke(7)}/>'
                + f'<path d="M{fw * 0.28:.1f} {fh * 0.36:.1f} v-6 h{fw * 0.44:.1f} v6" fill="none" stroke="#c9d2de" '
                  f'stroke-width="3.4" {NS}/>'
                + shade(fw, fh, "ush_s", 0.0, 0.35, True))

    def top(fw, fh, f):
        return (f'<rect width="{fw}" height="{fh}" fill="#45d6b6"/>'
                + f'<rect x="7" y="7" width="{fw - 14}" height="{fh - 14}" rx="5" fill="#2fc4a4" {stroke(3)}/>'
                + "".join(f'<line x1="{x:.1f}" y1="12" x2="{x:.1f}" y2="{fh - 12:.1f}" stroke="#7ff0d6" '
                          f'stroke-width="2" {NS}/>' for x in (fw * 0.3, fw * 0.5, fw * 0.7))
                + f'<rect x="{fw / 2 - 14:.1f}" y="{fh / 2 - 7:.1f}" width="28" height="14" rx="4" fill="#ffffff" '
                  f'{stroke(3)}/><path d="M{fw / 2 - 3:.1f} {fh / 2 - 4:.1f} h6 v3 h3 v3 h-3 v3 h-6 v-3 h-3 v-3 h3 Z" '
                  f'fill="#ff5a4e"/>'
                + shade(fw, fh, "ush_t", 0.25, 0.05))

    return crate("utility", None, front, side, top)


# Skin crate: a pink-painted wooden crate wrapped in a gold ribbon with a bow on top, and a snail-shell seal
def skin():
    pink = ["#ff6fb5", "#ff79bb", "#fb66ad"]
    pink_d = ["#d9478f", "#e04e97", "#d24289"]
    pink_t = ["#ff9fd0", "#ffa9d5", "#ff97ca"]

    def ribbon_v(fw, fh, w=16):
        x = fw / 2 - w / 2
        return (f'<rect x="{x:.1f}" y="-2" width="{w}" height="{fh + 4}" fill="url(#ribbon)" {stroke(3)}/>'
                f'<line x1="{x + 3:.1f}" y1="0" x2="{x + 3:.1f}" y2="{fh}" stroke="#fff6c4" stroke-width="2" {NS}/>')

    def dots(fw, fh, col):
        return "".join(f'<circle cx="{(i * 23 + (j % 2) * 11) % (fw + 10):.1f}" cy="{6 + j * 13:.1f}" r="1.8" '
                       f'fill="{col}" opacity="0.55"/>' for i in range(6) for j in range(int(fh / 13) + 1))

    def front(fw, fh, f):
        return (planks(fw, fh, pink, 4, seed=3, grain="#7a0040") + dots(fw, fh, "#ffd1ea")
                + frame(fw, fh, 8, "#e85aa2", "#ffd0e8", "#8c1f5a") + ribbon_v(fw, fh)
                + place(fw, fh, 34, emblem_shell(), cy=fh * 0.56)
                + shade(fw, fh, "ssh_f", 0.12, 0.25))

    def side(fw, fh, f):
        return (planks(fw, fh, pink_d, 4, seed=6, grain="#5a0030") + frame(fw, fh, 7, "#c63d84", "#ff9cd0", "#6b1544")
                + ribbon_v(fw, fh, 13) + shade(fw, fh, "ssh_s", 0.0, 0.35, True))

    def top(fw, fh, f):
        return (planks(fw, fh, pink_t, 3, seed=8, grain="#7a0040") + frame(fw, fh, 7, "#ff8cc6", "#ffe3f2", "#b23677")
                + ribbon_v(fw, fh, 15)
                + f'<rect x="-2" y="{fh / 2 - 7:.1f}" width="{fw + 4}" height="14" fill="url(#ribbon)" {stroke(3)}/>'
                + shade(fw, fh, "ssh_t", 0.25, 0.05))

    def bow(box):
        c = box.p(box.w / 2, box.h, box.d / 2)
        x, y = c
        return (f'<g transform="translate({x:.1f} {y - 8:.1f}) scale(1.55)">'
                f'<path d="M0 0 C -30 -44 -78 -30 -62 -6 C -54 8 -24 8 0 0 Z" fill="url(#ribbon)" stroke="{INK}" '
                f'stroke-width="7" stroke-linejoin="round"/>'
                f'<path d="M0 0 C 30 -44 78 -30 62 -6 C 54 8 24 8 0 0 Z" fill="url(#ribbon)" stroke="{INK}" '
                f'stroke-width="7" stroke-linejoin="round"/>'
                f'<path d="M-6 4 L-26 40 L-14 36 L-8 46 L2 8 Z" fill="#e8a91c" stroke="{INK}" stroke-width="6" '
                f'stroke-linejoin="round"/>'
                f'<path d="M6 4 L26 38 L14 35 L9 45 L-1 8 Z" fill="#e8a91c" stroke="{INK}" stroke-width="6" '
                f'stroke-linejoin="round"/>'
                f'<path d="M-44 -18 C -36 -28 -22 -24 -12 -12" fill="none" stroke="#fff6c4" stroke-width="4" '
                f'stroke-linecap="round"/>'
                f'<path d="M44 -18 C 36 -28 22 -24 12 -12" fill="none" stroke="#fff6c4" stroke-width="4" '
                f'stroke-linecap="round" opacity="0.7"/>'
                f'<ellipse cx="0" cy="0" rx="15" ry="12" fill="#ffd24a" stroke="{INK}" stroke-width="7"/>'
                f'<ellipse cx="-4" cy="-4" rx="5" ry="3.5" fill="#fff6c4"/></g>')

    defs = ('<linearGradient id="ribbon" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#fff0a0"/>'
            '<stop offset="0.45" stop-color="#ffcd3c"/><stop offset="1" stop-color="#e09412"/></linearGradient>')
    out = crate("skin", None, front, side, top, extra_fn=bow, lift=40, margin=62)
    return out.replace("<defs>", "<defs>" + defs, 1)


# Starter crate: a plain pine crate with a green star stencil
def starter():
    pine = ["#e9b96e", "#f0c27a", "#e2b064"]
    pine_d = ["#c8914a", "#cf9a52", "#c08744"]
    pine_t = ["#f8d79a", "#fbdda3", "#f4d092"]

    def front(fw, fh, f):
        return (planks(fw, fh, pine, 4, seed=1, grain="#6b3d10") + frame(fw, fh, 9, "#d9a256", "#ffe7b3", "#8a5a22")
                + place(fw, fh, 44, emblem_star()) + shade(fw, fh, "tsh_f", 0.12, 0.22))

    def side(fw, fh, f):
        return (planks(fw, fh, pine_d, 4, seed=4, grain="#5a300a") + frame(fw, fh, 8, "#b8813e", "#f0c27a", "#6b4214")
                + shade(fw, fh, "tsh_s", 0.0, 0.35, True))

    def top(fw, fh, f):
        return (planks(fw, fh, pine_t, 3, seed=9, grain="#6b3d10") + frame(fw, fh, 8, "#f0c27a", "#fff3d6", "#b8813e")
                + shade(fw, fh, "tsh_t", 0.25, 0.05))

    return crate("starter", None, front, side, top)


# STYLE (the lobby's Customise button): a snail shell with a paintbrush leaning on it, a dab of paint
def style():
    body = (
        f'<circle cx="220" cy="250" r="160" fill="#ff7ac4" stroke="{INK}" stroke-width="14"/>'
        f'<path d="M220 250 m0 -22 a22 22 0 1 1 -22 22 a44 44 0 0 1 44 -44 a66 66 0 0 1 66 66 a88 88 0 0 1 -88 88 '
        f'a110 110 0 0 1 -110 -110" fill="none" stroke="{INK}" stroke-width="30" stroke-linecap="round"/>'
        f'<path d="M220 250 m0 -22 a22 22 0 1 1 -22 22 a44 44 0 0 1 44 -44 a66 66 0 0 1 66 66 a88 88 0 0 1 -88 88 '
        f'a110 110 0 0 1 -110 -110" fill="none" stroke="#c2338a" stroke-width="16" stroke-linecap="round"/>'
        f'<path d="M120 170 q40 -62 110 -68" fill="none" stroke="#ffd3ec" stroke-width="16" stroke-linecap="round"/>'
        f'<path d="M110 360 q50 40 120 44" fill="none" stroke="#000" stroke-opacity="0.18" stroke-width="18" stroke-linecap="round"/>'
        # paint splash
        f'<path d="M300 370 c30 -18 70 -10 84 10 c18 -6 36 6 30 24 c-6 20 -40 22 -58 14 c-24 12 -66 10 -70 -14 '
        f'c-2 -14 4 -28 14 -34 Z" fill="#5fe0ff" stroke="{INK}" stroke-width="9" stroke-linejoin="round"/>'
        f'<circle cx="440" cy="380" r="11" fill="#5fe0ff" stroke="{INK}" stroke-width="7"/>'
        # brush
        f'<g transform="rotate(38 330 230)">'
        f'<rect x="304" y="40" width="52" height="210" rx="22" fill="#ffb02e" stroke="{INK}" stroke-width="10"/>'
        f'<rect x="314" y="52" width="12" height="180" rx="6" fill="#ffe08a"/>'
        f'<rect x="298" y="240" width="64" height="44" rx="6" fill="#c9d2de" stroke="{INK}" stroke-width="10"/>'
        f'<rect x="306" y="248" width="48" height="8" fill="#fff" opacity="0.7"/>'
        f'<path d="M300 282 h60 c4 40 -8 80 -30 96 c-22 -16 -34 -56 -30 -96 Z" fill="#5fe0ff" stroke="{INK}" '
        f'stroke-width="10" stroke-linejoin="round"/>'
        f'<path d="M312 292 c0 26 6 50 16 66" fill="none" stroke="#c8f6ff" stroke-width="6" stroke-linecap="round"/>'
        f'</g>'
        # sparkles
        f'<path d="M108 80 l8 22 l22 8 l-22 8 l-8 22 l-8 -22 l-22 -8 l22 -8 Z" fill="#fff" stroke="{INK}" '
        f'stroke-width="6" stroke-linejoin="round"/>'
    )
    return svg(body)


ICONS = {"Crate_Weapon": weapon, "Crate_Premium": premium, "Crate_Utility": utility, "Crate_Skin": skin,
         "Crate_Starter": starter, "Menu_Style": style}


def main():
    os.makedirs(OUT, exist_ok=True)
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from standins import STANDINS
    ICONS.update(STANDINS)
    for name, fn in ICONS.items():
        with open(os.path.join(OUT, f"{name}.svg"), "w", encoding="utf-8") as f:
            f.write(fn())
        print(name)


if __name__ == "__main__":
    main()
