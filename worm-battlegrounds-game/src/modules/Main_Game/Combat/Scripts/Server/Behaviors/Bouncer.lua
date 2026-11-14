--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
	A thrown or placed bomb. One with a Fuse explodes when it runs out (the Dynamite placed at the feet), or when it
	comes to rest if it was thrown (the Grenade); one that bursts on contact explodes on the first thing it touches (Cluster bomb, Variety
	grenade); water or lava only slows it. Then a cluster bomb scatters its bomblets and a variety grenade lets out its
	snails.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	options.Wind = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	options.Bounce = if row.BurstOnContact then nil else row.Elasticity or 0.5
	options.Tumble = true
	local body = Projectiles.Launch("Bouncer", shot.ItemId, shot.Origin, velocity, options) --- @type Combat_Body
	local burst: Vector3? = nil

	-- A thrown bomb's fuse runs in its slowed flight time, a placed one's in real seconds
	local thrown: boolean = row.Aim ~= "Feet"
	local fuse: number? = if row.Fuse and thrown then row.Fuse / _settings.PROJECTILE_TIME_SCALE else row.Fuse

	--[[ Flying ]]

	-- Water or lava only slows it: it bursts on what it touches under them, when its fuse runs out, or (thrown) as it comes to rest
	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Stopped then
			burst = if hit then hit.Position else body.Position
			break
		elseif fuse and (elapsed >= fuse or thrown and body.Grounded and body.Velocity.Magnitude < 1e-3) then
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
	One of a bomb's bomblets (a cluster bomb's, a variety grenade's): thrown up and out at a random angle and speed, in
	its bomb's wind, it explodes on contact. With Mini it's drawn as a small copy of its bomb (its model and trail, at that share of its size).
]]
--- @param shot Combat_Shot
function Module._runBomblet(shot, from: Vector3)
	--[[ Local Variables ]]

	local bomblets = shot.Row.Bomblets --- @type Arsenal_Bomblets
	local angle: number = math.rad(random:NextNumber(30, 150))
	local speed: number = random:NextNumber(_settings.BOMBLET_SPEED[1], _settings.BOMBLET_SPEED[2])
	local options = Projectiles.GetOptions(nil) --- @type Combat_ShotOptions
	options.GhostSteps = math.round(_settings.BOMBLET_GHOST / _settings.PROJECTILE_STEP)
	options.Wind = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	options.DrawScale = bomblets.Mini
	options.Tumble = bomblets.Mini ~= nil
	local velocity: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0) * speed
	local name: string = if bomblets.Mini then shot.ItemId else "Bomblet"
	local body = Projectiles.Launch("Bomblet", name, from + Vector3.yAxis * 1.5, velocity, options) --- @type Combat_Body

	--[[ Flying ]]

	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Stopped then
			local center: Vector3 = if hit then hit.Position else body.Position
			shot.Damage += Blast.Explode(center, bomblets.Radius, shot.ItemId, shot.ParticipantId, shot.Shiny, bomblets.DamageMax, bomblets.DamageEdge, "Small")
			break
		end
	end

	--[[ Cleaning ]]

	Projectiles.Land(body)
end

return Module
