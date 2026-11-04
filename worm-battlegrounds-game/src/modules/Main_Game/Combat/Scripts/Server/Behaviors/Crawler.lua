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

--- @class Combat_Crawler
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	The spider bomb: thrown like a grenade, it lands, then crawls along the ground and up walls toward the nearest
	enemy worm for CrawlTime seconds, and explodes when it reaches one or its time runs out.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local part: Part = Projectiles.Spawn("Crawler", shot.ItemId, shot.Origin, velocity, false)
	local started: number = os.clock()
	local last: Vector3 = part.Position
	local landed: Vector3? = nil

	--[[ Flying ]]

	while part.Parent do
		I.S.RunService.Heartbeat:Wait()
		local now: Vector3 = part.Position
		local shooter: Model? = if os.clock() - started < _settings.SHOOTER_GRACE then shot.Shooter else nil
		local result: RaycastResult? = Projectiles.Cast(last, now, shooter)
		if Projectiles.GetWorm(result) then
			shot.Damage += Module._explode(shot, result.Position)
			part:Destroy()
			return
		elseif result then
			landed = result.Position + result.Normal * 0.5
			break
		elseif Projectiles.IsLost(now, started) then
			part:Destroy()
			return
		end
		last = now
	end

	--[[ Crawling ]]

	part.Anchored = true
	part.Position = landed
	local crawlStart: number = os.clock()
	local position: Vector3 = landed

	while os.clock() - crawlStart < (row.CrawlTime or 5) do
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		local target: Model? = Module._getTarget(shot, position)
		if not target then
			break
		end
		if (target.PrimaryPart.Position - position).Magnitude <= _settings.CONTACT_DISTANCE then
			break
		end
		position = Module._getNextStep(position, math.sign(target.PrimaryPart.Position.X - position.X), (row.CrawlSpeed or 10) * deltaTime)
		part.Position = position
		if Projectiles.IsLost(position, started) then
			part:Destroy()
			return
		end
	end

	--[[ Exploding ]]

	shot.Damage += Module._explode(shot, position)
	part:Destroy()
end

--%%%%%%%%%%%%%%%%%%%% Explode

--[[
	Bursts the spider bomb with its row's blast.
]]
--- @param shot Combat_Shot
--- @return number
function Module._explode(shot, position: Vector3)
	--[[ Local Variables ]]

	--- @type Arsenal_WeaponData
	local row = shot.Row

	--[[ Returning ]]

	return Blast.Explode(position, row.BlastRadius, shot.ItemId, shot.ParticipantId, shot.Shiny, row.DamageMax, row.DamageEdge, row.Knockback)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Target

--[[
	Returns the nearest worm in play that isn't on the shooter's team.
]]
--- @param shot Combat_Shot
--- @return Model?
function Module._getTarget(shot, position: Vector3)
	--[[ Local Variables ]]

	local team: number? = shot.Shooter:GetAttribute("Team")
	local best: Model? = nil
	local bestDistance: number = math.huge

	--[[ Searching ]]

	for _index: number, model: Model in ipairs(I.Worms.GetAlive()) do
		local distance: number = (model.PrimaryPart.Position - position).Magnitude
		if model:GetAttribute("Team") ~= team and distance < bestDistance then
			best = model
			bestDistance = distance
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Next Step

--[[
	Returns where a crawler on the ground goes next, one step of a distance toward a side: up a wall in front, else
	along and down onto the ground, else falling.
]]
--- @return Vector3
function Module._getNextStep(position: Vector3, side: number, distance: number)
	--[[ Climbing ]]

	-- A wall in front: climb it
	if Projectiles.Cast(position, position + Vector3.xAxis * side * 0.8) then
		return position + Vector3.yAxis * distance
	end

	--[[ Walking ]]

	local ahead: Vector3 = position + Vector3.xAxis * side * distance
	local ground: RaycastResult? = Projectiles.Cast(ahead + Vector3.yAxis * 0.5, ahead - Vector3.yAxis * 3)

	--[[ Returning ]]

	if ground and not Projectiles.GetWorm(ground) then
		return ground.Position + Vector3.yAxis * 0.5
	end
	return ahead - Vector3.yAxis * distance * 2
end

return Module
