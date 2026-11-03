--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local Helpers --- @type ProfileStore_Helpers
local DataStore --- @type ProfileStore_DataStore

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

--- @class ProfileStore_Save
local _save = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		Helpers = _shared.Helpers
		DataStore = _shared.DataStore
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Auto Save List

--[[
	Inserts the profile at the current auto-save cursor so the next
	scheduled save skips over it (giving freshly loaded profiles a full
	auto-save interval before their first save).
]]
function _save.AddProfileToAutoSave(profile)
	state.ActiveSessionCheck[profile.session_token] = profile

	table.insert(state.AutoSaveList, state.AutoSaveIndex, profile)

	if #state.AutoSaveList > 1 then
		state.AutoSaveIndex += 1
	elseif #state.AutoSaveList == 1 then
		-- Only profile in the list - reset the auto-save clock so we
		-- don't fire immediately on first add.
		state.LastAutoSave = os.clock()
	end
end

--[[
	Removes the profile from the auto-save list and the active session
	map. Adjusts the cursor to keep it pointing at the same entry.
]]
function _save.RemoveProfileFromAutoSave(profile)
	state.ActiveSessionCheck[profile.session_token] = nil

	local auto_save_index = table.find(state.AutoSaveList, profile)

	if auto_save_index ~= nil then
		table.remove(state.AutoSaveList, auto_save_index)

		-- Elements after a removed one shift left; mirror that on the
		-- cursor so the "next profile to save" is unchanged.
		if auto_save_index < state.AutoSaveIndex then
			state.AutoSaveIndex -= 1
		end
		if state.AutoSaveList[state.AutoSaveIndex] == nil then
			state.AutoSaveIndex = 1
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Profile

