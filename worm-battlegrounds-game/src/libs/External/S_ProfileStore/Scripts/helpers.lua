--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared
local state --- @type ProfileStore_State
local env --- @type ProfileStore_Env

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

--- @class ProfileStore_Helpers
local _helpers = {
	Init = function(_shared)
		shared = _shared
		state = _shared.state
		env = _shared.env
	end,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Deep Copy

--[[
	Recursively copies every key/value pair of the given table.
	Non-table values are copied by value. Metatables are intentionally dropped.
]]
--- @return table
function _helpers.DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = _helpers.DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reconcile

--[[
	Fills missing string-keyed fields on `target` from `template` without
	overwriting existing values. Nested tables recurse; numeric keys are ignored.
]]
function _helpers.ReconcileTable(target, template)
	for k, v in pairs(template) do
		if type(k) == "string" then
			if target[k] == nil then
				if type(v) == "table" then
					target[k] = _helpers.DeepCopyTable(v)
				else
					target[k] = v
				end
			elseif type(target[k]) == "table" and type(v) == "table" then
				_helpers.ReconcileTable(target[k], v)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Session Helpers

--[[
	Checks whether the given session tag refers to this running Roblox server.
]]
--- @return boolean
function _helpers.IsThisSession(session_tag)
	return session_tag[1] == env.PlaceId and session_tag[2] == env.JobId
end

--[[
	Builds a unique token used as a key for update queues and session maps.
	Prefix reflects the store "mode" at the time of the call so real and
	mock stores never share a queue.
]]
--- @return string
function _helpers.SessionToken(store_name, profile_key, is_user_mock)
	local prefix = "L_" -- Live

	if is_user_mock == true then
		prefix = "U_" -- User-requested mock (ProfileStore.Mock)
	elseif shared.Module.DataStoreState ~= "Access" then
		prefix = "M_" -- Fallback mock (no DataStore access)
	end

	return prefix .. store_name .. "\0" .. profile_key
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Mock Flag

--[[
	Atomically consumes the "next call should run on the mock store" flag.
	ProfileStore.Mock.* methods set this before delegating to the real
	method; each consumer of the flag reads it exactly once.
]]
--- @return boolean
function _helpers.ReadMockFlag()
	local is_mock = state.MockFlag
	state.MockFlag = false
	return is_mock
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Store Ready

--[[
	Blocks until the given ProfileStore instance has finished its deferred
	bootstrap (DataStore access probe + object creation).
]]
function _helpers.WaitForStoreReady(profile_store)
	while profile_store.is_ready == false do
		task.wait()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTF-8 Sanitization

--[[
	Strips invalid UTF-8 byte sequences from a string so the result is
	always valid UTF-8 and safe to pass to DataStoreService (which rejects
	otherwise-valid-looking payloads with invalid codepoints).
]]
--- @return string
function _helpers.CleanUtf8String(str)
	local result = {}
	local i = 1

	while i <= #str do
		local c = string.byte(str, i)

		if c >= 0x00 and c <= 0x7F then
			-- 1-byte ASCII
			table.insert(result, string.char(c))
			i += 1
		elseif c >= 0xC2 and c <= 0xDF then
			-- 2-byte sequence
			local b2 = string.byte(str, i + 1)
			if b2 and b2 >= 0x80 and b2 <= 0xBF then
				table.insert(result, str:sub(i, i + 1))
				i += 2
			else
				i += 1
			end
		elseif c == 0xE0 then
			-- 3-byte sequence with restricted second byte
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			if b2 and b3 and b2 >= 0xA0 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF then
				table.insert(result, str:sub(i, i + 2))
				i += 3
			else
				i += 1
			end
		elseif (c >= 0xE1 and c <= 0xEC) or (c >= 0xEE and c <= 0xEF) then
			-- 3-byte sequence
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			if b2 and b3 and b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF then
				table.insert(result, str:sub(i, i + 2))
				i += 3
			else
				i += 1
			end
		elseif c == 0xED then
			-- 3-byte sequence excluding surrogate halves
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			if b2 and b3 and b2 >= 0x80 and b2 <= 0x9F and b3 >= 0x80 and b3 <= 0xBF then
				table.insert(result, str:sub(i, i + 2))
				i += 3
			else
				i += 1
			end
		elseif c == 0xF0 then
			-- 4-byte sequence with restricted second byte
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			local b4 = string.byte(str, i + 3)
			if b2 and b3 and b4 and b2 >= 0x90 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF and b4 >= 0x80 and b4 <= 0xBF then
				table.insert(result, str:sub(i, i + 3))
				i += 4
			else
				i += 1
			end
		elseif c >= 0xF1 and c <= 0xF3 then
			-- 4-byte sequence
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			local b4 = string.byte(str, i + 3)
			if b2 and b3 and b4 and b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF and b4 >= 0x80 and b4 <= 0xBF then
				table.insert(result, str:sub(i, i + 3))
				i += 4
			else
				i += 1
			end
		elseif c == 0xF4 then
			-- 4-byte sequence with restricted second byte (plane 16 cap)
			local b2 = string.byte(str, i + 1)
			local b3 = string.byte(str, i + 2)
			local b4 = string.byte(str, i + 3)
			if b2 and b3 and b4 and b2 >= 0x80 and b2 <= 0x8F and b3 >= 0x80 and b3 <= 0xBF and b4 >= 0x80 and b4 <= 0xBF then
				table.insert(result, str:sub(i, i + 3))
				i += 4
			else
				i += 1
			end
		else
			-- Continuation byte / illegal lead - skip one byte
			i += 1
		end
	end

	return table.concat(result)
end

--[[
	Recursively sanitises every string value and string key in the given
	table. Cycles are skipped to avoid stack overflows on self-referential
	profile data.
]]
local function cleanTableInternal(t, visited)
	if type(t) ~= "table" or visited[t] ~= nil then
		return
	end
	visited[t] = true

	for key, value in pairs(t) do
		-- Sanitise string keys; if the key changed we must rewrite it on
		-- the table (can't mutate keys in place in Lua).
		local cleaned_key = (type(key) == "string") and _helpers.CleanUtf8String(key) or key

		if type(value) == "table" then
			cleanTableInternal(value, visited)
		elseif type(value) == "string" then
			value = _helpers.CleanUtf8String(value)
		end

		if key ~= cleaned_key then
			t[key] = nil
		end
		t[cleaned_key] = value
	end
end

--[[
	Recursively sanitises every string value and string key in the given
	table. Cycles are skipped to avoid stack overflows on self-referential
	profile data.
]]
function _helpers.CleanTable(t)
	cleanTableInternal(t, {})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Error Reporting

--[[
	Records a DataStore API error: logs a warning, pushes the timestamp
	to the issue queue (used for critical state detection) and fires the
	public OnError signal.
]]
function _helpers.RegisterError(error_message, store_name, profile_key)
	warn(`💾 [{shared._localName}::{script.Name}]: DataStore API error (STORE:{store_name}; KEY:{profile_key}) - {tostring(error_message)}`)
	table.insert(state.IssueQueue, os.clock())
	shared.Module.OnError:Fire(tostring(error_message), store_name, profile_key)
end

--[[
	Fired when a DataStore key held data that wasn't a ProfileStore
	profile (or was manually corrupted). ProfileStore will overwrite it
	on the next save; notify observers so they can audit/alert.
]]
function _helpers.RegisterOverwrite(store_name, profile_key)
	warn(`💾 [{shared._localName}::{script.Name}]: Invalid profile was overwritten (STORE:{store_name}; KEY:{profile_key})`)
	shared.Module.OnOverwrite:Fire(store_name, profile_key)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return _helpers
