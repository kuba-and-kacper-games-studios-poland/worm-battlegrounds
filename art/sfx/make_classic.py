"""Builds Worm Battlegrounds' sound effects in the classic 2005-2009 Roblox soundscape: python -I make_classic.py <out>

Three kinds of sound, so the whole game sits in one nostalgic palette:
- CLASSIC: one of Roblox's own 2009 sounds as it is, played in game straight from its Roblox asset id (Roblox-owned,
  public domain, nothing to upload), e.g. the slingshot for a throw, "Kid saying Ouch" for a hurt snail.
- BUILT: made from those classic sounds (layered, re-pitched as PlaybackSpeed would, looped), uploaded once approved.
- SCORED: notifications played on the Great Strategy soundfont's instruments (the music's own trumpet, brass, piano,
  Tomb drum and orchestra hit), so turn calls sound like the music.

The classic WAVs live in tools/classic/sfx (README.md → Classic sounds). Writes WB_<Name>.wav (+ .ogg for BUILT and
SCORED) into <out>, and classic.json describing every sound for the preview.
"""

import json
import os
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_sfx  # noqa: E402
from snaillib import (CLASSIC, HERE, SR, N, Song, fade, level, loop_seam, mix, place, render_midi, room,  # noqa: E402
                      to_ogg, write)
from tracker import DRUMS, Track  # noqa: E402

SFX = os.path.join(HERE, "tools", "classic", "sfx")

# Roblox's own 2009 uploads (user "Roblox", public domain) and the client's built-in sounds
IDS = {
    "bass": 12221944, "button": 12221967, "clickfast": 12221976, "collide": 12221984, "electronicpingshort": 12221990,
    "flashbulb": 12221996, "glassbreak": 12222005, "hit": 12222046, "Kerplunk": 12222054, "Ouch": 12222058,
    "LaunchingRocket": 12222065, "pageturn": 12222076, "RocketShot": 12222084, "RocketWhoosh": 12222095,
    "RubberBandSling": 12222103, "ShortSpring": 12222124, "ShoulderRocket": 12222132, "snap": 12222140,
    "splat": 12222152, "switch": 12222170, "SWITCH3": 12222183, "swoosh": 12222200, "swordlunge": 12222208,
    "swordslash": 12222216, "unsheath": 12222225, "uuhhh": 12222242, "oof": 79348298352567,
}
BUILTIN = {"action_jump_land": "rbxasset://sounds/action_jump_land.mp3",
           "impact_water": "rbxasset://sounds/impact_water.mp3"}


def load(name):
    with wave.open(os.path.join(SFX, f"{name}.wav")) as w:
        return np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64) / 32768


def speed(x, factor):
    """Plays a sound faster (higher) or slower (lower), as Roblox's PlaybackSpeed does."""
    n = int(len(x) / factor)
    return np.interp(np.arange(n) * factor, np.arange(len(x)), x)


def length(*parts):
    return max(at + len(sig) / SR for sig, at, _g in parts) + 0.05


def stack(*parts):
    return mix(length(*parts), *parts)


def score(build, seconds, bpm=140):
    """Renders a few notes on the Great Strategy soundfont, mono."""
    song = Song(bpm, seed=5)
    build(song)
    out = os.path.join(HERE, "tools", "_score")
    song.write(out + ".mid")
    left, right = render_midi(out + ".mid", out + ".wav", room=0.4, level_=0.25, soundfont=CLASSIC["GreatStrategy"])
    return fade(((left + right) / 2)[: N(seconds)], 0.001, 0.15)


def sampled(notes, seconds, wet=0.25):
    """A one-shot on the classic sample pack (tracker.py): notes are (instrument, start s, length s, MIDI, velocity),
    and a drum hit is (its name in tracker's DRUMS, start s, 0, 0, velocity)."""
    tr = Track(120, max(1, int(seconds / 2) + 1), tail=0)
    for inst, at, dur, pitch, vel in notes:
        if inst in DRUMS:
            tr.drum(inst, at * 2, vel)
        else:
            tr.note(inst, at * 2, dur * 2, pitch, vel)
    x = tr.buf[: N(seconds)].mean(axis=1)
    return fade(room(x, wet, 1.2, 0.8)[: N(seconds)], 0.001, min(0.25, seconds / 3))


