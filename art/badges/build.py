"""Worm Battlegrounds' player badge icons: renders the SVG sources in src/ into PNGs and the review page.

    python -I build.py            # out/<name>.png (128 px) and preview.html
    python -I build.py --studio   # the same, then copies the PNGs into Roblox Studio's content folder
                                  # (textures/wb_badges/), so rbxasset://textures/wb_badges/<name>.png shows in Studio

The SVGs are drawn by a Chromium browser (Chrome or Edge, headless; set WB_BROWSER to use another) at twice the
size and scaled down with Pillow. Nothing here uploads anything.
"""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
SRC = HERE / "src"
OUT = HERE / "out"

# The badges in the order the game shows them, as the PlayerBadges module's BADGES rows name them
ICONS = [
    ("owner", "Game owner"),
    ("developer", "Developer"),
    ("admin", "Game admin"),
    ("staff", "Roblox staff"),
    ("star", "Star creator"),
]

SIZE = 128
SUPERSAMPLE = 2

# Studio's content folder name for local test pictures (practices.md: pictures stay local until approved)
STUDIO_FOLDER = "wb_badges"

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
            icon.save(OUT / f"{name}.png")
            print(f"out/{name}.png  {SIZE} x {SIZE}")


def copy_to_studio() -> None:
    """Copies the PNGs into the newest Roblox Studio's content/textures/wb_badges/."""
    versions = Path(os.environ["LOCALAPPDATA"]) / "Roblox" / "Versions"
    studios = [p for p in versions.glob("version-*") if (p / "RobloxStudioBeta.exe").is_file()]
    if not studios:
        sys.exit(f"No Roblox Studio found in {versions}")
    studio = max(studios, key=lambda p: (p / "RobloxStudioBeta.exe").stat().st_mtime)
    target = studio / "content" / "textures" / STUDIO_FOLDER
    target.mkdir(parents=True, exist_ok=True)
    for name, _ in ICONS:
        shutil.copyfile(OUT / f"{name}.png", target / f"{name}.png")
    print(f"Copied to {target} (rbxasset://textures/{STUDIO_FOLDER}/<name>.png)")


def preview() -> None:
    """preview.html: each badge large, then after sample names at the sizes the game shows them, on sky and sand."""
    pngs = {name: f"out/{name}.png" for name, _ in ICONS}
    cards = "".join(
        f'<figure><img src="{pngs[name]}" width="96" height="96"><figcaption>{title}<br><code>out/{name}.png</code>'
        f"</figcaption></figure>"
        for name, title in ICONS
    )

    def row(names: list, size: int) -> str:
        icons = "".join(f'<img src="{pngs[n]}" width="{size}" height="{size}">' for n in names)
        return f'<div class="row" style="font-size:{size}px"><span>DefinitelyNotBaxtrix</span>{icons}</div>'

    every = [name for name, _ in ICONS]
    rows = "".join(row(every, size) for size in (18, 24, 32)) + row(["developer"], 24) + row(["owner", "admin"], 24)
    page = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Player Badges</title>
<style>
:root {{ --ink:#19192a; --paper:#f6f3ea; --card:#ffffff; --muted:#5d5d70; }}
@media (prefers-color-scheme: dark) {{ :root {{ --ink:#ecebf5; --paper:#15151f; --card:#202030; --muted:#a3a3b8; }} }}
body {{ margin:0; padding:24px 16px; background:var(--paper); color:var(--ink);
  font-family:"Segoe UI",system-ui,sans-serif; }}
main {{ max-width:960px; margin:0 auto; }}
h1 {{ font-size:28px; margin:0 0 4px; }} h2 {{ font-size:18px; margin:28px 0 10px; }}
p {{ color:var(--muted); margin:0 0 12px; line-height:1.45; }}
.cards {{ display:flex; flex-wrap:wrap; gap:12px; }}
figure {{ margin:0; padding:14px; background:var(--card); border-radius:12px; text-align:center; width:150px; }}
figcaption {{ font-size:13px; margin-top:8px; }} code {{ font-size:11px; color:var(--muted); }}
.scene {{ border-radius:12px; padding:16px; margin-bottom:12px; }}
.sky {{ background:linear-gradient(#7ec8f2,#cdeeff); }} .sand {{ background:linear-gradient(#f2d7a0,#d9b06a); }}
.row {{ display:flex; align-items:center; gap:0.12em; margin:6px 0; color:#fff; font-weight:900;
  font-style:italic; -webkit-text-stroke:0.07em #19192a; paint-order:stroke fill; }}
.row span {{ margin-right:0.18em; }}
.row img {{ display:block; }}
</style></head><body><main>
<h1>Player badges</h1>
<p>The five icons drawn for the game (24 x 24 grid, rendered at 128 px), local until the owner approves them.
Verified and Premium are Roblox's own glyphs (U+E000, U+E001), drawn by the game's text, so they aren't here.</p>
<div class="cards">{cards}</div>
<h2>After a name, over the sky</h2>
<div class="scene sky">{rows}</div>
<h2>After a name, over sand</h2>
<div class="scene sand">{rows}</div>
</main></body></html>
"""
    (HERE / "preview.html").write_text(page, encoding="utf-8")
    print("preview.html")


if __name__ == "__main__":
    render()
    preview()
    if "--studio" in sys.argv[1:]:
        copy_to_studio()
