--- Tool session slice added by `Tool` module **Server** `Init` (`Player.SessionTemplate["Tool"]`).
--- @class Player_SessionData_Tool
--- @field CurrentlyEquipped Tool?
--- @field CreatedTools { [string]: Tool }
--- @field ToolsData { [string]: table }
--- @field ToolsConnections table

--- Tool script module API when required from the env **Server** script (`Server` under `global_data/Tool/...`).
--- @class Tool_ToolModule_Server
---
--- # Settings #
---
--- @field Cooldown number?
---
--- # Callbacks #
---
--- @field Init () -> ()
--- @field Equipped (player: Player, tool: Tool, toolUUID: string) -> ()
--- @field Unequipped (player: Player, tool: Tool, toolUUID: string) -> ()
--- @field Activated (player: Player, tool: Tool, toolUUID: string) -> ()
--- @field Deactivated (player: Player, tool: Tool, toolUUID: string) -> ()
--- @field Destroy (player: Player, tool: Tool, toolUUID: string) -> ()
local _tool_ToolModule_Server = {}

--- Tool script module API when required from the env **Client** script (`Client` under `global_data/Tool/...`).
--- @class Tool_ToolModule_Client
--- @field Init () -> ()
--- @field Equipped (tool: Tool, toolUUID: string) -> ()
--- @field Unequipped (tool: Tool, toolUUID: string) -> ()
--- @field Activated (tool: Tool, toolUUID: string) -> ()
--- @field Deactivated (tool: Tool, toolUUID: string) -> ()
--- @field Destroy (tool: Tool, toolUUID: string) -> ()
local _tool_ToolModule_Client = {}
