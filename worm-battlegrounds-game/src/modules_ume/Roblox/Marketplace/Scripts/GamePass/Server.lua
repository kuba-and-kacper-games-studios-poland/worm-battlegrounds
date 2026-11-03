--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MarketplaceService = I.S.MarketplaceService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local gamepasses = require(I.Dirs.GlobalData.Marketplace.GamePasses) --- @type Marketplace_GamePasses

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Replicator ]]

local replicatedNames = {} --- @type { [string]: boolean }

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

--- @class Marketplace_GamePass_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._cacheReplicatedNames()

	I.G_Player.OnCharacterAdded(I.Priority.Late, function(player: Player, _: Model)
		task.spawn(function()
			I.Marketplace._awardRewardForAll(player, Enum.InfoType.GamePass)
		end)
	end)

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, function(player: Player)
		I.Replicator.CreateFolder(player, _localName)
	end)

	I.G_Player.OnPlayerAdded(I.Priority.Setup, function(player: Player)
		task.spawn(function()
			Module._replicateAll(player)
			Module._updateGamePassRobuxSpent(player)
		end)
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		I.Marketplace._purchaseSucceeded(player, gamePassId, wasPurchased, gamepasses, "Marketplace_GamePassPurchaseSucceeded", "Marketplace_GamePassPurchaseFailed", true, Enum.InfoType.GamePass)
		Module._updateGamePassRobuxSpent(player)
	end)

	I.Marketplace._createIndividualEvents("Marketplace_GamePassPurchaseSucceeded", gamepasses)
	I.Marketplace._createIndividualEvents("Marketplace_GamePassPurchaseFailed", gamepasses)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Marketplace_GamePassPurchaseSucceeded", { "Player", "string" })
	I.Topic.Register("Marketplace_GamePassPurchaseFailed", { "Player", "string" })

	I.Topic.Subscribe("Marketplace_GamePassPurchaseSucceeded", function(player: Player, gamepassName: string)
		Module._replicateGamePass(player, gamepassName)
		I.Marketplace._awardReward(player, gamepassName, Enum.InfoType.GamePass)
	end)

	--- @Network
	I.Network.GetEvent("Marketplace_GamePassPurchaseSucceeded")
	I.Network.GetEvent("Marketplace_GamePassPurchaseFailed")

	I.Network.GetEvent("Marketplace_PromptGamePassPurchase", { "Player", "string" }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Marketplace_PromptGamePassPurchase", Module.PromptPurchase)

	I.Network.GetFunction("Marketplace_IsGamePassGifted", { "Player", "string" })
	I.Network.OnInvoke("Marketplace_IsGamePassGifted", Module.IsGifted)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	--[[ Control ]]

	I.Marketplace.GamePass_PromptPurchase = Module.PromptPurchase

	--[[ Gift Control ]]

	I.Marketplace.GamePass_Gift = Module.Gift
	I.Marketplace.GamePass_GiftAll = Module.GiftAll

	I.Marketplace.GamePass_ClearGift = Module.ClearGift
	I.Marketplace.GamePass_ClearAllGifts = Module.ClearAllGifts

	I.Marketplace.GamePass_IsGifted = Module.IsGifted
	I.Marketplace.GamePass_GetGifted = Module.GetGifted
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Cache Replicated Names

--[[
	Collects the game pass names that can be replicator attribute names, and warns about the rest.
]]
function Module._cacheReplicatedNames()
	--[[ Caching ]]

	--- @param _gamepassData Marketplace_GamePassesTableEntry
	for gamepassName: string, _gamepassData in pairs(gamepasses) do
		-- Skip names that aren't valid attribute names
		if not string.match(gamepassName, "^[%w_%-]+$") or #`GamePassGifted_{gamepassName}` > 100 then
			warn(`[{_localName}::{script.Name}]: Game pass ({gamepassName}) can't be replicated; its name isn't a valid attribute name!`)
			continue
		end

		replicatedNames[gamepassName] = true
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Replicate All

--[[
	Replicates every game pass's ownership for a player who just joined.
]]
function Module._replicateAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Replicating ]]

	for gamepassName: string, _replicated: boolean in pairs(replicatedNames) do
		Module._replicateGamePass(player, gamepassName)
	end
