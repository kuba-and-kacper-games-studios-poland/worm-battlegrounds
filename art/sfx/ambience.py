"""Level ambience for the themes, numpy only: every layer is built at the loop's length with its events wrapping round
the end and its filters done over the whole loop (FFT), so it loops with the music without a seam. Stereo: each side
gets its own noise, and events are panned. The wind is Roblox's own falling-wind recording (the owner, 2026-11-10: the
synthesized wind was too heavy), kept light.
"""

import os
import wave

import numpy as np

from snaillib import HERE, SR, band, spec

_rng = np.random.default_rng(11)


def reseed(seed):
    global _rng
    _rng = np.random.default_rng(seed)


def _n(seconds):
    return int(round(seconds * SR))


def _t(seconds):
    return np.arange(_n(seconds)) / SR


def wrap_add(buf, sig, at, gain=1.0, pan=0.0):
    """Adds a mono event into a stereo loop at `at` seconds, wrapping round the end, panned -1..1."""
    i = int(round(at * SR)) % buf.shape[0]
    idx = (np.arange(len(sig)) + i) % buf.shape[0]
    left, right = np.cos((pan + 1) * np.pi / 4) * 1.414, np.sin((pan + 1) * np.pi / 4) * 1.414
    np.add.at(buf[:, 0], idx, sig * gain * left)
    np.add.at(buf[:, 1], idx, sig * gain * right)


def _breathe(n, rate_hz, depth):
    """A slow random 0..1 swell (circular)."""
    y = spec(_rng.standard_normal(n), hi=rate_hz, order=2)
    y = y / (np.max(np.abs(y)) + 1e-9)
    return 1 - depth + depth * (0.5 + 0.5 * y)


# --- beds --------------------------------------------------------------------------------------------------------------

WIND = os.path.join(HERE, "tools", "classic", "sfx", "action_falling.wav")
_falling = None


def _falling_loop():
    """Roblox's own falling wind (the client's content/sounds/action_falling.ogg), its end folded onto its start."""
    global _falling
    if _falling is None:
        with wave.open(WIND) as w:
            ch = w.getnchannels()
            x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64).reshape(-1, ch).mean(axis=1)
        k = _n(0.5)
        body = x[:-k].copy()
        body[:k] = body[:k] * np.sqrt(np.linspace(0, 1, k)) + x[-k:] * np.sqrt(np.linspace(1, 0, k))
        _falling = body / (np.std(body) + 1e-12)
    return _falling


def wind(seconds, rate=1.15, swing=0.3, gust=0.7, gust_rate=0.1, lo=300.0, hi=6000.0):
    """Light wind from Roblox's falling-wind recording: read faster as each gust blows (so it brightens), swelling and
    dying away, its rumble cut, each side from its own place in the recording. Wraps at `seconds`."""
    src = _falling_loop()
    n, k = _n(seconds), _n(1.0)
    out = np.zeros((n, 2))
    for c in (0, 1):
        swell = _breathe(n, gust_rate, 1.0)[np.arange(n + k) % n]
        pos = (_rng.uniform(0, len(src)) + np.cumsum(rate * (1 + swing * (swell - 0.5)))) % (len(src) - 1)
        y = np.interp(pos, np.arange(len(src)), src) * (1 - gust + gust * swell ** 1.5)
        # The second after the end plays over the start, so the loop goes on where it left off
        head = y[:n].copy()
        head[:k] = head[:k] * np.sqrt(np.linspace(0, 1, k)) + y[n:] * np.sqrt(np.linspace(1, 0, k))
        out[:, c] = spec(head, lo=lo, hi=hi, order=2)
    return out / (np.std(out) + 1e-12)


def wind_whistle(seconds, f_lo=500, f_hi=1100, rate=0.07):
    """Mountain wind: a narrow resonance gliding slowly over gusting noise (the whistle round rocks)."""
    n = _n(seconds)
    out = np.zeros((n, 2))
    for c in (0, 1):
        x = _rng.standard_normal(n)
        # A few overlapping narrow bands whose levels swell at different times stand in for a moving resonance
        y = np.zeros(n)
        for f in np.linspace(f_lo, f_hi, 5):
            y += band(x, f * _rng.uniform(0.95, 1.05), 18) * _breathe(n, rate * _rng.uniform(0.7, 1.3), 1.0) ** 3
        out[:, c] = y / (np.std(y) + 1e-9)
    return out


