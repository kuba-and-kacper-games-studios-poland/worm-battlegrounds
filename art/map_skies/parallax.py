"""Parallax backdrop layers for the match maps of Snail Battlegrounds.

A skybox is drawn infinitely far away, so it never moves or grows as the match camera pans and zooms, and shapes
painted in it look stuck to the screen. So the shapes live in the world instead: flat pictures standing far behind
the map at their own depths (far mesas, clouds, near dunes), which the camera's perspective moves on its own. The
skybox keeps only its gradient (skies.py's `<Map>Gradient` themes).

The pictures are rendered in Blender (desert_backdrop.blend, scene DesertBackdrop: stepped brick mesas, dunes, cacti
and voxel clouds in the maps' own brick look, built with blender_voxel_lib.py, its `voxel_lib` text block) into
out/<Map>/parallax/raw/. This script finishes them: depth haze per
layer, the solid ground under each layer sampled from its own bottom edge, the rows for Atmosphere's Settings, and a
preview through the match camera.

Units are studs. X runs along the map (0 = its middle), Y is up from the map's Bounds bottom, and a layer's Depth is
how far behind the play plane it stands.

Run:  python -I parallax.py [Map ...]     (every map by default)
"""

import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import skies  # noqa: E402

OUT = os.path.join(HERE, "out")

# The match camera (MatchCamera's Settings): level along -Z, a 30 deg vertical field of view, from ZOOM_MIN to
# ZOOM_MAX studs in front of the plane
VFOV = 30.0
ZOOM_MIN, ZOOM_MAX = 45.0, 200.0


def C(*v):
    return np.array(v, np.float32)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


# =========================================================================== Desert
class Desert:
    MAP = "Desert"
    SKY = "DesertGradient"      # its gradient-only sky (skies.py)
    GROUND = 12.0               # the lava sea's surface, up from the Bounds bottom: every layer's ground line
    HAZE = C(248, 224, 186)     # the sky's horizon colour (skies.Desert.HAZE)

    # Each rendered layer: its raw tiles, depth, tile centres and width, the picture's v range in the render (studs,
    # 0 = the front ground edge's foot), the render's ground top (v), haze, and how far down its ground fill reaches
    layers = [
        dict(name="far", tiles=4, depth=1100, x0=-1000, x1=1000, v0=-8, v1=140, ground_v=4, haze=0.38,
             foot_haze=0.25, fill_bottom=-345, blur=1.0),
        dict(name="near", tiles=2, depth=350, x0=-525, x1=525, v0=-6, v1=60, ground_v=3, haze=0.1,
             foot_haze=0.08, fill_bottom=-145, blur=0),
    ]
    # Clouds, 700 behind: (raw name, x centre, bottom, cloud width); the picture is 1.12 x as wide, half as tall,
    # and its bottom 4 studs under the cloud's base
    clouds = [("cloud_1", -460, 128, 230), ("cloud_2", 40, 178, 160), ("cloud_3", 500, 140, 210), ("cloud_4", -120, 236, 120)]
    cloud_depth = 700
    cloud_haze = 0.12
    cloud_blur = 0              # in the clouds' own pixels; only the far layer is blurred (the owner: "the blur is too much")


