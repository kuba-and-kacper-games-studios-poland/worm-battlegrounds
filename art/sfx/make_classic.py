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
import snaillib as L  # noqa: E402
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


@sound("SCORED", -17)
def Match_DropIn():
    """The round starts and the snails drop in (GET READY): a military snare roll on the classic kit, sparse and soft
    into a fast loud roll, bass drum beats closing in, over low strings and a low choir swelling on D and the classic
    falling wind, faint (the owner, 2026-11-24: the numpy build sounded "too much AI... pixelated")."""
    total = 2.4
    notes = []
    at, gap = 0.0, 0.2
    while at < total - 0.1:
        prog = at / total
        notes.append(("snare", at, 0, 0, int(40 + 70 * prog ** 1.3)))
        at += gap
        gap = max(0.045, gap * 0.9)
    notes += [("bassdrum", t, 0, 0, v) for t, v in ((0, 70), (0.8, 76), (1.4, 84), (1.8, 92), (2.05, 100), (2.25, 110))]
    notes += [("strings", 0, total, 38, 70), ("strings2", 0.6, total - 0.6, 45, 64), ("lowchoir", 0, total, 26, 74)]
    notes += [("horn", 1.2, 1.2, 50, 72), ("horn", 1.2, 1.2, 57, 66)]
    wind = speed(load("action_falling"), 0.9)[: N(total)]
    wind = wind * np.linspace(0.2, 1, len(wind)) ** 2
    x = stack((sampled(notes, total + 0.6, wet=0.3), 0, 1), (wind, 0, 0.18))
    return x * np.concatenate([np.linspace(0.55, 1, N(total)), np.ones(len(x) - N(total))])


@sound("SCORED", -12)
def Match_BattleBegins():
    """THE BATTLE BEGINS, as the snails land: a 'da-da-DAAA' fanfare on the Great Strategy bright horn (two stabs, then
    the held D major chord landing with the words' slam, 0.24 s in), with a snare flam on the stabs, and the crash,
    the bass drum, the big hit and the font's orchestra hit on the chord, a low horn under it."""
    hit = 0.24
    notes = [("snare", 0, 0, 0, 84), ("snare", 0.12, 0, 0, 92)]
    for at in (0, 0.12):
        notes += [("brass", at, 0.09, 62, 100), ("brass", at, 0.09, 69, 96)]
    notes += [("brass", hit, 1.4, p, v) for p, v in ((62, 108), (66, 100), (69, 104), (74, 110))]
    notes += [("horn", hit, 1.5, 38, 96), ("horn2", hit, 1.5, 50, 84)]
    notes += [("crash", hit, 0, 0, 112), ("bassdrum", hit, 0, 0, 120), ("kick", hit, 0, 0, 110), ("hit", hit, 0, 0, 104)]

    def build(s):
        setup(s, {0: 55})
        s.note(0, hit * 140 / 60, 2, 62, 124, jitter=0, vjit=0)
    return stack((sampled(notes, 2.6, wet=0.3), 0, 1), (score(build, 2.6), 0, 0.7))


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


# --- 2026-11-16: each thrown weapon's own throw, the homing missile, the black hole, the variety grenade, the cluster --
# The throws replace the one shared classic slingshot (Fire_Throw, 12222103): each keeps the slingshot at its core,
# so they stay one family, with its own mark on it. Short numpy touches (clinks, servo chirps, warbles) where no
# classic sound has one, through snaillib as make_crates.py does; each reseeds so it builds the same every time.

def clinks(count, span, f_lo=2000, f_hi=3600, gain=0.3):
    """Small metal parts knocking together: short bright two-partial pings scattered over `span` seconds."""
    parts = []
    for _ in range(count):
        f = L.rng.uniform(f_lo, f_hi)
        ping = L.modal([f, f * 1.48, f * 2.3], [0.03, 0.018, 0.01], [1, 0.5, 0.25], 0.08)
        parts.append((ping, span * L.rng.random(), gain * L.rng.uniform(0.5, 1)))
    return stack(*parts)


