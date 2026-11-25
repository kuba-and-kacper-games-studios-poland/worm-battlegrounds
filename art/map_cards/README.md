# Map cards

The pictures of the maps in rotation on the lobby's public cards (MatchBoard's `MAPS` → `Thumbnail`, 1024 × 272) and on
the custom lobby's and the setup's map tiles (`TileThumbnail`, 512 × 303). Each is a shot of the map in a real match,
with its own lighting, sea and parallax backdrop, cut to the cards' slanted, rounded shape.

| File | What |
| --- | --- |
| `make_cards.py` | Crops each shot to the card and tile, cuts it to the shape, writes `out/<Map>_card.png`, `out/<Map>_tile.png` and `out/preview_sheet.png` |
| `out/shots/<Map>.jpg` | The Studio captures it cuts from (kept with the outputs, not in the repo) |

## The shape

Measured from the uploaded pictures of 2026-11-14 and 2026-11-15 (read in Studio with `EditableImage`): a
parallelogram whose sides move left 0.107 px per row, with rounded corners. The card's left and right edges stand at
30.9 and 1021.4 px at the top, radius 25; the tile's at 33.2 and 509.6, radius 33. `make_cards.py` draws it
supersampled, so the edges are smooth.

## Shooting a map

In a Studio play test: start a solo match on the map (`MatchBoard_PlaySolo` with the map id, from a LocalScript in the
game's VM), then a LocalScript bound after the camera (`RenderPriority.Camera + 5`) points a scriptable camera at the
map (field of view 30, looking along −Z), hides the ScreenGuis and billboards and the snails
(`LocalTransparencyModifier`), and the frame is captured. 2026-11-25: Desert and Rolling Plains from (0, 48, 160)
looking at (0, 40, 0); Echo Caverns from (0, 70, 215) looking at (0, 62, 0). The crops are in `make_cards.py`.

## Uploading

Only when the owner says so: copy the six PNGs into `../sfx/out/upload/<date>-map-cards/` (Studio's approved Open
Cloud folder), upload each as a Decal to The Snail Studio group (566704940), then read each image id in Studio
(`InsertService:LoadAsset(decal)`, the Decal's `Texture`) and put it in `MAPS`.

The 2026-11-25 set (the owner approved it; all six passed moderation):

| Map | Picture | Title | Decal | Image id |
| --- | --- | --- | --- | --- |
| Desert | Card | Snail Map Card Desert v2 | 132202762361220 | 81138287783963 |
| Desert | Tile | Snail Map Tile Desert v2 | 79595345064288 | 113826869502887 |
| Echo Caverns | Card | Snail Map Card Echo Caverns v2 | 123297460913957 | 128031100933800 |
| Echo Caverns | Tile | Snail Map Tile Echo Caverns v2 | 112454008937053 | 93769256053322 |
| Rolling Plains | Card | Snail Map Card Rolling Plains v2 | 74018742939681 | 92320287823767 |
| Rolling Plains | Tile | Snail Map Tile Rolling Plains v2 | 102631519676246 | 80399475408535 |

They replace Desert's 83756913609980 / 95484779686713, Echo Caverns' 97183016065357 / 113242205351682 (its old cave)
and Rolling Plains' 118659936926806 / 119350227368156.
