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

--- @class Combat_Rocket
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	A launched shot that flies with gravity (and wind when its row says so) and explodes on the first terrain or worm it
	touches. A piercing shot (the Spartan spear) hits every worm along its path once, then sticks in the terrain.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local wind: number = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local part: Part = Projectiles.Spawn("Rocket", shot.ItemId, shot.Origin, velocity, false, 0, wind)
	local started: number = os.clock()
	local last: Vector3 = part.Position
	local pierced = {} --- @type { [Model]: boolean }

	--[[ Flying ]]

	while part.Parent do
		I.S.RunService.Heartbeat:Wait()
		local now: Vector3 = part.Position
		local shooter: Model? = if os.clock() - started < _settings.SHOOTER_GRACE then shot.Shooter else nil
		local result: RaycastResult? = Projectiles.Cast(last, now, shooter)
		local worm: Model? = Projectiles.GetWorm(result)

		if row.Pierce and worm then
			-- A piercing shot hurts each worm once and flies on
			if not pierced[worm] then
				pierced[worm] = true
				local push: Vector3 = (part.AssemblyLinearVelocity.Unit + Vector3.yAxis * _settings.UPWARD_BIAS).Unit
				shot.Damage += Blast.Hit(worm.Name, row.DamageMax, push * I.G_Arsenal.GetKnockback(row.Knockback), shot.ItemId, shot.ParticipantId, worm.PrimaryPart.Position)
			end
		elseif result and row.Pierce then
			break
		elseif result then
			shot.Damage += Blast.Explode(result.Position, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
			break
		end

		if Projectiles.IsLost(now, started) then
			break
		end
		last = now
	end

	--[[ Cleaning ]]

	part:Destroy()
end

return Module
