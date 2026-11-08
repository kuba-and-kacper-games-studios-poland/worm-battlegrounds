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

-- What each snail's sounds remember between frames, by snail
local states = {} --- @type { [Model]: Snails_SoundState }

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

--- @class Snails_Client_Sounds
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Saving ]]

	snailsFolder = folder

	--[[ Connections ]]

	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
	I.Network.Fired("Match_KnockedOut", Module._onKnockedOut)
	I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Starts hearing a snail: its hurts from its health, its moves every frame, until it's gone.
]]
function Module._watchSnail(model: Instance)
	--[[ Checks ]]

	-- Check if it's a snail
	if not model:IsA("Model") then
		return
	end

	--[[ Saving ]]

	states[model] = {
		Health = model:GetAttribute("Health") or 0,
		LastRise = 0,
		Walked = 0,
		Climbing = 0,
		Resting = 0,
	}

	--[[ Connections ]]

	model:GetAttributeChangedSignal("Health"):Connect(function()
		Module._onHealth(model)
	end)
	model.Destroying:Connect(function()
		Module._stopJetpack(states[model])
		states[model] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Health

--[[
	Plays Snail_Hurt when a snail in play loses health.
]]
--- @param model Model
function Module._onHealth(model)
	--[[ Data ]]

	local state = states[model] --- @type Snails_SoundState?
	if not state then
		return
	end

	--[[ Local Variables ]]

	local health: number = model:GetAttribute("Health") or 0
	local hurt: boolean = health < state.Health

	--[[ Saving ]]

	state.Health = health

	--[[ Playing ]]

	if hurt and model:GetAttribute("Alive") and model.PrimaryPart then
		Module._play("Snail_Hurt", model.PrimaryPart)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Knocked Out

--[[
	Plays a knocked-out snail's sound: a splash in water, a burn in lava, a fall otherwise; nothing for a player who
	left.
]]
function Module._onKnockedOut(participantId: string, cause: string)
	--[[ Data ]]

	local model: Model? = snailsFolder:FindFirstChild(participantId)

	--[[ Checks ]]

	-- Check if the snail is here and didn't just leave
	if not model or not model.PrimaryPart or cause == "Left" then
		return
	end

	--[[ Playing ]]

	Module._play(if cause == "Water" then "Snail_Splash" elseif cause == "Lava" then "Snail_Burn" else "Snail_KnockedOut", model.PrimaryPart.Position)
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame, listens to how each snail in play moves: any snail lands with a thud after a fall; the active one
	squishes as it walks, boings as it jumps, and hums while its jetpack climbs.
]]
function Module._step(deltaTime: number)
	--[[ Listening ]]

	--- @param state Snails_SoundState
	for model: Model, state in pairs(states) do
		local root: BasePart? = model.PrimaryPart
		if not root or not model:GetAttribute("Alive") then
			Module._stopJetpack(state)
			continue
		end
		local velocity: Vector3 = root.AssemblyLinearVelocity
		local rise: number = velocity.Y
		local active: boolean = model:GetAttribute("Active") == true

		--[[ Landing ]]

		if state.LastRise < -_settings.LAND_SOUND_SPEED and rise > -_settings.LAND_SOUND_STOP then
			Module._play("Snail_Land", root.Position, math.clamp(-state.LastRise / 120, 0.3, 0.8))
		end

		--[[ Jumping ]]

		if active and state.LastRise < _settings.JUMP_SOUND_FROM and rise > _settings.JUMP_SOUND_SPEED then
			Module._play("Snail_Jump", root)
		end

		--[[ Walking ]]

		if active and math.abs(rise) < _settings.STEP_SOUND_MAX_RISE and math.abs(velocity.X) > 1 then
			state.Walked += math.abs(velocity.X) * deltaTime
			if state.Walked >= _settings.STEP_SOUND_DISTANCE then
				state.Walked = 0
				Module._play("Snail_Step", root, 0.35)
			end
		end

		--[[ Jetpack ]]

		local climbing: boolean = active and model:GetAttribute("JetpackFuel") ~= nil and rise > _settings.JETPACK_SOUND_RISE and rise < _settings.JUMP_SOUND_SPEED
		state.Climbing = if climbing then state.Climbing + deltaTime else 0
		state.Resting = if climbing then 0 else state.Resting + deltaTime
		if not state.Jetpack and state.Climbing >= _settings.JETPACK_SOUND_HOLD then
			state.Jetpack = I.Sound.Play({
				Name = "Snail_Jetpack",
				Location = root,
				SoundGroup = "SFX",
				Looped = true,
				RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
				RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
			})
		elseif state.Resting >= _settings.JETPACK_SOUND_HOLD then
			Module._stopJetpack(state)
		end

		state.LastRise = rise
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop Jetpack

--[[
	Stops a snail's jetpack hum, if it plays.
]]
--- @param state Snails_SoundState?
function Module._stopJetpack(state)
	--[[ Checks ]]

	-- Check if the hum plays
	if not state or not state.Jetpack then
		return
	end

	--[[ Stopping ]]

	state.Jetpack:Destroy()
	state.Jetpack = nil
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a snail's sound from it (or where it was), within Combat's sound range, a little higher or lower each time.
]]
function Module._play(name: string, location: BasePart | Vector3, volume: number?)
	I.Sound.Play({
		Name = name,
		Location = location,
		SoundGroup = "SFX",
		Volume = volume,
		RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
		RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
		PitchMin = 0.92,
		PitchMax = 1.08,
	})
end

return Module
