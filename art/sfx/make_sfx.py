"""Builds Worm Battlegrounds' sound effects from code (numpy only): python -I make_sfx.py <out> [Name ...]

Each sound is a function below named after its SoundsList name. Writes WB_<Name>.wav and .ogg into <out>, and prints
its length and loudness. The style (README.md): a toy-box orchestra over cartoon physics, punchy and short.
"""

import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from snaillib import (N, SR, ar, band, bandsweep, bubble, click, decay, drive, fade, fit, gibber, glide, grains, hz,
                      level, loop_seam, mallet, mix, modal, noise, note, osc, place, reseed, room, spec, sweep, swell, thump,
                      tt, to_ogg, write)

SOUNDS = {}
LOOPS = {"Snail_Jetpack"}


def sound(target_db, measure="loudest"):
    def wrap(fn):
        SOUNDS[fn.__name__] = (fn, target_db, measure)
        return fn
    return wrap


# --- shared pieces ---------------------------------------------------------------------------------------------------

def explosion(size=1.0, seed=1):
    """A cartoon boom: a short pitched sub drop, a crunchy body darkening fast, a crack, and debris patter."""
    reseed(seed)
    L = 0.7 + 0.9 * size
    sub = thump(95 + 25 / size, 32, 0.05 * size, 0.16 * size, L)
    body = sweep(noise(N(L)), 4000, 220, "lp", curve=0.5) * decay(L, 0.22 * size, 0.003)
    crack = spec(noise(N(0.012)), lo=1800) * decay(0.012, 0.004)
    pop = osc(glide(420, 90, 0.05, "exp", 0.012), 0.05) * decay(0.05, 0.02)
    debris = grains(L, int(18 * size), 900, 4000, start=0.08)
    x = mix(L, (sub, 0, 1.0), (body, 0, 0.9), (crack, 0, 0.6), (pop, 0, 0.5 / size), (debris, 0, 0.35))
    return room(drive(x, 2.4), wet=0.16, seconds=0.8, decay_s=0.45 + 0.2 * size)


def whoosh(seconds=0.35, f0=500, f1=2200, gain=1.0):
    return bandsweep(noise(N(seconds)), f0, f1, q=1.6) * swell(seconds, 0.55, 1.5) * gain


def chime(notes, gap=0.07, kind="marimba", seconds=1.0, vel=None):
    out = np.zeros(N(seconds + gap * len(notes)))
    for i, m in enumerate(notes):
        place(out, mallet(note(m) if isinstance(m, str) else m, seconds, kind, (vel or [1] * len(notes))[i]), i * gap)
    return out


def pop_gun(f0=360, f1=120, seconds=0.07, bright=0.6):
    return (osc(glide(f0, f1, seconds, "exp", seconds * 0.15), seconds) * decay(seconds, seconds * 0.35)
            + spec(noise(N(seconds)), lo=1000) * decay(seconds, 0.012) * bright)


# --- turns and match ---------------------------------------------------------------------------------------------------

@sound(-15)
def Turn_Yours():
    """Your turn: a bright rising marimba and glockenspiel call (G5 C6 E6 G6) over a soft swish."""
    m = chime(["G5", "C6", "E6", "G6"], 0.075, "marimba", 1.0, [0.8, 0.85, 0.95, 1.0])
    g = chime(["G6", "C7", "E7", "G7"], 0.075, "glock", 1.0, [0.25, 0.3, 0.35, 0.45])
    return room(mix(1.4, (whoosh(0.3, 600, 3000, 0.25), 0, 1), (m, 0.05, 1), (g, 0.05, 1)), 0.2)


@sound(-21)
def Turn_Start():
    """Anyone else's turn: the same call an octave down, softer, three notes (replaces the old fanfare)."""
    return room(chime(["G4", "C5", "E5"], 0.08, "marimba", 0.9, [0.8, 0.85, 0.9]), 0.18)


@sound(-21)
def Turn_Next():
    """You're next: two soft woody notes asking for attention."""
    return room(chime(["E5", "A5"], 0.11, "marimba", 0.8, [0.7, 0.9]), 0.2)


@sound(-19)
def Turn_Tick():
    """A woodblock tick for the last seconds (the HUD raises its pitch as time runs out)."""
    return mix(0.12, (mallet(note("A6"), 0.12, "wood"), 0, 1), (click(0.003), 0, 0.3))


