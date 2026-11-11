--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Liquids = require(_scripts:FindFirstChild("Client"):FindFirstChild("Liquids")) --- @type Atmosphere_Client_Liquids
local Ambient = require(_scripts:FindFirstChild("Client"):FindFirstChild("Ambient")) --- @type Atmosphere_Client_Ambient
local Wind = require(_scripts:FindFirstChild("Client"):FindFirstChild("Wind")) --- @type Atmosphere_Client_Wind
local Mood = require(_scripts:FindFirstChild("Client"):FindFirstChild("Mood")) --- @type Atmosphere_Client_Mood
local Reactions = require(_scripts:FindFirstChild("Client"):FindFirstChild("Reactions")) --- @type Atmosphere_Client_Reactions

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

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	--[[ Folders ]]

	local worldFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	local hasMatches: boolean = I.Config.PlaceLoader.MapId ~= _settings.LOBBY_MAP
	local arenaFolder: Instance? = if hasMatches then I.Dirs.UmeWorkspace:WaitForChild("Arena") else nil
	local matchFolder: Instance? = if hasMatches then I.Dirs.UmeWorkspace:WaitForChild("Match") else nil
	local lobbyFolder: Instance? = if I.Config.PlaceLoader.MapId ~= _settings.MATCH_MAP then I.Dirs.UmeWorkspace:WaitForChild("Lobby") else nil

	--[[ Handlers ]]

	Liquids.Start(arenaFolder)
	Ambient.Start(worldFolder, arenaFolder, lobbyFolder)
	Wind.Start(worldFolder)
	Mood.Start(matchFolder, arenaFolder)
	if hasMatches then
		Reactions.Start(arenaFolder, matchFolder, I.Dirs.UmeWorkspace:WaitForChild("Combat"), I.Dirs.UmeWorkspace:WaitForChild("Snails"))
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
