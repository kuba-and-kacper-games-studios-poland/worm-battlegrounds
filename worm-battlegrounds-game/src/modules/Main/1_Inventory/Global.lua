--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--- @type Inventory_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
	Table with all item data indexed by their names.
]]
--- @type { [string]: Inventory_ItemData }
local cachedItems = {}

--[[
	Table with all item names/data indexed by their categories.
]]
local cachedCategories = {
	Modules = {}, --- @type { [string]: { Inventory_ItemData } }
	Names = {}, --- @type { [string]: { string } }
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
	------ INITIALIZATION ------
	----------------------------

	Module._cacheItems()

	I.OnStarted(I.Priority.Default, Module._runSetupFunctions)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Inventory = {

		--[[ Data ]]

		Items = cachedItems,
		Categories = cachedCategories,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Cache Items

--[[
	Caches and validates all item data, then groups it by category.
]]
function Module._cacheItems()
	--[[ Local Variables ]]

	local allRarities = I.Rarity.GetRarities() --- @type { string }
	local allItems = {} --- @type { [string]: Inventory_ItemData }

	--[[ Local Functions ]]

	--%%%%%%%%%%%%%%%%%%%% Save Items From Folder

	--[[
		Loops through given folder and saves all item data to a local table.
	]]
	local function saveItemsFromFolder(folder: Folder)
		for _index: number, elem: Folder | ModuleScript in ipairs(folder:GetChildren()) do
			--[[ Item Module ]]

			-- Require an item module
			if elem:IsA("ModuleScript") then
				--[[ Duplicated ]]

				-- Skip a duplicated name on both sides, so both keep the first module
				if allItems[elem.Name] then
					-- Warn once, from the server
					if I.Env.IsServer then
						warn(`[{_localName}::{script.Name}]: Item ({elem.Name}) is duplicated!`)
					end
					continue
				end

				--[[ Requiring ]]

				local success: boolean
				local result --- @type Inventory_ItemData | string
				success, result = pcall(function()
					return require(elem)
				end)

				-- Require failed
				if not success then
					warn(`[{_localName}::{script.Name}]: Failed to require ({elem.Name}) Item Data! - ({result})`)
					continue
				end

				--[[ Saving ]]

				allItems[elem.Name] = result
				continue
			end

			--[[ Folder ]]

			-- Walk a sub folder
			if elem:IsA("Folder") then
				saveItemsFromFolder(elem)
				continue
			end

			--[[ Invalid ]]

			warn(`[{_localName}::{script.Name}]: Invalid Item module. Expected (ModuleScript), got ({elem.Name}: {typeof(elem)})!`)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Data

	--[[ Saving Data ]]

	saveItemsFromFolder(_data.Items)

	--%%%%%%%%%%%%%%%%%%%% Validating -> Saving

	--- @param itemData Inventory_ItemData
	for itemName: string, itemData in pairs(allItems) do
		--%%%%%%%%%%%%%%%%%%%% Data Checks

		--[[ Category ]]

		-- Move an unknown category to Other
		if not table.find(_settings.CATEGORIES, itemData.Category) then
			warn(`[{_localName}::{script.Name}]: Item ({itemName}) is under invalid (Category) - {itemData.Category}`)
			itemData.Category = "Other"
		end

		--[[ Rarity ]]

		-- Use the first rarity for an unknown one
		if not table.find(allRarities, itemData.Rarity) then
			warn(`[{_localName}::{script.Name}]: Item ({itemName}) has invalid (Rarity) - {itemData.Rarity}`)
			itemData.Rarity = allRarities[1]
		end

		--[[ Creating Category Table ]]

		-- Create the category's lists on first use
		if not cachedCategories["Modules"][itemData.Category] and not cachedCategories["Names"][itemData.Category] then
			cachedCategories["Modules"][itemData.Category] = {}
			cachedCategories["Names"][itemData.Category] = {}
		end

		--[[ Saving Item ]]

		cachedItems[itemName] = itemData
		table.insert(cachedCategories["Modules"][itemData.Category], itemData)
		table.insert(cachedCategories["Names"][itemData.Category], itemName)
	end
end

--%%%%%%%%%%%%%%%%%%%% Run Setup Functions

--[[
	Runs Setup Function for all cached items.
]]
function Module._runSetupFunctions()
	for _itemName: string, itemData in pairs(cachedItems) do
		--[[ Running Setup Function ]]

		if itemData["_setupFunction"] then
			itemData._setupFunction()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
