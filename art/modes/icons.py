"""Worm Battlegrounds' mode icons, drawn in the weapon icons' look: chunky objects with a thick ink outline, three tones
(a light top, the colour, a dark bottom), the brick studs on their faces and a soft gloss. Writes src/<name>.svg.

    python -I icons.py && python -I build.py

Every icon is on a 64 x 64 grid; build.py renders them to 256 px PNGs.
"""

from pathlib import Path

SRC = Path(__file__).resolve().parent / "src"

INK = "#171724"
LINE = 2.6

# Light, base, dark for each colour the icons use
TONES = {
    "red": ("#ff6b5e", "#e8322a", "#a3161a"),
    "blue": ("#5fc8ff", "#1f8fe8", "#145aa8"),
    "green": ("#9ff06a", "#43c83a", "#1f7f2a"),
    "yellow": ("#ffe766", "#ffc21a", "#d4870a"),
    "orange": ("#ffb15a", "#ff8a1c", "#c25a0c"),
    "purple": ("#c79bff", "#8f55f0", "#5b2bb0"),
    "metal": ("#f2f5fa", "#a9b3c2", "#5f6878"),
    "dark": ("#59607a", "#353a4e", "#1f2232"),
    "white": ("#ffffff", "#e9edf3", "#aeb6c4"),
    "pink": ("#ffc2dc", "#ff8fbd", "#d4568b"),
    "shell": ("#ffd28a", "#f0a04a", "#a8621e"),
    "wood": ("#f7c27a", "#d98c3c", "#8f531c"),
    "cyan": ("#c9fbff", "#5ff0ff", "#1aa6c8"),
}


class Icon:
    """One SVG: gradients made on demand, shapes added in drawing order."""

    def __init__(self, name: str, comment: str):
        self.name = name
        self.comment = comment
        self.defs: dict[str, str] = {}
        self.body: list[str] = []

    def tone(self, colour: str, angle: str = "v") -> str:
        """A light-to-dark fill of a colour (top to bottom, or top-left to bottom-right with 'd')."""
        key = f"{colour}_{angle}"
        if key not in self.defs:
            light, base, dark = TONES[colour]
            x2, y2 = ("0", "1") if angle == "v" else ("1", "1")
            self.defs[key] = (
                f'<linearGradient id="{key}" x1="0" y1="0" x2="{x2}" y2="{y2}">'
                f'<stop offset="0" stop-color="{light}"/><stop offset="0.45" stop-color="{base}"/>'
                f'<stop offset="1" stop-color="{dark}"/></linearGradient>'
            )
        return f"url(#{key})"

    def add(self, svg: str) -> None:
        self.body.append(svg)

    def shape(self, tag: str, attrs: str, colour: str, angle: str = "v", width: float = LINE) -> None:
        """A shaded shape with the ink outline."""
        self.add(f'<{tag} {attrs} fill="{self.tone(colour, angle)}" stroke="{INK}" stroke-width="{width}" stroke-linejoin="round"/>')

    def gloss(self, cx: float, cy: float, rx: float, ry: float, rotate: float = -25, opacity: float = 0.55) -> None:
        """The soft white shine on a face's upper left."""
        self.add(
            f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#ffffff" opacity="{opacity}" '
            f'transform="rotate({rotate} {cx} {cy})"/>'
        )

    def stud(self, x: float, y: float, size: float, colour: str) -> None:
        """A brick stud: a small rounded square, light on its top, its colour, a dark edge under it."""
        light, base, dark = TONES[colour]
        r = size * 0.28
        self.add(
            f'<rect x="{x - size / 2:.2f}" y="{y - size / 2 + size * 0.14:.2f}" width="{size:.2f}" height="{size:.2f}" rx="{r:.2f}" fill="{dark}"/>'
            f'<rect x="{x - size / 2:.2f}" y="{y - size / 2:.2f}" width="{size:.2f}" height="{size:.2f}" rx="{r:.2f}" fill="{base}"/>'
            f'<rect x="{x - size / 2 + size * 0.14:.2f}" y="{y - size / 2 + size * 0.1:.2f}" width="{size * 0.72:.2f}" height="{size * 0.34:.2f}" rx="{r * 0.6:.2f}" fill="{light}" opacity="0.9"/>'
        )

    def svg(self) -> str:
        defs = "".join(self.defs.values())
        return (
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">\n'
            f"  <!-- {self.comment} -->\n"
            f"  <defs>{defs}</defs>\n  " + "\n  ".join(self.body) + "\n</svg>\n"
        )


