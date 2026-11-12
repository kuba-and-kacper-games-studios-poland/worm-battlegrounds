--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Tags = require(_scripts:FindFirstChild("Client"):FindFirstChild("Tags")) --- @type Snails_Client_Tags
local Gear = require(_scripts:FindFirstChild("Client"):FindFirstChild("Gear")) --- @type Snails_Client_Gear
local Sounds = require(_scripts:FindFirstChild("Client"):FindFirstChild("Sounds")) --- @type Snails_Client_Sounds
local Effects = require(_scripts:FindFirstChild("Client"):FindFirstChild("Effects")) --- @type Snails_Client_Effects
local Motion = require(_scripts:FindFirstChild("Client"):FindFirstChild("Motion")) --- @type Snails_Client_Motion
local Ghost = require(_scripts:FindFirstChild("Client"):FindFirstChild("Ghost")) --- @type Snails_Client_Ghost
local Potions = require(_scripts:FindFirstChild("Client"):FindFirstChild("Potions")) --- @type Snails_Client_Potions
local Flight = require(_scripts:FindFirstChild("Client"):FindFirstChild("Flight")) --- @type Snails_Client_Flight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local snailsFolder: Folder

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

	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Snails = {

		--[[ Methods ]]

		Get = Module.Get,
		GetMine = Module.GetMine,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Tags.Start(snailsFolder)
	Gear.Start(snailsFolder)
	Sounds.Start(snailsFolder)
	Effects.Start(snailsFolder)
	Motion.Start(snailsFolder)
	Ghost.Start(snailsFolder)
	Potions.Start(snailsFolder)
	Flight.Start(snailsFolder)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns a participant's snail, or nil when it has none.
]]
--- @return Model?
function Module.Get(participantId: string)
	return snailsFolder:FindFirstChild(participantId)
end

--%%%%%%%%%%%%%%%%%%%% Get Mine

--[[
	**CLIENT** |
	Returns the local player's snail, or nil when they have none.
]]
--- @return Model?
function Module.GetMine()
	return snailsFolder:FindFirstChild(`P_{I.S.Players.LocalPlayer.UserId}`)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
