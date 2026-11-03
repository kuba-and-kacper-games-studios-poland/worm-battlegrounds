--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

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

--- @class Limited_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function rewardPurchase(player: Player, limitedId: string, ignoreGlobalLimit: boolean?, ignorePlayerLimit: boolean?, ignoreBoughtIncrement: boolean?)
		--[[ Checks ]]

		if not I.G_Limited.Data[limitedId] then
			return false, `Invalid LimitedId: $|cr$|{limitedId}#|`
		end

		--[[ Defaults ]]

		if ignoreGlobalLimit == nil then
			ignoreGlobalLimit = true
		end
		if ignorePlayerLimit == nil then
			ignorePlayerLimit = true
		end
		if ignoreBoughtIncrement == nil then
			ignoreBoughtIncrement = true
		end

		--[[ Executing ]]

		local value: boolean = I.Limited.RewardPurchase(player, limitedId, ignoreGlobalLimit, ignorePlayerLimit, ignoreBoughtIncrement)

		if value then
			return true, `Rewarded $|cr$|{limitedId}#| purchase to $|cr$|{player.Name}#|`
		else
			return false, `Failed to reward $|cr$|{limitedId}#| purchase to $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function canPurchase(player: Player, limitedId: string)
		--[[ Checks ]]

		if not I.G_Limited.Data[limitedId] then
			return false, `Invalid LimitedId: $|cr$|{limitedId}#|`
		end

		--[[ Executing ]]

		local value: boolean = I.Limited.CanPurchase(player, limitedId)

		if value then
			return true, `$|cr$|{player.Name}#| can purchase $|cr$|{limitedId}#|`
		else
			return true, `$|cr$|{player.Name}#| cannot purchase $|cr$|{limitedId}#|`
		end
	end

	local function hasBought(player: Player, limitedId: string)
		--[[ Checks ]]

		if not I.G_Limited.Data[limitedId] then
			return false, `Invalid LimitedId: $|cr$|{limitedId}#|`
		end

		--[[ Executing ]]

		local value: number = I.Limited.HasBought(player, limitedId)

		return true, `$|cr$|{player.Name}#| has bought $|cr$|{limitedId}#| $|cr$|{value}#| time(s)`
	end

	local function getRemaining(limitedId: string)
		--[[ Checks ]]

		if not I.G_Limited.Data[limitedId] then
			return false, `Invalid LimitedId: $|cr$|{limitedId}#|`
		end

		--[[ Executing ]]

		local value: number = I.Limited.GetRemaining(limitedId)

		return true, `$|cr$|{limitedId}#| has $|cr$|{value}#| remaining globally`
	end

	local function getRemainingPurchases(player: Player, limitedId: string)
		--[[ Checks ]]

		if not I.G_Limited.Data[limitedId] then
			return false, `Invalid LimitedId: $|cr$|{limitedId}#|`
		end

		--[[ Executing ]]

		local value: number = I.Limited.GetRemainingPurchases(player, limitedId)

		if value == -1 then
			return true, `$|cr$|{player.Name}#| has unlimited remaining purchases of $|cr$|{limitedId}#|`
		end

		return true, `$|cr$|{player.Name}#| has $|cr$|{value}#| remaining purchase(s) of $|cr$|{limitedId}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "reward_purchase" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "limitedId", types = { "string" }, dict = "Limited_LimitedIds", requireDict = true },
				{ name = "ignoreGlobalLimit", types = { "boolean" }, optional = true },
				{ name = "ignorePlayerLimit", types = { "boolean" }, optional = true },
				{ name = "ignoreBoughtIncrement", types = { "boolean" }, optional = true },
			},
			Callback = rewardPurchase,
		},

		--[[ Methods ]]

		{
			Aliases = { "can_purchase" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "limitedId", types = { "string" }, dict = "Limited_LimitedIds", requireDict = true },
			},
			Callback = canPurchase,
		},
		{
			Aliases = { "has_bought" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "limitedId", types = { "string" }, dict = "Limited_LimitedIds", requireDict = true },
			},
			Callback = hasBought,
		},
		{
			Aliases = { "get_remaining" },
			Args = {
				{ name = "limitedId", types = { "string" }, dict = "Limited_LimitedIds", requireDict = true },
			},
			Callback = getRemaining,
		},
		{
			Aliases = { "get_remaining_purchases" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "limitedId", types = { "string" }, dict = "Limited_LimitedIds", requireDict = true },
			},
			Callback = getRemainingPurchases,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Limited_Server", {
		Aliases = { "limited" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allLimitedIds = {} --- @type { string }

	--- @param _limitedData Limited_LimitedData
	for limitedId: string, _limitedData in pairs(I.G_Limited.Data) do
		table.insert(allLimitedIds, limitedId)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Limited_LimitedIds`, allLimitedIds, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
