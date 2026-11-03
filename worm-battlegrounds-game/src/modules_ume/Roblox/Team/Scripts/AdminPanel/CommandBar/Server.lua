--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Team"

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

--- @class Team_CommandBar_Server
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
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function create(teamName: string, teamColor: Color3, autoAssignable: boolean?)
		--[[ Checks ]]

		if I.Team._createdTeams[teamName] then
			return false, `Team $|cr$|{teamName}#| already exists`
		end

		--[[ Executing ]]

		-- Getting value
		local value: Team = I.Team.Create(teamName, teamColor, autoAssignable)

		-- Returning
		if value then
			return true, `Created Team $|cr$|{teamName}#|`
		else
			return false, `Failed to create Team $|cr$|{teamName}#|`
		end
	end

	local function remove(teamName: string)
		--[[ Checks ]]

		if not I.Team._createdTeams[teamName] then
			return false, `Team $|cr$|{teamName}#| does not exist`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Team.Remove(teamName)

		-- Returning
		if value then
			return true, `Removed Team $|cr$|{teamName}#|`
		else
			return false, `Failed to remove Team $|cr$|{teamName}#|`
		end
	end

	local function assign(player: Player, teamName: string?)
		--[[ Checks ]]

		if teamName and not I.Team._createdTeams[teamName] then
			return false, `Team $|cr$|{teamName}#| does not exist`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Team.Assign(player, teamName)

		-- Returning
		if value then
			if teamName then
				return true, `$|cr$|{player.Name}#| has been assigned to Team $|cr$|{teamName}#|`
			else
				return true, `$|cr$|{player.Name}#| has been unassigned from Team`
			end
		else
			return false, `Failed to assign $|cr$|{player.Name}#| to Team $|cr$|{teamName}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function get(player: Player)
		-- Getting value
		local value: Team | nil = player.Team

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| is assigned to Team $|cr$|{value}#|`
		else
			return true, `$|cr$|{player.Name}#| is not assigned to any Team`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "create" },
			Args = {
				{ name = "teamName", types = { "string" } },
				{ name = "teamColor", types = { "Color" } },
				{ name = "autoAssignable", types = { "boolean" }, optional = true },
			},
			Callback = create,
		},
		{
			Aliases = { "remove" },
			Args = {
				{ name = "teamName", types = { "string" }, dict = "Team_TeamNames", requireDict = true },
			},
			Callback = remove,
		},
		{
			Aliases = { "assign" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "teamName", types = { "string" }, dict = "Team_TeamNames", requireDict = true, optional = true },
			},
			Callback = assign,
		},

		--[[ Methods ]]

		{
			Aliases = { "get" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = get,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Team_Server", {
		Aliases = { "team" },
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

	local allTeamNames = {} --- @type { string }

	for teamName: string, _team: Team in pairs(I.Team._createdTeams) do
		table.insert(allTeamNames, teamName)
	end
	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Team_TeamNames`, allTeamNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
