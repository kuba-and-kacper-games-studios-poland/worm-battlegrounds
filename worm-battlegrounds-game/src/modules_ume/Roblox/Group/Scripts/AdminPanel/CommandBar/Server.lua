--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Group"

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

--- @class Group_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Group Functions

	local function getId(groupName: string)
		--[[ Checks ]]

		if not groupsList[groupName] then
			return false, `Invalid Group name: $|cr$|{groupName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number = I.G_Group.GetId(groupName)

		-- Returning
		if value then
			return true, `Group $|cr$|{groupName}#| Id is: $|cr$|{value}#|`
		else
			return false, `Failed to get Group $|cr$|{groupName}#| Id`
		end
	end

	local function getName(groupId: number)
		--[[ Checks ]]

		if groupId <= 0 then
			return false, `Group Id $|cr$|{groupId}#| cannot be equal to or less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.G_Group.GetName(groupId)

		-- Returning
		if value then
			return true, `Group $|cr$|{groupId}#| Name is: $|cr$|{value}#|`
		else
			return false, `Failed to get Group $|cr$|{groupId}#| Name`
		end
	end

	local function getInfo(groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local value: number = I.G_Group.GetInfo(groupName)

		-- Returning
		if value then
			return true, { `Retrieving Group {groupDisplayName} info...`, value, "_multilineOutput" }
		else
			return false, `Failed to retrieve Group {groupDisplayName} info`
		end
	end

	local function getAllies(groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local pages: StandardPages? = I.G_Group.GetAllies(groupName)
		if not pages then
			return false, `Failed to get allies for Group {groupDisplayName}`
		end

		local allies = {}
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				table.insert(allies, item)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
		end

		return true, { `Retrieving allies for Group {groupDisplayName}...`, allies, "_multilineOutput" }
	end

	local function getEnemies(groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local pages: StandardPages? = I.G_Group.GetEnemies(groupName)
		if not pages then
			return false, `Failed to get enemies for Group {groupDisplayName}`
		end

		local enemies = {}
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				table.insert(enemies, item)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
		end

		return true, { `Retrieving enemies for Group {groupDisplayName}...`, enemies, "_multilineOutput" }
	end

	--%%%%%%%%%%%%%%%%%%%% Player Functions

	local function promptJoin(player: Player, groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		I.Group.PromptJoin(player, groupName)

		return true, `Prompted $|cr$|Join#| for Group {groupDisplayName} for $|cr$|{player.Name}#|`
	end

	local function isMember(player: Player, groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Group.IsMember(player, groupName)

		-- Returning
		if value ~= nil then
			if value then
				return true, `$|cr$|{player.Name}#| $|cr$|is a member#| of Group {groupDisplayName}`
			else
				return true, `$|cr$|{player.Name}#| $|cr$|is not a member#| of Group {groupDisplayName}`
			end
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s membership status for Group {groupDisplayName}`
		end
	end

	local function getRole(player: Player, groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local value: string = I.Group.GetRole(player, groupName)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#|'s role in Group {groupDisplayName} is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s role in Group {groupDisplayName}`
		end
	end

	local function getRank(player: Player, groupName: string | number)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Data ]]

		-- Getting GroupId
		local groupId: number? = I.G_Group.GetId(groupName)
		if not groupId then
			return false, `Failed to resolve Group Id for $|cr$|{groupName}#|`
		end

		-- Creating display string
		local groupDisplayName: string = groupName ~= groupId and `$|cr$|{groupName}#|` or `$|cr$|{groupName}#| ($|cr$|{groupId}#|)`

		--[[ Executing ]]

		-- Getting value
		local value: number = I.Group.GetRank(player, groupName)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#|'s rank in Group {groupDisplayName} is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s rank in Group {groupDisplayName}`
		end
	end

	local function updateData(player: Player, groupName: string | number, useProxy: boolean?)
		--[[ Checks ]]

		if type(groupName) == "number" then
			if groupName <= 0 then
				return false, `Group Id $|cr$|{groupName}#| cannot be equal to or less than $|cr$|0#|`
			end
		else
			if not groupsList[groupName] then
				return false, `Invalid Group name: $|cr$|{groupName}#|`
			end
		end

		--[[ Executing ]]

		I.Group.UpdateData(player, groupName, useProxy)

		return true, `Updated Group $|cr$|{groupName}#| data for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		--[[ Group Functions ]]

		{
			Aliases = { "get_id" },
			Args = {
				{ name = "groupName", types = { "string" }, dict = "Group_GroupNames", requireDict = true },
			},
			Callback = getId,
		},
		{
			Aliases = { "get_name" },
			Args = {
				{ name = "groupId", types = { "number" }, dict = "Group_GroupIds", requireDict = false },
			},
			Callback = getName,
		},
		{
			Aliases = { "get_info" },
			Args = {
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = getInfo,
		},
		{
			Aliases = { "get_allies" },
			Args = {
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = getAllies,
		},
		{
			Aliases = { "get_enemies" },
			Args = {
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = getEnemies,
		},

		--[[ Player Functions ]]

		{
			Aliases = { "prompt_join" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = promptJoin,
		},

		{
			Aliases = { "is_member" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = isMember,
		},
		{
			Aliases = { "get_role" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = getRole,
		},
		{
			Aliases = { "get_rank" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
			},
			Callback = getRank,
		},
		{
			Aliases = { "update_data" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "groupName", types = { "string", "number" }, dict = "Group_GroupNames", requireDict = false },
				{ name = "useProxy", types = { "boolean" }, optional = true },
			},
			Callback = updateData,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Group_Server", {
		Aliases = { "group" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allGroupNames = {} --- @type { string }
	local allGroupIds = {} --- @type { number }

	for groupName: string, groupId: number in pairs(groupsList) do
		table.insert(allGroupNames, `{groupName}`)
		table.insert(allGroupIds, `{groupId}`)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Group_GroupNames`, allGroupNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Group_GroupIds`, allGroupIds, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
