# 0003: Values every server shares come from the clock; values others see go on the `Player`

**Status:** Accepted
**Date:** 2026-10-26
**Deciders:** Nari

## Context

Two of My Tree Farm's values needed more than one machine to agree:

- **The log price** had to be the same in every server, for the server that pays and the clients that show it.
- **The price board over each plot** shows its owner's daily deal timer, which other players' clients need. The
  Replicator folder is private to its player.

## Decision

- **A value every server shares is worked out from the clock**: from `Workspace:GetServerTimeNow()` in the module's
  Global (a slot index fed to seeded noise), so servers and clients compute the same value with no messages.
- **A per-player value other players see is an attribute on the `Player`**, written only by the server. Values only
  the player sees stay in their Replicator folder.
- The server still decides every amount (`ume/events.md` → The server decides).

Rule: `ume/values.md`.

## Options considered

| | A: from the clock (chosen) | B: MessagingService | C: a DataStore |
| --- | --- | --- | --- |
| Servers agree | Always, with no traffic | When messages arrive | After each read |
| Limits and failures | None | Quotas, dropped messages | Quotas, throttling |
| What it can hold | Values a formula gives | Any value | Any value |

| | A: attribute on the `Player` (chosen) | B: the Replicator |
| --- | --- | --- |
| Who can read it | Every client | Only its player |
| Who writes it | The server | The server |
