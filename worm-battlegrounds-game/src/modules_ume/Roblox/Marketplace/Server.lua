--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local assets = require(I.Dirs.GlobalData.Marketplace.Assets) --- @type Marketplace_Assets
local bundles = require(I.Dirs.GlobalData.Marketplace.Bundles) --- @type Marketplace_Bundles
local gamepasses = require(I.Dirs.GlobalData.Marketplace.GamePasses) --- @type Marketplace_GamePasses
local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local handlers = {
	[1] = require(_scripts.Asset.Server), --- @type Marketplace_Asset_Server
	[2] = require(_scripts.Bundle.Server), --- @type Marketplace_Bundle_Server
	[3] = require(_scripts.GamePass.Server), --- @type Marketplace_GamePass_Server
	[4] = require(_scripts.Product.Server), --- @type Marketplace_Product_Server
	[5] = require(_scripts.Premium.Server), --- @type Marketplace_RobloxPlus_Server,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Purchase Verification ]]

local VERIFY_ATTEMPTS: number = 3
local VERIFY_RETRY_DELAY: number = 2

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
	_pt["Marketplace"] = {
		AssetRewardsClaimed = {}, --- @type { [string]: number }
		BundleRewardsClaimed = {}, --- @type { [string]: number }
		GamePassRewardsClaimed = {}, --- @type { [string]: number }

		--[[ Robux Spent ]]

		AssetRobuxSpent = 0, --- @type number
		AssetRobuxSpentCalculatedFor = {}, --- @type { string }
		BundleRobuxSpent = 0, --- @type number
		BundleRobuxSpentCalculatedFor = {}, --- @type { string }
		GamePassRobuxSpent = 0, --- @type number
		GamePassRobuxSpentCalculatedFor = {}, --- @type { string }

		ProductRobuxSpent = 0, --- @type number

		--[[ Gifts ]]

		GiftedGamePasses = {}, --- @type { string }

		--[[ Receipts ]]

		ProcessedPurchaseIds = {}, --- @type { string }
		PurchaseLog = {}, --- @type { { [string]: any } }
	}

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Marketplace"] = {
		AssetRewardsClaimed = {}, --- @type { string }
		BundleRewardsClaimed = {}, --- @type { string }
		GamePassRewardsClaimed = {}, --- @type { string }

		IsRobloxPlus = false, --- @type boolean
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._validateData()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Marketplace = {

		--[[ Control ]]

		_createIndividualEvents = Module._createIndividualEvents,

		_purchaseSucceeded = Module._purchaseSucceeded,
		_awardRewardForAll = Module._awardRewardForAll,
		_awardReward = Module._awardReward,
	}

	----------------------------
	-------- POST-INIT ---------
	----------------------------

	for _, handler: table in ipairs(handlers) do
		if handler["Init"] then
			handler.Init()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	for _, handler: table in ipairs(handlers) do
		if handler["Start"] then
			handler.Start()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Validate Data

--[[
	Warns once about mistakes in the Marketplace tables: placeholder or duplicate ids within a kind,
	products without a `Reward`, and single or session rewards without a numeric `Version`.
]]
function Module._validateData()
	--[[ Local Variables ]]

	--- @type { [string]: { [string]: any } }
	local itemsTables = {
		Asset = assets,
		Bundle = bundles,
		GamePass = gamepasses,
		Product = products,
	}

	--[[ Validating ]]

	--- @param itemsTable { [string]: any }
	for kind: string, itemsTable in pairs(itemsTables) do
		local seenIds = {} --- @type { [number]: string }

		for name: string, itemData: any in pairs(itemsTable) do
			--[[ Id ]]

			-- Check that the id is a number, not the placeholder, and not used twice in this kind
			if type(itemData.Id) ~= "number" then
				warn(`[{_localName}::{script.Name}]: {kind} ({name}) is missing a numeric (Id)!`)
			elseif itemData.Id == 0 then
				warn(`[{_localName}::{script.Name}]: {kind} ({name}) still has the placeholder Id (0)!`)
			elseif seenIds[itemData.Id] then
				warn(`[{_localName}::{script.Name}]: {kind} ({name}) has the same Id ({itemData.Id}) as ({seenIds[itemData.Id]})!`)
			else
				seenIds[itemData.Id] = name
			end

			--[[ Rewards ]]

			-- Check if a product has its Reward function
			if kind == "Product" and type(itemData.Reward) ~= "function" then
				warn(`[{_localName}::{script.Name}]: Product ({name}) is missing its (Reward) function!`)
			end

			-- Check if single or session rewards have a numeric Version
			if (itemData.SingleReward or itemData.SessionReward) and type(itemData.Version) ~= "number" then
				warn(`[{_localName}::{script.Name}]: {kind} ({name}) has rewards but no numeric (Version)!`)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Individual Events

