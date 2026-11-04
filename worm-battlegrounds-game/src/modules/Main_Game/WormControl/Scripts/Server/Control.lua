--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WormControl"

--- @type WormControl_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type WormControl_Server_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The worms their players move right now, by participant id
local controls = {} --- @type { [string]: WormControl_Control }

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

--- @class WormControl_Server_Control
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._check)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Start Turn

--[[
	**SERVER** |
	Lets a worm's player move it: their client gets its physics, its Stamina fills and CanMove turns on. Returns
	whether it started (a worm out of play, or a bot's, can't).
]]
--- @return boolean
function Module.StartTurn(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Worms.Get(participantId)

	--[[ Checks ]]

	-- Check if the worm is in play
	if not model or not model:GetAttribute("Alive") then
		return false
	end

	--[[ Data ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(model:GetAttribute("UserId"))

	--[[ Checks ]]

	-- Check if a player in this server moves it
	if not player then
		return false
	end

	--[[ Saving ]]

	local position: Vector3 = model.PrimaryPart.Position
	controls[participantId] = {
		Player = player,
		LastX = position.X,
		Overdraft = 0,
		Good = position,
		GoodTime = os.clock(),
	}
	model:SetAttribute("Stamina", _settings.STAMINA_STUDS)
	model:SetAttribute("CanMove", true)

	--[[ Applying ]]

	I.Worms.SetOwner(participantId, player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% End Turn

--[[
	**SERVER** |
	Takes a worm back from its player: CanMove turns off and the server owns its physics again, facing the way the
	player left it. Call it before anything hits the worm.
]]
function Module.EndTurn(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Worms.Get(participantId)

	--[[ Saving ]]

	controls[participantId] = nil

	--[[ Checks ]]

	-- Check if the worm still exists
	if not model then
		return
	end

	--[[ Applying ]]

	model:SetAttribute("CanMove", false)
	Effects.ClearTurnEffects(participantId)

	-- Ghosts are anchored and owned by the server already
	if not model:GetAttribute("Alive") then
		return
	end

	local facing: number = if model.PrimaryPart.CFrame.LookVector.X < 0 then -1 else 1
	model.PrimaryPart:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.new(facing, 0, 0))
	model:SetAttribute("Facing", facing)
	I.Worms.SetOwner(participantId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Check

--[[
	Checks every worm its player moves, each frame.
]]
function Module._check()
	--[[ Checking ]]

	--- @param control WormControl_Control
	for participantId: string, control in pairs(controls) do
		Module._checkWorm(participantId, control)
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Worm

--[[
	Snaps a worm back where it last was and takes it from its player when it moved faster than walking or jumping
	allows; otherwise charges the distance it moved sideways to its Stamina, and snaps it back too when it moved
	more than STAMINA_GRACE past an empty bar.
]]
--- @param control WormControl_Control
function Module._checkWorm(participantId: string, control)
	--[[ Data ]]

	local model: Model? = I.Worms.Get(participantId)

	--[[ Checks ]]

	-- Check if the worm is in play and its player still here
	if not model or not model:GetAttribute("Alive") or not control.Player.Parent then
		Module.EndTurn(participantId)
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local position: Vector3 = root.Position
	local now: number = os.clock()
	local elapsed: number = now - control.GoodTime
	local sideways: number = math.abs(position.X - control.Good.X)
	local upwards: number = position.Y - control.Good.Y
	local speedMultiplier: number = model:GetAttribute("SpeedMultiplier") or 1

	--[[ Speed ]]

	-- Snap it back when it moved faster than its player could have made it
	-- Positions reach the server in bursts, so it always allows at least one interval's worth of movement
	local tolerance: number = _settings.SPEED_TOLERANCE * math.max(elapsed, _settings.CHECK_INTERVAL)
	if sideways > _settings.WALK_SPEED * speedMultiplier * tolerance + _settings.MOVE_SLACK or upwards > _settings.JUMP_SPEED * tolerance + _settings.MOVE_SLACK then
		Module._snapBack(participantId, control, "moved too fast")
		return
	end

	if elapsed >= _settings.CHECK_INTERVAL then
		control.Good = position
		control.GoodTime = now
	end

	--[[ Stamina ]]

	-- An empty bar only stops the walk on its client: the worm keeps its turn, and can still jump; speed stretches it
	local moved: number = math.abs(position.X - control.LastX) / speedMultiplier
	local stamina: number = model:GetAttribute("Stamina")
	control.LastX = position.X
	control.Overdraft += math.max(moved - stamina, 0)
	model:SetAttribute("Stamina", math.max(stamina - moved, 0))

	-- Snap it back when it kept going well past an empty bar
	if control.Overdraft > _settings.STAMINA_GRACE then
		Module._snapBack(participantId, control, "walked past its stamina")
	end
end

--%%%%%%%%%%%%%%%%%%%% Snap Back

--[[
	Takes a worm from its player for breaking a check, and puts it back where it last was, at rest.
]]
--- @param control WormControl_Control
function Module._snapBack(participantId: string, control, reason: string)
	--[[ Local Variables ]]

	local root: BasePart = I.Worms.Get(participantId).PrimaryPart

	--[[ Applying ]]

	warn(`[{_localName}::{script.Name}]: Worm ({participantId}) {reason} - snapped back.`)
	Module.EndTurn(participantId)
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = CFrame.new(control.Good) * root.CFrame.Rotation
end

return Module
