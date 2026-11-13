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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The participants who asked to open their flying black hole grenade
local detonations = {} --- @type { [string]: boolean }

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

--- @class Combat_Roller
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	The black hole grenade (the testers, 2026-11-13): thrown like a grenade, it opens on the first thing it touches, or
	wherever it is when its owner presses again (Detonate), even in the air. Open, it holds still for HoleTime, pulling
	every snail within PullRadius toward it (the shooter's teammates aside) while its trail streams on every screen,
	then bursts.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	options.Wind = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	options.Tumble = true
	local body = Projectiles.Launch("Roller", shot.ItemId, shot.Origin, velocity, options) --- @type Combat_Body
	detonations[shot.ParticipantId] = nil

	--[[ Flying ]]

	for elapsed: number, _hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			Projectiles.Land(body)
			return
		elseif body.Stopped or detonations[shot.ParticipantId] then
			break
		end
	end
	detonations[shot.ParticipantId] = nil

	--[[ Opening ]]

	-- It holds still where it opened, on every screen too
	body.Stopped = true
	body.Velocity = Vector3.zero
	local center: Vector3 = body.Position
	Module._pull(shot, center)

	local closesAt: number = os.clock() + (row.HoleTime or 2.5)
	while os.clock() < closesAt do
		Projectiles.SendState(body)
		task.wait(_settings.STATE_INTERVAL)
	end

	--[[ Exploding ]]

	Projectiles.Land(body)
	shot.Damage += Blast.Explode(center, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
end

--%%%%%%%%%%%%%%%%%%%% Pull

--[[
	Throws every snail within the row's PullRadius of an open black hole toward it, a little up, harder the closer it
	is (BLACK_HOLE_PULL_SPEED at the middle, half that at the edge), the shooter's teammates aside.
]]
--- @param shot Combat_Shot
function Module._pull(shot, center: Vector3)
	--[[ Local Variables ]]

	local radius: number = shot.Row.PullRadius or shot.Row.BlastRadius * 1.5

	--[[ Pulling ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		local offset: Vector3 = center - model.PrimaryPart.Position
		if offset.Magnitude > radius or offset.Magnitude < 0.5 or Blast.IsTeammate(model.Name, shot.ParticipantId) then
			continue
		end
		local speed: number = _settings.BLACK_HOLE_PULL_SPEED * (1 - 0.5 * offset.Magnitude / radius)
		local direction: Vector3 = (offset.Unit + Vector3.yAxis * _settings.UPWARD_BIAS * 0.5).Unit
		I.Snails.Knockback(model.Name, direction * speed * model.PrimaryPart:GetMass(), shot.ParticipantId, shot.ItemId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Detonate

--[[
	**SERVER** |
	Opens a participant's flying black hole grenade where it is.
]]
function Module.Detonate(participantId: string)
	detonations[participantId] = true
end

return Module
