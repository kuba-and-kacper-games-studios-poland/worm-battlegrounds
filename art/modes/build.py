"""Worm Battlegrounds' mode icons: renders the SVG sources in src/ into PNGs and the review page.

    python -I build.py            # out/<name>.png (256 px) and preview.html

The SVGs are drawn by a Chromium browser (Chrome or Edge, headless; set WB_BROWSER to use another) at twice the
size and scaled down with Pillow, then get the pixel fix (the crate kit's: fully clear pixels take the colour of the
nearest drawn ones, so Roblox's filtering never pulls a dark fringe into the edges). Nothing here uploads anything, or
copies anything into Studio.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
SRC = HERE / "src"
OUT = HERE / "out"

# One icon per way to play, as the game's MODE_ICONS rows name them (MatchBoard's Settings)
ICONS = [
    ("deathmatch", "Deathmatch"),
    ("teams", "Teams"),
    ("duo", "Duo"),
    ("trio", "Trio"),
    ("quads", "Quads"),
    ("bots", "Solo vs bots"),
    ("party", "Party"),
    ("custom", "Custom"),
    ("local", "Local"),
    ("tutorial", "Tutorial"),
    ("random", "Random map"),
]

SIZE = 256
SUPERSAMPLE = 2

BROWSERS = [
    os.environ.get("WB_BROWSER", ""),
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]


def find_browser() -> str:
    """The first Chromium browser found."""
    for path in BROWSERS:
        if path and Path(path).is_file():
            return path
    sys.exit("No Chrome or Edge found: set WB_BROWSER to a Chromium browser's exe")


def pixel_fix(im: Image.Image, steps: int = 12) -> Image.Image:
    """Spreads the colour of drawn pixels into the clear ones around them (alpha stays as it is), as the crate kit does."""
    a = np.asarray(im).astype(np.float32)
    rgb, alpha = a[..., :3].copy(), a[..., 3]
    known = alpha > 0
    for _ in range(steps):
        acc = np.zeros_like(rgb)
        cnt = np.zeros(alpha.shape, np.float32)
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)):
            k = np.roll(np.roll(known, dy, 0), dx, 1)
            c = np.roll(np.roll(rgb, dy, 0), dx, 1)
            acc += c * k[..., None]
            cnt += k
        grow = (~known) & (cnt > 0)
        rgb[grow] = acc[grow] / cnt[grow][:, None]
        known = known | grow
    rgb[~known] = rgb[known].mean(axis=0) if known.any() else 0
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")


def render() -> None:
    """Draws every icon side by side on a transparent page, screenshots it once and cuts out each icon."""
    tile = SIZE * SUPERSAMPLE
    images = "".join(
        f'<img src="{(SRC / f"{name}.svg").as_uri()}" width="{tile}" height="{tile}">' for name, _ in ICONS
    )
    page = (
        "<!doctype html><html><head><style>"
        "html,body{margin:0;padding:0;background:transparent;overflow:hidden}"
        "img{display:block;float:left}"
        f"</style></head><body>{images}</body></html>"
    )
    OUT.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory() as temp:
        html = Path(temp) / "render.html"
        shot = Path(temp) / "render.png"
        html.write_text(page, encoding="utf-8")
        subprocess.run(
            [
                find_browser(),
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--force-device-scale-factor=1",
                "--default-background-color=00000000",
                f"--user-data-dir={Path(temp) / 'profile'}",
                f"--window-size={tile * len(ICONS)},{tile}",
                "--allow-file-access-from-files",
                f"--screenshot={shot}",
                html.as_uri(),
            ],
            check=True,
            capture_output=True,
        )
        sheet = Image.open(shot).convert("RGBA")
        for index, (name, _) in enumerate(ICONS):
            icon = sheet.crop((index * tile, 0, (index + 1) * tile, tile))
            icon = icon.resize((SIZE, SIZE), Image.LANCZOS)
            pixel_fix(icon).save(OUT / f"{name}.png")
            print(f"out/{name}.png  {SIZE} x {SIZE}")


def preview() -> None:
    """preview.html: each icon large, then at the sizes the game shows them, on a dark card and on the sky."""
    cards = "".join(
        f'<figure><img src="out/{name}.png" width="128" height="128"><figcaption>{title}<br><code>out/{name}.png</code>'
        f"</figcaption></figure>"
        for name, title in ICONS
    )
    small = "".join(f'<img src="out/{name}.png" width="48" height="48" alt="{title}">' for name, title in ICONS)
    page = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Mode Icons</title>
<style>
body {{ margin:0; padding:24px 16px; background:#12131b; color:#f4f4f7; font-family:"Segoe UI",system-ui,sans-serif; }}
main {{ max-width:980px; margin:0 auto; }}
.cards {{ display:flex; flex-wrap:wrap; gap:12px; }}
figure {{ margin:0; padding:14px; background:#22222e; border-radius:12px; text-align:center; width:160px; }}
figcaption {{ font-size:13px; margin-top:8px; }} code {{ font-size:11px; color:#a7a7b6; }}
.strip {{ display:flex; gap:10px; padding:14px; border-radius:12px; margin-top:14px; }}
.dark {{ background:#191923; }} .sky {{ background:linear-gradient(#7ec8f2,#cdeeff); }}
</style></head><body><main>
<h1>Mode icons</h1>
<p>One icon per way to play (64 x 64 grid, rendered at 256 px), local until the owner approves them.</p>
<div class="cards">{cards}</div>
<div class="strip dark">{small}</div>
<div class="strip sky">{small}</div>
</main></body></html>
"""
    (HERE / "preview.html").write_text(page, encoding="utf-8")
    print("preview.html")


if __name__ == "__main__":
    render()
    preview()
