# Ume classes

Where each `@class` lives in a game module and what it is called. How types are written: `luau/types.md`. Examples:
`docs/guides/types.md`.

## Where `@class` lives

- A component's `@class` is in its component script (field order: `ume/components.md`).
- The Settings `@class` is in `Settings.lua` (`ume/settings.md`).
- A module's shared or repeated data shapes go in `<Module>/_meta/_types.lua`; core types in `src/core/_meta/_types.lua`.
- Entry scripts (`Server.lua`, `Client.lua`, `Global.lua`) have no `@class` on `local Module = {}`.
- A library's `init.lua` is `Ume_Library_<Name> : Ume_Library`.
- A `Scripts/` module has a `--- @class` with no `@field` lines, named after its path:
  - a handler: `ModuleName_Server_HandlerName`, `ModuleName_Client_HandlerName` or `ModuleName_Global_HandlerName`
    (Inventory's `Scripts/Server/Add.lua` is `Inventory_Server_Add`);
  - a helper in `Scripts/Helpers`, or a ModuleScript directly under `Scripts/`: `ModuleName_ScriptName`
    (`MessageWidget.lua` is `WidgetManager_MessageWidget`);
  - never the `@class` or tag of a component in the same module (`ume/components.md`).

## Profile data

Never write a class for saved profile data: no `ModuleName_ProfileData` or `Player_ProfileData`, no `@class` for a key
stamped on `I.Player.ProfileTemplate`, no custom class on `moduleData`, and no function that repairs or reshapes saved
data. The template in the module's entry script is the shape, and the module's README lists it (Data).
