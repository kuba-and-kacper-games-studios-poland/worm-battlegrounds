--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "PlayerCollision"

--- @type PlayerCollision_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local PhysicsService = I.S.PhysicsService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Dictionary ]]

local lastGroupNamesKey: string? = nil

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

--- @class PlayerCollision_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()

	I.DoEvery.Get(_settings.CMD_DICT_REFRESH_SEC):Connect(Module._registerCommandDictionaries)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function set(player: Player, collisionGroupName: string)
		--[[ Checks ]]

		if not PhysicsService:IsCollisionGroupRegistered(collisionGroupName) then
			return false, `CollisionGroup $|cr$|{collisionGroupName}#| is not registered`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.PlayerCollision.Set(player, collisionGroupName)

		-- Returning
		if value then
			return true, `Updated $|cr$|{player.Name}#|'s CollisionGroup to: $|cr$|{collisionGroupName}#|`
		else
			return false, `Failed to update $|cr$|{player.Name}#|'s CollisionGroup`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "set" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "collisionGroup", types = { "string" }, dict = "PlayerCollision_CollisionGroupNames", requireDict = true },
			},
			Callback = set,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("PlayerCollision_Server", {
		Aliases = { "player_collision" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
	Skips the refresh when the registered group names are the same as last time.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allCollisionGroupNames = {} --- @type { string }

	--- @param collisionGroupInfo { [string]: any }
	for _index: number, collisionGroupInfo in ipairs(PhysicsService:GetRegisteredCollisionGroups()) do
		table.insert(allCollisionGroupNames, collisionGroupInfo["name"])
	end

	--[[ Checks ]]

	local groupNamesKey: string = table.concat(allCollisionGroupNames, "\0")

	-- Skip the refresh when the group list didn't change
	if groupNamesKey == lastGroupNamesKey then
		return
	end

	--[[ Saving ]]

	lastGroupNamesKey = groupNamesKey

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`PlayerCollision_CollisionGroupNames`, allCollisionGroupNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
