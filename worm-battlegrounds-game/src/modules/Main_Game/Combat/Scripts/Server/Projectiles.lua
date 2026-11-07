--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Ballistics = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Ballistics")) --- @type Combat_Ballistics

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local combatFolder: Folder
local active: number = 0

-- One fixed step of the simulation, and how many steps apart a shot's state goes to the clients
local STEP: number = _settings.PROJECTILE_STEP
local STATE_EVERY: number = math.max(math.round(_settings.STATE_INTERVAL / STEP), 1)

-- Shot ids, counted up for this server's life
local nextId: number = 0

-- What simulated shots touch: terrain and snails in play, never the combat folder's parts, and the arena's liquid
local world = {} --- @type Combat_World

-- Casts that hit what projectiles hit (terrain and snails in play), with and without the shooter
local params: RaycastParams = RaycastParams.new()
local shooterParams: RaycastParams = RaycastParams.new()

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

--- @class Combat_Server_Projectiles
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Building ]]

	combatFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})

	--[[ Saving ]]

	params.CollisionGroup = "Projectile"
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { combatFolder }
	shooterParams.CollisionGroup = "Projectile"
	shooterParams.FilterType = Enum.RaycastFilterType.Exclude

	world.Params = RaycastParams.new()
	world.Params.CollisionGroup = "Projectile"
	world.Params.FilterType = Enum.RaycastFilterType.Exclude
	world.Exclude = { combatFolder }
	world.IsLiquid = Module._isLiquid

	--- @Network
	I.Network.GetEvent("Combat_Shot")
	I.Network.GetEvent("Combat_ShotEnd")
	I.Network.GetUEvent("Combat_ShotState")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Launch

--[[
	Starts a simulated shot (Ballistics) of a kind, named after its weapon, from a position at a velocity, on the
	server's clock now, and tells every client so each simulates it too. It counts as in flight until it lands (Land).
]]
--- @param options Combat_ShotOptions
--- @return Combat_Body
function Module.Launch(kind: string, name: string, position: Vector3, velocity: Vector3, options)
	--[[ Building ]]

	nextId += 1
	local body = Ballistics.New(position, velocity, options) --- @type Combat_Body
	body.Id = nextId
	body.Kind = kind
	body.Name = name
	body.Start = I.S.Workspace:GetServerTimeNow()
	active += 1

	--[[ Sending ]]

	I.Network.FireAll("Combat_Shot", body.Id, kind, name, body.Start, body.Position, body.Velocity, options)

	--[[ Returning ]]

	return body
end

--%%%%%%%%%%%%%%%%%%%% Land

--[[
	Ends a simulated shot where it is: it's no longer in flight, and every client takes its copy away.
]]
--- @param body Combat_Body
function Module.Land(body)
	--[[ Saving ]]

	active -= 1

	--[[ Sending ]]

	I.Network.FireAll("Combat_ShotEnd", body.Id, body.Position)
end

--%%%%%%%%%%%%%%%%%%%% Spawn

--[[
	Makes a server-owned projectile part on the arena's plane at a position, moving at a velocity, for the shots that
	crawl instead of fly (the spider bomb, a variety grenade's snails): `collide` lets it bounce off terrain and snails
	(with `elasticity`); `anchored` parts are moved by their behavior instead of physics. It counts as in flight until
	it's destroyed.
]]
--- @return Part
function Module.Spawn(kind: string, name: string, position: Vector3, velocity: Vector3, collide: boolean, elasticity: number?, anchored: boolean?)
	--[[ Building ]]

	local part: Part = Ballistics.MakePart(kind, name, Vector3.new(position.X, position.Y, 0))
	part.Anchored = anchored == true
	part.CanCollide = collide
	part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, elasticity or 0, 1, 100)

	if not anchored then
		local attachment: Attachment = I.Create("Attachment")({
			Parent = part,
		})
		I.Create("PlaneConstraint")({
			Attachment0 = I.Arena.GetPlane(),
			Attachment1 = attachment,
			Parent = part,
		})
	end

	--[[ Launching ]]

	part.Parent = combatFolder
	if not anchored then
		part:SetNetworkOwner(nil)
		part.AssemblyLinearVelocity = velocity
	end

	--[[ Saving ]]

	active += 1
	part.Destroying:Connect(function()
		active -= 1
	end)

	--[[ Returning ]]

	return part
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Fly

