# Worm Battlegrounds: player badge icons

The five icons the game draws after a player's name (the owner's pick, 2026-11-10): **Game owner** (a gold crown),
**Developer** (a green coin with a white wrench), **Game admin** (a red shield with a white check), **Roblox staff** (a
red tilted square with a white square inside) and **Star creator** (a purple coin with a gold star). Verified and
Premium are Roblox's own glyphs (`U+E000`, `U+E001`), drawn by the game's text, so they have no picture here.

Each is an SVG on a 24 × 24 grid: bold shapes with the game's ink outline (`#19192A`, the chat bubble's), 1.5 units
outside every silhouette so it reads on the sky and over sand, and white or gold marks with a thin ink rim.

| File | What |
| --- | --- |
| `src/owner.svg`, `developer.svg`, `admin.svg`, `staff.svg`, `star.svg` | The sources |
| `build.py` | Renders them into `out/<name>.png` (128 × 128, transparent) and `preview.html`; `--studio` also copies the PNGs into Roblox Studio's content folder |
| `out/`, `preview.html` | Made by `build.py`, not kept in the repo |

## Build

Python 3 with Pillow, and Chrome or Edge (the SVGs are drawn by the browser, headless, at twice the size and scaled
down; `WB_BROWSER` names another Chromium browser).

```bash
python -I build.py            # out/*.png and preview.html
python -I build.py --studio   # the same, then into <Studio>/content/textures/wb_badges/
```

`preview.html` shows each icon large, then after a sample name at 18, 24 and 32 px on the sky and on sand.

## In the game

The game's `PlayerBadges` module lists the badges in `Settings.lua` (`BADGES`). Each picture row's `Image` is the
badge's uploaded `rbxassetid://` id. A local `rbxasset://textures/wb_badges/` copy (`build.py --studio`) shows only in
Studio on the PC that built it, and is blank on live servers.

## Uploading

Only when the owner says so:
1. Give the five PNGs PrepKit's pixel-fix.
2. Upload them to The Snail Studio group (Creator 566704940) as Decals, with plain titles.
3. Put each image id in its row's `Image` in `PlayerBadges/Settings.lua`.

The owner approved the upload on 2026-11-11, and all five passed moderation:

| Upload | Row | Title | Decal | Image id |
| --- | --- | --- | --- | --- |
| `out/owner.png` | `Owner` | Badge Crown | 94629238217739 | 103399252005394 |
| `out/developer.png` | `Developer` | Badge Wrench | 103241706532430 | 85832783383908 |
| `out/admin.png` | `Admin` | Badge Shield | 86581086662272 | 108039580969964 |
| `out/staff.png` | `Staff` | Badge Tilted Square | 131460692768892 | 101046945125974 |
| `out/star.png` | `Star` | Badge Star | 86516685687235 | 120533067442932 |
