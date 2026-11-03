--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Badge"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Badge_Badges
local badgesData = require(I.Dirs.GlobalData.Badge.Badges)

--- @type { string }
local rewardTypes = {
	"Single",
	"Session",
	"Character",
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

--- @class Badge_CommandBar_Server
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

	local function award(player: Player, badgeName: string)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Badge.Award(player, badgeName)

		-- Returning
		if value then
			return true, `Awarded Badge $|cr$|{badgeName}#| to $|cr$|{player.Name}#|`
		else
			return false, `Failed to award Badge $|cr$|{badgeName}#| to $|cr$|{player.Name}#|`
		end
	end

	local function rewardFor(player: Player, badgeName: string, rewardType: string?, forceReward: boolean?)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		if rewardType then
			if not table.find(rewardTypes, rewardType) then
				return false, `Invalid Reward type: $|cr$|{rewardType}#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local success: boolean, value: { string } = I.Badge.RewardFor(player, badgeName, rewardType, forceReward)

		-- Returning
		if success then
			if rewardType then
				return true, {
					`Granting Badge $|cr$|{badgeName}#| $|cr$|{rewardType}#| reward to $|cr$|{player.Name}#|...`,
					`Granted $|cr$|{#value}#| rewards:`,
					value,
					"_multilineOutput",
				}
			else
				return true, {
					`Granting Badge $|cr$|{badgeName}#| rewards to $|cr$|{player.Name}#|...`,
					`Granted $|cr$|{#value}#| rewards:`,
					value,
					"_multilineOutput",
				}
			end
		else
			-- Getting second message
			local owns: boolean = I.G_Badge.Owns(player.UserId, badgeName)
			local returnTable = { "_multilineOutput" }
			if not owns then
				table.insert(returnTable, 1, `$|cr$|{player.Name}#| does not own the Badge $|cr$|{badgeName}#|`)
			end

			-- Returning
			if rewardType then
				table.insert(returnTable, 1, `Failed to grant Badge $|cr$|{badgeName}#| $|cr$|{rewardType}#| reward to $|cr$|{player.Name}#|`)
				return false, returnTable
			else
				table.insert(returnTable, 1, `Failed to grant Badge $|cr$|{badgeName}#| rewards to $|cr$|{player.Name}#|`)
				return false, returnTable
			end
		end
	end

	local function rewardForAll(player: Player, rewardType: string?, forceReward: boolean?)
		--[[ Checks ]]

		if rewardType then
			if not table.find(rewardTypes, rewardType) then
				return false, `Invalid Reward type: $|cr$|{rewardType}#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: table = I.Badge.RewardForAll(player, rewardType, forceReward)

		-- Returning
		if value then
			if next(value) then
				-- Calculating total rewards
				local totalRewardsGranted = 0
				for _badgeName: string, rewardTypes: table in pairs(value) do
					totalRewardsGranted += #rewardTypes
				end

				-- Returning
				if rewardType then
					return true, {
						`Granting all Badge $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#|...`,
						`Granted $|cr$|{totalRewardsGranted}#| rewards:`,
						value,
						"_multilineOutput",
					}
				else
					return true, {
						`Granting all Badge rewards to $|cr$|{player.Name}#|...`,
						`Granted $|cr$|{totalRewardsGranted}#| rewards:`,
						value,
						"_multilineOutput",
					}
				end
			else
				if rewardType then
					return true, `Granting all Badge $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#| succeeded, but no rewards were granted`
				else
					return true, `Granting all Badge rewards to $|cr$|{player.Name}#| succeeded, but no rewards were granted`
				end
			end
		else
			if rewardType then
				return false, `Failed to grant all Badge $|cr$|{rewardType}#| rewards to $|cr$|{player.Name}#|`
			else
				return false, `Failed to grant all Badge rewards to $|cr$|{player.Name}#|`
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Functions

	local function getInfo(badgeName: string)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: table = I.G_Badge.GetInfo(badgeName)

		-- Returning
		if value then
			return true, { `Retrieving Badge $|cr$|{badgeName}#| info...`, value, "_multilineOutput" }
		else
			return false, `Failed to retrieve Badge $|cr$|{badgeName}#| info`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Owns Functions

	local function owns_byPlayer(player: Player, badgeName: string)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.G_Badge.Owns(player.UserId, badgeName)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| owns the Badge $|cr$|{badgeName}#|`
		else
			return true, `$|cr$|{player.Name}#| does $|cr$|not#| own the Badge $|cr$|{badgeName}#|`
		end
	end

	local function owns_byName(playerName: string, badgeName: string)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		--[[ Getting Data ]]

		local success: boolean, playerId: number = pcall(function()
			return Players:GetUserIdFromNameAsync(playerName)
		end)
		if not success or not playerId then
			return false, `Failed to retrieve $|cr$|{playerName}#|'s userId`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.G_Badge.Owns(playerId, badgeName)

		-- Returning
		if value then
			return true, `$|cr$|{playerName}#| owns the Badge $|cr$|{badgeName}#|`
		else
			return true, `$|cr$|{playerName}#| does $|cr$|not#| own the Badge $|cr$|{badgeName}#|`
		end
	end

	local function owns_byId(playerId: number, badgeName: string)
		--[[ Checks ]]

		if not badgesData[badgeName] then
			return false, `Invalid Badge name: $|cr$|{badgeName}#|`
		end

		--[[ Getting Data ]]

		local success: boolean, playerName: string = pcall(function()
			return Players:GetNameFromUserIdAsync(playerId)
		end)
		if not success or not playerName then
			playerName = playerId
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.G_Badge.Owns(playerId, badgeName)

		-- Returning
		if value then
			return true, `$|cr$|{playerName}#| owns the Badge $|cr$|{badgeName}#|`
		else
			return true, `$|cr$|{playerName}#| does $|cr$|not#| own the Badge $|cr$|{badgeName}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "award" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
			},
			Callback = award,
		},
		{
			Aliases = { "reward_for" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
				{ name = "rewardType", types = { "string" }, dict = "Badge_BadgeRewardType", requireDict = true, optional = true },
				{ name = "forceReward", types = { "boolean" }, optional = true },
			},
			Callback = rewardFor,
		},
		{
			Aliases = { "reward_for_all" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "rewardType", types = { "string" }, dict = "Badge_BadgeRewardType", requireDict = true, optional = true },
				{ name = "forceReward", types = { "boolean" }, optional = true },
			},
			Callback = rewardForAll,
		},

		--[[ Get ]]

		{
			Aliases = { "get_info" },
			Args = {
				{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
			},
			Callback = getInfo,
		},

		--[[ Owns ]]

		{
			Aliases = { "owns" },

			Variants = {
				{
					Aliases = { "by_player" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
					},
					Callback = owns_byPlayer,
				},
				{
					Aliases = { "by_name" },
					Args = {
						{ name = "playerName", types = { "string" } },
						{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
					},
					Callback = owns_byName,
				},
				{
					Aliases = { "by_id" },
					Args = {
						{ name = "playerId", types = { "number" } },
						{ name = "badgeName", types = { "string" }, dict = "Badge_BadgeNames", requireDict = true },
					},
					Callback = owns_byId,
				},
			},
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Badge_Server", {
		Aliases = { "badge" },
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

	local allBadgeNames = {} --- @type { string }

	--- @param _badgeData Badge_BadgesTableEntry
	for badgeName: string, _badgeData in pairs(badgesData) do
		table.insert(allBadgeNames, badgeName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Badge_BadgeNames`, allBadgeNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Badge_BadgeRewardType`, rewardTypes, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
