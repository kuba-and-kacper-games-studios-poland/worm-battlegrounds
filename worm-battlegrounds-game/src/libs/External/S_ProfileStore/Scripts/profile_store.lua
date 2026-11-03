--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local constants --- @type ProfileStore_Constants
local Helpers --- @type ProfileStore_Helpers
local DataStore --- @type ProfileStore_DataStore
local Save --- @type ProfileStore_Save
local Profile --- @type Player_Profile
local VersionQuery --- @type ProfileStore_VersionQuery

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

--- @class ProfileStore_Methods
local _methods = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		constants = _shared.constants
		Helpers = _shared.Helpers
		DataStore = _shared.DataStore
		Save = _shared.Save
		Profile = _shared.Profile
		VersionQuery = _shared.VersionQuery
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Roblox Message Subscription

--[[
	Subscribes to MessagingService "PS_<unique_session_id>" to react to
	remote servers asking this one to end or auto-save the session.
	Throttled so bad actors can't spam work with messages.
	Retries SubscribeAsync with exponential backoff while the profile stays active.
]]
local function RobloxMessageSubscription(profile, unique_session_id)
	local last_roblox_message = 0
	local exp_backoff = 1
	local subscription

	--%%%%%%%%%%%%%%%%%%%% Local Functions

	--[[
		Handles a MessagingService payload for this session.
	]]
	local function on_message(message)
		--[[ Checks ]]

		-- Stale or invalid payload
		if type(message.Data) ~= "table" or message.Data.LoadCount ~= profile.SessionLoadCount then
			return
		end

		-- Throttle reactions to at most once every ~6s
		if os.clock() - last_roblox_message <= 6 then
			return
		end

		-- Profile inactive
		if profile:IsActive() ~= true then
			return
		end

		--[[ Applying ]]

		last_roblox_message = os.clock()
		if message.Data.EndSession == true then
			Save.SaveProfileAsync(profile, true, false, "External")
		else
			profile:Save()
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Subscribing

	while profile:IsActive() == true and shared.Module.IsClosing ~= true do
		local subscribe_ok: boolean, result: RBXScriptConnection = pcall(function()
			return MessagingService:SubscribeAsync("PS_" .. unique_session_id, on_message)
		end)
		if subscribe_ok == true then
			subscription = result
			break
		end

		warn(`💾 [{shared._localName}::{script.Name}]: MessagingService subscribe fail - {tostring(result)}`)
		task.wait(exp_backoff)
		exp_backoff = math.min(20, exp_backoff * 2)
	end

	--[[ Checks ]]

	-- Subscribe never succeeded
	if subscription == nil then
		return
	end

	--[[ Applying ]]

	if profile:IsActive() == true then
		profile.roblox_message_subscription = subscription
	else
		-- Profile went inactive while we yielded in SubscribeAsync
		subscription:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New

--[[
	**SERVER** |
	Creates a ProfileStore instance for the given DataStore name.
	Resolution of DataStoreState (Access / NoAccess / NoInternet) may
	happen after construction; public methods wait for it internally.
]]
function _methods.New(store_name, template)
	template = template or {}

	if type(store_name) ~= "string" then
		error(`[{shared._localName}::{script.Name}]: Invalid or missing "store_name"`)
	elseif string.len(store_name) == 0 then
		error(`[{shared._localName}::{script.Name}]: store_name cannot be an empty string`)
	elseif string.len(store_name) > 50 then
		error(`[{shared._localName}::{script.Name}]: store_name is too long`)
	end

	if type(template) ~= "table" then
		error(`[{shared._localName}::{script.Name}]: Invalid template argument`)
	end

	local Module = shared.Module

	--[[ Build self first so Mock can refer back to it. ]]
	local self
	self = setmetatable({
		Mock = {
			Name = store_name,

			-- Mock method wrappers set the MockFlag before forwarding to
			-- the real method. UpdateAsync consumes the flag and routes
			-- to UserMockStore instead of the live DataStore.
			StartSessionAsync = function(_, profile_key, params)
				state.MockFlag = true
				return self:StartSessionAsync(profile_key, params)
			end,
			MessageAsync = function(_, profile_key, message)
				state.MockFlag = true
				return self:MessageAsync(profile_key, message)
			end,
			GetAsync = function(_, profile_key, version)
				state.MockFlag = true
				return self:GetAsync(profile_key, version)
			end,
			VersionQuery = function(_, profile_key, sort_direction, min_date, max_date)
				state.MockFlag = true
				return self:VersionQuery(profile_key, sort_direction, min_date, max_date)
			end,
			RemoveAsync = function(_, profile_key)
				state.MockFlag = true
				return self:RemoveAsync(profile_key)
			end,
		},

		Name = store_name,

		template = template,
		data_store = nil,
		load_jobs = {},
		mock_load_jobs = {},
		is_ready = true,
	}, shared.ProfileStoreClass)

	-- v2 DataStore options (sort-key metadata, last-updated time, etc.)
	local options = Instance.new("DataStoreOptions")
	options:SetExperimentalFeatures({ v2 = true })

	if Module.DataStoreState == "NotReady" then
		-- Module hasn't resolved API access yet; bootstrap lazily.
		self.is_ready = false

		task.spawn(function()
			while Module.DataStoreState == "NotReady" do
				task.wait()
			end

			if Module.DataStoreState == "Access" then
				self.data_store = DataStoreService:GetDataStore(store_name, nil, options)
			end

			self.is_ready = true
		end)
	elseif Module.DataStoreState == "Access" then
		self.data_store = DataStoreService:GetDataStore(store_name, nil, options)
	end

	return self
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Session

