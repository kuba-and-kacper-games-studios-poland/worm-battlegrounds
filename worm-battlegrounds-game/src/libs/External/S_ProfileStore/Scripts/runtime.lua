--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--- @type Ume
local I

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local constants --- @type ProfileStore_Constants
local Save --- @type ProfileStore_Save

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

--- @class ProfileStore_Runtime
local _runtime = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		constants = _shared.constants
		Save = _shared.Save

		I = _shared.I
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% State Setter

--[[
	Atomically updates both internal and public DataStoreState fields.
]]
local function setDataStoreState(new_state: "NotReady" | "NoInternet" | "NoAccess" | "Access")
	shared.Module.DataStoreState = new_state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Studio Access Probe

--[[
	Detects whether this Studio session can reach live DataStores and
	whether API access is enabled. Result is cached on
	`ProfileStore.DataStoreState`.

	In live servers DataStore access is always available, so no probe is
	needed - we set state to "Access" synchronously.

	The probe is pcalled and produces exactly one warn / print based on
	the outcome, avoiding the 403 error spam the Roblox studio sometimes
	produces.
]]
function _runtime.StartStudioAccessCheck()
	--[[ Live Game: Access always available ]]

	if shared.env.IsStudio == false then
		setDataStoreState("Access")
		return
	end

	--[[ Studio: Check Access ]]

	task.spawn(function()
		local new_state = "NoAccess"

		-- Probe once. SetAsync writes a tiny timestamp; it's the cheapest
		-- way to distinguish "API disabled" (403) from "published game with
		-- API enabled" (success) from "no internet" (ConnectFail).
		local status, message = pcall(function()
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)

		local msg_str = type(message) == "string" and message or ""
		local no_internet_access = status == false and string.find(msg_str, "ConnectFail", 1, true) ~= nil

		if
			status == false
			and (
				string.find(msg_str, "403", 1, true) ~= nil -- API access disabled
				or string.find(msg_str, "must publish", 1, true) ~= nil -- Unpublished game
				or no_internet_access == true
			)
		then
			new_state = if no_internet_access == true then "NoInternet" else "NoAccess"
		elseif status == false then
			new_state = "NoAccess"
		else
			new_state = "Access"
		end

		setDataStoreState(new_state)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Heartbeat Loop

--[[
	Auto-save cursor advancement + critical state tracking.
	Runs on every Heartbeat. Cost is O(1) per frame except when a save
	fires (which goes to a new thread).
]]
function _runtime.StartHeartbeatLoop()
	RunService.Heartbeat:Connect(function()
		-- Auto-save:
		local auto_save_list_length = #state.AutoSaveList
		if auto_save_list_length > 0 then
			local auto_save_index_speed = constants.AUTO_SAVE_PERIOD / auto_save_list_length
			local os_clock = os.clock()

			while os_clock - state.LastAutoSave > auto_save_index_speed do
				state.LastAutoSave = state.LastAutoSave + auto_save_index_speed
				local profile = state.AutoSaveList[state.AutoSaveIndex]

				-- Skip profiles that were loaded very recently; finding a
				-- fresh one can loop around the ring once.
				if os_clock - profile.load_timestamp < constants.AUTO_SAVE_PERIOD / 2 then
					profile = nil
					for _ = 1, auto_save_list_length - 1 do
						state.AutoSaveIndex += 1
						if state.AutoSaveIndex > auto_save_list_length then
							state.AutoSaveIndex = 1
						end
						profile = state.AutoSaveList[state.AutoSaveIndex]
						if os_clock - profile.load_timestamp >= constants.AUTO_SAVE_PERIOD / 2 then
							break
						else
							profile = nil
						end
					end
				end

				-- Advance the cursor for next tick:
				state.AutoSaveIndex += 1
				if state.AutoSaveIndex > auto_save_list_length then
					state.AutoSaveIndex = 1
				end

				if profile ~= nil then
					task.spawn(Save.SaveProfileAsync, profile)
				end
			end
		end

		local Module = shared.Module

		-- Critical state detection:
		if Module.IsCriticalState == false then
			if #state.IssueQueue >= constants.CRITICAL_STATE_ERROR_COUNT then
				Module.IsCriticalState = true
				Module.OnCriticalToggle:Fire(true)
				state.CriticalStateStart = os.clock()
				warn(`💾 [{shared._localName}::{script.Name}]: Entered critical state`)
			end
		else
			if #state.IssueQueue >= constants.CRITICAL_STATE_ERROR_COUNT then
				-- Reset the expire timer while still in the error burst
				state.CriticalStateStart = os.clock()
			elseif os.clock() - state.CriticalStateStart > constants.CRITICAL_STATE_EXPIRE then
				Module.IsCriticalState = false
				Module.OnCriticalToggle:Fire(false)
				warn(`💾 [{shared._localName}::{script.Name}]: Critical state ended`)
			end
		end

		-- Expire stale issue entries from the queue:
		while true do
			local issue_time = state.IssueQueue[1]
			if issue_time == nil then
				break
			elseif os.clock() - issue_time > constants.CRITICAL_STATE_ERROR_EXPIRE then
				table.remove(state.IssueQueue, 1)
			else
				break
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Bind To Close

--[[
	Sets up game:BindToClose to release all active profiles gracefully.
	In mock mode (no real DataStore access) we return immediately so
	Studio simulations shut down quickly instead of waiting for saves.
]]
function _runtime.StartBindToClose()
	task.spawn(function()
		while shared.Module.DataStoreState == "NotReady" do
			task.wait()
		end

		local Module = shared.Module

		if Module.DataStoreState ~= "Access" then
			game:BindToClose(function()
				Module.IsClosing = true
				task.wait() -- Minimal yield for mock-mode shutdown
			end)
			return
		end

		game:BindToClose(function()
			Module.IsClosing = true

			--[[
				Release all active profiles. Clone the list first because
				SaveProfileAsync mutates AutoSaveList as it releases.
			]]
			local on_close_save_job_count = 0
			local active_profiles = {}

			-- selene: allow(manual_table_clone)
			for index, profile in ipairs(state.AutoSaveList) do
				active_profiles[index] = profile
			end

			for _, profile in ipairs(active_profiles) do
				-- Releasing one profile can end others via listeners,
				-- so always re-check active state before saving.
				if profile:IsActive() == true then
					on_close_save_job_count += 1
					task.spawn(function()
						Save.SaveProfileAsync(profile, true, nil, "Shutdown")
						on_close_save_job_count -= 1
					end)
				end
			end

			-- Yield until every pending save / load job is done
			while on_close_save_job_count > 0 or state.ActiveProfileLoadJobs > 0 or state.ActiveProfileSaveJobs > 0 do
				task.wait()
			end
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start All

--[[
	Convenience wrapper that spins up all runtime tasks in the right order.
]]
function _runtime.StartAll()
	_runtime.StartStudioAccessCheck()
	_runtime.StartHeartbeatLoop()
	_runtime.StartBindToClose()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _runtime
