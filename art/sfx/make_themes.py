"""Builds Worm Battlegrounds' themes on the classic Roblox samples (tracker.py): python -I make_themes.py <out> [Name ...]

Every theme has its own tune. A battle loop runs: intro groove (4 bars), the A tune (8), the B tune (8), the A tune with
the full band (8), a turnaround (4). Its sudden-death version plays the same tunes about 15 % faster over a heavier
band, as Great Strategy drives: a kick on every beat, snare rolls, an orchestra hit every bar, crashes, and the bass
and strings running in sixteenths. Writes WB_Music_<Name>.wav and .ogg into <out>.
"""

import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from snaillib import SR, level_stereo, to_ogg, write_stereo  # noqa: E402
from tracker import Track  # noqa: E402

NOTE = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8,
        "A": 9, "A#": 10, "Bb": 10, "B": 11}


def midi(name):
    return 12 * (int(name[-1]) + 1) + NOTE[name[:-1]]


def tune(text):
    """'B4/.5 D5/.5 R/1 ...' -> [(midi or None, beats)]"""
    out = []
    for tok in text.split():
        n, b = tok.split("/")
        out.append((None if n == "R" else midi(n), float(b)))
    return out


def chord(name, octave=4):
    """'G', 'Em', 'D7', 'Bdim' -> MIDI notes of the triad (and seventh), rooted in an octave."""
    root = name[:2] if len(name) > 1 and name[1] in "#b" else name[:1]
    quality = name[len(root):]
    r = 12 * (octave + 1) + NOTE[root]
    third = 3 if quality.startswith("m") and not quality.startswith("maj") or quality == "dim" else 4
    fifth = 6 if quality == "dim" else 7
    notes = [r, r + third, r + fifth]
    if "7" in quality:
        notes.append(r + 10)
    return notes


# --- the themes --------------------------------------------------------------------------------------------------------

