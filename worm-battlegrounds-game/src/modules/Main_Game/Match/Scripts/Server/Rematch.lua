--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Roster = require(script.Parent:FindFirstChild("Roster")) --- @type Match_Server_Roster
local Connection = require(script.Parent:FindFirstChild("Connection")) --- @type Match_Server_Connection

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder
local open: boolean = false

-- The players who voted for a rematch
local voters = {} --- @type { [Player]: boolean }

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

--- @class Match_Server_Rematch
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(folder: Folder)
	--[[ Saving ]]

	matchFolder = folder

	--[[ Network ]]

	I.Network.GetEvent("Match_Rematch", { "Player" }, { RateLimit = 2 })
	I.Network.Fired("Match_Rematch", Module._onVote)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Opens the rematch vote for REMATCH_SECONDS, or until every player still in the match voted, and returns the
	players who voted and are still here.
]]
--- @return { Player }
function Module.Run()
	--[[ Opening ]]

	voters = {}
	open = true
	matchFolder:SetAttribute("RematchVotes", 0)
	matchFolder:SetAttribute("RematchEndsAt", I.S.Workspace:GetServerTimeNow() + _settings.REMATCH_SECONDS)

	--[[ Waiting ]]

	local deadline: number = os.clock() + _settings.REMATCH_SECONDS
	while os.clock() < deadline and Module._getVoteCount() < #Connection.GetPlayersInMatch() do
		task.wait(0.25)
	end

	--[[ Closing ]]

	open = false
	matchFolder:SetAttribute("RematchEndsAt", 0)

	--[[ Returning ]]

	local staying = {} --- @type { Player }
	for player: Player, _voted: boolean in pairs(voters) do
		if player.Parent then
			table.insert(staying, player)
		end
	end
	return staying
end

--%%%%%%%%%%%%%%%%%%%% On Vote

--[[
	A player who played the match votes to play it again.
]]
function Module._onVote(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the vote is open and the player played
	if not open or voters[player] or not Roster.GetParticipantOf(player) then
		return
	end

	--[[ Saving ]]

	voters[player] = true
	matchFolder:SetAttribute("RematchVotes", Module._getVoteCount())
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Vote Count

--[[
	Returns how many players still here voted.
]]
--- @return number
function Module._getVoteCount()
	--[[ Counting ]]

	local count: number = 0
	for player: Player, _voted: boolean in pairs(voters) do
		if player.Parent then
			count += 1
		end
	end

	--[[ Returning ]]

	return count
end

return Module
