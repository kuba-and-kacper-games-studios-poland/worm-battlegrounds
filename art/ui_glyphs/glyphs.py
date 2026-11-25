"""Snail Battlegrounds' ui glyphs: writes src/<name>.svg, one minimal icon per lobby button and mode.

    python -I glyphs.py

The look is the studio's LobbyRework icons (DEATHMATCH, DUO, TRIO and the player count, 2026-11-24): solid white
shapes with a thick ink outline round the whole glyph, no colour, no gloss. Every glyph sits on a 64 x 64 grid inside
6..58, so they line up at one size. The outline is a stroke drawn under the fill (paint-order), so it only grows the
shape outwards; cut-outs inside a glyph are ink.
"""

from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE / "src"

INK = "#0c0c14"
WHITE = "#ffffff"
OUTLINE = 6


def svg(body: str) -> str:
    """A 64 x 64 glyph: every shape in `body` is white with the ink outline under it."""
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="256" height="256">'
        f'<g fill="{WHITE}" stroke="{INK}" stroke-width="{OUTLINE}" stroke-linejoin="round" stroke-linecap="round" '
        f'paint-order="stroke fill">{body}</g></svg>'
    )


def person(cx: float, top: float, scale: float = 1.0) -> str:
    """A person: a round head over rounded shoulders, its head's top at `top`."""
    r = 7.0 * scale
    head = f'<circle cx="{cx}" cy="{top + r}" r="{r}"/>'
    w = 12.5 * scale
    y = top + 2 * r + 2.5 * scale
    h = 13 * scale
    body = (
        f'<path d="M{cx - w},{y + h} C{cx - w},{y + 2 * scale} {cx - w * 0.55},{y} {cx},{y} '
        f'C{cx + w * 0.55},{y} {cx + w},{y + 2 * scale} {cx + w},{y + h} Z"/>'
    )
    return head + body