def snail(icon: Icon, x: float, y: float, s: float, body: str = "pink", shell: str = "shell") -> None:
    """The game's snail, facing right: a chunky soft body with its head up, two eyes on stalks, a studded shell on its back."""

    def t(px: float, py: float) -> str:
        return f"{x + px * s:.2f},{y + py * s:.2f}"

    # Eye stalks first, behind the head
    for (bx, by, ex, ey) in ((13, -2, 11, -11), (17, -1, 19, -10)):
        icon.add(f'<path d="M{t(bx, by)} L{t(ex, ey)}" stroke="{INK}" stroke-width="{4.2 * s:.2f}" stroke-linecap="round"/>')
        icon.add(f'<path d="M{t(bx, by)} L{t(ex, ey)}" stroke="{TONES[body][1]}" stroke-width="{1.8 * s:.2f}" stroke-linecap="round"/>')
        icon.add(f'<circle cx="{x + ex * s:.2f}" cy="{y + ey * s:.2f}" r="{2.8 * s:.2f}" fill="#ffffff" stroke="{INK}" stroke-width="{1.6 * s:.2f}"/>')
        icon.add(f'<circle cx="{x + (ex + 0.6) * s:.2f}" cy="{y + (ey + 0.3) * s:.2f}" r="{1.2 * s:.2f}" fill="{INK}"/>')
    # The body: a thick slug from the tail (left) to the raised head (right)
    icon.shape(
        "path",
        f'd="M{t(-17, 13)} Q{t(-19, 6)} {t(-11, 6)} L{t(5, 6)} Q{t(7, -5)} {t(15, -4)} Q{t(22, -3)} {t(21, 6)} Q{t(20, 13)} {t(12, 13)} Z"',
        body,
        width=LINE * s,
    )
    icon.gloss(x + 14 * s, y - 1 * s, 2.6 * s, 1.2 * s, -10, 0.5)
    # The shell, with its spiral and studs
    icon.shape("circle", f'cx="{x - 4 * s:.2f}" cy="{y - 1 * s:.2f}" r="{11.5 * s:.2f}"', shell, "d", LINE * s)
    icon.add(
        f'<path d="M{t(-4, -1)} a{2.6 * s:.2f},{2.6 * s:.2f} 0 1,1 {2.6 * s:.2f},{2.6 * s:.2f} '
        f'a{5.4 * s:.2f},{5.4 * s:.2f} 0 1,1 {-5.8 * s:.2f},{-6.6 * s:.2f} a{7.6 * s:.2f},{7.6 * s:.2f} 0 0,1 {9.6 * s:.2f},{2.2 * s:.2f}" '
        f'fill="none" stroke="{TONES[shell][2]}" stroke-width="{2 * s:.2f}" stroke-linecap="round"/>'
    )
    icon.stud(x - 10 * s, y - 5 * s, 3 * s, shell)
    icon.stud(x + 2 * s, y - 8 * s, 3 * s, shell)
    icon.stud(x - 9 * s, y + 6 * s, 3 * s, shell)
    icon.gloss(x - 8 * s, y - 8 * s, 3.6 * s, 1.7 * s)


def write(icon: Icon) -> None:
    (SRC / f"{icon.name}.svg").write_text(icon.svg(), encoding="utf-8")


