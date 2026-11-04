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
	The black hole grenade: released at the worm's feet, it rolls the way the worm faces at RollSpeed, hopping over
	bumps, and never explodes on its own: its owner blows it up (Detonate), or it bursts after MaxRollTime.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local rootRadius: number = I.Settings["Worms"].ROOT_SIZE / 2
	local feet: Vector3 = shot.Shooter.PrimaryPart.Position + Vector3.new(shot.Facing * (rootRadius + 0.8), -rootRadius * 0.4, 0)
	local part: Part = Projectiles.Spawn("Roller", shot.ItemId, feet, Vector3.zero, true, 0)
	local started: number = os.clock()
	local lastX: number = part.Position.X
	local stuckFor: number = 0
	detonations[shot.ParticipantId] = nil

	--[[ Rolling ]]

	while part.Parent and not detonations[shot.ParticipantId] and os.clock() - started < (row.MaxRollTime or 8) do
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		local velocity: Vector3 = part.AssemblyLinearVelocity
		part.AssemblyLinearVelocity = Vector3.new(shot.Facing * (row.RollSpeed or 10), velocity.Y, 0)

		-- Blocked by a bump: hop over it
		stuckFor = if math.abs(part.Position.X - lastX) < 0.02 then stuckFor + deltaTime else 0
		lastX = part.Position.X
		if stuckFor > 0.15 then
			stuckFor = 0
			part.AssemblyLinearVelocity = Vector3.new(velocity.X, _settings.ROLL_HOP_SPEED, 0)
		end

		if Projectiles.IsLost(part.Position, started) then
			part:Destroy()
			return
		end
	end

	--[[ Exploding ]]

	detonations[shot.ParticipantId] = nil
	local center: Vector3 = part.Position
	part:Destroy()
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
