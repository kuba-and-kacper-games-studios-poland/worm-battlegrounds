--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Team"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Teams = I.S.Teams

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Team_Teams
local teamsData = require(I.Dirs.GlobalData.Team.Teams)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: Team }
local createdTeams = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Team By Color

--[[
	Returns the created team that already uses this TeamColor.
]]
--- @return Team?
local function getTeamByColor(teamColor: BrickColor)
	--[[ Finding ]]

	for _teamName: string, team: Team in pairs(createdTeams) do
		-- Return the team with the same color
		if team.TeamColor == teamColor then
			return team
		end
	end

	--[[ Returning ]]

	return nil
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Team"] = {
		TeamConnection = nil, --- @type RBXScriptConnection?
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createTeams()

	I.OnStarted(I.Priority.Default, function()
		Module._connectAuthorizationCheck()
	end)

	--[[ Player ]]

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._connectTeamChanged)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._disconnectTeamChanged)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Team_Changed", { "Player", "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Team = {

		--[[ Control ]]

		Create = Module.Create,
		Remove = Module.Remove,
		Assign = Module.Assign,

		--[[ Methods ]]

		Get = Module.Get,
		GetPlayers = Module.GetPlayers,

		--[[ Private ]]

		_createdTeams = createdTeams,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Teams

--[[
	Creates all pre-defined `Teams` from the global data.
]]
function Module._createTeams()
	--[[ Creating Teams ]]

	--- @param teamData Team_TeamsTableEntry
	for teamName: string, teamData in pairs(teamsData) do
		--[[ Checks ]]

		local sameColorTeam: Team? = getTeamByColor(teamData.TeamColor)

		-- Skip a team whose TeamColor another team already uses
		if sameColorTeam then
			warn(`[{_localName}::{script.Name}]: Team ({teamName}) has the same TeamColor ({teamData.TeamColor}) as Team ({sameColorTeam.Name}) - skipping!`)
			continue
		end

		--[[ Creating ]]

		local newTeam: Team = I.Create("Team")({
			Name = teamName,
			TeamColor = teamData.TeamColor,
			AutoAssignable = teamData.AutoAssignable,
			Parent = Teams,
		}, {
			Team_Authorized = true,
		})

		--[[ Saving ]]

		createdTeams[teamName] = newTeam
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Authorization Check

--[[
	Creates a connection that checks if every old/new instance in the `Teams` service is authorized to be there.
]]
function Module._connectAuthorizationCheck()
	--%%%%%%%%%%%%%%%%%%%% Authorized Check

	--[[
		Checks if passed elem is authorized.
	]]
	local function authorizedCheck(elem: Instance)
		-- Authorized check
		if elem:GetAttribute("Team_Authorized") then
			-- Saving
			if elem:IsA("Team") and not createdTeams[elem.Name] then
				createdTeams[elem.Name] = elem
				I.AdminPanel_CommandBar.UpdateDictionary(`Team_TeamNames`, { elem.Name })
			end

			return
		end

		--[[ Authorization Failed -> Destroying ]]

		warn(`[{_localName}::{script.Name}]: Instance ({elem.Name}) created inside the (Teams) directory is not authorized!`)
		elem:Destroy()
	end

	--%%%%%%%%%%%%%%%%%%%% Removed Check

	--[[
		Forgets a created team that was destroyed or moved out of `Teams`.
	]]
	local function removedCheck(elem: Instance)
		--[[ Checks ]]

		-- Skip instances that aren't a created team
		if createdTeams[elem.Name] ~= elem then
			return
		end

		--[[ Forgetting ]]

		createdTeams[elem.Name] = nil
		I.AdminPanel_CommandBar.UpdateDictionary(`Team_TeamNames`, nil, { elem.Name })
	end

	--[[ Existing ]]

	for _, elem: Instance in ipairs(Teams:GetChildren()) do
		authorizedCheck(elem)
	end

	--[[ New ]]

	Teams.ChildAdded:Connect(authorizedCheck)

	--[[ Removed ]]

	Teams.ChildRemoved:Connect(removedCheck)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Connect Team Changed

--[[
	Publishes `Team_Changed` whenever the player's team changes, and once for a team Roblox gave them at join.
]]
function Module._connectTeamChanged(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Team"]

	--[[ Connecting ]]

	moduleSessionData.TeamConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
		I.Topic.Publish("Team_Changed", player, if player.Team then player.Team.Name else "")
	end)

	--[[ Publishing ]]

	-- Publish a team the player already has (AutoAssignable)
	if player.Team then
		I.Topic.Publish("Team_Changed", player, player.Team.Name)
	end
end

--%%%%%%%%%%%%%%%%%%%% Disconnect Team Changed

--[[
	Stops publishing `Team_Changed` for a leaving player.
]]
function Module._disconnectTeamChanged(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Team"]

	--[[ Checks ]]

	-- Skip players whose connection was never made
	if not moduleSessionData.TeamConnection then
		return
	end

	--[[ Disconnecting ]]

	moduleSessionData.TeamConnection:Disconnect()
	moduleSessionData.TeamConnection = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	**SERVER** |
    Creates a new team.
]]
--- @return Team?
function Module.Create(teamName: string, teamColor: BrickColor | Color3, autoAssignable: boolean?)
	--[[ Checks ]]

	-- Snap a Color3 to the nearest BrickColor
	if typeof(teamColor) == "Color3" then
		teamColor = BrickColor.new(teamColor)
	end

	-- Check if the team already exists
	if createdTeams[teamName] then
		warn(`[{_localName}::{script.Name}]: Team ({teamName}) already exists!`)
		return createdTeams[teamName]
	end

	local sameColorTeam: Team? = getTeamByColor(teamColor)

	-- Check if another team already uses that TeamColor
	if sameColorTeam then
		warn(`[{_localName}::{script.Name}]: Team ({teamName}) can't use TeamColor ({teamColor}), Team ({sameColorTeam.Name}) already has it!`)
		return nil
	end

	--[[ Creating ]]

	local newTeam: Team = I.Create("Team")({
		Name = teamName,
		TeamColor = teamColor,
		AutoAssignable = autoAssignable == true,
	}, {
		Team_Authorized = true,
	})

	newTeam.Parent = Teams

	--[[ Saving ]]

	createdTeams[teamName] = newTeam
	I.AdminPanel_CommandBar.UpdateDictionary(`Team_TeamNames`, { teamName })

	--[[ Returning ]]

	return createdTeams[teamName]
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	**SERVER** |
    Removes existing team.
]]
--- @return boolean
function Module.Remove(teamName: string)
	--[[ Checks ]]

	if not createdTeams[teamName] then
		warn(`[{_localName}::{script.Name}]: ({teamName}) is not a valid (teamName)!`)
		return false
	end

	--[[ Removing ]]

	createdTeams[teamName]:Destroy()

	-- Updating
	createdTeams[teamName] = nil
	I.AdminPanel_CommandBar.UpdateDictionary(`Team_TeamNames`, nil, { teamName })

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Assign