def warble(f0, f1, seconds, rate=7.0, depth=0.12):
    """A low wobbling tone gliding from f0 to f1, a little overdriven: the black hole's voice."""
    t = L.tt(seconds)
    f = L.glide(f0, f1, seconds, "log") * (1 + depth * np.sin(2 * np.pi * rate * t))
    y = np.sin(2 * np.pi * np.cumsum(f) / SR) + 0.4 * np.sin(4 * np.pi * np.cumsum(f) / SR)
    return L.spec(np.tanh(y * 1.5), hi=900)


@sound("BUILT", -16)
def Fire_Grenade():
    """Grenade thrown: the pin pulled (a classic switch, quick and high, with its ring tinkling), then the classic
    slingshot."""
    L.reseed(71)
    ring = L.modal([3150, 4700, 7900], [0.05, 0.03, 0.015], [1, 0.5, 0.25], 0.15)
    return stack((speed(load("switch"), 1.6), 0, 3.0), (ring, 0.01, 0.12), (load("RubberBandSling"), 0.14, 1))


@sound("BUILT", -15)
def Fire_ClusterBomb():
    """Cluster bomb thrown: heavier, the slingshot slowed and a weighty thump under it, the bomblets rattling inside
    as it's swung and as it leaves."""
    L.reseed(72)
    heft = L.thump(140, 60, 0.02, 0.08, 0.4)
    return stack((clinks(9, 0.22, gain=0.35), 0, 1), (speed(load("RubberBandSling"), 0.82), 0.2, 1),
                 (heft, 0.2, 0.5), (clinks(6, 0.3, 1800, 3000, 0.25), 0.32, 1))


@sound("BUILT", -16)
def Fire_VarietyGrenade():
    """Variety grenade thrown: the slingshot, a little brighter, with a finger-chime and glockenspiel sparkle running
    up after it."""
    L.reseed(73)
    sparkle = sampled([("chimes", 0.06 + i * 0.035, 0.3, p, 50 + i * 3) for i, p in enumerate((88, 91, 96, 100, 103))],
                      0.9, wet=0.3)
    glock = stack((L.mallet(100, 0.5, "glock"), 0.12, 0.12), (L.mallet(107, 0.5, "glock"), 0.2, 0.1))
    return stack((speed(load("RubberBandSling"), 1.06), 0, 1), (sparkle, 0, 0.8), (glock, 0, 1))


@sound("BUILT", -16)
def Fire_BlackHoleGrenade():
    """Black hole grenade thrown: the slingshot, a touch lower, with a low warble swelling and sinking under it, as if
    the grenade pulled at the air."""
    L.reseed(74)
    w = warble(95, 52, 0.9) * L.swell(0.9, 0.35, 1.5)
    return stack((speed(load("RubberBandSling"), 0.94), 0, 1), (w, 0.02, 0.45))


@sound("BUILT", -16)
def Fire_SpiderBomb():
    """Spider bomb thrown: the slingshot, and a tiny mechanical chirp as its legs fold (three servo blips, a classic
    switch click)."""
    L.reseed(75)
    blips = []
    for i, (f0, f1) in enumerate(((1800, 2600), (2000, 2900), (2300, 3300))):
        b = L.osc(L.glide(f0, f1, 0.035, "log"), 0.035, "square") * L.ar(0.035, 0.002, 1.2)
        blips.append((L.band(b, 2600, 1.2), 0.03 + i * 0.05, 0.22))
    return stack((load("RubberBandSling"), 0.06, 1), (speed(load("switch"), 1.3), 0.0, 2.0), *blips)


@sound("BUILT", -15)
def Fire_SpartanSpear():
    """Spartan spear thrown: a long swish (the classic sword slash, quicker) over a soft slingshot, and the bronze tip
    ringing as it leaves (the classic blade 'shing' and a metal ring)."""
    L.reseed(76)
    ring = L.modal([1250, 3420, 6600], [0.5, 0.25, 0.1], [1, 0.45, 0.2], 0.8)
    return stack((speed(load("swordslash"), 1.1), 0, 1), (speed(load("RubberBandSling"), 1.15), 0, 0.4),
                 (speed(load("unsheath"), 1.25), 0.05, 0.45), (ring, 0.08, 0.25))


