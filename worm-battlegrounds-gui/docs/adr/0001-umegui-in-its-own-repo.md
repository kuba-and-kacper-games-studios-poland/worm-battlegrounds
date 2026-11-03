# 0001: UmeGui in its own repo, paired with each game

**Status:** Accepted
**Date:** 2026-10-15
**Deciders:** Nari

> **Update, 2026-10-16:** the agent rules moved from `.cursor/rules/` to `.claude/rules/` (`gui/format.mdc` is now
> `gui/format.md`). The text below keeps the paths it was written with.
>
> **Update, 2026-10-16:** [0002](0002-games-from-new-project.md) replaces the game layout (a game is now one repo made
> from new-project) and ume-rbx's committed copy of the engine (now copied on demand into a gitignored `vendor/`).

## Context

UmeGui, the table-driven gui framework, lives in two repos today:

| Copy | Synced to | Role |
| --- | --- | --- |
| `ume-rbx/src/gui` | `ServerStorage.UmeGui` (dev place), `UmeRbx.UmeGuiSeed` (release) | Owner. The plugin's widgets build from the seed. `scripts/Sync.ps1 Framework` copies it into ume. |
| `ume/src/gui` | `ServerStorage.UmeGui` | The copy every game gets from the ume template. |

Facts that shape the decision:

1. **The copies have already diverged.** Both say 3.5.0. ume has `Engine/Device.lua`, `Themes/System/Gamepad.lua`,
   theme-local `Controls`, the Steal And Ride guis and theme, and uncommitted edits. ume-rbx has `Controls/FileRow`,
   `Controls/Viewport` and the Sync and Character widgets. `Sync.ps1 Framework` deletes files the target has and the
   source lacks, so running it now would throw away ume's work.
2. **The template ships content that isn't template.** `ume/src/gui/Guis` holds the plugin's own widgets
   (`Guis/Plugin`) and one game's guis (`Guis/Steal And Ride`, `Themes/StealAndRide`). Every new game starts with both.
3. **ume-sync already syncs several projects into one Studio.** Its only rule is that their mounts don't overlap
   (protocol `mount_conflict`). ume and ume-rbx can't share a place because both mount `ServerStorage/UmeGui` *and*
   `ServerStorage/TagListPlus`. So the fix is in the project layout. ume-sync itself needs no change.
4. **UmeGui is used only at design time.** No game code requires `ServerStorage.UmeGui`, and ServerStorage never
   reaches clients. Guis reach the game as the ScreenGuis the Gui tool exports to StarterGui.
5. **The plugin already works with two UmeGuis.** Its widgets build from the bundled seed. The Gui tool previews and
   exports through the *place's* `ServerStorage.UmeGui` and checks first whether each newer function exists
   (`ApplyDevice`, `GetDevices`, `GetPreview`), so a place can already run a different UmeGui version from the plugin.
6. **`Libs/Mirror` comes from the game.** `Sync.ps1 Libs` copies it from the framework's libraries, including
   `global_data/Sound`, and that sound data differs per game.
7. **Auto-connect remembers one project per place** (`places[key] = { ProjectId, … }` in the Sync tool), even though
   the tool can hold several claims at once.

## Decision

UmeGui moves to its own repo, **ume-gui**. ume-gui owns the engine and is the template for every game's guis. A game
is two repos side by side: `<game>`, made from the ume template, and `<game>-gui`, cloned from ume-gui. Both sync into
the same place as two ume-sync projects whose mounts don't overlap. ume drops `src/gui`. ume-rbx no longer owns
UmeGui: it keeps a pinned copy of the engine for its own widgets, and the widgets themselves stay in ume-rbx.

Each folder has one owner. In every gui repo, `src/engine` and `src/themes/System` belong to ume-gui (upstream).
`src/guis` and every other theme belong to the repo that cloned it.

### ume-gui

