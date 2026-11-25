"""Procedural cartoon skies for the match maps of Snail Battlegrounds.

Each sky is one function of view direction, sky(dirs) -> rgb, like the lobby sky
(art/lobby_sky/sky.py), so the six faces meet at their edges by construction.

The match camera always looks along -Z at pitch 0 (MatchCamera), so players see
one fixed window of the sky: the SkyboxFt side, about +-54 deg left and right and
+-35 deg up and down. Each theme is composed for that window; the rest of the
sphere is kept calm and continuous.

Run:  python -I skies.py                       every map, previews only (fast)
      python -I skies.py --maps Desert --faces  also write the six 1024 faces
      python -I skies.py --size 512 --faces     smaller faces
"""

import argparse
import os

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")

# Roblox's Sky unfolded:      Up
#                     Lf  Bk  Rt  Ft
#                             Dn
# Each face: (centre, image-right, image-up) as directions seen from inside.
FACES = {
    "ft": ((0, 0, -1), (1, 0, 0), (0, 1, 0)),
    "lf": ((1, 0, 0), (0, 0, 1), (0, 1, 0)),
    "bk": ((0, 0, 1), (-1, 0, 0), (0, 1, 0)),
    "rt": ((-1, 0, 0), (0, 0, -1), (0, 1, 0)),
    "up": ((0, 1, 0), (0, 0, -1), (1, 0, 0)),
    "dn": ((0, -1, 0), (0, 0, -1), (-1, 0, 0)),
}


def C(*v):
    return np.array(v, np.float32)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def mix(a, b, t):
    t = np.asarray(t, np.float32)
    if t.ndim:
        t = t[..., None]
    return a + (b - a) * t


def wrap(d):
    return (d + 180.0) % 360.0 - 180.0


# -------------------------------------------------------------------- noise
class Noise3:
    """Value-noise fBm on 3D points (seamless on the sphere)."""

    def __init__(self, seed):
        rng = np.random.default_rng(seed)
        p = rng.permutation(256).astype(np.int64)
        self.perm = np.concatenate([p, p])
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


TABLE_N = 8192
TABLE_AZ = np.arange(TABLE_N) * (360.0 / TABLE_N)


def lookup(table, az):
    x = (az % 360.0) * (TABLE_N / 360.0)
    i0 = np.floor(x).astype(np.int64) % TABLE_N
    i1 = (i0 + 1) % TABLE_N
    t = x - np.floor(x)
    return table[i0] * (1 - t) + table[i1] * t


# ------------------------------------------------------------ horizon shapes
def profile_table(peaks, kind, jag=None, rough=0.0):
    """Height table (deg) of a row of shapes round the horizon.

    peaks: (azimuth, height, half-width). kind: 'peak' (pointed mountain),
    'mesa' (flat top, steep sides), 'cone' (volcano, cut-off top), 'hill'.
    """
    top = np.full(TABLE_N, -10.0, np.float32)
    for c, h, w in peaks:
        d = np.abs(wrap(TABLE_AZ - c))
        u = np.clip(d / w, 0, None)
        if kind == "peak":
            soft = np.sqrt(d * d + (0.10 * w) ** 2) - 0.10 * w
            prof = h * np.clip(1 - soft / w, 0, None) ** 1.35
        elif kind == "mesa":
            # Flat plateau out to 0.62 w, a steep cliff, then a scree skirt.
            cliff = smoothstep(0.70, 0.62, u)
            skirt = 0.32 * np.clip(1 - (u - 0.62) / 0.38, 0, 1) ** 1.6
            prof = h * np.maximum(cliff, skirt)
        elif kind == "cone":
            prof = h * np.clip(1 - u, 0, None) ** 1.25
            rim = h * 0.84
            prof = np.where(prof > rim, rim + (prof - rim) * 0.15, prof)  # cut-off crater top
        else:  # hill
            prof = h * np.cos(np.clip(u, 0, 1) * np.pi / 2) ** 2
        prof = np.where(u < 1, prof, -10.0)
        top = np.maximum(top, prof)
    smooth = top.copy()
    if jag is not None:
        top = top + jag * rough * smoothstep(0, 1.5, top)
    return {"top": top, "smooth": smooth}


