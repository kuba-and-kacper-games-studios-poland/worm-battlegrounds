# Luau authorship

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

Every Luau file starts with the author header, except `_meta` files, ume's `Settings.lua` (`ume/settings.md`) and
ume-rbx's `init.server.lua` (which keeps its art banner):

```lua
--[[
	Created By: 	<nickname>
]]
```

## The nickname

Find it before creating a file, and never invent one. Take the first of:

1. ume-sync's `ume_settings` MCP tool, with `project` set to this folder's UmeSync project. It reads `general.username`
   in `ume.yaml`, then UmeSync's nickname setting, then the editor's `ume-vscode.general.username`.
2. Without ume-sync: `ume-vscode.general.username` in the editor's user `settings.json`
   (`%APPDATA%/Cursor/User/settings.json` or `%APPDATA%/Code/User/settings.json`). Missing, empty or `-` is none.
3. Otherwise ask the user (offer `git config user.name` as a guess), and save their answer with ume-sync's
   `set_nickname`.

A project that always uses one nickname sets it once in its `ume.yaml` (`general.username`), which step 1 reads.

## Created By / Edited By

- A new file gets `Created By:` with that nickname, never a name copied from another file.
- An existing file keeps its `Created By`. A different author adds `Edited By:` on the next line, comma-separating
  further names without repeats.
- After writing Luau files, call ume-sync's `stamp_authorship` with them (`project`, `paths`), leaving out
  ume's `Settings.lua`; it applies these rules.
  A new file may carry the placeholder `Created By: 	{username}`, which the tool fills in. Without ume-sync, write the
  lines yourself.
