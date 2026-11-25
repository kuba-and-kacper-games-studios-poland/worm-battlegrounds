"""Procedural cartoon lobby sky for Snail Battlegrounds.

The sky is one function of view direction, sky(dirs) -> rgb. Every face pixel is
turned into its 3D direction with Roblox's face orientations, so the six faces
meet at their edges by construction.

Run:  python -I sky.py          (writes out/sky_*.png and the two previews)
      python -I sky.py --size 512   (faster draft)
"""

import argparse
import os

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")

# ---------------------------------------------------------------- face frames
# World: +Y up. Roblox's Sky unfolds (every image upright as uploaded) as
#
#             Up
#     Lf  Bk  Rt  Ft
#             Dn
#
# Seen from inside, walking right along the strip turns you to the right, so
# facing Ft, Lf is on your right and Rt on your left. Up's bottom edge meets
# Rt's top edge, Dn's top edge meets Rt's bottom edge.
# Each face: (centre, image-right, image-up), all as directions seen from inside.
FACES = {
    "ft": ((0, 0, -1), (1, 0, 0), (0, 1, 0)),
    "lf": ((1, 0, 0), (0, 0, 1), (0, 1, 0)),
    "bk": ((0, 0, 1), (-1, 0, 0), (0, 1, 0)),
    "rt": ((-1, 0, 0), (0, 0, -1), (0, 1, 0)),
    "up": ((0, 1, 0), (0, 0, -1), (1, 0, 0)),
    "dn": ((0, -1, 0), (0, 0, -1), (-1, 0, 0)),
}

# --------------------------------------------------------------- palette (sRGB)
ZENITH = np.array([78, 150, 220], np.float32)
MID = np.array([120, 185, 235], np.float32)
HAZE = np.array([215, 232, 245], np.float32)
MIST = np.array([206, 224, 234], np.float32)       # just under the hills
FLOOR = np.array([200, 219, 236], np.float32)      # below-horizon / Dn
MOUNT = np.array([170, 190, 210], np.float32)
MOUNT_SHADE = np.array([150, 172, 198], np.float32)
SNOW = np.array([243, 248, 253], np.float32)
SNOW_SHADE = np.array([206, 220, 238], np.float32)
HILL = np.array([120, 165, 130], np.float32)
CLOUD = np.array([252, 253, 255], np.float32)
CLOUD_SHADE = np.array([206, 219, 236], np.float32)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def mix(a, b, t):
    t = np.asarray(t, np.float32)[..., None]
    return a + (b - a) * t


def wrap(d):
    """Wrap an angle difference in degrees to [-180, 180)."""
    return (d + 180.0) % 360.0 - 180.0


# -------------------------------------------------------------------- noise
class Noise3:
    """Small value-noise fBm on 3D points (seamless on the sphere)."""

    def __init__(self, seed):
        rng = np.random.default_rng(seed)
        self.perm = rng.permutation(256).astype(np.int64)
        self.perm = np.concatenate([self.perm, self.perm])
        self.val = rng.random(256).astype(np.float32)

    def _hash(self, x, y, z):
        p = self.perm
        return self.val[p[p[p[x & 255] + (y & 255)] + (z & 255)]]

    def value(self, pts):
        f = np.floor(pts)
        i = f.astype(np.int64)
        t = pts - f
        t = t * t * (3 - 2 * t)
        x0, y0, z0 = i[..., 0], i[..., 1], i[..., 2]
        tx, ty, tz = t[..., 0], t[..., 1], t[..., 2]
        out = 0.0
        for dx in (0, 1):
            wx = tx if dx else 1 - tx
            for dy in (0, 1):
                wy = ty if dy else 1 - ty
                for dz in (0, 1):
                    wz = tz if dz else 1 - tz
                    out = out + wx * wy * wz * self._hash(x0 + dx, y0 + dy, z0 + dz)
        return out

    def fbm(self, pts, octaves=4):
        total, amp, norm = 0.0, 1.0, 0.0
        for o in range(octaves):
            total = total + amp * self.value(pts * (2.0 ** o) + 17.3 * o)
            norm += amp
            amp *= 0.5
        return total / norm


