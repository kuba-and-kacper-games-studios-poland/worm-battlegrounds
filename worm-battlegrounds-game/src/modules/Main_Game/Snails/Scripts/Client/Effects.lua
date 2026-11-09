--[[
	Created By: 	Nari
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
	Starts drawing a snail's effects: a puff where a new one appears, its flying trail, and healing crosses when its
	health goes up, until it's gone.
]]
function Module._watchSnail(model: Instance, appeared: boolean)
	--[[ Checks ]]

	-- Check if it's a snail with its ball
	if not model:IsA("Model") or not model.PrimaryPart then
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local trail: Trail? = I.Vfx.AddTrail("Trail_Snail", root)

	--[[ Saving ]]

	if trail then
		trail.Enabled = false
	end
	states[model] = {
		Health = model:GetAttribute("Health") or 0,
		LastRise = 0,
		Trail = trail,
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
	Every frame, shows each snail's trail while it flies faster than TRAIL_SPEED, and puffs dust where one lands after
	a fall (as fast as Snail_Land's).
]]
function Module._step()
	--[[ Watching ]]

	--- @param state Snails_EffectState
	for model: Model, state in pairs(states) do
		local root: BasePart? = model.PrimaryPart
		if not root then
			continue
		end
		local velocity: Vector3 = root.AssemblyLinearVelocity
		local alive: boolean = model:GetAttribute("Alive") == true

		if state.Trail then
			state.Trail.Enabled = alive and velocity.Magnitude > _settings.TRAIL_SPEED
		end
		if alive and state.LastRise < -_settings.LAND_SOUND_SPEED and velocity.Y > -_settings.LAND_SOUND_STOP then
			I.Vfx.Play("Fall", CFrame.new(root.Position - Vector3.yAxis * root.Size.Y / 2), effectsFolder)
		end

		state.LastRise = velocity.Y
	end
end

return Module