def deathmatch() -> Icon:
    i = Icon("deathmatch", "Deathmatch: a red bullseye with metal crosshair arms")
    for (x, y, w, h) in ((29, 3, 6, 14), (29, 47, 6, 14), (3, 29, 14, 6), (47, 29, 14, 6)):
        i.shape("rect", f'x="{x}" y="{y}" width="{w}" height="{h}" rx="2"', "metal")
    i.shape("circle", 'cx="32" cy="32" r="21"', "red", "d")
    i.shape("circle", 'cx="32" cy="32" r="14"', "white", "d", 2.2)
    i.shape("circle", 'cx="32" cy="32" r="7.5"', "red", "d", 2.2)
    for (x, y) in ((32, 14.5), (17.5, 26), (46.5, 26), (21, 45), (43, 45)):
        i.stud(x, y, 3.6, "red")
    i.gloss(24, 20, 7, 3)
    return i


def teams() -> Icon:
    i = Icon("teams", "Teams: a red and a blue shield, overlapping, metal rims and studs")
    for (dx, colour) in ((-9, "red"), (9, "blue")):
        cx = 32 + dx
        path = f"M{cx - 13},{14} L{cx},{9} L{cx + 13},{14} L{cx + 13},{32} Q{cx + 13},{48} {cx},{56} Q{cx - 13},{48} {cx - 13},{32} Z"
        i.shape("path", f'd="{path}"', "metal", "d")
        inner = f"M{cx - 9},{17} L{cx},{13.5} L{cx + 9},{17} L{cx + 9},{32} Q{cx + 9},{44} {cx},{50.5} Q{cx - 9},{44} {cx - 9},{32} Z"
        i.shape("path", f'd="{inner}"', colour, "d", 2)
        for (sx, sy) in ((cx - 4, 22), (cx + 4, 22), (cx, 30), (cx - 4, 38), (cx + 4, 38)):
            i.stud(sx, sy, 3.4, colour)
        i.gloss(cx - 4, 18, 4.5, 1.8)
    return i


def snails(count: int) -> Icon:
    names = {2: "duo", 3: "trio", 4: "quads"}
    i = Icon(names[count], f"{names[count].title()}: {count} snails, the game's own, on a team")
    placements = {
        2: [(36, 27, 0.78), (24, 43, 0.86)],
        3: [(22, 22, 0.66), (44, 26, 0.66), (30, 45, 0.74)],
        4: [(20, 20, 0.58), (44, 20, 0.58), (18, 43, 0.62), (42, 45, 0.62)],
    }
    for (x, y, s) in placements[count]:
        snail(i, x, y, s)
    return i


def bots() -> Icon:
    i = Icon("bots", "Solo vs bots: a studded metal robot head, glowing eyes, a red antenna light")
    i.shape("rect", 'x="29" y="6" width="6" height="11" rx="1.5"', "metal", "d", 2.2)
    i.shape("circle", 'cx="32" cy="5" r="4"', "red", "d", 2)
    i.add('<circle cx="30.7" cy="3.7" r="1.2" fill="#ffffff" opacity="0.8"/>')
    i.shape("rect", 'x="4" y="27" width="8" height="14" rx="3"', "metal")
    i.shape("rect", 'x="52" y="27" width="8" height="14" rx="3"', "metal")
    i.shape("rect", 'x="9" y="15" width="46" height="42" rx="10"', "metal")
    i.shape("rect", 'x="15" y="24" width="34" height="18" rx="6"', "dark", "v", 2.2)
    for ex in (24, 40):
        i.add(f'<circle cx="{ex}" cy="33" r="5.5" fill="{TONES["cyan"][1]}" opacity="0.35"/>')
        i.shape("circle", f'cx="{ex}" cy="33" r="3.6"', "cyan", "v", 1.6)
        i.add(f'<circle cx="{ex - 1.2}" cy="31.8" r="1.1" fill="#ffffff"/>')
    for sx in (20, 28, 36, 44):
        i.stud(sx, 48.5, 3.6, "metal")
    i.stud(15.5, 19.5, 3, "metal")
    i.stud(48.5, 19.5, 3, "metal")
    i.gloss(22, 18.5, 7, 2.4)
    return i