def draw_band(col, az, el, table, base, haze, haze_amt, crest=None, crest_w=0.35,
              shade=None, sun_side=-1.0):
    """Paint one silhouette band (everything under its profile).

    base: its colour, haze: what it fades into near its foot. crest: a lighter
    rim colour along its top edge. shade: a darker colour for the shadow side of
    each slope (picked by the profile's slope)."""
    if isinstance(table, dict):
        tab, smooth = table["top"], table["smooth"]
    else:
        tab = smooth = table
    top = lookup(tab, az)
    inside = smoothstep(top + 0.06, top - 0.06, el)
    sel = inside > 0
    if not sel.any():
        return col
    a, e, t = az[sel], el[sel], top[sel]
    c = np.repeat(base[None], len(a), 0)
    if shade is not None:
        # The ridge between the lit and shadow sides wanders as it runs down.
        depth = np.clip(t - e, 0, None)
        wob = depth * (0.35 * np.sin(1.7 * e + 0.11 * a) + 0.18 * np.sin(4.3 * e - 0.07 * a))
        aa = a + wob
        slope = lookup(smooth, aa + 0.4) - lookup(smooth, aa - 0.4)
        side = smoothstep(-0.03, 0.03, slope * sun_side)
        c = mix(c, shade, 0.85 * side)
    if crest is not None:
        c = mix(c, crest, smoothstep(crest_w, 0.0, t - e) * 0.8)
    c = mix(c, haze, haze_amt + (1 - haze_amt) * 0.6 * smoothstep(t * 0.55, -0.8, e))
    m = inside[sel][:, None]
    col[sel] = col[sel] * (1 - m) + c * m
    return col


# -------------------------------------------------------------------- clouds
def make_puffy(rng, specs):
    """specs: (azimuth, base elevation, length deg, puff size deg)."""
    clouds = []
    for az, base, length, size in specs:
        blobs = []
        n = max(3, int(length / (size * 0.9)))
        for x in np.linspace(-0.5, 0.5, n) * length:
            r = size * rng.uniform(0.45, 0.65)
            blobs.append((x + rng.uniform(-0.2, 0.2) * size, base + r * 0.55, r))
        m = max(2, int(length / (size * 1.6)))
        for x in np.linspace(-0.38, 0.38, m) * length:
            bulge = 1 - (x / (0.5 * length)) ** 2
            r = size * (0.55 + 0.55 * bulge) * rng.uniform(0.85, 1.1)
            blobs.append((x + rng.uniform(-0.25, 0.25) * size,
                          base + size * (0.45 + 0.55 * bulge) + r * 0.2, r))
        clouds.append({"az": az, "base": base, "blobs": np.array(blobs, np.float32),
                       "extent": length * 0.5 + size * 2.5, "size": size})
    return clouds


def cloud_field(cl, x, y, light_dir):
    k = 10.0
    size = cl["size"]
    acc = np.zeros_like(x)
    light = np.zeros_like(x)
    L = np.array(light_dir, np.float32)
    L = L / np.linalg.norm(L)
    for bx, by, br in cl["blobs"]:
        dx, dy = x - bx, y - by
        d = np.sqrt(dx * dx + dy * dy) + 1e-4
        g = (br - d) / size
        w = np.exp(k * np.clip(g, -3, 3))
        acc += w
        light += w * ((dx * L[0] + dy * L[1]) / br)
    f = np.log(acc + 1e-12) / k
    light = light / (acc + 1e-12)
    f = np.minimum(f, (y - cl["base"]) / size * 0.8)
    return f, light


def draw_puffy(col, az, el, clouds, p):
    """p: dict with lit, shade, belly, rim, haze, opacity, light, belly_glow."""
    for cl in clouds:
        dx = wrap(az - cl["az"]) * np.cos(np.radians(el))
        sel = (np.abs(dx) < cl["extent"]) & (el > cl["base"] - 1) & (el < cl["base"] + 4 * cl["size"] + 1)
        if not sel.any():
            continue
        x, y = dx[sel], el[sel]
        f, light = cloud_field(cl, x, y, p.get("light", (-0.55, 0.83)))
        alpha = smoothstep(-0.035, 0.045, f)
        lit = smoothstep(-0.45, 0.25, light)
        height = (y - cl["base"]) / cl["size"]
        under = smoothstep(0.75, 0.05, height)
        tone = np.clip(0.40 + 0.60 * lit - 0.40 * under, 0, 1)
        c = mix(p["shade"], p["lit"], tone)
        c = mix(c, p["belly"], p.get("belly_amt", 0.0) * under)
        c = mix(c, p["lit"], 0.5 * smoothstep(0.12, 0.0, f) * smoothstep(0.0, 0.5, light))
        c = mix(c, p["haze"], p.get("haze_amt", 0.25) * smoothstep(13, 3, y))
        a = alpha * p.get("opacity", 0.95)
        col[sel] = col[sel] * (1 - a[:, None]) + c * a[:, None]
    return col