THEMES = {
    "PicnicPlains": {
        "bpm": 132, "drums": "galop",
        "chords_a": ["G", "G", "C", "D", "G", "Em", "Am", "D7"],
        "chords_b": ["C", "G", "Em", "D", "Am", "G", "C", "D7"],
        "a": "B4/.5 D5/.5 G5/1 F#5/.5 G5/.5 A5/1 | B5/1.5 A5/.5 G5/1 D5/1 | E5/.5 F#5/.5 G5/.5 E5/.5 D5/1 B4/1 | "
             "C5/.5 D5/.5 E5/.5 C5/.5 A4/2 | B4/.5 D5/.5 G5/1 F#5/.5 G5/.5 A5/1 | B5/1 C6/.5 B5/.5 A5/1 G5/1 | "
             "E5/.5 G5/.5 F#5/.5 A5/.5 G5/1 F#5/1 | G5/3 R/1",
        "b": "E5/2 D5/1 C5/1 | B4/2 C5/1 D5/1 | E5/1 F#5/1 G5/1 E5/1 | D5/4 | C5/2 B4/1 A4/1 | G4/2 A4/1 B4/1 | "
             "C5/1 E5/1 D5/1 F#5/1 | G5/2 D5/2",
        "lead_a": "brass", "lead_b": "strings", "double": "chimes", "bass": "sweepbass", "bass_style": "oompah",
        "comp": "piano", "comp_style": "offbeat", "pad": "altstrings", "arp": "harp",
        "sd_lead": "brass2", "sd_pad": "choir",
    },
    "Desert": {
        "bpm": 138, "drums": "tribal",
        "chords_a": ["E", "E", "F", "E", "E", "Am", "F", "E"],
        "chords_b": ["Am", "E", "Dm", "E", "Am", "G", "F", "E"],
        "a": "E5/.75 F5/.25 G#5/1 A5/.5 G#5/.5 F5/1 | E5/1.5 D5/.5 C5/.5 B4/.5 A4/1 | B4/.5 C5/.5 D5/.5 E5/.5 F5/1 E5/1 | "
             "G#4/.5 A4/.5 B4/1 E4/2 | E5/.5 E5/.5 F5/.5 G#5/.5 A5/1 B5/1 | C6/1 B5/.5 A5/.5 G#5/1 F5/1 | "
             "E5/.5 F5/.5 D5/.5 E5/.5 C5/1 B4/1 | E5/3 R/1",
        "b": "A4/2 C5/2 | B4/2 G#4/2 | A4/2 F4/2 | E4/4 | C5/2 E5/2 | D5/2 B4/2 | C5/1 B4/1 A4/1 G#4/1 | E4/4",
        "lead_a": "guitar", "lead_b": "tenorchoir", "double": "horn", "bass": "dirtybass", "bass_style": "ostinato",
        "comp": "horn2", "comp_style": "stabs", "pad": "choir", "arp": "harp",
        "sd_lead": "guitar", "sd_pad": "lowchoir",
    },
    "RockslideRidge": {
        "bpm": 144, "drums": "epic",
        "chords_a": ["Cm", "Cm", "Ab", "G", "Cm", "Fm", "G", "Cm"],
        "chords_b": ["Ab", "Bb", "Cm", "G", "Fm", "Cm", "Ab", "G"],
        "a": "C5/1 G4/.5 C5/.5 Eb5/1 D5/1 | C5/.5 Bb4/.5 Ab4/1 G4/2 | Ab4/1 Bb4/.5 C5/.5 D5/1 Eb5/1 | "
             "F5/.5 Eb5/.5 D5/1 G4/2 | C5/1 G4/.5 C5/.5 Eb5/1 G5/1 | F5/.5 Eb5/.5 D5/.5 Eb5/.5 F5/2 | "
             "Eb5/.5 D5/.5 C5/.5 D5/.5 B4/1 G4/1 | C5/3 R/1",
        "b": "Ab4/2 C5/2 | Bb4/2 D5/2 | C5/2 Eb5/2 | D5/2 B4/2 | Ab4/1 C5/1 F5/2 | G5/2 F5/1 Eb5/1 | "
             "D5/1 Eb5/1 F5/1 D5/1 | G5/4",
        "lead_a": "horn", "lead_b": "choir", "double": "brass", "bass": "wofstrings", "bass_style": "drive8",
        "comp": "strings2", "comp_style": "ostinato16", "pad": "tenorchoir", "arp": "harp",
        "sd_lead": "brass", "sd_pad": "lowchoir",
    },
    "Lobby": {
        "bpm": 112, "drums": "lobby",
        "chords_a": ["F", "Dm", "Gm", "C", "F", "Bb", "C", "F"],
        "chords_b": ["Bb", "F", "Gm", "C", "Dm", "Am", "Bb", "C"],
        "a": "A4/.5 C5/.5 F5/1 E5/.5 D5/.5 C5/1 | D5/.5 C5/.5 A4/1 G4/2 | Bb4/.5 D5/.5 G5/1 F5/.5 E5/.5 D5/1 | "
             "C5/3 R/1 | A4/.5 C5/.5 F5/1 G5/.5 A5/.5 F5/1 | Bb5/1 A5/.5 G5/.5 F5/1 D5/1 | "
             "C5/.5 D5/.5 E5/.5 G5/.5 F5/1 E5/1 | F5/3 R/1",
        "b": "D5/2 C5/2 | Bb4/2 A4/2 | G4/1 A4/1 Bb4/1 D5/1 | C5/4 | D5/2 F5/2 | E5/2 C5/2 | D5/1 E5/1 G5/1 E5/1 | F5/4",
        "lead_a": "piano", "lead_b": "chimes", "double": "chimes", "bass": "sweepbass", "bass_style": "walk",
        "comp": "altstrings", "comp_style": "pad2", "pad": "strings", "arp": "harp",
    },
}

PAN = {"lead": 0.0, "double": 0.25, "bass": 0.0, "comp": -0.35, "pad": 0.3, "arp": -0.25, "hits": 0.0}


# --- the band ----------------------------------------------------------------------------------------------------------

def play_tune(tr, inst, start_bar, text, vel, transpose=0, pan=0.0, legato=0.92):
    beat = start_bar * 4
    for n, b in tune(text.replace("|", "")):
        if n is not None:
            tr.note(inst, beat, b * legato, n + transpose, vel, pan)
        beat += b


