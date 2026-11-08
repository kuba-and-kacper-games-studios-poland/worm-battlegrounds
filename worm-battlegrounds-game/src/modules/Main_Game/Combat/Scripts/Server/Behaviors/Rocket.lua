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
	A launched shot that flies with gravity (and wind when its row says so) and explodes on the first terrain or snail it
	touches. A piercing shot (the Spartan spear) hits every snail along its path once, then sticks in the terrain.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	options.Wind = I.G_Combat.GetWindAcceleration(shot.ItemId, I.Match.GetWind())
	options.Pierce = row.Pierce
	local body = Projectiles.Launch("Rocket", shot.ItemId, shot.Origin, velocity, options) --- @type Combat_Body
	local pierced: number = 0

	--[[ Flying ]]

	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		-- A piercing shot hurts each snail it passed through once (the simulation lets it through them)
		while pierced < #body.Ignore do
			pierced += 1
			local snail: Instance = body.Ignore[pierced]
			local push: Vector3 = (body.Velocity.Unit + Vector3.yAxis * _settings.UPWARD_BIAS).Unit
			local at: Vector3 = snail:GetPivot().Position
			shot.Damage += Blast.Hit(snail.Name, row.DamageMax, push * I.G_Arsenal.GetKnockback(row.Knockback), shot.ItemId, shot.ParticipantId, at)
		end

		-- A piercing shot sinks in water or lava; any other blows up as it touches them
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Sunk and row.Pierce then
			continue
		elseif body.Stopped or body.Sunk then
			-- A piercing shot sticks in the terrain; any other bursts
			if not row.Pierce then
				local center: Vector3 = if hit and not body.Sunk then hit.Position else body.Position
				shot.Damage += Blast.Explode(center, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
			end
			break
		end
	end

	--[[ Cleaning ]]

	Projectiles.Land(body)
end

return Module