@sound("BUILT", -18)
def Homing_Lock():
    """The homing missile locking on: two quick high beeps (the classic electronic ping, twice as fast), 0.4 s."""
    p = speed(load("electronicpingshort"), 2.0)
    return fade(stack((p, 0, 1), (p, 0.13, 1))[: N(0.4)], 0.001, 0.05)


@sound("BUILT", -15)
def Homing_Boost():
    """The homing missile diving at its target: the classic rocket whoosh read faster and faster (its pitch rising) as
    the afterburner kicks in with a low fwoom, 1.2 s."""
    L.reseed(77)
    src = load("RocketWhoosh")[N(0.8):]
    n = N(1.2)
    rate = 1.0 + 0.7 * np.linspace(0, 1, n) ** 1.3
    burn = np.interp(np.cumsum(rate), np.arange(len(src)), src)
    burn *= np.clip(L.tt(1.2) / 0.08, 0, 1)
    fwoom = L.sweep(L.noise(N(0.5)), 2500, 250, "lp") * L.decay(0.5, 0.15, 0.01)
    return stack((burn, 0, 1), (fwoom, 0, 0.5), (L.thump(160, 55, 0.03, 0.1, 0.5), 0, 0.5))


@sound("BUILT", -13)
def BlackHole_Open():
    """The black hole opening: a quick inward breath (the classic swoosh reversed and slowed), then a deep whomp (a long
    sub thump and the classic bass slowed) with the low choir and sweeping bass blooming under it."""
    L.reseed(78)
    breath = np.flip(speed(load("swoosh"), 0.6))
    at = len(breath) / SR
    whomp = L.thump(90, 28, 0.06, 0.35, 1.4)
    air = L.sweep(L.noise(N(0.8)), 2000, 150, "lp") * L.decay(0.8, 0.25, 0.005)
    bloom = sampled([("lowchoir", 0, 0.9, 28, 92), ("sweepbass", 0, 0.5, 28, 90)], 1.4, wet=0.35)
    return stack((breath, 0, 0.8), (whomp, at, 1), (speed(load("bass"), 0.55), at, 0.6), (air, at, 0.4),
                 (bloom, at, 0.8))


@sound("BUILT", -22, loop=True)
def BlackHole_Hum():
    """The black hole pulling while it's open: a 3 s seamless loop that always seems to rise (a Shepard glide), a deep
    sub, a six-a-second warble and air rushing in (no classic sound has one, so it's synthesized)."""
    return make_sfx.BlackHole_Hum()


@sound("BUILT", -15)
def BlackHole_Collapse():
    """The black hole caving in: the classic rocket blast played backwards (sucked in, swelling), a tone rising under
    it, then cut off at its peak with a tiny low gulp and near silence, 1 s."""
    L.reseed(79)
    rev = np.flip(speed(load("collide"), 0.8)[: N(0.8)])
    rise = L.osc(L.glide(40, 180, 0.8, "log"), 0.8) * np.linspace(0, 1, N(0.8)) ** 2.5
    suck = np.flip(speed(load("swoosh"), 0.7))
    x = stack((rev, 0, 1), (rise, 0, 0.5), (suck, 0.8 - len(suck) / SR, 0.6))[: N(0.8)]
    x = fade(x, 0.001, 0.006)
    gulp = L.thump(70, 30, 0.02, 0.05, 0.18)
    return stack((x, 0, 1), (gulp, 0.81, 0.35))[: N(1.0)]


@sound("BUILT", -11)
def BlackHole_Burst():
    """The black hole bursting after it collapses: the classic Time Bomb boom with a slowed classic explosion and a
    long sub under it, the orchestra hit and a dark low choir on top, and its own mark, a deep warble falling away."""
    L.reseed(80)
    boom = fade(load("RocketShot")[: N(2.2)], 0.001, 0.6)
    sub = L.thump(110, 24, 0.06, 0.5, 2.5)
    fall = warble(320, 45, 1.6, rate=9, depth=0.15) * L.decay(1.6, 0.6, 0.004)
    dark = sampled([("hit", 0, 0, 0, 110), ("lowchoir", 0, 1.6, 28, 96), ("choir", 0.02, 1.4, 52, 70),
                    ("choir", 0.02, 1.4, 55, 66), ("crash", 0, 0, 0, 84)], 2.4, wet=0.4)
    return stack((boom, 0, 0.8), (L.spec(speed(load("impact_explosion_03"), 0.7), hi=3000), 0, 0.6), (sub, 0, 0.9),
                 (fall, 0.05, 0.4), (dark, 0, 0.7))[: N(2.6)]


