"""Cuts the Studio match shots into the lobby card (1024x272) and map tile (512x303) shapes."""
import os, sys
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS_DIR = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "out", "shots")  # the Studio captures

SHOTS = {
    # map: (capture file, card band (x0, y0, x1, y1), tile box (x0, y0, x1, y1))
    "Desert": ("Desert.jpg", (0, 280, 1733, 740), (520, 330, 1270, 775)),
    "EchoCaverns": ("EchoCaverns.jpg", (0, 280, 1733, 740), (500, 290, 1250, 735)),
    "RollingPlains": ("RollingPlains.jpg", (0, 380, 1733, 840), (520, 400, 1270, 845)),
}

# The cut of the current pictures, measured from the uploaded ones: a parallelogram leaning right (its sides move
# left by `slant` px per row), its left and right edges at the top, and a corner radius
SHAPES = {
    "card": dict(w=1024, h=272, left=30.9, right=1021.4, slant=0.1065, radius=25),
    "tile": dict(w=512, h=303, left=33.2, right=509.6, slant=0.1074, radius=33),
}


def mask(shape, ss=4):
    w, h = shape["w"], shape["h"]
    ys, xs = np.mgrid[0:h * ss, 0:w * ss].astype(np.float32)
    x = (xs + 0.5) / ss
    y = (ys + 0.5) / ss
    u = x + shape["slant"] * y  # unshear: the parallelogram becomes a rectangle
    l, r, rad = shape["left"], shape["right"], shape["radius"]
    cu = np.clip(u, l + rad, r - rad)
    cy = np.clip(y, rad, h - rad)
    inside = (u >= l) & (u <= r) & (y >= 0) & (y <= h) & (((u - cu) ** 2 + (y - cy) ** 2) <= rad * rad)
    a = inside.reshape(h, ss, w, ss).mean(axis=(1, 3))
    return Image.fromarray((a * 255).astype(np.uint8), "L")


def cut(img, box, shape):
    w, h = shape["w"], shape["h"]
    x0, y0, x1, y1 = box
    # widen or trim the box to the shape's aspect around its centre
    bw, bh = x1 - x0, y1 - y0
    target = w / h
    if bw / bh > target:
        nw = bh * target
        x0, x1 = x0 + (bw - nw) / 2, x1 - (bw - nw) / 2
    else:
        nh = bw / target
        y0, y1 = y0 + (bh - nh) / 2, y1 - (bh - nh) / 2
    crop = img.crop((round(x0), round(y0), round(x1), round(y1))).resize((w, h), Image.LANCZOS).convert("RGBA")
    crop.putalpha(mask(shape))
    return crop


os.makedirs(os.path.join(HERE, "out"), exist_ok=True)
sheet = Image.new("RGBA", (1024 + 512 + 30, 3 * 320 + 20), (24, 25, 36, 255))
for i, (name, (file, band, tile)) in enumerate(SHOTS.items()):
    img = Image.open(os.path.join(SHOTS_DIR, file)).convert("RGB")
    card = cut(img, band, SHAPES["card"])
    t = cut(img, tile, SHAPES["tile"])
    card.save(os.path.join(HERE, "out", f"{name}_card.png"))
    t.save(os.path.join(HERE, "out", f"{name}_tile.png"))
    sheet.alpha_composite(card, (10, 10 + i * 320 + 15))
    sheet.alpha_composite(t, (1024 + 20, 10 + i * 320))
sheet.save(os.path.join(HERE, "out", "preview_sheet.png"))
print("ok")
