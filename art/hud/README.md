# Worm Battlegrounds: hud pictures

Pictures the match hud draws that no design has.

| File | What |
| --- | --- |
| `make_turn_arrow.py` | The turn arrow (the owner's ask, 2026-11-11, from Worms Armageddon's bouncing arrow): a fat red arrow pointing down with the icons' ink outline, a light left edge and a darker right side, as an SVG drawn by Chrome or Edge through `../crates/build.py` into `out/TurnArrow.png` (128 × 160), then copied into Studio's content folder |
| `out/` | Made by the script, not kept in the repo |

## Build

```bash
python -I make_turn_arrow.py
```

## In the game

The SnailTag gui's `S_Arrow`, over the snail whose turn it is (the Snails module drops it in and bobs it).

## Uploading

Approved by the owner on 2026-11-11 and uploaded as `../crates` did (README → Uploading): staged in `../sfx/out/upload/`,
sent through Open Cloud as a Decal to The Snail Studio group (566704940), its image id read in Studio
(`InsertService:LoadAsset`, the Decal's `Texture`).

| Picture | Decal | Image id | Used by |
| --- | --- | --- | --- |
| `TurnArrow` ("Snail Turn Arrow") | 87256015728687 | 107929925047000 | SnailTag's `S_Arrow` |

The script still copies the PNG into Studio's content folder (`rbxasset://textures/wb_hud/`) for trying a redraw before
it's uploaded again.