def party() -> Icon:
    i = Icon("party", "Party: a striped party hat with studs, a pom-pom and confetti")
    for (x, y, colour, r) in ((9, 18, "yellow", 20), (55, 24, "blue", -30), (12, 46, "green", 45), (54, 50, "red", 10)):
        i.add(f'<rect x="{x - 3}" y="{y - 1.6}" width="6" height="3.2" rx="1" fill="{TONES[colour][1]}" stroke="{INK}" stroke-width="1.4" transform="rotate({r} {x} {y})"/>')
    i.shape("path", 'd="M32 8 L50 54 Q32 61 14 54 Z"', "purple", "d")
    i.add('<clipPath id="hat"><path d="M32 8 L50 54 Q32 61 14 54 Z"/></clipPath>')
    i.add(
        f'<g clip-path="url(#hat)"><path d="M10 40 L54 30 L54 38 L10 48 Z" fill="{i.tone("yellow")}" stroke="{INK}" stroke-width="1.6"/>'
        f'<path d="M10 24 L54 14 L54 20 L10 30 Z" fill="{i.tone("yellow")}" stroke="{INK}" stroke-width="1.6"/></g>'
    )
    i.add(f'<path d="M32 8 L50 54 Q32 61 14 54 Z" fill="none" stroke="{INK}" stroke-width="{LINE}" stroke-linejoin="round"/>')
    for (sx, sy, colour) in ((27, 50, "purple"), (37, 50, "purple"), (32, 33, "purple"), (31, 22, "yellow"), (24, 41, "yellow"), (40, 39, "yellow")):
        i.stud(sx, sy, 3.2, colour)
    i.shape("circle", 'cx="32" cy="10" r="5.5"', "red", "d", 2.2)
    i.add('<circle cx="30.2" cy="8.2" r="1.6" fill="#ffffff" opacity="0.8"/>')
    i.gloss(28.8, 30, 1.6, 6, 22, 0.35)
    return i


def custom() -> Icon:
    i = Icon("custom", "Custom: a violet studded panel with three metal sliders and coloured knobs")
    i.shape("rect", 'x="7" y="8" width="50" height="48" rx="9"', "purple", "d")
    for (y, knob, colour) in ((20, 22, "yellow"), (32, 41, "cyan"), (44, 30, "red")):
        i.shape("rect", f'x="14" y="{y - 2.2}" width="36" height="4.4" rx="2.2"', "dark", "v", 1.8)
        i.shape("rect", f'x="{knob - 4}" y="{y - 5}" width="8" height="10" rx="2.6"', colour, "v", 2)
        i.add(f'<rect x="{knob - 2.4}" y="{y - 3.6}" width="4.8" height="2.6" rx="1" fill="#ffffff" opacity="0.6"/>')
    for (sx, sy) in ((12, 12.5), (52, 12.5), (12, 51.5), (52, 51.5)):
        i.stud(sx, sy, 3.2, "purple")
    i.gloss(18, 11.5, 7, 1.6, 0, 0.45)
    return i


