# Worm Battlegrounds: the game's own sounds

Every sound here is made from code, as the farm game's caves are (`Farm Game 2/farm-game/art/sfx/caves`): numpy
synthesis for the effects, and General MIDI instruments rendered with FluidSynth and the GeneralUser GS bank for the
music. Nothing is recorded or licensed. They replace the free Creator Store placeholders in the game's
`src/global_data/Sound/SoundsList.lua` once the owner approves them, by name.

The style is the classic 2005-2009 Roblox soundscape (the owner's pick, 2026-11-10: "the vibe is Great Strategy"):
the music plays its own snail theme on the Great Strategy soundfont (BadliZ's 2005 tracker instruments) and, in the
lobby, the StealthPilot soundfont; the effects are Roblox's own 2009 sounds, sounds built from them, and calls scored
on the music's instruments. The earlier numpy set (`make_sfx.py`, Worms / Battlefield Heroes style) stays as a source
for the few sounds no classic one covers (the falling whistle, the fuse, the lava sizzle).

| File | What |
| --- | --- |
| `snaillib.py` | The shared DSP: FFT filters and filter sweeps, oscillators and glides, modal mallets (marimba, glockenspiel, xylophone, woodblock, bell), thumps, debris grains, bubbles, snail babble, a small outdoor tail, seamless loops, levelling, WAV and OGG writing |
| `make_sfx.py` | Every effect, one function per SoundsList name (its docstring says what it is) |
| `make_classic.py` | The effects in the classic soundscape: CLASSIC (a Roblox 2009 sound played by its id), BUILT (made from them) and SCORED (on the Great Strategy font), with `classic.json` for the preview; its `UPDATE_2026_11_16` list is the 16 Nov set (below) |
| `tracker.py` | A tracker-style sampler: plays the classic Roblox sample pack's long single-note samples re-pitched per note, lays them on a seamless loop, adds a wrapping hall |
| `make_levels.py` | The level music (the owner's pick, 2026-11-10, after Worms Armageddon's streams): each map's track is its ambience and a light song that sounds like the level, mixed as one, mostly one instrument at a time playing a bit of the tune, with a faster, driving sudden-death version (Rockslide Ridge stays epic all through, the owner's pick); and the lobby, the game's signature tune barely there over a meadow. On the classic samples, with hand drums and shakers in numpy. Since 2026-11-16 also the six new maps (below), each playing the snail tune (`snail()`: the lobby's call and answer as scale degrees) in its own mode |
| `ambience.py` | The levels' ambience, built at a loop's length so it wraps with the music: wind (from Roblox's own falling-wind recording), mountain whistle, sand hiss, lava rumble and bubbles, embers, birds, crickets, leaves, rockfalls, a hawk, water drips; since 2026-11-16 cave drips in a long stone echo, the cave's air, lake water lapping, wind in long grass |
| `make_themes.py` | The earlier themes (a different tune each, faster, and a heavier sudden death), replaced by `make_levels.py`; its note helpers (`midi`, `tune`, `chord`) are shared |
| `make_music.py` | The music: the lobby loop, a battle loop per map (Picnic Plains, Desert, Rockslide Ridge) and its sudden-death version, the win and lose stings. One 4-bar theme runs through all of them in different modes and bands |
| `make_crates.py` | Draft crate-opening sounds (2026-11-11, not approved yet): the reel's tick, landing and settle as crisp new synthesis, the crate, reveals and legendary calls on the classic samples; `out/crates/`, previewed in `../crates/` |
| `make_preview.py` | `preview.html`: every piece and effect with a player (loops on repeat), where it plays and what it replaces, for review; given the update folder, the "Update 16 Nov" section at the top |

## Build

FluidSynth 2.6.2 (its Windows x64 release) and the GeneralUser GS bank aren't in the repo: they live in `tools/`
(`tools/fluidsynth/fluidsynth-v2.6.2-win10-x64-cpp11/bin/fluidsynth.exe`, `tools/soundfont/GeneralUser-GS.sf2`, from
github.com/FluidSynth/fluidsynth and github.com/mrbumpy409/GeneralUser-GS), or set `WB_FLUIDSYNTH` and
`WB_SOUNDFONT`. The effects need only numpy and ffmpeg.

```bash
python -I make_sfx.py <sfx>               # every effect, ~10 s; or name some: python -I make_sfx.py <sfx> Turn_Yours
python -I make_music.py <music>           # every piece, ~45 s; or name some: python -I make_music.py <music> Win
python -I make_classic.py <classic>       # the classic effects, ~5 s
python -I make_levels.py <levels>         # the level music on the sample pack, ~5 min (make_music.py still makes the stings)
python -I make_preview.py <classic> <music>  # preview.html next to this file, everything embedded as MP3
# The 16 Nov update into its own folder, then the preview with its section (~8 min for the 12 tracks):
python -I make_levels.py out/update_2026-11-16 VolcanoIsle VolcanoIsle_SuddenDeath EchoCaverns ...
python -I make_classic.py out/update_2026-11-16 update
python -I make_preview.py out/classic out/levels out/update_2026-11-16
```

Loops render three times back to back and keep the middle pass, and their first 30 ms fade in from what really follows
their end, so the wrap has no seam or click. Music is levelled to -20 dB RMS (stings on their loudest 0.3 s).
The level tracks are 32 bars a loop: their tracker tail folds onto the start and their ambience wraps round the end.
The music is rolled off over 10 kHz and the ambience kept light under it (the owner, 2026-11-10: the wind, sand and
birds were too loud): each layer's level in the `*_air` functions is dB under the music while that layer sounds.
The light songs (`SPARSE`: Picnic Plains, Desert, the lobby) are set by how loud they play with their silences left
out, so their phrases are as loud as a busy song's and the loop is quieter overall: -20 dB (the lobby -23). The busy
ones (sudden death, Rockslide Ridge) are levelled to their RMS: -18 dB in sudden death, -20 for Rockslide Ridge.

Each effect writes `WB_<Name>.wav` (44.1 kHz, 16-bit mono) and `WB_<Name>.ogg` (ffmpeg, libvorbis q5) and prints its
length and peak. One-shots are levelled on their loudest 0.3 s (UI about -18 dB, weapons -14, big blasts -11) and
soft-limited under -1 dBFS; the jetpack is a seamless loop levelled on its RMS. `out/` and `preview.html` aren't kept
in the repo.

## Update 16 Nov (2026-11-16, approved and uploaded)

Rendered into `out/update_2026-11-16/` (WAV and OGG) and heard in `preview.html`'s "Update 16 Nov" section. The owner
approved all 28 the same day ("Sounds and songs are great"); they were staged in `out/upload/2026-11-16/` and uploaded
to The Snail Studio group (titles and ids below the 2026-11-10 table).

The six new maps' music (`make_levels.py`'s `NEW_MAPS`), made as Picnic Plains and Desert are: the map's ambience and
a light song, 32 bars, one instrument at a time playing a bit of the snail tune in the map's mode, levelled the same
(-20 dB on the sounding phrases, sudden death -18 dB RMS). The files carry the SoundsList name:
`WB_Music_<MapId>.wav` for `Music_<MapId>`, `WB_Music_<MapId>_SuddenDeath.wav` for its sudden death.

