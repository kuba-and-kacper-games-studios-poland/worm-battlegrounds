--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "SnailControl"

--- @type SnailControl_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Snails whose parachute has been in the air, so one opened on the ground waits for a fall before it closes
local airborne = setmetatable({}, { __mode = "k" }) --- @type { [Model]: boolean }

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

--- @class SnailControl_Server_Effects
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._checkParachutes)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply Effect

--[[
	**SERVER** |
	Gives a snail a movement effect: "Parachute" (falls slowly and takes no fall damage until it lands), "Jetpack" (fuel
	its player flies with while holding jump, kept from turn to turn until it's spent), "Speed" (walks faster and further this turn) or "LowGravity" (jumps
	higher and falls slower this turn). Shiny copies give a little more. Returns whether it applied.
]]
--- @return boolean
function Module.ApplyEffect(participantId: string, effect: string, shiny: boolean?)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model:GetAttribute("Alive") then
		return false
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local boost = _settings.SHINY_BOOST --- @type { [string]: number }
	local scale: number = if shiny then boost[effect] or 1 else 1

	--[[ Applying ]]

	if effect == "Parachute" then
		local chute: LinearVelocity = root:FindFirstChild("Chute")
		chute.LineVelocity = -_settings.PARACHUTE_FALL_SPEED * scale
		chute.Enabled = true
		airborne[model] = nil
		model:SetAttribute("Parachute", true)
	elseif effect == "Jetpack" then
		model:SetAttribute("JetpackFuel", _settings.JETPACK_FUEL * scale)
	elseif effect == "Speed" then
		model:SetAttribute("SpeedMultiplier", _settings.SPEED_MULTIPLIER * scale)
	elseif effect == "LowGravity" then
		local lift: VectorForce = root:FindFirstChild("Lift")
		lift.Force = Vector3.yAxis * root:GetMass() * I.S.Workspace.Gravity * (1 - I.Settings["Snails"].GRAVITY_SCALE * _settings.LOW_GRAVITY_SCALE * scale)
		model:SetAttribute("LowGravity", true)
	else
		warn(`[{_localName}::{script.Name}]: ({effect}) is not a movement effect!`)
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Clear Turn Effects

--[[
	**SERVER** |
	Ends the effects that last a turn (speed, low gravity); an open parachute stays until the snail lands, and jetpack
	fuel until it's spent.
]]
function Module.ClearTurnEffects(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)
	if not model then
		return
	end

	--[[ Applying ]]

	-- Back to the weight every snail feels (the ball's own mass: an anchored assembly's, mid-throw, is infinite)
	local root: BasePart = model.PrimaryPart
	root:FindFirstChild("Lift").Force = Vector3.yAxis * root:GetMass() * I.S.Workspace.Gravity * (1 - I.Settings["Snails"].GRAVITY_SCALE)
	model:SetAttribute("SpeedMultiplier", nil)
	model:SetAttribute("LowGravity", nil)
end

--%%%%%%%%%%%%%%%%%%%% Close Parachute

--[[
	**SERVER** |
	Closes a snail's parachute, when it has one open: the match's landing closes any still open once it's over, so no
	snail starts its turn under one.
]]
function Module.CloseParachute(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail has its parachute open
	if not model or not model:GetAttribute("Parachute") then
		return
	end

	--[[ Closing ]]

	model.PrimaryPart:FindFirstChild("Chute").Enabled = false
	model:SetAttribute("Parachute", nil)
	airborne[model] = nil
end

--%%%%%%%%%%%%%%%%%%%% Check Parachutes

--[[
	Closes the parachute of every snail that landed after it opened, or that came down into water or lava (the owner,
	2026-11-15: a snail that landed in Volcano Isle's chamber pool kept its parachute and couldn't move).
]]
function Module._checkParachutes()
	--[[ Checking ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		if not model:GetAttribute("Parachute") then
			continue
		end
		local grounded: boolean = I.Snails.IsGrounded(model.Name)
		if I.Arena.GetLiquid(model.PrimaryPart.Position) or grounded and airborne[model] then
			Module.CloseParachute(model.Name)
		elseif not grounded then
			airborne[model] = true
		end
	end
end

return Module