@sound(-17)
def Turn_TimeUp():
    """Time's up: a muted 'bwomp' falling a fifth with a droop."""
    f = np.concatenate([np.full(N(0.14), hz(note("E4"))), glide(hz(note("E4")), hz(note("A3")) * 0.97, 0.36, "log")])
    x = osc(f, 0.5, "saw") * ar(0.5, 0.01, 1.2)
    x = band(x, 700, 1.2) + band(x, 1400, 3) * 0.4
    wah = 0.6 + 0.4 * np.sin(2 * np.pi * 5 * tt(0.5))
    return room(x * wah, 0.2)


@sound(-18)
def Turn_Whoosh():
    """The swish under the 'Your turn' callout."""
    return whoosh(0.45, 300, 2800, 1.0)


@sound(-13)
def Match_SuddenDeath():
    """Sudden death: a tolling bell and a low gong over a rumbling swell of rising water."""
    reseed(4)
    bell = mix(3.0, (mallet(note("D4"), 3.0, "bell"), 0, 1), (mallet(note("D5"), 2.0, "bell"), 0, 0.3))
    gong = sum(np.sin(2 * np.pi * 70 * r * tt(3.0) + i) * np.exp(-tt(3.0) / (1.6 / r)) * g
               for i, (r, g) in enumerate([(1, 1), (1.47, 0.5), (2.09, 0.35), (2.56, 0.25), (3.4, 0.15)]))
    rumble = spec(noise(N(3.0)), hi=220) * swell(3.0, 0.75, 1.5)
    trom = (osc(hz(note("D2")), 1.4, "saw") + osc(hz(note("Eb2")), 1.4, "saw")) * ar(1.4, 0.05, 1.5)
    trom = spec(trom, hi=900)
    return room(mix(3.2, (bell, 0, 0.8), (gong, 0, 0.6), (rumble, 0, 0.5), (trom, 0.02, 0.35)), 0.25, 1.5, 1.2)


@sound(-17)
def Match_Knockout():
    """A knockout: a bright two-note 'ding-ding' over the blast."""
    d = lambda f: modal([f, f * 2.5, f * 4.1], [0.35, 0.12, 0.05], [1, 0.4, 0.15], 0.6)
    return room(mix(0.8, (d(1480), 0, 1), (d(1975), 0.11, 1)), 0.2)


@sound(-21)
def Match_WaterRise():
    """The sea rising each sudden-death turn: a low swell with slow bubbling."""
    reseed(5)
    x = spec(noise(N(2.2)), hi=320) * swell(2.2, 0.6, 1.4)
    for _ in range(14):
        place(x, bubble(rng_u(140, 260), rng_u(300, 520), rng_u(0.05, 0.1)), rng_u(0.2, 1.9), rng_u(0.15, 0.35))
    return room(x, 0.2)


def rng_u(a, b):
    from snaillib import rng
    return float(rng.uniform(a, b))


# --- weapons ---------------------------------------------------------------------------------------------------------

@sound(-14)
def Fire_Bazooka():
    """A cartoon launch: a chesty thump, a puff, and a rising fwoosh."""
    reseed(11)
    puff = spec(noise(N(0.5)), hi=1500) * decay(0.5, 0.15)
    return room(drive(mix(0.7, (thump(140, 60, 0.02, 0.07, 0.4), 0, 1), (puff, 0, 0.6),
                          (whoosh(0.5, 700, 3200, 0.9), 0.02, 1)), 1.8), 0.15)


@sound(-15)
def Fire_HomingMissile():
    """A launch with a lock-on: three quick beeps, then the fwoosh."""
    beep = lambda f: (osc(f, 0.05, "sine") + osc(3 * f, 0.05) * 0.2) * ar(0.05, 0.003, 1)
    x = mix(1.0, (beep(1600), 0, 0.4), (beep(1600), 0.09, 0.4), (beep(2100), 0.18, 0.5))
    place(x, Fire_Bazooka() * 0.9, 0.28)
    return x


@sound(-17)
def Fire_Throw():
    """A lob (grenade, cluster bomb, spider bomb, the spear): a quick arm swish with a small grunt-free flick."""
    reseed(12)
    return mix(0.4, (whoosh(0.28, 450, 1900, 1.0), 0, 1), (click(0.004, 1500) * 0.3, 0.0, 1))