def draw_streaks(col, d, el, nz, colour, lo, hi, amount, stretch=(1.0, 7.0), thresh=(0.55, 0.78),
                 offset=0.0, scale=2.4):
    """Long flat cloud bands (stratus / cirrus): noise squashed in elevation."""
    band = smoothstep(lo - 3, lo, el) * smoothstep(hi + 3, hi, el)
    sel = band > 0
    if not sel.any():
        return col
    pts = d[sel] * np.array([stretch[0], stretch[1], stretch[0]], np.float32) * scale + offset
    n = nz.fbm(pts, 4)
    a = smoothstep(thresh[0], thresh[1], n) * band[sel] * amount
    col[sel] = mix(col[sel], colour, a)
    return col


def glow(col, az, el, colour, az0, width, el_lo, el_hi, amount):
    g = np.exp(-(wrap(az - az0) / width) ** 2) * smoothstep(el_hi, el_lo, el) * amount
    return mix(col, colour, np.clip(g, 0, 1))


def gradient(el, stops):
    """stops: list of (elevation, colour) from low to high."""
    col = np.repeat(stops[0][1][None], len(el), 0)
    for (e0, c0), (e1, c1) in zip(stops[:-1], stops[1:]):
        t = smoothstep(e0, e1, el)
        col = col * (1 - t[:, None]) + c1 * t[:, None]
    return col


# ===================================================================== themes
class Sky:
    # Degrees the painted sky is tilted forward, so its horizon sits under eye level on the SkyboxFt side (straight
    # across the match camera's view, rising toward SkyboxBk, which no match camera sees): a lower horizon shows more
    # sky behind the map's lower half (the owner, 2026-11-25: "the bottom half is too long")
    HORIZON_DROP = 10.0

    def __init__(self, seed):
        self.rng = np.random.default_rng(seed)
        self.nz = Noise3(seed)
        self.build()

    def __call__(self, dirs):
        shape = dirs.shape[:-1]
        d = dirs.reshape(-1, 3).astype(np.float32)
        # Tilt about X: looking HORIZON_DROP degrees down toward -Z sees the painted horizon
        t = np.radians(self.HORIZON_DROP)
        y = d[:, 1] * np.cos(t) - d[:, 2] * np.sin(t)
        z = d[:, 1] * np.sin(t) + d[:, 2] * np.cos(t)
        el = np.degrees(np.arcsin(np.clip(y, -1, 1)))
        az = np.degrees(np.arctan2(d[:, 0], -z))   # 0 = Ft centre, +90 = Lf
        col = self.paint(d, az, el)
        return col.reshape(*shape, 3)

    def grain(self, col, d, amt=0.03):
        n = self.nz.fbm(d * 2.2, 3)
        return col * (1 + (n[:, None] - 0.5) * amt)