--[[
	Loads a profile and takes session ownership.
	Handles session stealing, force-load conflicts, and shutdown / cancel.
]]
function _methods:StartSessionAsync(profile_key: string, params)
	local is_mock = Helpers.ReadMockFlag()

	if type(profile_key) ~= "string" then
		error(`[{shared._localName}::{script.Name}]: profile_key must be a string`)
	elseif string.len(profile_key) == 0 then
		error(`[{shared._localName}::{script.Name}]: Invalid profile_key`)
	elseif string.len(profile_key) > 50 then
		error(`[{shared._localName}::{script.Name}]: profile_key is too long`)
	end

	if params ~= nil and type(params) ~= "table" then
		error(`[{shared._localName}::{script.Name}]: Invalid params`)
	end
	params = params or {}

	local Module = shared.Module

	if Module.IsClosing == true then
		return nil
	end

	Helpers.WaitForStoreReady(self)

	local session_token = Helpers.SessionToken(self.Name, profile_key, is_mock)

	if state.ActiveSessionCheck[session_token] ~= nil then
		error(`[{shared._localName}::{script.Name}]: Profile (STORE:{self.Name}; KEY:{profile_key}) is already loaded in this session`)
	end

	state.ActiveProfileLoadJobs += 1

	local is_user_cancel = false
	local function cancel_condition()
		if is_user_cancel == false then
			if params.Cancel ~= nil then
				is_user_cancel = params.Cancel() == true
			end
			return is_user_cancel
		end
		return true
	end

	local user_steal = params.Steal == true

	-- Session conflict handling values:
	local force_load_steps = 0
	local request_force_load = true
	local steal_session = false

	local start = os.clock()
	local exp_backoff = 1

	while Module.IsClosing == false and cancel_condition() == false do
		--[[
			Special case: if StartSessionAsync is called for the same key
			again while an earlier call is still running, the later call
			"steals" the in-flight job. The earlier call will return nil.
			This keeps quick-rejoin scenarios efficient and predictable.
		]]

		state.LoadIndex += 1
		local load_id = state.LoadIndex
		local profile_load_jobs = is_mock == true and self.mock_load_jobs or self.load_jobs
		local profile_load_job = profile_load_jobs[profile_key] -- {load_id, {loaded_data, key_info} or nil}

		local loaded_data, key_info
		local unique_session_id = HttpService:GenerateGUID(false)

		if profile_load_job ~= nil then
			-- Steal the existing load job:
			profile_load_job[1] = load_id
			while profile_load_job[2] == nil do -- Wait for the in-flight UpdateAsync to finish
				task.wait()
			end
			if profile_load_job[1] == load_id then -- Still ours?
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				state.ActiveProfileLoadJobs -= 1
				return nil
			end
		else
			profile_load_job = { load_id, nil }
			profile_load_jobs[profile_key] = profile_load_job

			profile_load_job[2] = table.pack(DataStore.UpdateAsync(self, profile_key, {
				ExistingProfileHandle = function(latest_data)
					if Module.IsClosing == true or cancel_condition() == true then
						return
					end

					local active_session = latest_data.MetaData.ActiveSession
					local force_load_session = latest_data.MetaData.ForceLoadSession

					if active_session == nil then
						-- Free to take the session:
						latest_data.MetaData.ActiveSession = {
							shared.env.PlaceId,
							shared.env.JobId,
							unique_session_id,
						}
						latest_data.MetaData.ForceLoadSession = nil
					elseif type(active_session) == "table" then
						if Helpers.IsThisSession(active_session) == false then
							-- Session owned by another server - see if we can grab it
							local last_update = latest_data.MetaData.LastUpdate
							if last_update ~= nil then
								-- If no updates for ASSUME_DEAD seconds, assume crash
								if os.time() - last_update > constants.ASSUME_DEAD then
									latest_data.MetaData.ActiveSession = {
										shared.env.PlaceId,
										shared.env.JobId,
										unique_session_id,
									}
									latest_data.MetaData.ForceLoadSession = nil
									return
								end
							end
							if steal_session == true or user_steal == true then
								local force_load_interrupted = if force_load_session ~= nil then not Helpers.IsThisSession(force_load_session) else true
								if force_load_interrupted == false or user_steal == true then
									latest_data.MetaData.ActiveSession = {
										shared.env.PlaceId,
										shared.env.JobId,
										unique_session_id,
									}
									latest_data.MetaData.ForceLoadSession = nil
								end
							elseif request_force_load == true then
								-- Ask the remote server to release
								latest_data.MetaData.ForceLoadSession = {
									shared.env.PlaceId,
									shared.env.JobId,
								}
							end
						else
							-- The active session is ours already; clear any stale force-load request
							latest_data.MetaData.ForceLoadSession = nil
						end
					end
				end,
				MissingProfileHandle = function(latest_data)
					local is_cancel = Module.IsClosing == true or cancel_condition() == true

					latest_data.Data = Helpers.DeepCopyTable(self.template)
					latest_data.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = if is_cancel == false then { shared.env.PlaceId, shared.env.JobId, unique_session_id } else nil,
						ForceLoadSession = nil,
						MetaTags = {}, -- ProfileService backwards compat
					}
				end,
				EditProfile = function(latest_data)
					if Module.IsClosing == true or cancel_condition() == true then
						return
					end

					local active_session = latest_data.MetaData.ActiveSession
					if active_session ~= nil and Helpers.IsThisSession(active_session) == true then
						latest_data.MetaData.SessionLoadCount += 1
						latest_data.MetaData.LastUpdate = os.time()
					end
				end,
			}, is_mock))

			if profile_load_job[1] == load_id then -- Load job wasn't stolen
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				state.ActiveProfileLoadJobs -= 1
				return nil -- Load job stolen
			end
		end

		if loaded_data ~= nil and key_info ~= nil then
			local active_session = loaded_data.MetaData.ActiveSession
			if type(active_session) == "table" then
				if Helpers.IsThisSession(active_session) == true then
					-- Success - this session now owns the profile
					local profile = Profile.New(loaded_data, key_info, self, profile_key, is_mock, session_token)
					Save.AddProfileToAutoSave(profile)

					if is_mock ~= true and Module.DataStoreState == "Access" then
						-- Subscribe for remote session conflict signals
						task.spawn(RobloxMessageSubscription, profile, unique_session_id)
					end

					if Module.IsClosing == true or cancel_condition() == true then
						-- Shutdown hit while we were acquiring - release immediately
						Save.SaveProfileAsync(profile, true)
						profile = nil
					end

					state.ActiveProfileLoadJobs -= 1
					return profile
				else
					if Module.IsClosing == true or cancel_condition() == true then
						state.ActiveProfileLoadJobs -= 1
						return nil
					end

					-- Profile is taken by some other session:
					local force_load_session = loaded_data.MetaData.ForceLoadSession
					local force_load_interrupted = if force_load_session ~= nil then not Helpers.IsThisSession(force_load_session) else true

					if force_load_interrupted == false then
						if request_force_load == false then
							force_load_steps += 1
							if force_load_steps >= math.ceil(constants.SESSION_STEAL / constants.LOAD_REPEAT_PERIOD) then
								steal_session = true
							end
						end

						-- Ask the remote server to end its session:
						if type(active_session[3]) == "string" then
							local session_load_count = loaded_data.MetaData.SessionLoadCount or 0
							task.spawn(MessagingService.PublishAsync, MessagingService, "PS_" .. active_session[3], { LoadCount = session_load_count, EndSession = true })
						end

						-- Retry after a delay
						local wait_until = os.clock() + if request_force_load == true then constants.FIRST_LOAD_REPEAT else constants.LOAD_REPEAT_PERIOD
						repeat
							task.wait()
						until os.clock() >= wait_until or Module.IsClosing == true
					else
						-- Another session is already trying to load this profile - back off
						state.ActiveProfileLoadJobs -= 1
						return nil
					end

					-- Only request a force load once per session attempt
					request_force_load = false
				end
			else
				state.ActiveProfileLoadJobs -= 1
				return nil -- Likely shutting down
			end
		else
			-- DataStore call errored - consider timeout + backoff before retry
			local default_timeout = false
			if params.Cancel == nil then
				default_timeout = os.clock() - start >= constants.START_SESSION_TIMEOUT
			end

			if default_timeout == true or Module.IsClosing == true or cancel_condition() == true then
				state.ActiveProfileLoadJobs -= 1
				return nil
			end

			task.wait(exp_backoff)
			exp_backoff = math.min(20, exp_backoff * 2)
		end
	end

	state.ActiveProfileLoadJobs -= 1
	return nil -- Game is shutting down or request was cancelled
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Message Async