| Map | Key, BPM (sudden death) | Song | Ambience |
| --- | --- | --- | --- |
| Volcano Isle | E Phrygian, 88 (118) | low harp, low toms' heartbeat, low choir, horn, piano, soft horn, chimes; SD pounding toms, brass stabs, the tune on the bright horn and horn | lava rumble and bubbles, embers, a hot breeze |
| Echo Caverns | B minor, 80 (120) | finger chimes with long echoes, harp, piano, soft horn, choir; SD an echoing piano pulse, dirty bass in eighths, guitar and chimes | cave drips in a stone echo, the cave's air, a far rumble |
| Rolling Plains | D major, 108 (138) | soft horn (whistle), plucked harp and guitar, wide strings; SD galloping strings and harp, shaker, bright horn and soft horn | gusts, long grass, leaves, birds, a hawk |
| Fluffy Fallout | C Mixolydian, 112 (140) | short plucked harp (pizzicato), piano, chimes, horn, woodblock; SD harp in sixteenths, toy drums (snare and tom tuned up, woodblocks), bright horn and piano | soft wind, crickets, a few birds |
| Mirage Mesa | A Hijaz, 76 (112) | harp plucked short (kalimba) with hanging echoes, chimes, soft horn, piano, choir haze, a lazy frame drum; SD hand drums speeding up through every 8 bars, harp arpeggios, bright horn and horn | sand hiss, hot wind, a far hawk, a few insects |
| Lakeside Showdown | G Lydian, 96 (126) | soft horn (flute) over a gentle harp, chimes, piano; SD driving harp, kit and bass, bright horn and soft horn | lake water lapping, birds, leaves, a breeze |

