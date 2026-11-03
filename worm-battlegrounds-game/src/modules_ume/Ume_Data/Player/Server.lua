--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Player"

--- @type Player_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players
local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")
local _templates = script:FindFirstAncestor(_localName):FindFirstChild("Templates")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--- @type Player_ProfileHandler
local profileHandler = require(_scripts.S_ProfileHandler)
--- @type Player_SessionHandler
local sessionHandler = require(_scripts.S_SessionHandler)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Templates

--[[
	**SERVER** |
	Template for the player's profile.
]]
--- @type Player_ProfileData
local profileTemplate = require(_templates.S_Profile)

--[[
	**SERVER** |
	Template for the player's session.
]]
--- @type Player_Session
local sessionTemplate = require(_templates.S_Session)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
	**SERVER** |
	Table containing all player profiles (persistent data).
]]
--- @class Player_Profiles
--- @type { [Player]: { [string]: table } }
local profiles = {}

--[[
	**SERVER** |
	Table containing the internal player profile sessions.
]]
--- @type { [Player]: { [string]: Player_Profile } }
local internalProfiles = {}

--[[
	**SERVER** |
	Table containing all player sessions (temporary data).
]]
--- @class Player_Sessions
--- @type { [Player]: Player_Session }
local sessions = {}

-- Keys used for resetting players data.
local dataResetKeys = {} --- @type { [Player]: string }

--[[
	**SERVER** |
	Table containing registered profile templates by namespace.
]]
--- @type { [string]: table }
local profileTemplates = {}
local profileNamespaces = {} --- @type { string }
local isRespawnFunctionOverridden: boolean = false

--[[ Other ]]

local CLIENT_LOAD_KICK_MESSAGE = "Oops! Something went wrong while loading. Please try again!"
local PROFILE_KEY_MAX_LENGTH = 50

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Client Framework Loaded

--[[
	Returns whether the client has reported that the Ume framework finished loading.
]]
--- @return boolean
local function isClientFrameworkLoaded(player: Player)
	local clientStatusBool: BoolValue? = player:FindFirstChild(I.Config.General._clientStatusBoolName) :: BoolValue?
	return clientStatusBool ~= nil and clientStatusBool.Value == true
end

--%%%%%%%%%%%%%%%%%%%% Respawn Function

