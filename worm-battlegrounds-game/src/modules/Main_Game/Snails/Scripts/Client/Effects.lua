--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local snailsFolder: Folder
local effectsFolder: Instance

--[[ State ]]

-- What each snail's effects remember between frames, by snail
local states = {} --- @type { [Model]: Snails_EffectState }

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

--- @class Snails_Client_Effects
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Folders ]]

	snailsFolder = folder
	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild("Combat")

	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(function(model: Instance)
		Module._watchSnail(model, true)
	end)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model, false)
	end
	I.Network.Fired("Match_KnockedOut", Module._onKnockedOut)
	I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Starts drawing a snail's effects: a puff where a new one appears, its flying trail, its jetpack's jet, and healing
	crosses when its health goes up, until it's gone.
]]
function Module._watchSnail(model: Instance, appeared: boolean)
	--[[ Checks ]]

	-- Check if it's a snail with its ball
	if not model:IsA("Model") or not model.PrimaryPart then
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local trails = I.Vfx.AddTrail("Trail_Snail", root) --- @type { Trail }
	local jet = I.Vfx.AddTrail("Trail_Jet", root) --- @type { Trail }

	--[[ Saving ]]

	for _index: number, trail: Trail in ipairs(trails) do
		trail.Enabled = false
	end
	-- The jet comes out under the jetpack, its attachments along Z so it keeps its width (trails may share them)
	local moved = {} --- @type { [Attachment]: boolean }
	for _index: number, trail: Trail in ipairs(jet) do
		trail.Enabled = false
		for _index2: number, attachment: Attachment in ipairs({ trail.Attachment0, trail.Attachment1 }) do
			if not moved[attachment] then
				moved[attachment] = true
				local offset: Vector3 = attachment.Position
				attachment.Position = Vector3.new(0, offset.Y, offset.X + offset.Z) + _settings.JET_TRAIL_OFFSET
			end
		end
	end
	states[model] = {
		Health = model:GetAttribute("Health") or 0,
		LastRise = 0,
		Trails = trails,
		Jet = jet,
		Climbing = 0,
		Resting = 0,
		Jetting = false,
	}

	--[[ Effects ]]

	if appeared then
		I.Vfx.Play("Spawn", CFrame.new(root.Position), effectsFolder)
	end

	--[[ Connections ]]

	model:GetAttributeChangedSignal("Health"):Connect(function()
		Module._onHealth(model)
	end)
	model.Destroying:Connect(function()
		states[model] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Health

--[[
	Rises healing crosses from a snail in play whose health goes up.
]]
--- @param model Model
function Module._onHealth(model)
	--[[ Data ]]

	local state = states[model] --- @type Snails_EffectState?
	if not state then
		return
	end

	--[[ Local Variables ]]

	local health: number = model:GetAttribute("Health") or 0
	local healed: boolean = health > state.Health and state.Health > 0

	--[[ Saving ]]

	state.Health = health

	--[[ Effects ]]

	if healed and model:GetAttribute("Alive") and model.PrimaryPart then
		I.Vfx.Play("Healing", CFrame.new(model.PrimaryPart.Position), effectsFolder, _settings.HEAL_VFX_SCALE)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Knocked Out

--[[
	Splashes where a snail falls into water or lava.
]]
function Module._onKnockedOut(participantId: string, cause: string)
	--[[ Data ]]

	local model: Model? = snailsFolder:FindFirstChild(participantId)

	--[[ Checks ]]

	-- Check if the snail is here and fell into a liquid
	if not model or not model.PrimaryPart or (cause ~= "Water" and cause ~= "Lava") then
		return
	end

	--[[ Effects ]]

	I.Vfx.Play(if cause == "Water" then "Splash_Water" else "Splash_Lava", CFrame.new(model.PrimaryPart.Position), effectsFolder)
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame, shows each snail's trail while it flies faster than TRAIL_SPEED, the active snail's jet while it climbs
	on its jetpack (as its hum: Sounds), and puffs dust where one lands after a fall (as fast as Snail_Land's).
]]
function Module._step(deltaTime: number)
	--[[ Watching ]]

	--- @param state Snails_EffectState
	for model: Model, state in pairs(states) do
		local root: BasePart? = model.PrimaryPart
		if not root then
			continue
		end
		local velocity: Vector3 = root.AssemblyLinearVelocity
		local alive: boolean = model:GetAttribute("Alive") == true
		local flying: boolean = alive and velocity.Magnitude > _settings.TRAIL_SPEED

		-- A jump passes through the climbing speeds too fast to count
		local climbing: boolean = alive and model:GetAttribute("Active") == true and model:GetAttribute("JetpackFuel") ~= nil and velocity.Y > _settings.JETPACK_SOUND_RISE and velocity.Y < _settings.JUMP_SOUND_SPEED
		state.Climbing = if climbing then state.Climbing + deltaTime else 0
		state.Resting = if climbing then 0 else state.Resting + deltaTime
		if state.Climbing >= _settings.JETPACK_SOUND_HOLD then
			state.Jetting = true
		elseif state.Resting >= _settings.JETPACK_SOUND_HOLD or not alive then
			state.Jetting = false
		end

		for _index: number, trail: Trail in ipairs(state.Trails) do
			trail.Enabled = flying
		end
		for _index: number, trail: Trail in ipairs(state.Jet) do
			trail.Enabled = state.Jetting
		end
		if alive and state.LastRise < -_settings.LAND_SOUND_SPEED and velocity.Y > -_settings.LAND_SOUND_STOP then
			I.Vfx.Play("Fall", CFrame.new(root.Position - Vector3.yAxis * root.Size.Y / 2), effectsFolder)
		end

		state.LastRise = velocity.Y
	end
end

return Module
