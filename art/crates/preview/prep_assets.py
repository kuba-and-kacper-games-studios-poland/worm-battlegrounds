"""Packs the preview's pictures, icons and sounds into assets.js (window.ASSETS) as data URIs, and writes local.html
(the page in a plain document, to open from a local server). python -I prep_assets.py

Reads the icons from ../out (make_icons.py), the sounds from ../../sfx/out/crates (make_crates.py) and the classic
interface sounds from ../../sfx/tools/classic/sfx. The GACHA design's frame pictures and the item icons come from
Roblox's thumbnail service by their asset ids, kept in rbx/ once fetched.
"""

import base64
import io
import json
import os
import shutil
import subprocess
import time
import urllib.request

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
RBX = os.path.join(HERE, "rbx")
ICONS = os.path.join(HERE, "..", "out")
SOUNDS = os.path.join(HERE, "..", "..", "sfx", "out", "crates")
CLASSIC = os.path.join(HERE, "..", "..", "sfx", "tools", "classic", "sfx")
OUT = os.path.join(HERE, "assets.js")

# name: (asset id, max side)
FRAMES = {
    # buy buttons
    "btn_main": (96244980257546, 420), "btn_stroke2": (103072937449096, 420), "btn_stroke": (98742725293542, 420),
    "btn_mask1": (106229793977777, 420), "btn_mask3": (100191324557254, 420), "btn_mask10": (137426694977730, 420),
    # GACHA title
    "title_main": (88013810407898, 420), "title_stroke2": (87371004434929, 420), "title_stroke": (81942735029674, 420),
    "title_mask": (131707844605248, 420),
    # BACK
    "back_main": (95065331631570, 300), "back_stroke2": (95688740078512, 300), "back_stroke": (115753650835461, 300),
    "back_mask": (102884751367093, 300),
    # balance chip
    "chip_main": (132693594544527, 420), "chip_stroke2": (110464716728942, 420), "chip_stroke": (129410270943519, 420),
    # rarity title bar
    "rt_main": (137437419218560, 420), "rt_stroke2": (139463011136255, 420), "rt_stroke": (72397301720248, 420),
    "rt_mask_legendary": (126861876368601, 420), "rt_mask_epic": (74301135635535, 420),
    "rt_mask_uncommon": (93672739452112, 420), "rt_mask_common": (126071489533238, 420),
    # odds item card
    "card_main": (111365905871167, 300), "card_stroke2": (76134696210650, 300), "card_stroke": (92579798166886, 300),
    # crate tab
    "tab_main": (86349849024067, 300), "tab_stroke2": (125225982857692, 300), "tab_stroke_sel": (125468000183098, 300),
    "tab_stroke": (82355483585473, 300),
    # lobby corner menu button (STYLE / WEAPONS / SKINS)
    "menu_main": (124280522035091, 300), "menu_stroke2": (98436890421039, 300), "menu_stroke": (100794772551035, 300),
}
# The game's classic interface sounds (Roblox 2009 uploads, in the sound kit's tools/classic/sfx)
CLASSIC_UI = {"Button_Click": "button", "Button_Hover": "clickfast", "Button_Close": "SWITCH3"}
ITEMS = {
    "BlackHoleGrenade": 126733567159283, "VarietyGrenade": 132575441840814, "HomingMissile": 107350591430267,
    "SpiderBomb": 126313994651146, "Minigun": 93480916921558, "ClusterBomb": 125982425140000,
    "SpartanSpear": 120095788569892, "Uzi": 79744307043186, "Dynamite": 99998769993186, "Grenade": 88613468948489,
    "Shotgun": 104705832389891, "Bandage": 101586916045478, "Jetpack": 99911728604760, "Medkit": 85030401627405,
    "SpeedPotion": 129368162518915, "Coins": 108986846988315, "Diamonds": 76353040161236,
    "Placeholder": 121731184312632,
}


