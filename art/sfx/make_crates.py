"""Crate-opening sounds (draft, not approved yet): python -I make_crates.py [<out>] [<name> ...]

A hybrid, as the owner asked (2026-11-11): the mechanical parts (the reel's tick, the landing lock, the latch) are
crisp, refined synthesis in the CS:GO case-opening manner, and everything musical (reveals, fanfares, the rare drops'
calls) is played on the classic Roblox soundscape the game already uses: The Great Strategy and Wind of Fjords
tracker samples and Roblox's own 2009 sounds, through the sound kit's tracker.py and make_classic.py helpers.

Writes WB_<Name>.wav and .ogg per sound into <out> (default out/crates), and crates.json (name, what, seconds), which
the crate kit's preview reads (art/crates/README.md).
"""

import json
import os
import sys

KIT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(KIT, "out", "crates")
sys.path.insert(0, KIT)

import numpy as np  # noqa: E402

import snaillib as L  # noqa: E402
from make_classic import load, sampled, speed, stack  # noqa: E402
from snaillib import N, SR, band, bubble, click, fade, level, modal, place, room, spec, sweep, thump, tt  # noqa: E402

SOUNDS = {}


def sound(target, seed=1):
    def wrap(fn):
        SOUNDS[fn.__name__] = {"fn": fn, "target": target, "seed": seed}
        return fn
    return wrap


def silence(seconds):
    return np.zeros(N(seconds))


def plus(*xs):
    """Sums sounds of different lengths."""
    out = np.zeros(max(len(x) for x in xs))
    for x in xs:
        out[: len(x)] += x
    return out


# --- the reel: crisp, refined -----------------------------------------------------------------------------------------

@sound(-21, seed=11)
def Crate_Tick():
    """The reel ticking as each card crosses the line: a short, dry, plasticky-metal click (a fine transient, a bright
    two-partial 'tik' and a tiny woody knock under it), 50 ms. The game varies its PlaybackSpeed a little per tick."""
    s = 0.06
    tr = click(0.0035, lo=3500) * 0.55
    tik = modal([2650, 3980, 6100], [0.010, 0.006, 0.003], [1.0, 0.45, 0.25], s)
    knock = modal([820, 1240], [0.008, 0.005], [0.5, 0.25], s)
    return L.mix(s, (tr, 0, 1), (tik, 0.0005, 0.8), (knock, 0, 0.7))


@sound(-19, seed=12)
def Crate_Land():
    """The reel coming to rest: a soft deep 'thock' with a two-part lock click on top (tch-tk), dry and short."""
    s = 0.45
    body = thump(170, 62, 0.02, 0.07, s)
    wood = L.mallet(57, s, "wood") * 0.8
    c1 = plus(modal([3100, 4700], [0.006, 0.004], [1, 0.5], 0.03), click(0.003, 3000) * 0.4)
    c2 = plus(modal([2400, 3600], [0.007, 0.004], [1, 0.5], 0.03), click(0.003, 3000) * 0.3)
    return L.mix(s, (body, 0, 1), (wood, 0, 0.5), (c1, 0.0, 0.7), (c2, 0.045, 0.55))


@sound(-20, seed=13)
def Crate_Settle():
    """The marker easing onto the card's centre after it lands: one tiny soft click and a felt 'tuck'."""
    s = 0.2
    return L.mix(s, (modal([1900, 2850], [0.008, 0.005], [1, 0.4], 0.04), 0, 0.6),
                 (thump(120, 70, 0.02, 0.04, s), 0, 0.5))


# --- the crate ---------------------------------------------------------------------------------------------------------

@sound(-19, seed=21)
def Crate_Shake():
    """The crate rattling before it opens: wooden knocks speeding up with a classic hit under the last, 0.7 s."""
    s = 0.75
    parts = []
    for i, (t, v, p) in enumerate(((0.0, 0.55, 50), (0.17, 0.62, 47), (0.30, 0.7, 52), (0.40, 0.8, 48), (0.47, 0.9, 53),
                                   (0.53, 1.0, 49))):
        parts.append((plus(L.mallet(p, 0.25, "wood"), thump(140, 70, 0.015, 0.04, 0.25) * 0.6), t, v))
    parts.append((speed(load("hit"), 0.8), 0.53, 0.35))
    return L.mix(s, *parts)


