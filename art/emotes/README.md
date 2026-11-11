# Worm Battlegrounds: emote icons

The emotes' icons (the owner's ask, 2026-11-11: "for wave a hand waving in the color of the snail"), in the game's
icon style: bold shapes, the ink outline, flat colours with a light edge, drawn with the snail's own pink, its purple
spots and its beaded eyestalks. They show on the EmoteShop cards, the lobby's emote row and the match's emote wheel, and
in the speech bubble over a snail (or beside a name on a lobby party card) when it plays the emote.

| Emote | Icon |
| --- | --- |
| `Emote_Wave` | A pink snail hand waving, with motion arcs |
| `Emote_ThumbsUp` | A pink fist, thumb up, with a sparkle |
| `Emote_Laugh` | The snail's face laughing, eyes shut, tears of joy |
| `Emote_Dance` | Two music notes and sparkles |
| `Emote_Flex` | A dumbbell held by the snail's pink grip, with an effort burst |
| `Emote_Taunt` | The snail's face winking with its tongue out |
| `Emote_Cry` | The snail's face crying streams of tears |
| `Emote_Backflip` | A looping arrow round the snail's shell |
| `Emote_VictoryTrumpet` | A gold trumpet with notes |

| File | What |
| --- | --- |
| `make_emote_icons.py` | Writes each icon as an SVG on a 256 × 256 grid, draws it into `out/Emote_<Id>.png` (256 × 256, transparent, pixel-fixed) through the crate kit's renderer (`../crates/build.py`: Chrome or Edge, headless) and `out/sheet.png` |
| `out/` | Made by the script, not kept in the repo |

## Build

```bash
python -I make_emote_icons.py
python -I ../bots/to_studio.py   # into Studio's content folder: rbxasset://textures/wb_emotes/
```

## In the game

Each emote's Inventory row (`Main/1_Inventory/Data/Items/Emote/Emote_<Id>.lua`) points its `IconId` at the icon's
uploaded `rbxassetid://` id. The owner approved the upload on 2026-11-11 ("upload all assets that you did not upload to
roblox"). All nine were uploaded as Decals to The Snail Studio group (566704940) and passed moderation:

| Emote | Decal | Image id |
| --- | --- | --- |
| `Backflip` ("Emote Backflip") | 128794711905099 | 134218829069464 |
| `Cry` ("Emote Cry") | 105978838837842 | 78834361903065 |
| `Dance` ("Emote Dance") | 109450066513188 | 101472172112086 |
| `Flex` ("Emote Flex") | 72492820626800 | 84814176236864 |
| `Laugh` ("Emote Laugh") | 90478304899115 | 134169553529809 |
| `Taunt` ("Emote Taunt") | 95289636879822 | 123361365197050 |
| `ThumbsUp` ("Emote Thumbs Up") | 128771872157457 | 133574145418278 |
| `VictoryTrumpet` ("Emote Victory Trumpet") | 130124302503814 | 89999271140028 |
| `Wave` ("Emote Wave") | 87945181381605 | 122190966104251 |

A new or redrawn icon is uploaded the same way (the crate kit's README → Uploading), and its row takes the new image
id. A local `rbxasset://` copy shows only in Studio on this PC, and is blank on live servers.
