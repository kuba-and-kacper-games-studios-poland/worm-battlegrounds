--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
	Puts the active snail's weapon in its hands during its turn (a copy of the weapon's model, in the weapon's pose),
	swaps it when the snail picks another, and takes it away once the turn ends. When the shot is away, a gun with its
	own pose plays its shot first (for its whole burst) and goes after.
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

	if heldModel and holder then
		Module._putAway(holder, heldId, heldModel)
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
	I.SnailRig.Hold(snail:FindFirstChild("Skin"), itemId, heldModel)
	I.SnailRig.SetAim(snail:FindFirstChild("Skin"), heldAngle)
	heldModel.Parent = effectsFolder

	--[[ Connections ]]

	if not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Turns the held weapon toward the snail's aim each frame. On its player's own screen, a snail standing still also
	turns to face its aim, so the weapon never points back through its body.
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

	--[[ Facing ]]

	-- Walking turns the snail its own way (SnailControl), so only a snail standing still follows its aim
	local root: BasePart = snail.PrimaryPart
	local side: number = math.sign(math.cos(heldAngle))
	if snail == I.Snails.GetMine() and not root:FindFirstChild("Walk").Enabled and side ~= 0 then
		root:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis * side)
	end

	--[[ Aiming ]]

	I.SnailRig.SetAim(snail:FindFirstChild("Skin"), heldAngle)
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
		I.SnailRig.SetAim(holder:FindFirstChild("Skin"), angle)
	end
end

--%%%%%%%%%%%%%%%%%%%% Put Away

--[[
	Takes a weapon out of a snail's hands. When its shot is away (the match is in its Flight) and it's a gun with its
	own pose, it plays the shot first, for at least the gun's burst, then goes.
]]
function Module._putAway(snail: Model, itemId: string?, weapon: Model)
	--[[ Data ]]

	local skin: Instance? = snail:FindFirstChild("Skin")
	local row = itemId and I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData?

	--[[ Checks ]]

	-- Put a weapon that wasn't fired, or has no shot of its own, away at once
	if not skin or I.Match.GetPhase() ~= "Flight" or not row or not row.HoldPose then
		if skin then
			I.SnailRig.Hold(skin, nil)
		end
		weapon:Destroy()
		return
	end

	--[[ Shooting ]]

	local seconds: number = I.SnailRig.Shoot(skin, (row.Pellets or 1) * (row.BurstInterval or 0))
	task.delay(seconds, function()
		-- The snail may hold a new weapon by now, which replaced this one's hold
		if holder ~= snail and skin.Parent then
			I.SnailRig.Hold(skin, nil)
		end
		weapon:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

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