class PicnicPlains(Sky):
    """Spring morning: soft blue, fat friendly clouds, far green hills and a few
    hazy floating islets echoing the map's own."""
    ZENITH, MID, HAZE = C(86, 158, 222), C(132, 192, 236), C(222, 238, 246)
    FLOOR = C(176, 210, 226)
    HILL_FAR, HILL_NEAR = C(150, 192, 170), C(122, 178, 132)
    MOUNT = C(176, 198, 222)

    def build(self):
        r = self.rng
        self.mount = profile_table([(-44, 4.6, 12), (-30, 3.2, 9), (38, 4.0, 11), (52, 5.4, 13),
                                    (150, 4, 12), (210, 4.5, 14), (280, 4, 12)], "peak",
                                   periodic_noise(r, TABLE_AZ, 30, 160, 0.9), 0.10)
        self.hill_far = 1.9 + 0.9 * periodic_noise(r, TABLE_AZ, 3, 18, 1.1)
        self.hill_near = 0.9 + 0.6 * periodic_noise(r, TABLE_AZ, 5, 26, 1.0)
        self.clouds = make_puffy(r, [(-46, 12.0, 20, 2.8), (-14, 17.0, 12, 2.0), (22, 10.5, 16, 2.4),
                                     (50, 15.0, 18, 2.6), (120, 9, 16, 2.4), (190, 8, 18, 2.5),
                                     (260, 11, 14, 2.2), (318, 8, 16, 2.3)])
        # Floating islets: (azimuth, elevation, half-width deg)
        self.islets = [(-34, 8.0, 2.4), (-24, 11.0, 1.1), (36, 9.5, 1.7)]

    def draw_islets(self, col, az, el):
        for c, e0, w in self.islets:
            x = wrap(az - c) / w
            y = (el - e0) / w
            sel = (np.abs(x) < 1.3) & (y > -2.2) & (y < 0.6)
            if not sel.any():
                continue
            xs, ys = x[sel], y[sel]
            topline = 0.16 * np.sqrt(np.clip(1 - xs * xs, 0, 1))         # domed grass top
            bottom = -0.95 * np.clip(1 - xs * xs, 0, 1) ** 0.75          # round rocky belly
            bottom = bottom - 0.35 * np.exp(-(xs / 0.28) ** 2)            # short root
            inside = smoothstep(0.04, -0.04, ys - topline) * smoothstep(-0.04, 0.04, ys - bottom)
            inside = inside * smoothstep(1.0, 0.96, np.abs(xs))
            grass = smoothstep(topline - 0.26, topline - 0.18, ys)
            c_ = mix(C(168, 178, 204), C(160, 204, 176), grass)
            c_ = mix(c_, C(150, 162, 192), 0.5 * smoothstep(-0.2, -0.9, ys))
            c_ = mix(c_, self.HAZE, 0.48)
            col[sel] = mix(col[sel], c_, inside * 0.9)
        return col

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (4, self.MID), (28, self.ZENITH)])
        col = self.grain(col, d)
        col = glow(col, az, el, C(255, 246, 226), 0, 70, 0, 8, 0.2)  # warm morning light low down
        col = draw_streaks(col, d, el, self.nz, C(250, 252, 255), 16, 36, 0.18)
        col = draw_puffy(col, az, el, self.clouds, dict(lit=C(253, 254, 255), shade=C(206, 222, 240),
                                                         belly=C(196, 214, 236), belly_amt=0.3,
                                                         haze=self.HAZE, haze_amt=0.3))
        col = draw_band(col, az, el, self.mount, self.MOUNT, self.HAZE, 0.30,
                        shade=C(160, 184, 212))
        col = draw_band(col, az, el, self.hill_far, mix(self.HILL_FAR, self.MOUNT, 0.2), self.HAZE, 0.40,
                        crest=C(176, 214, 186))
        col = draw_band(col, az, el, self.hill_near, self.HILL_NEAR, self.HAZE, 0.22,
                        crest=C(150, 200, 150))
        col = mix(col, self.FLOOR, smoothstep(-0.3, -6.0, el))
        return col


