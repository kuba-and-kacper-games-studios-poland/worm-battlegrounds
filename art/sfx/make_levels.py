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


# --- build -------------------------------------------------------------------------------------------------------------

LEVELS = {
    # name: (music builder, ambience builder, BPM, sudden-death BPM, hall wetness, sudden death's hall wetness)
    "Lobby": (lobby, lobby_air, 84, None, 0.32, None),
    "PicnicPlains": (picnic, picnic_air, 104, 132, 0.3, 0.22),
    "Desert": (desert, desert_air, 96, 124, 0.3, 0.24),
    "RockslideRidge": (ridge, ridge_air, 92, 120, 0.34, 0.34),
}
# The light songs: set by how loud their phrases play (their silences left out), so each plays as loud as a busy song
# and the loop is quieter overall, as WA's are. The busy ones (sudden death, Rockslide Ridge) are set by their RMS.
SPARSE = {"Lobby", "PicnicPlains", "Desert"}


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
