<h1 align="center">Project Structure</h1>

<p align="center">
Repository layout. Roblox mapping lives in <code>default.project.json</code>.
</p>

---

<br>

- **`default.project.json`**
    > _Rojo project file: maps repo folders into Roblox Services._
- **`src/`**
    - **`actors/`**
        > `src/actors/server/` (created on first use)
        >
        > _GameMode `Actors` scripts. `default.project.json` already maps `src/actors/server` to `ServerScriptService.Actors`; a client folder needs its own mapping. Execution is not tied to framework module initialization. [Actors](../guides/actors.md)._
    - **`core/`**
        > `src/core/_meta/_types.lua` - _Shared Lua types for core._
        > `src/core/_meta/README.md` - _What core does and the remotes it creates._
        >
        > _Framework bootstrap (`game_mode`, `game_instance`). Boot sequence: [Startup order](startup-order.md)._
        - **`game_mode/`**
            > `src/core/game_mode/client/Ume-Client.client.lua`  
            > `src/core/game_mode/server/Ume-Server.server.lua`
            >
            > _Main client/server scripts that start the framework on each environment._
        - **`game_instance/`**
            > `src/core/game_instance/Failed/init.lua`  
            > `src/core/game_instance/Start/init.lua`  
            > `src/core/game_instance/Start/configs/`  
            > `src/core/game_instance/Start/tasks/`
            >
            > _Configs, tasks, and loaders for libraries and modules._
    - **`global_data/`**
        > `src/global_data/`
        >
        > _Configuration read by `modules_ume`; keeps tunables out of `modules_ume/` sources. [Global data](../reference/global-data.md)._
    - **`libs/`**
        > `src/libs/External/`  
        > `src/libs/Internal/`
        >
        > _`External` = vendored/third-party; `Internal` = ume-maintained helpers._
    - **`modules/`**
        > `src/modules/Main/`  
        > `src/modules/Main_Controllers/`  
        > `src/modules/Main_Game/`  
        > `src/modules/Utils/`
        >
        > _Game logic and feature modules._
    - **`modules_ume/`**
        > `src/modules_ume/Roblox/`  
        > `src/modules_ume/Ume/`  
        > `src/modules_ume/Ume_Data/`
        >
        > _Stable framework modules for in-framework communication; Roblox API integration under `Roblox/`. Routine game work does not edit this tree._
    - **`other/`**
        > `src/other/TagListPlus.model.json`
        >
        > _TagListPlus component registry for CollectionService. Produced by the VS Code Ume plugin; used by the Roblox Studio Ume plugin. [TagListPlus](../guides/tag-list-plus.md)._

<br>

## Guis

A game's guis are not in this repo. In a game made from the
[new-project](https://github.com/ume-roblox/new-project) template, they live next to the game's `<game>-game` folder
in `<game>-gui`, a copy of [ume-gui](https://github.com/ume-roblox/ume-gui), which syncs `ServerStorage.UmeGui` (UmeGui:
guis as tables, previewed and exported to StarterGui by the Roblox Studio Ume plugin). Connect both projects to the
same place in UmeSync: they never sync the same instances. Setup and engine updates: ume-gui's
`docs/getting-started.md`.