class VolcanoIsle(Sky):
    """Ember dusk: plum sky over a warm amber horizon, smoke clouds lit from
    below by lava, two far volcano cones off to the sides with lazy plumes."""
    ZENITH, MID, LOW, HAZE = C(62, 48, 78), C(112, 72, 96), C(190, 104, 86), C(238, 152, 96)
    FLOOR = C(96, 46, 40)
    CONE, CONE_SHADE = C(110, 70, 84), C(86, 56, 72)

    def build(self):
        r = self.rng
        self.cones = profile_table([(-38, 9.0, 11), (-27, 4.2, 7), (44, 6.6, 9), (150, 5, 10), (230, 7, 11)],
                                   "cone", periodic_noise(r, TABLE_AZ, 40, 200, 0.8), 0.18)
        self.ridge = 1.4 + 0.9 * periodic_noise(r, TABLE_AZ, 4, 30, 1.0)
        self.vents = [(-38, 9.0 * 0.84), (44, 6.6 * 0.84)]
        # Each plume's puffs, built once so every face sees the same smoke:
        # along a path that rises and leans downwind, growing as they climb.
        self.plumes = []
        for c, top in self.vents:
            puffs = []
            for i in range(9):
                t = i / 8
                rise = 0.7 + 19.0 * t ** 1.1
                x = 7.0 * t ** 1.8 + r.uniform(-0.6, 0.6) * (0.4 + 1.6 * t)
                rad = 0.75 + 3.0 * t + r.uniform(-0.15, 0.4)
                puffs.append((x, top + rise, rad, t))
                if i > 1:   # a side puff so it billows rather than stacks
                    puffs.append((x + r.choice([-1, 1]) * rad * 0.75, top + rise - rad * 0.35, rad * 0.65, t))
            self.plumes.append((c, top, puffs))
        self.clouds = make_puffy(r, [(-50, 14.0, 22, 3.0), (-8, 18.0, 16, 2.4), (27, 12.5, 20, 2.8),
                                     (58, 17.0, 14, 2.2), (130, 11, 18, 2.6), (200, 10, 20, 2.6),
                                     (290, 12, 18, 2.6)])

    def draw_plumes(self, col, d, az, el):
        for c, top, puffs in self.plumes:
            sel = (np.abs(wrap(az - c - 4)) < 16) & (el > top - 0.5) & (el < top + 26)
            if not sel.any():
                continue
            x = wrap(az[sel] - c) * np.cos(np.radians(el[sel]))
            y = el[sel]
            acc = np.zeros_like(x)
            age = np.zeros_like(x)
            lit = np.zeros_like(x)
            for px, py, pr, t in puffs:
                dd = np.sqrt((x - px) ** 2 + (y - py) ** 2)
                w = np.exp(9.0 * np.clip((pr - dd) / pr, -3, 3))
                acc += w
                age += w * t
                lit += w * np.clip((py - y) / pr, -1, 1)      # undersides face the lava
            f = np.log(acc + 1e-12) / 9.0
            age, lit = age / (acc + 1e-12), lit / (acc + 1e-12)
            alpha = smoothstep(-0.05, 0.06, f) * smoothstep(1.0, 0.55, age) * 0.85
            base = mix(C(132, 96, 112), C(110, 84, 104), age)
            warm = smoothstep(0.45, 0.0, age) * smoothstep(-0.2, 0.8, lit)
            c_ = mix(base, C(238, 150, 104), warm * 0.9)
            c_ = mix(c_, C(160, 118, 128), 0.25 * smoothstep(0.2, -0.6, lit) * (1 - warm))
            col[sel] = col[sel] * (1 - alpha[:, None]) + c_ * alpha[:, None]
        return col

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (2, self.LOW), (8, self.MID), (30, self.ZENITH)])
        col = self.grain(col, d, 0.04)
        col = glow(col, az, el, C(255, 186, 110), 0, 60, -1, 4, 0.35)
        col = draw_streaks(col, d, el, self.nz, C(150, 96, 110), 14, 34, 0.30, offset=5.0)
        col = draw_puffy(col, az, el, self.clouds,
                         dict(lit=C(150, 108, 124), shade=C(98, 70, 92), belly=C(222, 132, 100), belly_amt=0.55,
                              haze=C(200, 120, 100), haze_amt=0.2, light=(0.2, -1.0), opacity=0.9))
        col = self.draw_plumes(col, d, az, el)
        col = draw_band(col, az, el, self.cones, self.CONE, self.HAZE, 0.18, shade=self.CONE_SHADE,
                        crest=C(176, 104, 96), crest_w=0.25)
        # Lava glow in each crater.
        for c, top in self.vents:
            g = np.exp(-((wrap(az - c)) / 1.3) ** 2 - ((el - top) / 0.45) ** 2)
            col = mix(col, C(255, 176, 90), np.clip(g * 0.9, 0, 1))
        col = draw_band(col, az, el, self.ridge, C(92, 56, 64), self.HAZE, 0.30, crest=C(150, 84, 76))
        col = mix(col, self.FLOOR, smoothstep(-0.3, -7.0, el))
        col = glow(col, az, el, C(200, 90, 50), 0, 80, -2, -12, 0.0)
        return col


class RockslideRidge(Sky):
    """Dusty highland under a calm overcast: pale slate sky, long stratus bands,
    three layers of jagged ridges fading into warm dust, a faint lava glow."""
    ZENITH, MID, HAZE = C(116, 140, 164), C(168, 178, 188), C(222, 208, 188)
    FLOOR = C(130, 104, 90)

    def build(self):
        r = self.rng
        j = periodic_noise(r, TABLE_AZ, 40, 260, 0.75)
        self.far = profile_table([(-46, 10, 10), (-36, 7, 8), (-22, 6, 9), (26, 6.5, 8), (40, 11, 11),
                                  (54, 7.5, 8), (120, 8, 12), (190, 9, 12), (260, 7, 12), (320, 8, 11)],
                                 "peak", j, 0.45)
        self.mid = profile_table([(-52, 5.5, 9), (-30, 4.0, 10), (-6, 2.6, 9), (18, 3.2, 9), (48, 5.0, 10),
                                  (100, 4, 12), (170, 5, 12), (240, 4, 14), (300, 5, 12)],
                                 "peak", periodic_noise(r, TABLE_AZ, 30, 200, 0.8), 0.35)
        self.near = 1.3 + 0.8 * periodic_noise(r, TABLE_AZ, 6, 60, 0.9)

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (4, self.MID), (30, self.ZENITH)])
        col = self.grain(col, d, 0.035)
        col = draw_streaks(col, d, el, self.nz, C(206, 210, 214), 8, 28, 0.55, stretch=(1.0, 9.0),
                           thresh=(0.50, 0.74))
        col = draw_streaks(col, d, el, self.nz, C(140, 150, 162), 10, 22, 0.28, stretch=(1.0, 10.0),
                           thresh=(0.60, 0.80), offset=11.0)
        col = glow(col, az, el, C(240, 176, 128), 0, 90, -1, 3, 0.22)
        col = draw_band(col, az, el, self.far, C(150, 156, 168), self.HAZE, 0.35, shade=C(132, 138, 154))
        col = draw_band(col, az, el, self.mid, C(118, 112, 112), self.HAZE, 0.28, shade=C(98, 94, 98),
                        crest=C(150, 140, 132), crest_w=0.2)
        col = draw_band(col, az, el, self.near, C(96, 84, 80), self.HAZE, 0.25, crest=C(130, 112, 100))
        col = mix(col, self.FLOOR, smoothstep(-0.3, -7.0, el))
        return col


