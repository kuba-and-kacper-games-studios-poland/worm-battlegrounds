--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Sound"

--- @type Sound_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local SoundService = I.S.SoundService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Sound_SoundsList
local soundsList = require(I.Dirs.GlobalData.Sound.SoundsList)
--- @type Sound_SoundGroupsList
local soundGroupsList = require(I.Dirs.GlobalData.Sound.SoundGroupsList)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
    Table containing all cached sounds.
]]
--- @type { [number]: Sound }
local cachedSounds = {}

--[[
    Table containing all SoundGroups.
]]
--- @type { [string]: SoundGroup }
local soundGroups = {}

--[[
    Counter for how many sounds have played, for easy debugging.
]]
local playedCount = 1

--[[
    Tracks sequential playback per logical sound name (`SoundsList` key).
    Only updated when `params.Sequential` is set; used to pick "next" variant (wrap).
]]
--- @type { [string]: number }
local sequentialLastIndexByName = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

--[[
    Directory for storing all cached sounds.
]]
local cachedDir: Folder

--[[
    Directory for storing created/playing sounds.
]]
local soundDir: Folder
local workspaceSoundDir: Folder

--[[
    Directory for storing sound groups.
]]
local soundGroupsDir: Folder

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Other

--[[
    3D sound holder part.
]]
local soundHolderPart: Part

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Create Sound Holder

--[[
	Returns a new Attachment at the given location, under this side's one invisible anchored holder Part.
]]
--- @return Attachment
local function createSoundHolder(location: Vector3)
	--[[ Creating Holder Part ]]

	-- Create the holder Part on first use
	if not soundHolderPart then
		soundHolderPart = I.Create("Part")({
			Name = "SoundHolder",
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Anchored = true,
			CFrame = CFrame.identity,
		})

		-- Keep the server's holder streamed in on every client
		if I.Env.IsServer then
			soundHolderPart.Parent = I.Create("Model")({
				Name = "SoundHolder",
				ModelStreamingMode = Enum.ModelStreamingMode.Persistent,
				Parent = workspaceSoundDir,
			})
		else
			soundHolderPart.Parent = workspaceSoundDir
		end
	end

	--[[ Creating Attachment ]]

	local attachment: Attachment = Instance.new("Attachment")
	attachment.Parent = soundHolderPart
	attachment.WorldPosition = location

	--[[ Returning ]]

	return attachment
end

--%%%%%%%%%%%%%%%%%%%% Resolve Playback Sound Id

--[[
	Resolves which rbxasset id from `soundIds` should play for this request.
]]
--- @param params Sound_Params
--- @param soundIds { number }
--- @return number
local function resolvePlaybackSoundId(params, soundIds)
	local len: number = #soundIds

	--[[ Sequential ]]

	if params.Sequential then
		--[[ Explicit Index ]]

		if params.SoundTableIndex ~= nil then
			local atIndex: number? = soundIds[params.SoundTableIndex]
			if atIndex == nil then
				-- Invalid index; pick random and remember it
				warn(`[{_localName}::{script.Name}]: SoundTableIndex ({params.SoundTableIndex}) for ({params.Name}) is empty or out of range; using random variant.`)
				local rId: number = I.Random.Int(1, len)
				sequentialLastIndexByName[params.Name] = rId
				return soundIds[rId]
			end

			sequentialLastIndexByName[params.Name] = params.SoundTableIndex
			return atIndex
		end

		--[[ Advance Index ]]

		local lastIndex: number? = sequentialLastIndexByName[params.Name]
		local nextIndex: number
		if lastIndex == nil then
			nextIndex = 1
		else
			nextIndex = lastIndex + 1
			if nextIndex > len then
				nextIndex = 1
			end
		end

		sequentialLastIndexByName[params.Name] = nextIndex
		return soundIds[nextIndex]
	end

	--[[ Explicit Index ]]

	if params.SoundTableIndex ~= nil then
		local atIndex: number? = soundIds[params.SoundTableIndex]
		if atIndex == nil then
			-- Invalid index; pick random
			warn(`[{_localName}::{script.Name}]: SoundTableIndex ({params.SoundTableIndex}) for ({params.Name}) is empty or out of range; using random variant.`)
			return soundIds[I.Random.Int(1, len)]
		end

		return atIndex
	end

	--[[ Random ]]

	return soundIds[I.Random.Int(1, len)]
