# Worm Battlegrounds: ui glyphs

One minimal icon for each lobby button and mode, in the look of the studio's `LobbyRework` icons (DEATHMATCH, DUO,
TRIO and the player count, 2026-11-24): solid white shapes with a thick ink outline round the whole glyph, no colour,
no gloss. They replace the mode icons (`art/modes`) and the menu's drawn pictures on the lobby's buttons; weapon and
item pictures keep their own look.

| Icon | Used for | What it shows |
| --- | --- | --- |
| `deathmatch` | Deathmatch | A white disc with an ink crosshair in it |
| `duo` | Duo | Two people, the back one up and to the right |
| `trio` | Trio, party | Three people, the middle one in front |
| `play` | Play solo | The play triangle, its corners rounded |
| `local` | Local | A gamepad, its cross and two buttons cut in ink |
| `custom` | Custom | Three sliders, each a bar with a round knob |
| `freeweapons` | Free weapons | A weapon crate: its lid over the box, a star cut into its front (the gift box until 2026-11-24) |
| `style` | Style | A paint brush, slanted, its tip down to the left |
| `weapons` | Weapons | A rocket, slanted up to the right, with fins and a window cut in ink |
| `skins` | Skins | A snail's shell with its spiral in ink |
| `easy` | Easy bots | A smiling face, its eyes and smile in ink |
| `medium` | Medium bots | A set face: brows down toward the middle, a straight mouth |
| `hard` | Hard bots | A skull: eye sockets, nose and the gaps between its teeth in ink |

Each is an SVG on a 64 × 64 grid, drawn inside 6 to 58 so they line up at one size: white (`#ffffff`) with a 6-unit
ink outline (`#0c0c14`) drawn under the fill, so it only grows the shape outwards; cut-outs inside a glyph are ink.

| File | What |
| --- | --- |
| `glyphs.py` | Draws every glyph into `src/` |
| `src/<icon>.svg` | The sources, written by `glyphs.py` |
| `build.py` | Renders them into `out/<icon>.png` (256 × 256, transparent, with the pixel fix) and `preview.html` |
| `out/`, `preview.html` | Made by `build.py`, not kept in the repo |

## Build

Python 3 with Pillow and NumPy, and Chrome or Edge (the SVGs are drawn by the browser, headless, at twice the size and
scaled down; `WB_BROWSER` names another Chromium browser).

```bash
python -I glyphs.py           # src/*.svg
python -I build.py            # out/*.png and preview.html
```

`preview.html` shows each glyph large, then at the sizes the game shows them, on a dark card and on the sky.

## In the game

Since 2026-11-24: MatchBoard's `MODE_ICONS` (Deathmatch, Duo and Trio their own, Bots and Party `play`, Local
`local`; Quads keeps its `art/modes` icon), the MatchBoard gui's LOCAL and CUSTOM icons and PLAY SOLO's default, the
Lobby gui's STYLE, WEAPONS and SKINS tiles and the FreeCrate gui's tile (`S_TileIcon`, the gift), each 0.54 of the
tile, at 0.545, 0.39: the tiles' slanted body is centred at about 0.54 of the frame's width, not 0.5 (the owner,
2026-11-24: "make sure the icons are centered").

## Uploading

Only when the owner says so:
1. `build.py` gives the PNGs the pixel fix (clear pixels take the nearest drawn colour, as the crate kit's).
2. Stage them in `../sfx/out/upload/` (Studio's approved Open Cloud folder) and upload each through Open Cloud as a
   Decal to The Snail Studio group (566704940), with a plain title ("Snail Glyph Play"); read each image id in Studio
   (`InsertService:LoadAsset(decal)`, the Decal's `Texture`).
3. Put each image id where the glyph is used and record it in the table here.

The 2026-11-24 set (the owner approved it; all ten passed moderation):

| Icon | Title | Decal | Image id |
| --- | --- | --- | --- |
| `deathmatch` | Snail Glyph Deathmatch | 97754934051789 | 88744460498201 |
| `duo` | Snail Glyph Duo | 84547871260979 | 76759738385570 |
| `trio` | Snail Glyph Trio | 87009143640922 | 126355291658126 |
| `play` | Snail Glyph Play | 86814932075002 | 119204758692964 |
| `local` | Snail Glyph Local | 105238662135717 | 86467359142321 |
| `custom` | Snail Glyph Custom | 122840076803833 | 89277478392791 |
| `freeweapons` | Snail Glyph Free Crate (the crate with a star, 2026-11-24; the gift before: 121012239301398 / 81176493230191) | 90403607718877 | 95485980368344 |
| `style` | Snail Glyph Style | 86310957063036 | 78330986091652 |
| `weapons` | Snail Glyph Rocket | 86855298367964 | 101862730182790 |
| `skins` | Snail Glyph Shell | 115639386442386 | 137985730069220 |

The difficulty set (2026-11-25, the owner approved the upload; all three passed moderation), on PLAY SOLO's difficulty
cards (MatchBoard's `DIFFICULTY_ICONS`):

| Icon | Title | Decal | Image id |
| --- | --- | --- | --- |
| `easy` | Snail Glyph Easy | 74795022723480 | 88105304367362 |
| `medium` | Snail Glyph Medium | 96532229887321 | 94010149349376 |
| `hard` | Snail Glyph Hard | 94462966575720 | 103240032909077 |
