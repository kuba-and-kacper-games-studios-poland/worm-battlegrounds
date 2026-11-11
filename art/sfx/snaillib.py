"""Shared DSP for Worm Battlegrounds' own sounds: numpy only (no scipy), after the farm game's cavelib.

One-shots are built dry-ish with a short outdoor tail (the game places them in the world), cartoon-punchy: short
sub energy, bright transients, soft-clipped. Loops are built circular so they have no seam.
"""

import os
import subprocess
import wave

import numpy as np

SR = 44100
rng = np.random.default_rng(7)


def reseed(seed):
    global rng
    rng = np.random.default_rng(seed)


def N(seconds):
    return max(1, int(round(seconds * SR)))


def tt(seconds):
    return np.arange(N(seconds)) / SR


def db(x):
    return 20 * np.log10(max(x, 1e-12))


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


NOTE_NAMES = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
              "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}


def note(name):
    """'E5' -> 76 (C4 = 60)."""
    return 12 * (int(name[-1]) + 1) + NOTE_NAMES[name[:-1]]


# --- filters ---------------------------------------------------------------------------------------------------------

def spec(x, lo=None, hi=None, order=2):
    """Zero-phase Butterworth-shaped high/low-pass over the whole signal."""
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR) + 1e-9
    H = np.ones_like(f)
    if hi:
        H /= np.sqrt(1 + (f / hi) ** (2 * order))
    if lo:
        H /= np.sqrt(1 + (lo / f) ** (2 * order))
    return np.fft.irfft(X * H, len(x))


def band(x, fc, q=2.0, order=2):
    """A band-pass round fc, about fc/q wide."""
    w = fc / q
    return spec(x, lo=max(fc - w / 2, 10), hi=fc + w / 2, order=order)


def peak(x, fc, q=4.0, gain_db=6.0):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR) + 1e-9
    g = 10 ** (gain_db / 20) - 1
    H = 1 + g / (1 + (q * (f / fc - fc / f)) ** 2)
    return np.fft.irfft(X * H, len(x))


def sweep(x, start_hz, end_hz, kind="lp", order=2, curve=1.0, frame=1024, hop=256):
    """A filter whose cutoff glides from start_hz to end_hz over the sound (log glide, shaped by curve), by STFT."""
    n = len(x)
    pad = np.concatenate([np.zeros(frame), x, np.zeros(frame)])
    win = np.hanning(frame)
    out = np.zeros(len(pad))
    norm = np.zeros(len(pad))
    f = np.fft.rfftfreq(frame, 1 / SR) + 1e-9
    for s in range(0, len(pad) - frame, hop):
        p = np.clip((s - frame) / max(n, 1), 0, 1) ** curve
        fc = start_hz * (end_hz / start_hz) ** p
        H = 1 / np.sqrt(1 + (f / fc) ** (2 * order)) if kind == "lp" else 1 / np.sqrt(1 + (fc / f) ** (2 * order))
        seg = np.fft.irfft(np.fft.rfft(pad[s:s + frame] * win) * H, frame)
        out[s:s + frame] += seg * win
        norm[s:s + frame] += win ** 2
    out /= np.maximum(norm, 1e-6)
    return out[frame:frame + n]


def bandsweep(x, start_hz, end_hz, q=2.0, curve=1.0):
    """A band-pass gliding from start_hz to end_hz."""
    return sweep(sweep(x, start_hz * (1 + 0.5 / q), end_hz * (1 + 0.5 / q), "lp", curve=curve),
                 start_hz * (1 - 0.5 / q), end_hz * (1 - 0.5 / q), "hp", curve=curve)


# --- sources ---------------------------------------------------------------------------------------------------------

def noise(n):
    return rng.standard_normal(n)


def osc(freq, seconds, shape="sine", phase=0.0):
    """An oscillator; freq may be a number or an array (per sample)."""
    n = N(seconds)
    f = np.broadcast_to(np.asarray(freq, float), (n,))
    ph = np.cumsum(f) / SR + phase
    if shape == "sine":
        return np.sin(2 * np.pi * ph)
    if shape == "tri":
        return 2 * np.abs(2 * (ph % 1) - 1) - 1
    if shape == "square":
        return np.sign(np.sin(2 * np.pi * ph))
    return 2 * (ph % 1) - 1  # saw


