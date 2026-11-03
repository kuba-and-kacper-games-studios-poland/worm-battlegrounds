--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MarketplaceService = I.S.MarketplaceService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local bundles = require(I.Dirs.GlobalData.Marketplace.Bundles) --- @type Marketplace_Bundles

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

--- @class Marketplace_Bundle_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Late, function(player: Player, _: Model)
		task.spawn(function()
			I.Marketplace._awardRewardForAll(player, Enum.InfoType.Bundle)
		end)
	end)

	I.G_Player.OnPlayerAdded(I.Priority.Default, function(player: Player)
		task.spawn(Module._updateBundleRobuxSpent, player)
	end)

	MarketplaceService.PromptBundlePurchaseFinished:Connect(function(player, bundleId, wasPurchased)
		I.Marketplace._purchaseSucceeded(player, bundleId, wasPurchased, bundles, "Marketplace_BundlePurchaseSucceeded", "Marketplace_BundlePurchaseFailed", true, Enum.InfoType.Bundle)
		Module._updateBundleRobuxSpent(player)
	end)

	I.Marketplace._createIndividualEvents("Marketplace_BundlePurchaseSucceeded", bundles)
	I.Marketplace._createIndividualEvents("Marketplace_BundlePurchaseFailed", bundles)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Marketplace_BundlePurchaseSucceeded", { "Player", "string" })
	I.Topic.Register("Marketplace_BundlePurchaseFailed", { "Player", "string" })

	I.Topic.Subscribe("Marketplace_BundlePurchaseSucceeded", function(player: Player, bundleName: string)
		I.Marketplace._awardReward(player, bundleName, Enum.InfoType.Bundle)
	end)

	--- @Network
	I.Network.GetEvent("Marketplace_BundlePurchaseSucceeded")
	I.Network.GetEvent("Marketplace_BundlePurchaseFailed")

	I.Network.GetEvent("Marketplace_PromptBundlePurchase", { "Player", "string" }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Marketplace_PromptBundlePurchase", Module.PromptPurchase)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	--[[ Control ]]

	I.Marketplace.Bundle_PromptPurchase = Module.PromptPurchase
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Purchase

--[[
	**SERVER** |
    Prompts a bundle purchase.
]]
--- @return boolean
function Module.PromptPurchase(player: Player, bundleName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local bundleId: number

	if bundles[bundleName] then
		bundleId = bundles[bundleName].Id
	else
		warn(`[{_localName}::{script.Name}]: ({bundleName}) is not a valid (bundleName)!`)
		return false
	end

	--[[ Checks ]]

	-- Invalid bundle id
	if bundleId == 0 then
		return false
	end

	-- Check if bundle can be purchased in the current place/map
	if bundles[bundleName]["PurchasePlaces"] then
		-- Getting Ids
		local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
		local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

		-- Getting if can be purchased
		local canBePurchasedInPlace: boolean = table.find(bundles[bundleName]["PurchasePlaces"], placeId) ~= nil
		local canBePurchasedInMap: boolean = table.find(bundles[bundleName]["PurchasePlaces"], placeMapId) ~= nil

		-- Return if bundle cannot be purchased
		if not canBePurchasedInPlace and not canBePurchasedInMap then
			return false
		end
	end

	-- Player already owns the bundle
	if I.G_Marketplace.PlayerOwnsBundle(player, bundleName) then
		return false
	end

	--[[ Prompting ]]

	local success: boolean = pcall(function()
		MarketplaceService:PromptBundlePurchase(player, bundleId)
	end)

	return success
end

--%%%%%%%%%%%%%%%%%%%% Update Bundle Robux Spent

--[[
    Updates the amount that player has spent on Bundles.
	Runs on join and after a purchase; each bundle is counted once.
]]
function Module._updateBundleRobuxSpent(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Updating ]]

	--- @param _bundleData Marketplace_BundlesTableEntry
	for bundleName: string, _bundleData in pairs(bundles) do
		--[[ Checks ]]

		-- Player does not own the bundle
		if not I.G_Marketplace.PlayerOwnsBundle(player, bundleName) then
			continue
		end

		-- The cost is already added
		if table.find(moduleData.BundleRobuxSpentCalculatedFor, bundleName) then
			continue
		end

		--[[ Getting Price ]]

		local price: number = tonumber(I.G_Marketplace.GetProductPrice(bundleName, Enum.InfoType.Bundle, false)) or 0
		if price <= 0 then
			continue
		end

		-- Skip it if an overlapping update counted it during the yields
		if table.find(moduleData.BundleRobuxSpentCalculatedFor, bundleName) then
			continue
		end

		--[[ Updating ]]

		moduleData.BundleRobuxSpent += price
		table.insert(moduleData.BundleRobuxSpentCalculatedFor, bundleName)
	end
end

return Module