```
ume-gui/
	default.project.json        ServerStorage.UmeGui
	src/
		engine/                 the UmeGui ModuleScript: init.lua, Engine/, Controls/, Libs/, Primitives.lua, _meta/, Version   [upstream]
		themes/System/          the default theme                                                                                 [upstream]
		themes/<Game>/          the game's theme, extending System                                                                [game]
		guis/                   the game's guis; the template ships guis/Examples                                                 [game]
	scripts/Sync.ps1            Libs: mirrors the paired game's libraries into src/engine/Libs/Mirror
	.cursor/rules/gui/format.mdc    the UmeGui reference (moves here from ume-rbx)
```

```json
{
	"name": "ume-gui",
	"tree": {
		"$className": "DataModel",
		"ServerStorage": {
			"$className": "ServerStorage",
			"UmeGui": {
				"$path": "src/engine",
				"Themes": { "$path": "src/themes" },
				"Guis": { "$path": "src/guis" }
			}
		}
	}
}
```

The instance tree in Studio stays exactly as it is now (`UmeGui.Engine`, `.Controls`, `.Themes`, `.Guis`, …), so the
engine code doesn't change. Only the files on disk are split. `src/engine` never contains `Guis` or `Themes`, which
lets another project add its own under the same ModuleScript (ume-rbx does).

`Sync.ps1 Libs` reads from the game repo it's paired with. By default that's the sibling folder named after this one
without `-gui` (`epic-mining-gui` reads `../epic-mining`, `ume-gui` reads `../ume`), and `-Framework <path>` overrides
it. The `Framework` mode is removed: nothing copies guis into a game repo any more.

### A game

```
Projects/
	epic-mining/          from the ume template      ServerScriptService/…, ServerStorage/TagListPlus, StarterPlayer/…
	epic-mining-gui/      cloned from ume-gui        ServerStorage/UmeGui
```

Add both folders to UmeSync and connect both in the place. Their mounts don't overlap, so neither claim is refused.

`<game>-gui` is a **clone**, not a GitHub "Use this template" copy. A clone shares history with ume-gui, so engine
updates arrive as a normal merge:

```powershell
git clone https://github.com/ume-roblox/ume-gui epic-mining-gui
cd epic-mining-gui
git remote rename origin upstream
git remote add origin https://github.com/<owner>/epic-mining-gui
git push -u origin main

# later, to update the engine
git pull upstream main        # or a tag
./scripts/Sync.ps1 Libs       # Mirror is generated: regenerate it, never merge it by hand
```

Merges are conflict-free as long as the game never edits `src/engine` or `src/themes/System`. An engine fix a game
needs goes to ume-gui first and comes back with the merge.

### ume-rbx

```
ume-rbx/
	src/core/               the plugin                                 UmeRbx
	src/widgets/            the plugin's guis (today's Guis/Plugin)    UmeRbx.UmeGuiSeed.Guis.Plugin
	vendor/ume-gui/         generated: ume-gui's src/engine and src/themes/System, at one version
	scripts/Sync.ps1 Gui    refreshes vendor/ume-gui from ../ume-gui; -Check reports drift
```

The `UmeRbx` node, the same in `plugin.project.json` and `default.project.json`:

```json
"UmeRbx": {
	"$path": "src/core",
	"UmeGuiSeed": {
		"$path": "vendor/ume-gui/engine",
		"Themes": { "$path": "vendor/ume-gui/themes" },
		"Guis": { "$className": "Folder", "Plugin": { "$path": "src/widgets" } }
	}
}
```

