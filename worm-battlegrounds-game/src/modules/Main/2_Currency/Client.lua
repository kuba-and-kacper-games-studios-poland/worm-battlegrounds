--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--- @type Currency_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local currencyRep: Folder

--[[ BigNum ]]

local zeroBN = I.BN.new("0")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Currency Folder

--[[
	Returns the cached currency replicator folder, or looks it up.
]]
--- @return Folder?
local function _currencyFolder()
	return currencyRep or I.Replicator.GetFolder(_localName)
end

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
	------ INITIALIZATION ------
	----------------------------

	Module._createIndividualTopics()

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Currency_Changed", { "string", "string" })

	--- @Component
	I.Component.RegisterOnLoaded("Currency_Slot", _components.Slot)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Currency = {

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

--%%%%%%%%%%%%%%%%%%%% Create Individual Topics

--[[
	Creates individual Topics for each currency. 
]]
function Module._createIndividualTopics()
	--[[ Registering ]]

	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		if currencyData.ClientUpdateIndividual then
			I.Topic.Register(`Currency_Changed-{currencyName}`, { "string" })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Gets the replicator and connects it to fire when currency is changed. 
]]
function Module._connectReplicator()
	--[[ Checks ]]

	local folder: Folder? = I.Replicator.GetFolder(_localName)
	if not folder then
		warn(`[{_localName}::{script.Name}]: Currency replicator folder not found.`)
		return
	end

	--[[ Saving ]]

	currencyRep = folder

	--[[ Connecting ]]

	folder.AttributeChanged:Connect(function(attribute: string)
		--[[ Checks ]]

		-- Invalid Currency
		if not _settings.CURRENCIES[attribute] then
			return
		end

		--[[ Publishing ]]

		if _settings.CURRENCIES[attribute].ClientUpdate then
			I.Topic.Publish("Currency_Changed", attribute, folder:GetAttribute(attribute))
		end

		if _settings.CURRENCIES[attribute].ClientUpdateIndividual then
			I.Topic.Publish(`Currency_Changed-{attribute}`, folder:GetAttribute(attribute))
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the amount of currency the player has. 
]]
--- @return string?
function Module.Get(currencyName: string)
	--[[ Checks ]]

	if not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	return folder:GetAttribute(currencyName)
end

--%%%%%%%%%%%%%%%%%%%% Get Total

--[[
	Returns the total amount of currency the player has. 
]]
--- @return string?
function Module.GetTotal(currencyName: string)
	--[[ Checks ]]

	if not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	return folder:GetAttribute(`{currencyName}-Total`)
end

--%%%%%%%%%%%%%%%%%%%% Get Total Spent

--[[
	Returns the total amount of currency the player has spent.
]]
--- @return string?
function Module.GetTotalSpent(currencyName: string)
	--[[ Checks ]]

	if not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	return folder:GetAttribute(`{currencyName}-TotalSpent`)
end

--%%%%%%%%%%%%%%%%%%%% Get Highest Owned

--[[
	Returns the highest amount of currency the player has owned.
]]
--- @return string?
function Module.GetHighestOwned(currencyName: string)
	--[[ Checks ]]

	if not _settings.CURRENCIES[currencyName] then
		warn(`[{_localName}::{script.Name}]: ({currencyName}) is not a valid currencyName!`)
		return nil
	end

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	return folder:GetAttribute(`{currencyName}-HighestOwned`)
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns table with all currencies amounts the player has.
]]
--- @return { [string]: string }?
function Module.GetAll()
	--[[ Checks ]]

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		currencies[currencyName] = folder:GetAttribute(currencyName) or currencyData.DefaultValue
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total

--[[
	Returns a table with all currency amounts the player has earned.
]]
--- @return { [string]: string }?
function Module.GetAllTotal()
	--[[ Checks ]]

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	for currencyName: string in pairs(_settings.CURRENCIES) do
		currencies[currencyName] = folder:GetAttribute(`{currencyName}-Total`) or "0"
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total Spent

--[[
	Returns a table with all currency amounts the player has spent.
]]
--- @return { [string]: string }?
function Module.GetAllTotalSpent()
	--[[ Checks ]]

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	for currencyName: string in pairs(_settings.CURRENCIES) do
		currencies[currencyName] = folder:GetAttribute(`{currencyName}-TotalSpent`) or "0"
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get All Total Owned

--[[
	Returns a table with the highest owned amounts for all currencies.
]]
--- @return { [string]: string }?
function Module.GetAllTotalOwned()
	--[[ Checks ]]

	local folder: Folder? = _currencyFolder()
	if not folder then
		return nil
	end

	--[[ Returning ]]

	local currencies = {} --- @type { [string]: string }
	--- @param currencyData Currency_CurrencySettings
	for currencyName: string, currencyData in pairs(_settings.CURRENCIES) do
		currencies[currencyName] = folder:GetAttribute(`{currencyName}-HighestOwned`) or currencyData.DefaultValue
	end

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Has Enough

--[[
	Returns whether the player has enough currency. 
]]
--- @return boolean
function Module.HasEnough(currencyName: string, amount: string)
	--[[ Checks ]]

	if not _settings.CURRENCIES[currencyName] then
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

	local folder: Folder? = _currencyFolder()
	if not folder then
		return false
	end

	--[[ Calculating ]]

	local playerAmountBN = I.BN.new(folder:GetAttribute(currencyName) or "0")
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
