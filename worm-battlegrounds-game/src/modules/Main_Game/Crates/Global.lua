--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local _data: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local crates = {} --- @type { [string]: Crates_CrateData }

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

	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Crates"):GetChildren()) do
		crates[row.Name] = require(row)
		Module._checkOdds(row.Name)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Crates = {

		--[[ Methods ]]

		Get = Module.Get,
		GetAll = Module.GetAll,
		GetPrice = Module.GetPrice,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Check Odds

--[[
	Warns when a crate's odds for one currency don't add up to 100, or name an item the inventory doesn't know.
]]
function Module._checkOdds(crateId: string)
	--[[ Checking ]]

	--- @param odds { [string]: number }
	for currency: string, odds in pairs(crates[crateId].OddsByCurrency) do
		local total: number = 0
		for itemId: string, chance: number in pairs(odds) do
			total += chance
			if not I.G_Inventory.Items[itemId] then
				warn(`[{_localName}::{script.Name}]: Crate ({crateId}) rolls an unknown item ({itemId})!`)
			end
		end
		if math.abs(total - 100) > 0.001 then
			warn(`[{_localName}::{script.Name}]: Crate ({crateId}) odds in {currency} add up to {total}, not 100!`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns a crate's row by its id.
]]
--- @return Crates_CrateData?
function Module.Get(crateId: string)
	--[[ Checks ]]

	-- Check if the crate has a row
	if not crates[crateId] then
		warn(`[{_localName}::{script.Name}]: Crate ({crateId}) has no row!`)
		return nil
	end

	--[[ Returning ]]

	return crates[crateId]
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns every crate row, by id.
]]
--- @return { [string]: Crates_CrateData }
function Module.GetAll()
	return crates
end

--%%%%%%%%%%%%%%%%%%%% Get Price

--[[
	Returns what a pack of 1, 3 or 10 crates costs in a currency (the row's One, Three or Ten), or nil when the crate
	doesn't take that currency.
]]
--- @return string?
function Module.GetPrice(crateId: string, currency: string, count: number)
	--[[ Data ]]

	local row = Module.Get(crateId) --- @type Crates_CrateData?
	if not row or not row.Prices[currency] then
		return nil
	end
	local price = row.Prices[currency] --- @type Crates_Price

	--[[ Returning ]]

	return if count == 1 then price.One elseif count == 3 then price.Three else price.Ten
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