def glide(f0, f1, seconds, curve="exp", tau=None):
    """A pitch curve from f0 to f1: 'exp' settles fast (tau), 'log' glides evenly in pitch."""
    t = tt(seconds)
    if curve == "exp":
        return f1 + (f0 - f1) * np.exp(-t / (tau or seconds / 4))
    return f0 * (f1 / f0) ** (t / seconds)


def decay(seconds, tau, attack=0.002):
    t = tt(seconds)
    return np.exp(-t / tau) * np.clip(t / max(attack, 1e-5), 0, 1)


def ar(seconds, attack, release_curve=2.0):
    n = N(seconds)
    ia = min(n, max(1, N(attack)))
    e = np.ones(n)
    e[:ia] = np.linspace(0, 1, ia)
    if n > ia:
        e[ia:] = np.linspace(1, 0, n - ia) ** release_curve
    return e


def swell(seconds, peak_at=0.7, curve=2.0):
    """Rises to its peak at peak_at of the length, then falls away."""
    n = N(seconds)
    t = np.linspace(0, 1, n)
    up = (t / peak_at) ** curve
    down = ((1 - t) / (1 - peak_at)) ** 1.5
    return np.where(t < peak_at, up, down)


def modal(freqs, decays, gains, seconds):
    t = tt(seconds)
    out = np.zeros(len(t))
    for f, d, g in zip(freqs, decays, gains):
        if f < SR * 0.45:
            out += g * np.sin(2 * np.pi * f * t + rng.uniform(0, 6.28)) * np.exp(-t / d)
    return out * np.clip(t / 0.0008, 0, 1)


def mallet(midi, seconds=1.2, kind="marimba", vel=1.0):
    """Tuned percussion from modal partials: marimba (woody, 1:4:10), glock (bright, inharmonic), bell (long)."""
    f = hz(midi)
    if kind == "marimba":
        return vel * modal([f, f * 3.93, f * 9.9], [0.35, 0.06, 0.02], [1, 0.35, 0.12], seconds)
    if kind == "glock":
        return vel * modal([f, f * 2.76, f * 5.40, f * 8.93], [0.9, 0.25, 0.08, 0.03], [1, 0.5, 0.25, 0.1], seconds)
    if kind == "xylo":
        return vel * modal([f, f * 3.0, f * 6.2], [0.18, 0.05, 0.015], [1, 0.4, 0.15], seconds)
    if kind == "wood":
        return vel * modal([f, f * 1.47, f * 2.09], [0.025, 0.015, 0.01], [1, 0.6, 0.3], seconds)
    # bell: tubular-ish
    return vel * modal([f, f * 2.0, f * 2.76, f * 3.98, f * 5.4], [2.2, 1.4, 0.9, 0.5, 0.3], [1, 0.6, 0.45, 0.3, 0.2],
                       seconds)


def thump(f0=120, f1=45, glide_s=0.03, tau=0.12, seconds=None, vel=1.0):
    t = tt(seconds or tau * 6)
    f = f1 + (f0 - f1) * np.exp(-t / glide_s)
    return vel * np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / tau) * np.clip(t / 0.002, 0, 1)


def click(seconds=0.006, lo=2000):
    return spec(noise(N(seconds)) * np.exp(-tt(seconds) / (seconds / 4)), lo=lo)


def grains(seconds, count, f_lo, f_hi, dur=(0.005, 0.015), density_fall=2.0, start=0.0):
    """Debris patter: short band-passed noise ticks thinning out over time."""
    out = np.zeros(N(seconds))
    for _ in range(count):
        at = start + (seconds - start) * rng.random() ** density_fall
        d = rng.uniform(*dur)
        g = band(noise(N(d)) * np.exp(-tt(d) / (d / 3)), rng.uniform(f_lo, f_hi), 2.5)
        place(out, g, at, rng.uniform(0.3, 1.0) * (1 - at / seconds) ** 1.5)
    return out


def bubble(f0=300, f1=900, seconds=0.05, vel=1.0):
    t = tt(seconds)
    f = f0 * (f1 / f0) ** (t / seconds)
    return vel * np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * t / seconds) ** 0.6


def gibber(syllables, base=330, seconds_each=0.1, seed=None):
    """'Animalese' babble: a saw per syllable through two formants, pitch per syllable."""
    r = np.random.default_rng(seed)
    out = []
    for i, pitch in enumerate(syllables):
        d = seconds_each * r.uniform(0.85, 1.2)
        f = base * pitch * glide(1.05, 0.97, d, "log")
        src = osc(f, d, "saw") * ar(d, 0.012, 1.4)
        f1, f2 = r.uniform(500, 850), r.uniform(1200, 2100)
        y = band(src, f1, 3) * 1.0 + band(src, f2, 4) * 0.7
        out.append(y)
        out.append(np.zeros(N(0.018)))
    return np.concatenate(out)


