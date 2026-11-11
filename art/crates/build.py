"""Renders the crate opening's game pictures into PNGs ready to upload: python -I build.py

The crate and STYLE icons (make_icons.py) at 512 x 512, the effect pictures (fx.py) at their own sizes, and the black
hole's disk as a 4 x 8 flipbook (1024 x 1024, 256 x 128 a frame). Each SVG is drawn by a Chromium browser (Chrome or
Edge, headless; WB_BROWSER names another) at twice the size and scaled down, then gets the pixel fix: fully clear
pixels take the colour of the nearest drawn ones, so Roblox's filtering never pulls a dark or white fringe into the
edges. Writes out/png/<Name>.png. Nothing here uploads anything (README.md → Uploading).
"""

import base64
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.argv = sys.argv[:1] + [str(HERE / "out")]

import fx  # noqa: E402
import make_icons  # noqa: E402

OUT = HERE / "out" / "png"
SUPERSAMPLE = 2
GAME_ICONS = ["Crate_Weapon", "Crate_Premium", "Crate_Utility", "Crate_Skin", "Crate_Starter", "Menu_Style"]

BROWSERS = [
    os.environ.get("WB_BROWSER", ""),
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]


def find_browser():
    for path in BROWSERS:
        if path and Path(path).is_file():
            return path
    sys.exit("No Chrome or Edge found: set WB_BROWSER to a Chromium browser's exe")


def draw(svg_text, w, h, temp):
    """One SVG drawn by the browser at SUPERSAMPLE times its size, scaled back down."""
    uri = "data:image/svg+xml;base64," + base64.b64encode(svg_text.encode("utf-8")).decode()
    W, H = w * SUPERSAMPLE, h * SUPERSAMPLE
    html = Path(temp) / "draw.html"
    shot = Path(temp) / "draw.png"
    html.write_text(f'<!doctype html><html><head><style>html,body{{margin:0;background:transparent;overflow:hidden}}'
                    f'img{{display:block}}</style></head><body><img src="{uri}" width="{W}" height="{H}"></body></html>',
                    encoding="utf-8")
    subprocess.run([find_browser(), "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                    "--default-background-color=00000000", f"--user-data-dir={Path(temp) / 'profile'}",
                    f"--window-size={W},{H}", f"--screenshot={shot}", html.as_uri()], check=True, capture_output=True)
    return Image.open(shot).convert("RGBA").crop((0, 0, W, H)).resize((w, h), Image.LANCZOS)


def pixel_fix(im, steps=12):
    """Spreads the colour of drawn pixels into the clear ones around them (alpha stays as it is)."""
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
    out = np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as temp:
        for name in GAME_ICONS:
            pixel_fix(draw(make_icons.ICONS[name](), 512, 512, temp)).save(OUT / f"{name}.png")
            print(f"{name}.png  512 x 512")
        for name, fn in fx.PICTURES.items():
            w, h, text = fn()
            pixel_fix(draw(text, w, h, temp)).save(OUT / f"{name}.png")
            print(f"{name}.png  {w} x {h}")
        sheet = Image.new("RGBA", (fx.DISK_COLS * fx.DISK_W, fx.DISK_ROWS * fx.DISK_H), (0, 0, 0, 0))
        frames = fx.DISK_COLS * fx.DISK_ROWS
        for i in range(frames):
            phase = -2 * 3.141592653589793 * i / frames
            cell = draw(fx.disk_frame(phase), fx.DISK_W, fx.DISK_H, temp)
            sheet.alpha_composite(cell, ((i % fx.DISK_COLS) * fx.DISK_W, (i // fx.DISK_COLS) * fx.DISK_H))
        pixel_fix(sheet).save(OUT / "Fx_Disk.png")
        print(f"Fx_Disk.png  {sheet.width} x {sheet.height} ({fx.DISK_COLS} x {fx.DISK_ROWS} frames)")


if __name__ == "__main__":
    main()
