--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Settings

--- @type Currency_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Currency_CommandBar_Server
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

	local function add(player: Player, currencyName: string, amount: string, spawnOrbs: boolean?)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		local amountBN = I.BN.new(amount)
		if amountBN < zeroBN then
			return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Currency.Add(player, currencyName, amount, spawnOrbs)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			if spawnOrbs then
				return true, `Added $|cr$|{formattedAmount}#| $|cr$|{currencyName}#| to $|cr$|{player.Name}#|'s Currency with orbs`
			else
				return true, `Added $|cr$|{formattedAmount}#| $|cr$|{currencyName}#| to $|cr$|{player.Name}#|'s Currency`
			end
		else
			return false, `Failed to add $|cr$|{formattedAmount}#| $|cr$|{currencyName}#| to $|cr$|{player.Name}#|'s Currency`
		end
	end

	local function subtract(player: Player, currencyName: string, amount: string)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		local amountBN = I.BN.new(amount)
		if amountBN < zeroBN then
			return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Currency.Subtract(player, currencyName, amount)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			return true, `Subtracted $|cr$|{formattedAmount}#| $|cr$|{currencyName}#| from $|cr$|{player.Name}#|'s Currency`
		else
			return false, `Failed to subtract $|cr$|{formattedAmount}#| $|cr$|{currencyName}#| from $|cr$|{player.Name}#|'s Currency`
		end
	end

	local function set(player: Player, currencyName: string, amount: string)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		local amountBN = I.BN.new(amount)

		-- MinValue Check
		if _settings.CURRENCIES[currencyName].RespectMinValue then
			local minBN = I.BN.new(_settings.CURRENCIES[currencyName].MinValue)
			if minBN > amountBN then
				return false, `Invalid Amount: $|cr$|{amount}#| cannot be less than $|cr$|{_settings.CURRENCIES[currencyName].MinValue}#|`
			end
		end

		-- MaxValue Check
		if _settings.CURRENCIES[currencyName].RespectMaxValue then
			local maxBN = I.BN.new(_settings.CURRENCIES[currencyName].MaxValue)
			if amountBN > maxBN then
				return false, `Invalid Amount: $|cr$|{amount}#| cannot be greater than $|cr$|{_settings.CURRENCIES[currencyName].MaxValue}#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Currency.Set(player, currencyName, amount)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			return true, `Set $|cr$|{player.Name}#|'s $|cr$|{currencyName}#| to $|cr$|{formattedAmount}#|`
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s $|cr$|{currencyName}#| to $|cr$|{formattedAmount}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function get(player: Player, currencyName: string, formatting: string?)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.Currency.Get(player, currencyName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#| has $|cr$|{value}#| $|cr$|{currencyName}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s $|cr$|{currencyName}#|`
		end
	end

	local function getTotal(player: Player, currencyName: string, formatting: string?)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.Currency.GetTotal(player, currencyName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#| has earned $|cr$|{value}#| total $|cr$|{currencyName}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s total $|cr$|{currencyName}#|`
		end
	end

	local function getAll(player: Player, formatting: string?)
		-- Getting value
		local value: table = I.Currency.GetAll(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s Currency data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Currency data`
		end
	end

	local function getAllTotal(player: Player, formatting: string?)
		-- Getting value
		local value: table = I.Currency.GetAllTotal(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s total Currency data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s total Currency data`
		end
	end

	local function getTotalSpent(player: Player, currencyName: string, formatting: string?)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.Currency.GetTotalSpent(player, currencyName)

		-- Returning
		if value then
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#| has spent $|cr$|{value}#| $|cr$|{currencyName}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s spent $|cr$|{currencyName}#|`
		end
	end

	local function getHighestOwned(player: Player, currencyName: string, formatting: string?)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.Currency.GetHighestOwned(player, currencyName)

		-- Returning
		if value then
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#|'s highest owned $|cr$|{currencyName}#| is $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s highest owned $|cr$|{currencyName}#|`
		end
	end

	local function getAllTotalSpent(player: Player, formatting: string?)
		-- Getting value
		local value: table = I.Currency.GetAllTotalSpent(player)

		-- Returning
		if value then
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s spent Currency data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s spent Currency data`
		end
	end

	local function getAllTotalOwned(player: Player, formatting: string?)
		-- Getting value
		local value: table = I.Currency.GetAllTotalOwned(player)

		-- Returning
		if value then
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s highest owned Currency data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s highest owned Currency data`
		end
	end

	local function hasEnough(player: Player, currencyName: string, amount: string)
		--[[ Checks ]]

		if not _settings.CURRENCIES[currencyName] then
			return false, `Invalid CurrencyName: $|cr$|{currencyName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Currency.HasEnough(player, currencyName, amount)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| has enough $|cr$|{currencyName}#| ($|cr$|{formattedAmount}#|)`
		else
			return true, `$|cr$|{player.Name}#| does not have enough $|cr$|{currencyName}#| ($|cr$|{formattedAmount}#|)`
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
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
				{ name = "spawnOrbs", types = { "boolean" }, optional = true },
			},
			Callback = add,
		},
		{
			Aliases = { "subtract" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
			},
			Callback = subtract,
		},
		{
			Aliases = { "set" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
			},
			Callback = set,
		},

		--[[ Methods ]]

		{
			Aliases = { "get" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = get,
		},
		{
			Aliases = { "get_total" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getTotal,
		},

		{
			Aliases = { "get_all" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getAll,
		},
		{
			Aliases = { "get_all_total" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getAllTotal,
		},
		{
			Aliases = { "get_total_spent" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getTotalSpent,
		},
		{
			Aliases = { "get_highest_owned" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getHighestOwned,
		},
		{
			Aliases = { "get_all_total_spent" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getAllTotalSpent,
		},
		{
			Aliases = { "get_all_total_owned" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
			},
			Callback = getAllTotalOwned,
		},
		{
			Aliases = { "has_enough" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "currencyName", types = { "string" }, dict = "Currency_CurrencyNames", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
			},
			Callback = hasEnough,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Currency_Server", {
		Aliases = { "currency" },
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

	local allCurrencyNames = {} --- @type { string }

	--- @param _currencyData Currency_CurrencySettings
	for currencyName: string, _currencyData in pairs(_settings.CURRENCIES) do
		table.insert(allCurrencyNames, currencyName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Currency_CurrencyNames`, allCurrencyNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
