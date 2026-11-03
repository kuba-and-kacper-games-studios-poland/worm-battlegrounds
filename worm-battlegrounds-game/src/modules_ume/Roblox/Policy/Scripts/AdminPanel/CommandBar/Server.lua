--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Policy"

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

--- @class Policy_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function get(player: Player)
		--[[ Executing ]]

		-- Getting value
		--- @type Policy_PlayerPolicy?
		local value = I.Policy.GetAll(player)

		--[[ Returning ]]

		if value then
			return true, { `Retrieving $|cr$|{player.Name}#|'s policies...`, value, "_multilineOutput" }
		else
			return false, `$|cr$|{player.Name}#|'s policies have not loaded yet`
		end
	end

	local function getAllowedExternalLinkReferences(player: Player)
		-- Getting value
		local value: { string } = I.Policy.GetAllowedExternalLinkReferences(player)

		-- Returning
		if value ~= nil then
			return true, { `Retrieving $|cr$|{player.Name}#|'s policy $|cr$|AllowedExternalLinkReferences#|...`, value, "_multilineOutput" }
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|AllowedExternalLinkReferences#|`
		end
	end

	local function getAreAdsAllowed(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetAreAdsAllowed(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|AreAdsAllowed#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|AreAdsAllowed#|`
		end
	end
	local function getArePaidRandomItemsRestricted(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetArePaidRandomItemsRestricted(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|ArePaidRandomItemsRestricted#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|ArePaidRandomItemsRestricted#|`
		end
	end
	local function getIsContentSharingAllowed(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetIsContentSharingAllowed(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|IsContentSharingAllowed#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|IsContentSharingAllowed#|`
		end
	end
	local function getIsEligibleToPurchaseCommerceProduct(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetIsEligibleToPurchaseCommerceProduct(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|IsEligibleToPurchaseCommerceProduct#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|IsEligibleToPurchaseCommerceProduct#|`
		end
	end
	local function getIsEligibleToPurchaseSubscription(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetIsEligibleToPurchaseSubscription(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|IsEligibleToPurchaseSubscription#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|IsEligibleToPurchaseSubscription#|`
		end
	end
	local function getIsPaidItemTradingAllowed(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetIsPaidItemTradingAllowed(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|IsPaidItemTradingAllowed#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|IsPaidItemTradingAllowed#|`
		end
	end
	local function getIsSubjectToChinaPolicies(player: Player)
		-- Getting value
		local value: boolean = I.Policy.GetIsSubjectToChinaPolicies(player)

		-- Returning
		if value ~= nil then
			return true, `$|cr$|{player.Name}#|'s $|cr$|IsSubjectToChinaPolicies#| policy is: $|cr$|{value}#|`
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s policy $|cr$|IsSubjectToChinaPolicies#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "get" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = get,

			Variants = {
				{
					Aliases = { "get_allowed_external_link_references" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getAllowedExternalLinkReferences,
				},
				{
					Aliases = { "get_are_ads_allowed" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getAreAdsAllowed,
				},
				{
					Aliases = { "get_are_paid_random_items_restricted" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getArePaidRandomItemsRestricted,
				},
				{
					Aliases = { "get_is_content_sharing_allowed" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getIsContentSharingAllowed,
				},
				{
					Aliases = { "get_is_eligible_to_purchase_commerce_product" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getIsEligibleToPurchaseCommerceProduct,
				},
				{
					Aliases = { "get_is_eligible_to_purchase_subscription" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getIsEligibleToPurchaseSubscription,
				},
				{
					Aliases = { "get_is_paid_item_trading_allowed" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getIsPaidItemTradingAllowed,
				},
				{
					Aliases = { "get_is_subject_to_china_policies" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getIsSubjectToChinaPolicies,
				},
			},
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Policy_Server", {
		Aliases = { "policy" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
