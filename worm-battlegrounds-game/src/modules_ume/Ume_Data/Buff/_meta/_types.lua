--- @class Buff_BuffData
---
--- # Default #
---
--- @field DefaultValue string | number
---
--- # Combining #
---
--- @field Mode "Add" | "Multiply" | "Max" | nil
---
--- # Updates #
---
--- @field ServerUpdate boolean?
--- @field ServerUpdateIndividual boolean?
--- @field ClientUpdate boolean?
--- @field ClientUpdateIndividual boolean?
local _buffs_BuffData = {}

--- @class Buff_BuffTable
--- @field Values { [string]: string | number }
--- @field Sum string | number
local _buffs_BuffTable = {}

--- @class Buff_State
--- @field Current { [string]: Buff_BuffTable }
--- @field Expiry { [string]: { [string]: number } }
local _buff_State = {}