@sound("BUILT", -14)
def Variety_Burst():
    """The variety grenade bursting into its minis: a bright pop (the classic flashbulb and Kerplunk) and a prism of
    finger chimes spraying up and back down, a glockenspiel glitter and a short bright-horn chord, rare and festive."""
    L.reseed(81)
    pop = stack((load("flashbulb"), 0, 1), (speed(load("Kerplunk"), 1.5), 0, 0.8), (L.click(0.004, 3000), 0, 0.6),
                (speed(load("collide"), 1.5)[: N(0.4)], 0, 0.3))
    up = (84, 88, 91, 95, 98, 102, 105)
    n = [("chimes", 0.03 + i * 0.025, 0.35, p, 56) for i, p in enumerate(up)]
    n += [("chimes", 0.22 + i * 0.03, 0.4, p, 46) for i, p in enumerate(reversed(up[:5]))]
    n += [("brass", 0.05, 0.25, p, 90) for p in (72, 76, 79, 83)] + [("crash", 0.03, 0, 0, 70)]
    prism = sampled(n, 1.6, wet=0.32)
    glit = stack(*[(L.mallet(p, 0.6, "glock"), 0.08 + i * 0.04, 0.12) for i, p in enumerate((96, 100, 103, 107))])
    return stack((pop, 0, 1), (prism, 0, 0.9), (glit, 0, 1))


@sound("BUILT", -19)
def Variety_Dig():
    """A variety worm burrowing: a short wet crunch (the classic splat, lower, over gritty soil grains and a soft
    thud), 0.3 s, made to repeat as they dig."""
    L.reseed(82)
    grit = L.grains(0.3, 26, 500, 2200, (0.004, 0.012), 1.5)
    return fade(stack((speed(load("splat"), 0.85), 0, 1), (grit, 0, 0.5), (L.thump(130, 60, 0.02, 0.05, 0.2), 0, 0.5))
                [: N(0.3)], 0.001, 0.06)


@sound("BUILT", -20)
def Variety_Squeak():
    """A variety worm diving in: a tiny cute squeak (synthesized; no classic sound squeaks) and a little classic
    Kerplunk bloop as it goes under."""
    return stack((make_sfx.Variety_Squeak(), 0, 1), (speed(load("Kerplunk"), 2.2), 0.13, 0.35))


@sound("BUILT", -15)
def Cluster_Split():
    """The cluster bomb splitting into its bomblets: a sharp pop (the classic snap and a small, quick classic blast,
    a Kerplunk pop) and the bomblets clinking apart."""
    L.reseed(83)
    blast = fade(speed(load("collide"), 1.8)[: N(0.35)], 0.001, 0.1)
    return stack((speed(load("snap"), 0.9), 0, 1), (blast, 0, 0.5), (speed(load("Kerplunk"), 1.3), 0, 0.6),
                 (clinks(7, 0.25, 2200, 3800, 0.3), 0.04, 1))


UPDATE_2026_11_16 = ["Fire_Grenade", "Fire_ClusterBomb", "Fire_VarietyGrenade", "Fire_BlackHoleGrenade",
                     "Fire_SpiderBomb", "Fire_SpartanSpear", "Homing_Lock", "Homing_Boost", "BlackHole_Open",
                     "BlackHole_Hum", "BlackHole_Collapse", "BlackHole_Burst", "Variety_Burst", "Variety_Dig",
                     "Variety_Squeak", "Cluster_Split"]


# --- 2026-11-17: the polish pass: the lobby's XP replay, the level-up and the frames, the free crate, the drop target,
# the emote wheel, the Shiny and Golden weapons' accents over their blasts. The ticks are crisp new synthesis, as
# make_crates.py's reel is; the calls and fanfares play on the classic samples (tracker.py), the Great Strategy's
# instruments for the melodies. Each reseeds so it builds the same every time.

def plus(*xs):
    """Sums sounds of different lengths."""
    out = np.zeros(max(len(x) for x in xs))
    for x in xs:
        out[: len(x)] += x
    return out


