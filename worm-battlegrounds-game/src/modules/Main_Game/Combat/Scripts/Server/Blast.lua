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
	A blast: tells every client, hurts every snail in play within its radius at once (from damageMax at the center to
	damageEdge at the edge) and credits the shooter, while it carves a round hole; once the hole is cut, throws each
	snail it hurt away from the center (tilted up) with the knockback class (None throws nobody). Returns, after the
	carve, the damage dealt to snails other than the shooter's.
]]
--- @return number
function Module.Explode(center: Vector3, radius: number, itemId: string, sourceId: string?, shiny: boolean?, damageMax: number, damageEdge: number, knockback: string)
	--[[ Local Variables ]]

	local position: Vector3 = Vector3.new(center.X, center.Y, 0)
	local rootRadius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local knockSpeed: number = I.G_Arsenal.GetKnockback(knockback)
	local multiplier: number = if shiny then I.Settings["Arsenal"].SHINY_DAMAGE_MULTIPLIER else 1
	local throws = {} --- @type { [string]: Vector3 }
	local carved: boolean = false
	local dealt: number = 0

	--[[ Publishing ]]

	I.Network.FireAll("Combat_Explosion", position, radius, itemId, shiny == true)

	--[[ Carving ]]

	-- The carve takes a few frames: the damage doesn't wait for it, the throws do (a thrown snail flies the new ground)
	task.spawn(function()
		I.Arena.Carve(position, radius)
		carved = true
	end)

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
		local taken: number
		local hurt: boolean
		taken, hurt = Module._hurt(model.Name, damage, itemId, sourceId, root.Position)
		dealt += taken
		if hurt and speed > 0 then
			throws[model.Name] = direction * speed
		end
	end

	--[[ Throwing ]]

	while not carved do
		task.wait()
	end
	for participantId: string, velocityChange: Vector3 in pairs(throws) do
		local model: Model? = I.Snails.Get(participantId)
		if model then
			I.Snails.Knockback(participantId, velocityChange * model.PrimaryPart:GetMass(), sourceId, itemId)
		end
	end

	--[[ Returning ]]

	return dealt
end

--%%%%%%%%%%%%%%%%%%%% Hit

--[[
	**SERVER** |
	Hurts one snail and throws it at a velocity change, credits the shooter, and tells every client, with whether the blow
	knocks it out (its health went to 0). A shooter's teammates are never hurt or thrown; the shooter always is (the
	testers, 2026-11-13). Returns the damage when it hit a snail other than the shooter's, else 0.
]]
--- @return number
function Module.Hit(participantId: string, damage: number, velocityChange: Vector3, itemId: string, sourceId: string?, position: Vector3)
	--[[ Hurting ]]

	local taken: number
	local hurt: boolean
	taken, hurt = Module._hurt(participantId, damage, itemId, sourceId, position)

	--[[ Throwing ]]

	if hurt and velocityChange.Magnitude > 0 then
		local model: Model = I.Snails.Get(participantId)
		I.Snails.Knockback(participantId, velocityChange * model.PrimaryPart:GetMass(), sourceId, itemId)
	end

	--[[ Returning ]]

	return taken
end

--%%%%%%%%%%%%%%%%%%%% Hurt

--[[
	Hurts one snail in play (not a teammate of the shooter), credits the shooter and tells every client, with whether the
	blow knocks it out. Returns the damage counted for the shooter (none for its own snail) and whether it hurt it.
]]
--- @return number
--- @return boolean
function Module._hurt(participantId: string, damage: number, itemId: string, sourceId: string?, position: Vector3)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model:GetAttribute("Alive") then
		return 0, false
	end

	-- Skip the shooter's teammates
	if Module.IsTeammate(participantId, sourceId) then
		return 0, false
	end

	--[[ Applying ]]

	local taken: number = math.floor(damage + 0.5)
	local before: number = model:GetAttribute("Health")
	I.Snails.Damage(participantId, taken, sourceId, itemId)

	--[[ Publishing ]]

	I.Network.FireAll("Combat_Hit", participantId, taken, position, before > 0 and model:GetAttribute("Health") <= 0)

	--[[ Returning ]]

	return if participantId ~= sourceId then taken else 0, true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Teammate

--[[
	**SERVER** |
	Returns whether a snail is on the shooter's team but isn't the shooter (in a free-for-all every snail is its own
	team), so the shooter's blows spare it.
]]
--- @return boolean
function Module.IsTeammate(participantId: string, sourceId: string?)
	--[[ Data ]]

	local victim = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local shooter = if sourceId then I.Match.GetParticipant(sourceId) else nil --- @type Match_Participant?

	--[[ Returning ]]

	return victim ~= nil and shooter ~= nil and participantId ~= sourceId and victim.Team == shooter.Team
end

return Module