def sand_hiss(seconds, rate=0.15):
    """Desert wind carrying sand: a soft hiss swelling and falling."""
    n = _n(seconds)
    out = np.zeros((n, 2))
    for c in (0, 1):
        x = spec(spec(_rng.standard_normal(n), lo=2500, order=2), hi=6000, order=2)
        out[:, c] = x / (np.std(x) + 1e-9) * _breathe(n, rate, 0.9) ** 2
    return out


def lava_rumble(seconds):
    """A molten sea's low boil: deep rumble breathing slowly."""
    n = _n(seconds)
    out = np.zeros((n, 2))
    for c in (0, 1):
        x = spec(spec(_rng.standard_normal(n), hi=140, order=2), lo=25, order=1)
        out[:, c] = x / (np.std(x) + 1e-9) * _breathe(n, 0.2, 0.6)
    return out


# --- events ----------------------------------------------------------------------------------------------------------

def _scatter(seconds, count, make, gain=(0.5, 1.0), spread=0.8):
    n = _n(seconds)
    out = np.zeros((n, 2))
    for _ in range(count):
        wrap_add(out, make(), _rng.uniform(0, seconds), _rng.uniform(*gain), _rng.uniform(-spread, spread))
    return out


def _chirp(f0, f1, dur, harmonics=(1, 0.25), vibrato=0.0, vib_hz=30):
    t = _t(dur)
    f = f0 * (f1 / f0) ** (t / dur) * (1 + vibrato * np.sin(2 * np.pi * vib_hz * t))
    ph = 2 * np.pi * np.cumsum(f) / SR
    y = sum(g * np.sin((k + 1) * ph) for k, g in enumerate(harmonics))
    return y * np.sin(np.pi * t / dur) ** 0.7


def bird_call():
    """One songbird phrase: a warble, a two-note whistle or a run of chirps."""
    kind = _rng.integers(3)
    if kind == 0:
        notes = [_chirp(_rng.uniform(2600, 3600), _rng.uniform(3000, 4400), _rng.uniform(0.05, 0.09), vibrato=0.04)
                 for _ in range(_rng.integers(4, 9))]
    elif kind == 1:
        f = _rng.uniform(1800, 2600)
        notes = [_chirp(f, f * 1.02, 0.18), np.zeros(_n(0.06)), _chirp(f * 0.8, f * 0.78, 0.22)]
    else:
        notes = []
        for _ in range(_rng.integers(3, 7)):
            notes += [_chirp(_rng.uniform(3500, 5000), _rng.uniform(2200, 3000), 0.035), np.zeros(_n(0.05))]
    return np.concatenate(notes) * 0.5


def birds(seconds, per_minute=10):
    return _scatter(seconds, int(per_minute * seconds / 60), bird_call, (0.25, 0.8))


def cricket():
    """A cricket's chirp: a 4.6 kHz tone pulsed fast, in a few bursts."""
    parts = []
    for _ in range(_rng.integers(2, 5)):
        t = _t(0.12)
        pulses = (np.sin(2 * np.pi * 32 * t) > 0.2).astype(float)
        parts += [np.sin(2 * np.pi * 4600 * t) * pulses * np.sin(np.pi * t / 0.12), np.zeros(_n(0.1))]
    return np.concatenate(parts) * 0.25


def crickets(seconds, per_minute=24):
    return _scatter(seconds, int(per_minute * seconds / 60), cricket, (0.3, 0.8))


def rustle():
    d = _rng.uniform(0.4, 1.0)
    x = band(_rng.standard_normal(_n(d)), _rng.uniform(2000, 4000), 1.2)
    grains = (np.random.default_rng(int(_rng.integers(1 << 30))).random(_n(d)) < 0.02).astype(float)
    return x * np.convolve(grains, np.ones(200) / 20, "same") * np.sin(np.pi * _t(d) / d) * 0.6