def periodic_noise(rng, az_deg, kmin, kmax, falloff):
    """Sum of integer-frequency sines in azimuth: wraps exactly at 360."""
    a = np.radians(az_deg)
    out = np.zeros_like(a)
    for k in range(kmin, kmax + 1):
        out += (k ** -falloff) * np.sin(k * a + rng.uniform(0, 2 * np.pi))
    return out / np.abs(out).max()


# ------------------------------------------------------ horizon profile tables
TABLE_N = 8192
TABLE_AZ = np.arange(TABLE_N) * (360.0 / TABLE_N)


def lookup(table, az):
    """Linear, periodic lookup of a 1D azimuth table."""
    x = (az % 360.0) * (TABLE_N / 360.0)
    i0 = np.floor(x).astype(np.int64) % TABLE_N
    i1 = (i0 + 1) % TABLE_N
    t = x - np.floor(x)
    return table[i0] * (1 - t) + table[i1] * t


def build_range(rng, peaks, rough):
    """peaks: list of (azimuth, height deg, half-width deg).

    Each peak keeps its own height table; they are painted tallest first
    (farthest), so where two overlap the front one's flank is the edge.
    """
    peaks = sorted(peaks, key=lambda p: -p[1])
    jag = periodic_noise(rng, TABLE_AZ, 20, 160, 0.9) * rough
    heights = np.full((len(peaks), TABLE_N), -10.0)
    for j, (c, h, w) in enumerate(peaks):
        d = wrap(TABLE_AZ - c)
        soft = np.sqrt(d * d + (0.10 * w) ** 2) - 0.10 * w   # rounded tip
        prof = h * np.clip(1 - soft / w, 0, None) ** 1.35
        prof = prof + jag * smoothstep(0, 2, prof)
        heights[j] = np.where(np.abs(d) < w, prof, -10.0)
    snow_jag = periodic_noise(rng, TABLE_AZ, 40, 220, 0.7)
    return {"top": heights.max(0), "heights": heights, "snow_jag": snow_jag, "peaks": peaks}


def build_world(seed=7):
    rng = np.random.default_rng(seed)
    # Far snowy range: three clusters spread round the horizon, gaps between.
    far = [
        (-38, 9.5, 13), (-24, 6.5, 10), (-52, 6.0, 11), (-12, 4.2, 9),
        (62, 7.8, 12), (78, 10.5, 14), (95, 6.2, 10), (110, 4.0, 9),
        (168, 8.6, 13), (186, 6.0, 10), (152, 5.0, 10),
        (240, 7.0, 12), (258, 5.0, 10), (300, 4.5, 11), (316, 6.8, 11),
    ]
    near = [
        (-62, 3.6, 13), (-5, 3.0, 12), (40, 3.4, 14), (128, 3.2, 13),
        (205, 3.8, 14), (225, 2.8, 10), (282, 3.4, 13), (340, 3.0, 12),
    ]
    world = {
        "far": build_range(rng, far, 0.22),
        "near": build_range(rng, near, 0.12),
        "hill_far": 2.3 + 1.0 * periodic_noise(rng, TABLE_AZ, 3, 18, 1.1),
        "hill_near": 1.1 + 0.75 * periodic_noise(rng, TABLE_AZ, 5, 26, 1.0),
        "noise": Noise3(seed),
    }
    # Clouds: (azimuth, base elevation, length deg, puff size deg)
    cloud_specs = [
        (-32, 7.0, 19, 2.6), (24, 12.5, 11, 1.9), (76, 5.5, 22, 2.9),
        (140, 10.0, 15, 2.2), (197, 6.5, 18, 2.5), (262, 13.0, 11, 1.8),
        (322, 8.5, 16, 2.3),
    ]
    clouds = []
    for az, base, length, size in cloud_specs:
        blobs = []
        # Bottom row of small puffs sitting on the flat base...
        n = max(3, int(length / (size * 0.9)))
        for x in np.linspace(-0.5, 0.5, n) * length:
            r = size * rng.uniform(0.45, 0.65)
            blobs.append((x + rng.uniform(-0.2, 0.2) * size, base + r * 0.55, r))
        # ...then bigger puffs piled on top, tallest near the middle.
        m = max(2, int(length / (size * 1.6)))
        for x in np.linspace(-0.38, 0.38, m) * length:
            bulge = 1 - (x / (0.5 * length)) ** 2
            r = size * (0.55 + 0.55 * bulge) * rng.uniform(0.85, 1.1)
            blobs.append((x + rng.uniform(-0.25, 0.25) * size,
                          base + size * (0.45 + 0.55 * bulge) + r * 0.2, r))
        clouds.append({"az": az, "base": base, "blobs": np.array(blobs, np.float32),
                       "extent": length * 0.5 + size * 2.5, "size": size})
    world["clouds"] = clouds
    return world


