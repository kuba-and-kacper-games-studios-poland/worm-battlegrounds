"""The top bar's icons: Leave game, and the music button's playing and muted looks (the owner, 2026-11-13: "change
header leave game and mute music to be an custom svg icon"). python -I make_icons.py

White glyphs with round strokes on a 24 x 24 grid, like the Settings gear beside them on the bar's dark round
buttons. out/<Name>.svg and, drawn by Chrome or Edge through the crate kit's build.py, out/<Name>.png (128 x 128,
transparent, pixel-fixed), plus out/preview.png: each icon on the bar's button colour, large and at its in-game size.

    python -I make_icons.py --raw   # when headless Chrome or Edge won't start: uses out/raw/<Name>.png instead, the
                                    # SVGs drawn at 256 x 256 by any browser (a canvas's toDataURL), then shrinks them
"""

import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

WHITE = "#ffffff"
STROKE = 2.4
SIZE = 128

# The top bar button's background (TopBar's PREFAB | Button), for the preview
BUTTON = (18, 18, 20, 255)

LINE = f'fill="none" stroke="{WHITE}" stroke-width="{STROKE}" stroke-linecap="round" stroke-linejoin="round"'

# A door frame open to the right, and an arrow leaving through it
LEAVE = (f'<path d="M 10.5 3.5 H 6 A 2.5 2.5 0 0 0 3.5 6 V 18 A 2.5 2.5 0 0 0 6 20.5 H 10.5" {LINE}/>'
         f'<path d="M 15 7.5 L 19.5 12 L 15 16.5 M 19.5 12 H 9.5" {LINE}/>')

# Two beamed notes
NOTES = (f'<path d="M 9 17.5 V 5.8 L 19.5 3.8 V 15.5" {LINE}/>'
         f'<path d="M 9 8.8 L 19.5 6.8" {LINE}/>'
         f'<circle cx="6.4" cy="17.6" r="2.9" fill="{WHITE}"/><circle cx="16.9" cy="15.6" r="2.9" fill="{WHITE}"/>')

# The notes with a slash through them, cut clear around it so it reads on the dark button
MUTED = ('<defs><mask id="cut"><rect width="24" height="24" fill="#fff"/>'
         '<path d="M 3.5 3.5 L 20.5 20.5" stroke="#000" stroke-width="5.6" stroke-linecap="round"/></mask></defs>'
         f'<g mask="url(#cut)">{NOTES}</g>'
         f'<path d="M 3.5 3.5 L 20.5 20.5" {LINE}/>')

ICONS = {
    "TopBar_Leave": LEAVE,
    "TopBar_Music": NOTES,
    "TopBar_MusicOff": MUTED,
}


def svg(body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="{SIZE}" height="{SIZE}">'
            f"{body}</svg>")


def preview(pngs):
    """Each icon on the bar's round dark button, at 96 px and at its in-game size (a 44 px button, the icon 0.6 of it)."""
    big, small = 160, 44
    sheet = Image.new("RGBA", (len(pngs) * (big + 24) + 24, big + small + 72), (236, 236, 240, 255))
    draw = ImageDraw.Draw(sheet)
    for index, png in enumerate(pngs):
        x = 24 + index * (big + 24)
        for size, y in ((big, 24), (small, big + 48)):
            left = x + (big - size) // 2
            draw.ellipse((left, y, left + size, y + size), fill=BUTTON)
            icon = Image.open(png).resize((round(size * 0.6),) * 2, Image.LANCZOS)
            offset = (size - icon.width) // 2
            sheet.alpha_composite(icon, (left + offset, y + offset))
    sheet.save(OUT / "preview.png")
    print(OUT / "preview.png")


def main():
    # Read before importing the crate kit's build.py, which overwrites sys.argv
    raw = "--raw" in sys.argv[1:]
    sys.path.insert(0, str(HERE.parent / "crates"))
    import build  # noqa: E402

    OUT.mkdir(exist_ok=True)
    pngs = []
    with tempfile.TemporaryDirectory() as temp:
        for name, body in ICONS.items():
            text = svg(body)
            (OUT / f"{name}.svg").write_text(text, encoding="utf-8")
            png = OUT / f"{name}.png"
            if raw:
                drawn = Image.open(OUT / "raw" / f"{name}.png").convert("RGBA").resize((SIZE, SIZE), Image.LANCZOS)
            else:
                drawn = build.draw(text, SIZE, SIZE, temp)
            build.pixel_fix(drawn).save(png)
            pngs.append(png)
            print(png)
    preview(pngs)


if __name__ == "__main__":
    main()