def fetch(ids):
    """Downloads the 420 px thumbnails of the pictures not in rbx/ yet."""
    os.makedirs(RBX, exist_ok=True)
    missing = [str(i) for i in ids if not os.path.exists(os.path.join(RBX, f"{i}.png"))]
    for attempt in range(6):
        if not missing:
            return
        url = ("https://thumbnails.roblox.com/v1/assets?assetIds=" + ",".join(missing)
               + "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false")
        rows = json.loads(urllib.request.urlopen(url, timeout=30).read())["data"]
        for row in rows:
            if row["state"] == "Completed":
                with open(os.path.join(RBX, f"{row['targetId']}.png"), "wb") as fh:
                    fh.write(urllib.request.urlopen(row["imageUrl"], timeout=30).read())
        missing = [i for i in missing if not os.path.exists(os.path.join(RBX, f"{i}.png"))]
        time.sleep(2)
    if missing:
        raise SystemExit(f"Thumbnails still pending: {missing}; run again in a minute")


def crop(im):
    bbox = im.getchannel("A").point(lambda a: 255 if a > 6 else 0).getbbox()
    return im.crop(bbox) if bbox else im


def webp(path, max_side):
    im = crop(Image.open(path).convert("RGBA"))
    k = min(1.0, max_side / max(im.size))
    if k < 1:
        im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "WEBP", quality=88, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode(), im.size


def mp3(path):
    r = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", path, "-codec:a", "libmp3lame", "-b:a", "128k", "-ac", "1",
                        "-f", "mp3", "-"], check=True, capture_output=True)
    return "data:audio/mpeg;base64," + base64.b64encode(r.stdout).decode()


def main():
    fetch([aid for aid, _ in FRAMES.values()] + list(ITEMS.values()))
    assets = {"img": {}, "size": {}, "svg": {}, "snd": {}, "sndInfo": {}}
    for name, (aid, side) in FRAMES.items():
        uri, size = webp(os.path.join(RBX, f"{aid}.png"), side)
        assets["img"][name] = uri
        assets["size"][name] = size
    for name, aid in ITEMS.items():
        uri, size = webp(os.path.join(RBX, f"{aid}.png"), 220)
        assets["img"]["item_" + name] = uri
        assets["size"]["item_" + name] = size
    for f in sorted(os.listdir(ICONS)):
        if f.endswith(".svg"):
            with open(os.path.join(ICONS, f), "rb") as fh:
                assets["svg"][f[:-4]] = "data:image/svg+xml;base64," + base64.b64encode(fh.read()).decode()
    with open(os.path.join(SOUNDS, "crates.json"), encoding="utf-8") as fh:
        info = json.load(fh)
    for name in info:
        assets["snd"][name] = mp3(os.path.join(SOUNDS, f"WB_{name}.wav"))
        assets["sndInfo"][name] = info[name]
    for name, src in CLASSIC_UI.items():
        assets["snd"][name] = mp3(os.path.join(CLASSIC, f"{src}.wav"))
    js = "window.ASSETS = " + json.dumps(assets, separators=(",", ":")) + ";\n"
    # the 3D crates (make_models.py) are fetched by crate3d.js from 3d/
    models = os.path.join(HERE, "..", "out", "3d")
    os.makedirs(os.path.join(HERE, "3d"), exist_ok=True)
    for f in sorted(os.listdir(models)) if os.path.isdir(models) else []:
        if f.endswith(".glb"):
            shutil.copyfile(os.path.join(models, f), os.path.join(HERE, "3d", f))
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(js)
    with open(os.path.join(HERE, "crate-preview.html"), encoding="utf-8") as fh:
        page = fh.read()
    with open(os.path.join(HERE, "local.html"), "w", encoding="utf-8") as fh:
        fh.write('<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,'
                 'initial-scale=1,viewport-fit=cover"><style>body{margin:0}[hidden]{display:none!important}</style>'
                 '</head><body>\n' + page + "\n</body></html>\n")
    print(f"{len(js) / 1e6:.2f} MB", {k: len(v) for k, v in assets.items()})
    print({k: v for k, v in assets["size"].items() if not k.startswith("item_")})


if __name__ == "__main__":
    main()