def setup(song, programs):
    for ch, prog in programs.items():
        song.program(ch, prog, bank=None if ch == 9 else 0)
        song.cc(ch, 7, 110)


SOUNDS = {}


def sound(kind, target=None, source=None, loop=False):
    """Registers a sound: CLASSIC ones name their classic source; BUILT and SCORED ones are levelled to target."""
    def wrap(fn):
        SOUNDS[fn.__name__] = {"fn": fn, "kind": kind, "target": target, "source": source, "loop": loop}
        return fn
    return wrap


# --- turns and match ---------------------------------------------------------------------------------------------------

@sound("SCORED", -18)
def Turn_Yours():
    """Your turn, a call to arms (the owner, 2026-11-10: "more military, this is a snails battle game"): a snare ruff
    into a short bugle call on the Great Strategy bright horn, up the bugle's own notes (G, G, C, E, a held G), the
    bass drum and an accent landing with it, a horn under the last note."""
    notes = [("snare", t, 0, 0, v) for t, v in ((0, 52), (0.04, 64), (0.08, 78), (0.12, 100))]
    notes += [("bassdrum", 0.12, 0, 0, 84), ("snare", 0.8, 0, 0, 92), ("bassdrum", 0.8, 0, 0, 92)]
    for at, dur, pitch, vel in ((0.12, 0.09, 67, 94), (0.24, 0.09, 67, 90), (0.36, 0.18, 72, 98), (0.58, 0.18, 76, 100),
                                (0.8, 0.55, 79, 106)):
        notes.append(("brass", at, dur, pitch, vel))
    notes.append(("horn", 0.8, 0.55, 60, 74))
    return sampled(notes, 1.7, wet=0.22)


@sound("SCORED", -22)
def Turn_Start():
    """Anyone else's turn: the same camp, smaller. A rat-a-tat on the snare and two bugle notes on the horn, a fourth up
    (G, C), lower and softer than the player's own call."""
    notes = [("snare", t, 0, 0, v) for t, v in ((0, 62), (0.07, 54), (0.14, 84))]
    notes += [("bassdrum", 0.14, 0, 0, 70)]
    notes += [("horn", 0.14, 0.14, 67, 80), ("horn", 0.32, 0.45, 72, 84)]
    return sampled(notes, 1.2, wet=0.22)


@sound("BUILT", -20)
def Turn_Next():
    """You're next: the classic electronic ping, twice, the second a third higher."""
    p = load("electronicpingshort")
    return stack((p, 0, 1), (speed(p, 1.26), 0.14, 0.9))


@sound("CLASSIC", source="clickfast")
def Turn_Tick():
    """The last seconds tick: the classic fast click (the HUD raises its pitch as time runs out)."""


@sound("SCORED", -17)
def Turn_TimeUp():
    """Time's up: brass falling a fifth onto a Tomb drum."""
    def build(s):
        setup(s, {0: 60, 1: 47})
        s.note(0, 0, 0.45, 64, 110, jitter=0, vjit=0)
        s.note(0, 0.5, 1.2, 57, 104, jitter=0, vjit=0)
        s.note(1, 0.5, 1, 45, 110, jitter=0, vjit=0)
    return score(build, 1.6)


@sound("CLASSIC", source="swoosh")
def Turn_Whoosh():
    """Under the 'Your turn' banner sliding in: the classic swoosh."""


