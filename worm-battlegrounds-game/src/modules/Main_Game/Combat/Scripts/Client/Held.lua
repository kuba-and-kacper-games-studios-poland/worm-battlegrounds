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

local snailsFolder: Instance
local effectsFolder: Instance

--[[ Held ]]

-- The snail holding a weapon now, which weapon, its model in the world and the angle it points at
local holder: Model? = nil
local heldId: string? = nil
local heldModel: Model? = nil
local heldAngle: number = 0
local stepConnection: RBXScriptConnection?

-- The aim this screen draws for the holding snail (MatchHud's crosshair), which the weapon follows at once
local drawnAngle: number? = nil

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

	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")
	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Looks again at who holds what whenever a snail's turn, weapon or state changes.
]]
function Module._watchSnail(model: Instance)
	--[[ Connections ]]

	model.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Active" or attribute == "HeldItem" or attribute == "Alive" or attribute == "Ghost" then
			Module._refresh()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Puts the active snail's weapon in its hands during its turn (a copy of the weapon's model), swaps it when the snail
	picks another, and takes it away once the shot is away or the turn ends.
]]
function Module._refresh()
	--[[ Data ]]

	local snail: Model? = Module._getHolder()
	local itemId: string? = snail and snail:GetAttribute("HeldItem")

	--[[ Checks ]]

	-- Skip when nothing changes
	if snail == holder and itemId == heldId then
		return
	end

	--[[ Clearing ]]

	if heldModel then
		heldModel:Destroy()
		heldModel = nil
	end
	holder = snail
	heldId = itemId

	-- Stop following when no snail holds a weapon
	if not snail or not itemId then
		if stepConnection then
			stepConnection:Disconnect()
			stepConnection = nil
		end
		return
	end

	--[[ Building ]]

	heldModel = I.G_Arsenal.GetModel(itemId):Clone()
	heldAngle = drawnAngle or Module._getAimAngle(snail)
	Module._place(snail, heldAngle)
	heldModel.Parent = effectsFolder

	--[[ Connections ]]

	if not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Keeps the held weapon in the snail's hands each frame, turning it toward the snail's aim.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Check if the snail is still in play
	local snail: Model? = holder
	if not snail or not snail.PrimaryPart or not heldModel then
		Module._refresh()
		return
	end

	--[[ Turning ]]

	if drawnAngle then
		heldAngle = drawnAngle
	else
		local turn: number = ((Module._getAimAngle(snail) - heldAngle + math.pi) % (2 * math.pi)) - math.pi
		heldAngle += turn * (1 - math.exp(-_settings.HELD_TURN_SPEED * deltaTime))
	end

	--[[ Placing ]]

	Module._place(snail, heldAngle)
end

--%%%%%%%%%%%%%%%%%%%% Set Aim

--[[
	**CLIENT** |
	Points the held weapon along the aim this screen draws (the crosshair), at once, so it never trails the server's
	copy of the aim. nil hands it back to the snail's replicated aim.
]]
function Module.SetAim(angle: number?)
	--[[ Saving ]]

	drawnAngle = angle

	--[[ Placing ]]

	if angle and holder and holder.PrimaryPart and heldModel then
		heldAngle = angle
		Module._place(holder, angle)
	end
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Moves the held weapon to the snail's hands on the camera's side, its front along the angle and its top up.
]]
function Module._place(snail: Model, angle: number)
	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)

	-- Of the two sides square to the aim, the one facing up, so the weapon is never upside down
	local up: Vector3 = if direction.X >= 0 then Vector3.new(-direction.Y, direction.X, 0) else Vector3.new(direction.Y, -direction.X, 0)
	local position: Vector3 = snail.PrimaryPart.Position + direction * _settings.HELD_FORWARD + Vector3.new(0, _settings.HELD_HEIGHT, _settings.HELD_DEPTH)

	--[[ Applying ]]

	heldModel:PivotTo(CFrame.lookAlong(position, direction, up))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Muzzle

--[[
	**CLIENT** |
	Returns where the held weapon's shot leaves it (the `Muzzle` attachment on its RootPart), or nil when nothing is held
	or the weapon has no muzzle.
]]
--- @return Vector3?
function Module.GetMuzzle()
	--[[ Data ]]

	local muzzle: Attachment? = heldModel and heldModel.PrimaryPart and heldModel.PrimaryPart:FindFirstChild("Muzzle")

	--[[ Returning ]]

	return muzzle and muzzle.WorldPosition
end

--%%%%%%%%%%%%%%%%%%%% Get Holder

--[[
	Returns the snail that holds a weapon now: the active snail, alive, during its turn, holding a weapon with a model.
]]
--- @return Model?
function Module._getHolder()
	--[[ Checks ]]

	-- Check if a turn is on
	if I.Match.GetPhase() ~= "Turn" then
		return nil
	end

	--[[ Finding ]]

	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
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
	Returns where a snail's weapon points: its aim while its aim keeps arriving (AimTime), else the way it faces.
]]
--- @return number
function Module._getAimAngle(snail: Model)
	--[[ Local Variables ]]

	local aiming: boolean = I.S.Workspace:GetServerTimeNow() - (snail:GetAttribute("AimTime") or 0) <= I.Settings["MatchHud"].AIM_SHOW_GRACE

	--[[ Returning ]]

	if aiming then
		return snail:GetAttribute("AimAngle") or 0
	end
	return if snail:GetAttribute("Facing") == -1 then math.pi else 0
end

return Module