def twinkles(count, span, f_lo, f_hi, gain=0.3, ring=0.12, fall=1.6):
    """Glints of light: short bright bell-like pings scattered over `span` seconds, thicker at the start."""
    parts = []
    for _ in range(count):
        f = L.rng.uniform(f_lo, f_hi)
        ping = L.modal([f, f * 2.76, f * 5.4], [ring, ring * 0.4, ring * 0.15], [1, 0.3, 0.1], ring * 5)
        at = span * L.rng.random() ** fall
        parts.append((ping, at, gain * L.rng.uniform(0.4, 1) * (1 - 0.6 * at / span)))
    return stack(*parts)


def coin(f, ring):
    """A coin ringing: a bright metal strike whose two closest modes beat slowly against each other, so it shimmers."""
    ring_ = L.modal([f, f * 1.0042, f * 2.09, f * 2.97, f * 4.13], [ring, ring * 0.9, ring * 0.45, ring * 0.3, ring * 0.15],
                    [1, 0.8, 0.45, 0.3, 0.15], ring * 5)
    return plus(ring_, L.click(0.0025, 4000) * 0.5)


@sound("SCORED", -19)
def Xp_Line():
    """An XP line popping in on the post-match level bar ("Match played +100", "Victory +50"): a bright little chime, a
    harp pluck and the finger chimes on G with a glockenspiel glint on top and the classic fast click as it pops in,
    0.6 s."""
    L.reseed(91)
    bell = sampled([("harp", 0, 0.1, 79, 90), ("chimes", 0, 0.3, 91, 72), ("chimes", 0.025, 0.25, 98, 44)], 0.6,
                   wet=0.18)
    glint = fade(L.mallet(103, 0.5, "glock"), 0.0005, 0.25)
    return stack((bell, 0, 1), (glint, 0.008, 0.1), (speed(load("clickfast"), 1.3), 0, 0.25))[: N(0.6)]


@sound("BUILT", -22)
def Xp_Tick():
    """The XP bar filling, over and over as it fills: a tiny crisp tick, 50 ms (the very start of the classic fast
    click, brightened, over a short glassy 'tik'), at a middle pitch so the game can raise its PlaybackSpeed as the bar
    fills."""
    L.reseed(92)
    s = 0.05
    cl = fade(L.spec(load("clickfast")[: N(0.012)], lo=1500), 0.0002, 0.006)
    tik = L.modal([2350, 3530, 5300], [0.008, 0.005, 0.0025], [1, 0.4, 0.2], s)
    return L.mix(s, (cl, 0, 0.6), (tik, 0.0003, 0.8), (L.click(0.002, 4000), 0, 0.4))


@sound("SCORED", -16)
def Level_Up():
    """A new level: a short fanfare on the Great Strategy bright horn up the old 'level clear' steps (an A flat chord, a
    B flat chord, then a held C major), the snare on each step, the bass drum and crash landing with the chord, horns
    and strings under it and a finger-chime run up, 1.9 s."""
    n = [("snare", 0.0, 0, 0, 72), ("snare", 0.15, 0, 0, 82)]
    for at, dur, chord, bass in ((0.0, 0.11, (68, 72, 75), 44), (0.15, 0.11, (70, 74, 77), 46),
                                 (0.3, 1.0, (72, 76, 79), 48)):
        n += [("brass", at, dur, p, 104 if p == chord[-1] else 86) for p in chord]
        n += [("brass2", at, dur, chord[-1] - 12, 80), ("horn", at, dur, bass, 88)]
    n += [("bassdrum", 0.3, 0, 0, 108), ("crash", 0.3, 0, 0, 90)]
    n += [("strings", 0.3, 1.1, p, 70) for p in (48, 55, 64, 72)]
    n += [("chimes", 0.32 + i * 0.03, 0.4, p, 52) for i, p in enumerate((84, 88, 91, 96, 100))]
    return sampled(n, 1.9, wet=0.28)