# -------------------------------------------------------------------- the sky
def sky_gradient(el):
    lo = smoothstep(0.0, 30.0, el) ** 0.75
    hi = smoothstep(18.0, 88.0, el)
    col = mix(HAZE, MID, lo)
    col = mix(col, ZENITH, hi)
    return col


def cloud_field(cl, x, y):
    """Smooth union of round puffs, in units of the cloud's puff size.

    > 0 inside. Returns (field, light) where light > 0 on the side of each
    puff that faces the light (upper left), so every puff gets its own
    cartoon shading.
    """
    k = 10.0
    size = cl["size"]
    acc = np.zeros_like(x)
    light = np.zeros_like(x)
    L = np.array([-0.55, 0.83], np.float32)
    for bx, by, br in cl["blobs"]:
        dx, dy = x - bx, y - by
        d = np.sqrt(dx * dx + dy * dy) + 1e-4
        g = (br - d) / size
        w = np.exp(k * np.clip(g, -3, 3))
        acc += w
        light += w * ((dx * L[0] + dy * L[1]) / br)   # -1 (away) .. 1 (toward)
    f = np.log(acc + 1e-12) / k
    light = light / (acc + 1e-12)
    # Flat bottom.
    f = np.minimum(f, (y - cl["base"]) / size * 0.8)
    return f, light


def draw_clouds(world, col, az, el):
    for cl in world["clouds"]:
        dx = wrap(az - cl["az"]) * np.cos(np.radians(el))
        sel = (np.abs(dx) < cl["extent"]) & (el > cl["base"] - 1) & (el < cl["base"] + 4 * cl["size"] + 1)
        if not sel.any():
            continue
        x, y = dx[sel], el[sel]
        f, light = cloud_field(cl, x, y)
        alpha = smoothstep(-0.035, 0.045, f)
        lit = smoothstep(-0.45, 0.25, light)
        height = (y - cl["base"]) / cl["size"]
        under = smoothstep(0.75, 0.05, height)               # blue-grey belly
        tone = np.clip(0.40 + 0.60 * lit - 0.40 * under, 0, 1)
        c = mix(CLOUD_SHADE, CLOUD, tone)
        # A soft bright rim just inside the top edges.
        c = mix(c, CLOUD, 0.5 * smoothstep(0.12, 0.0, f) * smoothstep(0.0, 0.5, light))
        # Distance haze: low clouds melt into the horizon a little.
        c = mix(c, HAZE, 0.25 * smoothstep(13, 3, y))
        a = alpha * 0.95
        col[sel] = col[sel] * (1 - a[:, None]) + c * a[:, None]
    return col


def draw_range(rng_tab, col, az, el, base_col, shade_col, haze_amt, snow=True):
    top = lookup(rng_tab["top"], az)
    inside = smoothstep(top + 0.07, top - 0.07, el)
    sel = inside > 0
    if not sel.any():
        return col
    a, e = az[sel], el[sel]
    jag = lookup(rng_tab["snow_jag"], a)
    c = np.repeat(shade_col[None], len(a), 0)
    n = len(rng_tab["peaks"])
    for j, (pc, ph, pw) in enumerate(rng_tab["peaks"]):
        h = lookup(rng_tab["heights"][j], a)
        cov = smoothstep(h + 0.07, h - 0.07, e)
        on = cov > 0
        if not on.any():
            continue
        d, ee = wrap(a[on] - pc), e[on]
        # Ridge: lit on the left of each peak, the ridge drifts as it runs down.
        ridge = 0.18 * (ph - ee) * np.sin(0.9 * ee + pc)
        lit = smoothstep(0.35, -0.35, d - ridge)
        cj = mix(shade_col, base_col, 0.25 + 0.75 * lit)
        if snow:
            # Snow line: ragged, highest on the flanks, running down the ridge.
            line = ph * 0.60 + 0.40 * jag[on] + 0.12 * np.abs(d) / pw * ph
            line = line - 0.10 * ph * np.clip(1 - np.abs(d - ridge) / 0.7, 0, 1)
            s_ = smoothstep(line - 0.12, line + 0.12, ee) * smoothstep(4.5, 6.0, ph)
            cj = mix(cj, mix(SNOW_SHADE, SNOW, lit), s_)
        # Farther (taller, painted earlier) peaks a touch paler.
        cj = mix(cj, HAZE, 0.12 * (1 - j / max(n - 1, 1)))
        m = cov[on][:, None]
        c[on] = c[on] * (1 - m) + cj * m
    # Atmosphere: whole range hazed, base melts into the mist.
    c = mix(c, HAZE, haze_amt + (1 - haze_amt) * 0.65 * smoothstep(3.0, -0.5, e))
    m = inside[sel][:, None]
    col[sel] = col[sel] * (1 - m) + c * m
    return col


