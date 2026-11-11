"""A tiny tracker-style sampler for the classic Roblox sample pack (tools/drive, README.md → Classic sounds and fonts).

As the 2005 tracker songs were made: each instrument is one long sampled note, played at another pitch by reading it
faster or slower (no stretching, the grit included). A Track lays notes and drum hits on a stereo buffer one loop long;
what rings past the end folds back onto the start, so the loop has no seam, and the hall it plays in wraps the same way.
"""

import os
import wave

import numpy as np

from snaillib import HERE, SR

PACK = os.path.join(HERE, "tools", "drive", "Roblox SonndFont")
GS = os.path.join(PACK, "The Great Strategy")
WOF = os.path.join(PACK, "Wind Of Fjords")

# name: (file, the MIDI note it was sampled at, gain, release seconds)
INSTRUMENTS = {
    "brass": (os.path.join(GS, "RBLX_INST_BRIGHTHORN1.wav"), 36, 1.0, 0.12),
    "brass2": (os.path.join(GS, "RBLX_INST_BRIGHTHORN2.wav"), 36, 1.0, 0.12),
    "horn": (os.path.join(GS, "RBLX_INST_HORN1.wav"), 36, 1.0, 0.15),
    "horn2": (os.path.join(GS, "RBLX_INST_HORN4.wav"), 36, 1.0, 0.15),
    "strings": (os.path.join(GS, "RBLX_INST_STRING1.wav"), 36, 1.0, 0.25),
    "strings2": (os.path.join(GS, "RBLX_INST_STRING3.wav"), 36, 1.0, 0.25),
    "altstrings": (os.path.join(GS, "RBLX_INST_ALTSTRING1.wav"), 36, 1.0, 0.2),
    "piano": (os.path.join(GS, "RBLX_INST_PIANO.wav"), 36, 1.0, 0.2),
    "chimes": (os.path.join(GS, "RBLX_INST_FINGERCHYM.wav"), 69, 0.8, 0.3),
    "choir": (os.path.join(WOF, "RBLX_INST_CHOIR.wav"), 36, 0.9, 0.35),
    "tenorchoir": (os.path.join(WOF, "RBLX_INST_TENORCHOIR.wav"), 24, 0.9, 0.35),
    "guitar": (os.path.join(WOF, "RBLX_INST_GUITARLEAD.wav"), 60, 0.9, 0.12),
    "harp": (os.path.join(WOF, "RBLX_INST_HARP.wav"), 48, 1.0, 0.4),
    "dirtybass": (os.path.join(WOF, "RBLX_INST_DIRTYBASS.wav"), 24, 1.0, 0.08),
    "sweepbass": (os.path.join(WOF, "RBLX_INST_SWEEPINGBASS.wav"), 24, 0.9, 0.1),
    "lowchoir": (os.path.join(WOF, "RBLX_INST_LOWCHOIR_BASS.wav"), 24, 0.9, 0.3),
    "wofstrings": (os.path.join(WOF, "RBLX_INST_STRING.wav"), 24, 1.0, 0.25),
}
DRUMS = {
    "kick": os.path.join(WOF, "Drums", "RBLX_DRUM_KICK.wav"),
    "bassdrum": os.path.join(WOF, "Drums", "RBLX_DRUM_BASSDRUM.wav"),
    "snare": os.path.join(WOF, "Drums", "RBLX_DRUM_SNARE.wav"),
    "crash": os.path.join(WOF, "Drums", "RBLX_DRUM_CRASHCYMBAL.wav"),
    "hit": os.path.join(WOF, "Drums", "RBLX_DRUM_HIT.wav"),
}

_cache = {}


def _load(path):
    if path not in _cache:
        with wave.open(path) as w:
            ch = w.getnchannels()
            x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64).reshape(-1, ch) / 32768
        if ch == 1:
            x = np.repeat(x, 2, axis=1)
        # Trim the silence before the sound starts
        start = int(np.argmax(np.abs(x).max(axis=1) > 0.004))
        _cache[path] = x[max(0, start - 20):]
    return _cache[path]


