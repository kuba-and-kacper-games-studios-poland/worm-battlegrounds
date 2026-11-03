--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MarketplaceService = I.S.MarketplaceService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local assets = require(I.Dirs.GlobalData.Marketplace.Assets) --- @type Marketplace_Assets

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

--- @class Marketplace_Asset_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Late, function(player: Player, _: Model)
		task.spawn(function()
			I.Marketplace._awardRewardForAll(player, Enum.InfoType.Asset)
		end)
	end)

	I.G_Player.OnPlayerAdded(I.Priority.Default, function(player: Player)
		task.spawn(Module._updateAssetRobuxSpent, player)
	end)

	MarketplaceService.PromptPurchaseFinished:Connect(function(player, assetId, isPurchased)
		I.Marketplace._purchaseSucceeded(player, assetId, isPurchased, assets, "Marketplace_AssetPurchaseSucceeded", "Marketplace_AssetPurchaseFailed", true, Enum.InfoType.Asset)
		Module._updateAssetRobuxSpent(player)
	end)

	I.Marketplace._createIndividualEvents("Marketplace_AssetPurchaseSucceeded", assets)
	I.Marketplace._createIndividualEvents("Marketplace_AssetPurchaseFailed", assets)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Marketplace_AssetPurchaseSucceeded", { "Player", "string" })
	I.Topic.Register("Marketplace_AssetPurchaseFailed", { "Player", "string" })

	I.Topic.Subscribe("Marketplace_AssetPurchaseSucceeded", function(player: Player, assetName: string)
		I.Marketplace._awardReward(player, assetName, Enum.InfoType.Asset)
	end)

	--- @Network
	I.Network.GetEvent("Marketplace_AssetPurchaseSucceeded")
	I.Network.GetEvent("Marketplace_AssetPurchaseFailed")

	I.Network.GetEvent("Marketplace_PromptAssetPurchase", { "Player", "string" }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Marketplace_PromptAssetPurchase", Module.PromptPurchase)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	--[[ Control ]]

	I.Marketplace.Asset_PromptPurchase = Module.PromptPurchase
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Purchase

--[[
	**SERVER** |
    Prompts an asset purchase.
]]
--- @return boolean
function Module.PromptPurchase(player: Player, assetName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local assetId: number

	if assets[assetName] then
		assetId = assets[assetName].Id
	else
		warn(`[{_localName}::{script.Name}]: ({assetName}) is not a valid (assetName)!`)
		return false
	end

	--[[ Checks ]]

	-- Invalid asset id
	if assetId == 0 then
		return false
	end

	-- Check if asset can be purchased in the current place/map
	if assets[assetName]["PurchasePlaces"] then
		-- Getting Ids
		local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
		local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

		-- Getting if can be purchased
		local canBePurchasedInPlace: boolean = table.find(assets[assetName]["PurchasePlaces"], placeId) ~= nil
		local canBePurchasedInMap: boolean = table.find(assets[assetName]["PurchasePlaces"], placeMapId) ~= nil

		-- Return if asset cannot be purchased
		if not canBePurchasedInPlace and not canBePurchasedInMap then
			return false
		end
	end

	-- Player already owns the asset
	if I.G_Marketplace.PlayerOwnsAsset(player, assetName) then
		return false
	end

	--[[ Prompting ]]

	local success: boolean = pcall(function()
		MarketplaceService:PromptPurchase(player, assetId)
	end)

	return success
end

--%%%%%%%%%%%%%%%%%%%% Update Asset Robux Spent

--[[
    Updates the amount that player has spent on Assets.
	Runs on join and after a purchase; each asset is counted once.
]]
function Module._updateAssetRobuxSpent(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Updating ]]

	--- @param _assetData Marketplace_AssetsTableEntry
	for assetName: string, _assetData in pairs(assets) do
		--[[ Checks ]]

		-- Player does not own the asset
		if not I.G_Marketplace.PlayerOwnsAsset(player, assetName) then
			continue
		end

		-- The cost is already added
		if table.find(moduleData.AssetRobuxSpentCalculatedFor, assetName) then
			continue
		end

		--[[ Getting Price ]]

		local price: number = tonumber(I.G_Marketplace.GetProductPrice(assetName, Enum.InfoType.Asset, false)) or 0
		if price <= 0 then
			continue
		end

		-- Skip it if an overlapping update counted it during the yields
		if table.find(moduleData.AssetRobuxSpentCalculatedFor, assetName) then
			continue
		end

		--[[ Updating ]]

		moduleData.AssetRobuxSpent += price
		table.insert(moduleData.AssetRobuxSpentCalculatedFor, assetName)
	end
end

return Module
