--%%%%%%%%%%%%%%%%%%%% Page Data

--[[
	One row returned by `OrderedDataStore:GetSortedAsync` pages.
]]
--- @class MockDataStores_PageData
---
--- # Entry #
---
--- @field key string
--- @field value number
local _mockDataStores_PageData = {}

--%%%%%%%%%%%%%%%%%%%% Data Store Pages

--[[
	DataStorePages substitute returned by `OrderedDataStore:GetSortedAsync`.
]]
--- @class MockDataStores_DataStorePages
---
--- # State #
---
--- @field IsFinished boolean
---
--- # Paging #
---
--- @field GetCurrentPage (self: MockDataStores_DataStorePages) -> { MockDataStores_PageData }
--- @field AdvanceToNextPageAsync (self: MockDataStores_DataStorePages) -> ()
local _mockDataStores_DataStorePages = {}
