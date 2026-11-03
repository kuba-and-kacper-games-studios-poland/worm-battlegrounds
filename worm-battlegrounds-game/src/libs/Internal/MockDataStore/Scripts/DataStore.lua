--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Copy Value

--[[
	Deep copies a stored value so callers cannot mutate the store, like a real DataStore round trip.
]]
--- @return any
local function copyValue(value: any)
	--[[ Checks ]]

	-- Return non-table values as they are
	if type(value) ~= "table" then
		return value
	end

	--[[ Copying ]]

	local copy = {}

	for key: any, entry: any in pairs(value) do
		copy[key] = copyValue(entry)
	end

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class MockDataStores_DataStore
local DataStore = {}
DataStore.__index = DataStore

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Creates an in-memory DataStore substitute.
]]
--- @return MockDataStores_DataStore
function DataStore.new()
	return setmetatable({ _entries = {} }, DataStore)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Async

--[[
	Stores a copy of `value` under `key`.
]]
function DataStore:SetAsync(key: any, value: any)
	self._entries[tostring(key)] = copyValue(value)
end

--%%%%%%%%%%%%%%%%%%%% Update Async

--[[
	Passes a copy of the current value to `transform` and stores its result.
	Returning nil from `transform` cancels the update, like the real API.
]]
--- @return any
function DataStore:UpdateAsync(key: any, transform: (oldValue: any) -> any)
	--[[ Local Variables ]]

	local keyString: string = tostring(key)
	local newValue: any = transform(copyValue(self._entries[keyString]))

	--[[ Checks ]]

	-- Cancel the update when the transform returns nil
	if newValue == nil then
		return nil
	end

	--[[ Saving ]]

	self._entries[keyString] = copyValue(newValue)

	--[[ Returning ]]

	return copyValue(newValue)
end

--%%%%%%%%%%%%%%%%%%%% Increment Async

--[[
	Adds `delta` (default 1) to the number stored under `key` and returns the new value.
]]
--- @return number
function DataStore:IncrementAsync(key: any, delta: number?)
	--[[ Local Variables ]]

	local keyString: string = tostring(key)
	local newValue: number = (self._entries[keyString] or 0) + (delta or 1)

	--[[ Saving ]]

	self._entries[keyString] = newValue

	--[[ Returning ]]

	return newValue
end

--%%%%%%%%%%%%%%%%%%%% Remove Async

--[[
	Removes the value under `key` and returns it.
]]
--- @return any
function DataStore:RemoveAsync(key: any)
	--[[ Local Variables ]]

	local keyString: string = tostring(key)
	local oldValue: any = self._entries[keyString]

	--[[ Removing ]]

	self._entries[keyString] = nil

	--[[ Returning ]]

	return oldValue
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Async

--[[
	Returns a copy of the value stored under `key`.
]]
--- @return any
function DataStore:GetAsync(key: any)
	return copyValue(self._entries[tostring(key)])
end

return DataStore
