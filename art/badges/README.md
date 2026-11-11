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

The game's `PlayerBadges` module lists the badges in `Settings.lua` (`BADGES`): each picture row's `Image` is
`rbxasset://textures/wb_badges/<name>.png` until the owner approves the icons. Such a picture shows only in a Studio
on the PC that ran `build.py --studio`, and blanks after the next Studio update (practices.md: pictures stay local
until the owner approves them).

## Uploading

Only when the owner says so: give the five PNGs PrepKit's pixel-fix, upload them to The Snail Studio group (Creator
566704940) as Decals or Images under plain titles ("Badge Crown", "Badge Wrench", "Badge Shield", "Badge Tilted
Square", "Badge Star"), and put each `rbxassetid://<id>` in its row's `Image` in `PlayerBadges/Settings.lua`: one
line per badge.

| Upload | Row |
| --- | --- |
| `out/owner.png` | `Owner` |
| `out/developer.png` | `Developer` |
| `out/admin.png` | `Admin` |
| `out/staff.png` | `Staff` |
| `out/star.png` | `Star` |
