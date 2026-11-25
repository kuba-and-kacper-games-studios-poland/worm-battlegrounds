---
title: "Wind off by default: only custom lobbies and local play that turn it on"
date: 2026-11-24
status: open
kind: changed
pages: ["Match", "Wind", "Custom lobbies"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/_meta/_types.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchSetup/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
---

**What changed.** The owner (2026-11-24) turned the wind off by default. Public, solo, party and tutorial matches
have no wind: it stays 0 all match, and the HUD hides the wind plate. A custom lobby and local play have a WIND
OFF / ON choice, OFF until picked; with ON the wind works as before (−20 to 20, a new one every two rounds, mostly
−5 to 5: Match's `WIND_MAX`, `WIND_ROUNDS`, `WIND_WEIGHTS`). This also ends the tutorial's wind step (Match's
`TUTORIAL_WINDS` is gone: `2026-11-24-tutorial-one-shot`). Narrows `2026-11-13-wind-per-round` and the 2026-11-15
wind entries (`2026-11-15-wind-every-turn`, `-wind-scale-20`, `-wind-weights`), which still hold for a match with
wind.

**Where.**
- The match's metadata has `Wind` (`boolean?`, `Match_Metadata`). `Phases.Play` sets the match folder's `WindOn`
  attribute to `metadata.Wind == true`; `Turns._rollWind` keeps `Wind` at 0 when the metadata has no wind.
- MatchHud's `Turn._refreshWind` shows the wind plate only while `WindOn`. The tip "the wind pushes every thrown
  shot" left the waiting tips (`HINT_TIPS`).
- MatchBoard: `Launch.Launch(players, kind, mode, size, mapId, difficulty, tutorial?, wind?)` writes `Wind = wind ==
  true`; `PlayLocal(player, difficulty, mapId, players, wind)`; `Custom.Create(..., wind)` stores the row's `Wind`
  (`MatchBoard_Row.Wind`, false by default in `Rows.AddRow`, published as the row's `Wind` attribute), and
  `StartRow` passes it on. Remotes: `MatchBoard_PlayLocal` is now `{ "Player", "string", "string", "number",
  "boolean" }` and `MatchBoard_CreateCustom` takes a trailing `"boolean"`.
- Guis: MatchSetup's `S_WindBox` (in the bots' row, shown only for local play) with `S_WindOff` and `S_WindOn`;
  CustomLobby's create step has a WIND header and `WindList` with `S_WindOff` and `S_WindOn` beside MODE. A custom
  room with wind adds "  |  Wind" to its info line.

**How to check.** A solo or public match: no wind plate, and `Workspace.Ume.Match`'s
`Wind` stays 0 and `WindOn` is false. A custom lobby or local play with WIND ON: the plate shows and the wind rolls
every two rounds; with OFF (the default) it's as a solo match.

**For the wiki.** Wind: it blows only in custom lobbies and local play that turn it on. Match: no wind in public,
solo, party and tutorial matches, the HUD's wind plate only with wind. Custom lobbies: the WIND OFF / ON choice and
the info line; local play's setup has it too.

Not checked here: a play test of each kind of match after the change. The `match wind` admin command still sets a
wind, but in a match without wind the next turn puts it back to 0.
