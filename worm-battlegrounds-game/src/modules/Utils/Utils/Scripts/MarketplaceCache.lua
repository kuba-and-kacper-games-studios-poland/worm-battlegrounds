--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local assets = require(I.Dirs.GlobalData.Marketplace.Assets) --- @type Marketplace_Assets
local bundles = require(I.Dirs.GlobalData.Marketplace.Bundles) --- @type Marketplace_Bundles
local gamepasses = require(I.Dirs.GlobalData.Marketplace.GamePasses) --- @type Marketplace_GamePasses
local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Products ]]

--- @type { [Enum.InfoType]: { [string]: any } }
local productsByType = {
	[Enum.InfoType.Asset] = assets,
	[Enum.InfoType.Bundle] = bundles,
	[Enum.InfoType.GamePass] = gamepasses,
	[Enum.InfoType.Product] = products,
}

-- The `Utils_InfoType` names the marketplace components take, and `Custom` for Group / RobloxPlus
--- @type { [string]: Enum.InfoType | string }
local infoTypes = {
	["Asset"] = Enum.InfoType.Asset,
	["Bundle"] = Enum.InfoType.Bundle,
	["GamePass"] = Enum.InfoType.GamePass,
	["Product"] = Enum.InfoType.Product,
	["Custom"] = "Custom",
}

--[[ Cache ]]

local cachedPrices = {} --- @type { [string]: string | number }
local cachedOwned = {} --- @type { [string]: boolean }
local pendingPrices = {} --- @type { [string]: { thread } }
local pendingOwned = {} --- @type { [string]: { thread } }

--[[ Signals ]]

local changedSignal = I.Signal.new() --- @type Signal

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Fetch Shared

--[[
	Returns `cache[key]`, or runs `fetch` once for every caller asking for `key` at the same time and caches a non-nil result.
	A key dropped while its fetch runs keeps that result out of the cache.
]]
--- @param cache { [string]: any }
--- @param pending { [string]: { thread } }
--- @return any
local function fetchShared(cache, pending, key: string, fetch: () -> any)
	--[[ Checks ]]

	-- Return the cached value
	if cache[key] ~= nil then
		return cache[key]
	end

	-- Wait for the request already running for this key
	if pending[key] then
		table.insert(pending[key], coroutine.running())
		return coroutine.yield()
	end

	--[[ Fetching ]]

	local waiting = {} --- @type { thread }
	pending[key] = waiting

	local success: boolean
	local result: any | string?
	success, result = pcall(fetch)

	-- Treat a failed lookup as no answer
	if not success then
		warn(`[{_localName}::{script.Name}]: Lookup of ({key}) failed! - ({result})`)
		result = nil
	end

	--[[ Saving ]]

	-- Cache the answer unless the key was dropped meanwhile
	if pending[key] == waiting then
		pending[key] = nil

		if result ~= nil then
			cache[key] = result
		end
	end

	--[[ Resuming ]]

	for _, thread: thread in ipairs(waiting) do
		task.spawn(thread, result)
	end

	--[[ Returning ]]

	return result
end

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

--- @class Utils_MarketplaceCache
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.Fired("Marketplace_AssetPurchaseSucceeded", function(assetName: string)
		Module._onPurchased(assetName, Enum.InfoType.Asset)
	end)
	I.Network.Fired("Marketplace_BundlePurchaseSucceeded", function(bundleName: string)
		Module._onPurchased(bundleName, Enum.InfoType.Bundle)
	end)
	I.Network.Fired("Marketplace_GamePassPurchaseSucceeded", function(gamepassName: string)
		Module._onPurchased(gamepassName, Enum.InfoType.GamePass)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Purchased

--[[
	Drops the cached ownership of a purchased or gifted product, then tells the labels.
]]
function Module._onPurchased(productName: string, infoType: Enum.InfoType)
	--[[ Clearing ]]

	local key: string = `{infoType.Name}:{productName}`
	cachedOwned[key] = nil
	pendingOwned[key] = nil

	--[[ Publishing ]]

	changedSignal:Fire(productName, infoType)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Price

--[[
	Returns the product's price from `I.G_Marketplace.GetProductPrice`, shared by every label of that product; nil when the lookup failed.
]]
--- @return string | number | nil
function Module.GetPrice(productName: string, infoType: Enum.InfoType, addPrefix: boolean)
	return fetchShared(cachedPrices, pendingPrices, `{infoType.Name}:{productName}:{addPrefix}`, function()
		return I.G_Marketplace.GetProductPrice(productName, infoType, addPrefix)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Get Owned

--[[
	Returns whether the local player owns the product, shared by every label of that product until a purchase or gift of it.
]]
--- @return boolean
function Module.GetOwned(productName: string, infoType: Enum.InfoType)
	return fetchShared(cachedOwned, pendingOwned, `{infoType.Name}:{productName}`, function()
		return I.G_Marketplace.PlayerOwns(I.Env.LocalPlayer, productName, infoType)
	end) == true
end

--%%%%%%%%%%%%%%%%%%%% Get Changed Signal

--[[
	Returns the signal that fires with `(productName, infoType)` once a purchase or gift dropped that product's cached ownership.
]]
--- @return Signal
function Module.GetChangedSignal()
	return changedSignal
end

--%%%%%%%%%%%%%%%%%%%% Get Info Type

--[[
	Returns the `Enum.InfoType` a `Utils_InfoType` name stands for, `"Custom"` for Custom, or nil for an unknown name.
]]
--- @return Enum.InfoType | string | nil
function Module.GetInfoType(infoTypeName: string)
	return infoTypes[infoTypeName]
end

--%%%%%%%%%%%%%%%%%%%% Is Listed

--[[
	Returns whether `productName` is listed in the Marketplace data for `infoType`.
]]
--- @return boolean
function Module.IsListed(productName: string, infoType: Enum.InfoType)
	return productsByType[infoType] ~= nil and productsByType[infoType][productName] ~= nil
end

return Module
