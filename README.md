# Worm Battlegrounds

A Roblox game built on the ume framework.

| Folder | What | UmeSync project |
| --- | --- | --- |
| `worm-battlegrounds-game/` | The game's code, started from ume v2.0.0 | `worm-battlegrounds-game` |
| `worm-battlegrounds-gui/` | The game's guis, started from ume-gui v4.1.0, with the `WormBattlegrounds` theme | `worm-battlegrounds-gui` |
| `worm-battlegrounds.rbxl` | The place both sync into | |

## Working on it

1. **Tools.** With [Rokit](https://github.com/rojo-rbx/rokit) installed, run `rokit install` in each folder (selene,
   StyLua).
2. **Sync.** In [UmeSync](https://github.com/ume-roblox/ume-sync), make a category **Worm Battlegrounds** and add both folders
   to it.
3. **Studio.** Open `worm-battlegrounds.rbxl` and connect both projects in the [Ume Roblox](https://github.com/ume-roblox/ume-rbx)
   plugin's **Sync** tool. They never sync the same instances, so both stay connected.

Each folder has its own `AGENTS.md` and rules, from the framework or the engine it was copied from, and the game's
own decisions are in `worm-battlegrounds-game/.claude/rules/game/practices.md`.
