--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Backdrop = require(_scripts:FindFirstChild("Server"):FindFirstChild("Backdrop")) --- @type Lobby_Server_Backdrop

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The match each player was offered to rejoin, until they answer
local offers = {} --- @type { [Player]: any }

-- Workspace.Ume.Lobby, which holds the bot match's map behind the lobby
local worldFolder: Folder

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

	-- The match server writes it when a player drops; the lobby reads and clears it
	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Match"] = {
		Rejoin = false,
	}

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Lobby_RejoinOffer")
	I.Network.GetEvent("Lobby_Rejoin", { "Player", "boolean" }, { RateLimit = 1 })
	I.Network.Fired("Lobby_Rejoin", Module._onRejoin)

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	-- The backdrop's map, and the clients' bots playing on it
	worldFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._onPlayerAdded)
	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		offers[player] = nil
	end)
	Backdrop.Start(worldFolder)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% On Player Added

--[[
	Routes a player who arrives in the lobby: a reserved server that booted the lobby (an expired match) sends
	everyone to a public lobby; a player who hasn't played the tutorial match goes there first (not in Studio, unless
	asked); a player who dropped out of a running match is asked whether to go back.
]]
function Module._onPlayerAdded(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Match"]

	--[[ Expired Match ]]

	if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 then
		I.TeleportExternal(I.S.Players:GetPlayers(), I.Config.PlaceLoader.DefaultPlaceId, _settings.TELEPORT_GUI)
		return
	end

	--[[ Tutorial ]]

	-- Studio skips the tutorial match unless asked to; a match that can't start goes on to the lobby's part
	local skipMatch: boolean = I.S.RunService:IsStudio() and I.S.Workspace:GetAttribute(_settings.STUDIO_TUTORIAL_ATTRIBUTE) ~= true
	if not I.Tutorial.IsMatchDone(player) then
		if not skipMatch and I.MatchBoard.Launch({ player }, "Solo", "Deathmatch", 2, _settings.TUTORIAL_MAP, _settings.TUTORIAL_DIFFICULTY, true) then
			return
		end
		if I.S.RunService:IsStudio() then
			I.Tutorial.CompleteMatch(player)
		end
	end

	--[[ Rejoin ]]

	local rejoin: any = moduleData["Rejoin"]
	moduleData["Rejoin"] = false
	if type(rejoin) == "table" and rejoin.Until and rejoin.Until > os.time() then
		offers[player] = rejoin
		I.Network.Fire("Lobby_RejoinOffer", player, rejoin.Until - os.time())
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Rejoin

--[[
	A player answers the rejoin offer: yes sends them back to their match's server.
]]
function Module._onRejoin(player: Player, accept: boolean)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local rejoin: any = offers[player]
	offers[player] = nil

	--[[ Checks ]]

	-- Check if the offer is real and still open
	if not accept or not rejoin or rejoin.Until <= os.time() then
		return
	end

	--[[ Teleporting ]]

	I.Transition.SetDestination({ player }, "Back to your match…", "")
	I.TeleportToServer({ player }, rejoin.PlaceId, nil, rejoin.AccessCode, _settings.TELEPORT_GUI)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