@sound(-16)
def Fire_Dynamite():
    """Dynamite set down: a match strike, then a fizzing fuse."""
    reseed(13)
    strike = bandsweep(noise(N(0.12)), 2500, 6000, 2) * ar(0.12, 0.005, 2)
    imp = (rng_arr(N(1.2)) < 180 / SR).astype(float) * rng_arr(N(1.2))
    fizz = band(np.convolve(imp, np.exp(-tt(0.002) / 0.0006), "same"), 4500, 1.5) * 2.5
    hiss = band(noise(N(1.2)), 5000, 2) * 0.15
    return mix(1.3, (strike, 0, 1), (fade(fizz + hiss, 0.05, 0.3), 0.08, 0.8))


def rng_arr(n):
    from snaillib import rng
    return rng.random(n)


@sound(-14)
def Fire_Shotgun():
    """A fat pop and a pump: shot, then clack-clack."""
    reseed(14)
    shot = drive(pop_gun(300, 85, 0.25, 0.9) + spec(noise(N(0.25)), hi=5000) * decay(0.25, 0.08), 2.0)
    clack = lambda f: band(noise(N(0.02)), f, 2) * decay(0.02, 0.006)
    return room(mix(0.9, (shot, 0, 1), (clack(2000), 0.42, 0.5), (clack(900), 0.6, 0.6)), 0.12)


@sound(-16)
def Fire_Uzi():
    """A rattling burst of small pops (12 a second)."""
    reseed(15)
    out = np.zeros(N(0.95))
    for i in range(10):
        p = 1 + rng_u(-0.05, 0.05)
        place(out, pop_gun(380 * p, 130 * p, 0.06, 0.7), i / 12, rng_u(0.8, 1.0))
    return room(drive(out, 1.6), 0.1)


@sound(-16)
def Fire_Minigun():
    """A whirring spin-up into a fast brrrt."""
    reseed(16)
    L = 1.6
    spin = spec(osc(glide(40, 110, L, "exp", 0.2), L, "saw"), hi=900) * (0.6 + 0.4 * np.sin(2 * np.pi * 7 * tt(L)))
    out = np.zeros(N(L))
    for i in range(int(20 * 1.25)):
        p = 1 + rng_u(-0.06, 0.06)
        place(out, pop_gun(330 * p, 120 * p, 0.05, 0.6), 0.3 + i / 20, rng_u(0.75, 1.0))
    return room(drive(mix(L, (spin * ar(L, 0.05, 0.6), 0, 0.35), (out, 0, 1)), 1.5), 0.1)


@sound(-14)
def Fire_BaseballBat():
    """A swing and a hollow bonk."""
    reseed(17)
    bonk = mix(0.25, (osc(glide(240, 140, 0.25, "exp", 0.05), 0.25) * decay(0.25, 0.05), 0, 1),
               (band(noise(N(0.03)), 1200, 2) * decay(0.03, 0.01), 0, 1))
    return room(mix(0.5, (whoosh(0.18, 600, 2500, 0.6), 0, 1), (drive(bonk, 1.5), 0.13, 1)), 0.15)


@sound(-13)
def Fire_OnePunch():
    """A wind-up swish, a huge smack, and a slide-whistle as the target flies."""
    reseed(18)
    smack = drive(mix(0.4, (thump(160, 55, 0.02, 0.08, 0.4), 0, 1), (spec(noise(N(0.15)), lo=600) * decay(0.15, 0.03), 0, 1)), 2.5)
    slide = osc(glide(600, 1800, 0.5, "log") * (1 + 0.01 * np.sin(2 * np.pi * 6 * tt(0.5))), 0.5, "sine")
    return room(mix(1.2, (whoosh(0.25, 400, 2600, 0.7), 0, 1), (smack, 0.2, 1), (slide * ar(0.5, 0.02, 1), 0.35, 0.25)),
                0.15)


# --- utilities -------------------------------------------------------------------------------------------------------

@sound(-18)
def Use_Heal():
    """A heal (bandage, medkit): a sparkling glockenspiel arpeggio up."""
    x = chime(["C6", "E6", "G6", "C7"], 0.06, "glock", 1.0, [0.7, 0.8, 0.9, 1.0])
    shimmer = sum(osc(4000 * (1 + d), 1.0) for d in (-0.004, 0, 0.003, 0.006)) * swell(1.0, 0.4, 1.5) * 0.04
    return room(mix(1.3, (x, 0, 1), (shimmer, 0.1, 1)), 0.25)


