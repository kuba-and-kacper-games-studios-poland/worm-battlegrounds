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

-- Each weapon's model from Assets/Arsenal/Models, and the ones with a projectile of their own from Projectiles
local cachedModels = {} --- @type { [string]: Model }
local cachedProjectiles = {} --- @type { [string]: Model }

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
	Module._cacheModels("Models", cachedModels)
	Module._cacheModels("Projectiles", cachedProjectiles)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Arsenal = {

		--[[ Methods ]]

		Get = Module.Get,
		GetAll = Module.GetAll,
		GetDamage = Module.GetDamage,
		GetKnockback = Module.GetKnockback,
		GetModel = Module.GetModel,
		GetProjectileModel = Module.GetProjectileModel,
		HasModel = Module.HasModel,
		HasProjectileModel = Module.HasProjectileModel,
		IsWeapon = Module.IsWeapon,
		IsUtility = Module.IsUtility,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Cache Models

--[[
	Caches the models in Assets/Arsenal/<folderName>, each named after its weapon or utility row (or, in Projectiles, a
	burst's shot from BURST_SHOTS) and with its RootPart (the PrimaryPart) hidden. Skips, with a warn on the server,
	what isn't a Model with a PrimaryPart or has no row.
]]
--- @param cache { [string]: Model }
function Module._cacheModels(folderName: string, cache)
	--[[ Data ]]

	local assets: Instance? = I.Dirs.Assets:FindFirstChild(_localName)
	local dir: Instance? = assets and assets:FindFirstChild(folderName)

	--[[ Checks ]]

	-- Check if the folder is in the place
	if not dir then
		if I.Env.IsServer then
			warn(`[{_localName}::{script.Name}]: Folder (Assets/{_localName}/{folderName}) is missing - no weapon has a model there!`)
		end
		return
	end

	--[[ Caching ]]

	for _index: number, model: Instance in ipairs(dir:GetChildren()) do
		--[[ Checks ]]

		-- Check if the child is a Model with its RootPart
		if not model:IsA("Model") or not model.PrimaryPart then
			if I.Env.IsServer then
				warn(`[{_localName}::{script.Name}]: ({model:GetFullName()}) isn't a Model with a PrimaryPart - skipped! -`, model)
			end
			continue
		end

		-- Check if a row uses it
		local isShot: boolean = folderName == "Projectiles" and table.find(_settings.BURST_SHOTS, model.Name) ~= nil
		if not weapons[model.Name] and not utilities[model.Name] and not isShot then
			if I.Env.IsServer then
				warn(`[{_localName}::{script.Name}]: Model (Assets/{_localName}/{folderName}/{model.Name}) has no row in Data - unused. -`, model)
			end
			continue
		end

		--[[ Saving ]]

		model.PrimaryPart.Transparency = 1
		cache[model.Name] = model
	end
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

--%%%%%%%%%%%%%%%%%%%% Get Model

--[[
	Returns a weapon's model (clone it): the one a worm holds, and throws when the weapon has no projectile model.
	Faces +X from its RootPart, at the grip of a held weapon and the centre of a thrown one.
]]
--- @return Model?
function Module.GetModel(itemId: string)
	--[[ Checks ]]

	-- Check if the weapon has a model
	if not cachedModels[itemId] then
		warn(`[{_localName}::{script.Name}]: Weapon ({itemId}) model is missing!`)
		return nil
	end

	--[[ Returning ]]

	return cachedModels[itemId]
end

--%%%%%%%%%%%%%%%%%%%% Get Projectile Model

--[[
	Returns the model a weapon's shot flies as (clone it): its own projectile model, else the weapon's model.
]]
--- @return Model?
function Module.GetProjectileModel(itemId: string)
	return cachedProjectiles[itemId] or Module.GetModel(itemId)
end

--%%%%%%%%%%%%%%%%%%%% Has Model

--[[
	Returns whether a weapon or utility has a model, without warning when it doesn't.
]]
--- @return boolean
function Module.HasModel(itemId: string)
	return cachedModels[itemId] ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Has Projectile Model

--[[
	Returns whether a weapon or a burst's shot (a snail) has a model of its own in Projectiles.
]]
--- @return boolean
function Module.HasProjectileModel(shotId: string)
	return cachedProjectiles[shotId] ~= nil
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
