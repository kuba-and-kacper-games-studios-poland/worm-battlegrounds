"""The crate opening's effect pictures, as SVG: the showcase's pedestal, beam and halo, the gold star card's star, and
the reveal's sparks, bones, bubbles, shockwave ring and the black hole's core and spinning disk (a flipbook).

White parts are tinted in game (ImageColor3); the rest keeps its colours. Each entry is (width, height, svg body).
"""

import math

INK = "#141821"


def svg(w, h, body, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">'
            f'<defs>{defs}</defs>{body}</svg>')


def pedestal():
    """The lobby pods' round plinth in dark slate with studs round its side; its ring is Fx_PedestalRing, tinted."""
    studs = ""
    for i in range(11):
        a = math.pi * (0.08 + 0.84 * i / 10)
        x = 400 - math.cos(a) * 340
        studs += (f'<rect x="{x - 14:.1f}" y="{132 + math.sin(a) * 60:.1f}" width="28" height="36" rx="6" '
                  f'fill="#3c4562" stroke="{INK}" stroke-width="5"/>')
    body = (f'<ellipse cx="400" cy="236" rx="392" ry="60" fill="#000" fill-opacity=".38"/>'
            f'<path d="M44 104 V196 A356 80 0 0 0 756 196 V104 Z" fill="#30374f" stroke="{INK}" stroke-width="12"/>'
            f'{studs}'
            f'<ellipse cx="400" cy="104" rx="356" ry="80" fill="#4a5474" stroke="{INK}" stroke-width="12"/>'
            f'<ellipse cx="400" cy="104" rx="300" ry="62" fill="#414a68"/>'
            f'<path d="M120 80 A300 60 0 0 1 400 40" fill="none" stroke="#fff" stroke-opacity=".25" stroke-width="10" '
            f'stroke-linecap="round"/>')
    return 800, 300, svg(800, 300, body)


def pedestal_ring():
    """The pedestal's glowing ring and the light pooled inside it, in white to tint with the crate's colour."""
    defs = ('<radialGradient id="pool"><stop offset="0" stop-color="#fff" stop-opacity=".8"/>'
            '<stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>'
            '<filter id="soft" x="-20%" y="-50%" width="140%" height="200%"><feGaussianBlur stdDeviation="9"/></filter>')
    body = ('<ellipse cx="400" cy="104" rx="240" ry="50" fill="url(#pool)"/>'
            '<ellipse cx="400" cy="104" rx="304" ry="64" fill="none" stroke="#fff" stroke-width="26" '
            'stroke-opacity=".45" filter="url(#soft)"/>'
            '<ellipse cx="400" cy="104" rx="304" ry="64" fill="none" stroke="#fff" stroke-width="10"/>')
    return 800, 300, svg(800, 300, body, defs)


def beam():
    """A soft spotlight cone from above, white."""
    defs = ('<linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity="0"/>'
            '<stop offset=".7" stop-color="#fff" stop-opacity=".9"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>'
            '</linearGradient><filter id="b"><feGaussianBlur stdDeviation="14"/></filter>')
    return 256, 512, svg(256, 512, '<path d="M98 0 H158 L250 512 H6 Z" fill="url(#g)" filter="url(#b)"/>', defs)


def halo():
    """The premium crate's turning halo: a dashed gold ring with a soft glow."""
    defs = '<filter id="b"><feGaussianBlur stdDeviation="8"/></filter>'
    body = ('<circle cx="256" cy="256" r="236" fill="none" stroke="#ffd65a" stroke-opacity=".35" stroke-width="22" '
            'filter="url(#b)"/>'
            '<circle cx="256" cy="256" r="236" fill="none" stroke="#ffe27a" stroke-width="6" '
            'stroke-dasharray="26 18" stroke-linecap="round"/>'
            '<circle cx="256" cy="256" r="214" fill="none" stroke="#9ff2ff" stroke-opacity=".5" stroke-width="2" '
            'stroke-dasharray="4 14"/>')
    return 512, 512, svg(512, 512, body, defs)


def star():
    """The gold star on the legendary card, inked, with a light glint."""
    pts = []
    for i in range(10):
        r = 116 if i % 2 == 0 else 50
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((128 + r * math.cos(a), 136 + r * math.sin(a)))
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"
    defs = ('<linearGradient id="g" x1="0" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="#fff3a8"/>'
            '<stop offset=".45" stop-color="#ffd23a"/><stop offset="1" stop-color="#e08a0c"/></linearGradient>')
    body = (f'<path d="{d}" fill="url(#g)" stroke="{INK}" stroke-width="16" stroke-linejoin="round"/>'
            f'<path d="M128 46 L146 102 L112 106 Z" fill="#fffbe0" opacity=".9"/>')
    return 256, 256, svg(256, 256, body, defs)


