# Ume values

Where a game's numbers and per-player values live, and how they're worked out. Who decides an amount:
`ume/events.md` → The server decides.

- **Amounts are integer strings**, and their math uses `I.BN` (`MultiplyWithPrecision` for a decimal price), never Lua
  numbers, which lose precision past 2^53.
- **The same value in every server comes from the clock**: work it out from `Workspace:GetServerTimeNow()` in the
  module's Global (seeded noise, a slot index), so server and clients agree with no messaging.
- **Where a per-player value lives:** private to the player, in their Replicator folder; seen by other players (an
  owner's timer on a board), in an attribute on the `Player`, written only by the server.