def harmony(tr, th, bar, name, sudden):
    """One bar of bass, comp, pad and arpeggio over a chord."""
    beat = bar * 4
    notes = chord(name, 4)
    root = chord(name, 2)[0]
    style = "drive16" if sudden else th["bass_style"]

    # Bass
    if style == "oompah":
        for b, n in ((0, root), (2, root + 7)):
            tr.note(th["bass"], beat + b, 0.9, n, 100, PAN["bass"])
    elif style == "ostinato":
        for b, d in ((0, 0), (0.5, 0), (1, 1), (1.5, 0), (2, 4), (2.5, 0), (3, 1), (3.5, 0)):
            tr.note(th["bass"], beat + b, 0.4, root + d, 96 if b % 1 == 0 else 80, PAN["bass"])
    elif style == "drive8":
        for e in range(8):
            tr.note(th["bass"], beat + e / 2, 0.42, root + (12 if e % 4 == 3 else 0), 98 if e % 2 == 0 else 84)
    elif style == "walk":
        for b, d in enumerate((0, 4 if notes[1] - notes[0] == 4 else 3, 7, 12)):
            tr.note(th["bass"], beat + b, 0.9, root + d, 90, PAN["bass"])
    else:  # drive16: sudden death
        for s in range(16):
            tr.note(th["bass"], beat + s / 4, 0.22, root + (12 if s % 8 == 6 else 0), 100 if s % 4 == 0 else 82)

    # Comp
    cs = "ostinato16" if sudden and th["comp_style"] != "ostinato16" else th["comp_style"]
    if cs == "offbeat":
        for b in (0.5, 1.5, 2.5, 3.5):
            for n in notes:
                tr.note(th["comp"], beat + b, 0.3, n, 78, PAN["comp"])
    elif cs == "stabs":
        for b in (0, 1.5, 3):
            for n in notes:
                tr.note(th["comp"], beat + b, 0.35, n - 12, 90, PAN["comp"])
    elif cs == "ostinato16":
        pattern = [notes[0], notes[0], notes[2], notes[0], notes[1], notes[0], notes[2], notes[1]]
        for s in range(16):
            tr.note(th["comp"], beat + s / 4, 0.2, pattern[s % 8] - 12, 84 if s % 4 == 0 else 66, PAN["comp"])
    else:  # pad2
        for n in notes:
            tr.note(th["comp"], beat, 1.9, n, 62, PAN["comp"])
            tr.note(th["comp"], beat + 2, 1.9, n, 58, PAN["comp"])


def drums(tr, kind, bar, fill, sudden):
    beat = bar * 4
    if sudden:
        for b in range(4):
            tr.drum("kick", beat + b, 118)
        tr.drum("kick", beat + 3.75, 90)
        for b in (1, 3):
            tr.drum("snare", beat + b, 112)
        for s in range(16):
            tr.drum("hat", beat + s / 4, 70 if s % 2 else 92, 0.2)
        tr.drum("hit", beat, 110)
        if bar % 2 == 0:
            tr.drum("crash", beat, 100, -0.2)
        if fill:
            for s in range(8, 16):
                tr.drum("snare", beat + s / 4, 70 + s * 3, pitch=1 + (s - 8) * 0.02)
        return
    if kind == "galop":
        for b in (0, 2):
            tr.drum("kick", beat + b, 108)
        for b in (1, 3):
            tr.drum("snare", beat + b, 96)
        for e in range(8):
            tr.drum("hat", beat + e / 2, 60 if e % 2 else 80, 0.2)
    elif kind == "tribal":
        for b, v in ((0, 112), (0.75, 84), (1.5, 96), (2, 104), (2.75, 84), (3.5, 96)):
            tr.drum("bassdrum", beat + b, v, -0.1)
        for b in (1, 3):
            tr.drum("snare", beat + b, 92)
        for s in range(16):
            tr.drum("hat", beat + s / 4, 48 if s % 2 else 66, 0.25)
    elif kind == "epic":
        for b in (0, 0.5, 2, 2.5):
            tr.drum("kick", beat + b, 112 if b % 1 == 0 else 92)
        for b in (1, 3):
            tr.drum("snare", beat + b, 104)
        for e in range(8):
            tr.drum("hat", beat + e / 2, 62 if e % 2 else 82, 0.2)
        if bar % 4 == 0:
            tr.drum("crash", beat, 92, -0.2)
    else:  # lobby
        tr.drum("kick", beat, 92)
        tr.drum("kick", beat + 2.5, 78)
        for b in (1, 3):
            tr.drum("snare", beat + b, 70)
        for e in range(8):
            tr.drum("hat", beat + e / 2, 50 if e % 2 else 64, 0.2)
    if fill:
        for s in range(12, 16):
            tr.drum("snare", beat + s / 4, 72 + (s - 12) * 10)


