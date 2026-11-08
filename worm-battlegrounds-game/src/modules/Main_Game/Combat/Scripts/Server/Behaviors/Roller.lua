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

-- The participants who asked to blow up their rolling grenade
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
	The black hole grenade: released at the snail's feet, it rolls the way the snail faces at RollSpeed, hopping over
	bumps: its owner blows it up (Detonate), or it bursts as it rolls into water or lava, or after MaxRollTime.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local rootRadius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local feet: Vector3 = shot.Shooter.PrimaryPart.Position + Vector3.new(shot.Facing * (rootRadius + 0.8), -rootRadius * 0.4, 0)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	options.Bounce = 0
	options.Drive = shot.Facing * (row.RollSpeed or 10)
	options.HopSpeed = _settings.ROLL_HOP_SPEED
	local body = Projectiles.Launch("Roller", shot.ItemId, feet, Vector3.zero, options) --- @type Combat_Body
	detonations[shot.ParticipantId] = nil

	--[[ Rolling ]]

	-- The simulation drives it along the ground and hops it over bumps in its way
	for elapsed: number, _hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			Projectiles.Land(body)
			return
		elseif detonations[shot.ParticipantId] or body.Sunk or elapsed >= (row.MaxRollTime or 8) then
			break
		end
	end

	--[[ Exploding ]]

	detonations[shot.ParticipantId] = nil
	local center: Vector3 = body.Position
	Projectiles.Land(body)
	shot.Damage += Blast.Explode(center, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
end

--%%%%%%%%%%%%%%%%%%%% Detonate

--[[
	**SERVER** |
	Blows up a participant's rolling black hole grenade.
]]
function Module.Detonate(participantId: string)
	detonations[participantId] = true
end

return Module