Stand-ins, since the sample pack has none of these: the marimba is the harp played low; the glockenspiel the Great
Strategy finger chimes; toms the Wind of Fjords bass drum read faster (`tom()`); the whistle and the flute `horn2`
(The Great Strategy's HORN4, whose tone is nearly a pure fundamental and octave), played high and soft; pizzicato and
the kalimba the harp with each note held under half its length (`plucks()`).

The effects (`make_classic.py`'s `UPDATE_2026_11_16`, all BUILT; `BlackHole_Hum` and `Variety_Squeak` are numpy in
`make_sfx.py`, as no classic sound has either): `Fire_Grenade`, `Fire_ClusterBomb`, `Fire_VarietyGrenade`,
`Fire_BlackHoleGrenade`, `Fire_SpiderBomb` and `Fire_SpartanSpear` each keep the classic slingshot at their core (the
one id they share today, 12222103) with their own mark (a pin, a rattle, a sparkle, a warble, a servo chirp, a swish
and ring), levelled as the slingshot plays (-15 to -16 dB); `Homing_Lock`, `Homing_Boost`; `BlackHole_Open`,
`BlackHole_Hum` (a 3 s seamless loop, -22 dB RMS), `BlackHole_Collapse`, `BlackHole_Burst` (-11, a big blast);
`Variety_Burst`, `Variety_Dig`, `Variety_Squeak`; `Cluster_Split`.

## Classic sounds and fonts (tools/classic, not in the repo)

- `GreatStrategy.sf2` and `StealthPilot.sf2`: NotRoblox's soundfonts (CC BY 3.0) from musical-artifacts.com
  (artifacts 3268 and 3851), ripped from BadliZ's "The Great Strategy" (2005) and StealthPilot's songs.
- `../drive/Roblox SonndFont/`: a sample pack the owner found (Google Drive, "Roblox SonndFont.zip", 80 MB): The Great
  Strategy's instruments (Bright Horn, Horn, Strings, Alt String, Piano, Finger Chimes, its drum loop) and Wind of
  Fjords' (choirs, harp, lead guitar, dirty and sweeping bass, strings, drum hits), each a long note at C (tracker.py
  lists each one's root).
- `sfx/*.wav`: Roblox's own 2009 uploads (user Roblox, public domain; ids in `make_classic.py`'s `IDS`) and three
  of the client's built-in sounds (`content/sounds`), and its falling wind (`action_falling.wav`, from
  `content/sounds/action_falling.ogg`), which `ambience.py` reads for every level's wind. They were taken from Studio's cache after loading each id in
  Studio, then converted to WAV; the game plays the CLASSIC ones straight from those ids.

## Credits

Music instruments: NotRoblox's Great Strategy and StealthPilot soundfonts, after BadliZ's "The Great Strategy".
Classic effects: Roblox (2009 uploads); OOF: Roblox's official upload (79348298352567).

## Uploading

Only after the owner approves the preview. The staged OGGs go in `out/upload/` (not kept in the repo), and Studio's
MCP uploads them through Open Cloud (`POST /assets/v1/assets`, `assetType` Audio, creator group 566704940, The Snail
Studio), then reads each id from its operation. That folder has to be in Studio's Assistant Settings → MCP
Permissions → Open Cloud upload directories, which only the owner sets (then Save, and a Studio restart). Each id
goes in `SoundsList.lua` under its name; a sound that covers several names (`Fire_Throw` for every thrown weapon,
`Use_Heal`, `Use_Potion`) gets the same id under each.

Titles are plain words starting "Snail" (Roblox moderates them): no weapon words, no other games' names, "Overtime"
for sudden death. The 2026-11-16 set (28 uploads, "Reviewing" at upload; ids in `SoundsList.lua`):

| Title | SoundsList name | Title | SoundsList name |
| --- | --- | --- | --- |
| Snail Volcano Isle Theme | `Music_VolcanoIsle` | Snail Volcano Isle Overtime | `Music_VolcanoIsle_SuddenDeath` |
| Snail Echo Caverns Theme | `Music_EchoCaverns` | Snail Echo Caverns Overtime | `Music_EchoCaverns_SuddenDeath` |
| Snail Rolling Plains Theme | `Music_RollingPlains` | Snail Rolling Plains Overtime | `Music_RollingPlains_SuddenDeath` |
| Snail Fluffy Fallout Theme | `Music_FluffyFallout` | Snail Fluffy Fallout Overtime | `Music_FluffyFallout_SuddenDeath` |
| Snail Mirage Mesa Theme | `Music_MirageMesa` | Snail Mirage Mesa Overtime | `Music_MirageMesa_SuddenDeath` |
| Snail Lakeside Showdown Theme | `Music_LakesideShowdown` | Snail Lakeside Showdown Overtime | `Music_LakesideShowdown_SuddenDeath` |
| Snail Toss Click | `Fire_Grenade` | Snail Toss Rattle | `Fire_ClusterBomb` |
| Snail Toss Sparkle | `Fire_VarietyGrenade` | Snail Toss Warble | `Fire_BlackHoleGrenade` |
| Snail Toss Chirp | `Fire_SpiderBomb` | Snail Swish Ring | `Fire_SpartanSpear` |
| Snail Lock Beeps | `Homing_Lock` | Snail Afterburner Whoosh | `Homing_Boost` |
| Snail Vortex Open | `BlackHole_Open` | Snail Vortex Hum | `BlackHole_Hum` |
| Snail Vortex Collapse | `BlackHole_Collapse` | Snail Vortex Boom | `BlackHole_Burst` |
| Snail Prism Chime | `Variety_Burst` | Snail Dig Crunch | `Variety_Dig` |
| Snail Worm Squeak | `Variety_Squeak` | Snail Split Pop | `Cluster_Split` |

