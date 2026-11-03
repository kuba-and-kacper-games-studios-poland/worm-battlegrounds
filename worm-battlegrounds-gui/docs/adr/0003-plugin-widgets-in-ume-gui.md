# 0003: The plugin's widgets live in ume-gui and ship with every game

**Status:** Accepted
**Date:** 2026-10-16
**Deciders:** Nari
**Amends:** what ume-rbx copies in [0002](0002-games-from-new-project.md)

## Context

ume-rbx kept its widgets, one UmeGui gui per tool, in its own `src/widgets`, and built them into its seed as
`Guis/Plugin`. ume-gui shipped two example guis (`src/guis/Examples`: Inventory and Settings) as the template's guis,
which a game copied and then deleted.

Games need their own development tools (debug panels, admin and testing windows). The plugin's widgets are the most
complete guis built on the System theme, but a game never had them: they stayed inside the plugin.

## Decision

**The plugin's widgets move to ume-gui's `src/guis/Plugin`, and ume-gui owns them.** The Examples guis are removed.

- ume-rbx's `Sync.ps1 Gui` copies `src/guis/Plugin` with the engine and the System theme into `vendor/ume-gui`, and
  the seed's `Guis` comes from that copy. The seed's tree and every `Plugin/<Tool>` path stay as they were.
- Every game gets the widgets: new-project's setup copies them with the rest of ume-gui, and a game's engine update
  copies `src/guis/Plugin` with `src/engine` and `src/themes/System`. A game never edits them; its own guis go in
  folders of its own.
- The Gui tool's **Install** copies the seed whole, widgets included, so an installed place matches a game folder.

## Options considered

| | A: widgets in ume-gui (chosen) | B: widgets stay in ume-rbx, Examples stay | C: widgets in ume-rbx, ume-gui copies them |
| --- | --- | --- | --- |
| A game has System guis to build tools from | Yes, 14 working widgets | Two small examples | Yes |
| Where a widget is edited | ume-gui | ume-rbx | ume-rbx |
| Copies between the two repos | ume-rbx copies from ume-gui, as for the engine | As 0002 | Both directions |

## Consequences

- **Easier:** every game can preview the plugin's widgets in the Gui tool and start its development tools from them.
  The gui tables for UmeGui all live in one repo, checked by its `selene src` and `stylua --check src`.
- **Harder:** a widget change spans two repos: the gui in ume-gui, the tool that drives it in ume-rbx. A plugin
  release bundles the widgets from a ume-gui tag, so a release that changes a widget needs that tag first. A game's
  copy of the widgets is a snapshot of its ume-gui version; the plugin always draws its own bundled copy.
- **Unchanged:** the host API, the `Plugin/<Tool>` paths and the seed's instance tree.
