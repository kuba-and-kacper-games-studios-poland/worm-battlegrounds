--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players
local MarketplaceService = I.S.MarketplaceService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Receipts ]]

local PURCHASE_IDS_LIMIT: number = 20
local SAVE_CONFIRM_TIMEOUT: number = 60
local PROFILE_LOAD_MARGIN: number = 60

--[[ Purchase Log ]]

local PURCHASE_LOG_DAYS: number = 30
local PURCHASE_LOG_LIMIT: number = 200

local processingPurchaseIds = {} --- @type { [string]: boolean }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Has Saved Purchase Id

--[[
	Returns whether a written profile snapshot holds the PurchaseId in Marketplace's processed list.
]]
--- @param savedData { [string]: any }?
--- @return boolean
local function hasSavedPurchaseId(savedData, purchaseId: string)
	--[[ Data ]]

	local marketplaceData: any = savedData and savedData["Marketplace"]

	--[[ Checks ]]

	-- Check if the snapshot has the processed list (older snapshots don't)
	if type(marketplaceData) ~= "table" or type(marketplaceData.ProcessedPurchaseIds) ~= "table" then
		return false
	end

	--[[ Returning ]]

	return table.find(marketplaceData.ProcessedPurchaseIds, purchaseId) ~= nil
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

--- @class Marketplace_Product_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	MarketplaceService.ProcessReceipt = Module._processReceipt

	I.Marketplace._createIndividualEvents("Marketplace_ProductPurchaseSucceeded", products)
	I.Marketplace._createIndividualEvents("Marketplace_ProductPurchaseFailed", products)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Marketplace_ProductPurchaseSucceeded", { "Player", "string" })
	I.Topic.Register("Marketplace_ProductPurchaseFailed", { "Player", "string" })

	--- @Network
	I.Network.GetEvent("Marketplace_ProductPurchaseSucceeded")
	I.Network.GetEvent("Marketplace_ProductPurchaseFailed")

	I.Network.GetEvent("Marketplace_PromptProductPurchase", { "Player", "string" }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Marketplace_PromptProductPurchase", Module.PromptPurchase)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	--[[ Control ]]

	I.Marketplace.Product_PromptPurchase = Module.PromptPurchase

	--[[ Gift ]]

	I.Marketplace.Product_Gift = Module.Gift
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Purchase

--[[
	**SERVER** |
    Prompts a Developer Product purchase.
]]
--- @return boolean
function Module.PromptPurchase(player: Player, productName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local productId: number

	if products[productName] then
		productId = products[productName].Id
	else
		warn(`[{_localName}::{script.Name}]: ({productName}) is not a valid (productName)!`)
		return false
	end

	--[[ Checks ]]

	-- Invalid product id
	if productId == 0 then
		return false
	end

	-- Check if product can be purchased in the current place/map
	if products[productName]["PurchasePlaces"] then
		-- Getting Ids
		local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
		local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

		-- Getting if can be purchased
		local canBePurchasedInPlace: boolean = table.find(products[productName]["PurchasePlaces"], placeId) ~= nil
		local canBePurchasedInMap: boolean = table.find(products[productName]["PurchasePlaces"], placeMapId) ~= nil

		-- Return if product cannot be purchased
		if not canBePurchasedInPlace and not canBePurchasedInMap then
			return false
		end
	end

	-- Requirements
	if products[productName]["Requirements"] then
		local success: boolean, requirementsMet: boolean = pcall(function()
			return products[productName].Requirements(player)
		end)

		if not success or not requirementsMet then
			if type(requirementsMet) == "string" then
				warn(`[{_localName}::{script.Name}]: Failed to Prompt Purchase! - {requirementsMet}`)
			end

			return false
		end
	end

	--[[ Prompting ]]

	local success: boolean = pcall(function()
		MarketplaceService:PromptProductPurchase(player, productId)
	end)

	return success
end

--%%%%%%%%%%%%%%%%%%%% Gift

--[[
	**SERVER** |
    Gifts a product to the `player`.
	A `Reward` that returns `false` counts as a failed gift.
]]
--- @return boolean
function Module.Gift(player: Player, productName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the product exists
	if not products[productName] then
		return false
	end

	--[[ Gifting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(products[productName].Reward, player)

	--[[ Returning ]]

	return success and result ~= false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rewarding

--%%%%%%%%%%%%%%%%%%%% Process Receipt

--[[
    Override for the `MarketplaceService.ProcessReceipt` function.
	Skips a receipt this server is already processing, and turns any error into NotProcessedYet.
]]
--- @param receiptInfo Marketplace_ReceiptInfo
--- @return Enum.ProductPurchaseDecision
function Module._processReceipt(receiptInfo)
	--[[ Checks ]]

	-- Check if this server is already processing the receipt
	if processingPurchaseIds[receiptInfo.PurchaseId] then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Processing ]]

	processingPurchaseIds[receiptInfo.PurchaseId] = true

	local success: boolean
	local result: any | string?
	success, result = pcall(Module._resolveReceipt, receiptInfo)

	processingPurchaseIds[receiptInfo.PurchaseId] = nil

	-- Check if resolving the receipt errored
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to process receipt ({receiptInfo.PurchaseId})! - ({result})`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Resolve Receipt

--[[
	Grants a developer product once per PurchaseId and returns PurchaseGranted only after the grant is saved.
	A receipt already in the processed PurchaseIds list is saved again, never granted twice.
]]
--- @param receiptInfo Marketplace_ReceiptInfo
--- @return Enum.ProductPurchaseDecision
function Module._resolveReceipt(receiptInfo)
	--[[ Checks ]]

	local player: Player? = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	-- Check if the player is in the server
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Waiting For Player ]]

	local playerSettings = I.Settings["Player"] --- @type Player_Settings
	local deadline: number = os.clock() + playerSettings.CLIENT_LOAD_TIMEOUT_SECONDS + PROFILE_LOAD_MARGIN

	-- Wait while the player is still loading
	while not I.Player.Valid(player) and player:IsDescendantOf(Players) and os.clock() < deadline do
		task.wait(0.1)
	end

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	local profile = I.Player.GetProfile(player) --- @type Player_Profile
	local productName: string? = nil

	--[[ Finding ]]

	--- @param productData Marketplace_ProductsTableEntry
	for name: string, productData in pairs(products) do
		if productData.Id == receiptInfo.ProductId then
			productName = name
			break
		end
	end

	--[[ Checks ]]

	-- Check if the product exists
	if not productName then
		warn(`[{_localName}::{script.Name}]: ({receiptInfo.ProductId}) is not a valid (ProductId)!`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Only save again when this PurchaseId was already granted
	if table.find(moduleData.ProcessedPurchaseIds, receiptInfo.PurchaseId) then
		return Module._saveReceipt(profile, receiptInfo.PurchaseId)
	end

	--[[ Data ]]

	--- @type Marketplace_ProductsTableEntry
	local productData = products[productName]

	--[[ Checks ]]

	-- Check the requirements before granting
	if productData["PurchasedRequirements"] then
		local success: boolean
		local result: any | string?
		success, result = pcall(productData.PurchasedRequirements, player)

		if not success or not result then
			if type(result) == "string" then
				warn(`[{_localName}::{script.Name}]: Purchased requirements for product ({productName}) failed! - {result}`)
			end

			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	--[[ Rewarding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(productData.Reward, player)

	-- Check if the reward errored or returned false
	if not success or result == false then
		warn(`[{_localName}::{script.Name}]: Reward for product ({productName}) failed for ({player.Name})! - ({if success then "returned false" else result})`)

		-- General
		I.Topic.Publish("Marketplace_ProductPurchaseFailed", player, productName)
		I.Network.Fire("Marketplace_ProductPurchaseFailed", player, productName)

		-- Individual
		I.Topic.Publish(`Marketplace_ProductPurchaseFailed-{productName}`, player)
		I.Network.Fire(`Marketplace_ProductPurchaseFailed-{productName}`, player)

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Saving ]]

	-- Count the Robux spent
	if receiptInfo.CurrencyType == Enum.CurrencyType.Robux then
		moduleData.ProductRobuxSpent += receiptInfo.CurrencySpent
	end

	-- Record the PurchaseId, dropping the oldest past the limit
	table.insert(moduleData.ProcessedPurchaseIds, receiptInfo.PurchaseId)
	while #moduleData.ProcessedPurchaseIds > PURCHASE_IDS_LIMIT do
		table.remove(moduleData.ProcessedPurchaseIds, 1)
	end

	-- Log the purchase, with what the Reward says it granted
	local now: number = os.time()
	table.insert(moduleData.PurchaseLog, {
		PurchaseId = receiptInfo.PurchaseId,
		ProductId = receiptInfo.ProductId,
		Product = productName,
		CurrencySpent = receiptInfo.CurrencySpent,
		Channel = if receiptInfo.ProductPurchaseChannel then receiptInfo.ProductPurchaseChannel.Name else nil,
		PlaceId = receiptInfo.PlaceIdWherePurchased,
		Time = now,
		Granted = if type(result) == "string" then result else nil,
	})

	-- Drop the oldest log entries past the age or size limit
	local oldestTime: number = now - PURCHASE_LOG_DAYS * 86400
	while moduleData.PurchaseLog[1].Time < oldestTime or #moduleData.PurchaseLog > PURCHASE_LOG_LIMIT do
		table.remove(moduleData.PurchaseLog, 1)
	end

	--[[ Publishing ]]

	-- General
	I.Topic.Publish("Marketplace_ProductPurchaseSucceeded", player, productName)
	I.Network.Fire("Marketplace_ProductPurchaseSucceeded", player, productName)

	-- Individual
	I.Topic.Publish(`Marketplace_ProductPurchaseSucceeded-{productName}`, player)
	I.Network.Fire(`Marketplace_ProductPurchaseSucceeded-{productName}`, player)

	--[[ Returning ]]

	return Module._saveReceipt(profile, receiptInfo.PurchaseId)
end

--%%%%%%%%%%%%%%%%%%%% Save Receipt

--[[
	Forces a profile save and waits until a written save holds the PurchaseId.
	Returns NotProcessedYet when the session ends first or the save isn't confirmed in time.
]]
--- @param profile Player_Profile
--- @return Enum.ProductPurchaseDecision
function Module._saveReceipt(profile, purchaseId: string)
	--[[ Checks ]]

	-- Check if a written save already holds the PurchaseId
	if hasSavedPurchaseId(profile.LastSavedData, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Check if this server still owns the profile session
	if not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Saving ]]

	local saved: boolean = false

	-- OnAfterSave fires after the DataStore write, with the data that was written
	--- @type ProfileStore_Connection
	local connection = profile.OnAfterSave:Connect(function(savedData: any)
		saved = saved or hasSavedPurchaseId(savedData, purchaseId)
	end)

	profile:Save()

	--[[ Waiting ]]

	local deadline: number = os.clock() + SAVE_CONFIRM_TIMEOUT

	while not saved and profile:IsActive() and os.clock() < deadline do
		task.wait(0.1)
	end

	connection:Disconnect()

	--[[ Checks ]]

	-- Check if the save was confirmed
	if not saved then
		warn(`[{_localName}::{script.Name}]: Save for receipt ({purchaseId}) was not confirmed; the receipt stays pending.`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--[[ Returning ]]

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return Module