end

--%%%%%%%%%%%%%%%%%%%% Replicate Game Pass

--[[
	Mirrors one game pass's gifted and real ownership onto the player's Marketplace replicator folder.
	Real ownership is written only after a successful check, so the client keeps its own check until then.
]]
function Module._replicateGamePass(player: Player, gamepassName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Skip names that can't be replicated
	if not replicatedNames[gamepassName] then
		return
	end

	--[[ Replicating ]]

	I.Replicator.Set(player, _localName, `GamePassGifted_{gamepassName}`, Module.IsGifted(player, gamepassName))

	local checked: boolean
	local owns: boolean
	checked, owns = I.G_Marketplace._checkOwnership(player, gamepassName, Enum.InfoType.GamePass)

	-- Write real ownership only when the check succeeded
	if checked then
		I.Replicator.Set(player, _localName, `GamePassOwned_{gamepassName}`, owns)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Purchase

--[[
	**SERVER** |
    Prompts a GamePass purchase.
]]
--- @return boolean
function Module.PromptPurchase(player: Player, gamepassName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local gamePassId: number

	if gamepasses[gamepassName] then
		gamePassId = gamepasses[gamepassName].Id
	else
		warn(`[{_localName}::{script.Name}]: ({gamepassName}) is not a valid (gamepassName)!`)
		return false
	end

	--[[ Checks ]]

	-- Invalid gamePass id
	if gamePassId == 0 then
		return false
	end

	-- Check if gamePass can be purchased in the current place/map
	if gamepasses[gamepassName]["PurchasePlaces"] then
		-- Getting Ids
		local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
		local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

		-- Getting if can be purchased
		local canBePurchasedInPlace: boolean = table.find(gamepasses[gamepassName]["PurchasePlaces"], placeId) ~= nil
		local canBePurchasedInMap: boolean = table.find(gamepasses[gamepassName]["PurchasePlaces"], placeMapId) ~= nil

		-- Return if gamePass cannot be purchased
		if not canBePurchasedInPlace and not canBePurchasedInMap then
			return false
		end
	end

	-- Player already owns the gamePass
	if I.G_Marketplace.PlayerOwnsGamePass(player, gamepassName) then
		return false
	end

	--[[ Prompting ]]

	local success: boolean = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, gamePassId)
	end)

	return success
end

--%%%%%%%%%%%%%%%%%%%% Update GamePass Robux Spent

--[[
    Updates the amount that player has spent on GamePasses.
	Runs on join and after a purchase; each bought (not gifted) game pass is counted once.
]]
function Module._updateGamePassRobuxSpent(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Updating ]]

	--- @param _gamepassData Marketplace_GamePassesTableEntry
	for gamepassName: string, _gamepassData in pairs(gamepasses) do
		--[[ Checks ]]

		-- Player does not really own the gamePass (gifts don't count)
		if not I.G_Marketplace.PlayerOwnsGamePass(player, gamepassName, false, false) then
			continue
		end

		-- The cost is already added
		if table.find(moduleData.GamePassRobuxSpentCalculatedFor, gamepassName) then
			continue
		end

		--[[ Getting Price ]]

		local price: number = tonumber(I.G_Marketplace.GetProductPrice(gamepassName, Enum.InfoType.GamePass, false)) or 0
		if price <= 0 then
			continue
		end

		-- Skip it if an overlapping update counted it during the yields
		if table.find(moduleData.GamePassRobuxSpentCalculatedFor, gamepassName) then
			continue
		end

		--[[ Updating ]]

		moduleData.GamePassRobuxSpent += price
		table.insert(moduleData.GamePassRobuxSpentCalculatedFor, gamepassName)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gift Control

--%%%%%%%%%%%%%%%%%%%% Gift GamePass

--[[
	**SERVER** |
    Gifts player a GamePass.
	The purchase-succeeded Topic it publishes runs the rewards and replicates the gift.
]]
--- @return boolean
function Module.Gift(player: Player, gamepassName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Checks ]]

	-- Check if the game pass exists
	if not gamepasses[gamepassName] then
		return false
	end

	--[[ Gifting ]]

	-- Gift it unless it was already gifted
	if not table.find(moduleData.GiftedGamePasses, gamepassName) then
		table.insert(moduleData.GiftedGamePasses, gamepassName)
	else
		return false
	end

	--[[ Updating ]]

	-- General
	I.Network.Fire("Marketplace_GamePassPurchaseSucceeded", player, gamepassName)
	I.Topic.Publish("Marketplace_GamePassPurchaseSucceeded", player, gamepassName)

	-- Individual
	I.Network.Fire(`Marketplace_GamePassPurchaseSucceeded-{gamepassName}`, player)
	I.Topic.Publish(`Marketplace_GamePassPurchaseSucceeded-{gamepassName}`, player)

	return true
