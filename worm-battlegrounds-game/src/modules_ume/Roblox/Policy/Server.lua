--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Policy"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local PolicyService = I.S.PolicyService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Loading ]]

local LOAD_ATTEMPTS: number = 4

--[[ Defaults ]]

--- @type Policy_PlayerPolicy
local DEFAULTS = {

	--[[ Links ]]

	AllowedExternalLinkReferences = {},

	--[[ Permissions ]]

	AreAdsAllowed = false,
	IsContentSharingAllowed = false,
	IsEligibleToPurchaseCommerceProduct = false,
	IsEligibleToPurchaseSubscription = false,
	IsPaidItemTradingAllowed = false,

	--[[ Restrictions ]]

	ArePaidRandomItemsRestricted = true,
	IsSubjectToChinaPolicies = true,
}

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

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Policy"] = {
		PlayerPolicy = {}, --- @type Policy_PlayerPolicy
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)
	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module._savePoliciesForPlayer)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Policy_Loaded", { "Player" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Policy = {

		--[[ Methods ]]

		GetAll = Module.GetAll,
		GetAllowedExternalLinkReferences = Module.GetAllowedExternalLinkReferences,
		GetAreAdsAllowed = Module.GetAreAdsAllowed,
		GetArePaidRandomItemsRestricted = Module.GetArePaidRandomItemsRestricted,
		GetIsContentSharingAllowed = Module.GetIsContentSharingAllowed,
		GetIsEligibleToPurchaseCommerceProduct = Module.GetIsEligibleToPurchaseCommerceProduct,
		GetIsEligibleToPurchaseSubscription = Module.GetIsEligibleToPurchaseSubscription,
		GetIsPaidItemTradingAllowed = Module.GetIsPaidItemTradingAllowed,
		GetIsSubjectToChinaPolicies = Module.GetIsSubjectToChinaPolicies,
		IsLoaded = Module.IsLoaded,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates the player's Policy folder in their replicator, filled with the fail-safe defaults.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Replicating ]]

	Module._replicatePolicy(player, DEFAULTS)
end

--%%%%%%%%%%%%%%%%%%%% Save Policies For Player

--[[
	Loads the player's policies, retrying with a growing wait between attempts.
	Then saves, replicates and publishes them.
]]
function Module._savePoliciesForPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	task.spawn(function()
		--[[ Getting Policy ]]

		local success: boolean = false
		local result: any | string?

		for attempt: number = 1, LOAD_ATTEMPTS do
			success, result = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)

			-- Stop when it loaded, after the last attempt, or when the player left
			if success or attempt == LOAD_ATTEMPTS or not I.Player.Valid(player) then
				break
			end

			-- Wait 1, 2, then 4 seconds between attempts
			task.wait(2 ^ (attempt - 1))
		end

		--[[ Checks ]]

		-- Check if the player is still valid
		if not I.Player.Valid(player) then
			return
		end

		-- Check if the policy loaded
		if not success or type(result) ~= "table" then
			warn(`[{_localName}::{script.Name}]: Failed to load the policy for ({player.Name}) after {LOAD_ATTEMPTS} attempts! - ({result})`)
			return
		end

		--[[ Data ]]

		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		local moduleSessionData = sessionData["Policy"]

		--- @type Policy_PlayerPolicy
		local playerPolicy = result

		--[[ Saving ]]

		moduleSessionData.PlayerPolicy = playerPolicy

		--[[ Replicating ]]

		Module._replicatePolicy(player, playerPolicy)

		--[[ Publishing ]]

		I.Topic.Publish("Policy_Loaded", player)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Replicate Policy

--[[
	Writes every policy field onto the player's Policy folder, the default for a missing field.
]]
--- @param policy Policy_PlayerPolicy
function Module._replicatePolicy(player: Player, policy)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Replicating ]]

	--- @param default boolean | { string }
	for key: string, default in pairs(DEFAULTS) do
		--[[ Value ]]

		--- @type boolean | { string }
		local value = policy[key]

		-- Use the default for a missing field
		if value == nil then
			value = default
		end

		--[[ Setting ]]

		-- Encode the list, attributes can't hold tables
		if type(value) == "table" then
			I.Replicator.Set(player, _localName, key, I.S.HttpService:JSONEncode(value))
			continue
		end

		I.Replicator.Set(player, _localName, key, value)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	**SERVER** |
	Returns all loaded policies for the player.
]]
--- @return Policy_PlayerPolicy?
function Module.GetAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Policy"]

	--[[ Returning ]]

	if next(moduleSessionData.PlayerPolicy) then
		return moduleSessionData.PlayerPolicy
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Allowed External Link References