def _tgs_hat():
    """The Great Strategy drum loop's brightest short hit, cut out to play as a hi-hat."""
    if "tgs_hat" not in _cache:
        x = _load(os.path.join(GS, "RBLX_DRUMS_TGS.wav")).mean(axis=1)
        env = np.sqrt(np.convolve(x ** 2, np.ones(441) / 441, "same"))
        onsets = np.where((env[1:] > 0.03) & (env[:-1] <= 0.03))[0]
        best, best_c = None, 0
        for o in onsets:
            seg = x[o:o + int(0.08 * SR)]
            if len(seg) < 512:
                continue
            spec = np.abs(np.fft.rfft(seg))
            centroid = np.sum(spec * np.arange(len(spec))) / (np.sum(spec) + 1e-9)
            if centroid > best_c:
                best, best_c = o, centroid
        hat = x[best:best + int(0.09 * SR)] * np.linspace(1, 0, int(0.09 * SR)) ** 2
        _cache["tgs_hat"] = np.stack([hat, hat], axis=1)
    return _cache["tgs_hat"]


class Track:
    """A stereo loop of `bars` bars at `bpm` (4 beats a bar) that notes and hits are laid on."""

    def __init__(self, bpm, bars, tail=4.0):
        self.bpm = bpm
        self.bars = bars
        self.length = int(round(bars * 4 * 60 / bpm * SR))
        self.buf = np.zeros((self.length + int(tail * SR), 2))
        self.rng = np.random.default_rng(bpm * 7 + bars)

    def at(self, beat):
        return int(round(beat * 60 / self.bpm * SR))

    def _add(self, sig, beat, gain, pan):
        i = max(0, self.at(beat) + int(self.rng.normal(0, 0.002) * SR))
        end = min(len(self.buf), i + len(sig))
        left, right = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
        self.buf[i:end, 0] += sig[: end - i, 0] * gain * left * 1.414
        self.buf[i:end, 1] += sig[: end - i, 1] * gain * right * 1.414

    def note(self, inst, beat, beats, midi, vel=100, pan=0.0, attack=0.004):
        """Plays an instrument's sample at a pitch for `beats` beats, then lets it go over its release; a slow `attack`
        (seconds) swells it in."""
        path, root, gain, release = INSTRUMENTS[inst]
        src = _load(path)
        ratio = 2 ** ((midi - root) / 12)
        hold = beats * 60 / self.bpm
        n = int((hold + release * 3) * SR)
        pos = np.arange(n) * ratio
        pos = pos[pos < len(src) - 1]
        sig = np.stack([np.interp(pos, np.arange(len(src)), src[:, c]) for c in (0, 1)], axis=1)
        t = np.arange(len(sig)) / SR
        env = np.minimum(t / attack, 1) * np.where(t < hold, 1.0, np.exp(-(t - hold) / release))
        v = (vel / 127) ** 1.6
        self._add(sig * env[:, None], beat, gain * v, pan)

    def sample(self, sig, beat, gain=1.0, pan=0.0):
        """Lays a mono sound (a synthesized hand drum, a shaker) at a beat."""
        self._add(np.stack([sig, sig], axis=1), beat, gain, pan)

    def drum(self, name, beat, vel=100, pan=0.0, pitch=1.0):
        src = _tgs_hat() if name == "hat" else _load(DRUMS[name])
        if pitch != 1.0:
            pos = np.arange(int(len(src) / pitch)) * pitch
            src = np.stack([np.interp(pos, np.arange(len(src)), src[:, c]) for c in (0, 1)], axis=1)
        self._add(src, beat, (vel / 127) ** 1.4, pan)

    def render(self, wet=0.22):
        """Folds the tail onto the start (seamless loop) and plays it in a small hall that wraps the same way."""
        out = self.buf[: self.length].copy()
        tail = self.buf[self.length:]
        k = min(len(tail), self.length)
        out[:k] += tail[:k]
        n = self.length
        t = np.arange(int(1.6 * SR)) / SR
        result = []
        for c in (0, 1):
            ir = self.rng.standard_normal(len(t)) * np.exp(-t * 6.9 / 1.3)
            ir = np.fft.irfft(np.fft.rfft(ir) / np.sqrt(1 + (np.fft.rfftfreq(len(ir), 1 / SR) / 5000) ** 2), len(ir))
            ir[: int(0.012 * SR)] *= np.linspace(0, 1, int(0.012 * SR))
            wetsig = np.fft.irfft(np.fft.rfft(out[:, c]) * np.fft.rfft(ir, n), n)
            g = (np.std(out[:, c]) + 1e-12) / (np.std(wetsig) + 1e-12)
            result.append(out[:, c] * (1 - wet) + wetsig * g * wet)
        return result[0], result[1]
