# 0009: Priority bands run from 100 down to -100

**Status:** Accepted, ume 2.0.0
**Date:** 2026-10-31
**Deciders:** Nari

## Context

`I.Priority` holds the shared bands for `I.OnStarted`, `I.OnLoaded` and the `I.G_Player` events. They ran from
`First = 1000000` to `Last = -1000000`, with `Data` 900000, `Replicator` 800000, `Setup` 500000 and `Late` -500000.
To run just after a band, code stepped below it, which made numbers like 499999 that are hard to read and compare.

## Decision

**The bands run from 100 down to -100:** `First` 100, `Data` 90, `Replicator` 80, `Setup` 50, `Default` 0, `Late` -50,
`Last` -100. Code passes a band, never a raw number, and steps one below it to run just after it
(`I.Priority.Setup - 1`). The bands' uses are in `docs/reference/core-globals.md`.

## Options considered

| | A: 100 to -100 (chosen) | B: keep ±1000000 |
| --- | --- | --- |
| Reading a priority | `Setup - 1` is 49 | `Setup - 1` is 499999 |
| Room between bands | 10 to 50 steps, plenty for one game | Hundreds of thousands |
| Games on 1.x | Raw numbers must change; band names keep working | No change |
