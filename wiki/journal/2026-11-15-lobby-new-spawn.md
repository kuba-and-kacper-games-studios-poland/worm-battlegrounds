---
title: "Lobby: the stage is the owner's NewSpawn, its four platforms laid out as before, all in the stud material"
date: 2026-11-15
status: open
kind: changed
pages: ["Lobby"]
files: []
---

**What changed.** The owner built `NewSpawn` in the dev place: the same meadow as the lobby's stage (the studio's
`Spawn_New`), with four new platforms (a cyan top, a blue base, a glowing ring beam). It is now the lobby's stage
prefab, `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB | Stage"]`, moved so its meadow stands exactly where the
old one did. Then, on the owner's word ("move it back like it was previously so the 4th one was at the back, plus
update the materials on them to be our stud material"):

- the platform that stood far right (mostly off screen) moved to the old raised back spot behind the front one, its
  base 4.9 studs tall down to the ground, as the old back pod's;
- the stands are symmetric ("the stands are not symmetrical, fix it"): the front and back ones on x 0, the side ones
  mirrored at x ±11.9;
- the meadow's two hedges (`Hedges` › `Hedge_01`, `Hedge_02`), placed for the old, smaller platforms, cut into the
  side stands ("the bushes are clipping"): each moved 0.25 studs out and 1.75 back, mirrored (x ±11.94, z 1223.87),
  the least that clears every stand by half a stud and touches nothing but the flat stepping stones they stood on;
- every part that had the `2022 Stud` variant on Plastic (the meadow's 863, which showed no studs) and the eight
  platform parts (Plastic bases, Neon tops) are SmoothPlastic with `2022 Stud`, the game's stud material. The tops no
  longer glow (Neon can't take the variant); the ring beams still do.

The platforms are the pods, each with the invisible `Snail` marker the party's snails stand on, 1.3 studs over its top:

| Pod | Where (from the camera) | Snail marker |
| --- | --- | --- |
| `Pod_1` | Front, the player's | (0, 2.5, 1200.9) |
| `Pod_2` | Behind, on the left | (11.9, 2.5, 1211.2) |
| `Pod_3` | The raised back one, behind the front | (0, 5.0, 1228.9), as the old back pod's |
| `Pod_4` | Behind, on the right, the left one's mirror: fills last, under the setup and waiting room | (−11.9, 2.5, 1211.2) |

The camera keeps its marker, (0, 7, 1180) at 50°, and all four platforms show. The 2026-11-12 stage
(`PREFAB | Stage_before_2026-11-15`) and the `NewSpawn` it came from (`NewSpawn_source_2026-11-15`) are in
`ServerStorage.!dump`. No code changed: Lobby still finds `Pods` › `Pod_N` › `Snail` and `Markers.Camera`.

**Where.** In the dev place only (place content, not in the repo): kept once the owner saves and publishes it.

**How to check.** The lobby shows the four platforms and the meadow with studs, the player's snail on the front one;
a party's third member stands on the raised back one. Tested in Studio: the stage built, the snail stood on `Pod_1`,
no errors; a capture from the lobby camera showed all four platforms.

**For the wiki.** Lobby: the stage's look (the new platforms, the stud material) and where party members stand.