class Desert(Sky):
    """Golden afternoon: clear teal sky, a few high wisps, pale peach haze and far
    mesas sitting low on the horizon, softened to almost nothing."""
    ZENITH, MID, HAZE = C(62, 146, 196), C(128, 190, 216), C(248, 224, 186)
    FLOOR = C(226, 190, 142)

    def build(self):
        r = self.rng
        self.mesa_far = profile_table([(-44, 4.2, 9), (-28, 2.8, 6), (34, 3.4, 8), (50, 5.0, 7),
                                       (130, 4, 9), (200, 3.5, 10), (290, 4, 9)], "mesa",
                                      periodic_noise(r, TABLE_AZ, 50, 220, 0.8), 0.06)
        self.mesa_near = profile_table([(-54, 2.6, 7), (-8, 1.6, 6), (22, 2.0, 5), (64, 2.2, 7), (170, 2, 8)],
                                       "mesa", periodic_noise(r, TABLE_AZ, 50, 220, 0.8), 0.05)
        self.dunes = 0.8 + 0.5 * periodic_noise(r, TABLE_AZ, 4, 30, 1.1)
        self.clouds = make_puffy(r, [(-40, 9.0, 14, 1.9), (36, 12.0, 10, 1.6), (150, 9, 12, 1.8)])

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (3, C(214, 214, 196)), (9, self.MID), (32, self.ZENITH)])
        col = self.grain(col, d, 0.03)
        col = draw_streaks(col, d, el, self.nz, C(255, 250, 240), 12, 32, 0.40, stretch=(1.0, 6.0),
                           thresh=(0.58, 0.80), scale=3.0)
        col = draw_puffy(col, az, el, self.clouds, dict(lit=C(255, 250, 240), shade=C(228, 214, 204),
                                                         belly=C(240, 200, 170), belly_amt=0.35,
                                                         haze=self.HAZE, haze_amt=0.35, opacity=0.85))
        col = draw_band(col, az, el, self.mesa_far, C(214, 168, 150), self.HAZE, 0.42,
                        shade=C(190, 150, 148))
        col = draw_band(col, az, el, self.mesa_near, C(206, 146, 112), self.HAZE, 0.30,
                        shade=C(178, 124, 104), crest=C(232, 182, 136), crest_w=0.15)
        col = draw_band(col, az, el, self.dunes, C(232, 196, 146), self.HAZE, 0.20, crest=C(246, 220, 170))
        col = mix(col, self.FLOOR, smoothstep(-0.3, -7.0, el))
        return col


