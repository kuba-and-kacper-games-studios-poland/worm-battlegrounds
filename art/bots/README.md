# Worm Battlegrounds: bot avatars

The bots' avatar pictures (the owner's ask, 2026-11-11: "custom icons for the Bot snails... this type of headshot,
different snails personalities, so snail in glasses, snail military"): voxel snail headshots in the game's snail look
(its voxel body, big white eyes with block pupils, thin eyestalks threaded with dark beads, purple spots, a tan shell
with a brown swirl), rendered like a Roblox avatar headshot: head and shoulders, three-quarter, on a clear background.

| Bot | Snail | Wears |
| --- | --- | --- |
| `Default` | Classic pink | Nothing: the game's bot picture |
| `Brainy` | Classic pink | Round black glasses |
| `Sarge` | Orange | A camo army helmet with a chin strap |
| `Shades` | Blue | Sunglasses and a backwards red cap |
| `Captain` | Yellow | A spotted red bandana and an eyepatch |
| `Tex` | Mint | A cowboy hat and a red neckerchief |
| `Shadow` | Purple | A ninja hood and a red headband |
| `King` | Pink | A gold crown with red jewels and an ermine collar |
| `Viking` | Lime | A horned steel helmet and a big orange beard |

| File | What |
| --- | --- |
| `make_bot_heads.py` | Builds each head from voxels (0.07-stud cubes from shape tests: the snail, its shell, its eyes and stalks, the outfit) with each voxel's face shaded like the game's voxels, adds the round beads and spots, and renders `out/Bot_<Name>.png` (512 × 512) in Blender 5 (EEVEE, a key, rim and fill light) |
| `to_studio.py` | Copies the bots' and the emotes' (`../emotes`) PNGs into Roblox Studio's content folder: `rbxasset://textures/wb_bots/` and `rbxasset://textures/wb_emotes/` |
| `out/` | Made by the scripts, not kept in the repo |

## Build

```bash
# in Blender 5 (the MCP's code tool): load make_bot_heads.py and call render_all(r"<this folder>/out")
python -I to_studio.py
```

## In the game

Every bot shows `Default`, the classic pink snail with no outfit (the owner, 2026-11-11: "lets do a default snail for
the bot. one icon"): MatchHud's `BOT_AVATAR`, in the team panels, the turn list, the turn callout and the results.
The eight personalities wait for rare bots with their own skins and avatars. The owner approved the upload on 2026-11-11.
`Default` went up as a Decal to The Snail Studio group (566704940), titled "Bot Avatar", with PrepKit's pixel-fix. It
passed moderation, and `BOT_AVATAR` holds its image id:

| Bot | Decal | Image id |
| --- | --- | --- |
| `Default` ("Bot Avatar") | 100735489129619 | 75705415395334 |

A personality's picture is uploaded the same way when a rare bot uses it.