The 2026-11-10 set (37 uploads, all approved):

| Title | SoundsList name | Title | SoundsList name |
| --- | --- | --- | --- |
| Snail Turn Bugle | `Turn_Yours` | Snail Jetpack Loop | `Snail_Jetpack` |
| Snail Turn Drum | `Turn_Start` | Snail Splash | `Snail_Splash` |
| Snail Next Ping | `Turn_Next` | Snail Lava Sizzle | `Snail_Burn` |
| Snail Time Up | `Turn_TimeUp` | Snail Ghost Rise | `Snail_Ghost` |
| Snail Overtime Horn | `Match_SuddenDeath` | Snail Land Thump | `Snail_Land` (Roblox's built-in landing sound, which has no id) |
| Snail Round Ding | `Match_Knockout` | Snail Lava Cooling | `Liquid_Obsidian` |
| Snail Water Rise | `Match_WaterRise` | Snail Window Open | `Window_Open` |
| Snail Seeker Launch | `Fire_HomingMissile` | Snail Teleport Out | `Teleport_Out` |
| Snail Fuse Hiss | `Fire_Dynamite` | Snail Teleport In | `Teleport_In` |
| Snail Big Pop | `Fire_Shotgun` | Snail Lobby Theme | `BGM` |
| Snail Rapid Pops | `Fire_Uzi` | Snail Picnic Plains Theme / Overtime | `Music_PicnicPlains`, `…_SuddenDeath` |
| Snail Spinner Pops | `Fire_Minigun` | Snail Desert Theme / Overtime | `Music_Desert`, `…_SuddenDeath` |
| Snail Swing Whoosh | `Fire_BaseballBat` | Snail Rockslide Ridge Theme / Overtime | `Music_RockslideRidge`, `…_SuddenDeath` |
| Snail Bonk | `Fire_OnePunch` | Snail Victory Sting | `Match_Win` |
| Snail Heal Chime | `Use_Bandage`, `Use_Medkit` | Snail Defeat Sting | `Match_Lose` |
| Snail Potion Gulp | `Use_SpeedPotion`, `Use_LowGravityPotion` | Snail Parachute Open | `Use_Parachute` |
| Snail Falling Whistle | `Shot_Whistle` | Snail Jetpack Start | `Use_Jetpack` |

The crate opening's set (2026-11-11, 21 uploads from `make_crates.py`, all approved), in `SoundsList.lua`'s Crates
category:

| Title | SoundsList name | Title | SoundsList name |
| --- | --- | --- | --- |
| Snail Crate Tick | `Crate_Tick` | Snail Reveal Common | `Reveal_Common` |
| Snail Crate Land | `Crate_Land` | Snail Reveal Uncommon | `Reveal_Uncommon` |
| Snail Crate Settle | `Crate_Settle` | Snail Reveal Rare | `Reveal_Rare` |
| Snail Crate Shake | `Crate_Shake` | Snail Reveal Epic | `Reveal_Epic` |
| Snail Crate Unlock | `Crate_Unlock` | Snail Reveal Legendary | `Reveal_Legendary` |
| Snail Crate Spin | `Crate_Spin` | Snail Reveal Shiny | `Reveal_Shiny` |
| Snail Crate Heartbeat | `Crate_Tease` | Snail Legendary Vortex | `Legend_BlackHole` |
| Snail Crate Gold Hit | `Crate_GoldHit` | Snail Legendary Party | `Legend_Variety` |
| Snail Crate Premium Shimmer | `Crate_Premium` | Snail Legendary Spooky | `Legend_Skeleton` |
| Snail Card Flip | `Card_Flip` | Snail Legendary Float | `Legend_LowGravity` |
| Snail Results Open | `Results_Open` | | |

The CLASSIC sounds aren't uploaded: `SoundsList.lua` holds Roblox's own 2009 ids (`make_classic.py`'s `IDS`).