def blur(img, radius):
    """Softens a picture like a camera's depth of field: blurs its colour premultiplied by alpha, so transparent
    edges keep their colour instead of darkening."""
    from PIL import ImageFilter
    if radius <= 0:
        return img
    rgb = img[..., :3].astype(np.float32)
    a = img[..., 3].astype(np.float32) / 255.0
    pre = np.dstack([rgb * a[..., None], a * 255.0])
    out = []
    for k in range(4):
        ch = Image.fromarray(np.clip(pre[..., k], 0, 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(radius))
        out.append(np.asarray(ch).astype(np.float32))
    a2 = out[3] / 255.0
    rgb2 = np.dstack(out[:3]) / np.maximum(a2[..., None], 1e-3)
    # Keep the colour of fully clear pixels near their neighbours (no black fringe when Roblox filters them)
    return np.dstack([np.clip(rgb2, 0, 255), out[3]])


class RollingPlains(Desert):
    MAP = "RollingPlains"
    SKY = "PicnicPlainsGradient"
    GROUND = 4.0                # the sea's surface (Y -4), up from the Bounds bottom (Y -8)
    HAZE = C(222, 238, 246)     # skies.PicnicPlains.HAZE
    SEA = C(123, 180, 233)      # one flat sea behind both layers (their fills), so the water is a single blue
    layers = [
        dict(name="far", tiles=4, depth=1100, x0=-1000, x1=1000, v0=-8, v1=190, ground_v=4, haze=0.3,
             foot_haze=0.08, fill_bottom=-345, blur=1.0, sea_top=24),  # its fill (the sea) reaches over the islands' feet
        dict(name="near", tiles=2, depth=350, x0=-525, x1=525, v0=-6, v1=75, ground_v=3, haze=0.08,
             foot_haze=0.08, fill_bottom=-145, blur=0),
    ]
    clouds = [("cloud_1", -520, 120, 230), ("cloud_2", 120, 170, 160), ("cloud_3", 560, 128, 210), ("cloud_4", -60, 225, 120)]


class EchoCaverns(Desert):
    MAP = "EchoCaverns"
    SKY = "MountainsGradient"
    GROUND = 6.0                # the sea's surface (Y -2), up from the Bounds bottom (Y -8)
    HAZE = C(214, 230, 244)     # skies.Mountains.HAZE
    layers = [
        dict(name="far", tiles=4, depth=1100, x0=-1000, x1=1000, v0=-8, v1=210, ground_v=4, haze=0.4,
             foot_haze=0.25, fill_bottom=-345, blur=1.0),
        dict(name="near", tiles=2, depth=350, x0=-525, x1=525, v0=-6, v1=75, ground_v=3, haze=0.08,
             foot_haze=0.08, fill_bottom=-145, blur=0),
    ]
    clouds = [("cloud_1", -430, 150, 230), ("cloud_2", 260, 200, 160), ("cloud_3", 600, 140, 210), ("cloud_4", -720, 230, 120)]


class Lobby(RollingPlains):
    """The lobby's scene, drawn only on the loading card (the lobby itself is a 3D stage): a meadow under snowy brick
    peaks, the lobby sky's own picture in the maps' brick look, over Picnic Plains' gradient sky with Rolling Plains'
    clouds (their rows are reused, not uploaded again)."""
    MAP = "Lobby"
    SEA = None
    layers = [
        dict(name="far", tiles=4, depth=1100, x0=-1000, x1=1000, v0=-8, v1=210, ground_v=4, haze=0.36,
             foot_haze=0.2, fill_bottom=-345, blur=1.0, fill=(144, 189, 168)),  # the hazed foothills' grass
        dict(name="near", tiles=2, depth=350, x0=-525, x1=525, v0=-6, v1=75, ground_v=3, haze=0.06,
             foot_haze=0.06, fill_bottom=-145, blur=0, fill=(92, 156, 113)),  # the meadow's grass
    ]


THEMES = {"Desert": Desert, "RollingPlains": RollingPlains, "EchoCaverns": EchoCaverns, "Lobby": Lobby}


def haze(img, amount, foot, v0, v1, ground_v, colour):
    """Mixes a layer toward the horizon's haze, more toward its foot."""
    rgb = img[..., :3].astype(np.float32)
    h = img.shape[0]
    v = v1 - (np.arange(h) + 0.5) / h * (v1 - v0)          # each row's height in the render
    k = amount + foot * smoothstep(ground_v + 40, ground_v, v)
    rgb = rgb + (colour - rgb) * k[:, None, None]
    return np.dstack([rgb, img[..., 3:4].astype(np.float32)])


def build(theme):
    raw = os.path.join(OUT, theme.MAP, "parallax", "raw")
    folder = os.path.join(OUT, theme.MAP, "parallax")
    rows, sprites = [], []
    for layer in theme.layers:
        tile_w = (layer["x1"] - layer["x0"]) / layer["tiles"]
        height = layer["v1"] - layer["v0"]
        bottom = theme.GROUND - (layer["ground_v"] - layer["v0"])
        foot_rows = []
        for t in range(layer["tiles"]):
            img = np.asarray(Image.open(os.path.join(raw, f"{layer['name']}_{t + 1}.png")).convert("RGBA"))
            out = haze(img, layer["haze"], layer["foot_haze"], layer["v0"], layer["v1"], layer["ground_v"], theme.HAZE)
            out = blur(out, layer["blur"])
            name = f"{layer['name']}_{t + 1}.png"
            Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA").save(os.path.join(folder, name), optimize=True)
            cx = layer["x0"] + tile_w * (t + 0.5)
            rows.append(dict(Image=name, Depth=layer["depth"], X=cx, Bottom=bottom, Width=tile_w, Height=height))
            sprites.append((layer["depth"], cx - tile_w / 2, cx + tile_w / 2, bottom, bottom + height,
                            out[..., :3], out[..., 3] / 255.0))
            # The ground fill takes the colour of the picture's opaque bottom edge
            h = out.shape[0]
            opaque = out[..., 3] > 250
            rows_with = np.nonzero(opaque.any(axis=1))[0]
            foot = out[rows_with[-3]:rows_with[-1] + 1][opaque[rows_with[-3]:rows_with[-1] + 1]][:, :3]
            foot_rows.append(foot.mean(axis=0))
        # A layer's own fill colour, else the theme's sea, else its bottom edge's
        fill = C(*layer["fill"]) if "fill" in layer else getattr(theme, "SEA", None)
        if fill is None:
            fill = np.mean(foot_rows, axis=0)
        # 1 stud over the front ground edge's foot, or up to sea_top (render v) where islands stand in a flat sea
        fill_top = bottom + (layer.get("sea_top", 1) - layer["v0"])
        rows.append(dict(Color=[int(round(c)) for c in fill], Depth=layer["depth"] + 0.5, X=(layer["x0"] + layer["x1"]) / 2,
                         Bottom=layer["fill_bottom"], Width=layer["x1"] - layer["x0"], Height=fill_top - layer["fill_bottom"]))
        sprites.append((layer["depth"] + 0.5, layer["x0"], layer["x1"], layer["fill_bottom"], fill_top, fill, None))
    for raw_name, cx, base, width in theme.clouds:
        img = np.asarray(Image.open(os.path.join(raw, raw_name + ".png")).convert("RGBA")).astype(np.float32)
        # Every cloud front faces the camera and gets the same light: shade it from a lit top to a cool belly
        rows_with = np.nonzero((img[..., 3] > 0).any(axis=1))[0]
        top, bot = rows_with[0], rows_with[-1]
        t = np.clip((np.arange(img.shape[0]) - top) / max(bot - top, 1), 0, 1)
        shade = 1.0 + (C(0.92, 0.94, 0.98) - 1.0) * (t ** 1.4)[:, None]
        img[..., :3] *= shade[:, None, :]
        img[..., :3] += (theme.HAZE - img[..., :3]) * theme.cloud_haze
        img = blur(img, theme.cloud_blur)
        name = raw_name + ".png"
        Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGBA").save(os.path.join(folder, name), optimize=True)
        pw, ph = width * 1.12, width * 0.56
        bottom = base - 4
        rows.append(dict(Image=name, Depth=theme.cloud_depth, X=cx, Bottom=bottom, Width=round(pw, 1), Height=round(ph, 1)))
        sprites.append((theme.cloud_depth, cx - pw / 2, cx + pw / 2, bottom, bottom + ph, img[..., :3], img[..., 3] / 255.0))
    with open(os.path.join(folder, "rows.json"), "w") as f:
        json.dump(rows, f, indent=1)
    return rows, sprites


# ============================================================================ preview
def sample(sprite, X, Y):
    d, x0, x1, y0, y1, col, alpha = sprite
    inside = (X >= x0) & (X < x1) & (Y >= y0) & (Y < y1)
    out_c = np.zeros(X.shape + (3,), np.float32)
    out_a = np.zeros(X.shape, np.float32)
    if not inside.any():
        return out_c, out_a
    if alpha is None:
        out_c[inside] = col
        out_a[inside] = 1
        return out_c, out_a
    h, w = alpha.shape
    u = ((X[inside] - x0) / (x1 - x0) * w).astype(int).clip(0, w - 1)
    v = ((y1 - Y[inside]) / (y1 - y0) * h).astype(int).clip(0, h - 1)
    out_c[inside] = col[v, u]
    out_a[inside] = alpha[v, u]
    return out_c, out_a


def frame(sky, sprites, map_img, cam_x, cam_y, zoom, w=960, h=540):
    th = np.tan(np.radians(VFOV) / 2)
    tw = th * w / h
    xs = ((np.arange(w) + 0.5) / w * 2 - 1) * tw
    ys = (1 - (np.arange(h) + 0.5) / h * 2) * th
    DX, DY = np.meshgrid(xs, ys)
    dirs = np.dstack([DX, DY, -np.ones_like(DX)])
    dirs /= np.linalg.norm(dirs, axis=-1, keepdims=True)
    col = sky(dirs)
    for sp in sorted(sprites, key=lambda s: -s[0]):
        X = cam_x + DX * (zoom + sp[0])
        Y = cam_y + DY * (zoom + sp[0])
        c, a = sample(sp, X, Y)
        col = col * (1 - a[..., None]) + c * a[..., None]
    if map_img is not None:
        c, a = sample(map_img, cam_x + DX * zoom, cam_y + DY * zoom)
        col = col * (1 - a[..., None]) + c * a[..., None]
    return Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), "RGB")