class Mountains(Sky):
    """Crisp alpine morning: a clear cool blue that sets off the map's grey rock and
    snow, a few soft clouds, and far snowy ranges low on the horizon, the tallest
    peaks toward the sides."""
    ZENITH, MID, HAZE = C(70, 132, 206), C(128, 178, 228), C(214, 230, 244)
    FLOOR = C(190, 210, 228)
    SNOW, SNOW_SHADE = C(244, 248, 253), C(200, 214, 236)

    def build(self):
        r = self.rng
        self.far = profile_table([(-48, 9.5, 11), (-36, 6.5, 8), (-24, 4.5, 8), (-4, 2.6, 9), (20, 3.4, 9),
                                  (36, 7.0, 9), (50, 10.0, 12), (110, 7, 12), (180, 8, 13), (250, 7, 12),
                                  (310, 8, 12)], "peak", periodic_noise(r, TABLE_AZ, 40, 240, 0.8), 0.30)
        self.near = profile_table([(-56, 4.2, 10), (-30, 2.6, 9), (8, 1.8, 10), (30, 2.4, 9), (58, 4.0, 10),
                                   (140, 3, 14), (220, 3.5, 14), (290, 3, 13)], "peak",
                                  periodic_noise(r, TABLE_AZ, 30, 200, 0.8), 0.18)
        self.forest = 0.9 + 0.35 * periodic_noise(r, TABLE_AZ, 60, 240, 0.6)
        self.clouds = make_puffy(r, [(-42, 13.0, 16, 2.4), (-6, 18.0, 11, 1.8), (30, 12.0, 14, 2.2),
                                     (56, 16.0, 12, 2.0), (150, 10, 16, 2.4), (230, 11, 16, 2.4)])

    def draw_snowy(self, col, az, el, table, rock, rock_shade, haze_amt):
        """A range with snow above a ragged line on each peak."""
        top = lookup(table["top"], az)
        inside = smoothstep(top + 0.06, top - 0.06, el)
        sel = inside > 0
        if not sel.any():
            return col
        a, e, t = az[sel], el[sel], top[sel]
        depth = np.clip(t - e, 0, None)
        wob = depth * (0.35 * np.sin(1.7 * e + 0.11 * a) + 0.18 * np.sin(4.3 * e - 0.07 * a))
        slope = lookup(table["smooth"], a + wob + 0.4) - lookup(table["smooth"], a + wob - 0.4)
        shade = smoothstep(-0.03, 0.03, -slope)
        c = mix(rock, rock_shade, 0.85 * shade)
        snowline = t - (1.1 + 0.5 * np.sin(0.9 * a) + 0.35 * np.sin(2.7 * a + 1.3)) * smoothstep(2.5, 6.0, t)
        snow = smoothstep(snowline - 0.15, snowline + 0.15, e) * smoothstep(2.0, 3.5, t)
        c = mix(c, mix(self.SNOW, self.SNOW_SHADE, shade), snow)
        c = mix(c, self.HAZE, haze_amt + (1 - haze_amt) * 0.6 * smoothstep(t * 0.5, -0.8, e))
        m = inside[sel][:, None]
        col[sel] = col[sel] * (1 - m) + c * m
        return col

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (4, self.MID), (30, self.ZENITH)])
        col = self.grain(col, d, 0.03)
        col = draw_streaks(col, d, el, self.nz, C(248, 251, 255), 16, 36, 0.20, stretch=(1.0, 7.0))
        col = draw_puffy(col, az, el, self.clouds, dict(lit=C(253, 254, 255), shade=C(204, 218, 238),
                                                         belly=C(190, 206, 230), belly_amt=0.3,
                                                         haze=self.HAZE, haze_amt=0.3))
        col = self.draw_snowy(col, az, el, self.far, C(150, 166, 194), C(126, 142, 176), 0.32)
        col = self.draw_snowy(col, az, el, self.near, C(124, 138, 164), C(104, 118, 148), 0.22)
        col = draw_band(col, az, el, self.forest, C(96, 128, 128), self.HAZE, 0.35, crest=C(120, 150, 146))
        col = mix(col, self.FLOOR, smoothstep(-0.3, -6.0, el))
        return col


class DesertGradient(Desert):
    """Desert's sky with its gradient only: its mesas, dunes and clouds stand in the world as parallax layers
    (parallax.py), since shapes painted in a skybox never move as the camera pans and zooms."""

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (3, C(214, 214, 196)), (9, self.MID), (32, self.ZENITH)])
        return self.grain(col, d, 0.02)


class PicnicPlainsGradient(PicnicPlains):
    """Picnic Plains' sky with its gradient only (Rolling Plains' parallax layers carry the shapes)."""

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (4, self.MID), (28, self.ZENITH)])
        return self.grain(col, d, 0.02)


class MountainsGradient(Mountains):
    """The Mountains sky with its gradient only (Echo Caverns' parallax layers carry the shapes)."""

    def paint(self, d, az, el):
        col = gradient(el, [(-2, self.HAZE), (4, self.MID), (30, self.ZENITH)])
        return self.grain(col, d, 0.02)


THEMES = {"PicnicPlains": (PicnicPlains, 11), "VolcanoIsle": (VolcanoIsle, 23),
          "RockslideRidge": (RockslideRidge, 31), "Desert": (Desert, 47), "Mountains": (Mountains, 59),
          "DesertGradient": (DesertGradient, 47), "PicnicPlainsGradient": (PicnicPlainsGradient, 11),
          "MountainsGradient": (MountainsGradient, 59)}