--[[
	**SERVER** |
	Returns all allowed external link references for the player, none until the policy has loaded.
]]
--- @return { string }
function Module.GetAllowedExternalLinkReferences(player: Player)
	return Module._get(player, "AllowedExternalLinkReferences")
end

--%%%%%%%%%%%%%%%%%%%% Get Are Ads Allowed

--[[
	**SERVER** |
	Returns state of the `AreAdsAllowed` policy for the player, `false` until the policy has loaded.
]]
--- @return boolean
function Module.GetAreAdsAllowed(player: Player)
	return Module._get(player, "AreAdsAllowed")
end

--%%%%%%%%%%%%%%%%%%%% Get Are Paid Random Items Restricted

--[[
	**SERVER** |
	Returns state of the `ArePaidRandomItemsRestricted` policy for the player, `true` until the policy has loaded.
]]
--- @return boolean
function Module.GetArePaidRandomItemsRestricted(player: Player)
	return Module._get(player, "ArePaidRandomItemsRestricted")
end

--%%%%%%%%%%%%%%%%%%%% Get Is Content Sharing Allowed

--[[
	**SERVER** |
	Returns state of the `IsContentSharingAllowed` policy for the player, `false` until the policy has loaded.
]]
--- @return boolean
function Module.GetIsContentSharingAllowed(player: Player)
	return Module._get(player, "IsContentSharingAllowed")
end

--%%%%%%%%%%%%%%%%%%%% Get Is Eligible To Purchase Commerce Product

--[[
	**SERVER** |
	Returns state of the `IsEligibleToPurchaseCommerceProduct` policy for the player, `false` until the policy has loaded.
]]
--- @return boolean
function Module.GetIsEligibleToPurchaseCommerceProduct(player: Player)
	return Module._get(player, "IsEligibleToPurchaseCommerceProduct")
end

--%%%%%%%%%%%%%%%%%%%% Get Is Eligible To Purchase Subscription

--[[
	**SERVER** |
	Returns state of the `IsEligibleToPurchaseSubscription` policy for the player, `false` until the policy has loaded.
]]
--- @return boolean
function Module.GetIsEligibleToPurchaseSubscription(player: Player)
	return Module._get(player, "IsEligibleToPurchaseSubscription")
end

--%%%%%%%%%%%%%%%%%%%% Get Is Paid Item Trading Allowed

--[[
	**SERVER** |
	Returns state of the `IsPaidItemTradingAllowed` policy for the player, `false` until the policy has loaded.
]]
--- @return boolean
function Module.GetIsPaidItemTradingAllowed(player: Player)
	return Module._get(player, "IsPaidItemTradingAllowed")
end

--%%%%%%%%%%%%%%%%%%%% Get Is Subject To China Policies

--[[
	**SERVER** |
	Returns state of the `IsSubjectToChinaPolicies` policy for the player, `true` until the policy has loaded.
]]
--- @return boolean
function Module.GetIsSubjectToChinaPolicies(player: Player)
	return Module._get(player, "IsSubjectToChinaPolicies")
end

--%%%%%%%%%%%%%%%%%%%% Is Loaded

--[[
	**SERVER** |
	Returns whether the player's policy has loaded.
]]
--- @return boolean
function Module.IsLoaded(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Policy"]

	--[[ Returning ]]

	return next(moduleSessionData.PlayerPolicy) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns one field of the player's loaded policy, or its fail-safe default from `DEFAULTS` while it isn't loaded.
]]
--- @return boolean | { string }
function Module._get(player: Player, key: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return DEFAULTS[key]
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Policy"]

	--- @type boolean | { string } | nil
	local value = moduleSessionData.PlayerPolicy[key]

	--[[ Checks ]]

	-- Use the fail-safe default while the field isn't loaded
	if value == nil then
		return DEFAULTS[key]
	end

	--[[ Returning ]]

	return value
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
