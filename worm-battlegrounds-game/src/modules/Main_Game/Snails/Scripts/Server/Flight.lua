--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local FlightHelper = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Flight")) --- @type Snails_Flight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The snails flying now, and their flights
local flights = {} --- @type { [Model]: Snails_FlightState }

local stepConnection: RBXScriptConnection?

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

--- @class Snails_Server_Flight
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Throw

--[[
	**SERVER** |
	Throws a snail on the game's own physics: its ball is anchored and flies a flight from where it is, at its speed
	plus the push (a snail already flying is thrown again from where its flight is). Every client draws the same flight
	from the snail's Flight attributes; it lands back on Roblox physics.
]]
function Module.Throw(model: Model, push: Vector3)
	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local flying = flights[model] --- @type Snails_FlightState?
	local from: Vector3 = if flying then flying.Body.Position else root.Position
	local velocity: Vector3 = (if flying then flying.Body.Velocity else root.AssemblyLinearVelocity) + push

	--[[ Launching ]]

	-- An anchored ball (already flying) has no owner to take back
	if not root.Anchored then
		root:SetNetworkOwner(nil)
	end
	root.Anchored = true
	root:FindFirstChild("Walk").Enabled = false
	flights[model] = FlightHelper.New(model, from, Vector3.new(velocity.X, velocity.Y, 0))

	--[[ Saving ]]

	-- The start goes last: clients start the flight when it changes, reading the rest
	model:SetAttribute("FlightFrom", from)
	model:SetAttribute("FlightVelocity", Vector3.new(velocity.X, velocity.Y, 0))
	model:SetAttribute("FlightStart", I.S.Workspace:GetServerTimeNow())

	--[[ Connections ]]

	if not stepConnection then
		stepConnection = I.S.RunService.Heartbeat:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves every flying snail along its flight this frame, and ends the flights that landed, ran too long, or whose snail
	was knocked out (its ghost stays anchored).
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = I.S.Workspace:GetServerTimeNow()

	--[[ Stepping ]]

	--- @param state Snails_FlightState
	for model: Model, state in pairs(flights) do
		local root: BasePart? = model.PrimaryPart
		local started: number = model:GetAttribute("FlightStart") or now
		if not root or not model.Parent or not model:GetAttribute("Alive") then
			Module._land(model, nil)
			continue
		end
		FlightHelper.Advance(state, now - started)
		FlightHelper.Apply(state, root)
		if FlightHelper.IsLanded(state) or now - started >= _settings.FLIGHT_MAX_SECONDS then
			Module._land(model, state)
		end
	end

	--[[ Connections ]]

	if not next(flights) and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Land

--[[
	Ends a snail's flight: hands its ball back to Roblox physics, server-owned, sliding on with FLIGHT_LAND_KEEP of its
	speed (nil state: a knocked-out snail, left as it is), and clears its Flight attributes.
]]
--- @param state Snails_FlightState?
function Module._land(model: Model, state)
	--[[ Applying ]]

	flights[model] = nil
	local root: BasePart? = model.PrimaryPart
	if state and root then
		root.Anchored = false
		root.AssemblyLinearVelocity = state.Body.Velocity * _settings.FLIGHT_LAND_KEEP
		root:SetNetworkOwner(nil)
	end

	--[[ Saving ]]

	model:SetAttribute("FlightStart", nil)
	model:SetAttribute("FlightFrom", nil)
	model:SetAttribute("FlightVelocity", nil)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Flying

--[[
	Returns whether a snail flies a throw now.
]]
--- @return boolean
function Module.IsFlying(model: Model)
	return flights[model] ~= nil
end

return Module
