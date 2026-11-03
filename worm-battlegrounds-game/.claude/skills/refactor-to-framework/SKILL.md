---
name: refactor-to-framework
description: Refactor a script, module or directory to the ume authoring rules: structure, names, comments, types and registry alignment, not new features. Run only when the user invokes it with a target.
argument-hint: <target path>
disable-model-invocation: true
---

# Refactor to framework

*Framework skill: read only in a game (`.claude/rules/family/family.md` → Rules).*

Run on: $ARGUMENTS. If no target was given, ask for one before reading any code.

The rules in `.claude/rules/` still apply; this file is the job plan. If a step here and a rule disagree, the rule wins.

**Goal:** Make the given target match ume authoring standards. The diff is structure, naming, comments, and registry alignment — not new features.

---

## 1. Scope

The user names the target. Do **not** expand into sibling modules. Surgical: only what that target needs. No drive-by features, no unrelated cleanup.

Never edit `docs/` (`.claude/rules/family/docs.md`).

---

## 2. Read (use the Read tool)

The owning rule is the constraint. Read the matching guide when that rule is not enough (templates and long examples).

| If the target includes | Rule | Guide |
| --- | --- | --- |
| Any Lua | `.claude/rules/ume/structure.md`, `.claude/rules/luau/comments.md`, `.claude/rules/ume/environments.md`, `.claude/rules/luau/types.md`, `.claude/rules/ume/classes.md` | `docs/guides/module-structure.md`, `docs/guides/comments.md`, `docs/guides/types.md` |
| `Components/` or `*.comp.json` | `.claude/rules/ume/components.md`, `.claude/rules/ume/tooling.md` | `docs/guides/component-structure.md`, `docs/guides/tag-list-plus.md` |
| `Settings.lua` | `.claude/rules/ume/settings.md` | `docs/guides/settings-structure.md` |
| `Data/` | — | `docs/guides/data-structure.md` |
| Remotes, Topics, or the README's Network section | `.claude/rules/ume/events.md` | `.claude/skills/network-and-events/SKILL.md` (follow it too), `docs/guides/events.md`, `docs/architecture/networking.md` |
| Replicator / `I.OnLoaded` | `.claude/rules/ume/structure.md` (locals, replicator, GUI) | `docs/architecture/startup-order.md` |
| Tweens | `.claude/rules/luau/tweens.md` | — |
| `src/actors/` | — | `docs/guides/actors.md` |

---

## 3. Pass

Walk these in order. Each item names what to check; the linked rule section is the full constraint. Skip an item that does not apply to the target.

1. **Layout and lifecycle** — `.claude/rules/luau/file.md` (Skeleton, When to split, Fail fast), `.claude/rules/ume/structure.md` (Top of the file, Services, Hidden server code, Handlers, Init and Start).
   Ume pointer kept (commented when unused); no chain-checks on `I`; `I.S.*` only cached in the Services region; client/shared names free of `s_` / `server`; split by system and line band; entry is a thin shell; `Handler.Init` / `Handler.Start` call sites; `I` assigned only in the entry; correct return shape (`{ _init, _start }` vs `Module`).
2. **Rails and `I`** — `.claude/rules/luau/file.md` (Rails), `.claude/rules/ume/structure.md` (Rails, Cache `Get*`).
   Main → Initialization → Player Control → Control → Methods; Control does work, Methods return data; `I` table group order matches rail order; `_mainLoop` per-player `pcall`; cache `Get*` miss behaviour.
3. **Names** — `.claude/rules/luau/file.md` (Names).
   PascalCase on `I`, `Module._camelCase` private, `Get*` / `Can*` / `Is*` for returning Methods, single-call-site work stays inline.
4. **Comments** — `.claude/rules/luau/comments.md`, `.claude/rules/ume/environments.md`, guide `docs/guides/comments.md`.
   `%` title per function, summary, `--- @return`, `**CLIENT** |` / `**SERVER** |` only where allowed, lifecycle exceptions, `--[[ Phase ]]` bodies, guard line comments, server `I.Player.Valid` guard, client gui `Enabled` check, prefab populate order, blank-line rules.
5. **Locals, GUI, replicator** — `.claude/rules/ume/structure.md` (Locals, replicator, gui), `.claude/rules/luau/file.md` (GUI writes).
   Local order, `_getElements`, `_connectReplicator` only via `I.OnLoaded`, `_createConnections`, no GUI wrapper helpers or defensive lookups.
6. **Types** — `.claude/rules/luau/types.md`, `.claude/rules/ume/classes.md`, guide `docs/guides/types.md`.
   `{ T }` / `{ [K]: V }` only in annotations, never on a colon; `--- @param` vs colon; annotation placement (lone, trailing, `_getElements`, requires); `for` bindings typed; function-type optional params as `T | nil`; `@class` location and handler/helper class names; grouped tables; no profile class or profile repair.
7. **Settings and Data** — `.claude/rules/ume/settings.md`, `.claude/rules/luau/types.md` (Table sections), guides `docs/guides/settings-structure.md`, `docs/guides/data-structure.md`.
   Settings: `%` category bars, one-line `--` or block comments with a blank line above each, no `@field`, no instance-path requires, `I.*` inside option functions. Data rows use `--[[ ]]` section labels; a loader is not Settings.
8. **Components** — `.claude/rules/ume/components.md`, `.claude/rules/ume/tooling.md`.
   `Component.new` trio, grouped `@class`, lifecycle headers, `Destroy` disconnect loop untouched, shared id across class / manifest / tag, no `Scripts/` class clash, `warn` passes `self.Instance`, manifests only.
9. **Tweens** — `.claude/rules/luau/tweens.md`.
   `_TweenInfo` / `_TweenGoal` / `_Tween` names, goal built at the play site, `I.S.TweenService`.
10. **Network** — if the target has remotes or Topics, also follow `.claude/skills/network-and-events/SKILL.md`. Do not keep a second remote checklist here.

---

## 4. Finish

Confirm these on the diff. Do not narrate them.

- File order is the rails: Main only if there is a session loop, then Initialization, Player Control, Control, Methods.
- Every new or edited function keeps the `%` header and `--[[ Phase ]]` body (lifecycle exceptions unchanged).
- Splits follow `.claude/rules/luau/file.md` → When to split and `.claude/rules/ume/structure.md` → Handlers; entry scripts stay a thin shell.
- Types follow `.claude/rules/luau/types.md`; no profile class and no repair of saved profile data (`.claude/rules/ume/classes.md`).
- The diff is structure, naming, comments, and registry alignment — not new features.
- If `*.comp.json` or tags changed, extract them (`.claude/rules/ume/tooling.md`).
- Author lines follow `.claude/rules/luau/authorship.md`: read the nickname before creating a file, and stamp what you wrote.
- The unit's `_meta/README.md` matches the code (the `readme` skill refreshes it), and the checks in `.claude/rules/ume/overview.md` → Checks pass.
