--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local wormsFolder: Instance
local effectsFolder: Instance

--[[ Held ]]

-- The worm holding a weapon now, which weapon, its model in the world and the angle it points at
local holder: Model? = nil
local heldId: string? = nil
local heldModel: Model? = nil
local heldAngle: number = 0
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

--- @class Combat_Client_Held
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Folders ]]

	wormsFolder = I.Dirs.UmeWorkspace:WaitForChild("Worms")
	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Connections ]]

	wormsFolder.ChildAdded:Connect(Module._watchWorm)
	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		Module._watchWorm(model)
	end
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Worm

--[[
	Looks again at who holds what whenever a worm's turn, weapon or state changes.
]]
function Module._watchWorm(model: Instance)
	--[[ Connections ]]

	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Active" or attribute == "HeldItem" or attribute == "Alive" or attribute == "Ghost" then
			Module._refresh()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Puts the active worm's weapon in its hands during its turn (a copy of the weapon's model), swaps it when the worm
	picks another, and takes it away once the shot is away or the turn ends.
]]
function Module._refresh()
	--[[ Data ]]

	local worm: Model? = Module._getHolder()
	local itemId: string? = worm and worm:GetAttribute("HeldItem")

	--[[ Checks ]]

	-- Skip when nothing changes
	if worm == holder and itemId == heldId then
		return
	end

	--[[ Clearing ]]

	if heldModel then
		heldModel:Destroy()
		heldModel = nil
	end
	holder = worm
	heldId = itemId

	-- Stop following when no worm holds a weapon
	if not worm or not itemId then
		if stepConnection then
			stepConnection:Disconnect()
			stepConnection = nil
		end
		return
	end

	--[[ Building ]]

	heldModel = I.G_Arsenal.GetModel(itemId):Clone()
	heldAngle = Module._getAimAngle(worm)
	Module._place(worm, heldAngle)
	heldModel.Parent = effectsFolder

	--[[ Connections ]]

	if not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Keeps the held weapon in the worm's hands each frame, turning it toward the worm's aim.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Check if the worm is still in play
	local worm: Model? = holder
	if not worm or not worm.PrimaryPart or not heldModel then
		Module._refresh()
		return
	end

	--[[ Turning ]]

	local turn: number = ((Module._getAimAngle(worm) - heldAngle + math.pi) % (2 * math.pi)) - math.pi
	heldAngle += turn * (1 - math.exp(-_settings.HELD_TURN_SPEED * deltaTime))

	--[[ Placing ]]

	Module._place(worm, heldAngle)
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Moves the held weapon to the worm's hands on the camera's side, its front along the angle and its top up.
]]
function Module._place(worm: Model, angle: number)
	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)

	-- Of the two sides square to the aim, the one facing up, so the weapon is never upside down
	local up: Vector3 = if direction.X >= 0 then Vector3.new(-direction.Y, direction.X, 0) else Vector3.new(direction.Y, -direction.X, 0)
	local position: Vector3 = worm.PrimaryPart.Position + direction * _settings.HELD_FORWARD + Vector3.new(0, _settings.HELD_HEIGHT, _settings.HELD_DEPTH)

	--[[ Applying ]]

	heldModel:PivotTo(CFrame.lookAlong(position, direction, up))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Holder

--[[
	Returns the worm that holds a weapon now: the active worm, alive, during its turn, holding a weapon with a model.
]]
--- @return Model?
function Module._getHolder()
	--[[ Checks ]]

	-- Check if a turn is on
	if I.Match.GetPhase() ~= "Turn" then
		return nil
	end

	--[[ Finding ]]

	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		local itemId: string? = model:GetAttribute("HeldItem")
		if model:IsA("Model") and model:GetAttribute("Active") and model:GetAttribute("Alive") and not model:GetAttribute("Ghost") and model.PrimaryPart and itemId and I.G_Arsenal.HasModel(itemId) then
			return model
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Aim Angle

--[[
	Returns where a worm's weapon points: its aim while its aim keeps arriving (AimTime), else the way it faces.
]]
--- @return number
function Module._getAimAngle(worm: Model)
	--[[ Local Variables ]]

	local aiming: boolean = I.S.Workspace:GetServerTimeNow() - (worm:GetAttribute("AimTime") or 0) <= I.Settings["MatchHud"].AIM_SHOW_GRACE

	--[[ Returning ]]

	if aiming then
		return worm:GetAttribute("AimAngle") or 0
	end
	return if worm:GetAttribute("Facing") == -1 then math.pi else 0
end

return Module