@sound("SCORED", -15)
def Frame_Unlock():
    """A new prestige frame round the player's picture: grander and shinier than the level-up. A shimmer swelling in
    (the crash cymbal reversed, the finger chimes climbing two octaves), then the orchestra hit, bass drum and crash on
    a full C major chord (bright horns, horns, the choir and strings, held), the classic blade 'shing' glinting round
    the rim, a bell ringing on top and glints falling away, 2.4 s."""
    L.reseed(93)
    hit = 0.5
    swell_ = np.flip(sampled([("crash", 0, 0, 0, 110)], 0.5, wet=0.1)) * np.linspace(0.2, 1, N(0.5)) ** 1.5
    run = [("chimes", 0.04 + i * 0.04, 0.35, p, 60 + i * 3)
           for i, p in enumerate((84, 86, 88, 91, 93, 96, 98, 100, 103, 105, 108))]
    n = run + [("hit", hit, 0, 0, 112), ("bassdrum", hit, 0, 0, 112), ("crash", hit, 0, 0, 96)]
    n += [("brass", hit, 1.3, p, 100) for p in (72, 76, 79)] + [("brass2", hit, 1.3, 60, 90)]
    n += [("horn", hit, 1.4, p, 84) for p in (48, 55, 60)]
    n += [("choir", hit + 0.02, 1.5, p, 78) for p in (60, 64, 67, 72)] + [("lowchoir", hit, 1.5, 36, 86)]
    n += [("strings", hit, 1.6, p, 74) for p in (43, 55, 64, 72)]
    n += [("chimes", hit + 0.05 + i * 0.06, 0.5, p, 50) for i, p in enumerate((108, 103, 100, 96))]
    body = sampled(n, 2.4, wet=0.32)
    bell = stack((fade(L.mallet(96, 1.9, "bell"), 0.0005, 0.9), 0, 0.12), (fade(L.mallet(103, 1.8, "bell"), 0.0005, 0.9),
                                                                          0.1, 0.07))
    glints = twinkles(12, 1.1, 3200, 7000, 0.07, 0.1)
    return stack((swell_, 0, 1.0), (body, 0, 1), (speed(load("unsheath"), 1.2), hit + 0.02, 0.3), (bell, hit, 1),
                 (glints, hit + 0.25, 1))[: N(2.4)]


@sound("SCORED", -17)
def Free_Claim():
    """Claiming the free crate for joining the group: a happy pop (a woody knock, the classic Kerplunk and flashbulb
    and a soft thump, like a lid popping off), then a quick harp run up C major into a bright piano chord and a
    finger-chime sparkle, 1 s."""
    L.reseed(94)
    pop = stack((speed(load("Kerplunk"), 1.4), 0, 0.9), (load("flashbulb"), 0, 0.6), (L.mallet(64, 0.2, "wood"), 0, 0.6),
                (L.thump(180, 90, 0.015, 0.04, 0.25), 0, 0.3), (L.click(0.003, 2500), 0, 0.4))
    n = [("harp", 0.06 + i * 0.04, 0.3, p, 92 + i * 4) for i, p in enumerate((72, 76, 79, 84))]
    n += [("piano", 0.22, 0.6, p, 86) for p in (72, 76, 79)]
    n += [("chimes", 0.22 + i * 0.05, 0.4, p, 66) for i, p in enumerate((96, 100, 103, 108))]
    return stack((pop, 0, 0.45), (sampled(n, 1.0, wet=0.25), 0, 1), (twinkles(6, 0.45, 4000, 7500, 0.05), 0.25, 1))[
        : N(1.0)]


@sound("BUILT", -18)
def Drop_Place():
    """Placing the landing target before the drop: a soft, satisfying thump that locks in (a deep felt thock and a
    woody 'tock' with a two-part latch click on top, the classic switch, low), and a short low harp note under it so
    it feels set, 0.45 s."""
    L.reseed(95)
    s = 0.45
    c1 = plus(L.modal([2900, 4300], [0.006, 0.004], [1, 0.5], 0.03), L.click(0.003, 3000) * 0.4)
    c2 = plus(L.modal([2200, 3300], [0.007, 0.004], [1, 0.5], 0.03), L.click(0.003, 3000) * 0.3)
    harp = sampled([("harp", 0, 0.12, 55, 96)], 0.4, wet=0.12)
    return L.mix(s, (L.thump(160, 58, 0.02, 0.07, s), 0, 0.6), (L.mallet(67, s, "wood"), 0, 0.5),
                 (L.mallet(55, s, "wood"), 0, 0.35), (c1, 0, 0.8), (c2, 0.04, 0.65),
                 (speed(load("switch"), 0.8), 0.035, 2.0), (harp, 0.01, 0.6))


