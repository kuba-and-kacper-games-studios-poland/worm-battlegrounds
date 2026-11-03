# Ume tooling

The extract and banner jobs are ume-sync MCP tools (UmeSync 1.4.0 or newer), called with `project` set to this
folder's UmeSync project (`AGENTS.md` → Studio). They write where `ume.yaml` says. When the tools are missing, ask the user to run the same job from
the UmeSync project menu (or the `Ume: …` command in VS Code or Cursor).

| After | Call | Then |
| --- | --- | --- |
| Changing a `*.comp.json` | `extract_components` (**Extract components**) | In Studio, TagList+ → Load Tags |
| Changing a `*.d.lua` | `extract_types` (**Extract types**): merges them into `src/other/types.d.lua` | |
| A module's ASCII banner drifted | `fix_banners` with `paths`, or none for the whole project (**Fix ASCII banners**) | |

- Edit `*.comp.json` manifests only: never `src/other/TagListPlus.model.json` by hand, or the TagListPlus folder the
  plugin builds.
- **Lint and format:** after editing Lua, run selene and StyLua (`AGENTS.md` → Commands) or ume-sync's `check`
  (`luau/studio.md`), and fix what they report in your files.
- **Builds:** check structural changes (new folders, `init.lua` conversions, moved files) with ume-sync's
  `instance_tree`, or the build in `AGENTS.md` → Commands.