@sound(-18)
def Use_Potion():
    """A potion: three glugs, then a bright rising lift."""
    reseed(19)
    glugs = mix(0.3, *[(bubble(f, f * 1.8, 0.07), i * 0.08, 0.8) for i, f in enumerate((200, 260, 330))])
    lift = chime(["E6", "G#6", "B6", "E7"], 0.05, "glock", 0.8, [0.5, 0.6, 0.7, 0.8])
    return room(mix(1.2, (glugs, 0, 1), (lift, 0.3, 0.8)), 0.2)


@sound(-20)
def Use_Parachute():
    """A canopy opening: a soft cloth fwump."""
    reseed(20)
    return mix(0.4, (band(noise(N(0.3)), 500, 1.2) * decay(0.3, 0.08, 0.01), 0, 1), (thump(90, 60, 0.03, 0.05, 0.2), 0, 0.4))


@sound(-18)
def Use_Jetpack():
    """A jetpack igniting: a pop and a burst of flame."""
    reseed(21)
    burst = spec(noise(N(0.5)), hi=1800) * decay(0.5, 0.18, 0.01)
    return mix(0.6, (pop_gun(260, 90, 0.08, 0.4), 0, 1), (burst, 0.02, 0.8))


# --- shots ----------------------------------------------------------------------------------------------------------

@sound(-11)
def Explosion_Big():
    """A big blast: deeper, longer, with a second rumble behind it."""
    return mix(2.4, (explosion(1.6, 31), 0, 1), (explosion(1.2, 32) * 0.35, 0.09, 1))


@sound(-13)
def Explosion_Small():
    """A small blast (grenade, bazooka, bomblets)."""
    return explosion(0.75, 33)


@sound(-19)
def Shot_Bounce():
    """A grenade clinking on rock: bright inharmonic ping with a little thud."""
    reseed(34)
    f0 = 1150
    ping = modal([f0, f0 * 2.76, f0 * 5.4, f0 * 8.93], [0.11, 0.06, 0.03, 0.015], [1, 0.6, 0.3, 0.15], 0.25)
    return mix(0.25, (ping, 0, 1), (thump(160, 100, 0.01, 0.03, 0.1), 0, 0.5), (click(0.003), 0, 0.3))


@sound(-20)
def Shot_Whistle():
    """A shot coming down: a falling whistle with a little wobble."""
    L = 2.2
    f = glide(1700, 650, L, "log") * (1 + 0.006 * np.sin(2 * np.pi * 7 * tt(L)))
    x = osc(f, L) + 0.15 * osc(2 * f, L)
    air = band(noise(N(L)), 2500, 2) * 0.05
    return (x + air) * ar(L, 0.15, 0.5)


# --- snails ----------------------------------------------------------------------------------------------------------

@sound(-24)
def Snail_Step():
    """A soft wet squish."""
    reseed(41)
    return mix(0.16, (band(noise(N(0.12)), 900, 1.5) * decay(0.12, 0.03, 0.008), 0, 1),
               (bubble(240, 160, 0.06, 0.4), 0.01, 1))


@sound(-19)
def Snail_Jump():
    """A springy boing up."""
    f = glide(220, 660, 0.3, "log") * (1 + 0.03 * np.sin(2 * np.pi * 16 * tt(0.3)))
    return (osc(f, 0.3, "tri") * ar(0.3, 0.005, 1.6)) * 0.8


@sound(-19)
def Snail_Land():
    """A soft plop on the ground."""
    reseed(42)
    return mix(0.25, (thump(130, 70, 0.02, 0.05, 0.25), 0, 1), (band(noise(N(0.1)), 700, 1.5) * decay(0.1, 0.03), 0, 0.5))


@sound(-24, "rms")
def Snail_Jetpack():
    """The jetpack's hum, a seamless loop: flame noise with a sputter."""
    reseed(43)
    L = 2.08
    x = spec(noise(N(L)), hi=1500) * 0.7 + band(noise(N(L)), 420, 2) * 0.6
    sput = 0.75 + 0.25 * np.sin(2 * np.pi * np.cumsum(17 + 3 * np.sin(2 * np.pi * 0.7 * tt(L))) / SR)
    return loop_seam(x * sput, 0.08)


@sound(-16)
def Snail_Hurt():
    """An 'ow!' squeak."""
    f = np.concatenate([glide(900, 1400, 0.05, "log"), glide(1400, 1000, 0.12, "log")])
    return osc(f, len(f) / SR, "tri") * ar(len(f) / SR, 0.006, 1.3) * 0.8


