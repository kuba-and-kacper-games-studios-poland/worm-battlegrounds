--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local Helpers --- @type ProfileStore_Helpers

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

--- @class ProfileStore_Mock
local _mock = {
	Init = function(_shared)
		Helpers = _shared.Helpers
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Key Info

--[[
	Produces a DataStoreKeyInfo-like table for mock entries. The version
	string mimics the shape of a real DataStore version identifier so code
	depending on that format keeps working in mock mode.
]]
function _mock.NewKeyInfo(params)
	local version_id_string = tostring(params.VersionId or 0)
	local meta_data = params.MetaData or {}
	local user_ids = params.UserIds or {}

	return {
		CreatedTime = params.CreatedTime,
		UpdatedTime = params.UpdatedTime,
		Version = string.rep("0", 16) .. "." .. string.rep("0", 10 - string.len(version_id_string)) .. version_id_string .. "." .. string.rep("0", 16) .. "." .. "01",

		GetMetadata = function()
			return Helpers.DeepCopyTable(meta_data)
		end,

		GetUserIds = function()
			return Helpers.DeepCopyTable(user_ids)
		end,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Update

--[[
	Mirrors DataStore:UpdateAsync / GetAsync behaviour against an in-memory
	backing table. Mock entries are created lazily on write; reads against
	unknown keys return nil without creating an entry.

	@return loaded_data, key_info
]]
function _mock.UpdateAsync(mock_data_store, profile_store_name, key, transform_function, is_get_call)
	local profile_store = mock_data_store[profile_store_name]

	if profile_store == nil then
		profile_store = {}
		mock_data_store[profile_store_name] = profile_store
	end

	local epoch_time = math.floor(os.time() * 1000)
	local mock_entry = profile_store[key]
	local mock_entry_was_nil = false

	if mock_entry == nil then
		mock_entry_was_nil = true

		-- Non-get calls implicitly "create" an empty row so the transform
		-- function can populate it. Pure reads never mutate the store.
		if is_get_call ~= true then
			mock_entry = {
				Data = nil,
				CreatedTime = epoch_time,
				UpdatedTime = epoch_time,
				VersionId = 0,
				UserIds = {},
				MetaData = {},
			}
			profile_store[key] = mock_entry
		end
	end

	local mock_key_info = mock_entry_was_nil == false and _mock.NewKeyInfo(mock_entry) or nil

	local transform, user_ids, roblox_meta_data = transform_function(mock_entry and mock_entry.Data, mock_key_info)

	-- Transform returned nil => Roblox semantics for "do not save"
	if transform == nil then
		return nil
	end

	if mock_entry ~= nil and is_get_call ~= true then
		mock_entry.Data = Helpers.DeepCopyTable(transform)
		mock_entry.UserIds = Helpers.DeepCopyTable(user_ids or {})
		mock_entry.MetaData = Helpers.DeepCopyTable(roblox_meta_data or {})
		mock_entry.VersionId += 1
		mock_entry.UpdatedTime = epoch_time
	end

	return Helpers.DeepCopyTable(transform), mock_entry ~= nil and _mock.NewKeyInfo(mock_entry) or nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove

--[[
	Removes a key from the mock store. Cleans up the empty store entry if
	it held the last key so :Test() reports a clean state.
]]
--- @return boolean
function _mock.RemoveAsync(mock_data_store, profile_store_name, key)
	local store = mock_data_store[profile_store_name]

	if store ~= nil then
		store[key] = nil
		if next(store) == nil then
			mock_data_store[profile_store_name] = nil
		end
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _mock
