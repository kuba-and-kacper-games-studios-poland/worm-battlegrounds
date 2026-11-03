--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Framework Loading Time

--- @return boolean, string
local function getFrameworkLoadingTime()
	-- Getting value
	local value: string = ("%.3fs"):format(I._frameworkLoadingTime)

	-- Returning
	return true, `Framework loading time: $|cr$|{value}#|`
end

--%%%%%%%%%%%%%%%%%%%% Get Modules Execution Time

--- @return boolean, string
local function getModulesExecutionTime()
	-- Getting value
	local value: string = ("%.3fs"):format(I._modulesExecutionTime_Total)

	-- Returning
	return true, `Modules loading time: $|cr$|{value}#|`
end

--%%%%%%%%%%%%%%%%%%%% Get Modules Functions Execution Time

--- @return boolean, { AdminPanel_CommandBar_Output }
local function getModulesFunctionsExecutionTime(depth: number?)
	-- Getting value
	local value = {}

	-- Fixing depth
	depth = I.Number.ToNumberOr(depth, 0)
	if depth <= 0 then
		depth = #I._modulesExecutionTime
	end

	-- Getting 'x' amount of execution times
	for count = 1, depth do
		if not I._modulesExecutionTime[count] then
			break
		end

		table.insert(value, I._modulesExecutionTime[count])
	end

	-- Returning
	return true, { "Getting modules execution time...", value, "_multilineOutput" }
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

--- @class AdminPanel_CommandBar_Defaults
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	if I.Env.IsClient then
		Module._registerCommands_Client()
		Module._registerDictionaries_Client()
	end

	if I.Env.IsServer then
		Module._registerCommands_Server()
		Module._registerCommands_Server_Utility()
		Module._registerDictionaries_Server()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Client

--%%%%%%%%%%%%%%%%%%%% Register Commands Client