def spark():
    """A streak of light (drawn along +X, so it faces its movement), white with a hot core."""
    defs = ('<linearGradient id="g" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#fff" stop-opacity="0"/>'
            '<stop offset=".75" stop-color="#fff" stop-opacity=".85"/><stop offset="1" stop-color="#fff"/></linearGradient>'
            '<filter id="b"><feGaussianBlur stdDeviation="3"/></filter>')
    body = ('<path d="M4 32 Q160 22 248 32 Q160 42 4 32 Z" fill="url(#g)" filter="url(#b)"/>'
            '<path d="M60 32 Q190 28 250 32 Q190 36 60 32 Z" fill="#fff"/>')
    return 256, 64, svg(256, 64, body, defs)


def bone():
    """A cartoon bone, inked."""
    body = (f'<g stroke="{INK}" stroke-width="10" fill="#f4f0e2" stroke-linejoin="round">'
            f'<circle cx="34" cy="34" r="24"/><circle cx="34" cy="70" r="24"/>'
            f'<circle cx="158" cy="34" r="24"/><circle cx="158" cy="70" r="24"/>'
            f'<rect x="34" y="34" width="124" height="36"/></g>'
            f'<rect x="30" y="38" width="132" height="28" fill="#f4f0e2"/>'
            f'<path d="M40 44 H150" stroke="#fff" stroke-width="7" stroke-linecap="round"/>')
    return 192, 104, svg(192, 104, body)


def bubble():
    """A soap bubble: a thin white ring, faint fill and a highlight."""
    body = ('<circle cx="64" cy="64" r="56" fill="#fff" fill-opacity=".12" stroke="#fff" stroke-width="6"/>'
            '<path d="M30 46 A40 40 0 0 1 58 22" fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round"/>'
            '<circle cx="86" cy="88" r="5" fill="#fff" fill-opacity=".7"/>')
    return 128, 128, svg(128, 128, body)


def ring():
    """A shockwave ring, white, soft on both sides."""
    defs = '<filter id="b"><feGaussianBlur stdDeviation="6"/></filter>'
    body = ('<circle cx="256" cy="256" r="228" fill="none" stroke="#fff" stroke-width="30" stroke-opacity=".55" '
            'filter="url(#b)"/><circle cx="256" cy="256" r="228" fill="none" stroke="#fff" stroke-width="12"/>')
    return 512, 512, svg(512, 512, body, defs)


def core():
    """The black hole: black, with a violet and cyan rim of light."""
    defs = ('<radialGradient id="g"><stop offset="0" stop-color="#000"/><stop offset=".68" stop-color="#000"/>'
            '<stop offset=".78" stop-color="#9b5cff"/><stop offset=".88" stop-color="#5ce1ff" stop-opacity=".55"/>'
            '<stop offset="1" stop-color="#5ce1ff" stop-opacity="0"/></radialGradient>')
    return 256, 256, svg(256, 256, '<circle cx="128" cy="128" r="128" fill="url(#g)"/>', defs)


DISK_COLS, DISK_ROWS, DISK_W, DISK_H = 4, 8, 256, 128


def disk_frame(phase):
    """One frame of the black hole's disk seen at a slant: bands of violet, cyan and pink swirling, the far side dim."""
    defs = '<filter id="b"><feGaussianBlur stdDeviation="1.6"/></filter>'
    segs = []
    n = 48
    for i in range(n):
        a0 = (i / n) * 2 * math.pi + phase
        a1 = a0 + 2 * math.pi / n * 1.1
        hue = (i * 7) % 3
        col = ("#b45cff", "#5ce1ff", "#ff5fd2")[hue]
        for rx, ry, w, op in ((112, 40, 9, 0.9), (92, 32, 7, 0.75), (72, 24, 5, 0.6)):
            x0, y0 = 128 + rx * math.cos(a0), 64 + ry * math.sin(a0)
            x1, y1 = 128 + rx * math.cos(a1), 64 + ry * math.sin(a1)
            far = math.sin((a0 + a1) / 2) < 0
            o = op * (0.45 if far else 1.0) * (0.55 + 0.45 * math.sin(i * 1.7 + rx))
            segs.append(f'<path d="M{x0:.1f} {y0:.1f} A{rx} {ry} 0 0 1 {x1:.1f} {y1:.1f}" fill="none" stroke="{col}" '
                        f'stroke-width="{w}" stroke-opacity="{max(0.08, o):.2f}" stroke-linecap="round"/>')
    return svg(DISK_W, DISK_H, f'<g filter="url(#b)">{"".join(segs)}</g>', defs)


PICTURES = {
    "Fx_Pedestal": pedestal, "Fx_PedestalRing": pedestal_ring, "Fx_Beam": beam, "Fx_Halo": halo, "Fx_Star": star,
    "Fx_Spark": spark, "Fx_Bone": bone, "Fx_Bubble": bubble, "Fx_Ring": ring, "Fx_Core": core,
}
