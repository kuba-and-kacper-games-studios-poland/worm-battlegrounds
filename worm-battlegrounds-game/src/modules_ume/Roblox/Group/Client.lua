--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Group"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local GroupService = I.S.GroupService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local groupRep: Folder

--[[ Prompt ]]

local isGroupJoinPromptShown: boolean = false

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
	------ INITIALIZATION ------
	----------------------------

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Group_PromptJoin", { "number" })
	I.Network.Fired("Group_PromptJoin", Module.PromptJoin)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Group = {

		--[[ Control ]]

		PromptJoin = Module.PromptJoin,

		--[[ Methods ]]

		IsMember = Module.IsMember,
		GetRole = Module.GetRole,
		GetRank = Module.GetRank,
		GetChangedSignal = Module.GetChangedSignal,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Looks up the Group replicator folder and saves it.
]]
function Module._connectReplicator()
	groupRep = I.Replicator.GetFolder(_localName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Join

--[[
	Opens the join prompt for a group, then asks the server to refresh the player's data when they joined.
]]
--- @return Enum.GroupMembershipStatus?
function Module.PromptJoin(groupName: string | number)
	--[[ Checks ]]

	-- Check if a join prompt is already open
	if isGroupJoinPromptShown then
		return nil
	end

	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Membership Checks ]]

	local isMemberSuccess: boolean
	local isMember: any | string?
	isMemberSuccess, isMember = pcall(I.Env.LocalPlayer.IsInGroupAsync, I.Env.LocalPlayer, groupId)

	-- Check if the membership status was read
	if not isMemberSuccess then
		warn(`[{_localName}::{script.Name}]: Failed to get Membership Status for Group ({groupName})! - {isMember}`)
		return nil
	end

	-- Check if the player is already a group member
	if isMember then
		return Enum.GroupMembershipStatus.AlreadyMember
	end

	--[[ Prompting Join ]]

	isGroupJoinPromptShown = true

	local success: boolean
	local result: any | string?
	success, result = pcall(GroupService.PromptJoinAsync, GroupService, groupId)

	isGroupJoinPromptShown = false

	-- Check if the prompt opened
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to prompt Join for Group ({groupName})! - {result}`)
		return nil
	end

	--[[ Updating ]]

	-- Ask the server to refresh the data when the player joined
	if result == Enum.GroupMembershipStatus.Joined then
		I.Network.Fire("Group_RequestUpdateData", groupName)
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Member

--[[
	Returns if the local player is in the group, from the replicated group data.
]]
--- @return boolean?
function Module.IsMember(groupName: string | number)
	return Module._getCertainData("IsMember", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Role

--[[
	Returns the name of the local player's role in the group, from the replicated group data.
]]
--- @return string?
function Module.GetRole(groupName: string | number)
	return Module._getCertainData("Role", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Rank

--[[
	Returns the local player's rank in the group, from the replicated group data.
]]
--- @return number?
function Module.GetRank(groupName: string | number)
	return Module._getCertainData("Rank", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Changed Signal

--[[
	**CLIENT** |
	Returns a signal that fires when the local player's rank in the group changes (joining, leaving, a new role).
]]
--- @return RBXScriptSignal?
function Module.GetChangedSignal(groupName: string | number)
	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Returning ]]

	return groupRep:GetAttributeChangedSignal(`{groupId}_Rank`)
end

--%%%%%%%%%%%%%%%%%%%% Get Certain Data

--[[
	Returns one replicated value of the local player's group data, read from the attributes the server sets under the group id.
]]
--- @return string | number | boolean | nil
function Module._getCertainData(dataName: string, groupName: string | number)
	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Returning ]]

	return groupRep:GetAttribute(`{groupId}_{dataName}`)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