--[[
	Queues a global update on the target profile. If the profile is
	active on this server it's saved immediately; otherwise we publish a
	MessagingService hint so the owning server saves sooner.
]]
--- @return boolean
function _methods:MessageAsync(profile_key: string, message)
	local is_mock = Helpers.ReadMockFlag()

	if type(profile_key) ~= "string" then
		error(`[{shared._localName}::{script.Name}]: profile_key must be a string`)
	elseif string.len(profile_key) == 0 then
		error(`[{shared._localName}::{script.Name}]: Invalid profile_key`)
	elseif string.len(profile_key) > 50 then
		error(`[{shared._localName}::{script.Name}]: profile_key is too long`)
	end

	if type(message) ~= "table" then
		error(`[{shared._localName}::{script.Name}]: message must be a table`)
	end

	local Module = shared.Module

	if Module.IsClosing == true then
		return false
	end

	Helpers.WaitForStoreReady(self)

	local exp_backoff = 1

	while Module.IsClosing == false do
		local loaded_data = DataStore.UpdateAsync(self, profile_key, {
			ExistingProfileHandle = nil,
			MissingProfileHandle = nil,
			EditProfile = function(latest_data)
				local global_updates = latest_data.GlobalUpdates
				local update_list = global_updates[2]

				global_updates[1] += 1
				table.insert(update_list, { global_updates[1], message })

				-- Keep the queue bounded; drop the oldest entries first
				while #update_list > constants.MAX_MESSAGE_QUEUE do
					table.remove(update_list, 1)
				end
			end,
		}, is_mock)

		if loaded_data ~= nil then
			local session_token = Helpers.SessionToken(self.Name, profile_key, is_mock)
			local profile = state.ActiveSessionCheck[session_token]

			if profile ~= nil then
				-- Message targets a profile active on this server - save immediately
				profile:Save()
			else
				local meta_data = loaded_data.MetaData or {}
				local active_session = meta_data.ActiveSession
				local session_load_count = meta_data.SessionLoadCount or 0

				if type(active_session) == "table" and type(active_session[3]) == "string" then
					-- Nudge the remote server to auto-save + pick up the message sooner
					task.spawn(MessagingService.PublishAsync, MessagingService, "PS_" .. active_session[3], { LoadCount = session_load_count })
				end
			end

			return true
		else
			-- DataStore call errored - retry with exponential backoff
			task.wait(exp_backoff)
			exp_backoff = math.min(20, exp_backoff * 2)
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Async

