"""Makes the skin snails' pictures for the Crates reel cards from Studio captures of the picture booth (README → Pictures).

The booth (`picture_booth.luau`, run in a playtest's client) shows each posed snail framed and lit as a Crates card's
S_Model viewport, six to a screen in 600 x 480 slots, once on black and once on white. Studio's screen capture of each
(1919 x 1078 game view, saved smaller as a JPEG) goes in here; the difference between the black and the white capture
gives each pixel's transparency, and the black one its colour. Each picture is saved as a 320 x 256 PNG.

    python -I make_pictures.py <a_black.jpg> <a_white.jpg> <b_black.jpg> <b_white.jpg>

Writes out/SnailSkin_<Model>.png, and copies them into ../sfx/out/upload/ for uploading.
"""
import os
import shutil
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
UPLOAD = os.path.join(HERE, "..", "sfx", "out", "upload")

# The booth's snails in its slot order (picture_booth.luau), six to a screen
ORDER = ["Classic", "Soldier", "Pirate", "Cowboy", "Ninja", "Knight", "Clown", "Devil", "Robot", "Skeleton"]
GAME_VIEW = (1919, 1078)  # the playtest's screen in gui pixels
SLOT = (600, 480)
PICTURE = (320, 256)  # the cards' picture box is 1.22 to 1.27 wide by 1 tall
INSET = 2  # pixels of each slot's edge left out (the capture blurs them into the next)


def slot_box(index, scale):
    """A slot's place in a capture (left, top, right, bottom), in the capture's pixels."""
    x = 60 + (index % 3) * 620
    y = 90 + (index // 3) * 500
    return (
        round(x * scale[0]) + INSET,
        round(y * scale[1]) + INSET,
        round((x + SLOT[0]) * scale[0]) - INSET,
        round((y + SLOT[1]) * scale[1]) - INSET,
    )


def matte(black, white):
    """A slot's RGBA from its black and white captures (float arrays, 0 to 255)."""
    # Each capture's own background, read from the slot's top rows (no snail reaches them)
    back_black = np.median(black[:12].reshape(-1, 3), axis=0)
    back_white = np.median(white[:12].reshape(-1, 3), axis=0)
    spread = float(np.mean(back_white - back_black))
    alpha = 1 - np.mean(white - black, axis=2) / spread
    alpha = np.clip(alpha, 0, 1)

    # JPEG noise: near-empty is empty, near-solid is solid
    alpha[alpha < 0.06] = 0
    alpha[alpha > 0.94] = 1
    colour = (black - (1 - alpha[..., None]) * back_black) / np.maximum(alpha[..., None], 1e-3)
    colour = np.clip(colour, 0, 255)
    colour[alpha == 0] = 0
    return colour, alpha


def shrink(colour, alpha):
    """Scales a picture down to PICTURE with its colour premultiplied, so edges don't pick up a fringe."""
    premultiplied = Image.fromarray((colour * alpha[..., None]).astype(np.uint8))
    mask = Image.fromarray((alpha * 255).astype(np.uint8))
    premultiplied = np.asarray(premultiplied.resize(PICTURE, Image.LANCZOS)).astype(np.float64)
    small_alpha = np.asarray(mask.resize(PICTURE, Image.LANCZOS)).astype(np.float64) / 255
    small = premultiplied / np.maximum(small_alpha[..., None], 1e-3)
    rgba = np.dstack([np.clip(small, 0, 255), small_alpha * 255]).astype(np.uint8)
    rgba[small_alpha == 0] = 0
    return Image.fromarray(rgba, "RGBA")


def run(captures):
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(UPLOAD, exist_ok=True)
    pairs = [(captures[0], captures[1]), (captures[2], captures[3])]
    for screen, (black_path, white_path) in enumerate(pairs):
        black_image = Image.open(black_path).convert("RGB")
        white_image = Image.open(white_path).convert("RGB")
        scale = (black_image.width / GAME_VIEW[0], black_image.height / GAME_VIEW[1])
        for index, name in enumerate(ORDER[screen * 6 : screen * 6 + 6]):
            box = slot_box(index, scale)
            black = np.asarray(black_image.crop(box)).astype(np.float64)
            white = np.asarray(white_image.crop(box)).astype(np.float64)
            picture = shrink(*matte(black, white))
            path = os.path.join(OUT, f"SnailSkin_{name}.png")
            picture.save(path)
            shutil.copy(path, os.path.join(UPLOAD, f"SnailSkin_{name}.png"))
            print(path)


if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    run(sys.argv[1:])