# --- assembly --------------------------------------------------------------------------------------------------------

def place(buf, sig, at, gain=1.0):
    i = int(round(at * SR))
    end = min(len(buf), i + len(sig))
    if end > i:
        buf[i:end] += sig[: end - i] * gain
    return buf


def mix(seconds, *parts):
    """parts: (signal, at_seconds, gain)."""
    out = np.zeros(N(seconds))
    for sig, at, g in parts:
        place(out, sig, at, g)
    return out


def fit(x, seconds):
    n = N(seconds)
    return x[:n] if len(x) >= n else np.concatenate([x, np.zeros(n - len(x))])


def fade(x, a=0.002, b=0.05):
    y = x.copy()
    ia, ib = min(len(y), N(a)), min(len(y), N(b))
    y[:ia] *= np.linspace(0, 1, ia)
    y[len(y) - ib:] *= np.linspace(1, 0, ib)
    return y


def drive(x, amount=2.0):
    return np.tanh(x * amount) / np.tanh(amount)


def conv(x, k):
    n = len(x) + len(k) - 1
    return np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(k, n), n)


def room(x, wet=0.18, seconds=0.9, decay_s=0.5, damp=4500.0, circular=False):
    """A small outdoor tail: dense noise decaying, darker as it goes."""
    n = N(seconds)
    t = np.arange(n) / SR
    ir = rng.standard_normal(n) * np.exp(-t * 6.9 / decay_s)
    ir = spec(ir, hi=damp, order=1)
    ir[: N(0.01)] *= np.linspace(0, 1, N(0.01))
    if circular:
        wetsig = np.fft.irfft(np.fft.rfft(x) * np.fft.rfft(ir, len(x)), len(x))
        dry = x
    else:
        wetsig = conv(x, ir)
        dry = np.concatenate([x, np.zeros(len(wetsig) - len(x))])
    g = (np.std(x) + 1e-12) / (np.std(wetsig) + 1e-12)
    return dry * (1 - wet) + wetsig * g * wet


def loop_seam(x, overlap=0.08):
    """Makes a loop seamless by crossfading its tail into its head."""
    o = N(overlap)
    y = x[:-o].copy()
    y[:o] = y[:o] * np.linspace(0, 1, o) + x[-o:] * np.linspace(1, 0, o)
    return y


# --- levels and files ------------------------------------------------------------------------------------------------

def rms_db(x):
    return db(np.sqrt(np.mean(np.square(x))))


def loudest_db(x, window=0.3):
    w = N(window)
    if len(x) <= w:
        return rms_db(x)
    s = np.concatenate([[0.0], np.cumsum(np.square(x))])
    return db(np.sqrt(np.max((s[w:] - s[:-w]) / w)))


def level(x, target_db, measure="loudest"):
    """Scales a one-shot so its loudest 0.3 s (or whole RMS) sits at target_db, then soft-limits under -1 dBFS."""
    now = loudest_db(x) if measure == "loudest" else rms_db(x)
    y = x * 10 ** ((target_db - now) / 20)
    return np.tanh(y / 0.89) * 0.89


def write(path, x):
    pcm = (np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def to_ogg(wav_path, quality=5):
    out = os.path.splitext(wav_path)[0] + ".ogg"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav_path, "-codec:a", "libvorbis", "-q:a", str(quality),
                    out], check=True)
    return out


# --- stereo files, MIDI and FluidSynth (music) -----------------------------------------------------------------------

HERE = os.path.dirname(os.path.abspath(__file__))
FLUIDSYNTH = os.environ.get("WB_FLUIDSYNTH", os.path.join(
    HERE, "tools", "fluidsynth", "fluidsynth-v2.6.2-win10-x64-cpp11", "bin", "fluidsynth.exe"))
SOUNDFONT = os.environ.get("WB_SOUNDFONT", os.path.join(HERE, "tools", "soundfont", "GeneralUser-GS.sf2"))
TPQ = 480


