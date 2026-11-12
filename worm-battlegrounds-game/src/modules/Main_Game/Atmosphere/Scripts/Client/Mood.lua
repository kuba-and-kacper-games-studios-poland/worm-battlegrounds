--[[
	Created By: 	HungryN00B
	Edited By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Ambient = require(script.Parent:FindFirstChild("Ambient")) --- @type Atmosphere_Client_Ambient
local Wind = require(script.Parent:FindFirstChild("Wind")) --- @type Atmosphere_Client_Wind

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local matchFolder: Instance?
local arenaFolder: Instance?

--[[ State ]]

-- The profile showing, by name, and whether a mood was set yet (the first is set at once, the rest tween)
local current: string? = nil
local started: boolean = false

-- Whether the sudden death layer is on the lighting
local suddenDeath: boolean = false

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

--- @class Atmosphere_Client_Mood
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(match: Instance?, arena: Instance?)
	--[[ Folders ]]

	matchFolder = match
	arenaFolder = arena

	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
	if matchFolder then
		matchFolder:GetAttributeChangedSignal("MapId"):Connect(Module._refresh)
		matchFolder:GetAttributeChangedSignal("SuddenDeath"):Connect(Module._refreshSuddenDeath)
		matchFolder:GetAttributeChangedSignal("SuddenDeath"):Connect(Module._refreshMusic)
		matchFolder:GetAttributeChangedSignal("Wind"):Connect(Module._refreshWind)
	end
	if arenaFolder then
		arenaFolder.ChildAdded:Connect(function(child: Instance)
			if child.Name == "Markers" and current ~= _settings.LOBBY_PROFILE then
				child:WaitForChild("Bounds", 5)
				Module._refreshArea()
			end
		end)
	end

	--[[ Starting ]]

	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the mood of where the player is: the lobby's outside matches, the map's in one. Its lighting preset tweens in
	(the first is set at once), then its particles, sudden death, wind and music follow.
]]
function Module._refresh()
	--[[ Data ]]

	local name: string = Module._getProfileName()

	--[[ Checks ]]

	-- Skip when that mood already shows
	if name == current then
		return
	end
	current = name

	-- Check if the place has a mood
	local profile = Module._getProfile(name) --- @type Atmosphere_Profile?
	if not profile then
		return
	end

	--[[ Lighting ]]

	I.Lighting.SetActivePreset(profile.Preset, nil, nil, if started then _settings.MOOD_TWEENINFO else nil)
	started = true

	--[[ Following ]]

	Module._refreshArea()
	Module._refreshSuddenDeath()
	Module._refreshWind()
	Module._refreshMusic()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Area