end

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createDirectories()
	Module._createSoundGroups()
	Module._cacheSounds()
	Module._preloadSounds()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	if I.Env.IsServer then
		I.Network.GetEvent("Sound_ClientPlay")

		I.Network.GetFunction("Sound_ChangeSoundGroupVolume")
		I.Network.GetFunction("Sound_GetSoundGroupVolume")
	end

	if I.Env.IsClient then
		I.Network.GetEvent("Sound_ClientPlay", { { Type = "table" } })
		I.Network.Fired("Sound_ClientPlay", Module.Play)

		I.Network.GetFunction("Sound_ChangeSoundGroupVolume", { "string", "number" })
		I.Network.OnInvoke("Sound_ChangeSoundGroupVolume", Module.ChangeSoundGroupVolume)

		I.Network.GetFunction("Sound_GetSoundGroupVolume", { "string" })
		I.Network.OnInvoke("Sound_GetSoundGroupVolume", Module.GetSoundGroupVolume)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Sound = {

		--[[ Control ]]

		Play = Module.Play,
		PlayForPlayer = Module.PlayForPlayer,
		PlayForPlayers = Module.PlayForPlayers,
		PlayForAll = Module.PlayForAll,

		ChangeSoundGroupVolume = Module.ChangeSoundGroupVolume,

		--[[ Methods ]]

		GetSoundGroupVolume = Module.GetSoundGroupVolume,
		GetSoundTableLength = Module.GetSoundTableLength,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Directories

--[[
    Creates Folders to store cached sounds, currently playing sounds, and SoundGroups.
]]
function Module._createDirectories()
	if I.Env.IsServer then
		-- Create Cached Folder
		cachedDir = Instance.new("Folder")
		cachedDir.Name = "CachedSounds"
		cachedDir.Parent = SoundService

		-- Create Container Folder
		soundDir = Instance.new("SoundGroup")
		soundDir.Name = "SoundsContainer"
		soundDir.Parent = SoundService

		workspaceSoundDir = Instance.new("SoundGroup")
		workspaceSoundDir.Name = "SoundsContainer"
		workspaceSoundDir.Parent = I.Dirs.UmeWorkspace

		-- Create SoundGroups Folder
		soundGroupsDir = Instance.new("Folder")
		soundGroupsDir.Name = "SoundGroups"
		soundGroupsDir.Parent = SoundService
	end

	if I.Env.IsClient then
		-- Get folders that were created on the server
		cachedDir = SoundService:FindFirstChild("CachedSounds")
		soundDir = SoundService:FindFirstChild("SoundsContainer")
		workspaceSoundDir = I.Dirs.UmeWorkspace:FindFirstChild("SoundsContainer")
		soundGroupsDir = SoundService:FindFirstChild("SoundGroups")
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Sound Groups

--[[
    Creates all pre-defined `SoundGroups` from the global data.
]]
function Module._createSoundGroups()
	--[[
        Server: Creating SoundGroups
    ]]

	if I.Env.IsServer then
		for name: string, volume: number in pairs(soundGroupsList) do
			local soundGroup: SoundGroup = I.Create("SoundGroup")({
				Name = name,
				Volume = volume,
				Parent = soundGroupsDir,
			})

			soundGroups[name] = soundGroup
		end
	end

	--[[
        Client: Saving SoundGroups
    ]]

	if I.Env.IsClient then
		for _, soundGroup: SoundGroup in ipairs(soundGroupsDir:GetChildren()) do
			if not soundGroup:IsA("SoundGroup") then
				continue
			end

			soundGroups[soundGroup.Name] = soundGroup
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Cache Sounds

--[[
    Caches all sounds by creating them as a new instances.
]]
function Module._cacheSounds()
	--[[
        Server: Creating sound Instances
    ]]

	if I.Env.IsServer then
		--[[
            Table containing all SoundIds from `_soundsList` without duplicates.
        ]]
		--- @type { number }
		local ids = {}

		--[[ Getting Ids ]]

		for _, idsTable in pairs(soundsList) do
			for _, id: number in ipairs(idsTable) do
				if type(id) ~= "number" then
					warn(`[{_localName}::{script.Name}]: ({id}) is not a valid SoundId!`)
					continue
				end

				if table.find(ids, id) then
					continue -- Duplicated
				end

				table.insert(ids, id)
			end
		end

		--[[ Caching Sounds ]]

		for _, soundId: number in ipairs(ids) do
			local sound: Sound = I.Create("Sound")({
				SoundId = `rbxassetid://{soundId}`,
				Name = tostring(soundId),
				Playing = false,
				Parent = cachedDir,
			})

			cachedSounds[soundId] = sound
		end
	end

	--[[
        Client: Saving cached sound to table
    ]]

	if I.Env.IsClient then
		for _, sound: Sound in ipairs(cachedDir:GetChildren()) do
			if not sound:IsA("Sound") then
				continue
			end

			cachedSounds[tonumber(sound.Name)] = sound
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Preload Sounds

--[[
	Loads every cached sound in the background on the client, so loading into the game doesn't wait for it.
]]
function Module._preloadSounds()
	--[[ Checks ]]

	-- Preload on the client only
	if not I.Env.IsClient then
		return
	end

	--[[ Collecting ]]

	--- @type { Sound }
	local sounds = {}

	for _soundId: number, sound: Sound in pairs(cachedSounds) do
		table.insert(sounds, sound)
	end

	--[[ Preloading ]]

	task.spawn(function()
		I.S.ContentProvider:PreloadAsync(sounds)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
    Plays a sound using provided params.
]]
--- @param params Sound_Params
--- @return Sound?
function Module.Play(params)
	--[[ Getting Sound ]]

	--- @type { number }
	local soundIds = soundsList[params.Name]

	-- Check if the sound name exists
	if not soundIds then
		warn(`[{_localName}::{script.Name}]: ({params.Name}) is not a valid SoundName!`)
		return nil
	end

	-- Check if the sound name has asset ids
	if #soundIds == 0 then
		warn(`[{_localName}::{script.Name}]: Sound table for ({params.Name}) is empty!`)
		return nil
	end

	--[[ Choosing Sound Id ]]

	local chosenSoundId: number = resolvePlaybackSoundId(params, soundIds)

	--[[ Getting Cached Sound ]]

	local cachedSound: Sound = cachedSounds[chosenSoundId]

	-- Check if the asset id was cached
	if not cachedSound then
		warn(`[{_localName}::{script.Name}]: ({chosenSoundId}) is not a valid SoundId!`)
		return nil
	end

	--[[ Cloning and Updating ]]

	local cloned: Sound = cachedSound:Clone()
	cloned.Volume = params.Volume or 0.5
	cloned.SoundGroup = soundGroups[params.SoundGroup] or soundGroups[_settings.DEFAULT_SOUND_GROUP]
	cloned.Looped = if params.Looped ~= nil then params.Looped else false
	cloned.PlaybackSpeed = params.PlaybackSpeed or 1
	cloned.TimePosition = params.TimePosition or 0
	cloned.RollOffMinDistance = params.RollOffMin or 10
	cloned.RollOffMaxDistance = params.RollOffMax or 100
	cloned.RollOffMode = params.RollOffMode or Enum.RollOffMode.Inverse

	--[[ Pitch ]]

	-- Pick a random pitch when a range is set
	if params.PitchMin and params.PitchMax then
		local pitchInstance: PitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchInstance.Octave = I.Random.Float(params.PitchMin, params.PitchMax)
		pitchInstance.Parent = cloned
	end

	--[[ Parent Sound ]]

	-- Use the position the server sent when the Location instance doesn't exist here
	local location: Instance | Vector3 | CFrame | nil = params.Location or params.FallbackPosition

	local soundHolder: Attachment?
	if typeof(location) == "Instance" then
		if location:IsA("Model") then
			-- Play from a part of the model, or from its pivot when it has none
			local modelPart: BasePart? = location.PrimaryPart or location:FindFirstChildWhichIsA("BasePart")
			if modelPart then
				cloned.Parent = modelPart
			else
				soundHolder = createSoundHolder(location:GetPivot().Position)
				cloned.Parent = soundHolder
			end
		else
			cloned.Parent = location
		end
	elseif typeof(location) == "Vector3" then
		soundHolder = createSoundHolder(location)
		cloned.Parent = soundHolder
	elseif typeof(location) == "CFrame" then
		soundHolder = createSoundHolder(location.Position)
		cloned.Parent = soundHolder
	else
		cloned.Parent = soundDir
	end

	--[[ Updating Name ]]

	if soundHolder then
		soundHolder.Name = `{playedCount}. {params.Name}`
	end
	cloned.Name = `{playedCount}. {params.Name}`
	playedCount += 1

	--[[ Auto Remove ]]

	local _autoRemove: boolean = if params.AutoRemove ~= nil then params.AutoRemove else true
	local _looped: boolean = if params.Looped ~= nil then params.Looped else false

	-- Destroy the holder together with the sound
	if soundHolder then
		cloned.Destroying:Once(function()
			soundHolder:Destroy()
		end)
	end

	-- Remove one-shot sounds by themselves
	if _autoRemove and not _looped then
		-- Destroy the sound once it ends or is stopped
		cloned.Ended:Once(function()
			cloned:Destroy()
		end)
		cloned.Stopped:Once(function()
			cloned:Destroy()
		end)

		-- Destroy it when its asset hasn't loaded in time
		task.delay(_settings.AUTO_REMOVE_LOAD_TIMEOUT, function()
			if not cloned.IsLoaded then
				cloned:Destroy()
			end
		end)
	end

	--[[ Playing ]]

	local _autoPlay: boolean = if params.AutoPlay ~= nil then params.AutoPlay else true

	-- Play now unless the caller plays it later
	if _autoPlay then
		cloned:Play()
	end

	--[[ Returning ]]

	return cloned
