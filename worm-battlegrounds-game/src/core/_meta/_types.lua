--[[
	Configuration for a specific place.
]]
--- @class Ume_PlaceLoader_PlaceSettings
---
--- # Places #
---
--- @field DefaultMapId string
--- @field LobbyId string
---
--- # Maps #
---
--- @field MapConfigs { [string]: Ume_PlaceLoader_MapSettings }
local _Ume_PlaceLoader_PlaceSettings = {}

--[[
	Configuration for the currently loaded map.
]]
--- @class Ume_PlaceLoader_MapSettings
---
--- # Stores #
---
--- @field ProfileStoreName string
--- @field LeaderboardStoreName string
---
--- # Support #
---
--- @field VRSupport boolean
---
--- # Game #
---
--- @field GameDirs { [string]: { string } }
---
--- # Modules #
---
--- @field ModulesDirs { string }
--- @field DisabledModules { string }
--- @field LoadingOrder { string }
---
--- # Return #
---
--- @field ReturnPlaceId number?
local _Ume_PlaceLoader_MapSettings = {}

--[[
	Metadata for the currently loaded map.
]]
--- @class Ume_PlaceLoader_Metadata
--- @field AccessCode string
local _Ume_PlaceLoader_Metadata = {}

--%%%%%%%%%%%%%%%%%%%% Priority

--- @class Ume_Priority
---
--- # Framework #
---
--- @field First number
--- @field Last number
---
--- # Modules #
---
--- @field Data number
--- @field Replicator number
--- @field Setup number
--- @field Default number
--- @field Late number
local _ume_Priority = {}

--[[
	One priority bucket after sorting, highest key first.
]]
--- @class Ume_PriorityFunctionEntry
---
--- # Entry #
---
--- @field key number
--- @field functions { function }
local _Ume_PriorityFunctionEntry = {}

--%%%%%%%%%%%%%%%%%%%% Library

--[[
	A library module that can assign itself onto the Ume instance.
]]
--- @class Ume_Library
--- @field _injectUme ((umeInstance: Ume) -> ())?
local _Ume_Library = {}

--%%%%%%%%%%%%%%%%%%%% Modules

--[[
	One module function timing after a load pass.
]]
--- @class Ume_ModuleExecEntry
---
--- # Entry #
---
--- @field FunctionName string
--- @field ExecTime number
local _Ume_ModuleExecEntry = {}

--%%%%%%%%%%%%%%%%%%%% Replication Gate

--[[
	One node in the descendant name tree stored on the replication manifest.
]]
--- @class ReplicationGate_NameTreeNode
---
--- # General #
---
--- @field name string
---
--- # Branch #
---
--- @field children { ReplicationGate_NameTreeNode }?
--- @field descendantCount number?
local _ReplicationGate_NameTreeNode = {}