@sound("BUILT", -21)
def Emote_WheelOpen():
    """The emote wheel spinning open: a soft quick whoosh (the classic swoosh, a touch faster and darker) over airy
    noise sweeping up with a light flutter slowing as the wheel settles, 0.35 s."""
    L.reseed(96)
    s = 0.3
    flutter = 0.65 + 0.35 * np.sin(2 * np.pi * np.cumsum(L.glide(34, 12, s, "log")) / SR)
    air = L.bandsweep(L.noise(N(s)), 700, 2600, q=1.6) * L.swell(s, 0.45, 1.5) * flutter
    return stack((L.spec(speed(load("swoosh"), 1.2), hi=5000), 0, 1), (air, 0, 0.35))


@sound("BUILT", -26)
def Emote_WheelHover():
    """Pointing at another slice of the emote wheel: a very soft, rounded tick (a felt-tipped woody 'tk', lower and
    duller than the XP tick), 50 ms."""
    L.reseed(97)
    s = 0.05
    tr = L.spec(L.click(0.002, 1200), hi=5000)
    return L.mix(s, (L.modal([1500, 2240], [0.007, 0.004], [1, 0.35], s), 0, 0.7),
                 (L.modal([620], [0.01], [1], s), 0, 0.35), (tr, 0, 0.25))


@sound("BUILT", -18)
def Variant_Shiny():
    """A Shiny weapon's blast: a sparkly, glassy shimmer laid over the explosion (a glass 'ting' ringing, high finger
    chimes and glints scattered and thinning out, a fizz of light), all above 2 kHz so the boom comes through whole,
    1 s."""
    L.reseed(98)
    f = 2640
    glass = L.modal([f, f * 2.32, f * 4.25, f * 6.63], [0.5, 0.3, 0.15, 0.08], [1, 0.5, 0.3, 0.15], 1.0)
    chimes = sampled([("chimes", 0.04 + i * 0.07, 0.3, p, 50 - i * 2) for i, p in enumerate((103, 108, 100, 105, 98, 103))],
                     1.0, wet=0.3)
    fizz = L.grains(1.0, 40, 6000, 11000, (0.002, 0.006), 1.3)
    x = stack((glass, 0.02, 0.22), (chimes, 0, 0.8), (twinkles(16, 0.8, 3000, 8000, 0.12, 0.07), 0.02, 1),
              (fizz, 0, 0.25))[: N(1.0)]
    return fade(L.spec(x, lo=2000), 0.0005, 0.3)


@sound("BUILT", -17)
def Variant_Golden():
    """A Golden weapon's blast: a richer, warmer shimmer than the Shiny one, with a coin ringing through it. Two coins
    clinking ('ka-ching', each a bright metal ring beating slowly), the finger chimes running up C major, bells ringing
    a C major chord and golden glints falling away, all above 1.2 kHz so the boom comes through whole, 1.4 s."""
    L.reseed(99)
    run = [("chimes", 0.1 + i * 0.035, 0.45, p, 50 + i * 2) for i, p in enumerate((84, 88, 91, 96, 100, 103, 108))]
    chimes = sampled(run, 1.4, wet=0.32)
    bells = stack(*[(L.mallet(p, 1.4, "bell"), 0.12 + i * 0.03, 0.09) for i, p in enumerate((84, 88, 91, 96))])
    x = stack((coin(2637, 0.18), 0, 0.3), (coin(3136, 0.32), 0.075, 0.36), (chimes, 0, 0.8), (bells, 0, 1),
              (twinkles(14, 1.1, 2600, 6500, 0.08, 0.12), 0.2, 1))[: N(1.4)]
    return fade(L.spec(x, lo=1200), 0.0005, 0.45)


UPDATE_2026_11_17 = ["Xp_Line", "Xp_Tick", "Level_Up", "Frame_Unlock", "Free_Claim", "Drop_Place", "Emote_WheelOpen",
                     "Emote_WheelHover", "Variant_Shiny", "Variant_Golden"]


