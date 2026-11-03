--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari.
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local Helpers --- @type ProfileStore_Helpers

-- Re-entrance bookkeeping; VersionQueryNextAsync may call itself.
local VersionQueryNextAsyncStackingFlag = false
local WarnAboutVersionQueryOnce = false

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

--- @class ProfileStore_VersionQuery
local _versionQuery = {
	Init = function(_shared)
		shared = _shared
		Helpers = _shared.Helpers
	end,
}
_versionQuery.__index = _versionQuery

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New

--[[
	Builds a query object. Actual DataStore calls are deferred to the
	first :NextAsync() so constructing a query is cheap.
]]
function _versionQuery.New(profile_store, profile_key, sort_direction, min_date, max_date, is_mock)
	return setmetatable({
		profile_store = profile_store,
		profile_key = profile_key,
		sort_direction = sort_direction,
		min_date = min_date,
		max_date = max_date,

		query_pages = nil,
		query_index = 0,
		query_failure = false,

		is_query_yielded = false,
		query_queue = {},

		is_mock = is_mock,
	}, _versionQuery)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Queue Helpers

--[[
	Drains the queue of pending :NextAsync calls. Stops as soon as a
	queued call yields on a DataStore operation so its result is preserved.
]]
local function MoveVersionQueryQueue(self)
	while #self.query_queue > 0 do
		local queue_entry = table.remove(self.query_queue, 1)
		task.spawn(queue_entry)

		if self.is_query_yielded == true then
			break
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Next Async

--[[
	Advances the query and returns the next historic profile (or nil).
	Yields while waiting on DataStore calls. Multiple concurrent callers
	are serialised via the internal query queue.
]]
function _versionQuery:NextAsync()
	local is_stacking = VersionQueryNextAsyncStackingFlag == true
	VersionQueryNextAsyncStackingFlag = false

	Helpers.WaitForStoreReady(self.profile_store)

	if shared.Module.IsClosing == true then
		return nil -- Silently fail during shutdown
	end

	-- Version queries don't make sense against mock stores:
	if self.is_mock == true or shared.Module.DataStoreState ~= "Access" then
		if shared.env.IsStudio == true and WarnAboutVersionQueryOnce == false then
			WarnAboutVersionQueryOnce = true
			warn(`💾 [{shared._localName}::{script.Name}]: :VersionQuery() is not supported in mock mode!`)
		end
		return nil
	end

	local profile
	local is_finished = false

	local function query_job()
		if self.query_failure == true then
			is_finished = true
			return
		end

		-- First call: load the first page of versions.
		if self.query_pages == nil then
			self.is_query_yielded = true

			task.spawn(function()
				VersionQueryNextAsyncStackingFlag = true
				profile = self:NextAsync()
				is_finished = true
			end)

			local list_success, error_message = pcall(function()
				self.query_pages = self.profile_store.data_store:ListVersionsAsync(self.profile_key, self.sort_direction, self.min_date, self.max_date)
				self.query_index = 0
			end)

			if list_success == false or self.query_pages == nil then
				warn(`💾 [{shared._localName}::{script.Name}]: Version query fail - {tostring(error_message)}`)
				self.query_failure = true
			end

			self.is_query_yielded = false
			MoveVersionQueryQueue(self)
			return
		end

		local current_page = self.query_pages:GetCurrentPage()
		local next_item = current_page[self.query_index + 1]

		-- Exhausted all pages:
		if self.query_pages.IsFinished == true and next_item == nil then
			is_finished = true
			return
		end

		-- Current page is done, load next page:
		if next_item == nil then
			self.is_query_yielded = true
			task.spawn(function()
				VersionQueryNextAsyncStackingFlag = true
				profile = self:NextAsync()
				is_finished = true
			end)

			local success = pcall(function()
				self.query_pages:AdvanceToNextPageAsync()
				self.query_index = 0
			end)

			if success == false or #self.query_pages:GetCurrentPage() == 0 then
				self.query_failure = true
			end

			self.is_query_yielded = false
			MoveVersionQueryQueue(self)
			return
		end

		-- Valid next version on the current page:
		self.query_index += 1
		profile = self.profile_store:GetAsync(self.profile_key, next_item.Version)
		is_finished = true
	end

	if self.is_query_yielded == false then
		query_job()
	else
		-- Stacking reinvocations from inside query_job should run before
		-- any newly submitted external calls:
		if is_stacking == true then
			table.insert(self.query_queue, 1, query_job)
		else
			table.insert(self.query_queue, query_job)
		end
	end

	while is_finished == false do
		task.wait()
	end

	return profile
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _versionQuery