--[[
	Registers general ume commands.
]]
function Module._registerCommands_Client()
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Config Get Functions

	--%%%%%%%%%%%%%%%%%%%% Get Game Version

	local function getGameVersion()
		-- Getting value
		local value: string = I.Config.General.GameVersion

		-- Returning
		return true, `Game Version: $|cr$|{value}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Get Framework Version

	local function getFrameworkVersion()
		-- Getting value
		local value: string = I.Config.General._umeVersion

		-- Returning
		return true, `Framework Version: $|cr$|{value}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Get Place Id

	local function getPlaceId()
		-- Getting value
		local value: string = I.Config.PlaceLoader.PlaceId

		-- Returning
		return true, `PlaceId: $|cr$|{value}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Get Map Id

	local function getMapId()
		-- Getting value
		local value: string = I.Config.PlaceLoader.MapId

		-- Returning
		return true, `MapId: $|cr$|{value}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Config Get Functions ]]

		{
			Aliases = { "config" },

			Variants = {
				{
					Aliases = { "get_game_version" },
					Callback = getGameVersion,
				},
				{
					Aliases = { "get_framework_version" },
					Callback = getFrameworkVersion,
				},
				{
					Aliases = { "get_placeId" },
					Callback = getPlaceId,
				},
				{
					Aliases = { "get_mapId" },
					Callback = getMapId,
				},
			},
		},

		--[[ Info Get Functions ]]

		{
			Aliases = { "info" },

			Variants = {
				{
					Aliases = { "get_framework_loading_time" },
					Callback = getFrameworkLoadingTime,
				},
				{
					Aliases = { "get_modules_execution_time" },
					Callback = getModulesExecutionTime,
				},
				{
					Aliases = { "get_modules_functions_execution_time" },
					Args = {
						{ name = "depth", types = { "number" }, optional = true },
					},
					Callback = getModulesFunctionsExecutionTime,
				},
			},
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Ume_Client", {
		Aliases = { "ume" },
		PermissionLevel = 1,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Dictionaries Client

--[[
	Registers general ume dictionaries.
]]
function Module._registerDictionaries_Client()
	--
	--%%%%%%%%%%%%%%%%%%%% Format Types %%%%%%%%%%%%%%%%%%%%--

	local formatType = I.Format.GetFormatFunctionNames() --- @type { string }

	-- Updating Dictionary
	I.AdminPanel_CommandBar.SetDictionary(`Ume_FormatTypes`, formatType, 1)

	--%%%%%%%%%%%%%%%%%%%% Place/Maps Ids %%%%%%%%%%%%%%%%%%%%--

	--[[ Place/Maps Config Ids ]]

	local allPlaceConfigsNames = {} --- @type { string }
	local allPlaceConfigsMapNames = {} --- @type { [string]: { string } }

	--- @param placeSettings Ume_PlaceLoader_PlaceSettings
	for placeId: string, placeSettings in pairs(I.Config.PlaceLoader.PlaceConfigs) do
		-- Saving placeId
		table.insert(allPlaceConfigsNames, `{placeId}`)

		--[[ Saving Maps ]]

		allPlaceConfigsMapNames[placeId] = {}

		--- @param mapSetting Ume_PlaceLoader_MapSettings
		for mapId: string, _mapSettings in pairs(placeSettings.MapConfigs) do
			table.insert(allPlaceConfigsMapNames[placeId], `{mapId}`)
		end
	end

	-- Updating Dictionary
	I.AdminPanel_CommandBar.SetDictionary("Ume_PlaceIds", allPlaceConfigsNames, 255)
	for placeId: string, mapIds: { string } in pairs(allPlaceConfigsMapNames) do
		I.AdminPanel_CommandBar.SetDictionary(`Ume_PlaceMapIds-{placeId}`, mapIds, 255)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Server

--%%%%%%%%%%%%%%%%%%%% Register Commands Server

--[[
	Registers general ume commands.
]]
function Module._registerCommands_Server()
	--%%%%%%%%%%%%%%%%%%%% Get Server Metadata

	local function getServerMetadata()
		-- Getting value
		local value: table | nil = I.Config.Metadata

		-- Returning
		if value then
			return true, { `Retrieving metadata for current server...`, value, "_multilineOutput" }
		else
			return true, `No metadata set for current server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Teleport Functions

	--%%%%%%%%%%%%%%%%%%%% Teleport

	local function teleport(players: Player | { Player } | { Player }, placeId: number, mapId: string, guiName: string?)
		--[[ Getting Data ]]

		-- Ensuring table
		if type(players) ~= "table" then
			players = { players }
		end

		local playersString: string = ""
		for _, player in ipairs(players) do
			playersString ..= `{#playersString > 0 and ", " or ""}{player}`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Teleport(players, placeId, mapId, nil, guiName)

		-- Returning
		if value then
			return true, `Teleported $|cr$|{playersString}#| to new server`
		else
			return false, `Failed to teleport $|cr$|{playersString}#| to new server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Teleport External

	local function teleportExternal(players, placeId, guiName: string?)
		--[[ Getting Data ]]

		-- Ensuring table
		if type(players) ~= "table" then
			players = { players }
		end

		local playersString: string = ""
		for _, player in ipairs(players) do
			playersString ..= `{#playersString > 0 and ", " or ""}{player}`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.TeleportExternal(players, placeId, guiName)

		-- Returning
		if value then
			return true, `Teleported $|cr$|{playersString}#| to external server`
		else
			return false, `Failed to teleport $|cr$|{playersString}#| to external server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Teleport Lobby

	local function teleportLobby(players: Player | { Player }, guiName: string?)
		--[[ Getting Data ]]

		-- Ensuring table
		if type(players) ~= "table" then
			players = { players }
		end

		local playersString: string = ""
		for _, player in ipairs(players) do
			playersString ..= `{#playersString > 0 and ", " or ""}{player}`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.TeleportToDefaultLobby(players, guiName)

		-- Returning
		if value then
			return true, `Teleported $|cr$|{playersString}#| to default lobby`
		else
			return false, `Failed to teleport $|cr$|{playersString}#| to default lobby`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Teleport To Existing Server

	local function teleportToExistingServer(players: Player | { Player }, placeId: number, jobId: string, accessCode: string?, guiName: string?)
		--[[ Getting Data ]]

		-- Ensuring table
		if type(players) ~= "table" then
			players = { players }
		end

		local playersString: string = ""
		for _, player in ipairs(players) do
			playersString ..= `{#playersString > 0 and ", " or ""}{player}`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.TeleportToServer(players, placeId, jobId, accessCode, guiName)

		-- Returning
		if value then
			return true, `Teleported $|cr$|{playersString}#| to existing server`
		else
			return false, `Failed to teleport $|cr$|{playersString}#| to existing server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lobby Functions

	--%%%%%%%%%%%%%%%%%%%% Get Persistent Lobby State

	local function getPersistentLobbyState()
		-- Getting value
		local success: boolean, isPersistent: boolean | string = I.GetPersistentLobbyState()

		-- Returning
		if success then
			if isPersistent then
				return true, `$|cr$|PersistentLobby#| is $|cr$|Enabled#|`
			else
				return true, `$|cr$|PersistentLobby#| is $|cr$|Disabled#|`
			end
		else
			return false, { "Failed to retrieve $|cr$|PersistentLobby#| state:", isPersistent, "_multilineOutput" }
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Update Persistent Lobby State

	local function updatePersistentLobbyState(state: boolean)
		-- Getting value
		local success: boolean, errorMessage: string = I.UpdatePersistentLobbyState(state)

		-- Returning
		if success then
			return true, `$|cr$|PersistentLobby#| state updated to: $|cr$|{state}#|`
		else
			return false, { "Failed to update $|cr$|PersistentLobby#| state:", errorMessage, "_multilineOutput" }
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Server Job Id Functions

	--%%%%%%%%%%%%%%%%%%%% Get Player Job Id

	local function getPlayerJobId(player: Player)
		-- Getting value
		local jobId: string = game.JobId
		local accessCode: string = I.Config.Metadata and I.Config.Metadata.AccessCode

		-- Returning
		if jobId and jobId ~= "" then
			return true, `Retrieving jobId for $|cr$|{player.Name}#| server...`, { jobId, accessCode }
		else
			return false, `Failed to retrieve jobId for $|cr$|{player.Name}#| server`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Save Player Job Id

	local function savePlayerJobId(invoker: Player, jobId: string, accessCode: string)
		--[[ Saving ]]

		if jobId then
			I.AdminPanel_CommandBar.UpdateDictionary(`Ume_SavedJobIds-{invoker.UserId}`, { jobId }, nil, 255, { BoundTo = invoker.UserId })
		end
		if accessCode then
			I.AdminPanel_CommandBar.UpdateDictionary(`Ume_ServerAccessCodes-{invoker.UserId}`, { accessCode }, nil, 255, { BoundTo = invoker.UserId })
		end

		--[[ Creating Return Table ]]

		local returnMessageTable = {}

		if jobId or accessCode then
			table.insert(returnMessageTable, `Saving retrieved server data from $|cr$|{invoker.Name}#|...`)
		end
		if jobId then
			table.insert(returnMessageTable, `JobId: $|cr$|{jobId}#|`)
		end
		if accessCode then
			table.insert(returnMessageTable, `Access Code: $|cr$|{accessCode}#|`)
		end
		table.insert(returnMessageTable, "_multilineOutput")

		--[[ Returning ]]

		return true, returnMessageTable
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Config Get Functions ]]

		{
			Aliases = { "get_server_metadata" },
			Callback = getServerMetadata,
		},

		--[[ Info Get Functions ]]

		{
			Aliases = { "info" },

			Variants = {
				{
					Aliases = { "get_framework_loading_time" },
					Callback = getFrameworkLoadingTime,
				},
				{
					Aliases = { "get_modules_execution_time" },
					Callback = getModulesExecutionTime,
				},
				{
					Aliases = { "get_modules_functions_execution_time" },
					Args = {
						{ name = "depth", types = { "number" }, optional = true },
					},
					Callback = getModulesFunctionsExecutionTime,
				},
			},
		},

		--[[ Lobby Functions ]]

		{
			Aliases = { "persistent_lobby" },

			Variants = {
				{
					Aliases = { "get_state" },
					Callback = getPersistentLobbyState,
				},
				{
					Aliases = { "update_state" },
					Args = {
						{ name = "state", types = { "boolean" } },
					},
					Callback = updatePersistentLobbyState,
				},
			},
		},

		--[[ Teleport Functions ]]

		{
			Aliases = { "teleport" },

			Variants = {
				{
					Aliases = { "new_server" },
					Args = {
						{ name = "players", types = { "Player", "table" }, dict = "players", requireDict = true },
						{ name = "placeId", types = { "number" }, dict = "Ume_PlaceIds", requireDict = true },
						{ name = "mapId", types = { "string" }, dict = "Ume_PlaceMapIds-$|arg:-1#|", requireDict = true },
						{ name = "guiName", types = { "string" }, dict = "Ume_UtilityGuiNames", requireDict = true, optional = true },
					},
					Callback = teleport,
				},
				{
					Aliases = { "external" },
					Args = {
						{ name = "players", types = { "Player", "table" }, dict = "players", requireDict = true },
						{ name = "placeId", types = { "number" } },
					},
					Callback = teleportExternal,
				},
				{
					Aliases = { "lobby" },
					Args = {
						{ name = "players", types = { "Player", "table" }, dict = "players", requireDict = true },
						{ name = "guiName", types = { "string" }, dict = "Ume_UtilityGuiNames", requireDict = true, optional = true },
					},
					Callback = teleportLobby,
				},
				{
					Aliases = { "existing_server" },
					Args = {
						{ name = "players", types = { "Player", "table" }, dict = "players", requireDict = true },
						{ name = "placeId", types = { "number" }, dict = "Ume_PlaceIds", requireDict = true },
						{ name = "jobId", types = { "string" }, dict = "Ume_SavedJobIds-$|invoker#|", requireDict = true },
						{ name = "accessCode", types = { "string" }, dict = "Ume_ServerAccessCodes-$|invoker#|", requireDict = true, optional = true },
						{ name = "guiName", types = { "string" }, dict = "Ume_UtilityGuiNames", requireDict = true, optional = true },
					},
					Callback = teleportToExistingServer,
				},
			},
		},

		{
			Aliases = { "get_player_job_id" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = getPlayerJobId,

			EnableGlobally = true,
			GlobalOutput = true,

			Callback_GlobalReturn = savePlayerJobId,
			GlobalReturnArgsCount = 2,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Ume_Server", {
		Aliases = { "s_ume" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Commands Server - Utility

--[[
	Registers utility server commands.
]]
function Module._registerCommands_Server_Utility()
	--%%%%%%%%%%%%%%%%%%%% Kick

	I.AdminPanel_CommandBar.Register("Kick", {
		Aliases = { "kick" },
		Args = {
			{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			{ name = "message", types = { "string" } },
			{ name = "showInvoker", types = { "boolean" }, optional = true },
		},
		PermissionLevel = 255,

		PassInvoker = true,
		Callback = function(invoker: Player, player: Player, message: string, showInvoker: boolean?)
			--[[ Creating Message ]]

			local kickMsg: string
			if showInvoker then
				kickMsg = `You were kicked by {invoker.Name}! Reason: {message}`
			else
				kickMsg = `You were kicked! Reason: {message}`
			end

			--[[ Executing ]]

			player:Kick(kickMsg)
			return true, `Kicked $|cr$|{player.Name}#| with message $|cr$|{kickMsg}#|`
		end,
	})

	--%%%%%%%%%%%%%%%%%%%% Kill

	I.AdminPanel_CommandBar.Register("Kill", {
		Aliases = { "kill" },
		Args = {
			{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
		},
		PermissionLevel = 255,

		Callback = function(player: Player)
			--[[ Executing ]]

			-- Getting value
			local character: Model? = player.Character
			if not character then
				return false, `Failed to kill $|cr$|{player.Name}#| - no character`
			end

			local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")

			-- Returning
			if humanoid then
				humanoid:TakeDamage(humanoid.Health)
				return true, `Killed $|cr$|{player.Name}#|`
			else
				return false, `Failed to kill $|cr$|{player.Name}#|`
			end
		end,
	})

	--%%%%%%%%%%%%%%%%%%%% Teleport

	I.AdminPanel_CommandBar.Register("Teleport", {
		Aliases = { "tp" },
		Args = {
			{ name = "player1", types = { "Player" }, dict = "players", requireDict = true },
			{ name = "player2", types = { "Player" }, dict = "players", requireDict = true, optional = true },
		},
		PermissionLevel = 255,

		PassInvoker = true,
		Callback = function(invoker: Player, player1: Player, player2: Player)
			--[[ Updating Variables ]]

			if not player2 then
				player2 = player1
				player1 = invoker
			end

			--[[ Executing ]]

			-- Getting value
			local characterToMove: Model = player1 and player1.Character
			local goalPoint: CFrame = player2 and player2.Character and player2.Character:GetPivot()

			-- Returning
			if characterToMove and goalPoint then
				I.World.MoveModelToPosition(characterToMove, goalPoint)
				return true, `Teleported $|cr$|{player1.Name}#| to $|cr$|{player2.Name}#|`
			else
				return false, `Failed to teleport $|cr$|{player1.Name}#| to $|cr$|{player2.Name}#|`
			end
		end,
	})

	--%%%%%%%%%%%%%%%%%%%% Morph

	I.AdminPanel_CommandBar.Register("Morph", {
		Aliases = { "morph" },
		PermissionLevel = 255,

		Variants = {
			{
				Aliases = { "by_player" },
				Args = {
					{ name = "target", types = { "Player" }, dict = "players", requireDict = true },
					{ name = "morphPlayer", types = { "Player" }, dict = "players", requireDict = true },
				},

				Callback = function(target: Player, morphPlayer: Player)
					--[[ Getting Data ]]

					-- Getting Humanoid
					local existingCharacter: Model = target.Character
					local existingHumanoid: Humanoid = existingCharacter and existingCharacter:FindFirstChildOfClass("Humanoid")
					if not existingHumanoid then
						return false, `Failed to get Humanoid for $|cr$|{target.Name}#|`
					end

					-- Getting Humanoid Description
					local success: boolean, morphHumanoidDescription: HumanoidDescription = pcall(function()
						return Players:GetHumanoidDescriptionFromUserIdAsync(morphPlayer.UserId)
					end)
					if not success or not morphHumanoidDescription then
						return false, `Failed to get HumanoidDescription for $|cr$|{morphPlayer.Name}#|`
					end

					--[[ Executing ]]

					-- Getting value
					local success: boolean = pcall(function()
						existingHumanoid:ApplyDescriptionAsync(morphHumanoidDescription)
					end)

					-- Returning
					if success then
						return true, `Applied HumanoidDescription $|cr$|{morphPlayer.Name}#| to $|cr$|{target.Name}#|`
					else
						return false, `Failed to apply HumanoidDescription $|cr$|{morphPlayer.Name}#| to $|cr$|{target.Name}#|`
					end
				end,
			},
			{
				Aliases = { "by_name" },
				Args = {
					{ name = "target", types = { "Player" }, dict = "players", requireDict = true },
					{ name = "morphPlayerName", types = { "string" } },
				},

				Callback = function(target: Player, morphPlayerName: string)
					--[[ Getting Data ]]

					-- Getting Humanoid
					local existingCharacter: Model = target.Character
					local existingHumanoid: Humanoid = existingCharacter and existingCharacter:FindFirstChildOfClass("Humanoid")
					if not existingHumanoid then
						return false, `Failed to get Humanoid for $|cr$|{target.Name}#|`
					end

					-- Getting userId
					local success: boolean, morphPlayerId: number = pcall(function()
						return Players:GetUserIdFromNameAsync(morphPlayerName)
					end)
					if not success or not morphPlayerId then
						return false, `Failed to retrieve $|cr$|{morphPlayerName}#|'s userId`
					end

					-- Getting Humanoid Description
					local success: boolean, morphHumanoidDescription: HumanoidDescription = pcall(function()
						return Players:GetHumanoidDescriptionFromUserIdAsync(morphPlayerId)
					end)
					if not success or not morphHumanoidDescription then
						return false, `Failed to get HumanoidDescription for $|cr$|{morphPlayerName}#|`
					end

					--[[ Executing ]]

					-- Getting value
					local success: boolean = pcall(function()
						existingHumanoid:ApplyDescriptionAsync(morphHumanoidDescription)
					end)

					-- Returning
					if success then
						return true, `Applied HumanoidDescription $|cr$|{morphPlayerName}#| to $|cr$|{target.Name}#|`
					else
						return false, `Failed to apply HumanoidDescription $|cr$|{morphPlayerName}#| to $|cr$|{target.Name}#|`
					end
				end,
			},
			{
				Aliases = { "by_id" },
				Args = {
					{ name = "target", types = { "Player" }, dict = "players", requireDict = true },
					{ name = "morphPlayerId", types = { "number" } },
				},

				Callback = function(target: Player, morphPlayerId: number)
					--[[ Getting Data ]]

					-- Getting Humanoid
					local existingCharacter: Model = target.Character
					local existingHumanoid: Humanoid = existingCharacter and existingCharacter:FindFirstChildOfClass("Humanoid")
					if not existingHumanoid then
						return false, `Failed to get Humanoid for $|cr$|{target.Name}#|`
					end

					-- Getting name
					local success: boolean, morphPlayerName: string = pcall(function()
						return Players:GetNameFromUserIdAsync(morphPlayerId)
					end)
					if not success or not morphPlayerName then
						morphPlayerName = morphPlayerId
					end

					-- Getting Humanoid Description
					local success: boolean, morphHumanoidDescription: HumanoidDescription = pcall(function()
						return Players:GetHumanoidDescriptionFromUserIdAsync(morphPlayerId)
					end)
					if not success or not morphHumanoidDescription then
						return false, `Failed to get HumanoidDescription for $|cr$|{morphPlayerName}#|`
					end

					--[[ Executing ]]

					-- Getting value
					local success: boolean = pcall(function()
						existingHumanoid:ApplyDescriptionAsync(morphHumanoidDescription)
					end)

					-- Returning
					if success then
						return true, `Applied HumanoidDescription $|cr$|{morphPlayerName}#| to $|cr$|{target.Name}#|`
					else
						return false, `Failed to apply HumanoidDescription $|cr$|{morphPlayerName}#| to $|cr$|{target.Name}#|`
					end
				end,
			},

			{
				Aliases = { "reset" },
				Args = {
					{ name = "target", types = { "Player" }, dict = "players", requireDict = true },
				},

				Callback = function(target: Player)
					--[[ Getting Data ]]

					-- Getting Humanoid
					local existingCharacter: Model = target.Character
					local existingHumanoid: Humanoid = existingCharacter and existingCharacter:FindFirstChildOfClass("Humanoid")
					if not existingHumanoid then
						return false, `Failed to get Humanoid for $|cr$|{target.Name}#|`
					end

					-- Getting Humanoid Description
					local success: boolean, morphHumanoidDescription: HumanoidDescription = pcall(function()
						return Players:GetHumanoidDescriptionFromUserIdAsync(target.UserId)
					end)
					if not success or not morphHumanoidDescription then
						return false, `Failed to get HumanoidDescription for $|cr$|{target.Name}#|`
					end

					--[[ Executing ]]

					-- Getting value
					local success: boolean = pcall(function()
						existingHumanoid:ApplyDescriptionAsync(morphHumanoidDescription)
					end)

					-- Returning
					if success then
						return true, `$|cr$|{target.Name}#|'s $|cr$|HumanoidDescription#| has been reset`
					else
						return false, `Failed to reset $|cr$|{target.Name}#|'s $|cr$|HumanoidDescription#|`
					end
				end,
			},
		},
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Dictionaries Server

--[[
	Registers general ume dictionaries.
]]
function Module._registerDictionaries_Server()
	--
	--%%%%%%%%%%%%%%%%%%%% Utility Guis %%%%%%%%%%%%%%%%%%%%--

	local allUtilityGuiNames = {} --- @type { string }

	local utilityGuisDir: Folder = I.Dirs.UmeServer:FindFirstChild("UtilityGuis")
	local utilityGuis: { ScreenGui }? = utilityGuisDir and utilityGuisDir:GetChildren()

	if utilityGuis then
		for _, gui: ScreenGui in ipairs(utilityGuis) do
			if gui:IsA("ScreenGui") and not table.find(allUtilityGuiNames, gui.Name) then
				table.insert(allUtilityGuiNames, gui.Name)
			end
		end
	end

	-- Updating Dictionary
	I.AdminPanel_CommandBar.SetDictionary(`Ume_UtilityGuiNames`, allUtilityGuiNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