def draw_hills(table, col, az, el, tint, haze_amt):
    top = lookup(table, az)
    inside = smoothstep(top + 0.06, top - 0.06, el)
    sel = inside > 0
    a, e, t = az[sel], el[sel], top[sel]
    depth = t - e                                   # degrees below the hill line
    c = mix(tint, tint * 1.06, smoothstep(0.35, 0.0, depth))   # soft lit crest
    c = mix(c, HAZE, haze_amt + (1 - haze_amt) * 0.55 * smoothstep(t - 0.2, -1.2, e))
    m = inside[sel][:, None]
    col[sel] = col[sel] * (1 - m) + c * m
    return col


def sky(world, dirs):
    """dirs: (..., 3) unit vectors -> (..., 3) float sRGB 0..255."""
    shape = dirs.shape[:-1]
    d = dirs.reshape(-1, 3).astype(np.float32)
    x, y, z = d[:, 0], d[:, 1], d[:, 2]
    el = np.degrees(np.arcsin(np.clip(y, -1, 1)))
    az = np.degrees(np.arctan2(x, -z))              # 0 = Ft centre, +90 = Lf
    nz = world["noise"]

    col = sky_gradient(el)
    # Painterly unevenness, very faint.
    n = nz.fbm(d * 2.2, 3)
    col = col * (1 + (n[:, None] - 0.5) * 0.035)
    # Faint high wisps (the only thing on Up besides the gradient).
    w = nz.fbm(d * np.array([2.6, 1.2, 2.6], np.float32) + 3.1, 3)
    wisp = smoothstep(0.60, 0.80, w) * smoothstep(24, 45, el) * 0.10
    col = mix(col, CLOUD, wisp)

    col = draw_clouds(world, col, az, el)
    col = draw_range(world["far"], col, az, el, MOUNT, MOUNT_SHADE, 0.22)
    near_col = mix(MOUNT, HILL, 0.35)
    col = draw_range(world["near"], col, az, el, near_col, near_col * 0.92, 0.30, snow=False)
    col = draw_hills(world["hill_far"], col, az, el, mix(HILL, MOUNT, 0.3), 0.45)
    col = draw_hills(world["hill_near"], col, az, el, HILL, 0.22)

    # Below the horizon: the hills sink into a pale mist, then the calm floor colour (Dn).
    col = mix(col, MIST, smoothstep(-0.3, -3.5, el))
    col = mix(col, FLOOR, smoothstep(-3.0, -20.0, el))
    return col.reshape(*shape, 3)


# ------------------------------------------------------------------ rendering
def face_dirs(name, size):
    c, r, u = (np.array(v, np.float32) for v in FACES[name])
    s = (np.arange(size, dtype=np.float32) + 0.5) / size * 2 - 1
    a = s[None, :, None]            # left -> right
    b = -s[:, None, None]           # top -> bottom
    d = c + a * r + b * u
    return d / np.linalg.norm(d, axis=-1, keepdims=True)