--[[
	Writes the profile's current data to the DataStore, applies received
	global updates, and (optionally) releases the session.

	Parameters:
	  profile          - Profile object
	  is_ending_session - true when this save should release the session
	  is_overwriting   - true for force-overwrite via :SetAsync
	  last_save_reason - "Manual" | "External" | "Shutdown"

	Repeats on error when ending a session (releasing a profile is not
	allowed to silently fail).
]]
function _save.SaveProfileAsync(profile, is_ending_session, is_overwriting, last_save_reason)
	if type(profile.Data) ~= "table" then
		error(`[{shared._localName}::{script.Name}]: Developer code likely set "Profile.Data" to a non-table value! ` .. `(STORE:{profile.ProfileStore.Name}; KEY:{profile.Key})`)
	end

	profile.OnSave:Fire()
	if is_ending_session == true then
		profile.OnLastSave:Fire(last_save_reason or "Manual")
	end

	if is_ending_session == true and is_overwriting ~= true then
		if profile.roblox_message_subscription ~= nil then
			profile.roblox_message_subscription:Disconnect()
		end
		_save.RemoveProfileFromAutoSave(profile)
		profile.OnSessionEnd:Fire()
	end

	state.ActiveProfileSaveJobs += 1

	-- Released (final) saves repeat forever until they succeeded; all other
	-- saves make a single attempt.
	local repeat_save_flag = true
	local exp_backoff = 1

	while repeat_save_flag == true do
		if is_ending_session ~= true then
			repeat_save_flag = false
		end

		local loaded_data, key_info = DataStore.UpdateAsync(profile.ProfileStore, profile.Key, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(latest_data)
				-- Confirm this session still owns the profile before editing:
				local session_owns_profile = false

				if is_overwriting ~= true then
					local active_session = latest_data.MetaData.ActiveSession
					local session_load_count = latest_data.MetaData.SessionLoadCount

					if type(active_session) == "table" then
						session_owns_profile = Helpers.IsThisSession(active_session) and session_load_count == profile.load_index
					end
				else
					-- :SetAsync forcefully claims ownership regardless of session state.
					session_owns_profile = true
				end

				if session_owns_profile == true then
					-- Clear processed (locked) global updates before writing:
					local locked_updates = profile.locked_global_updates
					local active_updates = latest_data.GlobalUpdates[2]
					-- ProfileService: {{update_id, version_id, update_locked, update_data}, ...}
					-- ProfileStore:   {{update_id, update_data}, ...}

					if next(locked_updates) ~= nil then
						local i = 1
						while i <= #active_updates do
							local update = active_updates[i]
							if locked_updates[update[1]] == true then
								table.remove(active_updates, i)
							else
								i += 1
							end
						end
					end

					-- Persist profile payload:
					latest_data.Data = profile.Data
					latest_data.RobloxMetaData = profile.RobloxMetaData
					latest_data.UserIds = profile.UserIds

					if is_overwriting ~= true then
						latest_data.MetaData.LastUpdate = os.time()

						if is_ending_session == true then
							latest_data.MetaData.ActiveSession = nil
						end
					else
						latest_data.MetaData.ActiveSession = nil
						latest_data.MetaData.ForceLoadSession = nil
					end
				end
			end,
		}, profile.is_mock)

		if loaded_data ~= nil and key_info ~= nil then
			if is_overwriting == true then
				-- :SetAsync never repeats - a single successful write is terminal.
				break
			end

			repeat_save_flag = false

			local active_session = loaded_data.MetaData.ActiveSession
			local session_load_count = loaded_data.MetaData.SessionLoadCount
			local session_owns_profile = false

			if type(active_session) == "table" then
				session_owns_profile = Helpers.IsThisSession(active_session) and session_load_count == profile.load_index
			end

			local force_load_session = loaded_data.MetaData.ForceLoadSession
			local force_load_pending = false
			if type(force_load_session) == "table" then
				force_load_pending = not Helpers.IsThisSession(force_load_session)
			end

			local is_active = profile:IsActive()

			-- Another server wants the session - release it cooperatively:
			if force_load_pending == true and session_owns_profile == true then
				if is_active == true then
					_save.SaveProfileAsync(profile, true, false, "External")
				end
				break
			end

			-- Reconcile locked / new global updates:
			local locked_updates = profile.locked_global_updates
			local received_updates = profile.received_global_updates
			local active_updates = loaded_data.GlobalUpdates[2]

			local new_updates = {}
			local still_pending = {}

			for _, update in ipairs(active_updates) do
				if locked_updates[update[1]] == true then
					still_pending[update[1]] = true
				elseif received_updates[update[1]] ~= true then
					received_updates[update[1]] = true
					table.insert(new_updates, update)
				end
			end

			-- Drop locks that the server successfully cleared from the store:
			for index in pairs(locked_updates) do
				if still_pending[index] ~= true then
					locked_updates[index] = nil
				end
			end

			profile.KeyInfo = key_info
			profile.LastSavedData = loaded_data.Data
			profile.global_updates = loaded_data.GlobalUpdates and loaded_data.GlobalUpdates[2] or {}

			if session_owns_profile == true then
				if is_active == true and is_ending_session ~= true then
					-- Dispatch unseen global updates to registered message handlers:
					for _, update in ipairs(new_updates) do
						local index = update[1]
						local update_data = update[#update] -- Backwards compatibility w/ ProfileService

						for _, handler in ipairs(profile.message_handlers) do
							local is_processed = false
							local processed_callback = function()
								is_processed = true
								locked_updates[index] = true
							end

							local send_update_data = Helpers.DeepCopyTable(update_data)

							task.spawn(handler, send_update_data, processed_callback)

							if is_processed == true then
								break
							end
						end
					end
				end
			else
				-- Lost ownership between start and save - clean up locally:
				if profile.roblox_message_subscription ~= nil then
					profile.roblox_message_subscription:Disconnect()
				end

				if is_active == true then
					_save.RemoveProfileFromAutoSave(profile)
					profile.OnSessionEnd:Fire()
				end
			end

			profile.OnAfterSave:Fire(profile.LastSavedData)
		elseif repeat_save_flag == true then
			-- Likely a DataStore error - exponential backoff and retry:
			task.wait(exp_backoff)
			exp_backoff = math.min(if last_save_reason == "Shutdown" then 8 else 20, exp_backoff * 2)
		end
	end

	state.ActiveProfileSaveJobs -= 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _save
