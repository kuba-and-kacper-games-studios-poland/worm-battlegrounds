--[[
	Created By: 	Nari
]]

local _localName: string = "Sound"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Mirror: Folder = script.Parent:FindFirstChild("Mirror")
local SoundData: Folder = Mirror:FindFirstChild("Sound")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CoreGui: CoreGui = game:GetService("CoreGui")
local SoundService: SoundService = game:GetService("SoundService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Settings

local SoundsList = require(SoundData:FindFirstChild("SoundsList")) --- @type { [string]: { number } }
local SoundGroupsList = require(SoundData:FindFirstChild("SoundGroupsList")) --- @type { [string]: number }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Cache ]]

local holder: Folder?
local cachedSounds = {} --- @type { [number]: Sound }

--[[ Host ]]

local playHost: Instance?

--[[ State ]]

local groupVolumes = {} --- @type { [string]: number }
local sequentialIndexes = {} --- @type { [string]: number }
local masterVolume: number = 1

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

--- @class UmeGui_Libs_Sound
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Checks ]]

	-- Only start once
	if holder then
		return
	end

	--[[ Holder ]]

	local folder: Folder = Instance.new("Folder")
	folder.Name = "__UmeGui_Sounds"
	folder.Archivable = false
	folder.Parent = CoreGui
	holder = folder

	--[[ Groups ]]

	for groupName: string, volume: number in pairs(SoundGroupsList) do
		groupVolumes[groupName] = volume
	end

	--[[ Caching ]]

	for _soundName: string, soundIds in pairs(SoundsList) do
		for _index: number, soundId: number in ipairs(soundIds) do
			-- Skip ids shared by several names
			if cachedSounds[soundId] then
				continue
			end

			local sound: Sound = Instance.new("Sound")
			sound.Name = tostring(soundId)
			sound.SoundId = `rbxassetid://{soundId}`
			sound.Parent = folder
			cachedSounds[soundId] = sound
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop

function Module.Stop()
	--[[ Checks ]]

	-- Skip when the sounds are not running
	if not holder then
		return
	end

	--[[ Destroying ]]

	holder:Destroy()
	holder = nil
	table.clear(cachedSounds)
	playHost = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Host

--[[
	Sets the plugin widget sounds play in, or nil to play them with PlayLocalSound. Studio edit mode only plays a
	plugin's sounds from inside one of its DockWidgetPluginGuis.
]]
function Module.SetHost(host: Instance?)
	--[[ Saving ]]

	playHost = host
end

--%%%%%%%%%%%%%%%%%%%% Set Volume

--[[
	Scales every sound played from now on (0 mutes, 1 plays them at the framework's volumes).
]]
function Module.SetVolume(volume: number)
	--[[ Saving ]]

	masterVolume = math.clamp(volume, 0, 1)
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a named sound once with the framework's play parameters. Looped and positional playback are game-only and ignored.
]]
--- @param params UmeGui_SoundParams
--- @return Sound?
function Module.Play(params)
	--[[ Data ]]

	local soundIds = SoundsList[params.Name] --- @type { number }?

	--[[ Checks ]]

	-- Check if the sound has been started
	if not holder then
		warn(`[{_localName}]: Sound has not been started!`)
		return nil
	end

	-- Check if the sound name is listed
	if not soundIds or #soundIds == 0 then
		warn(`[{_localName}]: Sound ({params.Name}) is not listed!`)
		return nil
	end

	--[[ Local Variables ]]

	local soundId: number = soundIds[Module._getIndex(params, #soundIds)]
	local groupVolume: number = groupVolumes[params.SoundGroup or "UI"] or 1
	local sound: Sound = cachedSounds[soundId]:Clone()

	--[[ Applying ]]

	sound.Volume = (params.Volume or 0.5) * groupVolume * masterVolume
	sound.PlaybackSpeed = params.PlaybackSpeed or 1
	sound.TimePosition = params.TimePosition or 0
	sound.Parent = playHost or holder

	-- Shift the pitch when a range is given
	if params.PitchMin and params.PitchMax then
		local pitch: PitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitch.Octave = params.PitchMin + (params.PitchMax - params.PitchMin) * math.random()
		pitch.Parent = sound
	end

	--[[ Playing ]]

	-- Edit mode is silent outside a plugin widget, so a sound in the host plays itself
	if playHost then
		sound:Play()
	else
		SoundService:PlayLocalSound(sound)
	end
	task.delay(math.max(sound.TimeLength, 1) / sound.PlaybackSpeed + 0.5, sound.Destroy, sound)

	--[[ Returning ]]

	return sound
end

--%%%%%%%%%%%%%%%%%%%% Change Sound Group Volume

--[[
	Sets the volume used for a sound group's later plays.
]]
--- @return boolean
function Module.ChangeSoundGroupVolume(soundGroupName: string, volume: number)
	--[[ Checks ]]

	-- Check if the group is listed
	if not groupVolumes[soundGroupName] then
		warn(`[{_localName}]: SoundGroup ({soundGroupName}) is not listed!`)
		return false
	end

	--[[ Saving ]]

	groupVolumes[soundGroupName] = volume

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Sound Group Volume

--[[
	Returns a sound group's volume.
]]
--- @return number?
function Module.GetSoundGroupVolume(soundGroupName: string)
	return groupVolumes[soundGroupName]
end

--%%%%%%%%%%%%%%%%%%%% Get Sound Table Length

--[[
	Returns how many variants a sound name has.
]]
--- @return number?
function Module.GetSoundTableLength(soundName: string)
	--[[ Data ]]

	local soundIds = SoundsList[soundName] --- @type { number }?

	--[[ Returning ]]

	return soundIds and #soundIds
end

--%%%%%%%%%%%%%%%%%%%% Get Index

--[[
	Picks the variant to play: an explicit index, the next one in sequence, or a random one.
]]
--- @param params UmeGui_SoundParams
--- @return number
function Module._getIndex(params, count: number)
	--[[ Explicit ]]

	-- Use the requested variant when it exists
	if params.SoundTableIndex and params.SoundTableIndex >= 1 and params.SoundTableIndex <= count then
		sequentialIndexes[params.Name] = params.SoundTableIndex
		return params.SoundTableIndex
	end

	--[[ Sequential ]]

	-- Step through the variants in order
	if params.Sequential then
		local nextIndex: number = (sequentialIndexes[params.Name] or 0) % count + 1
		sequentialIndexes[params.Name] = nextIndex
		return nextIndex
	end

	--[[ Returning ]]

	return math.random(1, count)
end

return Module
