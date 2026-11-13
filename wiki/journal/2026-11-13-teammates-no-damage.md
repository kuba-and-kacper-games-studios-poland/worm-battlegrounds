---
title: "Teammates can't hurt each other; your own blasts still hurt you"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modules", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
---

**What changed.** A blast does no damage (and no knock) to a snail on the shooter's team, other than the shooter. Free-for-all is unchanged.

**Where.** Combat's `Blast.Hit` returns 0 when `Blast.IsTeammate(participantId, sourceId)`.

**How to check.** In Duos, blast your teammate: no damage pop. Blast yourself: you lose health.

**For the wiki.** Match modes & maps (team modes): no friendly fire.

**From.** The testers: "if you are in team, you cannot damage team mates, you can always damage your self".