def leaves(seconds, per_minute=8):
    return _scatter(seconds, int(per_minute * seconds / 60), rustle, (0.3, 0.7))


def rockfall():
    """Stones tumbling somewhere off on the ridge: low clatter thinning out, far away."""
    d = _rng.uniform(1.0, 2.0)
    out = np.zeros(_n(d))
    for _ in range(_rng.integers(10, 25)):
        at = d * _rng.random() ** 1.6
        g = _rng.uniform(0.004, 0.02)
        hit = band(_rng.standard_normal(_n(g)), _rng.uniform(300, 1400), 2) * np.exp(-_t(g) / (g / 3))
        i = _n(at)
        out[i:i + len(hit)] += hit[: len(out) - i] * (1 - at / d)
    rumble = spec(_rng.standard_normal(_n(d)), hi=120) * np.exp(-_t(d) / (d / 2)) * 0.6
    return spec(out + rumble, hi=2500) * 0.8


def rockfalls(seconds, per_minute=2):
    return _scatter(seconds, max(1, int(per_minute * seconds / 60)), rockfall, (0.4, 0.8))


def hawk():
    """A hawk's cry, far off: a falling scream with a rough vibrato."""
    d = 0.9
    t = _t(d)
    f = 2700 * (1900 / 2700) ** (t / d) * (1 + 0.03 * np.sin(2 * np.pi * 18 * t))
    y = np.sin(2 * np.pi * np.cumsum(f) / SR) + 0.3 * np.sin(4 * np.pi * np.cumsum(f) / SR)
    return spec(y * np.sin(np.pi * t / d) ** 0.5, hi=3500) * 0.35


def hawks(seconds, count=1):
    return _scatter(seconds, count, hawk, (0.3, 0.5), 0.9)


def lava_bubble():
    """A thick bubble rising and popping in the lava."""
    d = _rng.uniform(0.12, 0.3)
    t = _t(d)
    f = _rng.uniform(55, 90) * (1 + 1.5 * t / d)
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * t / d)
    pop = spec(_rng.standard_normal(_n(0.01)), lo=500) * np.exp(-_t(0.01) / 0.003)
    return np.concatenate([body, pop * 0.4])


def lava_bubbles(seconds, per_minute=50):
    return _scatter(seconds, int(per_minute * seconds / 60), lava_bubble, (0.3, 1.0), 0.6)


def crackle(seconds, per_second=6):
    """Embers and cooling crust ticking."""
    n = _n(seconds)
    out = np.zeros((n, 2))
    for c in (0, 1):
        imp = (_rng.random(n) < per_second / SR) * _rng.random(n)
        out[:, c] = band(np.convolve(imp, np.exp(-_t(0.003) / 0.0008), "same"), 2600, 1.2)
    return out / (np.std(out) + 1e-9)


def drip():
    """A water drop into the oasis: a fast rising bubble chirp with a tick."""
    d = 0.16
    t = _t(d)
    f = 900 + 1100 * (1 - np.exp(-t / 0.012))
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.03) * np.clip(t / 0.0015, 0, 1) * 0.6


def drips(seconds, per_minute=14):
    return _scatter(seconds, int(per_minute * seconds / 60), drip, (0.2, 0.6), 0.7)


def sounding_rms(layer):
    """RMS while a layer sounds, its quiet gaps left out, so a sparse layer's calls are as loud as its level says."""
    mono = layer.mean(axis=1)
    w = _n(0.05)
    c = np.concatenate([[0.0], np.cumsum(mono ** 2)])
    env = np.sqrt(np.maximum(c[w:] - c[:-w], 0) / w)
    on = np.zeros(len(mono), bool)
    on[: len(env)] = env > 0.1 * env.max()
    if not on.any():
        return 1.0  # a silent layer (no events) stays silent
    return np.sqrt(np.mean(layer[on] ** 2)) + 1e-12


def mix_layers(*layers):
    """layers: (stereo array, level in dB). Each is set to its level while it sounds, and they're summed."""
    n = max(layer.shape[0] for layer, _db in layers)
    out = np.zeros((n, 2))
    for layer, target in layers:
        out[: layer.shape[0]] += layer * (10 ** (target / 20) / sounding_rms(layer))
    return out