--[[
	Shows the mood's particles: the lobby's in front of the stage, a map's and its wind over its bounds once the map
	has loaded (waiting for bounds that come after their markers).
]]
function Module._refreshArea()
	--[[ Data ]]

	local profile = _settings.PROFILES[current] --- @type Atmosphere_Profile?
	if not profile then
		return
	end

	--[[ Showing ]]

	-- The lobby, with no wind
	if current == _settings.LOBBY_PROFILE then
		Ambient.ShowLobby(profile)
		Wind.Show(nil, nil, nil)
		return
	end

	-- A map, over its bounds once they're here (a new map's markers bring them, and refresh this)
	local markers: Instance? = if arenaFolder then arenaFolder:FindFirstChild("Markers") else nil
	local found: Instance? = if markers then markers:FindFirstChild("Bounds") else nil
	local bounds: BasePart? = if found and found:IsA("BasePart") then found else nil
	Ambient.ShowMap(profile, bounds)
	Wind.Show(bounds, profile.WindColor, profile.WindSound)

	--[[ Waiting ]]

	-- The bounds can arrive after their markers (which only refresh this when they're added): look again once they're here
	if markers and not found then
		task.spawn(function()
			if markers:WaitForChild("Bounds", 10) then
				Module._refreshArea()
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Refresh Sudden Death

--[[
	Deepens the lighting while the match's sudden death runs, as a layer over the map's preset, and lifts it after.
]]
function Module._refreshSuddenDeath()
	--[[ Local Variables ]]

	local on: boolean = Module._isSuddenDeath()
	local weight: number = _settings.SUDDEN_DEATH_WEIGHT
	local id: string = _settings.SUDDEN_DEATH_ID

	--[[ Checks ]]

	-- Skip when the layer is already as it should be
	if on == suddenDeath then
		return
	end
	suddenDeath = on

	--[[ Lifting ]]

	if not on then
		I.Lighting.ClearValueBulk({
			{ "Lighting", "Brightness", weight, id },
			{ "ColorCorrectionEffect", "Contrast", weight, id },
			{ "ColorCorrectionEffect", "TintColor", weight, id },
			{ "Atmosphere", "Density", weight, id },
		}, _settings.SUDDEN_DEATH_TWEENINFO)
		return
	end

	--[[ Deepening ]]

	local brightness: number = I.Lighting.GetValue("Lighting", "Brightness")
	local contrast: number = I.Lighting.GetValue("ColorCorrectionEffect", "Contrast")
	local tint: Color3 = I.Lighting.GetValue("ColorCorrectionEffect", "TintColor")
	local density: number = I.Lighting.GetValue("Atmosphere", "Density")
	local warm: Color3 = _settings.SUDDEN_DEATH_TINT
	I.Lighting.SetValueBulk({
		{ "Lighting", "Brightness", { Value = brightness * _settings.SUDDEN_DEATH_BRIGHTNESS, Weight = weight, Id = id } },
		{ "ColorCorrectionEffect", "Contrast", { Value = contrast + _settings.SUDDEN_DEATH_CONTRAST, Weight = weight, Id = id } },
		{ "ColorCorrectionEffect", "TintColor", { Value = Color3.new(tint.R * warm.R, tint.G * warm.G, tint.B * warm.B), Weight = weight, Id = id } },
		{ "Atmosphere", "Density", { Value = density + _settings.SUDDEN_DEATH_DENSITY, Weight = weight, Id = id } },
	}, _settings.SUDDEN_DEATH_TWEENINFO)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Wind

--[[
	Hands the match's wind to the ambient particles and the wind's streaks; the lobby has none.
]]
function Module._refreshWind()
	--[[ Local Variables ]]

	local inMap: boolean = current ~= _settings.LOBBY_PROFILE and matchFolder ~= nil
	local wind: number = if inMap and matchFolder then matchFolder:GetAttribute("Wind") or 0 else 0

	--[[ Applying ]]

	Ambient.SetWind(wind)
	Wind.SetWind(wind)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Music

--[[
	Plays the mood's music (BGM_Controller), or its sudden-death track while the match's sudden death runs, crossfading
	from what played over MUSIC_FADE seconds.
]]
function Module._refreshMusic()
	--[[ Data ]]

	local profile = _settings.PROFILES[current] --- @type Atmosphere_Profile?
	if not profile then
		return
	end

	--[[ Playing ]]

	local track: string = if Module._isSuddenDeath() and profile.SuddenDeathMusic then profile.SuddenDeathMusic else profile.Music
	I.BGM_Controller.Play(track, _settings.MUSIC_FADE)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Profile Name

--[[
	Returns the name of the mood for where the player is: the map's while they're in a match on it, else the lobby's.
]]
--- @return string
function Module._getProfileName()
	--[[ Local Variables ]]

	local inMatch: boolean = I.Config.PlaceLoader.MapId == _settings.MATCH_MAP or I.S.Players.LocalPlayer:GetAttribute("InMatch") == true
	local mapId: string? = if matchFolder then matchFolder:GetAttribute("MapId") else nil

	--[[ Returning ]]

	return if inMatch and mapId then mapId else _settings.LOBBY_PROFILE
end

--%%%%%%%%%%%%%%%%%%%% Get Profile

--[[
	Returns a mood by name, nil with a warning when there's none (a map without a mood keeps the one showing).
]]
--- @return Atmosphere_Profile?
function Module._getProfile(name: string)
	--[[ Checks ]]

	-- Check if the mood exists
	if not _settings.PROFILES[name] then
		warn(`[{_localName}::{script.Name}]: Mood ({name}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return _settings.PROFILES[name]
end

--%%%%%%%%%%%%%%%%%%%% Is Sudden Death

--[[
	Returns whether the match the player is in on a map is in its sudden death.
]]
--- @return boolean
function Module._isSuddenDeath()
	return current ~= _settings.LOBBY_PROFILE and matchFolder ~= nil and matchFolder:GetAttribute("SuddenDeath") == true
end

return Module