@sound(-17, seed=22)
def Crate_Unlock():
    """The crate opening: a metal latch (the classic switch, low), the lid snapping up with the classic blade 'shing'
    for its light, and a quick harp glissando rising into the reel's whoosh."""
    s = 1.3
    latch = speed(load("switch"), 0.85)
    shing = speed(load("unsheath"), 1.35)
    scale = [60, 62, 64, 67, 69, 72, 74, 76, 79, 81, 84, 86, 88]
    gl = sampled([("harp", 0.12 + i * 0.022, 0.25, p, 64 + i * 3) for i, p in enumerate(scale)], 1.0, wet=0.2)
    sw = speed(load("swoosh"), 1.15)
    pop = thump(110, 48, 0.02, 0.09, 0.4)
    return L.mix(s, (latch, 0, 0.9), (pop, 0.08, 0.6), (shing, 0.1, 0.45), (gl, 0, 0.75), (sw, 0.42, 0.55))


@sound(-20, seed=23)
def Crate_Spin():
    """The reel launching (three and ten packs, where each reel starts by itself): a short airy swoosh up."""
    sw = speed(load("swoosh"), 1.3)
    return L.mix(0.6, (sw, 0, 0.9), (L.mallet(84, 0.4, "glock") * 0.25, 0.05, 1))


@sound(-22, seed=24)
def Crate_Tease():
    """A rare drop slowing in (epic and legendary, the last 2.5 s of the roll): a heartbeat on the classic bass drum
    speeding up under strings and a low choir swelling, sparse finger chimes on top. It stops as the reel lands."""
    notes = []
    for t, v in ((0.0, 70), (0.55, 74), (1.02, 80), (1.42, 86), (1.74, 92), (2.0, 98), (2.2, 104)):
        notes.append(("bassdrum", t, 0, 0, v))
    notes += [("strings", 0.0, 2.5, 48, 70), ("strings", 0.0, 2.5, 55, 64), ("lowchoir", 0.3, 2.2, 36, 70),
              ("strings2", 1.0, 1.5, 63, 60)]
    for t, p in ((0.4, 96), (1.1, 99), (1.6, 103), (2.0, 106), (2.25, 108)):
        notes.append(("chimes", t, 0.4, p, 50))
    x = sampled(notes, 2.6, wet=0.3)
    return x * np.clip(tt(2.6) / 1.2, 0.25, 1) ** 1.2


@sound(-16, seed=25)
def Crate_GoldHit():
    """The reel landing on the gold star card (a legendary is coming): the orchestra hit, crash and bass drum together,
    a finger-chime glissando rising, and a low choir and horns holding a G chord underneath into the golden reel."""
    n = [("hit", 0, 0, 0, 110), ("crash", 0, 0, 0, 100), ("bassdrum", 0, 0, 0, 112)]
    n += [("chimes", 0.05 + i * 0.03, 0.5, p, 60) for i, p in enumerate((84, 88, 91, 96, 100, 103, 108))]
    n += [("lowchoir", 0.0, 1.5, 31, 90)]
    n += [("choir", 0.05, 1.4, p, 70) for p in (67, 71, 74)]
    n += [("horn", 0.05, 1.4, p, 80) for p in (43, 55)]
    return sampled(n, 2.0, wet=0.35)


# --- reveals: one per rarity, rising in size --------------------------------------------------------------------------

@sound(-20, seed=31)
def Reveal_Common():
    """A common item: two soft harp notes (G, C) and a light chime."""
    return sampled([("harp", 0, 0.3, 67, 80), ("harp", 0.07, 0.4, 72, 86), ("chimes", 0.07, 0.3, 96, 40)], 0.9)


@sound(-19, seed=32)
def Reveal_Uncommon():
    """An uncommon item: three harp notes up (C, E, G) over a soft piano C, a chime on top."""
    n = [("harp", 0, 0.3, 72, 82), ("harp", 0.06, 0.3, 76, 86), ("harp", 0.12, 0.5, 79, 92),
         ("piano", 0.12, 0.5, 60, 60), ("chimes", 0.14, 0.4, 100, 48)]
    return sampled(n, 1.1)