def arrange(name, sudden=False):
    """Intro (4 bars), A (8), B (8), A with the full band (8), turnaround (4)."""
    th = THEMES[name]
    bpm = round(th["bpm"] * 1.15) if sudden else th["bpm"]
    tr = Track(bpm, 32)
    lead_a = th.get("sd_lead", th["lead_a"]) if sudden else th["lead_a"]
    pad = th.get("sd_pad", th["pad"]) if sudden else th["pad"]
    chords_by_bar = th["chords_a"][4:] + th["chords_a"] + th["chords_b"] + th["chords_a"] + th["chords_b"][4:]
    for bar, c in enumerate(chords_by_bar):
        harmony(tr, th, bar, c, sudden)
        drums(tr, th["drums"], bar, bar % 8 == 3 or bar == 31, sudden)
        # Pads under B and the full band; arpeggios in the full band
        if 12 <= bar < 28 or sudden:
            for n in chord(c, 4 if pad != "lowchoir" else 3):
                tr.note(pad, bar * 4, 3.95, n, 64, PAN["pad"])
        if bar >= 20 or (sudden and bar >= 4):
            arp = chord(c, 5)
            for e in range(8):
                tr.note(th["arp"], bar * 4 + e / 2, 0.45, arp[e % 3] + (12 if e >= 6 else 0), 66, PAN["arp"])
    # The tunes: A, then B, then A with its octave double (and in sudden death, doubled from the start)
    play_tune(tr, lead_a, 4, th["a"], 110, 0, PAN["lead"])
    play_tune(tr, th["lead_b"], 12, th["b"], 100, 0, PAN["lead"], legato=0.98)
    play_tune(tr, lead_a, 20, th["a"], 116, 0, PAN["lead"])
    play_tune(tr, th["double"], 20, th["a"], 84, 12, PAN["double"])
    if sudden:
        play_tune(tr, th["double"], 4, th["a"], 80, 12, PAN["double"])
        play_tune(tr, lead_a, 12, th["b"], 96, 12, PAN["double"])
    left, right = tr.render(0.2 if not sudden else 0.16)
    return level_stereo(left, right, -19 if sudden else -20)


PIECES = {
    "Lobby": lambda: arrange("Lobby"),
    "Battle_PicnicPlains": lambda: arrange("PicnicPlains"),
    "Battle_PicnicPlains_SuddenDeath": lambda: arrange("PicnicPlains", True),
    "Battle_Desert": lambda: arrange("Desert"),
    "Battle_Desert_SuddenDeath": lambda: arrange("Desert", True),
    "Battle_RockslideRidge": lambda: arrange("RockslideRidge"),
    "Battle_RockslideRidge_SuddenDeath": lambda: arrange("RockslideRidge", True),
}


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "out", "themes")
    os.makedirs(out, exist_ok=True)
    for name in sys.argv[2:] or list(PIECES):
        left, right = PIECES[name]()
        wav = os.path.join(out, f"WB_Music_{name}.wav")
        write_stereo(wav, left, right)
        to_ogg(wav)
        print(f"{name:36s} {len(left) / SR:6.1f} s  peak {20 * np.log10(np.max(np.abs(left)) + 1e-9):5.1f} dB")


if __name__ == "__main__":
    main()