--[[
	**SERVER** |
	Creates individual topics and remotes for provided products table.
]]
function Module._createIndividualEvents(prefix: string, productsTable: table)
	for name: string, _productData: table in pairs(productsTable) do
		I.Topic.Register(`{prefix}-{name}`, { "Player" })
		I.Network.GetEvent(`{prefix}-{name}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Purchase Succeeded

--[[
	Publishes changes to inform server and player whether the purchase was successful.
	With `productType`, a success is published only after the player's ownership is confirmed.
]]
--- @param productsTable Marketplace_Assets | Marketplace_Bundles | Marketplace_GamePasses
function Module._purchaseSucceeded(player: Player, productId: number, success: boolean, productsTable, successPrefix: string, failedPrefix: string, individualEvents: boolean, productType: Enum.InfoType?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Getting the Asset Name ]]

	local assetName: string? = nil

	--- @param productData Marketplace_AssetsTableEntry | Marketplace_BundlesTableEntry | Marketplace_GamePassesTableEntry
	for name: string, productData in pairs(productsTable) do
		if productData.Id == productId then
			assetName = name
			break
		end
	end

	-- Check if the product exists
	if not assetName then
		warn(`[{_localName}::{script.Name}]: Product for ProductId ({productId}) was not found!`)
		return
	end

	--[[ Verifying ]]

	-- Confirm ownership before a success, retrying while Roblox catches up
	if success and productType then
		local owns: boolean = false

		for attempt: number = 1, VERIFY_ATTEMPTS do
			local _checked: boolean
			_checked, owns = I.G_Marketplace._checkOwnership(player, assetName, productType)

			-- Stop once owned or out of attempts
			if owns or attempt == VERIFY_ATTEMPTS then
				break
			end

			task.wait(VERIFY_RETRY_DELAY)
		end

		-- Check if ownership was confirmed
		if not owns then
			warn(`[{_localName}::{script.Name}]: Purchase of {productType.Name} ({assetName}) by ({player.Name}) could not be verified!`)
			return
		end
	end

	--[[ Fail ]]

	if not success then
		I.Topic.Publish(failedPrefix, player, assetName)
		I.Network.Fire(failedPrefix, player, assetName)

		if individualEvents then
			I.Topic.Publish(`{failedPrefix}-{assetName}`, player)
			I.Network.Fire(`{failedPrefix}-{assetName}`, player)
		end

		return
	end

	--[[ Success ]]

	I.Topic.Publish(successPrefix, player, assetName)
	I.Network.Fire(successPrefix, player, assetName)

	if individualEvents then
		I.Topic.Publish(`{successPrefix}-{assetName}`, player)
		I.Network.Fire(`{successPrefix}-{assetName}`, player)
	end
end

--%%%%%%%%%%%%%%%%%%%% Award Reward For All

--[[
	**SERVER** |
	Rewards player for all products he has from the specific `itemType` table.
]]
--- @return { [string]: { string } }
function Module._awardRewardForAll(player: Player, productType: Enum.InfoType, rewardType: "Single" | "Session" | "Character"?, forceReward: boolean?)
	--- @type Marketplace_Assets | Marketplace_Bundles | Marketplace_GamePasses
	local itemsTable

	if productType == Enum.InfoType.Asset then
		itemsTable = assets
	elseif productType == Enum.InfoType.Bundle then
		itemsTable = bundles
	elseif productType == Enum.InfoType.GamePass then
		itemsTable = gamepasses
	else
		warn(`[{_localName}::{script.Name}]: ({productType}) is not a valid (productType)!`)
		return
	end

	--[[ Rewarding ]]

	--- @type { [string]: { string } }
	local rewarded = {}

	for productName: string, _productData: table in pairs(itemsTable) do
		local success: boolean, grantedRewardTypes: { string } = Module._awardReward(player, productName, productType, rewardType, forceReward)
		if success then
			rewarded[productName] = grantedRewardTypes
		end
	end

	return rewarded
end

--%%%%%%%%%%%%%%%%%%%% Award Reward

--[[
	Rewards player for specific product of a certain type that he has.
	Skips items with no reward of the requested type before checking ownership.
]]
--- @return boolean
--- @return { string }?
function Module._awardReward(player: Player, productName: string, productType: Enum.InfoType, rewardType: "Single" | "Session" | "Character"?, forceReward: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Item Data ]]

	--- @type Marketplace_AssetsTableEntry | Marketplace_BundlesTableEntry | Marketplace_GamePassesTableEntry
	local itemData

	if productType == Enum.InfoType.Asset then
		itemData = assets[productName]
	elseif productType == Enum.InfoType.Bundle then
		itemData = bundles[productName]
	elseif productType == Enum.InfoType.GamePass then
		itemData = gamepasses[productName]
	else
		warn(`[{_localName}::{script.Name}]: ({productType}) is not a valid (productType)!`)
		return false
	end

	-- Check if the item exists
	if not itemData then
		warn(`[{_localName}::{script.Name}]: ({productName}) is not a valid (productName) for the ({productType}) (productType)!`)
		return false
	end

	--[[ Local Variables ]]

	local runSingle: boolean = itemData.SingleReward ~= nil and (rewardType == nil or rewardType == "Single")
	local runSession: boolean = itemData.SessionReward ~= nil and (rewardType == nil or rewardType == "Session")
	local runCharacter: boolean = itemData.CharacterReward ~= nil and (rewardType == nil or rewardType == "Character")

	--[[ Checks ]]

	-- Skip items with no reward of the requested type
	if not runSingle and not runSession and not runCharacter then
		return false
	end

	-- Check if rewards can be granted in the current place/map
	if itemData["RewardPlaces"] then
		-- Getting Ids
		local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
		local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

		-- Getting if can be purchased
		local canBePurchasedInPlace: boolean = table.find(itemData["RewardPlaces"], placeId) ~= nil
		local canBePurchasedInMap: boolean = table.find(itemData["RewardPlaces"], placeMapId) ~= nil

		-- Return if asset cannot be purchased
		if not canBePurchasedInPlace and not canBePurchasedInMap then
			return false
		end
	end

	-- Check if the player owns the item, unless the reward is forced
	forceReward = forceReward == true
	if not forceReward then
		if productType == Enum.InfoType.Asset then
			if not I.G_Marketplace.PlayerOwnsAsset(player, productName) then
				return false
			end
		elseif productType == Enum.InfoType.Bundle then
			if not I.G_Marketplace.PlayerOwnsBundle(player, productName) then
				return false
			end
		elseif productType == Enum.InfoType.GamePass then
			if not I.G_Marketplace.PlayerOwnsGamePass(player, productName) then
				return false
			end
		end
	end

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local sessionModuleData = sessionData["Marketplace"]

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rewarding

	local grantedRewardTypes = {} --- @type { string }

	--[[ Single Reward ]]

	-- Run the single reward once per Version
	if runSingle then
		local claimed = moduleData[`{productType.Name}RewardsClaimed`] --- @type { [string]: number }
		local previousVersion: number? = claimed[productName]

		if (previousVersion or 0) < itemData.Version or forceReward then
			-- Claim first, so an overlapping call doesn't run it twice
			claimed[productName] = itemData.Version

			local success: boolean
			local result: any | string?
			success, result = pcall(itemData.SingleReward, player)

			-- Give the claim back when the reward errored
			if success then
				table.insert(grantedRewardTypes, "Single")
			else
				claimed[productName] = previousVersion
				warn(`[{_localName}::{script.Name}]: Failed to grant (SingleReward) for {productType.Name} ({productName}) for ({player.Name}) - {result}`)
			end
		end
	end

	--[[ Session Reward ]]

	-- Run the session reward once per Version and session
	if runSession then
		local claimed = sessionModuleData[`{productType.Name}RewardsClaimed`] --- @type { [string]: number }
		local previousVersion: number? = claimed[productName]

		if (previousVersion or 0) < itemData.Version or forceReward then
			-- Claim first, so an overlapping call doesn't run it twice
			claimed[productName] = itemData.Version

			local success: boolean
			local result: any | string?
			success, result = pcall(itemData.SessionReward, player)

			-- Give the claim back when the reward errored
			if success then
				table.insert(grantedRewardTypes, "Session")
			else
				claimed[productName] = previousVersion
				warn(`[{_localName}::{script.Name}]: Failed to grant (SessionReward) for {productType.Name} ({productName}) for ({player.Name}) - {result}`)
			end
		end
	end

	--[[ Character Reward ]]

	-- Run the character reward on every call
	if runCharacter then
		local success: boolean
		local result: any | string?
		success, result = pcall(itemData.CharacterReward, player)

		-- Print the error when the reward errored
		if success then
			table.insert(grantedRewardTypes, "Character")
		else
			warn(`[{_localName}::{script.Name}]: Failed to grant (CharacterReward) for {productType.Name} ({productName}) for ({player.Name}) - {result}`)
		end
	end

	--[[ Returning ]]

	return true, grantedRewardTypes
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
