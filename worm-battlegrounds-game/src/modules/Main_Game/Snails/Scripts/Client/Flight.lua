--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local FlightHelper = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Flight")) --- @type Snails_Flight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The snails this screen draws flying now, and their flights
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

--- @class Snails_Client_Flight
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(snailsFolder: Folder)
	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Starts drawing a snail's flight whenever the server throws it (its FlightStart changes) and stops when it lands.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Connections ]]

	model:GetAttributeChangedSignal("FlightStart"):Connect(function()
		Module._refresh(model)
	end)
	model.Destroying:Connect(function()
		flights[model] = nil
	end)

	--[[ Refreshing ]]

	Module._refresh(model)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Starts this screen's copy of a snail's flight from its Flight attributes, or forgets it once they're cleared (the
	server's landed ball takes over).
]]
--- @param model Model
function Module._refresh(model)
	--[[ Data ]]

	local from: Vector3? = model:GetAttribute("FlightFrom")
	local velocity: Vector3? = model:GetAttribute("FlightVelocity")

	--[[ Applying ]]

	flights[model] = if from and velocity and model:GetAttribute("FlightStart") then FlightHelper.New(model, from, velocity) else nil

	--[[ Connections ]]

	if next(flights) and not stepConnection then
		stepConnection = I.S.RunService.PreRender:Connect(Module._step)
	elseif not next(flights) and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves each flying snail's ball along this screen's copy of its flight, on the server's clock, before the frame is
	drawn; it waits where it landed until the server lands it too. A snail knocked out mid-flight is its ghost's to move.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = I.S.Workspace:GetServerTimeNow()

	--[[ Stepping ]]

	--- @param state Snails_FlightState
	for model: Model, state in pairs(flights) do
		local root: BasePart? = model.PrimaryPart
		local started: number? = model:GetAttribute("FlightStart")
		if root and started and root.Anchored and model:GetAttribute("Alive") ~= false then
			FlightHelper.Advance(state, now - started)
			FlightHelper.Apply(state, root)
		end
	end
end

return Module
