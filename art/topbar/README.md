# Worm Battlegrounds: top bar icons

The icons on the game's buttons in Roblox's top bar, beside the Settings gear (the owner's ask, 2026-11-13: "change
header leave game and mute music to be an custom svg icon"): **Leave game** (a door frame with an arrow leaving it), and
the music button's two looks, **Music** (two beamed notes) and **Music off** (the notes crossed out, cut clear around the
slash). White glyphs with round strokes on a 24 × 24 grid, drawn for the bar's dark round buttons.

| File | What |
| --- | --- |
| `make_icons.py` | The SVG sources (in code), rendered into `out/<Name>.svg` and `out/<Name>.png` (128 × 128, transparent, pixel-fixed), and `out/preview.png` (each icon on the button's colour, large and at its in-game 44 px) |
| `out/` | Made by the script, not kept in the repo |

## Build

Python 3 with Pillow and NumPy, and Chrome or Edge (drawn through `../crates/build.py`).

```bash
python -I make_icons.py
python -I make_icons.py --raw   # when headless Chrome or Edge won't start: from out/raw/<Name>.png, 256 x 256 renders of the SVGs
```

On 2026-11-13 headless Edge crashed on this PC (its GPU and network processes), so the SVGs were drawn on a canvas in
the Claude app's browser pane and built with `--raw`.

## In the game

| Icon | Used by |
| --- | --- |
| `TopBar_Leave` | MatchHud's `LEAVE_ICON`: Leave game, in matches |
| `TopBar_Music`, `TopBar_MusicOff` | TopBar_Controller's `MUSIC_ICON`, `MUSIC_OFF_ICON`: the music button, playing and muted |

## Uploading

Uploaded on 2026-11-13 at the owner's ask, as `../crates` did (README → Uploading): staged in `../sfx/out/upload/`,
sent through Open Cloud as Decals to The Snail Studio group (566704940), each image id read in Studio
(`InsertService:LoadAsset`, the Decal's `Texture`). All three passed moderation.

| Picture | Title | Decal | Image id |
| --- | --- | --- | --- |
| `TopBar_Leave` | TopBar Leave | 119082518528503 | 107990939394341 |
| `TopBar_Music` | TopBar Music | 109719345334471 | 101278000628566 |
| `TopBar_MusicOff` | TopBar Music Off | 85078518159765 | 117397305535105 |
