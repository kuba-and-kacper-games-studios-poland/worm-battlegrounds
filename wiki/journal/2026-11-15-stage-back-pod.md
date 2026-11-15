---
title: "Lobby stage: the 4th party member stands on the back pod, raised 7.5 studs (was 2.5) so they show"
date: 2026-11-15
status: open
kind: changed
pages: ["Lobby", "Party"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/_meta/README.md
---

**What changed.** The owner: "the 4th player should be in the back, and it should be slightly taller because the
player is not visible". On the lobby's stage, a party fills the pods front, behind left, behind right, then back (was
front, behind left, back, behind right). The back pod's column is 5 studs taller: its top is 7.5 studs over the front
pod's (was 2.5), so the snail on it shows its face and body over the front snail's head; before, it hid behind it.

**Where.** In the place, not in code: `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB | Stage"].Pods`. The back
pod is now `Pod_4` (its `Platform_Base` 9.9 tall, its `Snail` marker at y 10, was 5); the right side pod is `Pod_3`.
Lobby's `Stage` handler stands party members on `Pod_1` to `Pod_4` in order.

**How to check.** In a party of four, the fourth member stands on the high pod behind the player, and their snail's
face is seen over the player's snail.

**For the wiki.** Lobby (and Party, if it shows the stage): where each member of a party stands on the stage.
