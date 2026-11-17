---
title: "Smoother blasts: props break on every screen at once, drawn debris, pooled cutters and chips"
date: 2026-11-17
status: open
kind: changed
pages: ["Architecture", "Match modules", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Helpers/Cutter.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Helpers/PropCut.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Falling.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/PropBoxes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/PropCarver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Thrown.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/PropSeeThrough.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Reactions.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** A polish pass on blasts that hit the terrain and a tree together (the owner saw a slight hitch). No
gameplay result changes: craters, what falls and where, and damage are as before. What players see:

- **A tree breaks in the blast's frame on every screen.** Each client cuts the props a blast reaches itself, with the
  same stepped cutter and the same split as the server (`Scripts/Helpers/PropCut.lua`), the way it already cut the
  terrain (`Scripts/Client/PropCarver.lua`): the cut parts hide, their pieces show, and what the cut frees flies off at
  once. The server cuts every reached prop part at once, alongside the terrain's carve (`Props.Cut`), instead of one
  part after another after it; before, a tree's pieces appeared over several frames and held up the blast's throws.
- **Prop pieces fly, fall and fade on the game's own motion, drawn by each client** (`Scripts/Client/Thrown.lua`),
  never Roblox physics and nothing sent per frame: a thrown piece arcs by gravity, spinning in the plane (up to
  `PROP_KNOCK_SPIN` 6 rad/s, at `PROP_KNOCK_SPEED` 35), lands on the terrain and lies there; a prop whose ground is
  gone drops straight down the distance the server works out (`Arena_PropFall`), riding the ground cut loose under it
  when that falls too. Both fade after `PROP_FADE_DELAY` (3 s) over `PROP_FADE_TWEENINFO` (1 s), as before. They no
  longer bounce or tumble when they land.
- **Falling ground no longer stutters.** Each client hides the falling parts and draws copies of them falling
  (`Scripts/Client/Falling.lua`); before, the client and the server's replicated steps both moved the same parts,
  and a chunk could hop back up after it landed. The server still moves the real ground, which snails stand on.
- **Chunks a blast throws** come from a pool and fly on the game's own motion with a bounce (Combat's `Effects`,
  `DEBRIS_SPIN` 12, `DEBRIS_BOUNCE` 0.35, `DEBRIS_SLIDE` 0.6, `DEBRIS_REST_SPEED` 4, `DEBRIS_FADE_TWEENINFO` 0.5 s
  Quad In; `DEBRIS_MAX` 16, `DEBRIS_SPEED` 25 to 50, `DEBRIS_SIZE` 0.3 to 1, `DEBRIS_LIFETIME` 2.5 unchanged):
  anchored parts, not physics ones, so Arena's `Chip` collision group is gone. The hit stop holds them still.

Under the hood: the cutters' boxes are reused (Cutter's `Build` and `Release`; the server's in
`Workspace.Ume.Arena.Cutters`, each client's in its `Predicted` folder) and the merged cutter is never parented (it
used to replicate its mesh to every player); Atmosphere's prop bursts look only at the props near the blast; the
see-through props read a prop's box again only when it changes (`PropBoxes`; `PROP_SEE_THROUGH_REFRESH` is gone).

New names: the remote `Arena_PropFall @ (prop, drop, started)`, server to every client; the client Topic
`Arena_PropThrown @ (part)` (Arena publishes, Atmosphere's splashes subscribe; replaces the `PropWeld` welds);
the prop attributes `Arena_PropBase` (set at load) and `Arena_Carve` (the last carve the server cut into the prop);
the setting `PROP_REMOVE_MARGIN` (1 s: how much longer than the fade the server keeps what fell or flew off a prop).

**How to check.** Not checked in Studio yet (the lead tests it with the rest of the pass). In a match, blast a tree
standing on terrain: on every screen its cut shows and its top flies off in the blast's frame; the pieces land, lie
3 s and fade; the output shows no `Could not cut the props` warning. Blast a floating ledge with a plant on it: the
plant falls with the cut-off piece. A cut-off chunk of ground falls once, smoothly, and stays down.

**For the wiki.** Match modules → Arena: the new client scripts (PropCarver, Thrown, PropBoxes), Props' `Cut` and `Drop`, the `Arena_PropFall` remote, the `Arena_PropThrown` client Topic, `PROP_REMOVE_MARGIN`, no `Chip` group and no `PROP_SEE_THROUGH_REFRESH`. Architecture: props are cut on every screen like the terrain, and their pieces are drawn by each
client (no server physics); falling ground is drawn on copies. Match modes & maps (props): what flies off lands and lies still
rather than bouncing. Supersedes the props' and chips' physics described since 2026-11-10 and 2026-11-13.

**Checked in Studio (2026-11-17).** A Golden Bazooka shot through an oak and a bush and through a cave roof: props cut
(`Arena_Carve` 2), the cutter pool stayed at 24 boxes, no carve or prop warnings. One fix: Atmosphere's `Reactions`
errored ("table index is nil") whenever Decor parts were taken away, as on every map load, because with deferred
signals a removed part has already left its prop; each burst part's prop is now kept (`burstProps`).
