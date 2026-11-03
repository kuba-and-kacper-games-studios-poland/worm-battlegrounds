--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Statistic"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Statistic_Statistics
local statisticsData = require(I.Dirs.GlobalData.Statistic.Statistic)

--[[ BigNum ]]

local zeroBN = I.BN.new("0")

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

--- @class Statistic_CommandBar_Server
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

	local function add(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
		--[[ Checks ]]

		if not statisticsData[statisticName] then
			return false, `Invalid Statistic name: $|cr$|{statisticName}#|`
		end

		local amountBN = I.BN.new(amount)
		if amountBN < zeroBN then
			return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Statistic.Add(player, statisticName, amount, sensitiveCap == true)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string = I.Format.Text(I.Statistic.Get(player, statisticName))
			local formattedAmount: string = I.Format.Text(amount)

			return true, `Added $|cr$|{formattedAmount}#| to $|cr$|{statisticName}#| for $|cr$|{player.Name}#|. New total: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to update $|cr$|{statisticName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function subtract(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
		--[[ Checks ]]

		if not statisticsData[statisticName] then
			return false, `Invalid Statistic name: $|cr$|{statisticName}#|`
		end

		local amountBN = I.BN.new(amount)
		if amountBN < zeroBN then
			return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Statistic.Subtract(player, statisticName, amount, sensitiveCap == true)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string = I.Format.Text(I.Statistic.Get(player, statisticName))
			local formattedAmount: string = I.Format.Text(amount)

			return true, `Subtracted $|cr$|{formattedAmount}#| from $|cr$|{statisticName}#| for $|cr$|{player.Name}#|. New total: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to update $|cr$|{statisticName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function set(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
		--[[ Checks ]]

		if not statisticsData[statisticName] then
			return false, `Invalid Statistic name: $|cr$|{statisticName}#|`
		end

		local amountBN = I.BN.new(amount)
		if amountBN < zeroBN then
			return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Statistic.Set(player, statisticName, amount, sensitiveCap == true)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string = I.Format.Text(I.Statistic.Get(player, statisticName))

			return true, `Set $|cr$|{statisticName}#| for $|cr$|{player.Name}#| to $|cr$|{formattedValue}#|`
		else
			return false, `Failed to update $|cr$|{statisticName}#| for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function get(player: Player, statisticName: string, formatting: string?)
		--[[ Checks ]]

		if not statisticsData[statisticName] then
			return false, `Invalid Statistic name: $|cr$|{statisticName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string | nil = I.Statistic.Get(player, statisticName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `Statistic $|cr$|{statisticName}#| for $|cr$|{player.Name}#| is: $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{statisticName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function getAll(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Statistic.GetAll(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting statistics for $|cr$|{player.Name}#|...`, value, "_multilineOutput" }
		else
			return false, `Failed to get for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		--[[ Control ]]

		{

			Aliases = { "add" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "statName", types = { "string" }, dict = "Statistic_StatisticNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
				{ name = "sensitiveCap", types = { "boolean" }, optional = true },
			},
			Callback = add,
		},
		{

			Aliases = { "subtract" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "statName", types = { "string" }, dict = "Statistic_StatisticNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
				{ name = "sensitiveCap", types = { "boolean" }, optional = true },
			},
			Callback = subtract,
		},
		{

			Aliases = { "set" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "statName", types = { "string" }, dict = "Statistic_StatisticNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
				{ name = "sensitiveCap", types = { "boolean" }, optional = true },
			},
			Callback = set,
		},

		--[[ Methods ]]

		{
			Aliases = { "get" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "statName", types = { "string" }, dict = "Statistic_StatisticNames", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = get,
		},
		{
			Aliases = { "getAll" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getAll,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Statistic_Server", {
		Aliases = { "statistic" },
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

	local allStatNames = {} --- @type { string }

	--- @param statisticData Statistic_Statistic
	for name: string, _statisticData in pairs(statisticsData) do
		table.insert(allStatNames, name)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Statistic_StatisticNames`, allStatNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
