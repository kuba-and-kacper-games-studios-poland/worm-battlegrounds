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

--- @class Combat_Snail
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	One of a variety grenade's snails: it crawls one way at SNAIL_SPEED, eating the terrain in front of it, and hurts
	every snail it touches by the row's Damage a hit, Hits times at most, until SNAIL_LIFETIME runs out.
]]
--- @param shot Combat_Shot
function Module.Run(shot, from: Vector3, direction: Vector3)
	--[[ Local Variables ]]

	local snails = shot.Row.Snails --- @type Arsenal_Snails
	local part: Part = Projectiles.Spawn("Snail", "Snail", from, Vector3.zero, false, 0, true)
	local started: number = os.clock()
	local lastBite: number = 0
	local lastHit = {} --- @type { [Model]: number }
	local hits: number = 0
	local rootRadius: number = I.Settings["Snails"].ROOT_SIZE / 2

	--[[ Crawling ]]

	while part.Parent and os.clock() - started < _settings.SNAIL_LIFETIME and hits < snails.Hits do
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		part.Position += direction * _settings.SNAIL_SPEED * deltaTime

		-- Eat the terrain ahead
		if os.clock() - lastBite >= _settings.SNAIL_BITE then
			lastBite = os.clock()
			task.spawn(I.Arena.Carve, part.Position, snails.Radius)
		end

		-- Bite every snail close enough, once a second each
		for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
			local close: boolean = (model.PrimaryPart.Position - part.Position).Magnitude <= snails.Radius + rootRadius
			if close and os.clock() - (lastHit[model] or 0) >= 1 and hits < snails.Hits then
				lastHit[model] = os.clock()
				hits += 1
				local push: Vector3 = (direction + Vector3.yAxis * _settings.UPWARD_BIAS).Unit * I.G_Arsenal.GetKnockback("Small")
				shot.Damage += Blast.Hit(model.Name, snails.Damage, push, shot.ItemId, shot.ParticipantId, part.Position)
			end
		end

		if Projectiles.IsLost(part.Position, os.clock() - started) then
			break
		end
	end

	--[[ Cleaning ]]

	part:Destroy()
end

return Module
