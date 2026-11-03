--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Create Pages

--[[
	Builds a DataStorePages substitute over already sorted rows.
]]
--- @param rows { MockDataStores_PageData }
--- @return MockDataStores_DataStorePages
local function createPages(rows, pageSize: number)
	--[[ Local Variables ]]

	local pageStart: number = 1

	--- @type MockDataStores_DataStorePages
	local pages = {
		IsFinished = #rows <= pageSize,
	}

	--%%%%%%%%%%%%%%%%%%%% Get Current Page

	--[[
		Returns the rows on the current page.
	]]
	--- @return { MockDataStores_PageData }
	function pages:GetCurrentPage()
		--[[ Collecting ]]

		local page = {} --- @type { MockDataStores_PageData }

		for index: number = pageStart, math.min(pageStart + pageSize - 1, #rows) do
			table.insert(page, rows[index])
		end

		--[[ Returning ]]

		return page
	end

	--%%%%%%%%%%%%%%%%%%%% Advance To Next Page Async

	--[[
		Moves to the next page and updates `IsFinished`.
	]]
	function pages:AdvanceToNextPageAsync()
		--[[ Checks ]]

		-- Check if there is a page left
		if self.IsFinished then
			error("[MockDataStore::OrderedDataStore]: No more pages to advance to!", 2)
		end

		--[[ Advancing ]]

		pageStart += pageSize
		self.IsFinished = pageStart + pageSize - 1 >= #rows
	end

	--[[ Returning ]]

	return pages
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

--- @class MockDataStores_OrderedDataStore
local OrderedDataStore = {}
OrderedDataStore.__index = OrderedDataStore

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Creates an in-memory OrderedDataStore substitute.
]]
--- @return MockDataStores_OrderedDataStore
function OrderedDataStore.new()
	return setmetatable({ _entries = {} }, OrderedDataStore)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Async

--[[
	Stores a number under `key`.
]]
function OrderedDataStore:SetAsync(key: any, value: number)
	self._entries[tostring(key)] = value
end

--%%%%%%%%%%%%%%%%%%%% Update Async

--[[
	Passes the current number to `transform` and stores its result.
	Returning nil from `transform` cancels the update, like the real API.
]]
--- @return number?
function OrderedDataStore:UpdateAsync(key: any, transform: (oldValue: number?) -> number?)
	--[[ Local Variables ]]

	local keyString: string = tostring(key)
	local newValue: number? = transform(self._entries[keyString])

	--[[ Checks ]]

	-- Cancel the update when the transform returns nil
	if newValue == nil then
		return nil
	end

	--[[ Saving ]]

	self._entries[keyString] = newValue

	--[[ Returning ]]

	return newValue
end

--%%%%%%%%%%%%%%%%%%%% Increment Async

--[[
	Adds `delta` (default 1) to the number stored under `key` and returns the new value.
]]
--- @return number
function OrderedDataStore:IncrementAsync(key: any, delta: number?)
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
	Removes the number under `key` and returns it.
]]
--- @return number?
function OrderedDataStore:RemoveAsync(key: any)
	--[[ Local Variables ]]

	local keyString: string = tostring(key)
	local oldValue: number? = self._entries[keyString]

	--[[ Removing ]]

	self._entries[keyString] = nil

	--[[ Returning ]]

	return oldValue
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Async

--[[
	Returns the number stored under `key`.
]]
--- @return number?
function OrderedDataStore:GetAsync(key: any)
	return self._entries[tostring(key)]
end

--%%%%%%%%%%%%%%%%%%%% Get Sorted Async

--[[
	Returns pages of entries sorted by value (ties by key), optionally limited to [minValue, maxValue].
]]
--- @return MockDataStores_DataStorePages
function OrderedDataStore:GetSortedAsync(isAscending: boolean, pageSize: number, minValue: number?, maxValue: number?)
	--[[ Local Variables ]]

	local minFilter: number = minValue or -math.huge
	local maxFilter: number = maxValue or math.huge
	local rows = {} --- @type { MockDataStores_PageData }

	--[[ Filtering ]]

	for keyString: string, value: number in pairs(self._entries) do
		if value >= minFilter and value <= maxFilter then
			table.insert(rows, { key = keyString, value = value })
		end
	end

	--[[ Sorting ]]

	--- @param a MockDataStores_PageData
	--- @param b MockDataStores_PageData
	table.sort(rows, function(a, b)
		if a.value == b.value then
			return a.key < b.key
		end

		if isAscending then
			return a.value < b.value
		end

		return a.value > b.value
	end)

	--[[ Returning ]]

	return createPages(rows, math.max(math.floor(pageSize), 1))
end

return OrderedDataStore