--[[
	Respawn function that fires when a player's character dies.
]]
local respawnFunction = function(player: Player, _character: Model?)
	task.wait(1) -- Delay before respawn

	-- Load new character
	if I.Player.Valid(player) then
		local success: boolean, errorMessage: string = pcall(function()
			player:LoadCharacterAsync()
		end)

		if not success then
			warn(`[{_localName}::{script.Name}]: {errorMessage}`)
		end
	end
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

	Module.RegisterProfile("Data", profileTemplate)

	-- AutoLoad Warning
	if Players.CharacterAutoLoads then
		warn(`[{_localName}::{script.Name}]: Turning off (Players.CharacterAutoLoads)`)
		Players.CharacterAutoLoads = false
	end

	I.G_Player.OnPlayerAdded(I.Priority.Last, Module._playerLoaded, true)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Player = {

		--[[ Control ]]

		OverrideRespawnFunction = Module.OverrideRespawnFunction,
		ResetData = Module.ResetData,

		--[[ Data ]]

		Sessions = sessions,

		ProfileTemplate = profileTemplate,
		ProfileTemplates = profileTemplates,
		SessionTemplate = sessionTemplate.Data,

		--[[ Methods ]]

		GetProfile = Module.GetProfile,
		Valid = Module.Valid,
		RegisterProfile = Module.RegisterProfile,

		--[[ Private ]]

		_dataResetKeys = dataResetKeys,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	--[[
		Run `Player.Added` for players who joined before the framework finished loading.
	]]
	for _, player in Players:GetPlayers() do
		task.spawn(Module._added, player)
	end

	Players.PlayerAdded:Connect(Module._added)
	Players.PlayerRemoving:Connect(Module._playerRemoving)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Profile Data

--%%%%%%%%%%%%%%%%%%%% Register Profile

--[[
	**SERVER** |
	Registers a persistent profile namespace and its template.
]]
--- @param template { [string]: any }
--- @return { [string]: any }
function Module.RegisterProfile(namespace: string, template)
	--[[ Checks ]]

	if profileTemplates[namespace] ~= nil then
		error(`[{_localName}::{script.Name}]: Profile namespace ({namespace}) is already registered!`)
	end

	-- Check if players can still get the namespace
	if I.Started then
		error(`[{_localName}::{script.Name}]: Profile namespace ({namespace}) must be registered before the framework starts!`)
	end

	-- Check if the longest possible profile key fits ProfileStore's limit
	local longestKey: string = `PlayerProfile_{string.rep("9", 11)}_{namespace}_{I.Config.Map.ProfileStoreName}`
	if #longestKey > PROFILE_KEY_MAX_LENGTH then
		error(`[{_localName}::{script.Name}]: Profile namespace ({namespace}) makes keys up to {#longestKey} characters long, ProfileStore allows {PROFILE_KEY_MAX_LENGTH}! Use a shorter namespace or ProfileStoreName.`)
	end

	--[[ Saving ]]

	profileTemplates[namespace] = template
	table.insert(profileNamespaces, namespace)
	profileHandler.Register(namespace, template)

	return template
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Overrides

--%%%%%%%%%%%%%%%%%%%% Override Respawn Function

--[[
	**SERVER** |
	Overrides the default character respawn function with the provided one.
]]
--- @param callback function
function Module.OverrideRespawnFunction(callback)
	if isRespawnFunctionOverridden then
		warn(`[{_localName}::{script.Name}]: Respawn function is already overridden!`)
	else
		isRespawnFunctionOverridden = true
	end

	respawnFunction = callback
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Player Loaded

--[[
	Handles logic when a player has finished loading on the server.
]]
function Module._playerLoaded(player: Player)
	if not Module.Valid(player) then
		return
	end

	-- Informing player that he can start loading client framework
	I._informPlayerLoaded(player)

	-- Spawning character
	if not Players.CharacterAutoLoads and _settings.INITIAL_CHARACTER_AUTO_LOAD then
		task.spawn(function()
			player:LoadCharacterAsync()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Player Added

--[[
	Handles logic when a player joins the game.
]]
function Module._added(player: Player)
	--[[
		Wait for Ume to finish loading on the client, or exit if the player leaves.
	]]

	local deadline: number = os.clock() + _settings.CLIENT_LOAD_TIMEOUT_SECONDS

	repeat
		RunService.Heartbeat:Wait()
	until not player or isClientFrameworkLoaded(player) or os.clock() >= deadline

	-- Player left the game
	if not player or player:IsDescendantOf(Players) == false then
		return
	end

	-- Framework didn't load
	if not isClientFrameworkLoaded(player) then
		warn(`[{_localName}::{script.Name}]: Client framework failed to load within {_settings.CLIENT_LOAD_TIMEOUT_SECONDS}s ({player.Name} / {player.UserId})`)
		player:Kick(CLIENT_LOAD_KICK_MESSAGE)
		return
	end

	--[[
		Create Profile & Session
	]]

	for _, namespace: string in ipairs(profileNamespaces) do
		local success: boolean
		local result: any | string?
		success, result = pcall(profileHandler.Create, player, namespace, profiles, internalProfiles)

		-- Stop loading when a profile failed to load
		if not success or not result then
			profileHandler.Release(player, profiles, internalProfiles)

			-- Kick when loading errored (a failed load already kicked)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to load profile ({namespace}) for ({player.Name} / {player.UserId})! - ({result})`)
				player:Kick(CLIENT_LOAD_KICK_MESSAGE)
			end

			return
		end
	end

	sessionHandler.Create(player, sessions)

	--[[
		Character Events
	]]

	player.CharacterAdded:Connect(function(character)
		Module._characterAdded(player, character)
	end)
	player.CharacterRemoving:Connect(function(character)
		Module._characterRemoving(player, character)
	end)

	if Players.CharacterAutoLoads and player.Character then
		Module._characterAdded(player, player.Character)
	end

	--[[
		Signal Player Load
	]]

	if not Module.Valid(player) then
		return
	end

	I.Topic.Publish("_Player_PlayerAdded", player)
	Module._debugData()
end

--%%%%%%%%%%%%%%%%%%%% Player Removing

--[[
	Runs the removing callbacks, waits for them up to `REMOVING_CALLBACKS_TIMEOUT`, then releases the player's data.
]]
function Module._playerRemoving(player: Player, reason: Enum.PlayerExitReason)
	--[[ Callbacks ]]

	local finished: boolean = false

	task.spawn(function()
		I.G_Player._runPlayerRemoving(player, reason)
		finished = true
	end)

	--[[ Waiting ]]

	local deadline: number = os.clock() + _settings.REMOVING_CALLBACKS_TIMEOUT

	while not finished and os.clock() < deadline do
		task.wait()
	end

	-- Warn when a callback is still running at the deadline
	if not finished then
		warn(`[{_localName}::{script.Name}]: Removing callbacks for ({player.Name}) still running after {_settings.REMOVING_CALLBACKS_TIMEOUT}s - releasing data anyway!`)
	end

	--[[ Releasing ]]

	Module._removing(player)
end

--%%%%%%%%%%%%%%%%%%%% Removing

--[[
	Releases the player's data and clears what this module kept for them.
]]
function Module._removing(player: Player)
	--[[ Releasing ]]

	profileHandler.Release(player, profiles, internalProfiles)
	sessionHandler.Release(player, sessions)

	--[[ Removing Data Reset Key ]]

	dataResetKeys[player] = nil
	I.AdminPanel_CommandBar.SetDictionary(`Player_DataResetKeys-{player.Name}`, nil)

	--[[ Studio: Debugging ]]

	Module._debugData()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Character Control

--%%%%%%%%%%%%%%%%%%%% Character Added

--[[
	Handles logic when the player's character is spawned.
]]
function Module._characterAdded(player: Player, character: Model)
	local humanoid: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 60)
	if not humanoid or not Module.Valid(player) then
		return
	end

	--[[ Override `humanoid.Died` ]]

	if not Players.CharacterAutoLoads then
		humanoid.Died:Connect(function()
			respawnFunction(player, character)
		end)

		-- Respawn a character that died before the connection
		if humanoid.Health <= 0 then
			task.spawn(respawnFunction, player, character)
		end
	end

	--[[ Wait for all limbs to load ]]

	for _, limbName: string in ipairs(_settings.LIMB_TREES[humanoid.RigType] or {}) do
		local limb: Instance? = character:FindFirstChild(`{limbName}`) or character:WaitForChild(limbName, _settings.LIMB_WAIT_TIMEOUT)

		-- Warn about a limb the rig doesn't have and keep going
		if not limb then
			warn(`[{_localName}::{script.Name}]: Character of ({player.Name}) has no ({limbName}) after {_settings.LIMB_WAIT_TIMEOUT}s! -`, character)
		end
	end

	I.Topic.Publish("_Player_CharacterAdded", player, character)
end

--%%%%%%%%%%%%%%%%%%%% Character Removing

--[[
	Handles logic when the player's character is removed.
]]
function Module._characterRemoving(player: Player, character: Model)
	I.Topic.Publish("_Player_CharacterRemoving", player, character)

	-- Clear character after delay
	if _settings.CHARACTER_DESTROY_DELAY > 0 then
		task.spawn(function()
			task.wait(_settings.CHARACTER_DESTROY_DELAY)

			if character then
				character:Destroy()
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Profile

--[[
	**SERVER** |
	Returns the player's loaded ProfileStore profile for a namespace (`"Data"` when omitted): `.Data`, `:Save()`, `:MessageHandler()`.
]]
--- @return Player_Profile?
function Module.GetProfile(player: Player, namespace: string?)
	--[[ Data ]]

	local profileNamespace: string = namespace or "Data"
	local playerProfiles = internalProfiles[player] --- @type { [string]: Player_Profile }?

	--[[ Checks ]]

	-- Check if the profile is loaded
	if not playerProfiles or not playerProfiles[profileNamespace] then
		warn(`[{_localName}::{script.Name}]: Profile ({profileNamespace}) of ({player}) is not loaded!`)
		return nil
	end

	--[[ Returning ]]

	return playerProfiles[profileNamespace]
end

--%%%%%%%%%%%%%%%%%%%% Valid

--[[
	**SERVER** |
	Runs bunch of checks to ensure that player's profile and session data is valid, also checks if the client-side framework is loaded.
]]
--- @return boolean
function Module.Valid(player: Player)
	if not player or not profiles[player] or not sessions[player] or not isClientFrameworkLoaded(player) then
		return false
	end

	for _, namespace: string in ipairs(profileNamespaces) do
		if profiles[player][namespace] == nil then
			return false
		end
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Reset Data

--[[
	**SERVER** |
	Resets player's data and re-joins them.
]]
function Module.ResetData(player: Player, authorized: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	-- Abort if not authorized
	if not authorized then
		return
	end

	--[[ Reset Data ]]

	for _, namespace: string in ipairs(profileNamespaces) do
		local profile = internalProfiles[player][namespace]
		profile.Data = I.Table.DeepCopy(profileTemplates[namespace])
		profiles[player][namespace] = profile.Data
	end

	--[[ Teleport with GUI ]]

	I.TeleportToDefaultLobby({ player }, "DataResetGui")
end

--%%%%%%%%%%%%%%%%%%%% Debug Data

--[[
	Prints profile and session data of all users to output.
]]
function Module._debugData()
	if I.Env.IsStudio then
		print("Profiles:", internalProfiles)
		print("Sessions:", sessions)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
