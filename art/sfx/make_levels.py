"""Builds Worm Battlegrounds' level music in the Worms Armageddon way: python -I make_levels.py <out> [Name ...]

Each level track is a hybrid of the level's own ambience and a quiet song that sounds like the level (the owner's
pick, 2026-11-10, after Bjorn Lynne's WA streams: "Cavern has cave sounds, water droplets, and a jungle type beat
playing quietly"). The songs are light (the owner, 2026-11-10: "most of the song is single instruments playing from
time to time, so the melodies need to chill out"): a soft pulse, a chord that breathes in now and then, and one
instrument at a time playing a bit of the level's tune, with bars of the level's ambience between. The music is warm
(rolled off over 10 kHz), and the ambience is light under it (the owner: the wind, sand and birds were too loud): each
layer's level is in dB under the music, while it sounds, and the wind is Roblox's own falling-wind recording
(ambience.py). The lobby is the game's signature, barely there, over a meadow.

Sudden death keeps each level's key and tune, faster and driving: a full kit, snare rolls, crashes, the bass and
strings running, the tune every 8 bars on one instrument and answered on another, and the level's weather busier.
Rockslide Ridge is the exception that stays epic (the owner, 2026-11-10: "current Battle_RockslideRidge is epic, keep
it as it is"): its drums, choir and echoing horn call play all the way through.

32 bars a loop on the classic Roblox samples (tracker.py), hand drums and shakers in numpy, ambience from
ambience.py, all built at the loop's length so it wraps without a seam. Writes WB_Music_<Name>.wav and .ogg.
"""

import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ambience as A  # noqa: E402
from make_themes import midi, tune  # noqa: E402
from snaillib import SR, band, level_stereo, spec, to_ogg, write_stereo  # noqa: E402
from tracker import Track  # noqa: E402

rng = np.random.default_rng(21)


def _t(seconds):
    return np.arange(int(seconds * SR)) / SR


# --- hand percussion (numpy), scaled to sit with the sample pack (its hits peak round 0.2) -------------------------------

def shaker(vel=1.0):
    d = 0.07
    x = band(rng.standard_normal(int(d * SR)), 6500, 1.4)
    env = np.minimum(_t(d) / 0.006, 1) * np.exp(-_t(d) / 0.02)
    return x * env * 0.12 * vel


def dum(f=92, vel=1.0):
    """The low, open stroke of a hand drum."""
    d = 0.45
    t = _t(d)
    fr = f * (1 + 0.5 * np.exp(-t / 0.025))
    body = np.sin(2 * np.pi * np.cumsum(fr) / SR) * np.exp(-t / 0.14)
    slap = band(rng.standard_normal(int(d * SR)), 1100, 2) * np.exp(-t / 0.004)
    return (body + slap * 0.35) * 0.27 * vel


def tek(f=420, vel=1.0):
    """The bright rim stroke."""
    d = 0.14
    t = _t(d)
    body = np.sin(2 * np.pi * f * t) * np.exp(-t / 0.025)
    click = band(rng.standard_normal(int(d * SR)), 2800, 2) * np.exp(-t / 0.006)
    return (body * 0.6 + click) * 0.32 * vel


# --- helpers -----------------------------------------------------------------------------------------------------------

def play(tr, inst, bar, text, vel, transpose=0, pan=0.0, legato=0.9, echo=None):
    """Plays a phrase from a bar; `echo` (delay beats, repeats) answers each note quieter, like a mountain echo."""
    beat = bar * 4
    for n, b in tune(text.replace("|", "")):
        if n is not None:
            tr.note(inst, beat, b * legato, n + transpose, vel, pan)
            if echo:
                delay, repeats = echo
                for r in range(1, repeats + 1):
                    tr.note(inst, beat + delay * r, b * legato * 0.8, n + transpose, vel * 0.55 ** r, -pan or 0.3 * r)
        beat += b


def pad(tr, inst, bar, notes, beats=4, vel=60, pan=0.25, attack=0.004, at=0.0):
    """Holds a chord from a bar (`at` beats into it); a slow `attack` (seconds) breathes it in."""
    for n in notes:
        tr.note(inst, bar * 4 + at, beats - 0.05, n, vel, pan, attack)


def solos(tr, score):
    """A level's phrases, one instrument at a time: rows of (bar, instrument, phrase, velocity, transpose, pan, echo)."""
    for bar, inst, text, vel, transpose, pan, echo in score:
        play(tr, inst, bar, text, vel, transpose, pan, legato=0.95, echo=echo)


def arp(tr, inst, bar, notes, vel=58, pan=-0.3, per_bar=8):
    for e in range(per_bar):
        tr.note(inst, bar * 4 + e * 4 / per_bar, 4 / per_bar * 0.9, notes[e % len(notes)], vel, pan)


def n(names):
    return [midi(x) for x in names.split()]


# --- Picnic Plains: a sunny meadow, F Lydian ---------------------------------------------------------------------------

