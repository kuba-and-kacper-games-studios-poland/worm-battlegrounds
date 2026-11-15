---
title: "Fixed: matches that sometimes started with no camera or controls"
date: 2026-11-15
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/core/game_instance/Start/tasks/replication_gate.lua
---

**What changed.** Some matches opened with the camera far off and nothing to press, and the client's console repeated
`Snails.Scripts.Client.Tags:191: attempt to index nil with 'GetFolder'` every frame. A match server is fresh, so its
players join while it's still starting, and the framework's module tree reaches them in pieces; the client began
loading before Match's client scripts had arrived and skipped it (no `I.Match`, so no camera or controls). Now every
client, on live servers too, waits until everything in the server's manifest of the tree has arrived (up to 60 s, then
it's kicked with "Ume Instance replication incomplete"), as only Studio did before.

**Where.** ume's replication gate, `core/game_instance/Start/tasks/replication_gate.lua`: `WriteServerManifest` and
`WaitBeforeFrameworkLoad` no longer return outside Studio; `hierarchyMatches` accepts extras (remotes the server makes
later) and needs at least each truncated branch's descendant count; `CLIENT_WAIT_SECONDS` is 60 (was 10). A framework
file: ume itself should take the same change.

**How to check.** Only on live servers: start several matches from the lobby; none opens without the camera, and the
Tags error doesn't appear. In Studio the client starts as before.

**For the wiki.** Architecture: loading waits for the whole framework on every server, not only in Studio.
