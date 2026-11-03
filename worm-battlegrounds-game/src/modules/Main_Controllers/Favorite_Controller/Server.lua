--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Favorite_Controller"

--- @type Favorite_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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
	_pt["Favorite_Controller"] = {
		FirstTimePromptShown = false,
		MarketplacePromptShown = false,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._onJoined)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("Marketplace_AssetPurchaseSucceeded", Module._onPurchase)
	I.Topic.Subscribe("Marketplace_BundlePurchaseSucceeded", Module._onPurchase)
	I.Topic.Subscribe("Marketplace_GamePassPurchaseSucceeded", Module._onPurchase)
	I.Topic.Subscribe("Marketplace_ProductPurchaseSucceeded", Module._onPurchase)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Joined

--[[
	Prompts game favorite after some delay for the first time player joins the game.
]]
function Module._onJoined(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Favorite_Controller"]

	--[[ Checks ]]

	-- Skip when the prompt was already shown
	if moduleData.FirstTimePromptShown then
		return
	end

	--[[ Prompting after Delay ]]

	task.delay(_settings.PROMPT_AFTER_JOINED, function()
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		-- Already shown
		if moduleData.FirstTimePromptShown then
			return
		end

		--[[ Prompting ]]

		-- Claim the prompt first so another trigger skips it while this one waits
		moduleData.FirstTimePromptShown = true

		-- Give the prompt back when it didn't open
		if I.Favorite.PromptGameSetFavorite(player, true) ~= true then
			moduleData.FirstTimePromptShown = false
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Purchase

--[[
	Prompts game favorite after the first purchase. 
]]
function Module._onPurchase(player: Player, _productName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Favorite_Controller"]

	--[[ Checks ]]

	-- Skip when the prompt was already shown
	if moduleData.MarketplacePromptShown then
		return
	end

	--[[ Prompting after Delay ]]

	task.delay(_settings.PROMPT_AFTER_PURCHASE, function()
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		-- Already shown
		if moduleData.MarketplacePromptShown then
			return
		end

		--[[ Prompting ]]

		-- Claim the prompt first so another purchase skips it while this one waits
		moduleData.MarketplacePromptShown = true

		-- Give the prompt back when it didn't open
		if I.Favorite.PromptGameSetFavorite(player, true) ~= true then
			moduleData.MarketplacePromptShown = false
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
