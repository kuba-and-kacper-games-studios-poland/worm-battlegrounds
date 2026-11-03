# Ume overview

| Rule | Owns |
| --- | --- |
| `game/*` | In a game: its own rules, which win over these (`family/family.md` → Rules) |
| `luau/file.md` | File skeleton, rails, names, splits, fail fast, gui writes |
| `luau/comments.md` | Function headers, `--[[ Phase ]]` bodies, comments outside functions |
| `luau/types.md` | Annotations, table type syntax, table sections, `_meta/_types.lua` |
| `luau/tweens.md` | Tween locals |
| `luau/authorship.md` | The author header |
| `luau/readme.md` | The unit `_meta/README.md` |
| `luau/studio.md` | Studio through ume-sync and the Studio MCP |
| `ume/structure.md` | Module layout: `I`, services, server hiding, handlers, `Init` / `Start`, rails, cache `Get*`, gui locals |
| `ume/environments.md` | `**SERVER**` / `**CLIENT**` marks, the player guard, client and Global functions |
| `ume/classes.md` | Where each `@class` lives and its name, profile data |
| `ume/settings.md` | `Settings.lua`: its shape, category bars and comments |
| `ume/events.md` | Remotes, `argTypes`, the server deciding amounts, Topics, the README's Network section |
| `ume/components.md` | Component lifecycle, `Destroy`, `*.comp.json`, tags, loading, effects only while shown, warns |
| `ume/values.md` | Amounts, values every server shares, where per-player values live |
| `ume/input.md` | Keys, admin tools, chat commands |
| `ume/place.md` | Prefab names, templates on holder parts, a module's world folder, lighting presets |
| `ume/tooling.md` | Extracts, banners, selene, StyLua, builds |
| `family/*` | Shared rules: where this code comes from and what may change, working style, docs, and commits (in a game) or releases (in ume) |

## Before writing

Before creating or restructuring a Luau file, read its guide in `docs/guides/`:

| Writing | Guide |
| --- | --- |
| Entry scripts (`Server.lua`, `Client.lua`, `Global.lua`), `Scripts/` handlers and helpers | `module-structure.md` |
| Any function | `comments.md` |
| Annotations, `_meta/_types.lua` | `types.md` |
| `Components/*.lua`, `*.comp.json` | `component-structure.md`, `tag-list-plus.md` |
| `Settings.lua` | `settings-structure.md` |
| `Data/**` rows and loaders | `data-structure.md` |
| Remotes, Topics, the README's Network section | `events.md` |
| `_meta/README.md` | `module-readme.md` |
| Scripts under `src/actors/` | `actors.md` |

Guides are templates and long examples; where one differs from a rule, the rule wins. `docs/architecture/` and
`docs/reference/` explain how the framework runs: open them only when the task depends on startup order, networking,
the `I.*` surface or `src/global_data/`.

Skills in `.claude/skills/` are job plans; where a skill and a rule disagree, the rule wins.

## Checks

There are no unit tests. Before calling a change done:

1. `selene src` and StyLua pass on the files you changed (`ume/tooling.md`).
2. The code follows its owning rules (the table above). Check them; don't narrate them.
3. The unit's `_meta/README.md` matches what you changed (`luau/readme.md`).
4. For behaviour, name the observable (Output text, a remote payload, a gui property, an attribute) and check it in
   Studio (`luau/studio.md`). Don't build a test harness.
