--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local snailsFolder: Folder

-- Snails hiding in their shell, thrown and not yet landed, with when they hid (os.clock)
local hidden = {} --- @type { [Model]: number }

-- Casts that hit only what snails stand on
--- @type RaycastParams
local groundParams = RaycastParams.new()

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

--- @class Snails_Client_Motion
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Saving ]]

	snailsFolder = folder
	groundParams.CollisionGroup = "Snail"

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._step)
	I.Network.Fired("Combat_Hit", Module._onHit)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Animates every snail's skin from how its ball moves: it walks while it moves along the ground (never in the air,
	where a jetpack or a jump carries it), hides in its shell when it's hit or thrown (another's snail faster than
	HIDE_SPEED: the active one's own jumps and falls don't count), comes out HIDE_SECONDS after once it's slower than
	SHOW_SPEED or, whose turn it is, walks, and idles otherwise.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Animating ]]

	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		local skin: Instance? = model:FindFirstChild("Skin")
		local root: BasePart? = model:IsA("Model") and model.PrimaryPart
		if not skin or not root then
			continue
		end

		local velocity: Vector3 = root.AssemblyLinearVelocity
		local speed: number = velocity.Magnitude
		local walking: boolean = math.abs(velocity.X) > _settings.WALK_ANIMATION_SPEED and math.abs(velocity.Y) < _settings.STEP_SOUND_MAX_RISE and Module._isGrounded(root.Position)
		local active: boolean = model:GetAttribute("Active") == true

		-- Bots never get CanMove, so it's the turn, not the controls, that tells a snail's own jump from a throw
		if model:GetAttribute("Ghost") or (now - (hidden[model] or 0) >= _settings.HIDE_SECONDS and (speed < _settings.SHOW_SPEED or walking and active)) then
			hidden[model] = nil
		elseif speed > _settings.HIDE_SPEED and (hidden[model] or not active) then
			hidden[model] = now
		end

		I.SnailRig.SetMotion(skin, if hidden[model] then "Hidden" elseif walking then "Walk" else "Idle")
	end

	--[[ Clearing ]]

	for model: Model, _since: number in pairs(hidden) do
		if not model.Parent then
			hidden[model] = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Hit

--[[
	Pulls a snail into its shell the moment it's hit, before its knockback reaches this screen.
]]
function Module._onHit(participantId: string, damage: number, _position: Vector3, _knockout: boolean?)
	--[[ Data ]]

	local model: Instance? = snailsFolder:FindFirstChild(participantId)

	--[[ Checks ]]

	-- Check if the hit hurt a snail that's here
	if damage <= 0 or not model or not model:IsA("Model") then
		return
	end

	--[[ Hiding ]]

	hidden[model] = os.clock()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	Returns whether a snail whose ball is centered at a position stands on something, as SnailControl checks it.
]]
--- @return boolean
function Module._isGrounded(position: Vector3)
	--[[ Local Variables ]]

	-- A slightly smaller sphere, cast down, finds ground under any part of the ball
	local shrink: number = 0.15
	local radius: number = _settings.ROOT_SIZE / 2 - shrink

	--[[ Returning ]]

	return I.S.Workspace:Spherecast(position, radius, Vector3.new(0, -(shrink + _settings.GROUND_GAP), 0), groundParams) ~= nil
end

return Module
