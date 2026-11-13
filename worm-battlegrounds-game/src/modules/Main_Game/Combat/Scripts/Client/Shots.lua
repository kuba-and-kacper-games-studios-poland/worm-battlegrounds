--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Ballistics = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Ballistics")) --- @type Combat_Ballistics

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local effectsFolder: Instance

-- One fixed step of the simulation, and how many past steps each shot keeps to rewind to
local STEP: number = _settings.PROJECTILE_STEP
local HISTORY_STEPS: number = math.round(_settings.HISTORY_SECONDS / STEP)

-- The server's shots this client simulates, by id
local shots = {} --- @type { [number]: Combat_ClientShot }

-- What simulated shots touch here: as the server's, minus this client's own effects
local world = {} --- @type Combat_World

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

--- @class Combat_Client_Shots
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Folders ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	--[[ Saving ]]

	world.Params = RaycastParams.new()
	world.Params.CollisionGroup = "Projectile"
	world.Params.FilterType = Enum.RaycastFilterType.Exclude
	world.Exclude = { effectsFolder }
	world.IsLiquid = Module._isLiquid

	--[[ Connections ]]

	I.Network.Fired("Combat_Shot", Module._onShot)
	I.Network.UFired("Combat_ShotState", Module._onState)
	I.Network.Fired("Combat_ShotEnd", Module._onEnd)

	-- Before Flight draws the models on the parts, and the camera follows them
	I.S.RunService:BindToRenderStep("Combat_Shots", Enum.RenderPriority.Camera.Value - 2, Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Shot

--[[
	The server launched a shot: this client makes its own copy (a projectile part Flight draws the weapon on and the
	camera follows) and simulates it from the launch, catching up to the server's clock. A launcher's shot blasts out
	of it (LAUNCH_VFX).
]]
--- @param options Combat_ShotOptions
function Module._onShot(id: number, kind: string, name: string, start: number, position: Vector3, velocity: Vector3, options)
	--[[ Launch ]]

	local launch = _settings.LAUNCH_VFX[name] --- @type { string }?
	if launch and velocity.Magnitude > 1e-3 then
		for _index: number, vfx: string in ipairs(launch) do
			I.Vfx.Play(vfx, CFrame.lookAlong(position, velocity.Unit), effectsFolder, _settings.LAUNCH_VFX_SCALE)
		end
	end

	--[[ Building ]]

	local body = Ballistics.New(position, velocity, options) --- @type Combat_Body
	body.Id = id
	body.Kind = kind
	body.Name = name
	body.Start = start

	local part: Part = Ballistics.MakePart(kind, name, body.Position)
	local drawScale: number = (_settings.PROJECTILE_DRAW_SCALES[name] or _settings.PROJECTILE_DRAW_SCALE) * (options.DrawScale or 1)
	part.Size *= drawScale

	-- Flight draws the weapon's model at the same scale (a bomblet drawn as a small copy of its bomb)
	part:SetAttribute("DrawScale", drawScale)

	-- Moved here every frame, so Flight draws its model right on it
	part:SetAttribute("Simulated", true)
	part.Parent = effectsFolder

	--[[ Saving ]]

	--- @type Combat_ClientShot
	local shot = {
		Body = body,
		Part = part,
		History = { [0] = Ballistics.GetState(body) },
		Offset = Vector3.zero,
		LastBounce = 0,
		Whistled = false,
		Whistle = nil,
	}
	shots[id] = shot

	--[[ Catching Up ]]

	-- It arrives a moment after the server launched it: it catches up now, and its drawing eases out from the launch
	Module._catchUp(shot, math.floor((I.S.Workspace:GetServerTimeNow() - start) / STEP))
	shot.Offset = position - body.Position
end

--%%%%%%%%%%%%%%%%%%%% On State

--[[
	The server's state of a shot at one step: when this client's copy was elsewhere at that step, it goes back to the
	server's state there and steps again up to where it was, and the jump is smoothed out on screen (Offset).
]]
--- @param state Combat_BodyState
function Module._onState(id: number, state)
	--[[ Data ]]

	local shot = shots[id] --- @type Combat_ClientShot?
	if not shot then
		return
	end

	--[[ Local Variables ]]

	local body = shot.Body --- @type Combat_Body
	local mine = shot.History[state.Step] --- @type Combat_BodyState?

	--[[ Checks ]]

	-- Check if this copy was where the server's was
	if mine and (mine.Position - state.Position).Magnitude <= _settings.CORRECTION_TOLERANCE then
		return
	end

	--[[ Rewinding ]]

	local was: Vector3 = body.Position
	local reached: number = body.Step
	Ballistics.Load(body, state)
	--- @param _state Combat_BodyState
	for step: number, _state in pairs(shot.History) do
		if step > state.Step then
			shot.History[step] = nil
		end
	end
	shot.History[state.Step] = state

	--[[ Replaying ]]

	while body.Step < reached do
		Ballistics.Step(body, world)
		shot.History[body.Step] = Ballistics.GetState(body)
	end

	-- The copy moves over at once, but its drawing eases in from where it was
	shot.Offset += was - body.Position
end

--%%%%%%%%%%%%%%%%%%%% On End

--[[
	The server ended a shot: its copy goes, from where the server says it ended.
]]
function Module._onEnd(id: number, position: Vector3)
	--[[ Data ]]

	local shot = shots[id] --- @type Combat_ClientShot?
	if not shot then
		return
	end

	--[[ Removing ]]

	if shot.Whistle then
		shot.Whistle:Stop()
	end
	shot.Part.CFrame = CFrame.new(position)
	shot.Part:Destroy()
	shots[id] = nil
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame, steps each shot's copy up to one step past the server's clock and draws it between that step and the
	one before, so it moves smoothly at any frame rate, plus what's left of its last correction.
]]
function Module._step(deltaTime: number)
	--[[ Local Variables ]]

	local now: number = I.S.Workspace:GetServerTimeNow()
	local fade: number = math.exp(-deltaTime / _settings.CORRECTION_SMOOTH)

	--[[ Stepping ]]

	--- @param shot Combat_ClientShot
	for _id: number, shot in pairs(shots) do
		local body = shot.Body --- @type Combat_Body
		local time: number = math.max((now - body.Start) / STEP, 0)
		Module._catchUp(shot, math.floor(time) + 1)

		--[[ Drawing ]]

		local before = shot.History[body.Step - 1] or Ballistics.GetState(body) --- @type Combat_BodyState
		local alpha: number = math.clamp(time - (body.Step - 1), 0, 1)
		local position: Vector3 = before.Position:Lerp(body.Position, alpha)
		local angle: number = before.Angle + (body.Angle - before.Angle) * alpha
		shot.Offset *= fade
		shot.Part.CFrame = CFrame.new(position + shot.Offset) * CFrame.Angles(0, 0, angle)
		Module._whistle(shot)
	end
