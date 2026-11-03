# 0008: AdminPanel replaces Command

**Status:** Accepted, ume 2.0.0
**Date:** 2026-10-26
**Deciders:** Nari

## Context

ume's Command module held the command bar and the command registry. Modules registered their commands from
`Scripts/Command/*.lua`, which the loader ran after every module had initialized. My Tree Farm needed a second admin
tool, a dashboard of panels and blocks (buttons, switches, sliders, inputs, item gives) per player and per feature,
with its own permission level. It grew both as one module, AdminPanel, which then went back into ume.

## Decision

**AdminPanel replaces Command.** It holds two tools, each opened from the keyboard ([0004](0004-keys-and-chat-commands.md)):

- the **command bar**: Command's registry and bar, as `I.AdminPanel_CommandBar` (`Register`, `SetDictionary`,
  `UpdateDictionary`), with the `/cmd` chat command made on the server;
- the **dashboard**: panels that modules register with `I.AdminPanel_Dashboard.Register`.

`I.AdminPanel.GetPermissionLevel` gives a player's level from `src/global_data/AdminPanel/Permissions.lua`. A module's
tool scripts live in `Scripts/AdminPanel/CommandBar/` and `Scripts/AdminPanel/Dashboard/`, which the loader runs one
tool at a time after every module has started (`docs/architecture/startup-order.md`). Their classes are
`<Module>_CommandBar_<Side>` and `<Module>_Dashboard_<Side>`. The saved history moves to
`Profile.AdminPanel.CommandHistory`.

## Options considered

| | A: one AdminPanel module (chosen) | B: keep Command, add a Dashboard module | C: dashboard only in the game |
| --- | --- | --- | --- |
| Permission levels | One source for both tools | Two modules reading the same file | Command's, and the game's own |
| Shared window code (drag, resize, keys) | Once | Twice | Twice |
| Every game gets the dashboard | Yes | Yes | No |
| Change for games on 1.x | `I.Command` → `I.AdminPanel_CommandBar`, `Scripts/Command` → `Scripts/AdminPanel/CommandBar` | None | None |

## Consequences

- **Harder:** a game on ume 1.x renames its command scripts and their calls when it updates. ume 2.0.0 marks the break.
- **Easier:** a module adds its admin tools in one place, with one permission source and one set of windows.