GLYPHS = {
    # A white disc with an ink crosshair in it
    "deathmatch": (
        '<circle cx="32" cy="32" r="24"/>'
        f'<g fill="none" stroke="{INK}" stroke-width="4.5" paint-order="normal">'
        '<circle cx="32" cy="32" r="12"/>'
        '<path d="M32 13 V22 M32 42 V51 M13 32 H22 M42 32 H51"/></g>'
        f'<circle cx="32" cy="32" r="3" fill="{INK}" stroke="none"/>'
    ),
    # Two people, the back one up and to the right
    "duo": person(40, 9, 0.95) + person(25, 13, 1.05),
    # Three people, the middle one in front
    "trio": person(16, 12, 0.85) + person(48, 12, 0.85) + person(32, 9, 1.05),
    # The play triangle, its corners rounded
    "play": '<path d="M20 12 Q20 8 24 10 L52 29 Q55 32 52 35 L24 54 Q20 56 20 52 Z"/>',
    # A gamepad: the body with two grips, a cross and two buttons cut in ink
    "local": (
        '<path d="M16 20 H48 Q58 20 59 34 L60 44 Q60 52 53 50 L44 42 H20 L11 50 Q4 52 4 44 L5 34 Q6 20 16 20 Z"/>'
        f'<g fill="{INK}" stroke="none">'
        '<rect x="15" y="27" width="4" height="12" rx="1"/><rect x="11" y="31" width="12" height="4" rx="1"/>'
        '<circle cx="44" cy="29" r="2.8"/><circle cx="50" cy="35" r="2.8"/></g>'
    ),
    # Three sliders, each a bar with a round knob
    "custom": (
        '<rect x="9" y="14" width="46" height="6" rx="3"/><circle cx="22" cy="17" r="6.5"/>'
        '<rect x="9" y="29" width="46" height="6" rx="3"/><circle cx="42" cy="32" r="6.5"/>'
        '<rect x="9" y="44" width="46" height="6" rx="3"/><circle cx="28" cy="47" r="6.5"/>'
    ),
    # A weapon crate: its lid over the box, a star cut into its front (the gift glyph until 2026-11-24)
    "freeweapons": (
        '<rect x="11" y="26" width="42" height="29" rx="3"/>'
        '<rect x="7" y="15" width="50" height="12" rx="3"/>'
        f'<g fill="{INK}" stroke="none"><path d="M32.0 30.5 L34.5 36.6 L41.0 37.1 L36.0 41.3 L37.6 47.7 L32.0 44.2 L26.4 47.7 L28.0 41.3 L23.0 37.1 L29.5 36.6 Z"/>'
        '</g>'
    ),
    # A paint brush, slanted, its tip down to the left
    "style": (
        '<path d="M50 8 Q56 10 54 15 L36 37 L29 31 L46 10 Q48 8 50 8 Z"/>'
        '<path d="M27 33 L34 39 Q33 47 25 52 Q17 57 9 55 Q13 51 14 45 Q16 35 27 33 Z"/>'
    ),
    # A rocket, slanted up to the right, with fins and a window cut in ink
    "weapons": (
        '<path d="M52 8 Q57 7 56 12 Q53 26 40 37 L27 24 Q38 11 52 8 Z"/>'
        '<path d="M27 24 L17 25 L9 33 L21 34 Z"/><path d="M40 37 L39 47 L31 55 L30 43 Z"/>'
        '<path d="M24 37 L27 40 Q22 48 13 51 Q16 42 24 37 Z"/>'
        f'<circle cx="44" cy="20" r="4" fill="{INK}" stroke="none"/>'
    ),
    # The game's bazooka, slanted up to the right: its tube with a wide muzzle, a back end, a sight and a grip
    "bazooka": (
        '<g transform="rotate(-28 32 34)">'
        '<rect x="20" y="40" width="7" height="13" rx="2"/>'
        '<rect x="5" y="26" width="9" height="16" rx="2.5"/>'
        '<rect x="9" y="28" width="40" height="12" rx="3"/>'
        '<rect x="46" y="24" width="12" height="20" rx="3"/>'
        '<rect x="27" y="20" width="9" height="7" rx="2"/>'
        f'<rect x="21" y="28" width="3.5" height="12" fill="{INK}" stroke="none"/>'
        f'<rect x="51" y="28" width="3.5" height="12" fill="{INK}" stroke="none"/>'
        '</g>'
    ),
    # A snail from the side: its foot, its head with two eye stalks, and its shell with the spiral in ink
    "snail": (
        '<path d="M6 51 Q6 44 14 44 L50 44 Q59 44 59 51 Q59 56 52 56 L11 56 Q6 56 6 51 Z"/>'
        '<rect x="8" y="27" width="11" height="22" rx="5.5"/>'
        '<g transform="rotate(-14 10 22)"><rect x="8.5" y="12" width="3.5" height="16" rx="1.75"/></g>'
        '<g transform="rotate(14 17 22)"><rect x="15.5" y="12" width="3.5" height="16" rx="1.75"/></g>'
        '<circle cx="8.8" cy="12.5" r="3.4"/><circle cx="19.3" cy="12.5" r="3.4"/>'
        '<circle cx="38" cy="31" r="16"/>'
        f'<path d="M38 31 m0 -2.5 a2.5 2.5 0 1 1 -2.5 2.5 a5 5 0 0 1 5 -5 a7.5 7.5 0 0 1 7.5 7.5 a10 10 0 0 1 -10 10 '
        f'a12.5 12.5 0 0 1 -12.5 -12.5" fill="none" stroke="{INK}" stroke-width="4" paint-order="normal"/>'
    ),
    # Easy bots: a white face, smiling, its eyes and smile cut in ink
    "easy": (
        '<circle cx="32" cy="32" r="24"/>'
        f'<g fill="{INK}" stroke="none"><ellipse cx="24" cy="27" rx="3.6" ry="4.6"/><ellipse cx="40" cy="27" rx="3.6" ry="4.6"/></g>'
        f'<path d="M20 37 Q32 50 44 37" fill="none" stroke="{INK}" stroke-width="4.5" paint-order="normal"/>'
    ),
    # Medium bots: a white face, set on it: brows down toward the middle and a straight mouth, in ink
    "medium": (
        '<circle cx="32" cy="32" r="24"/>'
        f'<g fill="{INK}" stroke="none"><ellipse cx="24" cy="30" rx="3.6" ry="4.2"/><ellipse cx="40" cy="30" rx="3.6" ry="4.2"/></g>'
        f'<path d="M17 20 L28 23 M47 20 L36 23 M23 42 H41" fill="none" stroke="{INK}" stroke-width="4.5" paint-order="normal"/>'
    ),
    # Hard bots: a skull, its eye sockets, nose and the gaps between its teeth in ink
    "hard": (
        '<path d="M32 6 C46 6 55 15 55 28 C55 36 51 41 46 43 L46 52 Q46 57 41 57 L23 57 Q18 57 18 52 L18 43 '
        'C13 41 9 36 9 28 C9 15 18 6 32 6 Z"/>'
        f'<g fill="{INK}" stroke="none"><ellipse cx="23" cy="29" rx="6" ry="6.5"/><ellipse cx="41" cy="29" rx="6" ry="6.5"/>'
        '<path d="M32 36 L35.5 42 H28.5 Z"/></g>'
        f'<path d="M26.5 48 V57 M32 48 V57 M37.5 48 V57" fill="none" stroke="{INK}" stroke-width="3" paint-order="normal"/>'
    ),
    # A snail's shell: a round shell with its spiral in ink
    "skins": (
        '<circle cx="32" cy="32" r="24"/>'
        f'<path d="M32 32 m0 -3 a3 3 0 1 1 -3 3 a6 6 0 0 1 6 -6 a9 9 0 0 1 9 9 a12 12 0 0 1 -12 12 '
        f'a15 15 0 0 1 -15 -15 a18 18 0 0 1 18 -18" fill="none" stroke="{INK}" stroke-width="4.5" paint-order="normal"/>'
    ),
}


def main() -> None:
    """Writes every glyph's SVG into src/."""
    SRC.mkdir(exist_ok=True)
    for name, body in GLYPHS.items():
        (SRC / f"{name}.svg").write_text(svg(body), encoding="utf-8")
        print(f"src/{name}.svg")


if __name__ == "__main__":
    main()