@sound(-18, seed=33)
def Reveal_Rare():
    """A rare item: a harp arpeggio up an octave into a piano chord, finger chimes shimmering, a soft bass drum."""
    n = [("harp", i * 0.05, 0.4, p, 84 + i * 3) for i, p in enumerate((72, 76, 79, 84))]
    n += [("piano", 0.15, 0.9, p, 76) for p in (60, 64, 67)]
    n += [("chimes", 0.2, 0.5, 96, 56), ("chimes", 0.3, 0.5, 100, 50), ("chimes", 0.4, 0.6, 103, 44),
          ("bassdrum", 0.15, 0, 0, 70)]
    return sampled(n, 1.6, wet=0.28)


@sound(-17, seed=34)
def Reveal_Epic():
    """An epic item: a snare pickup into a bright-horn chord stab with the crash, strings and the choir swelling under
    it, the horn's top note held."""
    n = [("snare", t, 0, 0, v) for t, v in ((0.0, 50), (0.05, 60), (0.1, 72), (0.15, 86))]
    n += [("bassdrum", 0.2, 0, 0, 100), ("crash", 0.2, 0, 0, 90)]
    n += [("brass", 0.2, 0.25, p, 100) for p in (60, 64, 67)]
    n += [("brass2", 0.2, 1.1, 79, 104), ("horn", 0.2, 1.1, 48, 80)]
    n += [("strings", 0.2, 1.5, p, 74) for p in (48, 55, 60, 64)]
    n += [("choir", 0.25, 1.4, p, 70) for p in (60, 64, 67)]
    n += [("chimes", 0.3 + i * 0.04, 0.5, p, 50) for i, p in enumerate((96, 100, 103, 108))]
    return sampled(n, 2.5, wet=0.3)


@sound(-15, seed=35)
def Reveal_Legendary():
    """A legendary item: a snare ruff, the bass drum and crash, and a bright-horn fanfare up the chord (G, C, E, a
    held G) with horns, the choir and strings behind it and a chime glissando, landing on the orchestra hit."""
    n = [("snare", i * 0.035, 0, 0, 44 + i * 6) for i in range(8)]
    n += [("bassdrum", 0.3, 0, 0, 104), ("crash", 0.3, 0, 0, 96)]
    for at, dur, p, v in ((0.3, 0.12, 67, 98), (0.45, 0.12, 72, 100), (0.6, 0.12, 76, 104), (0.75, 1.3, 79, 112)):
        n.append(("brass", at, dur, p, v))
        n.append(("brass2", at, dur, p - 12, v - 16))
    n += [("horn", 0.75, 1.4, p, 86) for p in (48, 55, 60)]
    n += [("choir", 0.75, 1.8, p, 80) for p in (60, 64, 67, 72)]
    n += [("strings", 0.75, 2.0, p, 78) for p in (43, 55, 64, 72)]
    n += [("chimes", 0.75 + i * 0.03, 0.5, p, 56) for i, p in enumerate((84, 88, 91, 96, 100, 103, 108))]
    n += [("hit", 0.75, 0, 0, 108), ("bassdrum", 0.75, 0, 0, 112), ("crash", 0.75, 0, 0, 104)]
    return sampled(n, 3.4, wet=0.32)


@sound(-18, seed=36)
def Reveal_Shiny():
    """A copy that makes an item shiny: a quick finger-chime and glockenspiel glitter up two octaves."""
    n = [("chimes", i * 0.035, 0.4, p, 60 + i * 4) for i, p in enumerate((84, 88, 91, 96, 100, 103, 108))]
    x = sampled(n, 1.1, wet=0.3)
    gl = L.mix(1.1, *[(L.mallet(p, 0.8, "glock"), 0.03 + i * 0.035, 0.18) for i, p in enumerate((96, 100, 103, 108))])
    return plus(x, gl)


# --- the rarest drops: one call each ----------------------------------------------------------------------------------