@sound("SCORED", -13)
def Match_SuddenDeath():
    """Sudden death: a rolling Tomb drum swelling into the orchestra hit over low brass and a cymbal."""
    def build(s):
        setup(s, {0: 47, 1: 60, 2: 55, 9: 0})
        for i in range(16):
            s.note(0, i * 0.125, 0.12, 45, 50 + i * 4, jitter=0, vjit=0)
        for p in (50, 53, 57):
            s.note(1, 2, 3, p - 12, 112, jitter=0, vjit=0)
        s.note(2, 2, 2, 62, 124, jitter=0, vjit=0)
        s.note(9, 2, 2, 49, 110, jitter=0, vjit=0)
    return score(build, 4.0)


@sound("BUILT", -17)
def Match_Knockout():
    """A knockout: a bright 'ding-ding' from the classic ping."""
    p = load("electronicpingshort")
    return stack((speed(p, 1.5), 0, 1), (speed(p, 2.0), 0.12, 1))


@sound("BUILT", -21)
def Match_WaterRise():
    """The sea rising each sudden-death turn: low plops and a deep rumble."""
    k, b = load("Kerplunk"), load("bass")
    parts = [(speed(b, 0.5), 0, 0.8)] + [(speed(k, f), at, 0.5) for f, at in ((0.6, 0.1), (0.75, 0.45), (0.55, 0.8),
                                                                              (0.7, 1.15), (0.5, 1.5))]
    return stack(*parts)


# --- weapons ---------------------------------------------------------------------------------------------------------

@sound("CLASSIC", source="LaunchingRocket")
def Fire_Bazooka():
    """Bazooka fired: the classic 'Launching rocket'."""


@sound("BUILT", -15)
def Fire_HomingMissile():
    """Homing missile: three lock-on pings, then the classic shoulder-fired rocket."""
    p = speed(load("electronicpingshort"), 2.0)
    return stack((p, 0, 0.5), (p, 0.09, 0.5), (speed(p, 1.3), 0.18, 0.6), (load("ShoulderRocket"), 0.3, 1))


@sound("CLASSIC", source="RubberBandSling")
def Fire_Throw():
    """A lob (grenade, cluster bomb, spider bomb, the spear...): the classic slingshot."""


@sound("BUILT", -16)
def Fire_Dynamite():
    """Dynamite set down: a classic snap as the match strikes, then the fuse fizzing."""
    return stack((load("snap"), 0, 1), (load("flashbulb"), 0.02, 0.5), (make_sfx.Fire_Dynamite() * 0.6, 0.06, 1))


@sound("BUILT", -14)
def Fire_Shotgun():
    """Shotgun: a short high classic boom with a snap, then a switch-switch pump."""
    boom = load("collide")[: N(0.4)]
    return stack((speed(boom, 1.7), 0, 1), (load("snap"), 0, 0.8), (load("switch"), 0.42, 0.6),
                 (load("SWITCH3"), 0.58, 0.7))


@sound("BUILT", -16)
def Fire_Uzi():
    """Uzi: a rattling burst of classic snaps."""
    s, rng = load("snap"), np.random.default_rng(3)
    return stack(*[(speed(s, rng.uniform(0.9, 1.15)), i / 12, rng.uniform(0.8, 1)) for i in range(10)])


@sound("BUILT", -16)
def Fire_Minigun():
    """Minigun: a whoosh spinning up into a fast run of snaps."""
    s, rng = load("snap"), np.random.default_rng(4)
    spin = speed(load("RocketWhoosh")[: N(1.2)], 0.6)[: N(1.6)]
    return stack((spin * np.linspace(0.2, 1, len(spin)), 0, 0.5),
                 *[(speed(s, rng.uniform(0.85, 1.1)), 0.3 + i / 20, rng.uniform(0.7, 1)) for i in range(25)])


@sound("BUILT", -14)
def Fire_BaseballBat():
    """Baseball bat: the classic sword slash and a hit."""
    return stack((load("swordslash"), 0, 1), (load("hit"), 0.12, 1))


