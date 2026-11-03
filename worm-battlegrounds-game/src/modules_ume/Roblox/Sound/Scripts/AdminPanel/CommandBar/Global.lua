--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Sound"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Sound_SoundsList
local soundsList = require(I.Dirs.GlobalData.Sound.SoundsList)
--- @type Sound_SoundGroupsList
local soundGroupsList = require(I.Dirs.GlobalData.Sound.SoundGroupsList)

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

--- @class Sound_CommandBar_Global
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Client Functions

	--[[ Play ]]

	--%%%%%%%%%%%%%%%%%%%% Play

	--[[
		Plays a sound on this client.
	]]
	--- @return boolean
	--- @return string
	local function play(soundName: string, volume: number, soundGroup: string?, location: Player | Vector3?)
		--[[ Checks ]]

		-- Check if the sound name exists
		if not soundsList[soundName] then
			return false, `Invalid Sound name: $|cr$|{soundName}#|`
		end

		--[[ Executing ]]

		local value: Sound? = I.Sound.Play({
			Name = soundName,
			Volume = volume,
			SoundGroup = soundGroup,
			Location = location and ((typeof(location) == "Vector3" and location) or (location and location.Character)),
		})

		--[[ Returning ]]

		if value then
			return true, `Playing Sound $|cr$|{soundName}#|...`
		else
			return false, `Failed to play Sound $|cr$|{soundName}#|`
		end
	end

	--[[ Sound Group ]]

	local function setSoundGroupVolume(soundGroup: string, volume: number)
		--[[ Checks ]]

		if not soundGroupsList[soundGroup] then
			return false, `Invalid SoundGroup name: $|cr$|{soundGroup}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Sound.ChangeSoundGroupVolume(soundGroup, volume)

		-- Returning
		if value then
			return true, `Set SoundGroup $|cr$|{soundGroup}#| volume to: $|cr$|{volume}#|`
		else
			return false, `Failed to set SoundGroup $|cr$|{soundGroup}#| volume`
		end
	end

	local function getSoundGroupVolume(soundGroup: string)
		--[[ Checks ]]

		if not soundGroupsList[soundGroup] then
			return false, `Invalid SoundGroup name: $|cr$|{soundGroup}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number = I.Sound.GetSoundGroupVolume(soundGroup)

		-- Returning
		if value then
			return true, `SoundGroup $|cr$|{soundGroup}#| volume is: $|cr$|{value}#|`
		else
			return false, `Failed to get SoundGroup $|cr$|{soundGroup}#| volume`
		end
	end

	local function getSoundTableLength(soundName: string)
		--[[ Checks ]]

		if not soundsList[soundName] then
			return false, `Invalid Sound name: $|cr$|{soundName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number? = I.Sound.GetSoundTableLength(soundName)

		-- Returning
		if value ~= nil then
			return true, `Sound $|cr$|{soundName}#| table length is: $|cr$|{value}#|`
		else
			return false, `Failed to get Sound $|cr$|{soundName}#| table length`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Server Functions

	--[[ Play ]]

	--%%%%%%%%%%%%%%%%%%%% S Play

	--[[
		Plays a sound on the server.
	]]
	--- @return boolean
	--- @return string
	local function s_play(soundName: string, volume: number, soundGroup: string?, location: Player | Vector3?)
		--[[ Checks ]]

		-- Check if the sound name exists
		if not soundsList[soundName] then
			return false, `Invalid Sound name: $|cr$|{soundName}#|`
		end

		--[[ Executing ]]

		local value: Sound? = I.Sound.Play({
			Name = soundName,
			Volume = volume,
			SoundGroup = soundGroup,
			Location = location and ((typeof(location) == "Vector3" and location) or (location and location.Character)),
		})

		--[[ Returning ]]

		if value then
			return true, `Playing Sound $|cr$|{soundName}#| on server...`
		else
			return false, `Failed to play Sound $|cr$|{soundName}#| on server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% S Play For Player

	--[[
		Plays a sound on one player's client.
	]]
	--- @return boolean
	--- @return string
	local function s_playForPlayer(player: Player, soundName: string, volume: number, soundGroup: string?, location: Player | Vector3?)
		--[[ Checks ]]

		-- Check if the sound name exists
		if not soundsList[soundName] then
			return false, `Invalid Sound name: $|cr$|{soundName}#|`
		end

		--[[ Executing ]]

		local value: boolean = I.Sound.PlayForPlayer(player, {
			Name = soundName,
			Volume = volume,
			SoundGroup = soundGroup,
			Location = location and ((typeof(location) == "Vector3" and location) or (location and location.Character)),
		})

		--[[ Returning ]]

		if value then
			return true, `Playing Sound $|cr$|{soundName}#| for $|cr$|{player.Name}#|...`
		else
			return false, `Failed to play Sound $|cr$|{soundName}#| for $|cr$|{player.Name}#|`
		end
	end

	--[[ Sound Group ]]

	--%%%%%%%%%%%%%%%%%%%% S Set Sound Group Volume

	--[[
		Sets a sound group's volume on one player's client.
	]]
	--- @return boolean
	--- @return string
	local function s_setSoundGroupVolume(player: Player, soundGroup: string, volume: number)
		--[[ Checks ]]

		-- Check if the sound group exists
		if not soundGroupsList[soundGroup] then
			return false, `Invalid SoundGroup name: $|cr$|{soundGroup}#|`
		end

		--[[ Executing ]]

		-- The client's answer is nil when it timed out, and untrusted
		local value: any = I.Network.Invoke("Sound_ChangeSoundGroupVolume", player, soundGroup, volume)

		--[[ Returning ]]

		if value == true then
			return true, `Set $|cr$|{player.Name}#|'s SoundGroup $|cr$|{soundGroup}#| volume to: $|cr$|{volume}#|`
		else
			return false, `Failed to update $|cr$|{player.Name}#|'s SoundGroup $|cr$|{soundGroup}#| volume`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% S Get Sound Group Volume

	--[[
		Reads a sound group's volume from one player's client.
	]]
	--- @return boolean
	--- @return string | { string }
	local function s_getSoundGroupVolume(player: Player, soundGroup: string)
		--[[ Checks ]]

		-- Check if the sound group exists
		if not soundGroupsList[soundGroup] then
			return false, `Invalid SoundGroup name: $|cr$|{soundGroup}#|`
		end

		--[[ Executing ]]

		-- The client's answer is nil when it timed out, and untrusted
		local value: any = I.Network.Invoke("Sound_GetSoundGroupVolume", player, soundGroup)

		--[[ Returning ]]

		if type(value) == "number" then
			return true,
				{
					`Retrieving $|cr$|{player.Name}#|'s SoundGroup $|cr$|{soundGroup}#| volume`,
					`$|cr$|{player.Name}#|'s SoundGroup $|cr$|{soundGroup}#| volume is: $|cr$|{value}#|`,
					"_multilineOutput",
				}
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s SoundGroup $|cr$|{soundGroup}#| volume`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants_client = {

		--[[ Play ]]

		{
			Aliases = { "play" },
			Args = {
				{ name = "soundName", types = { "string" }, dict = "Sound_SoundNames", requireDict = true },
				{ name = "volume", types = { "number" }, optional = true },
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true, optional = true },
				{ name = "location", types = { "Player", "Vector3" }, dict = "players", requireDict = false, optional = true },
			},
			Callback = play,
		},

		--[[ Sound Group ]]

		{
			Aliases = { "set_sound_group_volume" },
			Args = {
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true },
				{ name = "volume", types = { "number" } },
			},
			Callback = setSoundGroupVolume,
		},
		{
			Aliases = { "get_sound_group_volume" },
			Args = {
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true },
			},
			Callback = getSoundGroupVolume,
		},
		{
			Aliases = { "get_table_length" },
			Args = {
				{ name = "soundName", types = { "string" }, dict = "Sound_SoundNames", requireDict = true },
			},
			Callback = getSoundTableLength,
		},
	}
	local variants_server = {

		--[[ Play ]]

		{
			Aliases = { "play" },
			Args = {
				{ name = "soundName", types = { "string" }, dict = "Sound_SoundNames", requireDict = true },
				{ name = "volume", types = { "number" }, optional = true },
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true, optional = true },
				{ name = "location", types = { "Player", "Vector3" }, dict = "players", requireDict = false, optional = true },
			},
			Callback = s_play,
		},
		{
			Aliases = { "play_for_player" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "soundName", types = { "string" }, dict = "Sound_SoundNames", requireDict = true },
				{ name = "volume", types = { "number" }, optional = true },
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true, optional = true },
				{ name = "location", types = { "Player", "Vector3" }, dict = "players", requireDict = false, optional = true },
			},
			Callback = s_playForPlayer,
		},

		--[[ Sound Group ]]

		{
			Aliases = { "set_sound_group_volume" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true },
				{ name = "volume", types = { "number" } },
			},
			Callback = s_setSoundGroupVolume,
		},
		{
			Aliases = { "get_sound_group_volume" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "soundGroup", types = { "string" }, dict = "Sound_SoundGroupNames", requireDict = true },
			},
			Callback = s_getSoundGroupVolume,
		},
		{
			Aliases = { "get_table_length" },
			Args = {
				{ name = "soundName", types = { "string" }, dict = "Sound_SoundNames", requireDict = true },
			},
			Callback = getSoundTableLength,
		},
	}

	--[[ Command ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("Sound_Client", {
			Aliases = { "sound" },
			PermissionLevel = 255,

			Variants = variants_client,
		})
	end

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("Sound_Server", {
			Aliases = { "s_sound" },
			PermissionLevel = 255,

			Variants = variants_server,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	if not I.Env.IsClient then
		return
	end

	--[[ Getting Values ]]

	local allSoundNames = {} --- @type { string }
	local allSoundGroupsNames = {} --- @type { string }

	for soundName: string, _value: number in pairs(soundsList) do
		table.insert(allSoundNames, soundName)
	end
	for groupName: string, _value: number in pairs(soundGroupsList) do
		table.insert(allSoundGroupsNames, groupName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Sound_SoundNames`, allSoundNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Sound_SoundGroupNames`, allSoundGroupsNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
