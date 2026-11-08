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
local Ballistics = require(script.Parent.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Ballistics")) --- @type Combat_Ballistics
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
	The spider bomb: thrown on the shared simulation like a grenade, it lands on the first thing it touches, then crawls
	along the ground and up walls toward the nearest enemy snail for CrawlTime seconds, and explodes when it reaches
	one, touches water or lava, or its time runs out.
]]
--- @param shot Combat_Shot
function Module.Run(shot)
	--[[ Local Variables ]]

	local row = shot.Row --- @type Arsenal_WeaponData
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(shot.ItemId, shot.Angle, shot.Power)
	local options = Projectiles.GetOptions(shot) --- @type Combat_ShotOptions
	local body = Projectiles.Launch("Crawler", shot.ItemId, shot.Origin, velocity, options) --- @type Combat_Body
	local landed: Vector3? = nil

	--[[ Flying ]]

	for elapsed: number, hit: RaycastResult? in Projectiles.Fly(body) do
		if Projectiles.IsGone(body, elapsed) then
			break
		elseif body.Sunk or (body.Stopped and Ballistics.GetSnail(hit)) then
			shot.Damage += Module._explode(shot, if hit and not body.Sunk then hit.Position else body.Position)
			break
		elseif body.Stopped then
			landed = if hit then hit.Position + hit.Normal * _settings.PROJECTILE_SIZE / 2 else body.Position
			break
		end
	end
	Projectiles.Land(body)

	-- Check if it landed on the ground
	if not landed then
		return
	end

	--[[ Crawling ]]

	local part: Part = Projectiles.Spawn("Crawler", shot.ItemId, landed, Vector3.zero, false, 0, true)
	local started: number = os.clock()
	local position: Vector3 = landed

	while os.clock() - started < (row.CrawlTime or 5) do
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		local target: Model? = Module._getTarget(shot, position)
		if not target then
			break
		end
		local offset: Vector3 = target.PrimaryPart.Position - position
		if offset.Magnitude <= _settings.CONTACT_DISTANCE or I.Arena.GetLiquid(position) then
			break
		end

		-- Right under or over its target it waits instead of turning back and forth
		local side: number = if math.abs(offset.X) < _settings.CRAWL_STOP then 0 else math.sign(offset.X)
		position = Module._getNextStep(position, side, (row.CrawlSpeed or 10) * deltaTime)
		part.Position = position
		if Projectiles.IsLost(position, os.clock() - started) then
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
	Returns the nearest snail in play that isn't on the shooter's team.
]]
--- @param shot Combat_Shot
--- @return Model?
function Module._getTarget(shot, position: Vector3)
	--[[ Local Variables ]]

	local team: number? = shot.Shooter:GetAttribute("Team")
	local best: Model? = nil
	local bestDistance: number = math.huge

	--[[ Searching ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
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
	Returns where a crawler goes next, one step of a distance toward a side (0 stays): up a wall taller than
	CRAWL_STEP_UP in front, else along the ground, easing up onto a ledge and down off one rather than jumping the
	stud grid's steps, else falling.
]]
--- @return Vector3
function Module._getNextStep(position: Vector3, side: number, distance: number)
	--[[ Local Variables ]]

	local radius: number = _settings.PROJECTILE_SIZE / 2
	local high: Vector3 = position + Vector3.yAxis * _settings.CRAWL_STEP_UP

	--[[ Climbing ]]

	-- A wall in front, taller than a step: climb it
	if side ~= 0 and Projectiles.Cast(high, high + Vector3.xAxis * side * (radius + distance)) then
		return position + Vector3.yAxis * distance
	end

	--[[ Walking ]]

	local ahead: Vector3 = position + Vector3.xAxis * side * distance
	local ground: RaycastResult? = Projectiles.Cast(ahead + Vector3.yAxis * _settings.CRAWL_STEP_UP, ahead - Vector3.yAxis * (radius + _settings.CRAWL_STEP_DOWN))

	-- Nothing under it: fall
	if not ground or Ballistics.GetSnail(ground) then
		return ahead - Vector3.yAxis * distance * 2
	end

	-- A step up: rise in place first, then move on once level with it
	local rise: number = ground.Position.Y + radius - position.Y
	if rise > distance then
		return position + Vector3.yAxis * distance
	end

	--[[ Returning ]]

	return Vector3.new(ahead.X, position.Y + math.max(rise, -distance * 2), ahead.Z)
end

return Module
