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

-- The four ways a variety grenade's worms dig off, fanned out downward
--- @type { Vector3 }
local snailDirections = {
	Vector3.new(-0.7, -1, 0).Unit,
	Vector3.new(-0.25, -1, 0).Unit,
	Vector3.new(0.25, -1, 0).Unit,
	Vector3.new(0.7, -1, 0).Unit,
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
	A thrown or placed bomb. One with a Fuse bounces around and explodes when it runs out (the Grenade, the Dynamite
	placed at the feet); one that bursts on contact explodes on the first thing it touches (Cluster bomb, Variety
	grenade); any explodes as it touches water or lava. Then a cluster bomb scatters its bomblets and a variety grenade
	lets out its snails.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	options.Wind = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	options.Bounce = if row.BurstOnContact then nil else row.Elasticity or 0.5
	local body = Projectiles.Launch("Bouncer", shot.ItemId, shot.Origin, velocity, options) --- @type Combat_Body
	local burst: Vector3? = nil

	-- A thrown bomb's fuse runs in its slowed flight time, a placed one's in real seconds
	local fuse: number? = if row.Fuse and row.Aim ~= "Feet" then row.Fuse / _settings.PROJECTILE_TIME_SCALE else row.Fuse

	--[[ Flying ]]

	-- One that touches water or lava blows up there
	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Stopped and not body.Sunk then
			burst = if hit then hit.Position else body.Position
			break
		elseif body.Sunk or fuse and elapsed >= fuse then
			burst = body.Position
			break
		end
	end
	Projectiles.Land(body)

	--[[ Bursting ]]

	if not burst then
		return
	end

	-- A snail still running from its Dynamite is the server's again before the blast can throw it
	if row.Retreat then
		I.SnailControl.EndTurn(shot.ParticipantId)
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
	local options = Projectiles.GetOptions(nil) --- @type Combat_ShotOptions
	options.GhostSteps = math.round(_settings.BOMBLET_GHOST / _settings.PROJECTILE_STEP)
	local velocity: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0) * speed
	local body = Projectiles.Launch("Bomblet", "Bomblet", from + Vector3.yAxis * 1.5, velocity, options) --- @type Combat_Body

	--[[ Flying ]]

	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Stopped or body.Sunk then
			local center: Vector3 = if hit and not body.Sunk then hit.Position else body.Position
			shot.Damage += Blast.Explode(center, bomblets.Radius, shot.ItemId, shot.ParticipantId, shot.Shiny, bomblets.DamageMax, bomblets.DamageEdge, "Small")
			break
		end
	end

	--[[ Cleaning ]]

	Projectiles.Land(body)
end

return Module
