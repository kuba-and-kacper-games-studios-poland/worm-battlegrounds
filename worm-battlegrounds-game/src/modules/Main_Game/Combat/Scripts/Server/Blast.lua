--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Combat_Server_Blast
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Explode

--[[
	**SERVER** |
	A blast: tells every client, carves a round hole, hurts every snail in play within its radius (from damageMax at the
	center to damageEdge at the edge), throws each away from the center (tilted up) with the knockback class and
	credits the shooter. Returns the damage dealt to snails other than the shooter's.
]]
--- @return number
function Module.Explode(center: Vector3, radius: number, itemId: string, sourceId: string?, shiny: boolean?, damageMax: number, damageEdge: number, knockback: string)
	--[[ Local Variables ]]

	local position: Vector3 = Vector3.new(center.X, center.Y, 0)
	local rootRadius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local knockSpeed: number = I.G_Arsenal.GetKnockback(knockback)
	local multiplier: number = if shiny then I.Settings["Arsenal"].SHINY_DAMAGE_MULTIPLIER else 1
	local dealt: number = 0

	--[[ Publishing ]]

	-- Before the carve, which takes a few frames, so the blast shows the moment it happens
	I.Network.FireAll("Combat_Explosion", position, radius, itemId, shiny == true)

	--[[ Carving ]]

	I.Arena.Carve(position, radius)

	--[[ Hurting ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		local root: BasePart = model.PrimaryPart
		local offset: Vector3 = root.Position - position
		local distance: number = math.max(offset.Magnitude - rootRadius, 0)
		if distance > radius then
			continue
		end

		local share: number = if radius > 0 then distance / radius else 0
		local damage: number = math.floor((damageMax + (damageEdge - damageMax) * share) * multiplier + 0.5)
		local away: Vector3 = if offset.Magnitude > 0.05 then offset.Unit else Vector3.yAxis
		local direction: Vector3 = (away + Vector3.yAxis * _settings.UPWARD_BIAS).Unit
		local speed: number = knockSpeed * (1 - (1 - _settings.KNOCKBACK_EDGE) * share)
		dealt += Module.Hit(model.Name, damage, direction * speed, itemId, sourceId, root.Position)
	end

	--[[ Returning ]]

	return dealt
end

--%%%%%%%%%%%%%%%%%%%% Hit

--[[
	**SERVER** |
	Hurts one snail and throws it at a velocity change, credits the shooter, and tells every client, with whether the blow
	knocks it out (its health went to 0). Returns the damage when it hit a snail other than the shooter's, else 0.
]]
--- @return number
function Module.Hit(participantId: string, damage: number, velocityChange: Vector3, itemId: string, sourceId: string?, position: Vector3)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model:GetAttribute("Alive") then
		return 0
	end

	--[[ Applying ]]

	-- The tutorial bot takes more damage, so a new player knocks it out in two hits
	local taken: number = math.floor(damage * (model:GetAttribute("DamageTaken") or 1) + 0.5)
	local before: number = model:GetAttribute("Health")
	I.Snails.Damage(participantId, taken, sourceId, itemId)
	I.Snails.Knockback(participantId, velocityChange * model.PrimaryPart:GetMass(), sourceId, itemId)

	--[[ Publishing ]]

	I.Network.FireAll("Combat_Hit", participantId, taken, position, before > 0 and model:GetAttribute("Health") <= 0)

	--[[ Returning ]]

	return if participantId ~= sourceId then taken else 0
end

return Module
