# 0005: `PREFAB | Name` templates, holder parts, and a world folder per module

**Status:** Accepted
**Date:** 2026-11-01
**Deciders:** Nari

## Context

My Tree Farm's place had grown without rules for what code clones and makes:

- **Names.** Gui templates were `PREFAB | Name`, but the place's templates had plain names (`Plot`, `Chunk`,
  `Stand`), so nothing told a template from a model found by its data id.
- **Templates at the origin.** BillboardGuis and particle emitters sat loose in their asset folders and showed at
  0, 0, 0.
- **Loose world objects.** Clients parented chips, flying logs, swing effects and outlines straight to Workspace, and
  a weather's particle box to the camera. A Highlight waiting in Workspace with no Adornee outlined the whole map, and
  the game hitched each time it was hovered.

## Decision

- **Templates code clones are named `PREFAB | Name`**, in the place as in gui templates. Anything found by a data id
  keeps that id. A setting names the prefab in full, and code renames each clone to the plain name.
- **A template that would show at 0, 0, 0 sits on a holder part** (a BillboardGui on the Attachment of a small part,
  emitters under one). Code finds the template anywhere in its folder and clones only it.
- **What a module makes in the world goes in `Workspace.Ume.<Module>`**, created by the module's server in `Init`.
  Clients wait for it and parent what they make there. A Highlight never sits in Workspace itself.

Rule: `ume/place.md`.

## Options considered

| | A: as above (chosen) | B: plain names, loose objects |
| --- | --- | --- |
| Tell a template from a model | By its name | Only by knowing the code |
| Templates in the place | Out of sight on their holders | Visible at 0, 0, 0 |
| Finding or clearing what a module made | One folder | Searching Workspace |