@sound(-14, seed=41)
def Legend_BlackHole():
    """Black hole grenade: everything sucked in (a falling filtered rush, the classic swoosh reversed, a sub sliding
    down), a deep implosion (a long thump and the classic explosion slowed), then a dark minor choir opening out."""
    s = 3.6
    suck_n = N(1.25)
    rush = sweep(L.noise(suck_n), 5000, 180, "lp", curve=0.7) * (np.linspace(0, 1, suck_n) ** 2.2)
    rev = np.flip(speed(load("swoosh"), 0.8))
    sub = L.osc(L.glide(240, 32, 1.25, "log"), 1.25) * np.linspace(0.1, 1, suck_n) ** 1.5 * 0.7
    boom = thump(95, 26, 0.05, 0.45, 2.0)
    expl = spec(speed(load("impact_explosion_03"), 0.55), hi=2500)
    n = [("lowchoir", 0.1, 2.0, 24, 96), ("choir", 0.15, 1.8, 63, 74), ("choir", 0.15, 1.8, 67, 70),
         ("choir", 0.15, 1.8, 72, 66), ("sweepbass", 0.0, 1.2, 36, 90), ("crash", 0.0, 0, 0, 86)]
    n += [("chimes", 0.6 + i * 0.22, 0.6, p, 46) for i, p in enumerate((99, 96, 103, 91))]
    pad = sampled(n, 2.3, wet=0.4)
    return L.mix(s, (rush, 0, 0.5), (rev, 1.25 - len(rev) / SR, 0.7), (sub, 0, 0.8), (boom, 1.25, 1.0),
                 (expl, 1.25, 0.55), (pad, 1.3, 0.9))


@sound(-14, seed=42)
def Legend_Variety():
    """Variety grenade: a party popping. The classic slingshot, a scatter of confetti pops, a finger-chime glissando
    and a bouncy major bright-horn fanfare with the crash, the classic Kerplunk bubbling under it."""
    s = 2.8
    sling = load("RubberBandSling")
    pops = L.mix(1.0, *[(plus(bubble(L.rng.uniform(400, 900), L.rng.uniform(1400, 2600), 0.035), click(0.002, 4000) * 0.5),
                         0.12 + 0.55 * L.rng.random() ** 1.4, L.rng.uniform(0.35, 0.8)) for _ in range(12)])
    n = [("chimes", 0.2 + i * 0.02, 0.4, p, 56) for i, p in enumerate((84, 86, 88, 91, 93, 96, 98, 100, 103))]
    for at, dur, p in ((0.4, 0.1, 72), (0.52, 0.1, 76), (0.64, 0.1, 79), (0.76, 1.1, 84)):
        n.append(("brass", at, dur, p, 104))
    n += [("horn", 0.76, 1.1, p, 84) for p in (60, 64, 67)]
    n += [("piano", 0.76, 0.8, p, 80) for p in (72, 84)]
    n += [("snare", t, 0, 0, 80) for t in (0.4, 0.52, 0.64)] + [("crash", 0.76, 0, 0, 100), ("bassdrum", 0.76, 0, 0, 104)]
    fan = sampled(n, 2.4, wet=0.28)
    return L.mix(s, (sling, 0, 0.8), (pops, 0.05, 0.7), (speed(load("Kerplunk"), 1.6), 0.3, 0.3), (fan, 0, 1))


@sound(-14, seed=43)
def Legend_Skeleton():
    """Skeleton skin: a crack of thunder, bones rattling (a scatter of woodblocks and the classic snap), and a low,
    spooky D-minor choir with the dirty bass, a chime line falling through it."""
    s = 3.4
    thn = L.noise(N(1.8))
    thunder = plus(spec(thn, hi=380, order=2) * L.decay(1.8, 0.55, 0.01) * 2.2, spec(thn, lo=1500) * L.decay(1.8, 0.06) * 0.4)
    bones = []
    for i in range(16):
        t = 0.18 + 0.75 * (i / 16) ** 0.8 + L.rng.uniform(-0.02, 0.02)
        bones.append((L.mallet(int(L.rng.integers(70, 88)), 0.12, "wood"), t, 0.9 - i * 0.04))
    rattle = L.mix(1.2, *bones)
    n = [("lowchoir", 0.35, 2.4, 26, 96), ("tenorchoir", 0.4, 2.2, 50, 80), ("choir", 0.45, 2.1, 65, 70),
         ("choir", 0.45, 2.1, 69, 66), ("dirtybass", 0.35, 0.6, 26, 96), ("bassdrum", 0.35, 0, 0, 100)]
    n += [("chimes", 1.0 + i * 0.18, 0.6, p, 54) for i, p in enumerate((93, 89, 86, 81))]
    choir = sampled(n, 3.0, wet=0.42)
    return L.mix(s, (thunder, 0, 0.9), (rattle, 0, 0.8), (speed(load("snap"), 1.2), 0.22, 0.4),
                 (speed(load("snap"), 0.9), 0.6, 0.3), (choir, 0, 1))


