"""The turn arrow: a fat red arrow pointing down at the snail whose turn it is (the owner, 2026-11-11, from Worms
Armageddon's bouncing arrow), in the game's icon style (the ink outline, a flat fill with a light edge and a darker
side). python -I make_turn_arrow.py

An SVG on a 128 x 160 grid; out/TurnArrow.svg and, drawn by Chrome or Edge through the crate kit's build.py,
out/TurnArrow.png (128 x 160, transparent, pixel-fixed). Then it's copied into Roblox Studio's content folder,
rbxasset://textures/wb_hud/TurnArrow.png, to try a redraw on this PC before it's uploaded (README -> Uploading).
"""

import os
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

INK = "#1b1530"
RED = "#f2382c"
RED_DARK = "#b81d1d"
RED_LIGHT = "#ff8a70"
OW = 8  # the ink outline's width
W, H = 128, 160

# The arrow's outline: a shaft with rounded top corners over a wide head
SHAFT = "M 42 22 Q 42 10 54 10 L 74 10 Q 86 10 86 22 L 86 76 L 42 76 Z"
HEAD = "M 12 72 L 116 72 L 64 148 Z"


def svg():
    ink = (f'<path d="{SHAFT}" fill="{INK}" stroke="{INK}" stroke-width="{OW * 2}" stroke-linejoin="round"/>'
           f'<path d="{HEAD}" fill="{INK}" stroke="{INK}" stroke-width="{OW * 2}" stroke-linejoin="round"/>')
    fill = (f'<path d="{SHAFT}" fill="url(#body)"/>'
            f'<path d="{HEAD}" fill="url(#body)" stroke="url(#body)" stroke-width="2" stroke-linejoin="round"/>')
    # The darker right side and the light left edge, inside the silhouette
    shade = ('<clipPath id="arrow"><path d="' + SHAFT + '"/><path d="' + HEAD + '"/></clipPath>'
             '<g clip-path="url(#arrow)">'
             f'<path d="M 72 0 L 128 0 L 128 160 L 64 160 L 92 72 L 72 72 Z" fill="{RED_DARK}" opacity="0.55"/>'
             f'<rect x="46" y="16" width="9" height="56" rx="4.5" fill="{RED_LIGHT}"/>'
             f'<path d="M 22 78 L 46 78 L 62 102 Z" fill="{RED_LIGHT}" opacity="0.8"/>'
             '</g>')
    defs = (f'<linearGradient id="body" x1="0" y1="0" x2="0" y2="1">'
            f'<stop offset="0" stop-color="#ff5a46"/><stop offset="1" stop-color="{RED}"/></linearGradient>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">'
            f'<defs>{defs}</defs>{ink}{fill}{shade}</svg>')


def to_studio(png):
    versions = Path(os.environ["LOCALAPPDATA"]) / "Roblox" / "Versions"
    studios = [p for p in versions.glob("version-*") if (p / "RobloxStudioBeta.exe").is_file()]
    if not studios:
        sys.exit(f"No Roblox Studio found in {versions}")
    studio = max(studios, key=lambda p: (p / "RobloxStudioBeta.exe").stat().st_mtime)
    target = studio / "content" / "textures" / "wb_hud"
    target.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(png, target / png.name)
    print(f"{png.name} to {target} (rbxasset://textures/wb_hud/)")


def main():
    sys.path.insert(0, str(HERE.parent / "crates"))
    import build  # noqa: E402

    OUT.mkdir(exist_ok=True)
    text = svg()
    (OUT / "TurnArrow.svg").write_text(text, encoding="utf-8")
    with tempfile.TemporaryDirectory() as temp:
        im = build.pixel_fix(build.draw(text, W, H, temp))
    png = OUT / "TurnArrow.png"
    im.save(png)
    print(f"{png}")
    to_studio(png)


if __name__ == "__main__":
    main()
