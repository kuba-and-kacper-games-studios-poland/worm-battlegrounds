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

--- @class Combat_Homing
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	The homing missile: flies off like a rocket (with wind) for LockDelay seconds, then turns toward the marked target
	at HomingSpeed, no longer pushed by wind, and explodes on contact or at the target.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local target: Vector3 = shot.Target or shot.Origin
	local wind: number = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local part: Part = Projectiles.Spawn("Homing", shot.ItemId, shot.Origin, velocity, false, 0, wind)
	local started: number = os.clock()
	local last: Vector3 = part.Position
	local locked: boolean = false
	local burst: Vector3? = nil

	--[[ Flying ]]

	while part.Parent do
		I.S.RunService.Heartbeat:Wait()
		local now: Vector3 = part.Position

		-- Lock on: the wind lets go, and the missile steers straight at the target from now on
		if not locked and os.clock() - started >= (row.LockDelay or 1) then
			locked = true
			local windForce: Instance? = part:FindFirstChild("Wind")
			if windForce then
				windForce:Destroy()
			end
		end
		if locked then
			local toTarget: Vector3 = target - now
			if toTarget.Magnitude <= _settings.CONTACT_DISTANCE then
				burst = now
				break
			end
			part.AssemblyLinearVelocity = toTarget.Unit * (row.HomingSpeed or 60)
		end

		local shooter: Model? = if os.clock() - started < _settings.SHOOTER_GRACE then shot.Shooter else nil
		local result: RaycastResult? = Projectiles.Cast(last, now, shooter)
		if result then
			burst = result.Position
			break
		elseif Projectiles.IsLost(now, started) then
			break
		end
		last = now
	end
	part:Destroy()

	--[[ Exploding ]]

	if burst then
		shot.Damage += Blast.Explode(burst, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
	end
end

return Module