@sound(-15, seed=44)
def Legend_LowGravity():
    """Low gravity potion: things lifting off. Bubbles rising faster and higher, a slow harp climb up the pentatonic,
    an airy choir chord floating in and finger chimes hanging on top."""
    s = 3.0
    bub = []
    for i in range(18):
        f0 = 260 + i * 70
        bub.append((bubble(f0, f0 * 2.4, 0.06), 0.05 + 1.5 * (i / 18) ** 0.85 + L.rng.uniform(-0.02, 0.02),
                    0.45 + 0.03 * i))
    bubbles = L.mix(2.0, *bub)
    pent = [60, 62, 64, 67, 69, 72, 74, 76, 79, 81, 84]
    n = [("harp", 0.1 + i * 0.075, 0.6, p, 70 + i * 3) for i, p in enumerate(pent)]
    n += [("choir", 0.4, 2.2, p, 72) for p in (72, 76, 79)]
    n += [("strings2", 0.4, 2.2, 60, 60)]
    n += [("chimes", 1.0 + i * 0.25, 0.8, p, 50) for i, p in enumerate((100, 103, 108, 105))]
    float_ = sampled(n, 2.9, wet=0.4)
    rev = np.flip(speed(load("swoosh"), 0.7))
    return L.mix(s, (bubbles, 0, 0.55), (rev, 0.0, 0.35), (float_, 0, 1))


# --- results and the screen --------------------------------------------------------------------------------------------

@sound(-21, seed=51)
def Card_Flip():
    """A result card turning over (three and ten packs): the classic page turn, quick, and a short harp pluck."""
    return L.mix(0.4, (speed(load("pageturn"), 1.35), 0, 0.7), (sampled([("harp", 0, 0.15, 79, 76)], 0.35), 0.03, 0.6))


@sound(-21, seed=52)
def Results_Open():
    """The packs' results laying out: a soft swoosh with a gentle harp chord."""
    n = [("harp", i * 0.03, 0.5, p, 70) for i, p in enumerate((67, 72, 76, 79))]
    return L.mix(0.9, (speed(load("swoosh"), 1.1), 0, 0.6), (sampled(n, 0.8), 0.08, 0.8))


@sound(-22, seed=53)
def Crate_Premium():
    """Picking the premium crate: a quiet, expensive shimmer (finger chimes and glock up a major seventh chord) over a
    low choir breath."""
    n = [("chimes", i * 0.05, 0.6, p, 54) for i, p in enumerate((84, 88, 91, 95, 96))]
    n += [("choir", 0.0, 0.9, 60, 54), ("choir", 0.0, 0.9, 67, 50)]
    return sampled(n, 1.4, wet=0.36)


# --- build --------------------------------------------------------------------------------------------------------------

def main():
    os.makedirs(OUT, exist_ok=True)
    meta = {}
    names = sys.argv[2:] or list(SOUNDS)
    for name in names:
        row = SOUNDS[name]
        L.reseed(row["seed"])
        x = row["fn"]()
        x = fade(x, 0.0005, 0.05)
        x = level(x, row["target"])
        wav = os.path.join(OUT, f"WB_{name}.wav")
        L.write(wav, x)
        L.to_ogg(wav)
        meta[name] = {"what": (row["fn"].__doc__ or "").strip(), "seconds": round(len(x) / SR, 2)}
        print(f"{name:20s} {len(x) / SR:5.2f} s  peak {20 * np.log10(np.max(np.abs(x)) + 1e-9):6.1f} dB")
    with open(os.path.join(OUT, "crates.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1)


if __name__ == "__main__":
    main()
