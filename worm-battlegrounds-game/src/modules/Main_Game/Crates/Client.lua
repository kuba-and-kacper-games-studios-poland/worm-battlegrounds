--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Panel = require(_scripts:FindFirstChild("Client"):FindFirstChild("Panel")) --- @type Crates_Client_Panel
local SkinModels = require(_scripts:FindFirstChild("Client"):FindFirstChild("SkinModels")) --- @type Crates_Client_SkinModels
local Odds = require(_scripts:FindFirstChild("Client"):FindFirstChild("Odds")) --- @type Crates_Client_Odds
local Showcase = require(_scripts:FindFirstChild("Client"):FindFirstChild("Showcase")) --- @type Crates_Client_Showcase
local Reel = require(_scripts:FindFirstChild("Client"):FindFirstChild("Reel")) --- @type Crates_Client_Reel
local Effects = require(_scripts:FindFirstChild("Client"):FindFirstChild("Effects")) --- @type Crates_Client_Effects
local Drops = require(_scripts:FindFirstChild("Client"):FindFirstChild("Drops")) --- @type Crates_Client_Drops
local Result = require(_scripts:FindFirstChild("Client"):FindFirstChild("Result")) --- @type Crates_Client_Result
local Stage3D = require(_scripts:FindFirstChild("Client"):FindFirstChild("Stage3D")) --- @type Crates_Client_Stage3D
local Reveal = require(_scripts:FindFirstChild("Client"):FindFirstChild("Reveal")) --- @type Crates_Client_Reveal
local GroupReward = require(_scripts:FindFirstChild("Client"):FindFirstChild("GroupReward")) --- @type Crates_Client_GroupReward

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

	I.Crates = {

		--[[ Control ]]

		ShowTab = Panel.ShowTab,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	SkinModels.Start()
	Odds.Start()
	Showcase.Start()
	Reel.Start()
	Effects.Start()
	Drops.Start()
	Result.Start()
	Stage3D.Start()
	Reveal.Start(Panel.Open)
	Panel.Start(Odds.Draw, Showcase.Draw, Reveal.Show)
	GroupReward.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