end

--%%%%%%%%%%%%%%%%%%%% Gift All

--[[
	**SERVER** |
    Gifts all GamePasses to a player.
	Each newly gifted pass publishes the purchase-succeeded Topic, which runs its rewards and replicates the gift.
]]
--- @return boolean
--- @return { string }
function Module.GiftAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Gifting ]]

	local gifted = {} --- @type { string }

	--- @param _gamepassData Marketplace_GamePassesTableEntry
	for gamepassName: string, _gamepassData in pairs(gamepasses) do
		-- Skip passes that were already gifted
		if table.find(moduleData.GiftedGamePasses, gamepassName) then
			continue
		end

		--[[ Saving ]]

		table.insert(moduleData.GiftedGamePasses, gamepassName)
		table.insert(gifted, gamepassName)

		--[[ Updating ]]

		-- General
		I.Network.Fire("Marketplace_GamePassPurchaseSucceeded", player, gamepassName)
		I.Topic.Publish("Marketplace_GamePassPurchaseSucceeded", player, gamepassName)

		-- Individual
		I.Network.Fire(`Marketplace_GamePassPurchaseSucceeded-{gamepassName}`, player)
		I.Topic.Publish(`Marketplace_GamePassPurchaseSucceeded-{gamepassName}`, player)
	end

	--[[ Returning ]]

	return true, gifted
end

--%%%%%%%%%%%%%%%%%%%% Clear Gift

--[[
	**SERVER** |
    Removes GamePass that was gifted to a player.
]]
--- @return boolean
function Module.ClearGift(player: Player, gamepassName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	local giftId: number? = table.find(moduleData.GiftedGamePasses, gamepassName)

	--[[ Checks ]]

	-- Check if the pass was gifted
	if not giftId then
		return false
	end

	--[[ Gift Clearing ]]

	table.remove(moduleData.GiftedGamePasses, giftId)
	task.spawn(Module._replicateGamePass, player, gamepassName)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Clear All Gifts

--[[
	**SERVER** |
	Removes all GamePasses that were gifted to a player.
]]
--- @return boolean
--- @return { string }
function Module.ClearAllGifts(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Gift Clearing ]]

	local cleared = I.Table.DeepCopy(moduleData.GiftedGamePasses) --- @type { string }
	table.clear(moduleData.GiftedGamePasses)

	--[[ Replicating ]]

	for _index: number, gamepassName: string in ipairs(cleared) do
		task.spawn(Module._replicateGamePass, player, gamepassName)
	end

	--[[ Returning ]]

	return true, cleared
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Gifted

--[[
	**SERVER** |
    Returns a boolean that indicates if a GamePass is gifted.
]]
--- @return boolean
function Module.IsGifted(player: Player, gamepassName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Returning ]]

	return table.find(moduleData.GiftedGamePasses, `{gamepassName}`) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get Gifted

--[[
	**SERVER** |
    Returns list of all gifted GamePasses for given player.
]]
--- @return boolean
--- @return { string }
function Module.GetGifted(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Marketplace"]

	--[[ Returning ]]

	return true, I.Table.DeepCopy(moduleData.GiftedGamePasses)
end

return Module