@sound("BUILT", -13)
def Fire_OnePunch():
    """One Punch: the classic sword lunge, a heavy hit and a bass thump."""
    return stack((load("swordlunge"), 0, 1), (speed(load("hit"), 0.7), 0.2, 1), (load("bass"), 0.2, 0.8))


# --- utilities -------------------------------------------------------------------------------------------------------

@sound("BUILT", -18)
def Use_Heal():
    """A heal: the classic ping climbing a major arpeggio."""
    p = load("electronicpingshort")
    return stack(*[(speed(p, f), i * 0.07, 0.8) for i, f in enumerate((1.0, 1.26, 1.5, 2.0))])


@sound("BUILT", -18)
def Use_Potion():
    """A potion: three Kerplunk glugs, then the ping rising."""
    k, p = load("Kerplunk"), load("electronicpingshort")
    return stack((speed(k, 1.2), 0, 1), (k, 0.09, 1), (speed(k, 0.8), 0.18, 1), (speed(p, 1.5), 0.3, 0.6),
                 (speed(p, 2.0), 0.37, 0.6))


@sound("BUILT", -20)
def Use_Parachute():
    """A parachute opening: the classic swoosh, slowed into a fwump."""
    return speed(load("swoosh"), 0.55)


@sound("BUILT", -18)
def Use_Jetpack():
    """A jetpack igniting: the start of the classic rocket whoosh."""
    return fade(load("RocketWhoosh")[: N(0.7)], 0.002, 0.25)


# --- blasts and shots --------------------------------------------------------------------------------------------------

@sound("CLASSIC", source="RocketShot")
def Explosion_Big():
    """A big blast: the classic Time Bomb boom."""


@sound("CLASSIC", source="collide")
def Explosion_Small():
    """A smaller blast: the classic rocket explosion (collide.wav)."""


@sound("CLASSIC", source="hit")
def Shot_Bounce():
    """A thrown bomb bouncing: the classic hit."""


@sound("BUILT", -20)
def Shot_Whistle():
    """A lobbed shot coming down: a falling whistle (no classic sound has one, so it's synthesized, plainly)."""
    return make_sfx.Shot_Whistle()


# --- snails ----------------------------------------------------------------------------------------------------------

@sound("CLASSIC", source="splat")
def Snail_Step():
    """The active snail walking: the classic paintball splat, quiet."""


@sound("CLASSIC", source="ShortSpring")
def Snail_Jump():
    """A jump: the classic short spring."""


@sound("CLASSIC", source="action_jump_land")
def Snail_Land():
    """A landing: Roblox's own built-in landing sound."""


@sound("BUILT", -24, loop=True)
def Snail_Jetpack():
    """The jetpack flying, a seamless loop cut from the classic rocket whoosh."""
    w = load("RocketWhoosh")
    return loop_seam(w[N(1.5): N(3.6)], 0.1)


@sound("CLASSIC", source="Ouch")
def Snail_Hurt():
    """A snail hurt: the classic 'Kid saying Ouch'."""


@sound("CLASSIC", source="glassbreak")
def Snail_ShellBreak():
    """The shell breaking: the classic glass break."""


@sound("CLASSIC", source="oof")
def Snail_KnockedOut():
    """Knocked out: the official OOF."""


@sound("BUILT", -15)
def Snail_Splash():
    """Into the sea: a deep Kerplunk over Roblox's own water impact."""
    return stack((load("impact_water"), 0, 0.8), (speed(load("Kerplunk"), 0.6), 0, 1))


@sound("BUILT", -16)
def Snail_Burn():
    """Into the lava: a sizzle over a low, slowed classic boom."""
    return stack((make_sfx.Snail_Burn(), 0, 1), (speed(load("collide"), 0.5)[: N(1.0)], 0, 0.35))


@sound("SCORED", -20)
def Snail_Ghost():
    """The ghost rising: Violin strings sliding up an arpeggio with the Digo Piano sparkling over them."""
    def build(s):
        setup(s, {0: 40, 1: 0})
        for i, p in enumerate((60, 64, 67, 72, 76, 79)):
            s.note(0, i * 0.35, 0.6, p, 80 + i * 4, jitter=0, vjit=0)
        for i, p in enumerate((84, 88, 91)):
            s.note(1, 1.2 + i * 0.25, 0.6, p, 70, jitter=0, vjit=0)
    return score(build, 3.4)