def write_stereo(path, left, right):
    data = np.stack([left, right], axis=1)
    pcm = (np.clip(data, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def read_stereo(path):
    with wave.open(path) as w:
        ch = w.getnchannels()
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64) / 32768
    x = x.reshape(-1, ch)
    return x[:, 0].copy(), x[:, 1 if ch > 1 else 0].copy()


def _vlq(x):
    out = [x & 0x7F]
    x >>= 7
    while x:
        out.append((x & 0x7F) | 0x80)
        x >>= 7
    return bytes(reversed(out))


class Song:
    """A Standard MIDI File in beats at one tempo (after the farm game's)."""

    def __init__(self, bpm, seed=3):
        self.bpm = bpm
        self.ev = []
        self.r = np.random.default_rng(seed)

    def tick(self, beats):
        return max(0, int(round(beats * TPQ)))

    def program(self, ch, prog, bank=0, at=0.0):
        if bank is not None:
            self.ev.append((self.tick(at), 0, ch, bytes([0xB0 | ch, 0, bank])))
        self.ev.append((self.tick(at), 0, ch, bytes([0xC0 | ch, prog])))

    def cc(self, ch, num, val, at=0.0):
        self.ev.append((self.tick(at), 1, ch, bytes([0xB0 | ch, num, int(max(0, min(127, val)))])))

    def bend(self, ch, semis, at, rng_semis=2.0):
        v = int(max(0, min(16383, 8192 + semis / rng_semis * 8192)))
        self.ev.append((self.tick(at), 1, ch, bytes([0xE0 | ch, v & 0x7F, v >> 7])))

    def note(self, ch, at, dur, pitch, vel, jitter=0.008, vjit=6):
        sec = 60 / self.bpm
        at = max(0.0, at + self.r.normal(0, jitter / sec)) if jitter else at
        vel = int(max(1, min(127, vel + self.r.integers(-vjit, vjit + 1)))) if vjit else int(vel)
        a, b = self.tick(at), self.tick(at + dur)
        self.ev.append((a, 3, ch, bytes([0x90 | ch, int(pitch), vel])))
        self.ev.append((max(a + 1, b), 2, ch, bytes([0x80 | ch, int(pitch), 0])))

    def write(self, path):
        import struct
        evs = sorted(self.ev, key=lambda e: (e[0], e[1]))
        tracks = []
        tempo = int(60_000_000 / self.bpm)
        tracks.append(b"\x00\xFF\x51\x03" + tempo.to_bytes(3, "big") + b"\x00\xFF\x2F\x00")
        for c in sorted({e[2] for e in evs}):
            data, last = b"", 0
            for t, _o, ch, msg in evs:
                if ch == c:
                    data += _vlq(t - last) + msg
                    last = t
            tracks.append(data + b"\x00\xFF\x2F\x00")
        with open(path, "wb") as f:
            f.write(b"MThd" + struct.pack(">IHHH", 6, 1, len(tracks), TPQ))
            for tr in tracks:
                f.write(b"MTrk" + struct.pack(">I", len(tr)) + tr)


CLASSIC = {
    "GreatStrategy": os.path.join(HERE, "tools", "classic", "GreatStrategy.sf2"),
    "StealthPilot": os.path.join(HERE, "tools", "classic", "StealthPilot.sf2"),
}


def render_midi(mid, wav, gain=0.6, room=0.55, level_=0.35, soundfont=None):
    """Renders a MIDI file with FluidSynth through a bank (GeneralUser GS unless named). Returns (L, R)."""
    soundfont = soundfont or SOUNDFONT
    if not os.path.exists(FLUIDSYNTH) or not os.path.exists(soundfont):
        raise SystemExit(f"FluidSynth or the sound bank is missing: {FLUIDSYNTH} / {soundfont} (README.md)")
    subprocess.run([FLUIDSYNTH, "-ni", "-q", "-g", str(gain), "-r", str(SR), "-F", wav,
                    "-o", f"synth.reverb.room-size={room}", "-o", f"synth.reverb.level={level_}",
                    "-o", "synth.reverb.width=0.9", "-o", "synth.reverb.damp=0.4",
                    "-o", "synth.chorus.active=0", "-o", "synth.polyphony=256", soundfont, mid],
                   check=True, stdout=subprocess.DEVNULL)
    return read_stereo(wav)


def level_stereo(left, right, target_db, measure="rms"):
    mono = (left + right) / 2
    now = rms_db(mono) if measure == "rms" else loudest_db(mono)
    g = 10 ** ((target_db - now) / 20)
    return np.tanh(left * g / 0.89) * 0.89, np.tanh(right * g / 0.89) * 0.89
