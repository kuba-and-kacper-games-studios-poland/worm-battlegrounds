--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local Signal --- @type ProfileStore_Signal
local Helpers --- @type ProfileStore_Helpers
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

--- @class Player_Profile
local _profile = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		Signal = _shared.Signal
		Helpers = _shared.Helpers
		Save = _shared.Save
	end,
}
_profile.__index = _profile

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New

--[[
	Builds a Profile object from a raw DataStore read (loaded_data +
	key_info). ProfileStore.New's internal call sites handle active /
	view-mode / mock distinction via arguments.
]]
function _profile.New(raw_data, key_info, profile_store, key, is_mock, session_token)
	local data = raw_data.Data or {}
	local session = raw_data.MetaData and raw_data.MetaData.ActiveSession or nil

	local global_updates = raw_data.GlobalUpdates and raw_data.GlobalUpdates[2] or {}
	local received_global_updates = {}

	for _, update in ipairs(global_updates) do
		received_global_updates[update[1]] = true
	end

	local self = setmetatable({
		Data = data,
		LastSavedData = Helpers.DeepCopyTable(data),

		FirstSessionTime = raw_data.MetaData and raw_data.MetaData.ProfileCreateTime or 0,
		SessionLoadCount = raw_data.MetaData and raw_data.MetaData.SessionLoadCount or 0,
		Session = session and { PlaceId = session[1], JobId = session[2] },

		RobloxMetaData = raw_data.RobloxMetaData or {},
		UserIds = raw_data.UserIds or {},
		KeyInfo = key_info,

		OnAfterSave = Signal.New(),
		OnSave = Signal.New(),
		OnLastSave = Signal.New(),
		OnSessionEnd = Signal.New(),

		ProfileStore = profile_store,
		Key = key,

		-- Internal state:
		load_timestamp = os.clock(),
		is_mock = is_mock,
		session_token = session_token or "",
		load_index = raw_data.MetaData and raw_data.MetaData.SessionLoadCount or 0,
		locked_global_updates = {},
		received_global_updates = received_global_updates,
		message_handlers = {},
		global_updates = global_updates,
	}, _profile)

	return self
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IsActive

--[[
	True while this server still holds the session lock for the profile.
	Only valid synchronously - yielding invalidates the guarantee.
]]
--- @return boolean
function _profile:IsActive()
	return state.ActiveSessionCheck[self.session_token] == self
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reconcile

--[[
	Fills missing fields on Profile.Data from the ProfileStore template.
	Safe to call repeatedly; existing values are preserved.
]]
function _profile:Reconcile()
	Helpers.ReconcileTable(self.Data, self.ProfileStore.template)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Session

--[[
	Releases the session; subsequent :IsActive() returns false. Runs the
	save on a new thread so callers don't yield through a full DataStore
	round-trip unless they explicitly wait for OnSessionEnd.
]]
function _profile:EndSession()
	if self:IsActive() == true then
		task.spawn(Save.SaveProfileAsync, self, true, nil, "Manual")
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% User Ids

--[[
	Associates `user_id` with the profile (GDPR compliance).
]]
function _profile:AddUserId(user_id: number)
	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn(`💾 [{shared._localName}::{script.Name}]: Invalid UserId argument for :AddUserId() ({tostring(user_id)}); Traceback:\n` .. debug.traceback())
		return
	end

	-- Real Roblox DataStores reject negative UserIds. Mock/no-access
	-- stores allow them since they never cross the boundary.
	if user_id < 0 and self.is_mock ~= true and shared.Module.DataStoreState == "Access" then
		return
	end

	if table.find(self.UserIds, user_id) == nil then
		table.insert(self.UserIds, user_id)
	end
end

--[[
	Removes a `user_id` association (safe - no-op if not present).
]]
function _profile:RemoveUserId(user_id: number)
	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn(`💾 [{shared._localName}::{script.Name}]: Invalid UserId argument for :RemoveUserId() ({tostring(user_id)}); Traceback:\n` .. debug.traceback())
		return
	end

	local index = table.find(self.UserIds, user_id)
	if index ~= nil then
		table.remove(self.UserIds, index)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SetAsync

--[[
	Forcefully saves the profile. Only valid for view-mode profiles
	(returned by :GetAsync / :VersionQuery); live sessions must use :Save
	so session-lock invariants are respected.
]]
function _profile:SetAsync()
	if self.view_mode ~= true then
		error(`[{shared._localName}::{script.Name}]: :SetAsync() can only be used in view mode`)
	end

	Save.SaveProfileAsync(self, nil, true)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Message Handler

--[[
	Registers a function that handles incoming global updates (messages).
	Handlers are invoked in registration order; the first to call the
	"processed" callback locks the message so no later handlers see it.
]]
function _profile:MessageHandler(fn: (message: any, processed: () -> ()) -> ())
	if type(fn) ~= "function" then
		error(`[{shared._localName}::{script.Name}]: fn argument is not a function`)
	end

	-- Don't process messages if the profile session was ended
	if self.view_mode ~= true and self:IsActive() ~= true then
		return
	end

	local locked_updates = self.locked_global_updates
	table.insert(self.message_handlers, fn)

	-- Dispatch any cached updates to the new handler immediately:
	for _, update in ipairs(self.global_updates) do
		local index = update[1]
		local update_data = update[#update] -- ProfileService backwards compat

		if locked_updates[index] ~= true then
			local processed_callback = function()
				locked_updates[index] = true
			end

			local send_update_data = Helpers.DeepCopyTable(update_data)

			task.spawn(fn, send_update_data, processed_callback)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save

--[[
	Immediately saves an active profile. Also reschedules the next auto
	save so we don't double-save shortly after.
]]
function _profile:Save()
	if self.view_mode == true then
		error(`[{shared._localName}::{script.Name}]: Can't save profile in view mode; Should you be calling :SetAsync() instead?`)
	end

	if self:IsActive() == false then
		warn(`💾 [{shared._localName}::{script.Name}]: Attempted saving an inactive profile (STORE:{self.ProfileStore.Name}; KEY:{self.Key});` .. ` Traceback:\n` .. debug.traceback())
		return
	end

	-- Move the profile right behind the auto save index to delay the next auto save for it:
	Save.RemoveProfileFromAutoSave(self)
	Save.AddProfileToAutoSave(self)

	task.spawn(Save.SaveProfileAsync, self)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _profile