--[[
	Returns an iterator that steps a launched shot one fixed step at a time, on the server's clock (waiting a frame when
	it's ahead, catching up when it's behind), giving the seconds since launch and what it touched that step. Every
	STATE_INTERVAL its state goes to the clients, which correct their copies by it.
]]
--- @param body Combat_Body
--- @return () -> (number, RaycastResult?)
function Module.Fly(body)
	return function()
		--[[ Waiting ]]

		local due: number = body.Start + (body.Step + 1) * STEP
		while I.S.Workspace:GetServerTimeNow() < due do
			I.S.RunService.Heartbeat:Wait()
		end

		--[[ Stepping ]]

		local hit: RaycastResult? = Ballistics.Step(body, world)

		--[[ Sending ]]

		if body.Step % STATE_EVERY == 0 then
			I.Network.UFireAll("Combat_ShotState", body.Id, Ballistics.GetState(body))
		end

		--[[ Returning ]]

		return body.Step * STEP, hit
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Options

--[[
	Returns a simulated shot's base options: a projectile's radius, and its shooter (when it has one) left out for
	SHOOTER_GRACE. Behaviors add their own.
]]
--- @param shot Combat_Shot?
--- @return Combat_ShotOptions
function Module.GetOptions(shot)
	--- @type Combat_ShotOptions
	local options = {
		Radius = _settings.PROJECTILE_SIZE / 2,
		Shooter = if shot then shot.Shooter else nil,
		GraceSteps = math.round(_settings.SHOOTER_GRACE / STEP),
	}
	return options
end

--%%%%%%%%%%%%%%%%%%%% Cast

--[[
	Returns what a projectile hits moving from one point to another: terrain or a snail in play, never another
	projectile. `shooter` is left out while the shot is still leaving it.
]]
--- @return RaycastResult?
function Module.Cast(from: Vector3, to: Vector3, shooter: Model?)
	--[[ Local Variables ]]

	local direction: Vector3 = to - from

	--[[ Checks ]]

	-- Check if it moved at all
	if direction.Magnitude < 1e-3 then
		return nil
	end

	--[[ Returning ]]

	if shooter then
		shooterParams.FilterDescendantsInstances = { combatFolder, shooter }
		return I.S.Workspace:Raycast(from, direction, shooterParams)
	end
	return I.S.Workspace:Raycast(from, direction, params)
end

--%%%%%%%%%%%%%%%%%%%% Get Active

--[[
	Returns how many projectiles are still in flight.
]]
--- @return number
function Module.GetActive()
	return active
end

--%%%%%%%%%%%%%%%%%%%% Is Lost

--[[
	Returns whether a projectile has left the arena (beside or below it) or flown longer than MAX_PROJECTILE_TIME.
]]
--- @return boolean
function Module.IsLost(position: Vector3, elapsed: number)
	return elapsed > _settings.MAX_PROJECTILE_TIME or I.Arena.GetHazard(position) == "Bounds"
end

--%%%%%%%%%%%%%%%%%%%% Is Gone

--[[
	Returns whether a simulated shot is over without a blast: lost (IsLost), or sunk in liquid SINK_SECONDS ago.
]]
--- @param body Combat_Body
--- @return boolean
function Module.IsGone(body, elapsed: number)
	return Module.IsLost(body.Position, elapsed) or body.Sunk and (body.Step - body.SunkStep) * STEP >= _settings.SINK_SECONDS
end

--%%%%%%%%%%%%%%%%%%%% Is Liquid

--[[
	Returns whether a position is in the arena's liquid.
]]
--- @return boolean
function Module._isLiquid(position: Vector3)
	return I.Arena.GetLiquid(position) ~= nil
end

return Module
