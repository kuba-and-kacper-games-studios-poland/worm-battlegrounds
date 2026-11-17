--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Held = require(_scripts:FindFirstChild("Client"):FindFirstChild("Held")) --- @type Combat_Client_Held
local Flight = require(_scripts:FindFirstChild("Client"):FindFirstChild("Flight")) --- @type Combat_Client_Flight
local Shots = require(_scripts:FindFirstChild("Client"):FindFirstChild("Shots")) --- @type Combat_Client_Shots
local Effects = require(_scripts:FindFirstChild("Client"):FindFirstChild("Effects")) --- @type Combat_Client_Effects
local Aimbot = require(_scripts:FindFirstChild("Client"):FindFirstChild("Aimbot")) --- @type Combat_Client_Aimbot
local Vortex = require(_scripts:FindFirstChild("Client"):FindFirstChild("Vortex")) --- @type Combat_Client_Vortex
local Variants = require(_scripts:FindFirstChild("Client"):FindFirstChild("Variants")) --- @type Combat_Client_Variants

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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Combat = {

		--[[ Control ]]

		SetAim = Held.SetAim,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Before Held, which dresses the weapons it puts in hands
	Variants.Start()
	Held.Start()
	Flight.Start()
	Shots.Start()
	Effects.Start()
	Aimbot.Start()
	Vortex.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