@sound(-16)
def Snail_ShellBreak():
    """The shell cracking: a sharp snap and chips clattering."""
    reseed(44)
    snap = band(noise(N(0.05)), 2500, 1.2) * decay(0.05, 0.01)
    crack = modal([1900, 3100, 4700], [0.05, 0.03, 0.02], [1, 0.6, 0.3], 0.15)
    return room(mix(0.7, (snap, 0, 1), (crack, 0, 0.6), (grains(0.65, 14, 2000, 6000, start=0.05), 0, 0.5)), 0.12)


@sound(-16)
def Snail_KnockedOut():
    """Knocked out: a squeaky 'bye-bye!' in snail babble, then a deflating sigh."""
    bye = gibber([1.15, 0.9], 360, 0.13, seed=3)
    sigh = osc(glide(500, 180, 0.45, "log"), 0.45, "tri") * ar(0.45, 0.02, 1.2) * 0.4
    return room(mix(0.9, (bye, 0, 1), (sigh, 0.32, 1)), 0.15)


@sound(-15)
def Snail_Splash():
    """Into the water: a deep ploonk, spray, and bubbles."""
    reseed(45)
    plunk = osc(glide(320, 80, 0.2, "exp", 0.04), 0.2) * decay(0.2, 0.08)
    spray = spec(noise(N(0.6)), hi=2200) * decay(0.6, 0.2, 0.004)
    out = mix(1.0, (plunk, 0, 1), (spray, 0, 0.6))
    for _ in range(10):
        place(out, bubble(rng_u(380, 600), rng_u(900, 1300), rng_u(0.02, 0.04), 0.5), rng_u(0.08, 0.85))
    return room(out, 0.15)


@sound(-16)
def Snail_Burn():
    """Into the lava: a hiss and crackle with a deep gloop."""
    reseed(46)
    L = 1.4
    hiss = spec(noise(N(L)), lo=3500) * decay(L, 0.5, 0.01)
    crk = (rng_arr(N(L)) < 60 / SR) * rng_arr(N(L))
    crackle = band(np.convolve(crk, np.exp(-tt(0.003) / 0.0008), "same"), 3000, 1.2) * 3 * decay(L, 0.6)
    gloop = osc(glide(90, 55, 0.4, "exp", 0.1), 0.4) * decay(0.4, 0.15)
    return mix(L, (hiss, 0, 0.6), (crackle, 0, 0.8), (gloop, 0, 0.8))


@sound(-20)
def Snail_Ghost():
    """The ghost rising: a theremin glide up with a soft airy choir, fading as the ghost does."""
    L = 2.2
    f = glide(hz(note("C5")), hz(note("G6")), L, "log") * (1 + 0.017 * np.sin(2 * np.pi * 5.5 * tt(L)))
    ther = (osc(f, L) + 0.2 * osc(2 * f, L)) * swell(L, 0.35, 1.5)
    choir = sum(band(osc(hz(note(n)) * (1 + d), L, "saw"), hz(note(n)) * 2.2, 2) for n in ("C5", "E5", "G5")
                for d in (-0.003, 0.003)) * swell(L, 0.4, 2) * 0.15
    return room(mix(L + 0.5, (ther, 0, 0.8), (choir, 0, 1)), 0.35, 1.6, 1.2)


@sound(-19)
def Liquid_Obsidian():
    """Lava meeting water: a sharp steam hiss cooling into a crackle."""
    reseed(47)
    L = 1.2
    steam = spec(noise(N(L)), lo=2500) * decay(L, 0.35, 0.005)
    crk = (rng_arr(N(L)) < 40 / SR) * rng_arr(N(L))
    crackle = band(np.convolve(crk, np.exp(-tt(0.003) / 0.0008), "same"), 2200, 1.2) * 2.5 * decay(L, 0.5)
    return mix(L, (steam, 0, 0.7), (crackle, 0.1, 0.6))


# --- build -----------------------------------------------------------------------------------------------------------

def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "out")
    names = sys.argv[2:] or list(SOUNDS)
    os.makedirs(out, exist_ok=True)
    for name in names:
        fn, target, measure = SOUNDS[name]
        # Loops keep their seam; one-shots get clean edges
        x = fn() if name in LOOPS else fade(fn(), 0.0005, 0.04)
        x = level(x, target, measure)
        wav = os.path.join(out, f"WB_{name}.wav")
        write(wav, x)
        to_ogg(wav)
        print(f"{name:20s} {len(x) / SR:5.2f} s  peak {20 * np.log10(np.max(np.abs(x)) + 1e-9):6.1f} dB")


if __name__ == "__main__":
    main()
