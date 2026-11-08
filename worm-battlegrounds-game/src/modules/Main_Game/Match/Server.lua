--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Roster = require(_scripts:FindFirstChild("Server"):FindFirstChild("Roster")) --- @type Match_Server_Roster
local Phases = require(_scripts:FindFirstChild("Server"):FindFirstChild("Phases")) --- @type Match_Server_Phases
local Turns = require(_scripts:FindFirstChild("Server"):FindFirstChild("Turns")) --- @type Match_Server_Turns
local Placement = require(_scripts:FindFirstChild("Server"):FindFirstChild("Placement")) --- @type Match_Server_Placement
local Stats = require(_scripts:FindFirstChild("Server"):FindFirstChild("Stats")) --- @type Match_Server_Stats
local Connection = require(_scripts:FindFirstChild("Server"):FindFirstChild("Connection")) --- @type Match_Server_Connection

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder

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

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Match"] = {
		Rejoin = false,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	matchFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
	Roster.Init(matchFolder)
	Phases.Init(matchFolder)
	Connection.Init(matchFolder)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Match_PhaseChanged", { "string" })
	I.Topic.Register("Match_TurnStarted", { "string" })
	I.Topic.Register("Match_TurnEnded", { "string" })
	I.Topic.Register("Match_ParticipantOut", { "string", "string", { Type = "string", Optional = true }, { Type = "string", Optional = true } })
	I.Topic.Register("Match_Ended", { "table", "table", "table" })

	--- @Network
	I.Network.GetEvent("Match_PickDrop", { "Player", "number", "number" }, { RateLimit = 10 })
	I.Network.Fired("Match_PickDrop", Phases.PickDrop)
	I.Network.GetEvent("Match_KnockedOut")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Match = {

		--[[ Control ]]

		Play = Phases.Play,
		Host = Phases.Host,
		SkipTurn = Turns.Skip,
		SetTurnSeconds = Turns.SetTurnSeconds,
		SetWind = Module.SetWind,
		SetRound = Module.SetRound,

		--[[ Methods ]]

		GetParticipant = Roster.GetParticipant,
		GetParticipantOf = Roster.GetParticipantOf,
		GetParticipants = Roster.GetParticipants,
		GetActive = Module.GetActive,
		GetPhase = Module.GetPhase,
		GetWind = Module.GetWind,
		GetMetadata = Roster.GetMetadata,
		IsActivePlayer = Module.IsActivePlayer,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.Topic.Subscribe("Snails_Died", Module._onSnailDied)
	I.Topic.Subscribe("Combat_ShotFired", Turns.OnShotFired)
	I.Topic.Subscribe("Combat_ShotResolved", Module._onShotResolved)
	Connection.Start()
	Phases.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Wind

--[[
	**SERVER** |
	Sets this turn's wind, kept between -WIND_MAX and WIND_MAX; the next turn rolls its own. For testing.
]]
function Module.SetWind(wind: number)
	matchFolder:SetAttribute("Wind", math.clamp(math.round(wind), -_settings.WIND_MAX, _settings.WIND_MAX))
end

--%%%%%%%%%%%%%%%%%%%% Set Round

--[[
	**SERVER** |
	Sets the round the match is on; from SUDDEN_DEATH_ROUND, the next turn starts sudden death. For testing.
]]
function Module.SetRound(round: number)
	matchFolder:SetAttribute("Round", math.max(math.round(round), 1))
end

--%%%%%%%%%%%%%%%%%%%% On Snail Died

--[[
	Takes a knocked-out snail's participant out of the match, credits the knockout, and tells every client for the
	kill feed.
]]
function Module._onSnailDied(participantId: string, cause: string, killerId: string?, itemId: string?)
	--[[ Checks ]]

	-- Check if the snail plays in this match
	if not Roster.GetParticipant(participantId) then
		return
	end

	--[[ Saving ]]

	Placement.RecordOut(participantId)
	if killerId and killerId ~= participantId then
		Stats.AddKnockout(killerId)
	end

	--[[ Publishing ]]

	I.Topic.Publish("Match_ParticipantOut", participantId, cause, killerId, itemId)
	I.Network.FireAll("Match_KnockedOut", participantId, cause, killerId, itemId)
end

--%%%%%%%%%%%%%%%%%%%% On Shot Resolved

--[[
	Counts a resolved shot's damage for its shooter, and lets the turn move on.
]]
function Module._onShotResolved(participantId: string, damage: number)
	--[[ Saving ]]

	Stats.AddShot(participantId, damage)
	Turns.OnShotResolved()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Active

--[[
	**SERVER** |
	Returns the id of the participant whose turn it is, or nil between turns.
]]
--- @return string?
function Module.GetActive()
	--[[ Local Variables ]]

	local activeId: string? = matchFolder:GetAttribute("ActiveId")

	--[[ Returning ]]

	return if activeId and activeId ~= "" then activeId else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Phase

--[[
	**SERVER** |
	Returns the match's phase: Waiting, Drop, Landing, Turn, Flight, Settle or Ended.
]]
--- @return string
function Module.GetPhase()
	return matchFolder:GetAttribute("Phase") or "Waiting"
end

--%%%%%%%%%%%%%%%%%%%% Get Wind

--[[
	**SERVER** |
	Returns this turn's wind, from -WIND_MAX (blowing left) to WIND_MAX (blowing right).
]]
--- @return number
function Module.GetWind()
	return matchFolder:GetAttribute("Wind") or 0
end

--%%%%%%%%%%%%%%%%%%%% Is Active Player

--[[
	**SERVER** |
	Returns whether it's this player's snail's turn.
]]
--- @return boolean
function Module.IsActivePlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Returning ]]

	return Module.GetActive() == `P_{player.UserId}`
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
