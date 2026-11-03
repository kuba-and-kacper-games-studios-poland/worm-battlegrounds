--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local Helpers --- @type ProfileStore_Helpers
local Mock --- @type ProfileStore_Mock

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

--- @class ProfileStore_DataStore
local _dataStore = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		Helpers = _shared.Helpers
		Mock = _shared.Mock
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Update Queue

--[[
	Serializes concurrent updates for the same session token. Callers get
	a "next_in_queue" callback they must invoke when done; this keeps
	UpdateAsync calls from overlapping on the same DataStore key and
	avoids conflicting transforms.

	@return function next_in_queue
]]
function _dataStore.WaitInUpdateQueue(session_token)
	local queue = state.UpdateQueue[session_token]
	local is_first = queue == nil

	if is_first == true then
		queue = {}
		state.UpdateQueue[session_token] = queue
	end

	if is_first == false then
		table.insert(queue, coroutine.running())
		coroutine.yield()
	end

	return function()
		local next_co = table.remove(queue, 1)
		if next_co ~= nil then
			coroutine.resume(next_co)
		else
			state.UpdateQueue[session_token] = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Update Async

--[[
	Wraps DataStore:UpdateAsync / :GetAsync / :GetVersionAsync with:
		- serialization via WaitInUpdateQueue
		- profile-shape detection and the ExistingProfileHandle /
			MissingProfileHandle / EditProfile callbacks that other modules use
		- UTF-8 sanitisation of outgoing payloads
		- pcall safety + error reporting
		- transparent mock fallback when studio API access is off

	@return loaded_data, key_info
]]
function _dataStore.UpdateAsync(profile_store, profile_key, transform_params, is_user_mock, is_get_call, version)
	--[[ transform_params = {
			ExistingProfileHandle = function(latest_data),
			MissingProfileHandle  = function(latest_data),
			EditProfile           = function(latest_data),
	} ]]

	local loaded_data, key_info

	local next_in_queue = _dataStore.WaitInUpdateQueue(Helpers.SessionToken(profile_store.Name, profile_key, is_user_mock))

	local success = true
	local error_message

	success, error_message = pcall(function()
		local transform_function = function(latest_data)
			local missing_profile = false
			local overwritten = false
			local global_updates = { 0, {} }

			if latest_data == nil then
				missing_profile = true
			elseif type(latest_data) ~= "table" then
				missing_profile = true
				overwritten = true
			else
				if type(latest_data.Data) == "table" and type(latest_data.MetaData) == "table" and type(latest_data.GlobalUpdates) == "table" then
					-- Regular profile structure detected:
					latest_data.WasOverwritten = false -- Must be reset if set previously
					global_updates = latest_data.GlobalUpdates

					if transform_params.ExistingProfileHandle ~= nil then
						transform_params.ExistingProfileHandle(latest_data)
					end
				elseif latest_data.Data == nil and latest_data.MetaData == nil and type(latest_data.GlobalUpdates) == "table" then
					-- Partial profile (only GlobalUpdates) - treat as missing but keep queued updates
					latest_data.WasOverwritten = false
					global_updates = latest_data.GlobalUpdates or global_updates
					missing_profile = true
				else
					missing_profile = true
					overwritten = true
				end
			end

			-- Profile was not created or the row holds unrelated data:
			if missing_profile == true then
				latest_data = {
					-- Data = nil,
					-- MetaData = nil,
					GlobalUpdates = global_updates,
				}
				if transform_params.MissingProfileHandle ~= nil then
					transform_params.MissingProfileHandle(latest_data)
				end
			end

			-- Standard profile editing pass:
			if transform_params.EditProfile ~= nil then
				transform_params.EditProfile(latest_data)
			end

			-- Mark the row so the next write can silently replace it:
			if overwritten == true then
				latest_data.WasOverwritten = true
			end

			-- Enforce UTF-8 validity on anything that will hit the DataStore
			Helpers.CleanTable(latest_data)

			return latest_data, latest_data.UserIds, latest_data.RobloxMetaData
		end

		if is_user_mock == true then
			-- User-opted-in mock store (ProfileStore.Mock.*)
			loaded_data, key_info = Mock.UpdateAsync(state.UserMockStore, profile_store.Name, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		elseif shared.Module.DataStoreState ~= "Access" then
			-- Transparent fallback when studio API access is off / no internet
			loaded_data, key_info = Mock.UpdateAsync(state.MockStore, profile_store.Name, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		else
			if is_get_call == true then
				if version ~= nil then
					local version_success, version_error = pcall(function()
						loaded_data, key_info = profile_store.data_store:GetVersionAsync(profile_key, version)
					end)

					if version_success == false and type(version_error) == "string" and string.find(version_error, "not valid") ~= nil then
						warn(`💾 [{shared._localName}::{script.Name}]: Passed version argument is not valid; Traceback:\n` .. debug.traceback())
					end
				else
					loaded_data, key_info = profile_store.data_store:GetAsync(profile_key)
				end

				-- GetAsync has no built-in transform; apply ours manually:
				loaded_data = transform_function(loaded_data)
			else
				loaded_data, key_info = profile_store.data_store:UpdateAsync(profile_key, transform_function)
			end
		end
	end)

	next_in_queue()

	if success == true and type(loaded_data) == "table" then
		-- Surface detected overwrites to developers:
		if loaded_data.WasOverwritten == true and is_get_call ~= true then
			Helpers.RegisterOverwrite(profile_store.Name, profile_key)
		end
		return loaded_data, key_info
	else
		Helpers.RegisterError(error_message or "Undefined error", profile_store.Name, profile_key)
		return nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _dataStore