# ------------------------------------------------------------------ rendering
def face_dirs(name, size):
    c, r, u = (np.array(v, np.float32) for v in FACES[name])
    s = (np.arange(size, dtype=np.float32) + 0.5) / size * 2 - 1
    d = c + s[None, :, None] * r + (-s)[:, None, None] * u
    return d / np.linalg.norm(d, axis=-1, keepdims=True)


def to_image(col, seed=0):
    rng = np.random.default_rng(seed)
    dither = rng.random(col.shape[:2], np.float32) - rng.random(col.shape[:2], np.float32)
    return Image.fromarray(np.clip(np.round(col + dither[..., None]), 0, 255).astype(np.uint8), "RGB")


def check_seams(raw):
    E = {"L": lambda a: (a[:, 0], a[:, 1]), "R": lambda a: (a[:, -1], a[:, -2]),
         "T": lambda a: (a[0], a[1]), "B": lambda a: (a[-1], a[-2])}
    pairs = [("lf", "R", "bk", "L", False), ("bk", "R", "rt", "L", False),
             ("rt", "R", "ft", "L", False), ("ft", "R", "lf", "L", False),
             ("up", "B", "rt", "T", False), ("up", "L", "bk", "T", False),
             ("up", "R", "ft", "T", True), ("up", "T", "lf", "T", True),
             ("dn", "T", "rt", "B", False), ("dn", "L", "bk", "B", True),
             ("dn", "R", "ft", "B", False), ("dn", "B", "lf", "B", True)]
    worst = 0.0
    for fa, ea, fb, eb, rev in pairs:
        a0, a1 = E[ea](raw[fa])
        b0, b1 = E[eb](raw[fb])
        if rev:
            b0, b1 = b0[::-1], b1[::-1]
        across = np.abs(a0 - b0).mean()
        inside = 0.5 * (np.abs(a0 - a1).mean() + np.abs(b0 - b1).mean())
        worst = max(worst, across / max(inside, 1e-3))
    return worst


def view_dirs(w, h, vfov=70.0, yaw=0.0, pitch=0.0):
    """Match camera: looks along -Z (yaw 0), level, 70 deg vertical field of view."""
    p, yw = np.radians(pitch), np.radians(yaw)
    fwd = np.array([np.sin(yw) * np.cos(p), np.sin(p), -np.cos(yw) * np.cos(p)], np.float32)
    right = np.cross(fwd, [0, 1, 0]).astype(np.float32)
    right /= np.linalg.norm(right)
    up = np.cross(right, fwd)
    th = np.tan(np.radians(vfov) / 2)
    tw = th * w / h
    xs = ((np.arange(w) + 0.5) / w * 2 - 1) * tw
    ys = (1 - (np.arange(h) + 0.5) / h * 2) * th
    d = fwd + xs[None, :, None] * right + ys[:, None, None] * up
    return d / np.linalg.norm(d, axis=-1, keepdims=True)


def preview_cross(imgs, cell=256):
    sheet = Image.new("RGB", (cell * 4, cell * 3), (40, 44, 52))
    spots = {"lf": (0, 1), "bk": (1, 1), "rt": (2, 1), "ft": (3, 1), "up": (2, 0), "dn": (2, 2)}
    draw = ImageDraw.Draw(sheet)
    for k, (cx, cy) in spots.items():
        sheet.paste(imgs[k].resize((cell, cell), Image.LANCZOS), (cx * cell, cy * cell))
        draw.text((cx * cell + 6, cy * cell + 4), "Skybox" + k.capitalize(), fill=(40, 60, 90))
    return sheet


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--maps", nargs="*", default=list(THEMES))
    ap.add_argument("--faces", action="store_true", help="also write the six faces and the cross")
    ap.add_argument("--size", type=int, default=1024)
    ap.add_argument("--width", type=int, default=1600)
    args = ap.parse_args()
    for name in args.maps:
        cls, seed = THEMES[name]
        sky = cls(seed)
        folder = os.path.join(OUT, name)
        os.makedirs(folder, exist_ok=True)
        w = args.width
        h = w * 9 // 16
        to_image(sky(view_dirs(w, h)), 99).save(os.path.join(folder, "preview_view.png"))
        print(name, "preview written")
        if args.faces:
            raw, imgs = {}, {}
            for i, f in enumerate(FACES):
                raw[f] = sky(face_dirs(f, args.size))
                imgs[f] = to_image(raw[f], i)
                imgs[f].save(os.path.join(folder, f"sky_{f}.png"), optimize=True)
            print(f"  faces written, worst seam ratio {check_seams(raw):.2f}")
            preview_cross(imgs).save(os.path.join(folder, "preview_cross.png"))


if __name__ == "__main__":
    main()
