--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

--- @type Limited_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local products = require(I.Dirs.GlobalData.Marketplace.Products) --- @type Marketplace_Products

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

local Stock = require(_scripts:FindFirstChild("Server"):FindFirstChild("Stock")) --- @type Limited_Server_Stock

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local holdMap: MemoryStoreHashMap? = nil
local productLimiteds = {} --- @type { [number]: string }
local heldIds = {} --- @type { [Player]: { [string]: boolean } }

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

--- @class Limited_Server_Hold
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getHoldMap()
	Module._mapProducts()
	Module._createConnections()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Hold Map

--[[
	Gets the MemoryStore hash map that holds copies while purchase prompts are open.
	Without DataStore access, or when it can't be gotten, holds are skipped.
]]
function Module._getHoldMap()
	--[[ Checks ]]

	-- Skip without DataStore access
	if not I.DataStoreAccess then
		return
	end

	--[[ Getting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return I.S.MemoryStoreService:GetHashMap(_settings.HOLD_MAP_NAME)
	end)

	if success then
		holdMap = result
	else
		warn(`[{_localName}::{script.Name}]: Failed while getting the (Limited) hold map! - {result}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Map Products

--[[
	Maps each limited's developer product id to the limited, and warns for a `ProductId` that isn't in the Marketplace products.
]]
function Module._mapProducts()
	--- @param limitedData Limited_LimitedData
	for limitedId: string, limitedData in pairs(I.G_Limited.Data) do
		--[[ Data ]]

		--- @type Marketplace_ProductsTableEntry?
		local productData = products[limitedData.ProductId]

		--[[ Checks ]]

		-- Skip a limited whose product isn't listed
		if not productData then
			warn(`[{_localName}::{script.Name}]: Limited ({limitedId}) names ProductId ({limitedData.ProductId}), which isn't in the Marketplace products!`)
			continue
		end

		-- Skip a product without a real id
		if productData.Id == 0 then
			continue
		end

		--[[ Saving ]]

		productLimiteds[productData.Id] = limitedId
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Releases holds when a purchase prompt closes without a purchase, and when a player leaves.
]]
function Module._createConnections()
	--[[ Connections ]]

	I.S.MarketplaceService.PromptProductPurchaseFinished:Connect(Module._onPromptFinished)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._onPlayerRemoving)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Take

--[[
	Holds one copy of the limited for the player for `HOLD_TIME` seconds, unless every copy left is sold or held by other players.
	Returns true without a hold when holds are off or the MemoryStore fails, since the purchase still checks the stock.
]]
--- @return boolean
function Module.Take(player: Player, limitedId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Skip holds when there is no hold map
	if not holdMap then
		return true
	end

	--[[ Local Variables ]]

	local maximumAmount: number = I.G_Limited.Data[limitedId].MaximumAmount
	local sold: number = Stock.GetSold(limitedId)
	local userKey: string = tostring(player.UserId)
	local granted: boolean = false

	--[[ Holding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return holdMap:UpdateAsync(limitedId, function(holds: any)
			--[[ Local Variables ]]

			local now: number = os.time()
			local activeHolds: number = 0

			-- Decide again on every run, since UpdateAsync reruns the transform after a conflict
			granted = false
			holds = if typeof(holds) == "table" then holds else {}

			--[[ Counting ]]

			for key: string, expiresAt: any in pairs(holds) do
				-- Drop expired holds
				if typeof(expiresAt) ~= "number" or expiresAt <= now then
					holds[key] = nil
					continue
				end

				-- Count holds of other players
				if key ~= userKey then
					activeHolds += 1
				end
			end

			--[[ Checks ]]

			-- Cancel the write when no copy is free
			if sold + activeHolds >= maximumAmount then
				return nil
			end

			--[[ Holding ]]

			holds[userKey] = now + _settings.HOLD_TIME
			granted = true

			return holds
		end, _settings.HOLD_TIME + 60)
	end)

	--[[ Checks ]]

	-- Allow the prompt when the MemoryStore fails
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to hold a copy of ({limitedId}) - prompting without a hold! - {result}`)
		return true
	end

	-- Check if a copy was held
	if not granted then
		return false
	end

	--[[ Saving ]]

	heldIds[player] = heldIds[player] or {}
	heldIds[player][limitedId] = false

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Releases the player's hold on the limited in a new thread, when this session took one.
]]
function Module.Release(player: Player, limitedId: string)
	--[[ Checks ]]

	-- Skip when this session has no hold on the limited
	if not heldIds[player] or heldIds[player][limitedId] == nil then
		return
	end

	--[[ Saving ]]

	heldIds[player][limitedId] = nil

	--[[ Releasing ]]

	task.spawn(Module._releaseHold, player.UserId, limitedId)
end

--%%%%%%%%%%%%%%%%%%%% Release Hold

--[[
	Removes the user's entry from the limited's holds.
]]
function Module._releaseHold(userId: number, limitedId: string)
	--[[ Local Variables ]]

	local userKey: string = tostring(userId)

	--[[ Releasing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return holdMap:UpdateAsync(limitedId, function(holds: any)
			-- Cancel the write when there is nothing to remove
			if typeof(holds) ~= "table" or holds[userKey] == nil then
				return nil
			end

			holds[userKey] = nil
			return holds
		end, _settings.HOLD_TIME + 60)
	end)

	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to release the hold on ({limitedId})! - {result}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Prompt Finished

--[[
	Keeps the hold until the reward when the player bought the limited's product, otherwise releases it.
]]
function Module._onPromptFinished(userId: number, productId: number, isPurchased: boolean)
	--[[ Data ]]

	local limitedId: string? = productLimiteds[productId]
	local player: Player? = I.S.Players:GetPlayerByUserId(userId)

	--[[ Checks ]]

	-- Skip products that aren't limiteds, and players who left
	if not limitedId or not player then
		return
	end

	-- Skip when this session has no hold on the limited
	if not heldIds[player] or heldIds[player][limitedId] == nil then
		return
	end

	--[[ Releasing ]]

	if isPurchased then
		heldIds[player][limitedId] = true
	else
		Module.Release(player, limitedId)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Player Removing

--[[
	Releases the leaving player's holds, except those whose product was bought (they stay until the receipt or `HOLD_TIME`).
]]
function Module._onPlayerRemoving(player: Player)
	--[[ Checks ]]

	-- Skip players without holds
	if not heldIds[player] then
		return
	end

	--[[ Releasing ]]

	for limitedId: string, purchased: boolean in pairs(heldIds[player]) do
		if not purchased then
			task.spawn(Module._releaseHold, player.UserId, limitedId)
		end
	end

	--[[ Saving ]]

	heldIds[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