--[[
	Read-only snapshot of a profile. Returned profiles are in view mode
	and cannot :Save() - only :SetAsync() (force-overwrite) is valid.
]]
function _methods:GetAsync(profile_key: string, version: string?)
	local is_mock = Helpers.ReadMockFlag()

	if type(profile_key) ~= "string" then
		error(`[{shared._localName}::{script.Name}]: profile_key must be a string`)
	elseif string.len(profile_key) == 0 then
		error(`[{shared._localName}::{script.Name}]: Invalid profile_key`)
	elseif string.len(profile_key) > 50 then
		error(`[{shared._localName}::{script.Name}]: profile_key is too long`)
	end

	local Module = shared.Module

	if Module.IsClosing == true then
		return nil
	end

	Helpers.WaitForStoreReady(self)

	-- Version-scoped reads require the real DataStore:
	if version ~= nil and (is_mock or Module.DataStoreState ~= "Access") then
		return nil
	end

	local exp_backoff = 1

	while Module.IsClosing == false do
		local loaded_data, key_info = DataStore.UpdateAsync(
			self,
			profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = function(latest_data)
					latest_data.Data = Helpers.DeepCopyTable(self.template)
					latest_data.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = nil,
						ForceLoadSession = nil,
						MetaTags = {},
					}
				end,
				EditProfile = nil,
			},
			is_mock,
			true, -- is_get_call
			version
		)

		if loaded_data ~= nil then
			if key_info == nil then
				return nil -- Successful read of an empty key
			end

			local profile = Profile.New(loaded_data, key_info, self, profile_key, is_mock)
			profile.view_mode = true
			return profile
		else
			task.wait(exp_backoff)
			exp_backoff = math.min(20, exp_backoff * 2)
		end
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove Async

