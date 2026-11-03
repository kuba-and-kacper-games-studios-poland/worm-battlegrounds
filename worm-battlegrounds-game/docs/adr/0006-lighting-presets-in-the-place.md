# 0006: Lighting presets live in the place, shared with the plugin

**Status:** Accepted
**Date:** 2026-11-01
**Deciders:** Nari

## Context

The Lighting module's presets were Lua files in `src/global_data/Lighting/Presets/`, while the Ume plugin's Lighting
Manager kept its own in the place (`Lighting.Presets`, each with a `__config`). The two never met: a preset made in
the plugin didn't exist in game, and the module only captured the place's live lighting as `Default`. My Tree Farm
needed weather presets that could be tuned in Studio and shown in game.

## Decision

**Presets are made in the place with the Lighting Manager.** The Lighting module reads them at start the way the
plugin applies them (an effect with no instance is off), over a Lua preset with the same name. It also takes
`FogColor`, `FogStart`, `FogEnd` and `ShadowSoftness`, which the plugin keeps. Lua presets stay for the template's own
and for what the place can't hold. Code applies a preset by id (`I.Lighting.SetActivePreset(id)`).

A plugin preset holds every Lighting property, `ClockTime` too, so a game that layers a clock over presets puts the
clock's layer above them.

Rule: `ume/place.md`.

## Options considered

| | A: presets in the place (chosen) | B: Lua presets only | C: two sets, kept apart |
| --- | --- | --- | --- |
| Tune a preset | In Studio, with the plugin | By editing Lua | Either, but they differ |
| What the game shows | What Studio showed | What the Lua says | Only the Lua set |
| Sky, Atmosphere, post effects | Instances, as made | Described in Lua | Both |
