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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local pendingPurchases = {} --- @type { [Player]: { [string]: number } }

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

--- @class Limited_Server_Purchase
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._clearPending)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reward Purchase

--[[
	**SERVER** |
	Finalizes a limited purchase: takes one copy from the global stock (never overselling), adds it to the player's
	`Bought` count and runs the limited's `Reward`. Returns false, giving the copy back, when the player left during
	the stock update or the `Reward` errors or returns `false`.
	`ignoreGlobalLimit` skips the global stock, `ignorePlayerLimit` the per-player cap, `ignoreBoughtIncrement` the `Bought + 1` write.
]]
--- @return boolean
function Module.RewardPurchase(player: Player, limitedId: string, ignoreGlobalLimit: boolean?, ignorePlayerLimit: boolean?, ignoreBoughtIncrement: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Limited_LimitedData
	local limitedData = I.G_Limited.Data[limitedId]

	--[[ Checks ]]

	-- Invalid Id
	if not limitedData then
		warn(`[{_localName}::{script.Name}]: ({limitedId}) is not a valid (limitedId)!`)
		return false
	end

	-- Per-player purchase limit
	if not ignorePlayerLimit and Module.GetRemainingPurchases(player, limitedId) == 0 then
		return false
	end

	--[[ Claiming ]]

	local countsBought: boolean = not ignoreBoughtIncrement

	-- Claim the player's slot before the stock update yields
	if countsBought then
		Module._changePending(player, limitedId, 1)
	end

	--[[ Reserving ]]

	local reserved: boolean = false

	if not ignoreGlobalLimit then
		reserved = Stock.Reserve(limitedId)

		-- Stop when no copy could be reserved
		if not reserved then
			if countsBought then
				Module._changePending(player, limitedId, -1)
			end

			Hold.Release(player, limitedId)
			return false
		end
	end

	--[[ Checks ]]

	-- Give the copy back when the player left during the stock update
	if not I.Player.Valid(player) then
		if countsBought then
			Module._changePending(player, limitedId, -1)
		end

		if reserved then
			Stock.Release(limitedId)
		end

		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Limited"]

	--[[ Saving ]]

	if countsBought then
		moduleData.Bought[limitedId] = (moduleData.Bought[limitedId] or 0) + 1
		Module._changePending(player, limitedId, -1)
	end

	--[[ Rewarding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(limitedData.Reward, player)

	-- Undo the purchase when the Reward errors or returns false
	if not success or result == false then
		warn(`[{_localName}::{script.Name}]: Reward for ({limitedId}) failed - giving the copy back! - ({result})`)

		if countsBought then
			local bought: number = moduleData.Bought[limitedId] - 1
			moduleData.Bought[limitedId] = if bought > 0 then bought else nil
		end

		if reserved then
			Stock.Release(limitedId)
		end

		Hold.Release(player, limitedId)
		return false
	end

	--[[ Releasing ]]

	Hold.Release(player, limitedId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Product Requirements

--[[
	**SERVER** |
	The `Requirements` of a limited's developer product: whether the player can buy it now (`CanPurchase`),
	then holds one copy for them while the purchase prompt is open.
]]
--- @return boolean
function Module.ProductRequirements(player: Player, limitedId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the player can buy it now
	if not Module.CanPurchase(player, limitedId) then
		return false
	end

	--[[ Returning ]]

	return Hold.Take(player, limitedId)
end

--%%%%%%%%%%%%%%%%%%%% Change Pending

--[[
	Changes how many purchases of the limited the player has in progress.
]]
function Module._changePending(player: Player, limitedId: string, delta: number)
	--[[ Data ]]

	local playerPending = pendingPurchases[player] --- @type { [string]: number }?

	--[[ Checks ]]

	-- Skip a decrement after the player's entries were cleared
	if not playerPending and delta < 0 then
		return
	end

	--[[ Saving ]]

	if not playerPending then
		playerPending = {}
		pendingPurchases[player] = playerPending
	end

	local count: number = (playerPending[limitedId] or 0) + delta
	playerPending[limitedId] = if count > 0 then count else nil
end

--%%%%%%%%%%%%%%%%%%%% Clear Pending

--[[
	Forgets the leaving player's purchases in progress.
]]
function Module._clearPending(player: Player)
	--[[ Saving ]]

	pendingPurchases[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Can Purchase

--[[
	**SERVER** |
	Returns whether `player` is currently allowed to purchase `limitedId`
	(global stock remaining and per-player `AmountPerPlayer` remaining).
]]
--- @return boolean
function Module.CanPurchase(player: Player, limitedId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Limited_LimitedData
	local limitedData = I.G_Limited.Data[limitedId]

	--[[ Checks ]]

	-- Invalid Id
	if not limitedData then
		return false
	end

	-- Stock not loaded
	if not Stock.IsReady() then
		return false
	end

	-- Stock depleted
	if Stock.GetRemaining(limitedId) == 0 then
		return false
	end

	-- Per-player purchase limit
	if Module.GetRemainingPurchases(player, limitedId) == 0 then
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Has Bought

--[[
	**SERVER** |
	Returns how many copies of `limitedId` the player has bought (0 if none).
]]
--- @return number
function Module.HasBought(player: Player, limitedId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return 0
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Limited"]

	--[[ Returning ]]

	return moduleData.Bought[limitedId] or 0
end

--%%%%%%%%%%%%%%%%%%%% Get Remaining Purchases

--[[
	**SERVER** |
	Returns how many more times `player` can buy `limitedId`, counting purchases in progress.
	`AmountPerPlayer` of `-1` means unlimited and returns `-1`.
]]
--- @return number
function Module.GetRemainingPurchases(player: Player, limitedId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return 0
	end

	--[[ Data ]]

	--- @type Limited_LimitedData
	local limitedData = I.G_Limited.Data[limitedId]

	--[[ Checks ]]

	-- Invalid Id
	if not limitedData then
		return 0
	end

	-- Unlimited per player
	if limitedData.AmountPerPlayer == -1 then
		return -1
	end

	--[[ Local Variables ]]

	local bought: number = Module.HasBought(player, limitedId)
	local pending: number = if pendingPurchases[player] then pendingPurchases[player][limitedId] or 0 else 0

	--[[ Returning ]]

	return math.max(0, limitedData.AmountPerPlayer - bought - pending)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
