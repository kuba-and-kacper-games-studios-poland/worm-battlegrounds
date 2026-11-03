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
local bundles = require(I.Dirs.GlobalData.Marketplace.Bundles) --- @type Marketplace_Bundles
local gamepasses = require(I.Dirs.GlobalData.Marketplace.GamePasses) --- @type Marketplace_GamePasses
local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local marketplaceRep: Folder?

--[[ Product Info ]]

local PRODUCT_INFO_TTL: number = 300

local productInfoCache = {} --- @type { [string]: Marketplace_ProductInfoCacheEntry }

--[[ Ownership ]]

local ownedCache = {} --- @type { [Player]: { [string]: boolean } }

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

	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._clearOwnedCache)

	if I.Env.IsClient then
		I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	if I.Env.IsClient then
		--- @Network
		I.Network.GetEvent("Marketplace_AssetPurchaseSucceeded", { "string" })
		I.Network.GetEvent("Marketplace_AssetPurchaseFailed", { "string" })

		I.Network.GetEvent("Marketplace_BundlePurchaseSucceeded", { "string" })
		I.Network.GetEvent("Marketplace_BundlePurchaseFailed", { "string" })

		I.Network.GetEvent("Marketplace_GamePassPurchaseSucceeded", { "string" })
		I.Network.GetEvent("Marketplace_GamePassPurchaseFailed", { "string" })

		I.Network.GetEvent("Marketplace_ProductPurchaseSucceeded", { "string" })
		I.Network.GetEvent("Marketplace_ProductPurchaseFailed", { "string" })

		I.Network.GetEvent("Marketplace_RobloxPlusUpdated", { "boolean" })

		for assetName: string in pairs(assets) do
			I.Network.GetEvent(`Marketplace_AssetPurchaseSucceeded-{assetName}`, {})
			I.Network.GetEvent(`Marketplace_AssetPurchaseFailed-{assetName}`, {})
		end

		for bundleName: string in pairs(bundles) do
			I.Network.GetEvent(`Marketplace_BundlePurchaseSucceeded-{bundleName}`, {})
			I.Network.GetEvent(`Marketplace_BundlePurchaseFailed-{bundleName}`, {})
		end

		for gamepassName: string in pairs(gamepasses) do
			I.Network.GetEvent(`Marketplace_GamePassPurchaseSucceeded-{gamepassName}`, {})
			I.Network.GetEvent(`Marketplace_GamePassPurchaseFailed-{gamepassName}`, {})
		end

		for productName: string in pairs(products) do
			I.Network.GetEvent(`Marketplace_ProductPurchaseSucceeded-{productName}`, {})
			I.Network.GetEvent(`Marketplace_ProductPurchaseFailed-{productName}`, {})
		end
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Marketplace = {

		--[[ Info Methods ]]

		GetProductInfo = Module.GetProductInfo,
		GetProductPrice = Module.GetProductPrice,

		--[[ Player Methods ]]

		PlayerOwns = Module.PlayerOwns,
		PlayerOwnsAsset = Module.PlayerOwnsAsset,
		PlayerOwnsBundle = Module.PlayerOwnsBundle,
		PlayerOwnsGamePass = Module.PlayerOwnsGamePass,
		PlayerHasRobloxPlus = Module.PlayerHasRobloxPlus,

		--[[ Internal ]]

		_checkOwnership = Module._checkOwnership,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Caches the local player's Marketplace replicator folder, which holds the replicated game pass ownership.
]]
function Module._connectReplicator()
	--[[ General ]]

	marketplaceRep = I.Replicator.GetFolder(_localName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Clear Owned Cache

--[[
	Drops the leaving player's cached ownership.
]]
function Module._clearOwnedCache(player: Player)
	--[[ Clearing ]]

	ownedCache[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Info Methods

--%%%%%%%%%%%%%%%%%%%% Get Product Info

--[[
	Universal function that returns product info by its name and type.
	Results are cached per type and id for `PRODUCT_INFO_TTL` seconds, and concurrent callers share one request.
]]
--- @return Marketplace_ProductInfo | nil
function Module.GetProductInfo(productName: string, productType: Enum.InfoType)
	--[[ Getting Product Id ]]

	local productId: number

	if productType == Enum.InfoType.Asset then
		if assets[productName] then
			productId = assets[productName].Id
		end
	elseif productType == Enum.InfoType.Bundle then
		if bundles[productName] then
			productId = bundles[productName].Id
		end
	elseif productType == Enum.InfoType.GamePass then
		if gamepasses[productName] then
			productId = gamepasses[productName].Id
		end
	elseif productType == Enum.InfoType.Product then
		if products[productName] then
			productId = products[productName].Id
		end
	else
		warn(`[{_localName}::{script.Name}]: ({productType}) is not a valid (productType)!`)
		return false
	end

	if not productId then
		warn(`[{_localName}::{script.Name}]: ({productName}) is not a valid (productName) for a ({productType.Name})`)
		return false
	end

	--[[ Cache ]]

	local cacheKey: string = `{productType.Name}_{productId}`

	--- @type Marketplace_ProductInfoCacheEntry?
	local cachedEntry = productInfoCache[cacheKey]

	-- Wait for a request another caller already started
	if cachedEntry and cachedEntry.Pending then
		while cachedEntry.Pending do
			task.wait()
		end

		-- Check if that request failed
		if not cachedEntry.Info then
			return false
		end
	end

	-- Return a cached result that hasn't expired
	if cachedEntry and cachedEntry.Info and os.clock() < cachedEntry.ExpiresAt then
		return I.Table.DeepCopy(cachedEntry.Info)
	end

	--[[ Getting Info ]]

	--- @type Marketplace_ProductInfoCacheEntry
	local newEntry = {
		Info = nil,
		ExpiresAt = 0,
		Pending = true,
	}
	productInfoCache[cacheKey] = newEntry

	local success: boolean
	local result: any | string?
	success, result = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, productId, productType)

	--[[ Saving ]]

	newEntry.Pending = false

	-- Keep only successful results
	if success then
		newEntry.Info = result
		newEntry.ExpiresAt = os.clock() + PRODUCT_INFO_TTL
	elseif productInfoCache[cacheKey] == newEntry then
		productInfoCache[cacheKey] = nil
	end

	--[[ Returning ]]

	if success then
		return I.Table.DeepCopy(result)
	else
		return false
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Product Price

--[[
    Returns price of the given `productName`.
]]
--- @return string | number | nil
function Module.GetProductPrice(productName: string, productType: Enum.InfoType, addPrefix: boolean)
	--[[ Data ]]

	--- @type Marketplace_ProductInfo
	local productInfo = Module.GetProductInfo(productName, productType)

	--[[ Checks ]]

	-- Product info missing
	if not productInfo then
		return nil
	end

	--[[ Returning ]]

	-- Not for sale
	if not productInfo.IsForSale then
		if addPrefix then
			return `\u{E002}-`
		else
			return `-`
		end
	end

	-- Actual price
	if productInfo.PriceInRobux then
		if addPrefix then
			return `\u{E002}{productInfo.PriceInRobux}`
		else
			return productInfo.PriceInRobux
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Methods

--%%%%%%%%%%%%%%%%%%%% Player Owns

--[[
	Universal function that returns if player owns a product by its name and type.
]]
--- @return boolean
function Module.PlayerOwns(player: Player, productName: string, productType: Enum.InfoType)
	if productType == Enum.InfoType.GamePass then
		return Module.PlayerOwnsGamePass(player, productName)
	elseif productType == Enum.InfoType.Asset then
		return Module.PlayerOwnsAsset(player, productName)
	elseif productType == Enum.InfoType.Bundle then
		return Module.PlayerOwnsBundle(player, productName)
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Player Owns Asset

--[[
    Returns if player owns a certain Asset by its name.
	A positive result is cached for the session.
]]
--- @return boolean
function Module.PlayerOwnsAsset(player: Player, assetName: string)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the asset exists
	if not assets[assetName] then
		warn(`[{_localName}::{script.Name}]: ({assetName}) is not a valid (assetName)!`)
		return false
	end

	--[[ Getting Info ]]

	local _checked: boolean
	local owns: boolean
	_checked, owns = Module._checkOwnership(player, assetName, Enum.InfoType.Asset)

	--[[ Returning ]]

	return owns
end

--%%%%%%%%%%%%%%%%%%%% Player Owns Bundle

--[[
    Returns if player owns a certain Bundle by its name.
	A positive result is cached for the session.
]]
--- @return boolean
function Module.PlayerOwnsBundle(player: Player, bundleName: string)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the bundle exists
	if not bundles[bundleName] then
		warn(`[{_localName}::{script.Name}]: ({bundleName}) is not a valid (bundleName)!`)
		return false
	end

	--[[ Getting Info ]]

	local _checked: boolean
	local owns: boolean
	_checked, owns = Module._checkOwnership(player, bundleName, Enum.InfoType.Bundle)

	--[[ Returning ]]

	return owns
end

--%%%%%%%%%%%%%%%%%%%% Player Owns Game Pass

--[[
	Returns if player owns a certain GamePass by its name; a gifted pass counts unless `includeGifted` is false.
	With `stopAfterGifted`, returns only whether it was gifted. The local client reads replicated ownership when it has it.
]]
--- @return boolean
function Module.PlayerOwnsGamePass(player: Player, gamepassName: string, stopAfterGifted: boolean?, includeGifted: boolean?)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the game pass exists
	if not gamepasses[gamepassName] then
		warn(`[{_localName}::{script.Name}]: ({gamepassName}) is not a valid (gamepassName)!`)
		return false
	end

	--[[ Local Variables ]]

	local countGifted: boolean = includeGifted ~= false

	--[[ Replicated Ownership ]]

	-- Read the local player's replicated ownership once the server has filled it
	if I.Env.IsClient and player == I.Env.LocalPlayer and marketplaceRep then
		local repGifted: boolean? = marketplaceRep:GetAttribute(`GamePassGifted_{gamepassName}`)
		local repOwned: boolean? = marketplaceRep:GetAttribute(`GamePassOwned_{gamepassName}`)

		if repGifted ~= nil and repOwned ~= nil then
			if stopAfterGifted == true then
				return repGifted
			end

			return repOwned or (countGifted and repGifted)
		end
	end

	--[[ Is Gifted ]]

	local isGifted: boolean = false

	-- Check if gamePass was gifted
	if stopAfterGifted == true or countGifted then
		if I.Env.IsClient then
			isGifted = I.Network.Invoke("Marketplace_IsGamePassGifted", gamepassName) == true
		elseif I.Env.IsServer then
			isGifted = I.Marketplace.GamePass_IsGifted(player, gamepassName)
		end
	end

	-- Return if gamepass was gifted
	if stopAfterGifted == true or (countGifted and isGifted) then
		return isGifted
	end

	--[[ Getting Info ]]

	local _checked: boolean
	local owns: boolean
	_checked, owns = Module._checkOwnership(player, gamepassName, Enum.InfoType.GamePass)

	--[[ Returning ]]

	return owns
end

--%%%%%%%%%%%%%%%%%%%% Player Has Roblox Plus

--[[
	Returns whether the player has Roblox Plus.
]]
--- @return boolean
function Module.PlayerHasRobloxPlus(player: Player)
	if not player then
		return false
	end

	if I.Env.IsClient then
		if player ~= I.Env.LocalPlayer then
			return false
		end
	end

	return player.HasRobloxSubscription
end

--%%%%%%%%%%%%%%%%%%%% Check Ownership

--[[
	Checks whether the player really owns a named asset, bundle or game pass (gifts don't count).
	Returns whether the check succeeded and its result; a positive result is cached for the session.
]]
--- @return boolean
--- @return boolean
function Module._checkOwnership(player: Player, productName: string, productType: Enum.InfoType)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return false, false
	end

	--[[ Data ]]

	local cacheKey: string = `{productType.Name}_{productName}`
	local productId: number? = nil

	if productType == Enum.InfoType.Asset then
		productId = assets[productName] and assets[productName].Id
	elseif productType == Enum.InfoType.Bundle then
		productId = bundles[productName] and bundles[productName].Id
	elseif productType == Enum.InfoType.GamePass then
		productId = gamepasses[productName] and gamepasses[productName].Id
	end

	--[[ Checks ]]

	-- Check if the product exists
	if not productId then
		warn(`[{_localName}::{script.Name}]: ({productName}) is not a valid (productName) for a ({productType.Name})!`)
		return false, false
	end

	-- Return a cached positive result
	if ownedCache[player] and ownedCache[player][cacheKey] then
		return true, true
	end

	--[[ Getting Info ]]

	local success: boolean
	local result: any | string?

	if productType == Enum.InfoType.Asset then
		success, result = pcall(MarketplaceService.PlayerOwnsAssetAsync, MarketplaceService, player, productId)
	elseif productType == Enum.InfoType.Bundle then
		success, result = pcall(MarketplaceService.PlayerOwnsBundleAsync, MarketplaceService, player, productId)
	else
		success, result = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, productId)
	end

	--[[ Saving ]]

	local owns: boolean = success and result == true

	-- Cache a positive result while the player is still in the server
	if owns and player:IsDescendantOf(I.S.Players) then
		ownedCache[player] = ownedCache[player] or {}
		ownedCache[player][cacheKey] = true
	end

	--[[ Returning ]]

	return success, owns
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
