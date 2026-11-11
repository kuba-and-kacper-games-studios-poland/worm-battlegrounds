--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Liquids = require(script.Parent:FindFirstChild("Liquids")) --- @type Atmosphere_Client_Liquids
local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Atmosphere_Client_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local worldFolder: Instance
local arenaFolder: Instance?
local lobbyFolder: Instance?

--[[ State ]]

-- The mood whose particles show, the map bounds they fill (nil in the lobby), and a count of moods shown
local profile = nil --- @type Atmosphere_Profile?
local bounds: BasePart? = nil
local shown: number = 0

-- The ambient areas showing, and the wind they drift with
local streams = {} --- @type { Atmosphere_Stream }
local wind: number = 0

-- When each of the mood's Surface rows plays next, and its Ceiling
local surfaceTimes = {} --- @type { number }
local ceilingTime: number = math.huge

-- The lobby stage's clouds drifting, played only while the lobby shows
local cloudTweens = {} --- @type { Tween }

local random: Random = Random.new()

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

--- @class Atmosphere_Client_Ambient
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(world: Instance, arena: Instance?, lobby: Instance?)
	--[[ Folders ]]

	worldFolder = world
	arenaFolder = arena
	lobbyFolder = lobby

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._step)

	--[[ Starting ]]

	-- The stage is built by the Lobby module, on its own thread
	if lobbyFolder then
		task.spawn(Module._driftClouds)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Plays the mood's liquid surface effects and its ceiling's grit when each is due, on spots in the camera's view.
]]
function Module._step()
	--[[ Checks ]]

	-- Skip while no mood shows
	if not profile then
		return
	end

	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Surfaces ]]

	--- @param row Atmosphere_SurfaceRow
	for index: number, row in ipairs(profile.Surface) do
		if now >= surfaceTimes[index] then
			surfaceTimes[index] = now + random:NextNumber(row.Every[1], row.Every[2])
			Module._playOnSurface(row)
		end
	end

	--[[ Ceiling ]]

	if profile.Ceiling and now >= ceilingTime then
		ceilingTime = now + random:NextNumber(profile.Ceiling.Every[1], profile.Ceiling.Every[2])
		Module._playFromCeiling(profile.Ceiling)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Drift Clouds

--[[
	Sets the lobby stage's clouds drifting slowly sideways and back, each its own way, once the stage is built.
]]
function Module._driftClouds()
	--[[ Elements ]]

	local stage: Instance = lobbyFolder:WaitForChild("Stage")
	local clouds: Instance? = stage:FindFirstChild("Clouds")

	--[[ Checks ]]

	-- Check if the stage has clouds
	if not clouds then
		return
	end

	--[[ Drifting ]]

	for _index: number, cloud: Instance in ipairs(clouds:GetChildren()) do
		if not cloud:IsA("BasePart") then
			continue
		end
		local seconds: number = random:NextNumber(_settings.CLOUD_DRIFT_SECONDS[1], _settings.CLOUD_DRIFT_SECONDS[2])
		local offset: number = random:NextNumber(0.5, 1) * _settings.CLOUD_DRIFT * (if random:NextInteger(0, 1) == 0 then -1 else 1)
		local Drift_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)
		local Drift_TweenGoal = { CFrame = cloud.CFrame + Vector3.xAxis * offset }
		local Drift_Tween: Tween = I.S.TweenService:Create(cloud, Drift_TweenInfo, Drift_TweenGoal)
		table.insert(cloudTweens, Drift_Tween)
		if not bounds then
			Drift_Tween:Play()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Lobby

--[[
	Shows the lobby's mood: its ambient area in front of the stage camera, once the stage is built, and the clouds
	drifting.
]]
--- @param newProfile Atmosphere_Profile
function Module.ShowLobby(newProfile)
	--[[ Showing ]]

	local generation: number = Module._show(newProfile, nil)

	--[[ Clouds ]]

	for _index: number, tween: Tween in ipairs(cloudTweens) do
		tween:Play()
	end

	--[[ Checks ]]

	-- Check if this place has the lobby stage
	if not lobbyFolder then
		return
	end

	--[[ Building ]]

	task.spawn(function()
		local stage: Instance = lobbyFolder:WaitForChild("Stage")
		local marker: BasePart = stage:FindFirstChild(I.Settings["Lobby"].CAMERA_MARKER, true)
		if generation ~= shown then
			return
		end
		Module._buildStreams(newProfile, marker.CFrame * CFrame.new(0, 0, -_settings.LOBBY_AREA_DISTANCE), _settings.LOBBY_AREA_SIZE)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Show Map

--[[
	Shows a map's mood: its ambient areas over the map's bounds (none until the map has loaded them), its liquid
	surface effects and its ceiling.
]]
--- @param newProfile Atmosphere_Profile
function Module.ShowMap(newProfile, newBounds: BasePart?)
	--[[ Checks ]]

	-- Skip when this map's areas already show
	if newBounds and newProfile == profile and newBounds == bounds then
		return
	end

	--[[ Showing ]]

	Module._show(newProfile, newBounds)

	--[[ Clouds ]]

	for _index: number, tween: Tween in ipairs(cloudTweens) do
		tween:Pause()
	end

	--[[ Building ]]

	if newBounds then
		Module._buildStreams(newProfile, CFrame.new(newBounds.Position + Vector3.zAxis * _settings.AMBIENT_FRONT / 2), newBounds.Size + Vector3.zAxis * _settings.AMBIENT_FRONT)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Wind

--[[
	Bends every ambient area's particles with the match's wind (a point of wind pulls WIND_PUSH sideways).
]]
function Module.SetWind(newWind: number)
	--[[ Saving ]]

	wind = newWind

	--[[ Pulling ]]

	--- @param stream Atmosphere_Stream
	for _index: number, stream in ipairs(streams) do
		Module._pullStream(stream)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Stops the areas showing and starts a mood's timers. Returns the mood's number, so a build that waits can tell it's
	still the one showing.
]]
--- @param newProfile Atmosphere_Profile
--- @return number
function Module._show(newProfile, newBounds: BasePart?)
	--[[ Clearing ]]

	--- @param stream Atmosphere_Stream
	for _index: number, stream in ipairs(streams) do
		local longest: number = 0
		for emitter: ParticleEmitter, _pull: Vector3 in pairs(stream.Pulls) do
			emitter.Enabled = false
			longest = math.max(longest, emitter.Lifetime.Max)
		end
		task.delay(longest, function()
			stream.Part:Destroy()
		end)
	end
	streams = {}

	--[[ Saving ]]

	local now: number = os.clock()
	shown += 1
	profile = newProfile
	bounds = newBounds
	surfaceTimes = {}
	--- @param row Atmosphere_SurfaceRow
	for index: number, row in ipairs(newProfile.Surface) do
		surfaceTimes[index] = now + random:NextNumber(row.Every[1], row.Every[2])
	end
	ceilingTime = if newProfile.Ceiling then now + random:NextNumber(newProfile.Ceiling.Every[1], newProfile.Ceiling.Every[2]) else math.huge

	--[[ Returning ]]

	return shown
