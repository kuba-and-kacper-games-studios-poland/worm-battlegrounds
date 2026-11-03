--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Marketplace"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MarketplaceService = I.S.MarketplaceService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [Player]: RBXScriptConnection }
local subscriptionConnections = {}

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

--- @class Marketplace_RobloxPlus_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Default, function(player: Player)
		task.spawn(function()
			Module._connectSubscriptionListener(player)
			Module._update(player)
		end)
	end)

	I.G_Player.OnPlayerRemoving(I.Priority.Default, function(player: Player)
		Module._disconnectSubscriptionListener(player)
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Marketplace_RobloxPlusUpdated", { "Player", "boolean" })

	--- @Network
	I.Network.GetEvent("Marketplace_RobloxPlusUpdated")

	I.Network.GetEvent("Marketplace_PromptRobloxPlusPurchase", { "Player" }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Marketplace_PromptRobloxPlusPurchase", Module.PromptPurchase)

	I.Network.GetFunction("Marketplace_IsRobloxPlus", { "Player" })
	I.Network.OnInvoke("Marketplace_IsRobloxPlus", Module.IsRobloxPlus)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	--[[ Control ]]

	I.Marketplace.RobloxPlus_PromptPurchase = Module.PromptPurchase

	--[[ Methods ]]

	I.Marketplace.RobloxPlus_IsRobloxPlus = Module.IsRobloxPlus
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Subscription Listener

--[[
	Connects a listener that refreshes Roblox Plus state when subscription changes.
]]
function Module._connectSubscriptionListener(player: Player)
	--[[ Resetting ]]

	Module._disconnectSubscriptionListener(player)

	--[[ Connecting ]]

	local ok: boolean, changed: RBXScriptSignal? = pcall(function()
		return player:GetPropertyChangedSignal("HasRobloxSubscription")
	end)
	if not ok or not changed then
		return
	end

	subscriptionConnections[player] = changed:Connect(function()
		Module._update(player)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Disconnect Subscription Listener

--[[
	Disconnects the Roblox Plus subscription listener for the player.
]]
function Module._disconnectSubscriptionListener(player: Player)
	--[[ Disconnecting ]]

	local conn: RBXScriptConnection? = subscriptionConnections[player]
	if conn then
		conn:Disconnect()
		subscriptionConnections[player] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Syncs Roblox Plus state for the player.
]]
function Module._update(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Marketplace"]

	--[[ Updating ]]

	moduleData.IsRobloxPlus = player.HasRobloxSubscription

	I.Topic.Publish("Marketplace_RobloxPlusUpdated", player, moduleData.IsRobloxPlus)
	I.Network.Fire("Marketplace_RobloxPlusUpdated", player, moduleData.IsRobloxPlus)
end

--%%%%%%%%%%%%%%%%%%%% Prompt Purchase

--[[
	**SERVER** |
    Prompts Roblox Plus subscription purchase.
]]
--- @return boolean
function Module.PromptPurchase(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	if Module.IsRobloxPlus(player) then
		return false
	end

	--[[ Prompting ]]

	local success: boolean = pcall(function()
		MarketplaceService:PromptRobloxSubscriptionPurchase(player)
	end)

	return success
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Roblox Plus

--[[
	**SERVER** |
	Returns if the player has Roblox Plus.
]]
--- @return boolean
function Module.IsRobloxPlus(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	return player.HasRobloxSubscription
end

return Module
