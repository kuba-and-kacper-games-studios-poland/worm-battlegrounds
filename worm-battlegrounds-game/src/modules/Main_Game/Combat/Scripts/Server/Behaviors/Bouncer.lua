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
local Snail = require(script.Parent:FindFirstChild("Snail")) --- @type Combat_Snail

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

-- The four ways a variety grenade's snails crawl off: down-left, down-right, left, right
--- @type { Vector3 }
local snailDirections = {
	Vector3.new(-1, -1, 0).Unit,
	Vector3.new(1, -1, 0).Unit,
	Vector3.new(-1, 0, 0),
	Vector3.new(1, 0, 0),
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

--- @class Combat_Bouncer
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	A thrown bomb. One with a Fuse bounces around and explodes when it runs out (the Grenade); one that bursts on
	contact explodes on the first thing it touches (Dynamite, Cluster bomb, Variety grenade). Then a cluster bomb
	scatters its bomblets and a variety grenade lets out its snails.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local wind: number = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local bounces: boolean = not row.BurstOnContact
	local part: Part = Projectiles.Spawn("Bouncer", shot.ItemId, shot.Origin, velocity, bounces, row.Elasticity, wind)
	local started: number = os.clock()
	local last: Vector3 = part.Position
	local burst: Vector3? = nil

	--[[ Flying ]]

	while part.Parent do
		I.S.RunService.Heartbeat:Wait()
		local now: Vector3 = part.Position
		local shooter: Model? = if os.clock() - started < _settings.SHOOTER_GRACE then shot.Shooter else nil
		local result: RaycastResult? = if bounces then nil else Projectiles.Cast(last, now, shooter)

		if result then
			burst = result.Position
			break
		elseif row.Fuse and os.clock() - started >= row.Fuse then
			burst = now
			break
		elseif Projectiles.IsLost(now, started) then
			break
		end
		last = now
	end
	part:Destroy()

	--[[ Bursting ]]

	if not burst then
		return
	end
	shot.Damage += Blast.Explode(burst, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)

	--[[ Splitting ]]

	local pending: number = 0

	if row.Bomblets then
		for _index: number = 1, row.Bomblets.Count do
			pending += 1
			task.spawn(function()
				Module._runBomblet(shot, burst)
				pending -= 1
			end)
		end
	end
	if row.Snails then
		for index: number = 1, row.Snails.Count do
			pending += 1
			task.spawn(function()
				Snail.Run(shot, burst + Vector3.yAxis, snailDirections[(index - 1) % #snailDirections + 1])
				pending -= 1
			end)
		end
	end

	while pending > 0 do
		task.wait()
	end
end

--%%%%%%%%%%%%%%%%%%%% Run Bomblet

--[[
	One of a cluster bomb's bomblets: thrown up and out at a random angle and speed, it explodes on contact.
]]
--- @param shot Combat_Shot
function Module._runBomblet(shot, from: Vector3)
	--[[ Local Variables ]]

	local bomblets = shot.Row.Bomblets --- @type Arsenal_Bomblets
	local angle: number = math.rad(random:NextNumber(30, 150))
	local speed: number = random:NextNumber(_settings.BOMBLET_SPEED[1], _settings.BOMBLET_SPEED[2])
	local part: Part = Projectiles.Spawn("Bomblet", "Bomblet", from + Vector3.yAxis * 1.5, Vector3.new(math.cos(angle), math.sin(angle), 0) * speed, false)
	local started: number = os.clock()
	local last: Vector3 = part.Position

	--[[ Flying ]]

	while part.Parent do
		I.S.RunService.Heartbeat:Wait()
		local now: Vector3 = part.Position
		local result: RaycastResult? = if os.clock() - started > 0.1 then Projectiles.Cast(last, now) else nil
		if result then
			shot.Damage += Blast.Explode(result.Position, bomblets.Radius, shot.ItemId, shot.ParticipantId, shot.Shiny, bomblets.DamageMax, bomblets.DamageEdge, "Small")
			break
		elseif Projectiles.IsLost(now, started) then
			break
		end
		last = now
	end

	--[[ Cleaning ]]

	part:Destroy()
end

return Module