def preview(theme, sprites, map_img=None):
    gradient = skies.THEMES[theme.SKY]
    sky = gradient[0](gradient[1])
    folder = os.path.join(OUT, theme.MAP, "parallax")
    path = []
    for t in np.linspace(0, 1, 16):
        path.append((0, 50, ZOOM_MIN + (ZOOM_MAX - ZOOM_MIN) * (0.5 - 0.5 * np.cos(np.pi * t))))
    for t in np.linspace(0, 1, 16):
        path.append((-90 * np.sin(2 * np.pi * t), 50 + 10 * np.sin(np.pi * t), ZOOM_MAX))
    for t in np.linspace(0, 1, 16):
        path.append((0, 50 - 25 * np.sin(np.pi * t), ZOOM_MAX + (ZOOM_MIN - ZOOM_MAX) * (0.5 - 0.5 * np.cos(np.pi * t))))
    frames = [frame(sky, sprites, map_img, cx, cy, z, 640, 360) for cx, cy, z in path]
    frames[0].save(os.path.join(folder, "preview.gif"), save_all=True, append_images=frames[1:], duration=90, loop=0)
    stills = [frame(sky, sprites, map_img, 0, 40, ZOOM_MIN), frame(sky, sprites, map_img, 0, 50, 110),
              frame(sky, sprites, map_img, 0, 50, ZOOM_MAX)]
    sheet = Image.new("RGB", (960, 540 * 3 + 20), (24, 26, 32))
    d = ImageDraw.Draw(sheet)
    for i, im in enumerate(stills):
        sheet.paste(im, (0, i * 550))
        d.text((12, i * 550 + 8), ["zoomed in (45)", "start (110)", "zoomed out (200)"][i], fill=(20, 20, 20))
    sheet.save(os.path.join(folder, "preview_stills.png"))


def main():
    names = sys.argv[1:] or list(THEMES)
    for name in names:
        theme = THEMES[name]()
        rows, sprites = build(theme)
        preview(theme, sprites)
        print(name, len(rows), "rows")


if __name__ == "__main__":
    main()