def local() -> Icon:
    i = Icon("local", "Local: a red studded couch with a gamepad on its seat")
    i.shape("rect", 'x="9" y="10" width="46" height="26" rx="7"', "red")
    for sx in (18, 26, 38, 46):
        i.stud(sx, 17, 3.4, "red")
    i.shape("rect", 'x="3" y="26" width="12" height="26" rx="5"', "red", "d")
    i.shape("rect", 'x="49" y="26" width="12" height="26" rx="5"', "red", "d")
    i.shape("rect", 'x="11" y="34" width="42" height="16" rx="5"', "red")
    i.shape("rect", 'x="8" y="50" width="6" height="6" rx="1.5"', "wood", "v", 2)
    i.shape("rect", 'x="50" y="50" width="6" height="6" rx="1.5"', "wood", "v", 2)
    # The gamepad on the seat
    i.shape("path", 'd="M20 34 Q20 27 27 27 L37 27 Q44 27 44 34 L46 44 Q46 49 41 48 L37 43 L27 43 L23 48 Q18 49 18 44 Z"', "dark", "v", 2.2)
    i.add(f'<path d="M24.5 32 h5 M27 29.5 v5" stroke="{TONES["metal"][0]}" stroke-width="1.8" stroke-linecap="round"/>')
    for (bx, by, colour) in ((38, 30.5, "yellow"), (41, 33, "red"), (35, 33, "blue"), (38, 35.5, "green")):
        i.add(f'<circle cx="{bx}" cy="{by}" r="1.5" fill="{TONES[colour][1]}" stroke="{INK}" stroke-width="0.8"/>')
    i.gloss(18, 14, 6, 1.8, 0, 0.45)
    return i


def tutorial() -> Icon:
    i = Icon("tutorial", "Tutorial: a green studded target with an arrow in its bullseye")
    i.shape("circle", 'cx="28" cy="36" r="22"', "green", "d")
    i.shape("circle", 'cx="28" cy="36" r="14"', "white", "d", 2.2)
    i.shape("circle", 'cx="28" cy="36" r="7"', "green", "d", 2.2)
    for (x, y) in ((28, 17.5), (13, 30), (43, 31), (15, 47), (41, 48)):
        i.stud(x, y, 3.6, "green")
    i.gloss(20, 24, 7, 3)
    # The arrow, stuck in the middle from the top right
    i.add(f'<path d="M29 35 L55 9" stroke="{INK}" stroke-width="5.6" stroke-linecap="round"/>')
    i.add(f'<path d="M29 35 L55 9" stroke="{TONES["wood"][1]}" stroke-width="2.6" stroke-linecap="round"/>')
    i.shape("path", 'd="M51 6 L58 5 L59 12 L55 9 Z"', "red", "d", 1.8)
    i.shape("path", 'd="M48 9 L52 2 L56 6 L52 12 Z"', "red", "d", 1.8)
    return i


