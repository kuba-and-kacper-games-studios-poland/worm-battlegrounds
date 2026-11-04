--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arsenal"

--- @type Arsenal_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local _data: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Every weapon and utility row, by item id
local weapons = {} --- @type { [string]: Arsenal_WeaponData }
local utilities = {} --- @type { [string]: Arsenal_UtilityData }

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

	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Weapons"):GetChildren()) do
		weapons[row.Name] = require(row)
	end
	for _index: number, row: Instance in ipairs(_data:FindFirstChild("Utilities"):GetChildren()) do
		utilities[row.Name] = require(row)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Arsenal = {

		--[[ Methods ]]

		Get = Module.Get,
		GetAll = Module.GetAll,
		GetDamage = Module.GetDamage,
		GetKnockback = Module.GetKnockback,
		IsWeapon = Module.IsWeapon,
		IsUtility = Module.IsUtility,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns a weapon's or utility's row by its item id.
]]
--- @return (Arsenal_WeaponData | Arsenal_UtilityData)?
function Module.Get(itemId: string)
	--[[ Checks ]]

	-- Check if the item has a row
	if not weapons[itemId] and not utilities[itemId] then
		warn(`[{_localName}::{script.Name}]: Item ({itemId}) has no Arsenal row!`)
		return nil
	end

	--[[ Returning ]]

	return weapons[itemId] or utilities[itemId]
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns every weapon row and every utility row, by item id.
]]
--- @return { [string]: Arsenal_WeaponData }, { [string]: Arsenal_UtilityData }
function Module.GetAll()
	return weapons, utilities
end

--%%%%%%%%%%%%%%%%%%%% Get Damage

--[[
	Returns a weapon's blast damage at a distance from its center: DamageMax at the center, falling in a straight line
	to DamageEdge at BlastRadius, nothing beyond; a shiny copy deals SHINY_DAMAGE_MULTIPLIER more.
]]
--- @return number
function Module.GetDamage(itemId: string, distance: number, isShiny: boolean?)
	--[[ Data ]]

	--- @type Arsenal_WeaponData?
	local row = weapons[itemId]

	--[[ Checks ]]

	-- Check if it's a weapon whose blast reaches that far
	if not row or distance > row.BlastRadius then
		return 0
	end

	--[[ Returning ]]

	local share: number = if row.BlastRadius > 0 then distance / row.BlastRadius else 0
	local damage: number = row.DamageMax + (row.DamageEdge - row.DamageMax) * share
	return damage * (if isShiny then _settings.SHINY_DAMAGE_MULTIPLIER else 1)
end

--%%%%%%%%%%%%%%%%%%%% Get Knockback

--[[
	Returns the speed a knockback class throws a worm at, in studs per second.
]]
--- @return number
function Module.GetKnockback(class: string)
	return _settings.KNOCKBACK[class] or 0
end

--%%%%%%%%%%%%%%%%%%%% Is Weapon

--[[
	Returns whether an item id is a weapon.
]]
--- @return boolean
function Module.IsWeapon(itemId: string)
	return weapons[itemId] ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Utility

--[[
	Returns whether an item id is a utility.
]]
--- @return boolean
function Module.IsUtility(itemId: string)
	return utilities[itemId] ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