end

--%%%%%%%%%%%%%%%%%%%% Play For Player

--[[
	Plays sound for a player, created locally on that player's client.
	On the client it plays the sound locally and warns.
]]
--- @param params Sound_Params
--- @return boolean
function Module.PlayForPlayer(player: Player, params)
	-- Check if this runs on the client
	if I.Env.IsClient then
		Module.Play(params)
		warn(`[{_localName}::{script.Name}]: (PlayForPlayer) can only be executed by the server!`)
		return false
	end

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Playing ]]

	I.Network.Fire("Sound_ClientPlay", player, Module._getClientParams(params))

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Play For Players

--[[
	Plays sound for several players, created locally on each of their clients.
	On the client it plays the sound locally and warns.
]]
--- @param players { Player }
--- @param params Sound_Params
--- @return boolean
function Module.PlayForPlayers(players, params)
	--[[ Checks ]]

	-- Check if this runs on the client
	if I.Env.IsClient then
		Module.Play(params)
		warn(`[{_localName}::{script.Name}]: (PlayForPlayers) can only be executed by the server!`)
		return false
	end

	--[[ Local Variables ]]

	--- @type Sound_Params
	local clientParams = Module._getClientParams(params)

	--[[ Playing ]]

	for _, player: Player in ipairs(players) do
		-- Skip players that aren't loaded or have left
		if not I.Player.Valid(player) then
			continue
		end

		I.Network.Fire("Sound_ClientPlay", player, clientParams)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Play For All