end

--%%%%%%%%%%%%%%%%%%%% Whistle

--[[
	Whistles a lobbed shot (WHISTLE_KINDS) once from its part as it starts coming down fast, and hushes it as it lands,
	rests or rises again.
]]
--- @param shot Combat_ClientShot
function Module._whistle(shot)
	--[[ Local Variables ]]

	local body = shot.Body --- @type Combat_Body

	--[[ Hushing ]]

	if shot.Whistle then
		if body.Stopped or body.Grounded or body.Sunk or body.Velocity.Y > 0 then
			shot.Whistle:Stop()
			shot.Whistle = nil
		end
		return
	end

	--[[ Checks ]]

	-- Check if it's a lobbed shot coming down fast for the first time
	if shot.Whistled or not _settings.WHISTLE_KINDS[body.Kind] or body.Velocity.Y > -_settings.WHISTLE_FALL_SPEED then
		return
	end

	--[[ Playing ]]

	shot.Whistled = true
	shot.Whistle = I.Sound.Play({
		Name = "Shot_Whistle",
		Location = shot.Part,
		SoundGroup = "SFX",
		Volume = 0.5,
		RollOffMin = _settings.SOUND_ROLLOFF_MIN,
		RollOffMax = _settings.SOUND_ROLLOFF_MAX,
	})
end

--%%%%%%%%%%%%%%%%%%%% Catch Up

--[[
	Steps a shot's copy up to a step, keeping each step's state for rewinding, never more than MAX_CATCH_UP steps at
	once, so a long stall doesn't freeze the screen. A bounce on the way plays Shot_Bounce.
]]
--- @param shot Combat_ClientShot
function Module._catchUp(shot, target: number)
	--[[ Local Variables ]]

	local body = shot.Body --- @type Combat_Body
	local limit: number = body.Step + _settings.MAX_CATCH_UP

	--[[ Stepping ]]

	while body.Step < target and body.Step < limit do
		local before: Vector3 = body.Velocity
		Ballistics.Step(body, world)
		shot.History[body.Step] = Ballistics.GetState(body)
		shot.History[body.Step - HISTORY_STEPS] = nil

		-- A stopped or sunk shot is bursting, not bouncing
		local change: number = (body.Velocity - before).Magnitude
		if change >= _settings.BOUNCE_SOUND_SPEED and not body.Stopped and not body.Sunk and os.clock() - shot.LastBounce >= _settings.BOUNCE_SOUND_GAP then
			shot.LastBounce = os.clock()
			I.Sound.Play({
				Name = "Shot_Bounce",
				Location = body.Position,
				SoundGroup = "SFX",
				Volume = math.clamp(change / 80, 0.15, 0.6),
				RollOffMin = _settings.SOUND_ROLLOFF_MIN,
				RollOffMax = _settings.SOUND_ROLLOFF_MAX,
				PitchMin = 0.9,
				PitchMax = 1.15,
			})
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Liquid

--[[
	Returns whether a position is in the arena's liquid as this client sees it: inside one of its drawn blocks (they
	block no queries, so their boxes are read).
]]
--- @return boolean
function Module._isLiquid(position: Vector3)
	--[[ Data ]]

	local arena: Instance? = I.Dirs.UmeWorkspace:FindFirstChild("Arena")
	local liquid: Instance? = if arena then arena:FindFirstChild("Liquid") else nil
	if not liquid then
		return false
	end

	--[[ Checking ]]

	for _index: number, block: Instance in ipairs(liquid:GetChildren()) do
		if block:IsA("BasePart") then
			local inside: Vector3 = block.CFrame:PointToObjectSpace(position)
			if math.abs(inside.X) <= block.Size.X / 2 and math.abs(inside.Y) <= block.Size.Y / 2 then
				return true
			end
		end
	end

	--[[ Returning ]]

	return false
end

return Module
