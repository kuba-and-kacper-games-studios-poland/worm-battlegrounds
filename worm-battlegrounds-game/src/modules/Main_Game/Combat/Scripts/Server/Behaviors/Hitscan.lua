--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Projectiles = require(script.Parent.Parent:FindFirstChild("Projectiles")) --- @type Combat_Server_Projectiles
local Blast = require(script.Parent.Parent:FindFirstChild("Blast")) --- @type Combat_Server_Blast
local Ballistics = require(script.Parent.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Ballistics")) --- @type Combat_Ballistics

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

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

--- @class Combat_Hitscan
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Guns: Pellets bullets fired straight from the muzzle within a Spread cone, all at once (Shotgun) or BurstInterval
	apart (Uzi, Minigun). Each bullet hurts the first snail it reaches by PerBulletDamage and pushes it a little, or
	chips the terrain where it lands. Every bullet's line is sent to clients as a tracer.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local spread: number = math.rad(row.Spread or 0)
	local range: number = row.Range or 60
	local push: number = I.G_Arsenal.GetKnockback(row.Knockback) * _settings.BULLET_KNOCK_SHARE
	local tracers = {} --- @type { Vector3 }

	--[[ Firing ]]

	for _bullet: number = 1, row.Pellets or 1 do
		local angle: number = shot.Angle + random:NextNumber(-spread, spread)
		local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
		local result: RaycastResult? = Projectiles.Cast(shot.Origin, shot.Origin + direction * range, shot.Shooter)
		local landed: Vector3 = if result then result.Position else shot.Origin + direction * range
		local snail: Model? = Ballistics.GetSnail(result)

		if snail then
			shot.Damage += Blast.Hit(snail.Name, row.PerBulletDamage or 0, direction * push, shot.ItemId, shot.ParticipantId, landed)
		elseif result then
			task.spawn(I.Arena.Carve, landed, _settings.BULLET_CARVE)
		end

		if row.BurstInterval then
			I.Network.FireAll("Combat_Tracer", shot.ItemId, shot.Origin, { landed })
			task.wait(row.BurstInterval)
		else
			table.insert(tracers, landed)
		end
	end

	--[[ Publishing ]]

	if #tracers > 0 then
		I.Network.FireAll("Combat_Tracer", shot.ItemId, shot.Origin, tracers)
	end
end

return Module