--[[
	Deletes profile data permanently. Mock stores delete in-memory;
	live stores call DataStore:RemoveAsync.
]]
--- @return boolean
function _methods:RemoveAsync(profile_key: string)
	local is_mock = Helpers.ReadMockFlag()

	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error(`[{shared._localName}::{script.Name}]: Invalid profile_key`)
	end

	local Module = shared.Module

	if Module.IsClosing == true then
		return false
	end

	Helpers.WaitForStoreReady(self)

	local wipe_status = false
	local next_in_queue = DataStore.WaitInUpdateQueue(Helpers.SessionToken(self.Name, profile_key, is_mock))

	if is_mock == true then
		wipe_status = shared.Mock.RemoveAsync(state.UserMockStore, self.Name, profile_key)
		task.wait()
	elseif Module.DataStoreState ~= "Access" then
		wipe_status = shared.Mock.RemoveAsync(state.MockStore, self.Name, profile_key)
		task.wait()
	else
		wipe_status = pcall(function()
			self.data_store:RemoveAsync(profile_key)
		end)
	end

	next_in_queue()

	return wipe_status
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Version Query

--[[
	Returns a VersionQuery object that can iterate historic versions.
	Unsupported against mock stores; returns a query that yields no
	profiles and warns once in Studio.
]]
function _methods:VersionQuery(profile_key: string, sort_direction: Enum.SortDirection?, min_date, max_date)
	local is_mock = Helpers.ReadMockFlag()

	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error(`[{shared._localName}::{script.Name}]: Invalid profile_key`)
	end

	if sort_direction ~= nil and (typeof(sort_direction) ~= "EnumItem" or sort_direction.EnumType ~= Enum.SortDirection) then
		error(`[{shared._localName}::{script.Name}]: Invalid sort_direction ({tostring(sort_direction)})`)
	end

	if min_date ~= nil and typeof(min_date) ~= "DateTime" and typeof(min_date) ~= "number" then
		error(`[{shared._localName}::{script.Name}]: Invalid min_date ({tostring(min_date)})`)
	end

	if max_date ~= nil and typeof(max_date) ~= "DateTime" and typeof(max_date) ~= "number" then
		error(`[{shared._localName}::{script.Name}]: Invalid max_date ({tostring(max_date)})`)
	end

	min_date = typeof(min_date) == "DateTime" and min_date.UnixTimestampMillis or min_date
	max_date = typeof(max_date) == "DateTime" and max_date.UnixTimestampMillis or max_date

	return VersionQuery.New(self, profile_key, sort_direction, min_date, max_date, is_mock)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _methods
