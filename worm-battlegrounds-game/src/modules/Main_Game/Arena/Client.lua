--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Carver = require(_scripts:FindFirstChild("Client"):FindFirstChild("Carver")) --- @type Arena_Client_Carver
local Falling = require(_scripts:FindFirstChild("Client"):FindFirstChild("Falling")) --- @type Arena_Client_Falling
local PropBoxes = require(_scripts:FindFirstChild("Client"):FindFirstChild("PropBoxes")) --- @type Arena_Client_PropBoxes
local Thrown = require(_scripts:FindFirstChild("Client"):FindFirstChild("Thrown")) --- @type Arena_Client_Thrown
local PropCarver = require(_scripts:FindFirstChild("Client"):FindFirstChild("PropCarver")) --- @type Arena_Client_PropCarver
local PropSeeThrough = require(_scripts:FindFirstChild("Client"):FindFirstChild("PropSeeThrough")) --- @type Arena_Client_PropSeeThrough

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
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	I.Topic.Register("Arena_PropThrown", { "BasePart" })
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	local arenaFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	Carver.Start(arenaFolder)
	Falling.Start(arenaFolder)
	PropBoxes.Start(arenaFolder)
	Thrown.Start(arenaFolder)
	PropCarver.Start(arenaFolder)
	PropSeeThrough.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
