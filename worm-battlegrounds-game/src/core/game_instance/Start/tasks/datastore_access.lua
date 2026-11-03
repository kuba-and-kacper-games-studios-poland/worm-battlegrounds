--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_DatastoreAccess
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check Access

--[[
	Checks if the DataStore is accessible.
]]
function _task.CheckAccess(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	local new_state = "NoAccess"

	if not I.Env.IsStudio then
		new_state = "Access"
	else
		--[[ Checking Access ]]

		local status: boolean, message: string? = pcall(function()
			return I.S.DataStoreService:GetDataStore("____UME"):SetAsync("____UME", os.time())
		end)

		--[[ Updating State ]]

		local msg_str: string? = type(message) == "string" and message or ""
		local no_internet_access: boolean = status == false and string.find(msg_str, "ConnectFail", 1, true) ~= nil

		if status == false and (string.find(msg_str, "403", 1, true) ~= nil or string.find(msg_str, "must publish", 1, true) ~= nil or no_internet_access == true) then
			new_state = if no_internet_access == true then "NoInternet" else "NoAccess"
		elseif status == false then
			new_state = "NoAccess"
		else
			new_state = "Access"
		end

		--[[ Result Message ]]

		if new_state == "Access" then
			print(`💾 DataStore access is available - data will be saved`)
		elseif new_state == "NoAccess" then
			warn(`💾 Studio Access to API Services is disabled - data will NOT be saved`)
		elseif new_state == "NoInternet" then
			warn(`💾 No internet access detected - data will NOT be saved`)
		else
			warn(`💾 DataStore access is not available - data will NOT be saved`)
		end
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- **SERVER** | Indicates if the DataStores are accessible.
	--- @type boolean
	I.DataStoreAccess = new_state == "Access"

	-- **SERVER** | Indicates the type of DataStore access.
	--- @type "Access" | "NoAccess" | "NoInternet"
	I.DataStoreAccessType = new_state
end

return _task
