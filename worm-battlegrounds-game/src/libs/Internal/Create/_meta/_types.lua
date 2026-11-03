--%%%%%%%%%%%%%%%%%%%% Property Info

--[[
	Cached reflection data for one property of a class.
]]
--- @class Create_PropertyInfo
---
--- # Types #
---
--- @field ScriptType string
--- @field EngineType string?
--- @field EnumType string?
--- @field InstanceType string?
---
--- # Access #
---
--- @field Writable boolean
local _create_PropertyInfo = {}

--%%%%%%%%%%%%%%%%%%%% Factory

--- @alias Create_Factory (properties: { [string]: any } | nil, attributes: { [string]: any } | nil) -> Instance
