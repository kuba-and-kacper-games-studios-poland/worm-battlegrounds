--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--- @type Currency_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Currency"] = {
		Currencies = {}, --- @type { [string]: Currency_CurrencyData }
	}

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		_pt["Currency"]["Currencies"][currencyName] = {
			Amount = currencyData.DefaultValue,
			TotalEarned = "0",
			TotalSpent = "0",
			HighestOwned = currencyData.DefaultValue,
		} --- @type Currency_CurrencyData
	end

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._validateCurrencies()
	Module._createIndividualTopics()

	I.G_Player.OnPlayerAdded(I.Priority.Data, Module._validatePlayerCurrencies)
	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Currency_Changed", { "Player", "string", "string", "string", "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Currency = {

		--[[ Control ]]

		Add = Module.Add,
		Subtract = Module.Subtract,
		Set = Module.Set,

		--[[ Methods ]]

		Get = Module.Get,
		GetTotal = Module.GetTotal,
		GetTotalSpent = Module.GetTotalSpent,
		GetHighestOwned = Module.GetHighestOwned,

		GetAll = Module.GetAll,
		GetAllTotal = Module.GetAllTotal,
		GetAllTotalSpent = Module.GetAllTotalSpent,
		GetAllTotalOwned = Module.GetAllTotalOwned,

		HasEnough = Module.HasEnough,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Validate Currencies

--[[
	Runs several checks to ensure currencies are set up correctly. 
]]
function Module._validateCurrencies()
	--[[ Checks ]]

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		--[[ Creating BigNums ]]

		local defBN = I.BN.new(currencyData.DefaultValue)
		local minBN = I.BN.new(currencyData.MinValue)
		local maxBN = I.BN.new(currencyData.MaxValue)

		--[[ Default Value Checks ]]

		-- Min Max Check
		if currencyData.RespectMinValue and currencyData.RespectMaxValue then
			if minBN > maxBN then
				warn(`[{_localName}::{script.Name}]: [{currencyName}] - Minimum Value ({currencyData.MinValue}) is greater than the Maximum Value ({currencyData.MaxValue})!`)
			end
		end

		-- Check MinValue
		if minBN > defBN and currencyData.RespectMinValue then
			warn(`[{_localName}::{script.Name}]: [{currencyName}] - Default Value ({currencyData.DefaultValue}) is smaller than Minimum Value ({currencyData.MinValue})!`)
			currencyData.DefaultValue = currencyData.MinValue
		end

		-- Check MaxValue
		if defBN > maxBN and currencyData.RespectMaxValue then
			warn(`[{_localName}::{script.Name}]: [{currencyName}] - Default Value ({currencyData.DefaultValue}) is greater than Maximum Value ({currencyData.MaxValue})!`)
			currencyData.DefaultValue = currencyData.MaxValue
		end

		--[[ Range Check ]]

		-- Check if the range between Min and Max is valid
		if currencyData.RespectMinValue and currencyData.RespectMaxValue then
			if minBN > maxBN then
				warn(`[{_localName}::{script.Name}]: [{currencyName}] - Minimum Value ({currencyData.MinValue}) is greater than Maximum Value ({currencyData.MaxValue})!`)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Individual Topics

--[[
	Creates individual Topics for each currency. 
]]
function Module._createIndividualTopics()
	--[[ Registering ]]

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		-- Register only when ServerUpdateIndividual is on
		if currencyData.ServerUpdateIndividual then
			I.Topic.Register(`Currency_Changed-{currencyName}`, { "Player", "string", "string", "string" })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Validate Player Currencies

--[[
	Makes sure that all player currencies are in a valid format and range. 
]]
function Module._validatePlayerCurrencies(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	-- Check if the currencies table exists
	if type(moduleData["Currencies"]) ~= "table" then
		moduleData["Currencies"] = {}
	end

	--[[ Validating ]]

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		--- @type Currency_CurrencyData
		local currency = moduleData["Currencies"][currencyName]

		--[[ Creating ]]

		-- Create a missing currency entry
		if type(currency) ~= "table" then
			currency = {
				Amount = currencyData.DefaultValue,
				TotalEarned = "0",
				TotalSpent = "0",
				HighestOwned = currencyData.DefaultValue,
			} --- @type Currency_CurrencyData
			moduleData["Currencies"][currencyName] = currency
		end

		--[[ General Checks ]]

		local fieldDefaults = {
			Amount = currencyData.DefaultValue,
			TotalEarned = "0",
			TotalSpent = "0",
			HighestOwned = currencyData.DefaultValue,
		} --- @type Currency_CurrencyData
		for fieldName: string, defaultValue: string in pairs(fieldDefaults) do
			local savedNumber: number? = tonumber(currency[fieldName])

			-- Keep a whole number saved as a Lua number or a scientific string, written as an integer string
			if type(currency[fieldName]) ~= "string" or not I.Number.IsIntegerString(currency[fieldName]) then
				if savedNumber and savedNumber == savedNumber and math.abs(savedNumber) ~= math.huge and savedNumber % 1 == 0 then
					currency[fieldName] = string.format("%.0f", savedNumber)
					continue
				end
			end

			-- Reset a saved value that isn't an integer string
			if type(currency[fieldName]) ~= "string" or not I.Number.IsIntegerString(currency[fieldName]) then
				-- Warn with the replaced value so it can be recovered
				if currency[fieldName] ~= nil then
					warn(`[{_localName}::{script.Name}]: ({player.Name}) {currencyName}.{fieldName} ({tostring(currency[fieldName])}) is not an integer string - reset to ({defaultValue})!`)
				end
				currency[fieldName] = defaultValue
			end
		end

		--[[ Range Checks ]]

		local amountBN = I.BN.new(currency.Amount) --- @type BigNum_Instance
		local minBN = I.BN.new(currencyData.MinValue) --- @type BigNum_Instance
		local maxBN = I.BN.new(currencyData.MaxValue) --- @type BigNum_Instance

		-- Check MinValue
		if currencyData.RespectMinValue then
			-- Raise to MinValue
			if minBN > amountBN then
				currency.Amount = currencyData.MinValue
				amountBN = minBN
			end
		end

		-- Check MaxValue
		if currencyData.RespectMaxValue then
			-- Cap at MaxValue
			if amountBN > maxBN then
				currency.Amount = currencyData.MaxValue
				amountBN = maxBN
			end
		end

		-- Check HighestOwned
		if amountBN > I.BN.new(currency.HighestOwned) then
			currency.HighestOwned = currency.Amount
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates a `Currency` Folder in the player's Replicator. 
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Creating Attributes ]]

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		-- Mirror only currencies the client follows
		if currencyData.ClientUpdate then
			--- @type Currency_CurrencyData
			local currency = moduleData["Currencies"][currencyName]

			I.Replicator.Set(player, _localName, currencyName, currency.Amount)
			I.Replicator.Set(player, _localName, `{currencyName}-Total`, currency.TotalEarned)
			I.Replicator.Set(player, _localName, `{currencyName}-TotalSpent`, currency.TotalSpent)
			I.Replicator.Set(player, _localName, `{currencyName}-HighestOwned`, currency.HighestOwned)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	**SERVER** |
	Adds currency to the player's account.
]]
--- @return boolean
function Module.Add(player: Player, currencyName: string, amount: string, spawnOrbs: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	-- Check if the currency exists
	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return false
	end

	-- Check if amount is an integer string
	if not I.Number.IsIntegerString(amount) then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	--- @type BigNum_Instance
	local amountBN = I.BN.new(amount)

	-- Check if amount is not negative
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(currency.Amount) --- @type BigNum_Instance
	local finalBN = currentBN + amountBN --- @type BigNum_Instance

	--[[ Capping ]]

	-- Cap at MaxValue when it is respected
	if _settings.CURRENCIES[currencyName].RespectMaxValue then
		--- @type BigNum_Instance
		local maxBN = I.BN.new(_settings.CURRENCIES[currencyName].MaxValue)

		-- Cap the new amount at MaxValue
		if finalBN > maxBN then
			amountBN = maxBN - currentBN
			finalBN = maxBN
		end
	end

	--- @type BigNum_Instance
	local totalFinalBN = I.BN.new(currency.TotalEarned) + amountBN

	--[[ Saving ]]

	currency.Amount = tostring(finalBN)
	currency.TotalEarned = tostring(totalFinalBN)

	-- Raise HighestOwned when the new amount is higher
	if finalBN > I.BN.new(currency.HighestOwned) then
		currency.HighestOwned = currency.Amount
	end

	--[[ Publishing ]]

	-- Mirror the new values when the client follows this currency
	if _settings.CURRENCIES[currencyName].ClientUpdate then
		-- Fly orbs in on the player's slots
		if spawnOrbs then
			I.Replicator.Set(player, _localName, `{currencyName}-SpawnOrbs`, I.Random.Float())
		end
		I.Replicator.Set(player, _localName, currencyName, currency.Amount)
		I.Replicator.Set(player, _localName, `{currencyName}-Total`, currency.TotalEarned)
		I.Replicator.Set(player, _localName, `{currencyName}-HighestOwned`, currency.HighestOwned)
	end

	local delta: string = tostring(finalBN - currentBN)

	-- Publish the server Topic when ServerUpdate is on
	if _settings.CURRENCIES[currencyName].ServerUpdate then
		I.Topic.Publish("Currency_Changed", player, currencyName, amount, currency.Amount, delta)
	end

	-- Publish the currency's own Topic when ServerUpdateIndividual is on
	if _settings.CURRENCIES[currencyName].ServerUpdateIndividual then
		I.Topic.Publish(`Currency_Changed-{currencyName}`, player, amount, currency.Amount, delta)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Subtract

--[[
	**SERVER** |
	Subtracts currency from the player and returns whether the operation succeeded.
]]
--- @return boolean
function Module.Subtract(player: Player, currencyName: string, amount: string, force: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	-- Check if the currency exists
	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return false
	end

	-- Check if amount is an integer string
	if not I.Number.IsIntegerString(amount) then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	--- @type BigNum_Instance
	local amountBN = I.BN.new(amount)

	-- Check if amount is not negative
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	-- Check if the player has enough, unless forced
	if not force then
		if not Module.HasEnough(player, currencyName, amount) then
			return false
		end
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(currency.Amount) --- @type BigNum_Instance
	local finalBN = currentBN - amountBN --- @type BigNum_Instance

	--[[ Capping ]]

	-- Floor at MinValue when it is respected, else at 0
	if _settings.CURRENCIES[currencyName].RespectMinValue then
		--- @type BigNum_Instance
		local minBN = I.BN.new(_settings.CURRENCIES[currencyName].MinValue)

		-- Floor at MinValue
		if finalBN < minBN then
			finalBN = minBN
		end
	else
		-- Floor at 0
		if finalBN < zeroBN then
			finalBN = zeroBN
		end
	end

	-- Never raise the balance, even when it already sits below the floor
	if finalBN > currentBN then
		finalBN = currentBN
	end

	--- @type BigNum_Instance
	local spentBN = currentBN - finalBN

	--[[ Saving ]]

	currency.Amount = tostring(finalBN)
	currency.TotalSpent = tostring(I.BN.new(currency.TotalSpent) + spentBN)

	--[[ Publishing ]]

	-- Mirror the new values when the client follows this currency
	if _settings.CURRENCIES[currencyName].ClientUpdate then
		I.Replicator.Set(player, _localName, currencyName, currency.Amount)
		I.Replicator.Set(player, _localName, `{currencyName}-TotalSpent`, currency.TotalSpent)
	end

	local delta: string = tostring(finalBN - currentBN)

	-- Publish the server Topic when ServerUpdate is on
	if _settings.CURRENCIES[currencyName].ServerUpdate then
		I.Topic.Publish("Currency_Changed", player, currencyName, amount, currency.Amount, delta)
	end

	-- Publish the currency's own Topic when ServerUpdateIndividual is on
	if _settings.CURRENCIES[currencyName].ServerUpdateIndividual then
		I.Topic.Publish(`Currency_Changed-{currencyName}`, player, amount, currency.Amount, delta)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	**SERVER** |
	Sets the player's currency to a specific amount.
]]
--- @return boolean
function Module.Set(player: Player, currencyName: string, amount: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	-- Check if the currency exists
	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return false
	end

	-- Check if amount is an integer string
	if not I.Number.IsIntegerString(amount) then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(currency.Amount) --- @type BigNum_Instance
	local finalBN = I.BN.new(amount) --- @type BigNum_Instance

	--[[ Capping ]]

	-- Rounding to MinValue
	if _settings.CURRENCIES[currencyName].RespectMinValue then
		--- @type BigNum_Instance
		local minBN = I.BN.new(_settings.CURRENCIES[currencyName].MinValue)

		-- Raise to MinValue
		if minBN > finalBN then
			finalBN = minBN
		end
	end

	-- Rounding to MaxValue
	if _settings.CURRENCIES[currencyName].RespectMaxValue then
		--- @type BigNum_Instance
		local maxBN = I.BN.new(_settings.CURRENCIES[currencyName].MaxValue)

		-- Cap at MaxValue
		if finalBN > maxBN then
			finalBN = maxBN
		end
	end

	--- @type BigNum_Instance
	local differenceBN = finalBN - currentBN

	--[[ Saving ]]

	currency.Amount = tostring(finalBN)

	-- Count a raise as earned
	if differenceBN > zeroBN then
		currency.TotalEarned = tostring(I.BN.new(currency.TotalEarned) + differenceBN)
	end

	-- Raise HighestOwned when the new amount is higher
	if finalBN > I.BN.new(currency.HighestOwned) then
		currency.HighestOwned = currency.Amount
	end

	--[[ Publishing ]]

	-- Mirror the new values when the client follows this currency
	if _settings.CURRENCIES[currencyName].ClientUpdate then
		I.Replicator.Set(player, _localName, currencyName, currency.Amount)
		I.Replicator.Set(player, _localName, `{currencyName}-Total`, currency.TotalEarned)
		I.Replicator.Set(player, _localName, `{currencyName}-HighestOwned`, currency.HighestOwned)
	end

	local delta: string = tostring(differenceBN)

	-- Publish the server Topic when ServerUpdate is on
	if _settings.CURRENCIES[currencyName].ServerUpdate then
		I.Topic.Publish("Currency_Changed", player, currencyName, amount, currency.Amount, delta)
	end

	-- Publish the currency's own Topic when ServerUpdateIndividual is on
	if _settings.CURRENCIES[currencyName].ServerUpdateIndividual then
		I.Topic.Publish(`Currency_Changed-{currencyName}`, player, amount, currency.Amount, delta)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the amount of currency player has. 
]]
--- @return string?
function Module.Get(player: Player, currencyName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	--[[ Returning ]]

	return currency.Amount
end

--%%%%%%%%%%%%%%%%%%%% Get Total

--[[
	Returns the total amount of currency the player has earned.
]]
--- @return string?
function Module.GetTotal(player: Player, currencyName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	--[[ Returning ]]

	return currency.TotalEarned
end

--%%%%%%%%%%%%%%%%%%%% Get Total Spent

--[[
	Returns the total amount of currency the player has spent.
]]
--- @return string?
function Module.GetTotalSpent(player: Player, currencyName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	--[[ Returning ]]

	return currency.TotalSpent
end

--%%%%%%%%%%%%%%%%%%%% Get Highest Owned

--[[
	Returns the highest amount of currency the player has owned.
]]
--- @return string?
function Module.GetHighestOwned(player: Player, currencyName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	--[[ Returning ]]

	return currency.HighestOwned
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns table with all currencies amounts player has.
]]
--- @return { [string]: string }?
function Module.GetAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currency Currency_CurrencyData
	for currencyName: string, currency in pairs(moduleData.Currencies) do
		currencies[currencyName] = currency.Amount
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total

--[[
	Returns a table with all currency amounts the player has earned.
]]
--- @return { [string]: string }?
function Module.GetAllTotal(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currency Currency_CurrencyData
	for currencyName: string, currency in pairs(moduleData.Currencies) do
		currencies[currencyName] = currency.TotalEarned
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total Spent

--[[
	Returns a table with all currency amounts the player has spent.
]]
--- @return { [string]: string }?
function Module.GetAllTotalSpent(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currency Currency_CurrencyData
	for currencyName: string, currency in pairs(moduleData.Currencies) do
		currencies[currencyName] = currency.TotalSpent
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total Owned

--[[
	Returns a table with the highest owned amounts for all currencies.
]]
--- @return { [string]: string }?
function Module.GetAllTotalOwned(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currency Currency_CurrencyData
	for currencyName: string, currency in pairs(moduleData.Currencies) do
		currencies[currencyName] = currency.HighestOwned
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Has Enough

--[[
	Returns whether the player has enough of the specified currency. 
]]
--- @return boolean
function Module.HasEnough(player: Player, currencyName: string, amount: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Currency"]

	--- @type Currency_CurrencyData
	local currency = moduleData["Currencies"][currencyName]

	--[[ Checks ]]

	if not currency or not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return false
	end

	if not I.Number.IsIntegerString(amount) then
		warn(`[{_localName}::{script.Name}]: ({amount}) is not a valid amount!`)
		return false
	end

	local amountBN = I.BN.new(amount)
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	--[[ Calculating ]]

	local playerAmountBN = I.BN.new(currency.Amount)
	local leftAfterBN = playerAmountBN - amountBN

	--[[ Returning ]]

	if _settings.CURRENCIES[currencyName].RespectMinValue then
		return leftAfterBN >= I.BN.new(_settings.CURRENCIES[currencyName].MinValue)
	end

	return leftAfterBN >= zeroBN
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