--[[
	Plays sound for every player, created locally on each client.
	On the client it plays the sound locally and warns.
]]
--- @param params Sound_Params
--- @return boolean
function Module.PlayForAll(params)
	--[[ Checks ]]

	-- Check if this runs on the client
	if I.Env.IsClient then
		Module.Play(params)
		warn(`[{_localName}::{script.Name}]: (PlayForAll) can only be executed by the server!`)
		return false
	end

	--[[ Playing ]]

	I.Network.FireAll("Sound_ClientPlay", Module._getClientParams(params))

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Change Sound Group Volume

--[[
    **CLIENT** |
    Changes volume of the sound group.
]]
--- @return boolean
function Module.ChangeSoundGroupVolume(soundGroupName: string, volume: number)
	--[[ Checks ]]

	if not I.Env.IsClient then
		warn(`[{_localName}::{script.Name}]: SoundGroup volume can only be changed on the client!`)
		return false
	end

	if not soundGroups[soundGroupName] then
		warn(`[{_localName}::{script.Name}]: ({soundGroupName}) is not a valid SoundGroup name!`)
		return false
	end

	--[[ Updating ]]

	soundGroups[soundGroupName].Volume = volume
	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Sound Group Volume

--[[
    **CLIENT** |
    Returns volume of the sound group.
]]
--- @return number
function Module.GetSoundGroupVolume(soundGroupName: string)
	--[[ Checks ]]

	if not I.Env.IsClient then
		warn(`[{_localName}::{script.Name}]: SoundGroup volume can only be accessed on the client!`)
		return nil
	end

	if not soundGroups[soundGroupName] then
		warn(`[{_localName}::{script.Name}]: ({soundGroupName}) is not a valid SoundGroup name!`)
		return nil
	end

	--[[ Returning ]]

	return soundGroups[soundGroupName].Volume
end

--%%%%%%%%%%%%%%%%%%%% Get Sound Table Length

--[[
    Returns how many sound asset ids are listed for a sound name.
]]
--- @return number?
function Module.GetSoundTableLength(soundName: string)
	--- @type { number }
	local soundIds = soundsList[soundName]
	if not soundIds then
		warn(`[{_localName}::{script.Name}]: ({soundName}) is not a valid SoundName!`)
		return nil
	end

	return #soundIds
end

--%%%%%%%%%%%%%%%%%%%% Get Client Params

--[[
	Returns a copy of the params to fire to clients, with the world position of an Instance Location as FallbackPosition.
]]
--- @param params Sound_Params
--- @return Sound_Params
function Module._getClientParams(params)
	--[[ Copying ]]

	--- @type Sound_Params
	local clientParams = table.clone(params)

	--[[ Fallback Position ]]

	-- Send where an Instance Location is, for clients that don't have that instance
	if typeof(params.Location) == "Instance" then
		if params.Location:IsA("Attachment") then
			clientParams.FallbackPosition = params.Location.WorldPosition
		elseif params.Location:IsA("PVInstance") then
			clientParams.FallbackPosition = params.Location:GetPivot().Position
		end
	end

	--[[ Returning ]]

	return clientParams
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
