"""Builds Worm Battlegrounds' music in the classic 2005-2008 Roblox sound: python -I make_music.py <out> [Name ...]

The battle loops and stings play through the Great Strategy soundfont (BadliZ's 2005 tracker instruments: Brass, the
Tr2 trumpet, Violin strings, Digo Piano, the Tomb drum, orchestra hits and his kit), the lobby through the
StealthPilot soundfont (the era's synth lead, bass and square), both NotRoblox's CC BY rips (README.md → Credits).

One whistleable 4-bar theme (the snails' motif) runs through every piece in different clothes and modes, as Worms
W.M.D does: the lobby relaxed in F major, each map's battle loop in its own mode and band, a sudden-death version of
each loop (the same length and tempo, so the game can crossfade into it), and the win and lose stings.

Loops render three times back to back and keep the middle pass, so the tails of the end ring into the start and the
loop has no seam. Writes WB_Music_<Name>.wav and .ogg into <out>.
"""

import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from snaillib import CLASSIC, SR, Song, level_stereo, render_midi, to_ogg, write_stereo  # noqa: E402

# --- harmony ---------------------------------------------------------------------------------------------------------

SCALES = {
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "major": [0, 2, 4, 5, 7, 9, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
}


class Key:
    def __init__(self, root_midi, mode):
        self.root = root_midi
        self.mode = mode
        self.scale = SCALES[mode]

    def deg(self, d, sharp=False):
        """A scale degree (0 = the root, 7 = an octave up) as a MIDI note; `sharp` raises a minor seventh (the
        leading tone) in the minor modes."""
        octave, step = divmod(d, 7)
        pitch = self.root + 12 * octave + self.scale[step]
        if sharp and self.mode != "major" and step == 6:
            pitch += 1
        return pitch

    def triad(self, d, sharp_third=False):
        return [self.deg(d), self.deg(d + 2, sharp_third), self.deg(d + 4)]


# The motif: (degree, beats, sharp). Degree 7 is the octave over the key's root.
MOTIF = [
    [(7, 1.5), (4, 0.5), (7, 0.5), (8, 0.5), (9, 1)],
    [(8, 0.75), (7, 0.25), (6, 0.5), (4, 0.5), (5, 1), (4, 1)],
    [(7, 0.5), (9, 0.5), (11, 1), (10, 0.5), (9, 0.5), (8, 1)],
    [(9, 0.5), (8, 0.5), (7, 0.5), (6, 0.5, True), (7, 2)],
]
ANSWER = [
    [(11, 1.5), (9, 0.5), (11, 0.5), (12, 0.5), (11, 1)],
    [(10, 0.75), (9, 0.25), (8, 0.5), (7, 0.5), (8, 1), (6, 1, True)],
    [(9, 0.5), (10, 0.5), (11, 0.5), (12, 0.5), (11, 1), (9, 1)],
    [(8, 1), (6, 0.5, True), (8, 0.5), (7, 2)],
]

# Eight-bar progressions as (degree, sharp third) per bar; a bar given as a list splits in two
PROGRESSIONS = {
    "minor": [(0, 0), (5, 0), (2, 0), (4, 1), (0, 0), (3, 0), [(5, 0), (4, 1)], (0, 0)],
    "major": [(0, 0), (3, 0), (5, 0), (4, 0), (0, 0), (3, 0), [(1, 0), (4, 0)], (0, 0)],
    "phrygian": [(0, 0), (1, 0), (0, 0), (6, 0), (0, 0), (1, 0), [(5, 0), (4, 1)], (0, 0)],
}


def chords(key, bars):
    """The (start beat, length, degree, sharp third) of each chord over `bars` bars."""
    prog = PROGRESSIONS[key.mode]
    out = []
    for bar in range(bars):
        c = prog[bar % 8]
        if isinstance(c, list):
            out.append((bar * 4, 2, c[0][0], c[0][1]))
            out.append((bar * 4 + 2, 2, c[1][0], c[1][1]))
        else:
            out.append((bar * 4, 4, c[0], c[1]))
    return out


def phrase(song, ch, key, at, bars_of, vel, octave=0, legato=0.92, every=None):
    """Plays motif bars from `at` (beats), one bar of notes per bar; `every` keeps only some notes."""
    for b, bar in enumerate(bars_of):
        t = at + b * 4
        for i, n in enumerate(bar):
            d, dur = n[0], n[1]
            sharp = len(n) > 2 and n[2]
            if every is None or i % every == 0:
                song.note(ch, t, dur * legato, key.deg(d, sharp) + 12 * octave, vel)
            t += dur


# --- channels --------------------------------------------------------------------------------------------------------

DRUMS = 9


def setup(song, programs, volumes, pans=None):
    for ch, prog in programs.items():
        song.program(ch, prog, bank=None if ch == DRUMS else 0)
        song.cc(ch, 7, volumes.get(ch, 90))
        song.cc(ch, 10, (pans or {}).get(ch, 64))
        song.cc(ch, 91, 50)


# --- pieces ----------------------------------------------------------------------------------------------------------

def battle(song, key, offset, style, bars=32):
    """One pass of a battle loop at `offset` beats: A groove (1-8), B the motif (9-16), C a light break (17-24), D the
    full band (25-32), turning back into A."""
    ch_list = chords(key, bars)
    lead, answer, bass, harm, perc_tuned, pad = 0, 1, 2, 3, 4, 5

    for start, length, d, sharp in ch_list:
        t = offset + start
        bar = int(start // 4)
        section = bar // 8
        root = key.deg(d) - 24
        fifth = key.deg(d + 4) - 24
        tri = key.triad(d, bool(sharp))

        # Bass: the style's ostinato, light in the break
        if style == "march":
            for beat in range(0, int(length), 2):
                song.note(bass, t + beat, 0.45, root if beat % 4 == 0 else fifth, 96 if section != 2 else 70)
        elif style == "desert":
            for beat in (0, 1.5, 2.5) if length == 4 else (0, 1.5):
                song.note(bass, t + beat, 0.4, root, 92 if section != 2 else 66)
        else:
            for e in range(int(length * 2)):
                song.note(bass, t + e / 2, 0.3, root if e % 4 != 3 else fifth, 88 if e % 2 == 0 else 70)

        # Harmony: off-beat chords (march), sustained stabs (desert), tremolo pad (ridge)
        if section != 2:
            if style == "march":
                for beat in range(1, int(length), 2):
                    for p in tri:
                        song.note(harm, t + beat, 0.35, p, 62)
            elif style == "desert":
                for p in tri:
                    song.note(harm, t, 0.5, p - 12, 84)
            else:
                for p in tri:
                    song.note(harm, t, length * 0.98, p - 12, 58)

        # Pads in the full band
        if section == 3:
            for p in tri:
                song.note(pad, t, length * 0.95, p, 64)

    # Melody: B the motif and its answer; C a light echo; D the motif loud with the answer under it
    phrase(song, lead, key, offset + 32, MOTIF + ANSWER, 92)
    phrase(song, perc_tuned, key, offset + 64, MOTIF, 70, octave=1, every=2)
    phrase(song, answer, key, offset + 80, ANSWER, 64, octave=0, legato=0.6)
    phrase(song, lead, key, offset + 96, MOTIF + ANSWER, 104)
    phrase(song, answer, key, offset + 96, MOTIF + ANSWER, 70, octave=-1)

    # Percussion
    for bar in range(bars):
        t = offset + bar * 4
        section = bar // 8
        if style == "march":
            for beat in range(4):
                song.note(DRUMS, t + beat, 0.2, 38, 70 if beat % 2 else 82)
                if section >= 1:
                    song.note(DRUMS, t + beat + 0.5, 0.1, 38, 46)
            song.note(DRUMS, t, 0.3, 36, 84)
        elif style == "desert":
            for beat, n, v in ((0, 41, 96), (1.5, 43, 70), (2, 45, 84), (3, 43, 66), (3.5, 41, 60)):
                song.note(DRUMS, t + beat, 0.3, n, v if section != 2 else v - 20)
            if section >= 1:
                for e in range(8):
                    song.note(DRUMS, t + e / 2, 0.1, 54, 50 if e % 2 else 62)
        else:
            song.note(DRUMS, t, 0.3, 36, 92)
            song.note(DRUMS, t + 2, 0.3, 36, 80)
            for beat in (1, 3):
                song.note(DRUMS, t + beat, 0.2, 38, 84 if section != 2 else 60)
        if bar % 8 == 0 and section in (1, 3):
            song.note(DRUMS, t, 1.5, 49, 90)


def sudden_death_layer(song, key, offset, bars=32):
    """The sudden-death layer: timpani eighths, a choir's minor-second rub, low trombone stabs, a bell every 4 bars."""
    timp, choir, trom, bell = 10, 11, 12, 13
    for start, length, d, _sharp in chords(key, bars):
        t = offset + start
        for e in range(int(length * 2)):
            song.note(timp, t + e / 2, 0.4, key.deg(d) - 24 if e % 4 != 2 else key.deg(d + 4) - 24, 80 if e % 2 == 0 else 60)
        song.note(trom, t, 0.6, key.deg(d) - 24, 92)
    for bar in range(0, bars, 4):
        t = offset + bar * 4
        song.note(choir, t, 15.5, key.deg(7), 56)
        song.note(choir, t, 15.5, key.deg(7) + 1, 44)
        song.note(bell, t, 4, key.deg(7) - 12, 80)


STYLES = {
    # name: (bpm, key, style, programs {channel: GM program}, volumes)
    # Great Strategy font: 56 Tr2 trumpet, 60 Brass, 40/48 Violin strings, 0/32 Digo Piano, 47 Tomb drum, 55 orchestra hit
    "PicnicPlains": (108, Key(62, "major"), "march",
                     {0: 56, 1: 40, 2: 60, 3: 0, 4: 0, 5: 48, DRUMS: 0},
                     {0: 100, 1: 80, 2: 96, 3: 76, 4: 70, 5: 72, DRUMS: 90}),
    "Desert": (100, Key(62, "phrygian"), "desert",
               {0: 40, 1: 56, 2: 32, 3: 60, 4: 47, 5: 48, DRUMS: 0},
               {0: 100, 1: 80, 2: 100, 3: 86, 4: 86, 5: 70, DRUMS: 92}),
    "RockslideRidge": (112, Key(62, "minor"), "ridge",
                       {0: 60, 1: 56, 2: 60, 3: 44, 4: 47, 5: 61, DRUMS: 0},
                       {0: 102, 1: 86, 2: 98, 3: 76, 4: 92, 5: 74, DRUMS: 92}),
}
SD_PROGRAMS = {10: 47, 11: 48, 12: 54, 13: 55}
SD_VOLUMES = {10: 96, 11: 74, 12: 88, 13: 84}


def loop_piece(name, bpm, build, bars, out, font="GreatStrategy"):
    """Renders a loop three times over through a classic font and keeps the middle pass, levelled to -20 dB RMS."""
    song = Song(bpm, seed=sum(map(ord, name)))
    for p in range(3):
        build(song, p * bars * 4)
    mid = os.path.join(out, f"_{name}.mid")
    song.write(mid)
    left, right = render_midi(mid, os.path.join(out, f"_{name}_raw.wav"), soundfont=CLASSIC[font])
    length = int(round(bars * 4 * 60 / bpm * SR))

    # The loop's head fades in from what really follows its end (the third pass), so the wrap never clicks
    k = int(0.03 * SR)
    ramp = np.linspace(0, 1, k)
    loops = []
    for x in (left, right):
        y = x[length:2 * length].copy()
        y[:k] = x[length:length + k] * ramp + x[2 * length:2 * length + k] * (1 - ramp)
        loops.append(y)
    return level_stereo(loops[0], loops[1], -20)


def battle_track(map_name, sudden, out):
    bpm, key, style, programs, volumes = STYLES[map_name]

    def build(song, offset):
        if offset == 0:
            setup(song, programs, volumes, {0: 60, 1: 74, 3: 50, 4: 80, 5: 64})
            if sudden:
                setup(song, SD_PROGRAMS, SD_VOLUMES, {11: 64, 12: 54, 13: 72})
        battle(song, key, offset, style)
        if sudden:
            sudden_death_layer(song, key, offset)

    return loop_piece(f"{map_name}{'_SD' if sudden else ''}", bpm, build, 32, out)


def lobby(out):
    key = Key(65, "major")

    def build(song, offset):
        # StealthPilot font: 1 Synth 1 (the tune), 0 Bass, 3 Synth 2 (chords), 5 Square (sparkles)
        if offset == 0:
            setup(song, {0: 1, 1: 0, 2: 3, 3: 5, DRUMS: 0}, {0: 92, 1: 96, 2: 74, 3: 60, DRUMS: 76},
                  {0: 58, 1: 64, 2: 50, 3: 80})
        for start, length, d, sharp in chords(key, 24):
            t = offset + start
            tri = key.triad(d, bool(sharp))
            walk = [key.deg(d) - 24, key.deg(d + 2) - 24, key.deg(d + 4) - 24, key.deg(d + 5) - 24]
            for beat in range(int(length)):
                song.note(1, t + beat, 0.8, walk[beat % 4], 76)
            for beat in (1, 3) if length == 4 else (1,):
                for p in tri:
                    song.note(2, t + beat, 0.3, p, 58)
        for bar in range(24):
            t = offset + bar * 4
            song.note(DRUMS, t, 0.2, 36, 80)
            song.note(DRUMS, t + 2.5, 0.2, 36, 64)
            song.note(DRUMS, t + 1, 0.2, 38, 60)
            song.note(DRUMS, t + 3, 0.2, 38, 66)
            for e in range(8):
                song.note(DRUMS, t + e / 2, 0.1, 42, 42 if e % 2 else 52)
            if bar % 2 == 1:
                song.note(3, t + 3.5, 0.5, key.deg(14 + bar % 5), 48)
        phrase(song, 0, key, offset + 32, MOTIF + ANSWER, 78, octave=-1, legato=0.85)
        phrase(song, 0, key, offset + 64, MOTIF, 70, octave=-1, legato=0.7)

    return loop_piece("Lobby", 90, build, 24, out, "StealthPilot")


def sting(name, bpm, build, seconds, target, out):
    song = Song(bpm, seed=7)
    build(song)
    mid = os.path.join(out, f"_{name}.mid")
    song.write(mid)
    left, right = render_midi(mid, os.path.join(out, f"_{name}_raw.wav"), soundfont=CLASSIC["GreatStrategy"])
    n = int(seconds * SR)
    left, right = left[:n], right[:n]
    fade = np.linspace(1, 0, int(0.4 * SR))
    left[-len(fade):] *= fade
    right[-len(fade):] *= fade
    return level_stereo(left, right, target, "loudest")


def win(out):
    key = Key(62, "major")

    def build(song):
        setup(song, {0: 60, 1: 56, 2: 55, 3: 47, DRUMS: 0}, {0: 104, 1: 104, 2: 90, 3: 100, DRUMS: 100})
        for i in range(16):
            song.note(DRUMS, i * 0.25, 0.2, 38, 50 + i * 4, jitter=0, vjit=0)
        for i, d in enumerate((4, 5, 6)):
            song.note(1, 4 + i / 3, 0.3, key.deg(d), 100)
        for p in key.triad(0) + [key.deg(7)]:
            song.note(0, 5, 5, p, 108)
        song.note(1, 5, 5, key.deg(9) , 110)
        song.note(2, 5, 3, key.deg(7), 100)
        for i in range(24):
            song.note(3, 5 + i * 0.125, 0.12, key.deg(0) - 24, 70 + i)
        song.note(DRUMS, 5, 3, 49, 110)
        song.note(DRUMS, 5, 1, 36, 110)

    return sting("Win", 100, build, 6.0, -15, out)


def lose(out):
    def build(song):
        setup(song, {0: 56, 1: 47}, {0: 104, 1: 86})
        song.cc(0, 101, 0)
        song.cc(0, 100, 0)
        song.cc(0, 6, 2)
        for i, n in enumerate((58, 57, 56)):
            song.note(0, i * 0.75, 0.7, n, 96, jitter=0)
        song.note(0, 2.25, 3, 55, 100, jitter=0)
        for k in range(24):
            song.bend(0, 0.4 * np.sin(k / 24 * 2 * np.pi * 6 * 2.5), 2.5 + k * 0.1)
        song.bend(0, 0, 5.0)
        song.note(1, 2.25, 1, 38, 70, jitter=0)

    return sting("Lose", 80, build, 4.5, -16, out)


PIECES = {
    "Lobby": lobby,
    "Battle_PicnicPlains": lambda out: battle_track("PicnicPlains", False, out),
    "Battle_PicnicPlains_SuddenDeath": lambda out: battle_track("PicnicPlains", True, out),
    "Battle_Desert": lambda out: battle_track("Desert", False, out),
    "Battle_Desert_SuddenDeath": lambda out: battle_track("Desert", True, out),
    "Battle_RockslideRidge": lambda out: battle_track("RockslideRidge", False, out),
    "Battle_RockslideRidge_SuddenDeath": lambda out: battle_track("RockslideRidge", True, out),
    "Win": win,
    "Lose": lose,
}


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "out")
    os.makedirs(out, exist_ok=True)
    for name in sys.argv[2:] or list(PIECES):
        left, right = PIECES[name](out)
        wav = os.path.join(out, f"WB_Music_{name}.wav")
        write_stereo(wav, left, right)
        to_ogg(wav)
        print(f"{name:36s} {len(left) / SR:6.1f} s")


if __name__ == "__main__":
    main()
