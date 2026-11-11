---
title: "Each place has its own mood: lighting per map and lobby, ambient particles with the wind, and effects that react to blasts, splashes and falls"
date: 2026-11-10
status: open
kind: added
pages: ["Match modes & maps", "Lobby", "Match modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Mood.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Ambient.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Reactions.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Liquids.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
---

**What changed.** A new client module, Atmosphere, gives the lobby and each map a mood of its own (the owner's ask:
"subtle, high quality, minimalistic but visible, worms-type colours in a professional way"; plan approved the same
day). Before, every place shared one lighting (the place's own, colour correction saturation 1.0, teal ambient, purple
outdoor ambient, latitude 76 at 14:30).

- **Lighting presets, in the place** (Lighting Manager format, `Lighting.Presets`): **Lobby** (the active one): high
  soft sun from behind the stage camera, neutral fill so skins show true, light haze, saturation 0.25. **Plains**
  (Picnic Plains): late morning, warm key light, teal and lavender fill, soft blue haze, saturation 0.35. **Desert**:
  late afternoon, low golden sun with long shadows, warm hazy horizon, saturation 0.3. **Cave** (Rockslide Ridge):
  dimmer, little sky fill, a dark warm-grey haze that closes in the sky, so the golden pool glows against grey rock.
  The light tweens over 2 s between moods (`MOOD_TWEENINFO`).
- **Sudden death** deepens the light a touch as a layer over the map's preset: brightness × 0.88, contrast +0.06,
  atmosphere density +0.05, a warmer tint, over 4 s (`SUDDEN_DEATH_*`).
- **Ambient particles** (new Vfx prefabs `Ambient_*`): lobby sun motes and drifting stage clouds; Plains pollen and
  the odd leaf; Desert sand wisps low over the ground; Cave dust motes. In a match they drift with the turn's wind
  (`WIND_PUSH` 0.35 studs/s² per point of wind), so they double as a wind read.
- **Liquid surfaces:** sun glints on water (Plains, Desert's oasis), lava bubbles that pop and embers that rise
  (Desert), drips rippling the cave pool (tinted with its colour); grit trickles from Rockslide Ridge's rock ceiling.
- **Reactions:** a blast bursts leaves, needles, cacti and twigs out of the props it reaches in their own colours
  (rocks in dust); chips, shots, props, snails dropping into a pond and falling ground splash where they enter water
  or lava (lava adds steam); falling ground lands with dust in its colour; new obsidian steams (its hiss is the music
  and sound session's entry). Reactions play in Combat's folder, so a big hit's stop freezes them too.
- The music per mood (`Music`, `SuddenDeathMusic`, `MUSIC_FADE`) was added to the same module by the sound session;
  its own journal entry covers it.

**Where.** `PROFILES` and every number in `Atmosphere/Settings.lua`; the mood choice and sudden death in
`Scripts/Client/Mood.lua`; ambient areas, wind, surface and ceiling effects in `Ambient.lua`; reactions in
`Reactions.lua`. The prefabs are in `Workspace.Ume.ReplicatedStorage_Assets/Vfx` (`Leaves`, `Dust`, `Lava_Bubble`,
`Ember`, `Steam`, `Glint`, `Ripple`, `Grit`, `Ambient_Motes`, `Ambient_Pollen`, `Ambient_Leaf`, `Ambient_Sand`,
`Ambient_CaveDust`), all cloned from the studio's existing emitters. Arena's liquid parts now carry `Arena_Liquid`
(their kind) for clients. No remotes; it listens to Arena's `Arena_Carve` and `Arena_Fall`.

**How to check.** In Studio, the lobby is bright and even with a few motes; Solo vs bots: Rockslide Ridge goes dim
with a dark sky, Desert golden with bubbles on the open lava strips, Picnic Plains sunny with glints on the sea.
Blasting a tree throws green leaves; a chunk dropping in the sea splashes.

**For the wiki.** Match modes & maps: a line per map on its look (time of day, what moves). Lobby: the stage's soft
light and drifting clouds. Match modules: the Atmosphere module (client only, no remotes). Architecture: lighting
presets now live in the place (`Lighting.Presets`), applied per place by Atmosphere.

**Unsure.** The presets and prefabs live in the place file: they're there only once the place is saved (and
published with both places). Tuned in a Studio playtest at the match camera's distance; not yet seen on a phone.