--[[
	**SERVER** |
	Assigns team to player; `Team_Changed` is published by the player's Team change.
]]
--- @return boolean
function Module.Assign(player: Player, teamName: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Take the player off any team when no name is given
	if not teamName then
		player.Team = nil
		return true
	end

	-- Check if the team exists
	if not createdTeams[teamName] then
		return false
	end

	--[[ Changing ]]

	player.Team = createdTeams[teamName]

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	**SERVER** |
    Returns Team instance by its name.
]]
--- @return Team | nil
function Module.Get(teamName: string)
	--[[ Checks ]]

	if not createdTeams[teamName] then
		warn(`[{_localName}::{script.Name}]: ({teamName}) is not a valid (teamName)!`)
		return nil
	end

	--[[ Returning ]]

	return createdTeams[teamName]
end

--%%%%%%%%%%%%%%%%%%%% Get Players

--[[
	**SERVER** |
	Returns the players on a team by its name.
]]
--- @return { Player }?
function Module.GetPlayers(teamName: string)
	--[[ Checks ]]

	-- Check if the team exists
	if not createdTeams[teamName] then
		warn(`[{_localName}::{script.Name}]: ({teamName}) is not a valid (teamName)!`)
		return nil
	end

	--[[ Returning ]]

	return createdTeams[teamName]:GetPlayers()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
