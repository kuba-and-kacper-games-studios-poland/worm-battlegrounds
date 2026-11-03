--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Group"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local GroupService = I.S.GroupService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Group_Groups
local groupsList = require(I.Dirs.GlobalData.Group.Groups)

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Group = {

		--[[ Methods ]]

		GetId = Module.GetId,
		GetName = Module.GetName,
		GetInfo = Module.GetInfo,

		GetAllies = Module.GetAllies,
		GetEnemies = Module.GetEnemies,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Id

--[[
	Returns the id of a group listed in Groups.lua, or a group id passed as a positive whole number.
	Warns when the group is missing or not valid; there is no Default fallback.
]]
--- @return number?
function Module.GetId(groupName: string | number)
	--[[ Checks ]]

	-- Check if a group was passed
	if groupName == nil then
		warn(`[{_localName}::{script.Name}]: (groupName) is required!`)
		return nil
	end

	--[[ Finding ]]

	-- Return a number when it is a positive whole id
	if type(groupName) == "number" and groupName > 0 and string.match(tostring(groupName), "^%d+$") then
		return groupName
	end

	-- Return the id of a listed group
	if type(groupName) == "string" and groupsList[groupName] then
		return groupsList[groupName]
	end

	--[[ Returning ]]

	-- Warn when it is neither a listed name nor a valid id
	warn(`[{_localName}::{script.Name}]: ({groupName}) is not a valid (groupName)!`)
	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Name

--[[
	Returns name of the pre-defined group.
]]
--- @return string?
function Module.GetName(groupId: string | number)
	-- Returning if missing
	if not groupId then
		return nil
	end

	--[[ Finding ]]

	-- Returning matching group name/id
	for loopGroupName: string, loopGroupId: number in pairs(groupsList) do
		if loopGroupName == groupId or loopGroupId == groupId then
			return loopGroupName
		end
	end

	-- Not found
	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Info

--[[
	Returns group info using the Roblox API.
]]
--- @return Group_GroupInfo?
function Module.GetInfo(groupName: string | number)
	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Getting Info ]]

	local success: boolean
	local groupInfo --- @type Group_GroupInfo | string
	success, groupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, groupId)

	-- Check if the info was read
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to get info for Group ({groupName})! - {groupInfo}`)
		return nil
	end

	--[[ Returning ]]

	return groupInfo
end

--%%%%%%%%%%%%%%%%%%%% Get Allies

--[[
	Returns `StandardPages` of group allies.
]]
--- @return StandardPages?
function Module.GetAllies(groupName: string | number)
	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Getting Allies ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(GroupService.GetAlliesAsync, GroupService, groupId)

	-- Check if the pages were read
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to get (Allies) for Group ({groupName})! - {result}`)
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Get Enemies

--[[
	Returns `StandardPages` of group enemies.
]]
--- @return StandardPages?
function Module.GetEnemies(groupName: string | number)
	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Getting Enemies ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(GroupService.GetEnemiesAsync, GroupService, groupId)

	-- Check if the pages were read
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to get (Enemies) for Group ({groupName})! - {result}`)
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
