---
title: "The shell no longer breaks below 50 health"
date: 2026-11-12
status: open
kind: removed
pages: ["The game", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
---

**What changed.** The owner: "remove that system where the shell breaks under 50hp, make it so the shell always stays
on the snail". A snail keeps its shell at any health, on every screen. Nothing breaks, no chips fly, and the
`Snail_ShellBreak` sound no longer plays.

Supersedes 2026-11-06-shell-break (now `dropped`). 2026-11-08-match-sounds lists `Snail_ShellBreak`, and
2026-11-11-skin-snails says the shell breaks below 50 health: neither holds any more.

**Where.** `Snails/Scripts/Client/Shell.lua` is gone, and Snails' client no longer starts it. Snails' `Settings.lua`
lost its Shell category (`SHELL_BREAK_HEALTH`, `SHELL_PART`, `SHELL_CHIPS`, `SHELL_CHIP_SIZE`, `SHELL_CHIP_SPEED`,
`SHELL_CHIP_LIFETIME`, `SHELL_CHIP_COLORS`). `Snail_ShellBreak` (12222005) left `src/global_data/Sound/SoundsList.lua`.
A knockout still sets `Alive` false and `Ghost` true before `Health` drops to 0.

**How to check.** Studio, 2026-11-12: no `Shell` module under `Snails.Scripts.Client`, and nothing else sets the skin's
`Shell` part's `LocalTransparencyModifier` (a ghost fades the whole skin). Not watched on screen: hurt a snail below
50 and its shell stays.

**For the wiki.** The game (the snail) and Match screen: take out the shell break, with a History line. Match modules:
Snails' client has no `Shell` handler.