def picnic(tr, sudden):
    F, G_F = n("F4 A4 C5"), n("G4 B4 D5")
    motif = "C5/.5 D5/.5 F5/1 A5/1 G5/1 | F5/.5 G5/.5 A5/.5 C6/.5 A5/2"
    answer = "A4/1 G4/.5 F4/.5 G4/2 | C5/1 A4/1 F4/2"
    if not sudden:
        # A soft shaker, a hand drum in the middle, a string chord breathing in now and then, a low note every 4 bars
        for bar in range(32):
            beat = bar * 4
            if 4 <= bar < 28:
                for e in range(8):
                    tr.sample(shaker(0.45 if e % 2 == 0 else 0.3), beat + e / 2, 1, 0.3)
            if 8 <= bar < 24:
                tr.sample(dum(110, 0.5), beat, 1, -0.1)
                tr.sample(tek(vel=0.3), beat + 2.5, 1, 0.2)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("sweepbass", beat, 3.5, midi("F2"), 50)
        for bar, chord in ((8, F), (20, F), (24, G_F)):
            pad(tr, "altstrings", bar, chord, beats=16, vel=40, attack=1.5)
        solos(tr, [
            (2, "harp", "C5/.5 D5/.5 F5/1 A5/2", 70, 0, -0.2, (0.75, 1)),
            (6, "piano", "G5/1 F5/.5 D5/.5 C5/2", 62, 0, 0.15, None),
            (10, "chimes", "A5/2 C6/2", 54, 0, 0.35, (0.75, 2)),
            (15, "harp", motif, 66, 0, -0.2, None),
            (20, "horn", "F4/2 G4/1 A4/1 | C5/4", 58, 0, -0.3, None),
            (25, "piano", "C5/.5 D5/.5 F5/1 A5/1 G5/1 | F5/4", 58, 0, 0.15, None),
            (29, "chimes", "C6/1 A5/3", 46, 0, 0.35, (0.75, 2)),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        ch = F if bar % 2 == 0 else G_F
        tr.drum("kick", beat, 96)
        tr.drum("kick", beat + 2, 88)
        for b in (1, 3):
            tr.drum("snare", beat + b, 84)
        for e in range(8):
            tr.drum("hat", beat + e / 2, 50 if e % 2 else 62, 0.2)
        for s in range(16):
            tr.sample(shaker(0.45), beat + s / 4, 1, 0.3)
        if bar % 8 == 0:
            tr.drum("crash", beat, 76, -0.2)
        if bar % 8 == 7:
            for s in range(8, 16):
                tr.drum("snare", beat + s / 4, 56 + s * 3)
        for b in (0, 1.5, 2, 3.5):
            tr.note("sweepbass", beat + b, 0.45, midi("F2"), 78)
        for e in range(8):
            tr.note("strings2", beat + e / 2, 0.42, (ch + [ch[0] + 12])[e % 4] - 12, 58 if e % 2 else 66, -0.3)
        pad(tr, "choir", bar, ch, vel=44)
    solos(tr, [(bar, "brass", motif, 92, 0, 0.0, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn", answer, 78, 0, -0.15, None) for bar in (4, 12, 20, 28)])


def picnic_air(seconds, sudden):
    A.reseed(31)
    return A.mix_layers(
        (A.wind(seconds, gust=0.7 if not sudden else 0.85), -14 if not sudden else -13),
        (A.birds(seconds, 10 if not sudden else 4), -16 if not sudden else -19),
        (A.crickets(seconds, 20), -25),
        (A.leaves(seconds, 6), -23),
    )


# --- Desert: a lava sea and a water oasis, D Phrygian dominant ---------------------------------------------------------

def desert(tr, sudden):
    D = midi("D2")
    drone = n("D3 A3")
    motif = "D5/.5 Eb5/.5 F#5/1 G5/2 | A5/1 G5/.5 F#5/.5 Eb5/1 D5/1"
    if not sudden:
        # A slow camel walk on a hand drum, a choir drone breathing in for 6 bars of every 8, a low note every 4 bars
        for bar in range(32):
            beat = bar * 4
            if 4 <= bar < 28:
                tr.sample(dum(vel=0.55), beat, 1, -0.1)
                tr.sample(tek(vel=0.32), beat + 2.5, 1, 0.2)
                tr.sample(tek(vel=0.24), beat + 3.5, 1, 0.25)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("dirtybass", beat, 3, D, 44)
        for bar in (0, 8, 16, 24):
            pad(tr, "tenorchoir", bar, drone, beats=24, vel=44, pan=0.0, attack=2.0)
        solos(tr, [
            (3, "guitar", "D5/.5 Eb5/.5 F#5/1 G5/2", 64, -12, 0.15, None),
            (8, "harp", "A5/1 G5/.5 F#5/.5 Eb5/1 D5/1", 62, 0, -0.2, (0.75, 1)),
            (13, "horn", "D4/2 Eb4/1 F#4/1 | D4/4", 56, 0, -0.25, None),
            (18, "guitar", motif, 62, -12, 0.15, None),
            (24, "harp", "G5/.5 F#5/.5 Eb5/1 D5/2", 56, 0, -0.2, (0.75, 2)),
            (29, "chimes", "D6/2 A5/2", 42, 0, 0.35, (0.75, 2)),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        tr.drum("kick", beat, 96)
        tr.drum("kick", beat + 2, 88)
        for b in (1, 3):
            tr.drum("snare", beat + b, 84)
        # Maqsum on the hand drums
        for b, kind in ((0, "dum"), (0.5, "tek"), (1.5, "tek"), (2, "dum"), (3, "tek"), (3.5, "tek")):
            tr.sample(dum(vel=0.8) if kind == "dum" else tek(vel=0.6), beat + b, 1, -0.1 if kind == "dum" else 0.2)
        for s in range(16):
            tr.sample(shaker(0.5), beat + s / 4, 1, 0.35)
        if bar % 8 == 0:
            tr.drum("hit", beat, 90)
        if bar % 4 == 0:
            pad(tr, "lowchoir", bar, n("D2 A2"), beats=16, vel=62, pan=0.0)
        if bar % 8 == 7:
            for s in range(8, 16):
                tr.drum("snare", beat + s / 4, 56 + s * 3)
        for e in range(8):
            tr.note("sweepbass", beat + e / 2, 0.42, D + (12 if e == 6 else 0), 82 if e % 2 == 0 else 68)
        if bar % 2 == 0:
            for p in n("D4 F#4 A4"):
                tr.note("horn2", beat, 0.3, p - 12, 60, -0.3)
    solos(tr, [(bar, "guitar", motif, 90, -12, 0.1, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn", motif, 80, -12, -0.1, None) for bar in (4, 12, 20, 28)])


def desert_air(seconds, sudden):
    A.reseed(41)
    lava = A.lava_bubbles(seconds, 40 if not sudden else 90)
    lava[:, 1] *= 0.35  # the lava sea off to the left
    drips = A.drips(seconds, 14)
    drips[:, 0] *= 0.35  # the oasis to the right
    return A.mix_layers(
        (A.wind(seconds, rate=1.0, swing=0.2, gust=0.6, hi=4500), -15 if not sudden else -14),
        (A.sand_hiss(seconds), -26 if not sudden else -23),
        (A.lava_rumble(seconds), -21 if not sudden else -18),
        (lava, -17 if not sudden else -15),
        (A.crackle(seconds, 5 if not sudden else 12), -27 if not sudden else -24),
        (drips, -18),
        (A.crickets(seconds, 30), -26),
    )


# --- Rockslide Ridge: a high rocky ridge, A Dorian -------------------------------------------------------------------

def ridge(tr, sudden):
    chords = [n("A3 C4 E4"), n("G3 B3 D4"), n("F#3 A3 D4"), n("A3 C4 E4")]
    roots = [midi(x) for x in ("A1", "G1", "F#1", "A1")]
    call = "E5/1 A5/1 D5/2"
    answer = "D5/1 G5/1 C5/1 E5/1"
    for bar in range(32):
        beat = bar * 4
        ch, root = chords[(bar // 2) % 4], roots[(bar // 2) % 4]
        if not sudden:
            if 4 <= bar < 30:
                tr.drum("bassdrum", beat, 80, -0.1)
                tr.drum("bassdrum", beat + 3.5, 62, 0.1)
            if 12 <= bar < 28:
                tr.drum("snare", beat + 2, 58)
                for b in range(4):
                    tr.drum("hat", beat + b, 40, 0.25)
            if bar % 2 == 0:
                pad(tr, "choir" if bar % 8 < 4 else "wofstrings", bar, ch, beats=8, vel=56, pan=0.0)
                if bar >= 4:
                    tr.note("lowchoir", beat, 7.6, root + 12, 58)
        else:
            for e in range(8):
                tr.drum("kick" if e % 2 == 0 else "bassdrum", beat + e / 2, 100 if e % 2 == 0 else 74)
            for b in (1, 3):
                tr.drum("snare", beat + b, 100)
            for e in range(8):
                tr.drum("hat", beat + e / 2, 52 if e % 2 else 68, 0.2)
            if bar % 4 == 0:
                tr.drum("crash", beat, 90, -0.2)
                tr.drum("hit", beat, 92)
            if bar % 8 == 7:
                for s in range(8, 16):
                    tr.drum("snare", beat + s / 4, 60 + s * 3)
            for e in range(8):
                tr.note("sweepbass", beat + e / 2, 0.42, root + 12 + (12 if e == 7 else 0), 90 if e % 2 == 0 else 76)
            for s in range(16):
                tr.note("strings2", beat + s / 4, 0.2, ch[s % 3] + (12 if s % 8 >= 4 else 0) - 12, 76 if s % 4 == 0 else 60)
            if bar % 2 == 0:
                pad(tr, "choir", bar, ch, beats=8, vel=60, pan=0.0)
    if not sudden:
        play(tr, "horn", 8, call, 88, 0, 0.0, echo=(0.75, 2))
        play(tr, "guitar", 16, answer, 74, -12, -0.2, echo=(0.75, 2))
        play(tr, "horn", 24, call, 80, -12, 0.0, echo=(0.75, 2))
    else:
        for bar in range(0, 32, 4):
            play(tr, "brass", bar, call, 102, 0, 0.0, echo=(0.75, 1))
            play(tr, "horn", bar + 2, answer, 90, 0, -0.15)


def ridge_air(seconds, sudden):
    A.reseed(51)
    return A.mix_layers(
        (A.wind_whistle(seconds), -18 if not sudden else -16),
        (A.wind(seconds, rate=1.3, swing=0.4, gust=0.8, gust_rate=0.14), -14 if not sudden else -13),
        (A.rockfalls(seconds, 2 if not sudden else 6), -15 if not sudden else -14),
        (A.leaves(seconds, 5), -26),
        (A.hawks(seconds, 1 if not sudden else 0), -17),
    )


# --- Lobby: the game's signature over a meadow, G major ---------------------------------------------------------------

LOBBY_CALL = "D5/.5 G5/.5 B5/1 A5/.5 G5/.5 | E5/1 D5/3"
LOBBY_ANSWER = "E5/.5 G5/.5 C6/1 B5/.5 A5/.5 | A5/1 F#5/1 G5/2"


def lobby(tr, sudden):
    """Barely there, but the game's own: a four-bar tune (a call rising up G major, an answer coming home) on the harp,
    later the piano, then the harp again, its first notes on the chimes between, over a string chord that breathes in
    under it and a low note. No drums: most of the loop is the meadow."""
    G, C, D, Em = n("G3 B3 D4"), n("C4 E4 G4"), n("D3 F#3 A3"), n("E3 G3 B3")
    for start, inst, vel in ((2, "harp", 64), (12, "piano", 54), (24, "harp", 56)):
        echo = (0.75, 1) if inst == "harp" else None
        play(tr, inst, start, LOBBY_CALL, vel, 0, -0.15, 0.95, echo)
        play(tr, inst, start + 2, LOBBY_ANSWER, vel - 4, 0, -0.15, 0.95, echo)
        for bar, at, chord, beats in ((start, 0, G, 8), (start + 2, 0, C, 4), (start + 3, 0, D, 2), (start + 3, 2, G, 10)):
            pad(tr, "altstrings", bar, chord, beats=beats, vel=34, pan=0.2, attack=1.2 if beats > 4 else 0.4, at=at)
        for bar, at, root, beats in ((start, 0, "G1", 7), (start + 2, 0, "C2", 3.5), (start + 3, 0, "D2", 1.8),
                                     (start + 3, 2, "G1", 6)):
            tr.note("sweepbass", bar * 4 + at, beats, midi(root), 40)
    play(tr, "chimes", 19, "D5/.5 G5/.5 B5/3", 46, 0, 0.35, 0.95, (0.75, 2))
    pad(tr, "altstrings", 18, Em, beats=16, vel=28, pan=0.2, attack=2.0)


def lobby_air(seconds, sudden):
    """A plains meadow: a light breeze, birds, crickets and the grass moving."""
    A.reseed(61)
    return A.mix_layers(
        (A.wind(seconds, gust=0.6), -17),
        (A.birds(seconds, 9), -15),
        (A.crickets(seconds, 16), -24),
        (A.leaves(seconds, 6), -22),
    )


# --- the 2026-11-16 maps: the snail tune in each map's mode ------------------------------------------------------------
# The game's own four bars (the lobby's call and answer) as scale degrees from the map's tonic, so each map plays the
# same tune in its own mode: the call rises from the fifth under the tonic to the third and settles (5 1 3 2 1 | 6 5),
# the answer climbs to the fourth and comes home through the seventh (6 1 4 3 2 | 2 7 1). "head" is the call's first
# bar on its own, "tail" the answer's last; the light songs mostly play bits like these.

MODES = {
    "major": [0, 2, 4, 5, 7, 9, 11],
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],
    "lydian": [0, 2, 4, 6, 7, 9, 11],
    "hijaz": [0, 1, 4, 5, 7, 8, 10],  # Phrygian dominant
}
THEME = {
    "call": [(-3, .5), (0, .5), (2, 1), (1, .5), (0, .5), (-2, 1), (-3, 3)],
    "answer": [(-2, .5), (0, .5), (3, 1), (2, .5), (1, .5), (1, 1), (-1, 1), (0, 2)],
    "head": [(-3, .5), (0, .5), (2, 1), (1, .5), (0, 1.5)],
    "tail": [(1, 1), (-1, 1), (0, 2)],
}
_NAMES = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]


def snail(tonic, mode, part="call"):
    """The snail tune's `part` in a key, as play() text: snail("E5", "phrygian") -> 'B4/.5 E5/.5 G5/1 ...'."""
    root, scale, out = midi(tonic), MODES[mode], []
    for d, beats in THEME[part]:
        octave, step = divmod(d, 7)
        p = root + 12 * octave + scale[step]
        out.append(f"{_NAMES[p % 12]}{p // 12 - 1}/{beats:g}")
    return " ".join(out)


def plucks(tr, score):
    """Like solos(), but short and bouncy (pizzicato, kalimba): each note held for less than half its length."""
    for bar, inst, text, vel, transpose, pan, echo in score:
        play(tr, inst, bar, text, vel, transpose, pan, legato=0.42, echo=echo)


def kit(tr, bar, kick=96, snare=84, hats=True, crash_every=8):
    """Sudden death's backbeat, as Picnic Plains' and Desert's: kick on 1 and 3, snare on 2 and 4, eighth hats, a
    crash every `crash_every` bars and a snare roll into it."""
    beat = bar * 4
    tr.drum("kick", beat, kick)
    tr.drum("kick", beat + 2, kick - 8)
    for b in (1, 3):
        tr.drum("snare", beat + b, snare)
    if hats:
        for e in range(8):
            tr.drum("hat", beat + e / 2, 50 if e % 2 else 62, 0.2)
    if bar % crash_every == 0:
        tr.drum("crash", beat, 76, -0.2)
    if bar % 8 == 7:
        for s in range(8, 16):
            tr.drum("snare", beat + s / 4, 56 + s * 3)


def tom(tr, beat, vel, high=False, pan=0.0):
    """A tom: the Wind of Fjords bass drum played faster (higher), the way a tracker tuned its drums."""
    tr.drum("bassdrum", beat, vel, pan, pitch=1.6 if high else 1.25)


# --- Volcano Isle: a smoking island, E Phrygian -----------------------------------------------------------------------

def volcano(tr, sudden):
    key = ("E5", "phrygian")
    E = midi("E2")
    if not sudden:
        # A slow heartbeat on low toms, a low marimba-ish figure on the harp now and then, the low choir growling
        for bar in range(32):
            beat = bar * 4
            if 4 <= bar < 28:
                tom(tr, beat, 64, pan=-0.1)
                tom(tr, beat + 0.75, 48, pan=-0.1)
                if bar % 2 == 1:
                    tom(tr, beat + 2.5, 40, high=True, pan=0.25)
            if 8 <= bar < 28 and bar % 8 == 0:
                tr.note("lowchoir", beat, 7.6, E + 12, 48)
            if bar in (6, 7, 18, 19):
                for b, p in ((0, "E3"), (1.5, "E3"), (2, "F3"), (3, "E3")):
                    tr.note("harp", beat + b, 0.4, midi(p), 46, 0.3)
        for bar, chord, beats in ((8, n("E3 B3"), 16), (20, n("E3 B3"), 4), (24, n("F3 C4"), 8)):
            pad(tr, "altstrings", bar, chord, beats=beats, vel=38, attack=1.5)
        plucks(tr, [
            (2, "harp", snail(*key, "call"), 72, -12, -0.2, None),
            (16, "harp", snail(*key, "answer"), 66, -12, -0.2, (0.75, 1)),
            (26, "harp", snail(*key, "head"), 62, -12, -0.2, None),
        ])
        solos(tr, [
            (7, "horn", snail(*key, "head"), 58, -12, -0.3, None),
            (11, "piano", snail(*key, "answer"), 56, -12, 0.15, None),
            (21, "horn2", snail(*key, "tail"), 54, -12, 0.2, None),
            (30, "chimes", snail(*key, "head"), 40, 0, 0.35, (0.75, 2)),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        kit(tr, bar, hats=False)
        # Pounding toms in eighths, low and high, louder on the beat
        for e in range(8):
            tom(tr, beat + e / 2, 92 if e % 2 == 0 else 70, high=e % 4 == 3, pan=-0.2 if e % 2 == 0 else 0.2)
        for e in (1, 3, 5, 7):
            tr.drum("hat", beat + e / 2, 44, 0.3)
        if bar % 8 == 0:
            tr.drum("hit", beat, 90)
        for e in range(8):
            tr.note("sweepbass", beat + e / 2, 0.42, E + (1 if e == 7 else 0), 84 if e % 2 == 0 else 70)
        # Brass stabs: the open fifth on the beat, the flat second pushing on the off-beat
        for p in n("E3 B3"):
            tr.note("brass2", beat, 0.3, p, 70, -0.25)
        if bar % 2 == 1:
            for p in n("F3 C4"):
                tr.note("brass2", beat + 2.5, 0.3, p, 66, 0.25)
        if bar % 4 == 0:
            pad(tr, "lowchoir", bar, n("E2 B2"), beats=16, vel=60, pan=0.0)
    solos(tr, [(bar, "brass", snail(*key, "call"), 94, 0, 0.0, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn", snail(*key, "answer"), 80, -12, -0.15, None) for bar in (4, 12, 20, 28)])


def volcano_air(seconds, sudden):
    A.reseed(71)
    return A.mix_layers(
        (A.lava_rumble(seconds), -19 if not sudden else -16),
        (A.lava_bubbles(seconds, 50 if not sudden else 110), -16 if not sudden else -14),
        (A.crackle(seconds, 8 if not sudden else 16), -23 if not sudden else -20),
        (A.wind(seconds, rate=0.9, swing=0.2, gust=0.5, hi=3500), -18 if not sudden else -16),
    )


# --- Echo Caverns: a cave with a pool, B minor ------------------------------------------------------------------------

def caverns(tr, sudden):
    key = ("B5", "minor")
    chords = [n("B3 D4 F#4"), n("G3 B3 D4"), n("A3 C#4 E4"), n("F#3 A3 C#4")]
    roots = [midi(x) for x in ("B1", "G1", "A1", "F#1")]
    if not sudden:
        # A deep thump far off, a low note every two bars, a choir breathing in; the glockenspiel's plinks echo away
        for bar in range(32):
            beat = bar * 4
            if 4 <= bar < 28 and bar % 2 == 0:
                tr.note("sweepbass", beat, 3.5, roots[(bar // 4) % 4], 46)
            if 8 <= bar < 24:
                tr.drum("bassdrum", beat, 46, 0.0, pitch=0.8)
        for bar, chord, beats in ((8, chords[0], 16), (20, chords[1], 8), (24, n("E3 G3 B3"), 8)):
            pad(tr, "choir", bar, chord, beats=beats, vel=36, pan=0.0, attack=2.0)
        solos(tr, [
            (2, "chimes", snail(*key, "head"), 60, 0, -0.3, (0.75, 3)),
            (6, "harp", snail(*key, "call"), 64, -12, 0.25, (0.75, 2)),
            (11, "chimes", snail(*key, "answer"), 54, 0, -0.3, (1.5, 2)),
            (16, "piano", snail(*key, "head"), 52, -12, 0.15, (0.75, 2)),
            (20, "chimes", snail(*key, "call"), 56, 0, 0.3, (0.75, 3)),
            (25, "horn2", snail(*key, "tail"), 50, -12, -0.2, (1.5, 1)),
            (29, "chimes", snail(*key, "head"), 44, 0, 0.35, (1.5, 3)),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        ch, root = chords[(bar // 2) % 4], roots[(bar // 2) % 4]
        kit(tr, bar)
        # The echoing pulse: a piano note on each beat answered a dotted eighth later, twice, across the hall
        for b in range(4):
            p = (ch + [ch[0] + 12])[b] + 12
            tr.note("piano", beat + b, 0.4, p, 58, -0.3)
            tr.note("piano", beat + b + 0.75, 0.3, p, 34, 0.35)
            tr.note("piano", beat + b + 1.5, 0.3, p, 22, -0.1)
        # The driving bass: eighths, the octave on the seventh
        for e in range(8):
            tr.note("dirtybass", beat + e / 2, 0.42, root + 12 + (12 if e == 6 else 0), 80 if e % 2 == 0 else 66)
        if bar % 2 == 0:
            pad(tr, "choir", bar, ch, beats=8, vel=46, pan=0.0)
    solos(tr, [(bar, "guitar", snail(*key, "call"), 88, -12, 0.1, (0.75, 1)) for bar in (0, 8, 16, 24)]
          + [(bar, "chimes", snail(*key, "answer"), 80, 0, -0.2, (0.75, 2)) for bar in (4, 12, 20, 28)])


def caverns_air(seconds, sudden):
    A.reseed(81)
    return A.mix_layers(
        (A.cave_drips(seconds, 18 if not sudden else 30), -15 if not sudden else -14),
        (A.cave_tone(seconds), -20 if not sudden else -19),
        (A.wind_whistle(seconds, 250, 500, 0.05), -27),
        (A.rockfalls(seconds, 1 if not sudden else 3), -20 if not sudden else -18),
    )


# --- Rolling Plains: open grassland under a big sky, D major ----------------------------------------------------------

def plains(tr, sudden):
    key = ("D5", "major")
    chords = [n("D3 A3 F#4"), n("D3 A3 F#4"), n("G3 D4 B4"), n("A3 E4 C#5")]
    roots = [midi(x) for x in ("D2", "D2", "G2", "A2")]
    if not sudden:
        # A plucked string on the beat, the chord spread wide and breathing in, a low note every 4 bars
        for bar in range(32):
            beat = bar * 4
            ch, root = chords[(bar // 2) % 4], roots[(bar // 2) % 4]
            if 4 <= bar < 28:
                tr.note("harp", beat, 0.5, root + 12, 46, -0.5)
                tr.note("harp", beat + 2, 0.5, ch[1], 38, 0.5)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("sweepbass", beat, 3.5, root, 46)
        for bar, chord, beats in ((8, chords[0], 16), (20, chords[2], 4), (24, chords[3], 8)):
            pad(tr, "altstrings", bar, chord[:2], beats=beats, vel=38, pan=-0.6, attack=1.5)
            pad(tr, "altstrings", bar, chord[2:], beats=beats, vel=36, pan=0.6, attack=1.8)
        solos(tr, [
            (2, "horn2", snail(*key, "call"), 66, 0, -0.35, None),
            (6, "harp", snail(*key, "answer"), 64, 0, 0.35, (0.75, 1)),
            (11, "horn2", snail(*key, "head"), 58, 0, 0.3, None),
            (20, "horn2", snail(*key, "answer"), 60, 0, -0.35, None),
            (25, "harp", snail(*key, "call"), 60, 0, 0.35, (0.75, 1)),
            (29, "horn2", snail(*key, "tail"), 50, 0, -0.2, None),
        ])
        plucks(tr, [(15, "guitar", snail(*key, "call"), 60, -12, -0.2, None)])
        return
    for bar in range(32):
        beat = bar * 4
        ch, root = chords[(bar // 2) % 4], roots[(bar // 2) % 4]
        kit(tr, bar)
        for s in range(16):
            tr.sample(shaker(0.5), beat + s / 4, 1, 0.35)
        # The gallop: an eighth and two sixteenths on every beat, strings and harp together, the bass under it
        for b in range(4):
            for off, length, accent in ((0, 0.45, 70), (0.5, 0.22, 56), (0.75, 0.22, 60)):
                p = ch[(b + (off > 0)) % 3]
                tr.note("strings2", beat + b + off, length, p - 12, accent, -0.35)
                tr.note("harp", beat + b + off, length, p, accent - 10, 0.35)
            tr.note("sweepbass", beat + b, 0.45, root, 82)
            tr.note("sweepbass", beat + b + 0.75, 0.22, root, 66)
        if bar % 2 == 0:
            pad(tr, "choir", bar, ch, beats=8, vel=44)
    solos(tr, [(bar, "brass", snail(*key, "call"), 92, 0, 0.0, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn2", snail(*key, "answer"), 100, 0, -0.15, None) for bar in (4, 12, 20, 28)])


def plains_air(seconds, sudden):
    A.reseed(91)
    return A.mix_layers(
        (A.wind(seconds, rate=1.2, gust=0.8 if not sudden else 0.9), -14 if not sudden else -13),
        (A.grass(seconds), -20 if not sudden else -19),
        (A.leaves(seconds, 10), -22),
        (A.birds(seconds, 9 if not sudden else 4), -16 if not sudden else -19),
        (A.hawks(seconds, 1), -19),
    )


# --- Fluffy Fallout: soft, silly, C Mixolydian ------------------------------------------------------------------------

def fluffy(tr, sudden):
    key = ("C5", "mixolydian")
    chords = [n("C3 E3 G3"), n("C3 E3 G3"), n("Bb2 D3 F3"), n("C3 E3 G3")]
    if not sudden:
        # Oom-pah on plucked strings, a tiny woodblock on the off-beats, a string chord now and then
        for bar in range(32):
            beat = bar * 4
            ch = chords[(bar // 2) % 4]
            if 4 <= bar < 28:
                tr.note("harp", beat, 0.3, ch[0], 50, -0.2)
                tr.note("harp", beat + 2, 0.3, ch[2] - 12, 42, -0.2)
                if 8 <= bar < 24:
                    tr.sample(tek(640, 0.28), beat + 1, 1, 0.3)
                    tr.sample(tek(640, 0.22), beat + 3, 1, 0.3)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("sweepbass", beat, 3, midi("C2"), 46)
        for bar, chord, beats in ((8, n("C4 E4 G4"), 16), (20, n("Bb3 D4 F4"), 4), (24, n("C4 E4 G4"), 8)):
            pad(tr, "altstrings", bar, chord, beats=beats, vel=36, attack=1.2)
        plucks(tr, [
            (2, "harp", snail(*key, "call"), 72, 0, -0.2, None),
            (14, "harp", snail(*key, "answer"), 68, 0, 0.2, None),
            (24, "harp", snail(*key, "call"), 66, 0, -0.2, (0.5, 1)),
            (28, "piano", snail(*key, "answer"), 56, 0, 0.15, None),
        ])
        solos(tr, [
            (6, "piano", snail(*key, "head"), 58, 0, 0.15, None),
            (10, "chimes", snail(*key, "tail"), 48, 0, 0.35, (0.75, 2)),
            (19, "horn", snail(*key, "call"), 56, -12, -0.3, None),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        ch = chords[(bar // 2) % 4]
        # Toy drums: a soft kick, the snare and toms played fast and high, woodblock taps
        tr.drum("kick", beat, 84)
        tr.drum("kick", beat + 2, 76)
        for b in (1, 3):
            tr.drum("snare", beat + b, 80, 0.1, pitch=1.5)
        for e in range(8):
            tr.sample(tek(700 if e % 2 else 560, 0.45 if e % 2 else 0.6), beat + e / 2, 1, 0.3)
        tr.drum("bassdrum", beat + 3.5, 60, -0.2, pitch=1.9)
        if bar % 8 == 0:
            tr.drum("crash", beat, 70, -0.2)
        if bar % 8 == 7:
            for s in range(8, 16):
                tr.drum("snare", beat + s / 4, 50 + s * 3, 0.1, pitch=1.5)
        # Fast pizzicato: the chord in sixteenths, up and down
        arpn = ch + [ch[0] + 12, ch[1] + 12, ch[0] + 12] + ch[2:0:-1]
        for s in range(16):
            tr.note("harp", beat + s / 4, 0.18, arpn[s % 8] + 12, 62 if s % 4 == 0 else 50, 0.35 if s % 2 else -0.35)
        for b in (0, 1, 2, 3):
            tr.note("sweepbass", beat + b, 0.3, ch[0] - 12 + (7 if b % 2 else 0), 78)
    solos(tr, [(bar, "brass", snail(*key, "call"), 88, 0, 0.0, None) for bar in (0, 8, 16, 24)])
    plucks(tr, [(bar, "piano", snail(*key, "answer"), 98, 0, -0.15, None) for bar in (4, 12, 20, 28)])


def fluffy_air(seconds, sudden):
    A.reseed(101)
    return A.mix_layers(
        (A.wind(seconds, rate=1.0, swing=0.2, gust=0.5), -18 if not sudden else -17),
        (A.crickets(seconds, 30), -21 if not sudden else -23),
        (A.leaves(seconds, 4), -26),
        (A.birds(seconds, 3), -22),
    )


# --- Mirage Mesa: heat haze over a mesa and its oasis, A Hijaz --------------------------------------------------------

def mirage(tr, sudden):
    key = ("A5", "hijaz")
    if not sudden:
        # A lazy frame drum (dum . . dum, a tek every other bar), a choir haze breathing in; a kalimba (the harp,
        # plucked short) plays the tune slowly, its notes hanging in the heat
        for bar in range(32):
            beat = bar * 4
            if 6 <= bar < 26:
                tr.sample(dum(80, 0.5), beat, 1, -0.1)
                tr.sample(dum(80, 0.3), beat + 1.5, 1, -0.1)
                if bar % 2 == 1:
                    tr.sample(tek(380, 0.26), beat + 3, 1, 0.25)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("sweepbass", beat, 3.5, midi("A1"), 44)
        for bar, chord, beats in ((4, n("A4 E5"), 8), (14, n("A4 E5"), 8), (20, n("Bb4 D5"), 4), (24, n("A4 E5"), 8)):
            pad(tr, "choir", bar, chord, beats=beats, vel=34, pan=0.0, attack=3.0)
        plucks(tr, [
            (2, "harp", snail(*key, "call"), 70, 0, -0.25, (1.5, 2)),
            (16, "harp", snail(*key, "answer"), 64, 0, 0.25, (1.5, 2)),
            (25, "harp", snail(*key, "call"), 60, 0, -0.25, (0.75, 2)),
        ])
        solos(tr, [
            (7, "chimes", snail(*key, "head"), 48, 0, 0.35, (0.75, 3)),
            (11, "horn2", snail(*key, "answer"), 56, -12, -0.2, None),
            (21, "piano", snail(*key, "head"), 52, -12, 0.15, None),
            (30, "chimes", snail(*key, "tail"), 42, 0, 0.35, (1.5, 2)),
        ])
        return
    arpn = n("A3 C#4 E4 G4 Bb4 G4 E4 C#4")
    for bar in range(32):
        beat = bar * 4
        phase = bar % 8
        kit(tr, bar, hats=phase >= 4)
        # The hand drums speed up through every 8 bars: quarters, eighths, the maqsum with sixteenths, then a roll
        if phase < 2:
            hits = [(b, "dum" if b % 2 == 0 else "tek", 0.7) for b in range(4)]
        elif phase < 4:
            hits = [(e / 2, "dum" if e in (0, 3, 4) else "tek", 0.65) for e in range(8)]
        elif phase < 6:
            hits = [(b, k, 0.75) for b, k in ((0, "dum"), (0.5, "tek"), (1.5, "tek"), (2, "dum"), (3, "tek"),
                                             (3.5, "tek"))]
            hits += [(s / 4, "tek", 0.35) for s in range(16) if s % 2]
        else:
            hits = [(s / 4, "dum" if s % 4 == 0 else "tek", 0.45 + 0.03 * s + 0.1 * (phase - 6)) for s in range(16)]
        for b, kind, v in hits:
            tr.sample(dum(80, v) if kind == "dum" else tek(400, v * 0.85), beat + b, 1, -0.1 if kind == "dum" else 0.2)
        for s in range(16):
            tr.sample(shaker(0.45), beat + s / 4, 1, 0.35)
        for e in range(8):
            tr.note("harp", beat + e / 2, 0.3, arpn[e], 56, 0.3 if e % 2 else -0.3)
            tr.note("sweepbass", beat + e / 2, 0.42, midi("A1") + (1 if e == 7 else 0), 82 if e % 2 == 0 else 68)
        if bar % 4 == 0:
            pad(tr, "lowchoir", bar, n("A1 E2"), beats=16, vel=60, pan=0.0)
    solos(tr, [(bar, "brass", snail(*key, "call"), 92, -12, 0.0, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn", snail(*key, "answer"), 80, -12, -0.15, None) for bar in (4, 12, 20, 28)])


def mirage_air(seconds, sudden):
    A.reseed(111)
    return A.mix_layers(
        (A.sand_hiss(seconds, 0.1), -22 if not sudden else -20),
        (A.wind(seconds, rate=0.9, swing=0.25, gust=0.55, hi=4000), -16 if not sudden else -15),
        (A.hawks(seconds, 2 if not sudden else 1), -16),
        (A.crickets(seconds, 10), -28),
    )


# --- Lakeside Showdown: a calm lake shore, G Lydian -------------------------------------------------------------------

def lakeside(tr, sudden):
    key = ("G5", "lydian")
    chords = [n("G2 D3 B3 D4"), n("G2 D3 B3 D4"), n("A2 E3 C#4 E4"), n("G2 D3 B3 D4")]
    if not sudden:
        # A gentle harp under it all, a chord on each beat; a flute (the soft horn) plays the tune over it
        for bar in range(32):
            beat = bar * 4
            ch = chords[(bar // 2) % 4]
            if 4 <= bar < 28:
                for b in range(4):
                    tr.note("harp", beat + b, 0.9, ch[b], 44 if b == 0 else 36, 0.3)
            if 8 <= bar < 28 and bar % 4 == 0:
                tr.note("sweepbass", beat, 3.5, ch[0] - 12, 44)
        for bar, chord, beats in ((8, n("G3 B3 D4"), 16), (20, n("A3 C#4 E4"), 4), (24, n("G3 B3 D4"), 8)):
            pad(tr, "altstrings", bar, chord, beats=beats, vel=34, pan=-0.2, attack=1.5)
        solos(tr, [
            (2, "horn2", snail(*key, "call"), 68, 0, -0.2, None),
            (6, "horn2", snail(*key, "answer"), 64, 0, -0.2, None),
            (11, "chimes", snail(*key, "head"), 46, 0, 0.35, (0.75, 2)),
            (15, "horn2", snail(*key, "call"), 62, 0, -0.2, None),
            (20, "piano", snail(*key, "answer"), 54, -12, 0.15, None),
            (24, "horn2", snail(*key, "head"), 60, 0, -0.2, None),
            (29, "horn2", snail(*key, "tail"), 52, 0, -0.2, None),
        ])
        return
    for bar in range(32):
        beat = bar * 4
        ch = chords[(bar // 2) % 4]
        kit(tr, bar)
        tr.drum("bassdrum", beat + 1.5, 70, -0.1)
        tr.drum("bassdrum", beat + 3.5, 64, -0.1)
        # The driving harp: the chord in sixteenths, rising
        for s in range(16):
            tr.note("harp", beat + s / 4, 0.2, ch[s % 4] + 12, 64 if s % 4 == 0 else 52, 0.3 if s % 2 else -0.3)
        for e in range(8):
            tr.note("sweepbass", beat + e / 2, 0.42, ch[0] + (12 if e == 6 else 0), 82 if e % 2 == 0 else 68)
        if bar % 2 == 0:
            pad(tr, "choir", bar, ch[1:], beats=8, vel=44)
    solos(tr, [(bar, "brass", snail(*key, "call"), 90, 0, 0.0, None) for bar in (0, 8, 16, 24)]
          + [(bar, "horn2", snail(*key, "answer"), 100, 0, -0.15, None) for bar in (4, 12, 20, 28)])


def lakeside_air(seconds, sudden):
    A.reseed(121)
    return A.mix_layers(
        (A.lapping(seconds), -15 if not sudden else -14),
        (A.birds(seconds, 10 if not sudden else 4), -16 if not sudden else -19),
        (A.leaves(seconds, 5), -24),
        (A.wind(seconds, gust=0.6), -19 if not sudden else -17),
    )


# --- build -------------------------------------------------------------------------------------------------------------

LEVELS = {
    # name: (music builder, ambience builder, BPM, sudden-death BPM, hall wetness, sudden death's hall wetness)
    "Lobby": (lobby, lobby_air, 84, None, 0.32, None),
    "PicnicPlains": (picnic, picnic_air, 104, 132, 0.3, 0.22),
    "Desert": (desert, desert_air, 96, 124, 0.3, 0.24),
    "RockslideRidge": (ridge, ridge_air, 92, 120, 0.34, 0.34),
    # 2026-11-16: the new maps, named by their MapId (their files map to SoundsList's Music_<MapId>)
    "VolcanoIsle": (volcano, volcano_air, 88, 118, 0.3, 0.24),
    "EchoCaverns": (caverns, caverns_air, 80, 120, 0.42, 0.34),
    "RollingPlains": (plains, plains_air, 108, 138, 0.3, 0.22),
    "FluffyFallout": (fluffy, fluffy_air, 112, 140, 0.28, 0.22),
    "MirageMesa": (mirage, mirage_air, 76, 112, 0.36, 0.28),
    "LakesideShowdown": (lakeside, lakeside_air, 96, 126, 0.32, 0.24),
}
NEW_MAPS = ("VolcanoIsle", "EchoCaverns", "RollingPlains", "FluffyFallout", "MirageMesa", "LakesideShowdown")
# The light songs: set by how loud their phrases play (their silences left out), so each plays as loud as a busy song
# and the loop is quieter overall, as WA's are. The busy ones (sudden death, Rockslide Ridge) are set by their RMS.
SPARSE = {"Lobby", "PicnicPlains", "Desert", *NEW_MAPS}


def piece(level, sudden=False):
    build, air, bpm, sd_bpm, wet, sd_wet = LEVELS[level]
    tr = Track(sd_bpm if sudden else bpm, 32)
    build(tr, sudden)
    left, right = tr.render(sd_wet if sudden else wet)
    # Warm, as the WA streams: roll the music off over 10 kHz
    music = np.stack([spec(left, hi=10000, order=2), spec(right, hi=10000, order=2)], axis=1)
    sparse = level in SPARSE and not sudden
    music /= A.sounding_rms(music) if sparse else np.sqrt(np.mean(music ** 2)) + 1e-12
    # The ambience's levels are dB under the music (0 dB here)
    mix = music + air(len(left) / SR, sudden)[: len(left)]
    target = -18 if sudden else (-23 if level == "Lobby" else -20)
    if not sparse:
        return level_stereo(mix[:, 0], mix[:, 1], target)
    g = 10 ** (target / 20)
    return np.tanh(mix[:, 0] * g / 0.89) * 0.89, np.tanh(mix[:, 1] * g / 0.89) * 0.89


PIECES = {"Lobby": lambda: piece("Lobby")}
for lv in ("PicnicPlains", "Desert", "RockslideRidge"):
    PIECES[f"Battle_{lv}"] = (lambda lv=lv: piece(lv))
    PIECES[f"Battle_{lv}_SuddenDeath"] = (lambda lv=lv: piece(lv, True))
# The new maps' pieces carry the SoundsList name itself: WB_Music_<MapId>.wav and WB_Music_<MapId>_SuddenDeath.wav
for lv in NEW_MAPS:
    PIECES[lv] = (lambda lv=lv: piece(lv))
    PIECES[f"{lv}_SuddenDeath"] = (lambda lv=lv: piece(lv, True))


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "out", "levels")
    os.makedirs(out, exist_ok=True)
    for name in sys.argv[2:] or list(PIECES):
        left, right = PIECES[name]()
        wav = os.path.join(out, f"WB_Music_{name}.wav")
        write_stereo(wav, left, right)
        to_ogg(wav)
        print(f"{name:36s} {len(left) / SR:6.1f} s  peak {20 * np.log10(np.max(np.abs(left)) + 1e-9):5.1f} dB")


if __name__ == "__main__":
    main()
