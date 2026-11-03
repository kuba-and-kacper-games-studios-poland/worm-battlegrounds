--- @class Component
--- @field __index Component
---
--- # State #
---
--- @field Instance Instance | any
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Where It Builds #
---
--- @field Ancestors { Instance }?
--- @field IgnoreAncestors { Instance }?
---
--- # Methods #
---
--- @field new (instance: Instance) -> ()
--- @field Init function
--- @field Destroy function
local _component = {}

--- @class Component_TagSignals
--- @field Added Signal
--- @field Removed Signal
local _component_TagSignals = {}
