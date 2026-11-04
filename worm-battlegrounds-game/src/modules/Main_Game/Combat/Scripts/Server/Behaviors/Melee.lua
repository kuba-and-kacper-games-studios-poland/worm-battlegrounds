--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

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

--- @class Combat_Melee
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	A swing (Baseball bat, One Punch): the nearest worm within MELEE_BOX in front of the worm, toward the aimed side,
	takes DamageMax and is launched along that side, tilted up by the row's Lift (steeper for the punch).
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local root: BasePart = shot.Shooter.PrimaryPart
	local side: number = if shot.Direction.X < 0 then -1 else 1
	local center: Vector3 = root.Position + Vector3.xAxis * side * (I.Settings["Worms"].ROOT_SIZE / 2 + (row.Reach or 4) / 2)
	local victim: Model? = nil
	local nearest: number = math.huge

	--[[ Searching ]]

	for _index: number, model: Model in ipairs(I.Worms.GetAlive()) do
		local offset: Vector3 = model.PrimaryPart.Position - center
		local inside: boolean = math.abs(offset.X) <= _settings.MELEE_BOX / 2 + 1 and math.abs(offset.Y) <= _settings.MELEE_BOX / 2 + 1
		if model ~= shot.Shooter and inside and offset.Magnitude < nearest then
			victim = model
			nearest = offset.Magnitude
		end
	end

	--[[ Hitting ]]

	I.Network.FireAll("Combat_Tracer", shot.ItemId, root.Position, { center })
	if victim then
		local launch: Vector3 = (Vector3.xAxis * side + Vector3.yAxis * (row.Lift or 0.6)).Unit * I.G_Arsenal.GetKnockback(row.Knockback)
		shot.Damage += Blast.Hit(victim.Name, row.DamageMax, launch, shot.ItemId, shot.ParticipantId, victim.PrimaryPart.Position)
	end

	--[[ Waiting ]]

	-- Give the swing a moment, so the hit worm is already flying when the turn waits for things to settle
	task.wait(0.3)
end

return Module