- `default.project.json` mounts only `ServerStorage/UmeRbx`. The `UmeGui` and `TagListPlus` mounts and `src/other` go
  (`TagListPlus.model.json` is generated from a game's components, so it belongs to the game repo). The ume-rbx dev
  place connects **ume-rbx + ume-gui**, so the Gui tool has a real `ServerStorage.UmeGui` to work on.
- Each tool's `Gui/Main.lua` still mounts `"Plugin/<Tool>"`. The seed's instance tree is unchanged.
- `Helpers/UmeGui.Install` copies the seed **without** `Guis/Plugin` (it leaves an empty `Guis`), so a place never
  gets the plugin's widgets. It remains the quick path for places that have no gui repo.
- The Sync tool remembers a **list** of projects per place, and Auto-connect reconnects all of them. The saved-data
  schema migrates `ProjectId`/`ProjectName` into a one-item list.
- `vendor/ume-gui` is a copy, like `Libs/Mirror` is today: generated, checked with `-Check`, never edited by hand. Its
  `Version` says which UmeGui a plugin release bundles.

### The contract between ume-rbx and a place's UmeGui

The Gui tool calls six functions on the place's `ServerStorage.UmeGui`: `Build`, `Export`, `GetGuiNames`,
`GetPreview`, `GetDevices` and `ApplyDevice`. Now that every game updates its engine on its own schedule, ume-gui
documents these as its **host API**. Removing one or changing its shape is a major version. The plugin keeps checking
for newer functions before calling them, so it works with older games and newer ones.

## Options considered

| | A: own repo per game, ume-rbx keeps a copy (chosen) | B: gui stays in the game repo, drop ume-rbx's overlapping mounts | C: one shared ume-gui synced into every game | D: like A, but ume-rbx uses a git submodule | E: plugin builds its widgets from the place's UmeGui |
| --- | --- | --- | --- | --- | --- |
| Fixes the sync conflict | Yes | Yes | Yes | Yes | Yes |
| Engine copies to keep in step | 1 owner; ume-rbx's copy is generated | 2 owners, copy script between them | 1 | 1 owner; a pinned submodule | 1 |
| New games start clean | Yes | No (plugin widgets, Steal And Ride) | No (every game's guis) | Yes | Yes |
| Engine version per game | Yes | Yes | No | Yes | Yes |
| Repos per game | 2 | 1 | 1 + shared | 2 | 2 |
| Migration effort | Medium | Small | Medium | Medium | Medium, plus risk |

### A: Own repo per game, ume-rbx keeps a pinned copy (chosen)
- **Pros:** one owner and one history for the engine. Templates hold only template content. Each game updates its
  engine when it chooses to. ume-rbx releases are reproducible and need nothing next to them to build. It reuses the
  copy-and-check approach the family already uses (`Libs/Mirror`).
- **Cons:** two repos and two UmeSync projects per game. An engine change that a plugin widget needs takes one extra
  step (`Sync.ps1 Gui`) before ume-rbx sees it.

### B: Gui stays in the game repo; only remove ume-rbx's overlapping mounts
- **Pros:** the smallest change. It unblocks syncing ume and ume-rbx together today.
- **Cons:** the engine keeps two owners and a copy script between them, which is how it diverged in the first place.
  The template keeps shipping the plugin's widgets and a game's guis. Game code and gui design stay in one repo.

### C: One shared ume-gui synced into every game
ume-sync's ADR 0011 allows one project in many places.
- **Pros:** one engine checkout for everything.
- **Cons:** every game's guis end up in one repo and in every place. A game can't stay on an older engine. A
  per-game `Libs/Mirror` (sounds) is impossible.

### D: Like A, but ume-rbx takes ume-gui as a git submodule
- **Pros:** the pin is an exact commit, with no copy script.
- **Cons:** every clone needs `--recursive`, and submodules are awkward on Windows. The submodule brings the template's
  `guis/Examples` and theme slots, which the project file would have to skip. ume-sync treats it as plain files
  anyway. It's also a second way of sharing code in a family that already uses copy-and-check.

### E: The plugin builds its own widgets from the place's `ServerStorage.UmeGui`
- **Pros:** one engine in the place and no bundled copy.
- **Cons:** the plugin's own UI breaks in places without UmeGui, with an old one, or while a game's gui repo is
  mid-edit. A game could break the plugin.

## Trade-off analysis

The core trade is **one more repo and one more UmeSync project per game** against **one owner for the engine and
clean templates**. Option B is cheaper today, but it keeps the setup that let the two copies diverge, and that
divergence is now the most expensive part of this migration. The extra repo costs little because ume-sync already
handles several projects per place. The one real gap is Auto-connect remembering a single project, and that's a small
change in the Sync tool.

For ume-rbx, a plain copy (A) beats a submodule (D) because the plugin needs only part of ume-gui (`engine` and
`themes/System`, not `guis`), and the family already keeps generated copies with a drift check. Building the plugin's
widgets from the place's UmeGui (E) is ruled out because a game must never be able to break the plugin's own UI.

Splitting `src/engine` from `src/guis` and `src/themes` costs one indirection in the project file. In return, ownership
is visible on disk, upstream merges stay clean, ume-rbx can add its widgets without name clashes, and agents get a
simple rule: never edit `src/engine` in a game repo.

## Consequences

- **Easier:**
  - A game and its gui repo, or ume-rbx and ume-gui, sync into one Studio with no `mount_conflict`.
  - The engine has one history, so changes no longer split between two copies.
  - New games start with only the engine and an example.
  - Gui work can happen in the gui repo alone.
  - The Gui tool works with every game, whatever UmeGui version that game has.
- **Harder:**
  - Every game needs two clones and two connected projects.
  - An engine change used by a plugin widget means editing in ume-gui, then running `Sync.ps1 Gui` in ume-rbx.
  - Upstream merges depend on the ownership rule. A game that edits `src/engine` will get merge conflicts.
  - `Libs/Mirror` must be regenerated after every merge from upstream.
- **Revisit:**
  - Plugin-only controls (`FileRow`) stay upstream for now. If more appear, ume-rbx can define its own theme that
    extends System and carries its own `Controls`. Themes already support this (`Themes/StealAndRide/Controls`).
  - If keeping two clones in step gets tedious, add a VS Code workspace file to the ume template that opens
    `<game>` and `<game>-gui` together.

## Action items

1. [x] **Reconcile the two copies** into one engine before moving anything. Commit ume's pending gui edits first,
   then merge ume's `Device`, `Gamepad` and theme-local `Controls` with ume-rbx's `FileRow`, `Viewport` and widget
   changes. Bump UmeGui to 3.6.0.
2. [x] **Fill ume-gui:** `src/engine`, `src/themes/System`, `src/guis/Examples`, `default.project.json`,
   `scripts/Sync.ps1` (Libs, defaulting to the paired repo), `rokit.toml`, `selene.toml`, `stylua.toml`,
   `.cursor/rules/gui/format.mdc`, a `CLAUDE.md` stating the ownership rule, and docs (host API, starting a game's gui
   repo). Tag `v3.6.0`.
3. [x] **Give Steal And Ride its own gui repo,** cloned from ume-gui, holding `Guis/Steal And Ride` and
   `Themes/StealAndRide`.
4. [x] **ume:** delete `src/gui` and the `ServerStorage.UmeGui` mount. The README and docs say to pair a game with
   ume-gui.
5. [x] **ume-rbx:** move `src/gui/Guis/Plugin` to `src/widgets`, replace `Sync.ps1`'s Framework and Libs modes with
   `Gui`, add `vendor/ume-gui`, and update both project files. Drop the `UmeGui` and `TagListPlus` mounts and
   `src/other`. Make `Install` leave out `Guis/Plugin`. Fix the comment in `src/core/_meta/_types.lua`. Update
   `CLAUDE.md` and `docs/` (architecture, umegui, development). Have `Release.ps1` run `Sync.ps1 Gui -Check`.
6. [x] **ume-rbx Sync tool:** remember a list of projects per place, have Auto-connect reconnect all of them, and
   migrate the saved-data schema.
7. [x] **ume-versions:** add ume-gui to the family table and a `gui.json` badge.
8. [x] **Verify in Studio:** connect ume and ume-gui in one place, and ume-rbx and ume-gui in the dev place. Check that
   both sync, that the Gui tool lists ume-gui's guis, that an export reaches StarterGui, and that the plugin's widgets
   still build from the seed.
