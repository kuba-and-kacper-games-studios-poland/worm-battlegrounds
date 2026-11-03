# Studio

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

How an agent works with Roblox Studio. The UmeSync project and its place: `AGENTS.md` → Studio.

| MCP server | Tools | For |
| --- | --- | --- |
| **ume-sync** | `mcp__ume-sync__*` | Connecting a folder to a place, the sync review and state, checks (`code_tools`, `check`, `format`), the extracts and banners (`ume/tooling.md`), the author stamp (`luau/authorship.md`), alerts (`notify_user`) |
| **Roblox Studio** | `mcp__Roblox_Studio__*` | Looking inside the open place: instances, Luau in edit mode, the Output, play tests, screenshots |

ume-sync is the only way files reach Studio. Never write scripts into the place with the Studio tools in place of a sync.

## Connecting

Only when the user asks to connect, sync or check something in Studio:

1. **ume-sync**: if its tools are missing or refuse to connect, the UmeSync app (or its MCP server) isn't running: tell
   the user. One-time setup: `claude mcp add --transport http --scope user ume-sync http://127.0.0.1:34880/mcp`.
2. **The project**: `list_projects`, and take the one whose `path` is this folder (match the path, not the name). If
   it isn't listed, ask before `add_project`.
3. **The Studio**: `list_studios`, and take the one with that place open. If none has it, several do, or the
   only one has another place, ask. Never assume the only open Studio is the right one. It needs the Ume plugin's Sync
   tool with **Let agents control this Studio** on.
4. **Connect**: `connect_studio` with `project` and `studio`.
   - `in_use`: another Studio holds this place for the project; ask before passing `force`.
   - `place_not_allowed`, `mount_conflict`, or folders a Team Create collaborator holds: report it and stop.
   - A review: show the counts of added, changed and removed files, and `answer_review` with `accept: true` only when
     the user asked to sync.
5. **Confirm** with `sync_status`, and say which project is synced into which place.

`disconnect_studio` and `resync` take the same `project` and `studio`.

## Editing and checking

- Before editing Luau, call `code_tools` once to see which checks are set up.
- After editing, `check` the files you changed (`paths`): selene, StyLua and ume-lsp as the editor shows them. Stamp
  them first (`luau/authorship.md`).
- Check behaviour with the Studio tools (instances, Luau in edit mode, the Output).
- Call `notify_user` (`kind`, `message`) when you need the user (a question, an approval, a blocker) and when a long
  task ends, never for routine progress. When the result says it wasn't shown, say it in the chat.
