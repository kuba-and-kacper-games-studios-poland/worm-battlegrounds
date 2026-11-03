--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

local Stock = require(_scripts:FindFirstChild("Server"):FindFirstChild("Stock")) --- @type Limited_Server_Stock
local Hold = require(_scripts:FindFirstChild("Server"):FindFirstChild("Hold")) --- @type Limited_Server_Hold
local Purchase = require(_scripts:FindFirstChild("Server"):FindFirstChild("Purchase")) --- @type Limited_Server_Purchase

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
	_pt["Limited"] = {
		Bought = {},
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Stock.Init()
	Hold.Init()
	Purchase.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Limited = {

		--[[ Control ]]

		RewardPurchase = Purchase.RewardPurchase,
		ProductRequirements = Purchase.ProductRequirements,

		--[[ Methods ]]

		CanPurchase = Purchase.CanPurchase,
		HasBought = Purchase.HasBought,
		GetRemaining = Stock.GetRemaining,
		GetRemainingPurchases = Purchase.GetRemainingPurchases,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Stock.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
