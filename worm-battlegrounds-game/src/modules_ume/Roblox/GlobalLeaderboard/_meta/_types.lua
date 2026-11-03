--%%%%%%%%%%%%%%%%%%%% Page Data

--- @class GlobalLeaderboard_PageData
--- @field key string
--- @field value number
local _globalLeaderboards_PageData = {}

--- @alias GlobalLeaderboard_OrderedDataStore OrderedDataStore | MockDataStores_OrderedDataStore
--- @alias GlobalLeaderboard_DataStorePages DataStorePages | MockDataStores_DataStorePages

--%%%%%%%%%%%%%%%%%%%% Update Group

--- @class GlobalLeaderboard_RegisterUpdateFunction_Table
--- @field UpdateFunction function
--- @field CacheOnUpdate boolean?
--- @field IsAscending boolean
--- @field PageSize number
local _globalLeaderboards_RegisterUpdateFunction_Table = {}

--- @class GlobalLeaderboard_UpdateGroup
--- @field FunctionTables { [string]: GlobalLeaderboard_UpdateGroup_FunctionTable }
--- @field CurrentUpdateIndex number
--- @field TotalUpdateFunctions number
--- @field IsRunning boolean
local _globalLeaderboards_UpdateGroup = {}

--- @class GlobalLeaderboard_UpdateGroup_FunctionTable
---
--- # Update #
---
--- @field UpdateFunction function
--- @field CacheOnUpdate boolean
---
--- # Store #
---
--- @field StoreName string
--- @field Scope string?
--- @field IsAscending boolean
--- @field PageSize number
local _globalLeaderboards_UpdateGroup_FunctionTable = {}
