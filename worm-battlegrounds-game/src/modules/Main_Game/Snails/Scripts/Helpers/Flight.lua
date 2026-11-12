--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The most steps one frame catches up, so a long hitch never freezes the game
local MAX_STEPS_PER_FRAME: number = 30

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

--- @class Snails_Flight
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Returns a thrown snail's flight from where it was thrown, at the speed it was thrown with: a Combat body the size of
	its ball, light (GRAVITY_SCALE) and bouncing off what it hits (FLIGHT_BOUNCE), that hits what a snail hits.
]]
--- @return Snails_FlightState
function Module.New(model: Model, from: Vector3, velocity: Vector3)
	--[[ Local Variables ]]

	--- @type Combat_ShotOptions
	local options = {
		Radius = _settings.ROOT_SIZE / 2,
		GravityScale = _settings.GRAVITY_SCALE,
		Bounce = _settings.FLIGHT_BOUNCE,
	}

	--- @type Combat_World
	local world = {
		Params = RaycastParams.new(),
		Exclude = { model, I.Dirs.UmeWorkspace:FindFirstChild("Combat") },
		IsLiquid = Module._isLiquid,
	}
	world.Params.CollisionGroup = model.PrimaryPart.CollisionGroup
	world.Params.FilterType = Enum.RaycastFilterType.Exclude

	--[[ Returning ]]

	--- @type Snails_FlightState
	local state = {
		Body = I.G_Combat.NewBody(from, velocity, options),
		World = world,
	}
	return state
end

--%%%%%%%%%%%%%%%%%%%% Advance

--[[
	Steps a flight up to where it should be after a number of seconds since it started (MAX_STEPS_PER_FRAME at most at
	once), and stops stepping once it has landed.
]]
--- @param state Snails_FlightState
function Module.Advance(state, seconds: number)
	--[[ Local Variables ]]

	-- Combat's Ballistics moves a body by its own step (PROJECTILE_STEP slowed by PROJECTILE_TIME_SCALE); a snail flies at real speed
	local combat = I.Settings["Combat"] --- @type Combat_Settings
	local step: number = combat.PROJECTILE_STEP * combat.PROJECTILE_TIME_SCALE
	local due: number = math.min(math.floor(seconds / step), state.Body.Step + MAX_STEPS_PER_FRAME)

	--[[ Stepping ]]

	while state.Body.Step < due and not Module.IsLanded(state) do
		I.G_Combat.StepBody(state.Body, state.World)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Puts a snail's anchored ball where its flight is, upright as it was, moving at the flight's speed (an anchored part
	keeps the speed it's given), so whatever reads its speed sees it fly.
]]
--- @param state Snails_FlightState
function Module.Apply(state, root: BasePart)
	--[[ Applying ]]

	root.CFrame = CFrame.new(state.Body.Position.X, state.Body.Position.Y, root.Position.Z) * root.CFrame.Rotation
	root.AssemblyLinearVelocity = if Module.IsLanded(state) then Vector3.zero else state.Body.Velocity
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Landed

--[[
	Returns whether a flight has landed: it rests on the ground (rolling after a soft touch) or was stopped.
]]
--- @param state Snails_FlightState
--- @return boolean
function Module.IsLanded(state)
	return state.Body.Grounded or state.Body.Stopped
end

--%%%%%%%%%%%%%%%%%%%% Is Liquid

--[[
	Returns whether a position is in the arena's drawn liquid (Workspace.Ume.Arena.Liquid's blocks), which the server
	and every client see alike, so their flights slow in it the same.
]]
--- @return boolean
function Module._isLiquid(position: Vector3)
	--[[ Data ]]

	local arena: Instance? = I.Dirs.UmeWorkspace:FindFirstChild("Arena")
	local liquid: Instance? = if arena then arena:FindFirstChild("Liquid") else nil
	if not liquid then
		return false
	end

	--[[ Checking ]]

	for _index: number, block: Instance in ipairs(liquid:GetChildren()) do
		if block:IsA("BasePart") then
			local inside: Vector3 = block.CFrame:PointToObjectSpace(position)
			if math.abs(inside.X) <= block.Size.X / 2 and math.abs(inside.Y) <= block.Size.Y / 2 then
				return true
			end
		end
	end

	--[[ Returning ]]

	return false
end

return Module
