---
title: "A snail's shell breaks below 50 health"
date: 2026-11-06
status: dropped
kind: added
pages: ["The game", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Shell.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** When a snail's health drops below **50** (of 200), its shell breaks: the shell disappears and
bursts into 12 tan and brown chips that fly off, bounce on the ground and fade after 1.5 seconds. The snail plays on
without it. Healing back to 50 or more (Bandage, Medkit) puts the shell back. A snail knocked out at 0 stays shell-less
as a ghost. It's only a look: a broken shell changes no damage or movement.

**Where.** `Snails/Scripts/Client/Shell.lua`, started from the Snails client. Settings in Snails' `Settings.lua`:
`SHELL_BREAK_HEALTH = 50`, `SHELL_PART = "Shell"` (the skin part that breaks; a skin without one never breaks),
`SHELL_CHIPS = 12`, `SHELL_CHIP_SIZE` 0.3–0.6 studs, `SHELL_CHIP_SPEED` 14–26 studs/s, `SHELL_CHIP_LIFETIME = 1.5`,
`SHELL_CHIP_COLORS`. Each client reads the snail's `Health` attribute (no remote) and hides the shell with its
`LocalTransparencyModifier`; the chips are client-only parts named `ShellChip` in the snail's model, in Arena's
`Chip` collision group. The chips are a code-made placeholder until the owner provides a break effect.

**How to check.** In a Studio match, set a snail's `Health` attribute to 42 on the server: its shell vanishes and 12
`ShellChip` parts appear in its model, gone within about 2 seconds. Set it to 120: the shell is back. Checked
2026-11-06.

**For the wiki.** The game (the snail): the shell breaks under 50 health and grows back with healing. Match screen:
a hurt snail has no shell. Match modules: Snails' client has a `Shell` handler.

**Dropped.** Removed on 2026-11-12 at the owner's ask: the shell always stays on the snail (2026-11-12-shell-break-removed).
