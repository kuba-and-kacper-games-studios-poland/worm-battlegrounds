--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions
local Registry = require(script.Parent:FindFirstChild("Registry")) --- @type AdminPanel_Dashboard_Server_Registry

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Move Character

--[[
	Moves one player's character to another's. Returns whether both had a character.
]]
--- @return boolean
local function moveCharacter(player: Player, toPlayer: Player)
	--[[ Local Variables ]]

	local character: Model? = player.Character
	local goal: Model? = toPlayer.Character

	--[[ Checks ]]

	-- Check if both characters exist
	if not character or not goal then
		return false
	end

	--[[ Moving ]]

	I.World.MoveModelToPosition(character, goal:GetPivot())

	--[[ Returning ]]

	return true
end

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

--- @class AdminPanel_Dashboard_Server_Defaults
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerPlayerPanel()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Player Panel

--[[
	Registers the sections every player's page starts with: who they are, and moving, respawning and kicking them.
]]
function Module._registerPlayerPanel()
	--%%%%%%%%%%%%%%%%%%%% Respawn

	--[[
		Loads the player's character again.
	]]
	--- @return boolean
	--- @return string
	local function respawn(_admin: Player, _values, target: Player)
		--[[ Respawning ]]

		target:LoadCharacter()

		--[[ Returning ]]

		return true, `Respawned {target.Name}`
	end

	--%%%%%%%%%%%%%%%%%%%% Kill

	--[[
		Takes all of the player's health.
	]]
	--- @return boolean
	--- @return string
	local function kill(_admin: Player, _values, target: Player)
		--[[ Local Variables ]]

		local humanoid: Humanoid? = if target.Character then target.Character:FindFirstChildOfClass("Humanoid") else nil

		--[[ Checks ]]

		-- Check if the player has a humanoid
		if not humanoid then
			return false, `{target.Name} has no character`
		end

		--[[ Killing ]]

		humanoid:TakeDamage(humanoid.Health)

		--[[ Returning ]]

		return true, `Killed {target.Name}`
	end

	--%%%%%%%%%%%%%%%%%%%% Bring

	--[[
		Moves the player to the admin.
	]]
	--- @return boolean
	--- @return string
	local function bring(admin: Player, _values, target: Player)
		--[[ Returning ]]

		if not moveCharacter(target, admin) then
			return false, `Couldn't bring {target.Name}`
		end

		return true, `Brought {target.Name}`
	end

	--%%%%%%%%%%%%%%%%%%%% Go To

	--[[
		Moves the admin to the player.
	]]
	--- @return boolean
	--- @return string
	local function goTo(admin: Player, _values, target: Player)
		--[[ Returning ]]

		if not moveCharacter(admin, target) then
			return false, `Couldn't go to {target.Name}`
		end

		return true, `Went to {target.Name}`
	end

	--%%%%%%%%%%%%%%%%%%%% Kick

	--[[
		Kicks the player with the reason typed in the section.
	]]
	--- @param values { [string]: any }
	--- @return boolean
	--- @return string
	local function kick(_admin: Player, values, target: Player)
		--[[ Local Variables ]]

		local reason: string = if type(values.Reason) == "string" and values.Reason ~= "" then values.Reason else "No reason given"

		--[[ Kicking ]]

		target:Kick(`You were kicked! Reason: {reason}`)

		--[[ Returning ]]

		return true, `Kicked {target.Name}: {reason}`
	end

	--%%%%%%%%%%%%%%%%%%%% Registering

	Registry.Register("AdminPanel_Player", {
		Name = "Player",
		Scope = "Player",
		Sections = {
			{
				Title = "Player",
				Blocks = {
					{
						Type = "Info",
						Id = "UserId",
						Text = "User id",
						Value = function(target: Player)
							return tostring(target.UserId)
						end,
					},
					{
						Type = "Info",
						Id = "AccountAge",
						Text = "Account age",
						Value = function(target: Player)
							return `{target.AccountAge} days`
						end,
					},
					{
						Type = "Info",
						Id = "Level",
						Text = "Admin level",
						Value = function(target: Player)
							return tostring(Permissions.GetPermissionLevel(target))
						end,
					},
				},
			},
			{
				Title = "Actions",
				Blocks = {
					{ Type = "Button", Id = "Respawn", Text = "Respawn", Callback = respawn },
					{ Type = "Button", Id = "Kill", Text = "Kill", Callback = kill },
					{ Type = "Button", Id = "Bring", Text = "Bring", Callback = bring },
					{ Type = "Button", Id = "GoTo", Text = "Go to", Callback = goTo },
				},
			},
			{
				Title = "Kick",
				Blocks = {
					{ Type = "Input", Id = "Reason", Text = "Reason", Placeholder = "Why they are kicked", Button = "Kick", Callback = kick },
				},
			},
		},
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
