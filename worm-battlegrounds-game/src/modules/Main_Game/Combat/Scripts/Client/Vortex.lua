--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Flight = require(script.Parent:FindFirstChild("Flight")) --- @type Combat_Client_Flight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The open black holes this screen draws, and whether their step is bound
local vortices = {} --- @type { Combat_Vortex }
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

--- @class Combat_Client_Vortex
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.Network.Fired("Combat_HoleOpened", Module._onOpened)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	A black hole opened: its whomp sounds, its hum loops, and VORTEX_ARMS carriers of its trail start orbiting it (the
	still hole drew no trail of its own), closing in and spinning faster until it collapses and bursts.
]]
function Module._onOpened(center: Vector3, seconds: number)
	--[[ Sounds ]]

	Module._play("BlackHole_Open", center)
	local hum: Sound? = Module._play("BlackHole_Hum", center, true)
	task.delay(math.max(seconds - _settings.VORTEX_COLLAPSE, 0), function()
		if hum then
			hum:Stop()
		end
		Module._play("BlackHole_Collapse", center)
	end)
	task.delay(seconds, function()
		Module._play("BlackHole_Burst", center)
	end)

	--[[ Building ]]

	local arms = {} --- @type { BasePart }
	for _index: number = 1, _settings.VORTEX_ARMS do
		table.insert(arms, Flight.MakeTrailCarrier(_settings.VORTEX_TRAIL, center, "VortexArm"))
	end

	--[[ Saving ]]

	table.insert(vortices, {
		Center = center,
		Arms = arms,
		Started = os.clock(),
		Seconds = seconds,
		Angle = 0,
	})
	stepConnection = stepConnection or I.S.RunService.Heartbeat:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame, turns each open hole's arms round its middle, closing in as it nears its burst, and clears away the
	ones that burst once their trails faded.
]]
function Module._step(deltaTime: number)
	--[[ Stepping ]]

	for index: number = #vortices, 1, -1 do
		local vortex = vortices[index] --- @type Combat_Vortex
		local elapsed: number = os.clock() - vortex.Started
		local share: number = math.clamp(elapsed / vortex.Seconds, 0, 1)
		local radius: number = _settings.VORTEX_RADIUS + (_settings.VORTEX_END_RADIUS - _settings.VORTEX_RADIUS) * share * share
		vortex.Angle += (_settings.VORTEX_SPIN + _settings.VORTEX_SPIN_GROWTH * elapsed) * 2 * math.pi * deltaTime

		--[[ Placing ]]

		for armIndex: number, arm: BasePart in ipairs(vortex.Arms) do
			local angle: number = vortex.Angle + (armIndex - 1) * 2 * math.pi / #vortex.Arms
			arm.CFrame = CFrame.new(vortex.Center + Vector3.new(math.cos(angle), math.sin(angle), 0) * radius)
		end

		--[[ Clearing ]]

		if elapsed >= vortex.Seconds + 1 then
			for _armIndex: number, arm: BasePart in ipairs(vortex.Arms) do
				arm:Destroy()
			end
			table.remove(vortices, index)
		end
	end

	--[[ Stopping ]]

	if #vortices == 0 and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a black hole sound where it is, heard as far as the camera can be; looped when asked. Returns the sound.
]]
--- @return Sound?
function Module._play(name: string, position: Vector3, looped: boolean?)
	--[[ Returning ]]

	return I.Sound.Play({
		Name = name,
		Location = position,
		SoundGroup = "SFX",
		Looped = looped == true,
		RollOffMin = _settings.SOUND_ROLLOFF_MIN,
		RollOffMax = _settings.SOUND_ROLLOFF_MAX,
	})
end

return Module
