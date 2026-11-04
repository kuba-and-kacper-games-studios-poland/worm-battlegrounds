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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
