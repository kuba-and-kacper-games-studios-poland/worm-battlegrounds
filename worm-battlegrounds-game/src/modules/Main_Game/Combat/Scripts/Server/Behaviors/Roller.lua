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
	wherever it is when its owner presses again (Detonate), even in the air. Open, it holds still for HoleTime while its
	trail streams on every screen, drawing every snail within PullRadius in (the shooter's teammates aside: Drag), then
	bursts where they're stuck to it, and lets them go.
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
	local closesAt: number = os.clock() + (row.HoleTime or 2.5)
	local sentAt: number = 0
	local dragged = {} --- @type { [string]: boolean }
	while os.clock() < closesAt do
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		Module._drag(shot, center, deltaTime, dragged)
		if os.clock() - sentAt >= _settings.STATE_INTERVAL then
			Projectiles.SendState(body)
			sentAt = os.clock()
		end
	end

	--[[ Exploding ]]

	Projectiles.Land(body)
	shot.Damage += Blast.Explode(center, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)

	--[[ Releasing ]]

	for participantId: string, _held: boolean in pairs(dragged) do
		I.Snails.Release(participantId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Drag

--[[
	One frame of an open black hole: every snail within the row's PullRadius of it (the shooter's teammates aside) moves
	toward it at BLACK_HOLE_DRAG_SPEED, sliding on the ground and drifting through the air, and sticks within
	BLACK_HOLE_STICK of its middle (I.Snails.Drag). Each one it ever drew is noted in `dragged`, to let go of after.
]]
--- @param shot Combat_Shot
--- @param dragged { [string]: boolean }
function Module._drag(shot, center: Vector3, deltaTime: number, dragged)
	--[[ Local Variables ]]

	local radius: number = shot.Row.PullRadius or shot.Row.BlastRadius * 1.5

	--[[ Dragging ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		local inReach: boolean = (center - model.PrimaryPart.Position).Magnitude <= radius
		if (dragged[model.Name] or inReach) and not Blast.IsTeammate(model.Name, shot.ParticipantId) then
			dragged[model.Name] = true
			I.Snails.Drag(model.Name, center, _settings.BLACK_HOLE_DRAG_SPEED, deltaTime, _settings.BLACK_HOLE_STICK)
		end
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