def to_image(col, seed):
    rng = np.random.default_rng(seed)
    dither = rng.random(col.shape[:2], np.float32) - rng.random(col.shape[:2], np.float32)
    out = np.clip(np.round(col + dither[..., None]), 0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGB")


def check_seams(raw):
    """For each of the 12 cube edges, folded as Roblox's cross folds them,
    compare the colour step across the edge with the step one pixel inside
    the faces. A wrong fold shows up as a seam step far above the inner one."""
    f = raw
    # Each edge as (outermost line, the line next to it), in a given direction.
    E = {
        "L": lambda a: (a[:, 0], a[:, 1]), "R": lambda a: (a[:, -1], a[:, -2]),
        "T": lambda a: (a[0], a[1]), "B": lambda a: (a[-1], a[-2]),
    }
    pairs = [  # (face, edge, face, edge, reversed)
        ("lf", "R", "bk", "L", False), ("bk", "R", "rt", "L", False),
        ("rt", "R", "ft", "L", False), ("ft", "R", "lf", "L", False),
        ("up", "B", "rt", "T", False), ("up", "L", "bk", "T", False),
        ("up", "R", "ft", "T", True), ("up", "T", "lf", "T", True),
        ("dn", "T", "rt", "B", False), ("dn", "L", "bk", "B", True),
        ("dn", "R", "ft", "B", False), ("dn", "B", "lf", "B", True),
    ]
    worst = 0.0
    for fa, ea, fb, eb, rev in pairs:
        a0, a1 = E[ea](f[fa])
        b0, b1 = E[eb](f[fb])
        if rev:
            b0, b1 = b0[::-1], b1[::-1]
        across = np.abs(a0 - b0).mean()
        inside = 0.5 * (np.abs(a0 - a1).mean() + np.abs(b0 - b1).mean())
        ratio = across / max(inside, 1e-3)
        worst = max(worst, ratio)
        print(f"  {fa}.{ea} | {fb}.{eb}: step across {across:.3f}, inside {inside:.3f}")
    print(f"seams: worst across/inside ratio {worst:.2f} (about 1 means seamless)")
    return worst


def preview_cross(imgs, cell=256):
    W, H = cell * 4, cell * 3
    sheet = Image.new("RGB", (W, H), (40, 44, 52))
    spots = {"lf": (0, 1), "bk": (1, 1), "rt": (2, 1), "ft": (3, 1), "up": (2, 0), "dn": (2, 2)}
    draw = ImageDraw.Draw(sheet)
    for k, (cx, cy) in spots.items():
        sheet.paste(imgs[k].resize((cell, cell), Image.LANCZOS), (cx * cell, cy * cell))
        draw.text((cx * cell + 6, cy * cell + 4), "Skybox" + k.capitalize(), fill=(40, 60, 90))
    return sheet


def preview_view(world, w=1600, h=900, pitch_down=5.0, vfov=50.0, yaw=0.0):
    # yaw 0 looks at the Ft face centre, 180 at Bk; pitched down.
    p, yw = np.radians(-pitch_down), np.radians(yaw)
    fwd = np.array([np.sin(yw) * np.cos(p), np.sin(p), -np.cos(yw) * np.cos(p)], np.float32)
    right = np.cross(fwd, [0, 1, 0]).astype(np.float32)
    right /= np.linalg.norm(right)
    up = np.cross(right, fwd)
    th = np.tan(np.radians(vfov) / 2)
    tw = th * w / h
    xs = ((np.arange(w) + 0.5) / w * 2 - 1) * tw
    ys = (1 - (np.arange(h) + 0.5) / h * 2) * th
    d = fwd + xs[None, :, None] * right + ys[:, None, None] * up
    d /= np.linalg.norm(d, axis=-1, keepdims=True)
    return to_image(sky(world, d), 99)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--size", type=int, default=1024)
    ap.add_argument("--yaw", type=float, default=180.0,
                    help="preview camera yaw in degrees (0 = Ft / -Z, 90 = Lf / +X, 180 = Bk / +Z, the lobby camera)")
    args = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)
    world = build_world()
    raw, imgs = {}, {}
    for i, name in enumerate(FACES):
        raw[name] = sky(world, face_dirs(name, args.size))
        imgs[name] = to_image(raw[name], i)
        imgs[name].save(os.path.join(OUT, f"sky_{name}.png"), optimize=True)
        print("wrote", f"sky_{name}.png")
    check_seams(raw)
    preview_cross(imgs).save(os.path.join(OUT, "preview_cross.png"))
    preview_view(world, yaw=args.yaw).save(os.path.join(OUT, "preview_view.png"))
    print("wrote previews")


if __name__ == "__main__":
    main()
