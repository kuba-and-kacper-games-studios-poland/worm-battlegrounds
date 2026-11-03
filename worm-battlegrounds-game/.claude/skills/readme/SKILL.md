---
name: readme
description: Write or refresh the _meta/README.md of one Luau unit (an ume module or library, an ume-rbx tool, or ume-gui's engine, controls, a theme or a gui) from its code, following the repo's README template, and move any description comment above the module table into it. Use when a unit has no README yet, when its API, remotes, Topics, settings, data, components, commands or files changed, or when asked to document a unit.
argument-hint: <unit folder>
---

# Unit README

*Shared skill: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read
only. Change all copies together (`.claude/rules/family/family.md`).*

Write or refresh `$ARGUMENTS/_meta/README.md`. If no folder was given, ask for one. Owning rule: `.claude/rules/luau/readme.md`.

1. **Template.** Open the template `luau/readme.md` names for this folder and read its examples. The section names, their order and the table shapes come from there.
2. **Read the whole unit.** Every file in the folder, not only the entry script:
   - **ume module:** each entry script's `I.<Name> = { … }` / `I.G_<Name> = { … }` table and the function behind every key (signature, `--- @param`, `--- @return`, summary); `Settings.lua`; `Data/`; `Scripts/**` (including `Scripts/AdminPanel`); `Components/*.lua` with their `*.comp.json`; `_meta/_types.lua`; every `I.Topic.Register` / `Publish`, `I.Network.Get*` / `Fired` / `OnInvoke` / `UFired` / `Fire*` / `Invoke` / `UFire*`; the profile template keys; Replicator folders and attributes; its `I.AdminPanel_CommandBar.Register` commands and `I.AdminPanel_Dashboard.Register` panels.
   - **ume library:** `init.lua`, the `I.<Name>` it assigns in `_injectUme`, `Scripts/`, `Data/`, `Components/`, `_meta/_types.lua`.
   - **ume-rbx tool:** `init.lua`, `Settings.lua`, `Gui/**`, `Handlers/**`, `_meta/_types.lua`, its widget in ume-gui
     `../ume-gui/src/guis/Plugin/<Tool>.lua` (and `<Tool>/Preview.lua`), its saved-data schema
     `Tools/SavedData/Handlers/Schema/<Tool>.lua`, its toolbar group and button in `Plugin/App.lua` and the toolbar helper.
   - **ume-gui:** the engine's `init.lua` API, `Engine/*`, `Libs/*`; each control's schema, structure, handle and `Styles/<Control>.lua`; a theme's `init.lua`, `Tokens.lua`, `Styles/`; a gui's table, views, named nodes and `Preview.lua`.
3. **Old sources.** Take what is still true from:
   - a `--[[ … ]]` description above `--- @class` / `local Module` in any of the unit's files (and the summary blocks of the functions you document);
   - an existing `README.md` in the unit's root folder (move it into `_meta/`).
4. **Write** `_meta/README.md` from the code. Where the code and an old comment disagree, the code wins; mention the disagreement in your report. A gui that a module or a plugin tool drives also gets its Integration section (`gui/repo.md` → Gui READMEs).
5. **Remove what the README replaced.** Delete every description block above a module table in the unit (keep `--- @class`) and the old root `README.md`. Touch nothing else in those files, and stamp the Lua files you changed (`luau/authorship.md`).
6. **Cross-check.** Every public function and `I` key, Topic and remote name, `GetAttribute` / `SetAttribute` name, `*.comp.json` attribute, settings key and command alias in the unit appears in the README, and every name in the README exists in the code. Fix the README until both hold.
7. **Checks.** Run the folder's checks on the Lua files you changed (`ume/overview.md` → Checks in ume, `gui/code.md` → Checks in ume-gui, `plugin/tooling.md` in ume-rbx).
8. **Report** what the README covers, what you removed, and anything in the code that looked wrong (a manifest attribute nothing reads, a tag that doesn't match its class). Don't fix code here unless asked.
