# Architecture decision records

One file per decision that is hard to reverse. Most come from My Tree Farm, the first game built on new-project, where
they were settled before they moved into ume (its lessons tell each story in full).

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](0001-windows-open-through-widgetmanager.md) | Windows open through WidgetManager, never a module's `Open` | Accepted |
| [0002](0002-tags-are-authored.md) | Component tags are authored; code writes attributes | Accepted |
| [0003](0003-values-from-the-clock-and-the-player.md) | Values every server shares come from the clock; values others see go on the `Player` | Accepted |
| [0004](0004-keys-and-chat-commands.md) | Number keys belong to the hotbar; admin tools open from keys; chat commands are made on the server | Accepted |
| [0005](0005-what-modules-keep-in-the-place.md) | `PREFAB \| Name` templates, holder parts, and a world folder per module | Accepted |
| [0006](0006-lighting-presets-in-the-place.md) | Lighting presets live in the place, shared with the plugin | Accepted |
| [0007](0007-effects-only-while-shown.md) | Gui effects run only while they show | Accepted |
| [0008](0008-adminpanel-replaces-command.md) | AdminPanel replaces Command | Accepted, ume 2.0.0 |
| [0009](0009-priority-bands-100.md) | Priority bands run from 100 down to -100 | Accepted, ume 2.0.0 |
| [0010](0010-game-agent-files-in-dot-game.md) | A game's agent files ship in `.game/` | Accepted, ume 2.0.0 |
