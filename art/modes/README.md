# Worm Battlegrounds: mode icons

One icon for each way to play (the owner, 2026-11-17: "how to visually represent all the modes… computer icon for
bots"), for the lobby's mode buttons, the match board's rows and the setup's title.

| Icon | Mode | What it shows |
| --- | --- | --- |
| `deathmatch` | Deathmatch | A red bullseye with metal crosshair arms |
| `teams` | Teams | A red and a blue shield, overlapping, with metal rims |
| `duo`, `trio`, `quads` | Duo, Trio, Quads | Two, three or four of the game's snails (pink body, studded shell) |
| `bots` | Solo vs bots | A metal robot head with glowing eyes and a red antenna light |
| `party` | Party | A striped party hat with a pom-pom and confetti |
| `custom` | Custom | A violet panel of three metal sliders with coloured knobs |
| `local` | Local | A red couch with a gamepad on its seat |
| `tutorial` | Tutorial | A green target with an arrow in its bullseye |
| `random` | Random map | A chunky white die with rounded edges and glossy red pips |

Each is an SVG on a 64 × 64 grid in the weapon icons' look (the owner, 2026-11-17: "check how our weapon icons look,
make the style similar"; the first set was flat stickers): chunky objects with a thick ink outline (`#171724`), three
tones on every face (a light top, the colour, a dark bottom), the brick studs on their faces, metal parts in light
grey, and a soft white gloss on the upper left.

| File | What |
| --- | --- |
| `icons.py` | Draws every icon into `src/` from shared pieces (the tones, the stud, the gloss, the snail) |
| `src/<icon>.svg` | The sources, written by `icons.py` |
| `build.py` | Renders them into `out/<icon>.png` (256 × 256, transparent) and `preview.html` |
| `out/`, `preview.html` | Made by `build.py`, not kept in the repo |

## Build

Python 3 with Pillow, and Chrome or Edge (the SVGs are drawn by the browser, headless, at twice the size and scaled
down; `WB_BROWSER` names another Chromium browser).

```bash
python -I icons.py            # src/*.svg
python -I build.py            # out/*.png and preview.html
```

`preview.html` shows each icon large, then at the sizes the game shows them, on a dark card and on the sky.

## In the game

Since 2026-11-17: SOLO VS BOTS (Bots, or Party in a party), each public card (its mode) and the setup's title (Bots,
Party or Local) take theirs from MatchBoard's `MODE_ICONS`; LOCAL, CUSTOM, the custom lobby's titles and the Random
map card carry theirs in the MatchBoard and CustomLobby guis. Teams and Tutorial have no place yet.

## Uploading

Only when the owner says so:
1. `build.py` gives the PNGs the pixel fix (clear pixels take the nearest drawn colour, as the crate kit's).
2. Stage them in `../sfx/out/upload/` (Studio's approved Open Cloud folder) and upload each through Open Cloud as a
   Decal to The Snail Studio group (566704940), with a plain title ("Snail Mode Bots"); read each image id in Studio
   (`InsertService:LoadAsset(decal)`, the Decal's `Texture`).
3. Put each image id in `MODE_ICONS` and record it in the table here.

The 2026-11-17 set (the owner approved the weapon-look redraw, asking for a better die first; all eleven passed
moderation at upload):

| Icon | Title | Decal | Image id |
| --- | --- | --- | --- |
| `deathmatch` | Snail Mode Deathmatch | 89896670070202 | 101410705091276 |
| `teams` | Snail Mode Teams | 93790683418343 | 76604245828704 |
| `duo` | Snail Mode Duo | 107262561762046 | 130275829062405 |
| `trio` | Snail Mode Trio | 138486643208094 | 130310099327594 |
| `quads` | Snail Mode Quads | 81742394084974 | 137708705569595 |
| `bots` | Snail Mode Bots | 70927670525162 | 70468282427332 |
| `party` | Snail Mode Party | 101164944878083 | 120087464798832 |
| `custom` | Snail Mode Custom | 76538759216970 | 99448007204452 |
| `local` | Snail Mode Local | 103169719706719 | 126362872028871 |
| `tutorial` | Snail Mode Tutorial | 138135187874643 | 97002366999238 |
| `random` | Snail Mode Random | 136811571504418 | 85646554440176 |