@sound("BUILT", -19)
def Liquid_Obsidian():
    """Lava meeting water: a steam hiss with the classic glass cracking, slowed and low."""
    return stack((make_sfx.Liquid_Obsidian(), 0, 1), (speed(load("glassbreak"), 0.6), 0.05, 0.4))


# --- interface ---------------------------------------------------------------------------------------------------------

@sound("CLASSIC", source="clickfast")
def Button_Hover():
    """Hovering a button: the classic fast click."""


@sound("CLASSIC", source="button")
def Button_Click():
    """Pressing a button: the classic button."""


@sound("CLASSIC", source="SWITCH3")
def Button_Close():
    """Closing a window: the classic switch."""


@sound("BUILT", -20)
def Window_Open():
    """Opening a window (shop, crates, loadout): one short high harp pluck with a tiny classic bubble under it."""
    pluck = sampled([("harp", 0, 0.12, 88, 96)], 0.35, wet=0.15)
    return fade(stack((pluck, 0, 1), (speed(load("Kerplunk"), 1.8), 0, 0.35))[: N(0.4)], 0.001, 0.12)


@sound("CLASSIC", source="electronicpingshort")
def Notification():
    """A notification: the classic electronic ping."""


@sound("CLASSIC", source="bass")
def Error():
    """Something refused: the classic bass."""


@sound("BUILT", -18)
def Teleport_Out():
    """Leaving for a match (the card sliding over): a quick harp glissando rising two octaves with finger chimes, into
    a soft classic swoosh, whisked away."""
    scale = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79, 81, 83, 84]
    notes = [("harp", i * 0.035, 0.3, p, 70 + i * 2) for i, p in enumerate(scale)]
    notes += [("chimes", 0.3, 0.6, 96, 60), ("chimes", 0.42, 0.6, 100, 54)]
    return stack((sampled(notes, 1.3), 0, 1), (load("swoosh"), 0.5, 0.7))[: N(1.3)]


@sound("SCORED", -16)
def Teleport_In():
    """Arriving in the match (the card sliding off): the swoosh and a short brass 'ta-da' on the orchestra hit."""
    def build(s):
        setup(s, {0: 60, 1: 55})
        s.note(0, 0.25, 0.3, 74, 110, jitter=0, vjit=0)
        s.note(0, 0.5, 1.2, 81, 112, jitter=0, vjit=0)
        s.note(1, 0.5, 1, 74, 118, jitter=0, vjit=0)
    return stack((load("swoosh"), 0, 1), (score(build, 2.0), 0, 1))


# --- build -----------------------------------------------------------------------------------------------------------

def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "out", "classic")
    os.makedirs(out, exist_ok=True)
    meta = {}
    for name, row in SOUNDS.items():
        fn = row["fn"]
        if row["kind"] == "CLASSIC":
            src = row["source"]
            x = load(src)
            ref = f"rbxassetid://{IDS[src]}" if src in IDS else BUILTIN[src]
        else:
            x = fn()
            x = x if row["loop"] else fade(x, 0.0005, 0.04)
            x = level(x, row["target"], "rms" if row["loop"] else "loudest")
            ref = None
        wav = os.path.join(out, f"WB_{name}.wav")
        write(wav, x)
        if row["kind"] != "CLASSIC":
            to_ogg(wav)
        meta[name] = {"kind": row["kind"], "what": (fn.__doc__ or "").strip(), "ref": ref, "loop": row["loop"]}
        print(f"{name:22s} {row['kind']:8s} {len(x) / SR:5.2f} s {ref or ''}")
    with open(os.path.join(out, "classic.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1)


if __name__ == "__main__":
    main()