end

--%%%%%%%%%%%%%%%%%%%% Build Streams

--[[
	Fills an area with each of a mood's ambient prefabs, every one over its share of the area's height, streaming
	until the mood changes.
]]
--- @param forProfile Atmosphere_Profile
function Module._buildStreams(forProfile, cframe: CFrame, size: Vector3)
	--[[ Building ]]

	--- @param row Atmosphere_AmbientRow
	for _index: number, row in ipairs(forProfile.Ambient) do
		--[[ Data ]]

		local prefab: BasePart? = I.Vfx.Get(row.Effect)
		if not prefab then
			continue
		end

		--[[ Placing ]]

		local part: BasePart = prefab:Clone()
		part.Name = row.Effect
		part.CFrame = cframe * CFrame.new(0, size.Y * ((row.Bottom + row.Top) / 2 - 0.5), 0)
		part.Size = Vector3.new(size.X, size.Y * (row.Top - row.Bottom), size.Z)

		--[[ Streaming ]]

		local stream = { Part = part, Pulls = {} } --- @type Atmosphere_Stream
		for _index2: number, emitter: Instance in ipairs(part:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				stream.Pulls[emitter] = emitter.Acceleration
				emitter.Rate *= row.RateScale
				emitter.Enabled = true
			end
		end
		Module._pullStream(stream)
		part.Parent = worldFolder
		table.insert(streams, stream)
	end
end

--%%%%%%%%%%%%%%%%%%%% Pull Stream

--[[
	Sets an ambient area's emitters to their own acceleration plus the wind's pull.
]]
--- @param stream Atmosphere_Stream
function Module._pullStream(stream)
	--[[ Pulling ]]

	for emitter: ParticleEmitter, pull: Vector3 in pairs(stream.Pulls) do
		emitter.Acceleration = pull + Vector3.xAxis * wind * _settings.WIND_PUSH
	end
end

--%%%%%%%%%%%%%%%%%%%% Play On Surface

--[[
	Plays a Surface row's effect on a random open spot of its liquid, when that spot is in view.
]]
--- @param row Atmosphere_SurfaceRow
function Module._playOnSurface(row)
	--[[ Data ]]

	local spot: Vector3?
	local color: Color3?
	spot, color = Liquids.GetSurfaceSpot(row.Liquid)

	--[[ Checks ]]

	-- Check if the liquid has an open surface in view
	if not spot or not Effects.IsOnScreen(spot) then
		return
	end

	--[[ Playing ]]

	Effects.Play(row.Effect, spot, worldFolder, nil, if row.Tint and color then color:Lerp(Color3.new(1, 1, 1), _settings.LIQUID_TINT_LIGHTEN) else nil)
end

--%%%%%%%%%%%%%%%%%%%% Play From Ceiling

--[[
	Trickles a Ceiling row's effect from the underside of the rock over a random spot of the map: the first place,
	coming down from the bounds' top through rock, where the rock gives way to air.
]]
--- @param row Atmosphere_CeilingRow
function Module._playFromCeiling(row)
	--[[ Data ]]

	local terrain: Instance? = if arenaFolder then arenaFolder:FindFirstChild("Terrain") else nil

	--[[ Checks ]]

	-- Check if the map has loaded
	if not bounds or not terrain then
		return
	end

	--[[ Local Variables ]]

	local top: number = bounds.Position.Y + bounds.Size.Y / 2
	local lowest: number = top - bounds.Size.Y * _settings.CEILING_SHARE
	local x: number = random:NextNumber(bounds.Position.X - bounds.Size.X / 2, bounds.Position.X + bounds.Size.X / 2)
	local params: OverlapParams = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { terrain }
	local sawRock: boolean = false

	--[[ Finding ]]

	for y: number = top - _settings.CEILING_STEP / 2, lowest, -_settings.CEILING_STEP do
		local inRock: boolean = #I.S.Workspace:GetPartBoundsInBox(CFrame.new(x, y, bounds.Position.Z), Vector3.one * 0.2, params) > 0
		if sawRock and not inRock then
			local spot: Vector3 = Vector3.new(x, y + _settings.CEILING_STEP / 2, bounds.Position.Z)
			if Effects.IsOnScreen(spot) then
				Effects.Play(row.Effect, spot, worldFolder)
			end
			return
		end
		sawRock = sawRock or inRock
	end
end

return Module
