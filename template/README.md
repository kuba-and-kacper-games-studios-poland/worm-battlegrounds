# {{Title}}

A Roblox game built on the ume framework.

| Folder | What | UmeSync project |
| --- | --- | --- |
| `{{Name}}-game/` | The game's code, started from ume {{UmeRef}} | `{{Name}}-game` |
| `{{Name}}-gui/` | The game's guis, started from ume-gui {{UmeGuiRef}}, with the `{{Theme}}` theme | `{{Name}}-gui` |
| `{{Name}}.rbxl` | The place both sync into | |

## Working on it

1. **Tools.** With [Rokit](https://github.com/rojo-rbx/rokit) installed, run `rokit install` in each folder (selene,
   StyLua).
2. **Sync.** In [UmeSync](https://github.com/ume-roblox/ume-sync), make a category **{{Title}}** and add both folders
   to it.
3. **Studio.** Open `{{Name}}.rbxl` and connect both projects in the [Ume Roblox](https://github.com/ume-roblox/ume-rbx)
   plugin's **Sync** tool. They never sync the same instances, so both stay connected.

Each folder has its own `AGENTS.md` and rules, from the framework or the engine it was copied from, and the game's
own decisions are in `{{Name}}-game/.claude/rules/game/practices.md`.