def random() -> Icon:
    i = Icon("random", "Random map: a chunky white die with rounded edges and glossy red pips on its faces")
    # The die's corners: the top face's four, then the bottom ones
    t_back, t_right, t_front, t_left = (32, 5), (57, 17.5), (32, 30), (7, 17.5)
    b_right, b_front, b_left = (57, 45), (32, 58.5), (7, 45)

    def rounded(points: list, r: float) -> str:
        """A closed path through the points with each corner rounded r units along its edges."""
        out = []
        n = len(points)
        for k in range(n):
            px, py = points[k]
            ax, ay = points[k - 1]
            bx, by = points[(k + 1) % n]
            da = ((ax - px) ** 2 + (ay - py) ** 2) ** 0.5
            db = ((bx - px) ** 2 + (by - py) ** 2) ** 0.5
            sx, sy = px + (ax - px) * r / da, py + (ay - py) * r / da
            ex, ey = px + (bx - px) * r / db, py + (by - py) * r / db
            out.append(f"{'M' if k == 0 else 'L'}{sx:.2f},{sy:.2f} Q{px},{py} {ex:.2f},{ey:.2f}")
        return " ".join(out) + " Z"

    # The faces, light top, mid left, darker right, under one rounded outline
    i.defs["die_top"] = '<linearGradient id="die_top" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#eef2f8"/></linearGradient>'
    i.defs["die_left"] = '<linearGradient id="die_left" x1="0" y1="0" x2="0.4" y2="1"><stop offset="0" stop-color="#eef2f8"/><stop offset="1" stop-color="#c3ccda"/></linearGradient>'
    i.defs["die_right"] = '<linearGradient id="die_right" x1="1" y1="0" x2="0.6" y2="1"><stop offset="0" stop-color="#cfd7e3"/><stop offset="1" stop-color="#97a2b6"/></linearGradient>'
    i.defs["pip"] = '<radialGradient id="pip" cx="0.38" cy="0.32" r="0.75"><stop offset="0" stop-color="#ff7a6b"/><stop offset="0.55" stop-color="#e8322a"/><stop offset="1" stop-color="#9e1418"/></radialGradient>'
    i.add(f'<path d="{rounded([t_left, t_front, b_front, b_left], 3)}" fill="url(#die_left)"/>')
    i.add(f'<path d="{rounded([t_front, t_right, b_right, b_front], 3)}" fill="url(#die_right)"/>')
    i.add(f'<path d="{rounded([t_left, t_back, t_right, t_front], 3)}" fill="url(#die_top)"/>')
    # The soft bevel where the faces meet, lit along the top face's front edges
    i.add(f'<path d="M{t_left[0] + 3},{t_left[1] + 1.5} L{t_front[0]},{t_front[1]} L{t_right[0] - 3},{t_right[1] + 1.5}" fill="none" stroke="#ffffff" stroke-width="1.6" stroke-linecap="round" opacity="0.9"/>')
    i.add(f'<path d="M{t_front[0]},{t_front[1] + 1.5} L{b_front[0]},{b_front[1] - 3}" stroke="{INK}" stroke-width="1.2" opacity="0.35"/>')
    i.add(f'<path d="{rounded([t_left, t_back, t_right, b_right, b_front, b_left], 4)}" fill="none" stroke="{INK}" stroke-width="{LINE}" stroke-linejoin="round"/>')

    # Pips lie on their faces: drawn on a unit square mapped onto each face
    faces = {
        "top": (t_left, (t_back[0] - t_left[0], t_back[1] - t_left[1]), (t_front[0] - t_left[0], t_front[1] - t_left[1])),
        "left": (t_left, (t_front[0] - t_left[0], t_front[1] - t_left[1]), (b_left[0] - t_left[0], b_left[1] - t_left[1])),
        "right": (t_front, (t_right[0] - t_front[0], t_right[1] - t_front[1]), (b_front[0] - t_front[0], b_front[1] - t_front[1])),
    }
    pips = {"top": [(0.5, 0.5, 0.15)], "left": [(0.28, 0.28, 0.11), (0.72, 0.72, 0.11)], "right": [(0.25, 0.25, 0.1), (0.5, 0.5, 0.1), (0.75, 0.75, 0.1)]}
    for face, spots in pips.items():
        (ox, oy), (ux, uy), (vx, vy) = faces[face]
        group = [f'<g transform="matrix({ux} {uy} {vx} {vy} {ox} {oy})">']
        for (s, t, r) in spots:
            group.append(f'<circle cx="{s}" cy="{t}" r="{r * 1.18}" fill="{INK}" opacity="0.85"/>')
            group.append(f'<circle cx="{s}" cy="{t}" r="{r}" fill="url(#pip)"/>')
            group.append(f'<ellipse cx="{s - r * 0.32}" cy="{t - r * 0.36}" rx="{r * 0.34}" ry="{r * 0.22}" fill="#ffffff" opacity="0.85"/>')
        group.append("</g>")
        i.add("".join(group))
    i.gloss(23, 13.5, 6, 1.7, -26, 0.75)
    return i


def main() -> None:
    SRC.mkdir(exist_ok=True)
    for icon in (deathmatch(), teams(), snails(2), snails(3), snails(4), bots(), party(), custom(), local(), tutorial(), random()):
        write(icon)
    print("wrote", len(list(SRC.glob("*.svg"))), "icons")


if __name__ == "__main__":
    main()