# --- 2026-11-25: the diamonds payout (coins became diamonds): the burst out of the snail and each diamond landing in
# the top bar's diamonds slot. The clink is crisp new synthesis on a finger-chime body, as the 17 Nov ticks are; the
# burst is the classic swoosh and flashbulb with the finger chimes. Each reseeds so it builds the same every time.

def gem(f, ring):
    """A cut gem ringing: a glassy strike, its partials spread wide and inharmonic (as Variant_Shiny's glass), the
    upper ones dying fast so it rings clean, never metal."""
    return L.modal([f, f * 2.32, f * 4.25, f * 6.63], [ring, ring * 0.5, ring * 0.25, ring * 0.12],
                   [1, 0.4, 0.18, 0.07], ring * 5)


@sound("BUILT", -21)
def Diamond_Collect():
    """A diamond landing in the diamonds slot, once per icon of the payout's burst (up to 30, the game raising its
    pitch from 1.0 to 1.6 across them): a crisp glassy 'clink', a gem dropping onto a pile (a bright glass strike on G7
    over a softer one an octave down, a smaller one settling on them 22 ms later on C8, a finger-chime body on G6, a soft
    tip), 0.2 s with no tail."""
    L.reseed(101)
    s = 0.2
    body = sampled([("chimes", 0, 0.04, 91, 84)], 0.24, wet=0.08)
    tip = L.spec(L.click(0.0015, 3500), hi=11000)
    x = L.mix(s, (gem(3136, 0.045), 0, 0.5), (gem(1568, 0.05), 0, 0.4), (gem(4186, 0.03), 0.022, 0.25),
              (body, 0, 0.7), (tip, 0, 0.15))
    return fade(L.spec(x, lo=700, hi=12000), 0.0003, 0.09)


@sound("BUILT", -19)
def Diamond_Burst():
    """The diamonds bursting out of the snail before they fly to the slot: a short sparkly shimmer (the classic swoosh,
    quick and airy, and a soft flashbulb pop, over bright air rising), a finger-chime run up G major and a few glassy
    gem 'tings' and glints scattering, all over 1.5 kHz so the '+amount' chime under it stays clear, 0.75 s."""
    L.reseed(102)
    s = 0.75
    whoosh = L.spec(speed(load("swoosh"), 1.35), lo=1500)
    air = L.bandsweep(L.noise(N(0.5)), 2000, 7500, q=1.4) * L.swell(0.5, 0.3, 1.6)
    run = sampled([("chimes", 0.005 + i * 0.035, 0.12, p, 62 - i * 2) for i, p in enumerate((91, 95, 98, 103, 107))],
                  s, wet=0.25)
    tings = stack(*[(gem(f, 0.09), at, g) for f, at, g in ((3520, 0.01, 0.3), (4699, 0.09, 0.22), (3951, 0.18, 0.2),
                                                           (5274, 0.27, 0.14))])
    fizz = L.grains(0.6, 26, 6000, 11000, (0.002, 0.005), 1.4)
    x = stack((whoosh, 0, 0.45), (L.spec(load("flashbulb"), lo=1500), 0, 0.25), (air, 0, 0.12), (run, 0, 0.85),
              (tings, 0, 1), (twinkles(10, 0.45, 3500, 8000, 0.09, 0.06), 0.03, 1), (fizz, 0, 0.18))[: N(s)]
    return fade(L.spec(x, lo=1500), 0.0005, 0.25)


UPDATE_2026_11_25 = ["Diamond_Collect", "Diamond_Burst"]
UPDATES = {"update": UPDATE_2026_11_16, "update17": UPDATE_2026_11_17, "update25": UPDATE_2026_11_25}


# --- build -----------------------------------------------------------------------------------------------------------

def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "out", "classic")
    os.makedirs(out, exist_ok=True)
    meta = {}
    # Name some to build only them (python -I make_classic.py <out> Fire_Grenade ...); "update" builds the 2026-11-16
    # set, "update17" the 2026-11-17 one, "update25" the 2026-11-25 one
    names = sys.argv[2:] or list(SOUNDS)
    if len(names) == 1 and names[0] in UPDATES:
        names = UPDATES[names[0]]
    for name in names:
        row = SOUNDS[name]
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
