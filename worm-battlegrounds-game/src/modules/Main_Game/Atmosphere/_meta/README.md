# Atmosphere

Each place's mood, drawn by every client on its own: the lobby's outside matches and each map's in a match (the
`InMatch` Player attribute and the match folder's `MapId`). A mood is a lighting preset in the place (Lobby, Plains,
Desert, Cave, Volcano), its music, a few ambient particles that drift with the match's wind, small effects on its liquids'
surfaces (sun glints, lava bubbles and embers, drips in a cave pool) and grit trickling from a cave's ceiling. In a
match the wind shows on screen as faint white streaks blowing across the camera's view, just in front of the map: their way
from the wind's sign, how many and how fast from its strength, breathing in gusts, none in still air. It's heard too:
each map's wind loop (taken from Fight and Ride Animals' zone ambience) eases louder with the wind and goes silent in
still air, and in strong wind a gust whooshes at the streaks' gust peaks. The
lighting tweens from one mood to the next (the first after joining is set at once), and the music crossfades. While a
match's sudden death runs, the lighting deepens a touch as a layer over the map's preset and the map's music crossfades
into its sudden-death version; both go back when it ends or the player leaves the match. Each mood's track carries the
place's ambience, so no separate ambience plays. In a match the module also reacts to what happens in the arena: a
blast bursts leaves, needles, cacti and twigs in their own colours out of the props it reaches (rocks in dust), chips,
shots, props, snails and falling ground splash where they drop into water or lava (lava adds steam), falling ground
lands with dust in its own colour, and new obsidian steams and hisses. Everything plays from the studio's particle
prefabs through the Vfx library, in the same style as the rest of the game's effects, and nothing is sent over the
network.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Atmosphere` |
| Runs on | Server (the world folder only), Client · Lobby map, Match map, Studio map |
| Uses | `I.Lighting`, `I.Vfx`, `I.BGM_Controller`, `I.Sound`, `I.Network` (listens to Arena's `Arena_Carve` and `Arena_Fall`), `I.Config.PlaceLoader`, `I.Settings` (Lobby's `CAMERA_MARKER`, Arena's `LIQUID_COLORS`, Combat's `SOUND_ROLLOFF_MIN`/`MAX`, Match's `WIND_MAX`) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Creates `Workspace.Ume.Atmosphere`, where clients put their ambient particles |
| `Client.lua` | The client entry: finds the world, Arena, Match, Lobby, Combat and Snails folders this map has, and starts the handlers |
| `Settings.lua` | `Atmosphere_Settings`: the moods (`PROFILES`), sudden death, ambient, reactions and effects numbers |
| `Scripts/Client/Mood.lua` | Picks the mood for where the player is, sets its lighting preset, music, particles, wind and the sudden-death layer; a map's particles and wind wait for its `Bounds` marker when it arrives after the markers |
| `Scripts/Client/Wind.lua` | The wind's streaks: one `WIND_EFFECT` copy kept over the camera's view each frame (after MatchCamera, at the `Camera` render priority + 2), turned, sped up and thickened by the wind, breathing in gusts; and its sound: the map's `WindSound` loop eased to the wind's volume, and a `WIND_GUST_SOUND` whoosh at strong gusts' peaks; a change of wind bursts streaks across the view with the whoosh |
| `Scripts/Client/Ambient.lua` | The ambient areas (a mood's `Ambient_` prefabs streaming over the map's bounds, or in front of the lobby stage camera), their wind, the liquid surface effects and ceiling grit on spots in view, and the lobby stage's drifting clouds |
| `Scripts/Client/Reactions.lua` | The arena's reactions: prop bursts on `Arena_Carve`, splashes where watched things drop through a liquid's surface, splashes and landing dust for `Arena_Fall` groups, steam and the hiss from new obsidian |
| `Scripts/Client/Liquids.lua` | Reads the arena's liquid rectangles (their `Arena_Liquid` kind) at most every `LIQUID_REFRESH`: surfaces crossed going down, random open surface spots, the liquid at a point, and whether a surface is the sea's |
| `Scripts/Client/Effects.lua` | Plays a Vfx prefab once like `I.Vfx.Play`, painted in a colour, pulled by the wind and with its counts scaled; whether a point is in view |
| `_meta/_types.lua` | `Atmosphere_Profile` and its rows, `Atmosphere_Stream`, `Atmosphere_LiquidRect`, `Atmosphere_Track` |

## Network

No remotes: each client draws from what replicates (the `Match` folder's `MapId`, `Wind` and `SuddenDeath`, the
`InMatch` Player attribute, the arena's parts and its liquid parts' `Arena_Liquid`), and from Arena's own
`Arena_Carve` and `Arena_Fall`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PROFILES` | `Lobby`, `PicnicPlains`, `TutorialMeadow`, `LakesideShowdown` and `RollingPlains` (Picnic Plains' row), `Desert`, `RockslideRidge` (lava bubbles and embers since its lava sea, 2026-11-14), `EchoCaverns` (Rockslide Ridge's cave row, with water ripples), `VolcanoIsle` | Each mood, by MapId (below) |
| `LOBBY_PROFILE` | `"Lobby"` | The mood outside matches |
| `LOBBY_MAP`, `MATCH_MAP` | `"Lobby"`, `"Match"` | The place loader's maps with no matches and with only a match; the Studio map has both and follows `InMatch` |
| `MOOD_TWEENINFO` | 2 s Sine InOut | How the lighting moves from one mood to the next |
| `MUSIC_FADE` | `2.5` | Seconds one mood's music crossfades into the next's, and into its sudden-death version |
| `SUDDEN_DEATH_BRIGHTNESS` | `0.88` | Sudden death multiplies the brightness by this |
| `SUDDEN_DEATH_CONTRAST`, `SUDDEN_DEATH_DENSITY` | `0.06`, `0.05` | Added to the colour correction's contrast and the atmosphere's density |
| `SUDDEN_DEATH_TINT` | `255, 232, 214` | Multiplied into the colour correction's tint (warmer) |
| `SUDDEN_DEATH_WEIGHT`, `SUDDEN_DEATH_ID` | `5`, `"SuddenDeath"` | The lighting layer's weight and id |
| `SUDDEN_DEATH_TWEENINFO` | 4 s Sine InOut | How the sudden-death layer comes and goes |
| `AMBIENT_FRONT` | `8` | How far in front of the map's front face its ambient particles reach, toward the camera |
| `LOBBY_AREA_DISTANCE`, `LOBBY_AREA_SIZE` | `30`, `70 × 34 × 40` | The lobby's ambient box, in front of the stage camera |
| `WIND_PUSH` | `0.35` | The sideways pull on drifting particles per point of wind (studs/s²) |
| `CLOUD_DRIFT`, `CLOUD_DRIFT_SECONDS` | `3`, `{ 9, 14 }` | How far the lobby stage's clouds drift and back, and over how long |
| `CEILING_SHARE`, `CEILING_STEP` | `0.4`, `1` | Grit trickles from rock in the bounds' top 40 %, found by sampling every stud down |
| `WIND_EFFECT` | `"Wind_Streak"` | The streaks' prefab (its look: texture, stretch, fade, base size and speed) |
| `WIND_DEPTH` | `{ 1, 12 }` | The streaks fly this many studs in front of the map's front face, toward the camera |
| `WIND_RATE` | `18` | Streaks a second at the strongest wind (Match's `WIND_MAX`), scaled down with the wind; the prefab's own rate is ignored |
| `WIND_SIZE_SCALE`, `WIND_SPREAD` | `1`, `2` | Each streak is this many times the prefab's size, and leaves within this many degrees of level |
| `WIND_OPACITY` | `0.6` | Each streak is this many times as opaque as the prefab's (its `Transparency` keypoints scaled toward clear) |
| `WIND_SPEED_SHARE` | `{ 0.45, 1 }` | The streaks' speed as a share of the prefab's, in the weakest wind and the strongest |
| `WIND_UPWIND_SHARE` | `0.5` | The streaks' area reaches this share of the view's width further upwind, so they blow in from the edge |
| `WIND_GUST_SHARE`, `WIND_GUST_SECONDS` | `0.35`, `4` | The streaks' rate swings by this share over this many seconds |
| `WIND_SOUND_VOLUME` | `{ 0.1, 0.7 }` | The map's wind loop's volume in the weakest wind and the strongest (silent at 0), in the SFX group |
| `WIND_SOUND_TWEENINFO` | 2 s Sine InOut | How the loop eases to a new wind, and fades out when the map goes |
| `WIND_GUST_SOUND`, `WIND_GUST_SOUND_FROM` | `"Wind_Gust"`, `0.4` | The whoosh at a gust's peak, in wind of 40 % of the strongest or more, as likely as the wind's share |
| `WIND_GUST_SOUND_VOLUME` | `{ 0.15, 0.5 }` | The whoosh's volume, from just past `WIND_GUST_SOUND_FROM` to the strongest wind |
| `WIND_CHANGE_BURST`, `WIND_CHANGE_BURST_MIN` | `40`, `8` | Streaks each emitter bursts when the wind changes (once every snail played on it), at the strongest wind and at least |
| `PROP_EFFECTS` | `Leaves`, `Needles`, `Bush`, `Cactus`, `Twig` → `"Leaves"`; `Rock` → `"Dust"` | The burst a blast plays from each kind of prop part, by part name |
| `PROP_PARTS_FULL` | `6` | Parts a blast must reach for a prop's full burst; fewer play a smaller one (down to half) |
| `PROP_WIND_SHARE` | `0.5` | The share of the wind's pull that bends a burst |
| `SPLASH_EFFECTS` | Water `{ "Splash_Water" }`, Lava `{ "Splash_Lava", "Steam" }` | What a fall into each liquid plays; the first takes a liquid's own colour |
| `SPLASH_SCALES` | Chip `0.35`, Shot `0.5`, Snail `0.7`, Prop `0.9` | How big a splash each falling thing makes |
| `LANDING_WIDTH`, `LANDING_SCALES` | `3`, `{ 0.6, 2 }` | A falling chunk's splash and dust scale: its width / 3, within these |
| `LANDING_MIN_DROP` | `2` | A chunk falling less than this lands without dust |
| `LANDING_EFFECT`, `LANDING_LIGHTEN` | `"Dust"`, `0.55` | The dust a chunk lands with, in its colour lightened by this share |
| `SPLASH_COOLDOWN` | `0.6` | One thing splashes at most once in this many seconds |
| `LIQUID_TINT_LIGHTEN` | `0.25` | A liquid with its own colour (`Arena_LiquidColor`) tints splashes and ripples with it, lightened by this share |
| `OBSIDIAN_EFFECT`, `OBSIDIAN_STEAM_GAP`, `OBSIDIAN_SOUND_GAP`, `OBSIDIAN_SETTLE` | `"Steam"`, `0.25`, `1.2`, `2` | New obsidian's steam, at most this often, its hiss (`Liquid_Obsidian`) at most this often, and neither in a map's first 2 seconds |
| `SMALL_SPLASH_GAP` | `0.12` | Chips splash at most this often between them |
| `CLEANUP_MARGIN` | `0.5` | How long a played effect's copy stays after its last particle |
| `LIQUID_REFRESH` | `0.1` | How long the liquid's shape is reused before it's read again |

A `PROFILES` row:

| Key | Lobby | PicnicPlains | Desert | RockslideRidge | VolcanoIsle |
| --- | --- | --- | --- | --- | --- |
| `Preset` | `Lobby` | `Plains` | `Desert` | `Cave` | `Volcano` |
| `Music`, `SuddenDeathMusic` | `BGM`, none | `Music_PicnicPlains`, `…_SuddenDeath` | `Music_Desert`, `…_SuddenDeath` | `Music_RockslideRidge`, `…_SuddenDeath` | `Music_VolcanoIsle`, `…_SuddenDeath` (Desert's tracks for now) |
| `WindColor` | none (no wind) | `255, 255, 255` | `255, 240, 214` | `228, 222, 212` | `235, 214, 200` |
| `WindSound` | none | `Wind_OpenAir` | `Wind_Desert` | `Wind_Howl` | `Wind_OpenAir` |
| `Ambient` (`Effect`, `Bottom`–`Top`, `RateScale`) | `Ambient_Motes` 0–1 | `Ambient_Pollen` 0.1–1, `Ambient_Leaf` 0.3–1 | `Ambient_Sand` 0.05–0.6 | `Ambient_CaveDust` 0–0.85 | `Ambient_CaveDust` 0.2–1, rate 0.6 (ash) |
| `Surface` (`Liquid`, `Effect`, `Every`, `Tint`) | none | Water `Glint` 0.15–0.4 s | Lava `Lava_Bubble` 0.6–1.6 s, Lava `Ember` 0.25–0.7 s, Water `Glint` 0.8–2 s | Lava `Lava_Bubble` 0.4–1.2 s, Lava `Ember` 0.2–0.6 s (Echo Caverns: Water `Ripple` 1.5–4 s, tinted) | Lava `Lava_Bubble` 0.4–1.2 s, Lava `Ember` 0.2–0.6 s |
| `Ceiling` (`Effect`, `Every`) | none | none | none | `Grit` 3–7 s | none |

A map with no row warns once and keeps the mood showing.

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Atmosphere` | Created by the server; each client's ambient areas (named after their prefab) and surface effects. Reactions play in Combat's folder instead, so a big hit's stop freezes them with the rest |
| `Lighting` | The Lighting Manager's active preset, `Lobby` (`Lighting.__config`'s `Lighting_Id`): a high soft sun behind the stage camera (`GeographicLatitude` −12, `ClockTime` 13.4), neutral fill, colour correction saturation 0.25 |
| `Lighting.Presets.Plains` | Late morning: warm key light from the camera's side (latitude 70, 10.4), teal and lavender fill, soft blue haze, saturation 0.35 |
| `Lighting.Presets.Desert` | Late afternoon: low golden sun (latitude 70, 15.7), warm sand bounce, warm hazy horizon (density 0.32, haze 1.4, glare 0.3), saturation 0.3 |
| `Lighting.Presets.Cave` | Rockslide Ridge and Echo Caverns: dimmer light (brightness 2.3) with little sky fill (`EnvironmentDiffuseScale` 0.25, so the blue sky doesn't tint the rock), a dark warm-grey haze that closes in the sky (haze 2.4), no sun rays, bloom from 1.2 |
| `Lighting.Presets.Volcano` | Volcano Isle: the Desert's, later and through smoke: warm sun from the camera's side (latitude 70, 16.4, brightness 2.7), reddish fill and sky shift, a thicker ember-tinted haze (density 0.36, haze 1.9, decay 140, 69, 51), saturation 0.28 |
| `ReplicatedStorage_Assets/Vfx/PREFAB \| …` | The prefabs this module plays, made from the studio's existing emitters (their textures and flipbooks): `Leaves`, `Dust`, `Lava_Bubble`, `Ember`, `Steam`, `Glint`, `Ripple`, `Grit`, and the streams `Ambient_Motes`, `Ambient_Pollen`, `Ambient_Leaf`, `Ambient_Sand`, `Ambient_CaveDust` and `Wind_Streak` (no `EmitCount`; code sizes the part to the area and turns them on). It also plays `Splash_Water` and `Splash_Lava` |
| `Workspace.Ume.Arena.Liquid` parts | Read for their `Arena_Liquid` attribute (`"Water"` or `"Lava"`), which Arena's liquid sets |
| `Workspace.Ume.Lobby.Stage` | The lobby stage's camera marker (Lobby's `CAMERA_MARKER`) places the lobby's area; its `Clouds` parts drift while the lobby shows |

Roblox lowers particle rates on low graphics settings on its own; the module adds no setting for it.
