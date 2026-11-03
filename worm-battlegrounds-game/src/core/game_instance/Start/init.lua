--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tasks

-- Core setup tasks
local replication_gate = require(script.tasks.replication_gate) --- @type Ume_Task_ReplicationGate
local directories = require(script.tasks.directories) --- @type Ume_Task_Directories
local environment = require(script.tasks.environment) --- @type Ume_Task_Environment
local libraries = require(script.tasks.libraries) --- @type Ume_Task_Libraries
local services = require(script.tasks.services) --- @type Ume_Task_Services
local config = require(script.tasks.config) --- @type Ume_Task_Config
local datastore_access = require(script.tasks.datastore_access) --- @type Ume_Task_DatastoreAccess

-- Core runtime tasks
local finished_functions = require(script.tasks.finished_functions) --- @type Ume_Task_FinishedFunctions
local modules = require(script.tasks.modules) --- @type Ume_Task_Modules
local pointer = require(script.tasks.pointer) --- @type Ume_Task_Pointer
local protect = require(script.tasks.protect) --- @type Ume_Task_Protect
local status = require(script.tasks.status) --- @type Ume_Task_Status

-- Special behavior
local place_loader = require(script.tasks.place_loader) --- @type Ume_Task_Place_Loader

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--  __    __                                ______                        __
-- /  |  /  |                              /      |                      /  |
-- $$ |  $$ | _____  ____    ______        $$$$$$/  _______    _______  _$$ |_     ______   _______    _______   ______
-- $$ |  $$ |/     \/    \  /      \         $$ |  /       \  /       |/ $$   |   /      \ /       \  /       | /      \
-- $$ |  $$ |$$$$$$ $$$$  |/$$$$$$  |        $$ |  $$$$$$$  |/$$$$$$$/ $$$$$$/    $$$$$$  |$$$$$$$  |/$$$$$$$/ /$$$$$$  |
-- $$ |  $$ |$$ | $$ | $$ |$$    $$ |        $$ |  $$ |  $$ |$$      \   $$ | __  /    $$ |$$ |  $$ |$$ |      $$    $$ |
-- $$ \__$$ |$$ | $$ | $$ |$$$$$$$$/        _$$ |_ $$ |  $$ | $$$$$$  |  $$ |/  |/$$$$$$$ |$$ |  $$ |$$ \_____ $$$$$$$$/
-- $$    $$/ $$ | $$ | $$ |$$       |      / $$   |$$ |  $$ |/     $$/   $$  $$/ $$    $$ |$$ |  $$ |$$       |$$       |
--  $$$$$$/  $$/  $$/  $$/  $$$$$$$/       $$$$$$/ $$/   $$/ $$$$$$$/     $$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--[[
	For more information, please refer to the documentation at https://github.com/ume-roblox.
]]
--- @class Ume
local Ume = {}

function Ume.Bloom()
	Ume.Bloom = nil -- Clear to prevent being called a second time

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	--[[
		Indicates if the Ume framework has fully loaded and started.
	]]
	Ume.Started = false

	local startLoadingTime: number = os.clock()

	--%%%%%%%%%%%%%%%%%%%% [1] - Load

	--[[ Client:Waiting for replication gate ]]

	replication_gate.WaitBeforeFrameworkLoad(Ume)

	--[[ Loading core services and assets ]]

	services.Load(Ume)
	environment.Load(Ume)
	directories.Load(Ume)
	config.Load(Ume)

	datastore_access.CheckAccess(Ume)

	libraries.Load(Ume)
	libraries.InjectUme(Ume)

	--%%%%%%%%%%%%%%%%%%%% [2] - Place Loader

	--[[ Server: loading map ]]

	if Ume.Env.IsServer then
		--[[ Verifying and loading ]]

		place_loader.FindDuplicated(Ume)
		place_loader.VerifyConfigs(Ume)
		place_loader.GetStores(Ume)
		place_loader.GetCurrentPlaceConfig(Ume)

		--[[ Getting MapId / Lobby ]]

		place_loader.IsLobbyPersistent(Ume)
		place_loader.FetchMapId(Ume)

		--[[ Updating Config and Directories ]]

		place_loader.UpdateCurrentMapConfig(Ume)
		place_loader.MoveWorkspaceMap(Ume)
		place_loader.UpdateDirectories(Ume)

		--[[ Temporary Lobby ]]

		if place_loader.IsLobby and not place_loader.IsPersistentLobby then
			place_loader.TeleportPlayersToMainServer(Ume)
			return -- Return to prevent further loading
		end

		--[[ Registering Functions ]]

		place_loader.CreateLobbyFunctions(Ume)
		place_loader.CreateTeleportFunction(Ume)
	end

	--[[ Client: updating config ]]

	if Ume.Env.IsClient then
		place_loader.UpdateCurrentMapConfig(Ume)
	end

	--%%%%%%%%%%%%%%%%%%%% [3] - Pointer & Config

	--[[ Create framework pointer ]]

	if Ume.Env.IsServer then
		pointer.Create(Ume)
	end

	--[[ Register OnStarted (called when framework finishes loading) ]]

	finished_functions.CreateOnStartedFunction(Ume)

	--[[ Register OnLoaded (called when player data loads on the server) ]]

	if Ume.Env.IsClient then
		finished_functions.CreateOnLoadedFunction(Ume)
	end

	--[[ Update config to production ]]

	if not Ume.Env.IsStudio then
		config.Update(Ume)
	end

	--%%%%%%%%%%%%%%%%%%%% [4] - Modules

	--[[ Prepare modules: rename, filter, store ]]

	if Ume.Env.IsServer then
		modules.PrepareForLoading(Ume)
	end
	modules.StoreAllModules(Ume)

	--[[ Run all modules and finished functions ]]

	modules.Run(Ume)
	finished_functions.RunFrameworkStarted()

	--%%%%%%%%%%%%%%%%%%%% [5] - Protect

	--[[ Hide server-side scripts from the client ]]

	if Ume.Env.IsServer then
		protect.HideServerScripts(Ume)
	end

	--%%%%%%%%%%%%%%%%%%%% [6] - Finishing

	--[[ Server: listen and expose instance to the client ]]

	if Ume.Env.IsServer then
		finished_functions.CreateOnLoadedRemote(Ume)
		status.ListenForClient(Ume)

		replication_gate.WriteServerManifest(Ume)
		protect.ExposeInstanceToClient(Ume)
	end

	--[[ Client: listen and inform the server that loading is complete ]]

	if Ume.Env.IsClient then
		finished_functions.ListenForPlayerLoadedRemote(Ume)
		status.Update(Ume)
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	Ume.Started = true

	--[[ Calculate loading time ]]

	local endLoadingTime: number = os.clock()
	local loadingTimeFormatted: string = ("%.3f"):format(endLoadingTime - startLoadingTime)

	-- Total execution time for loading the framework.
	--- @type number
	Ume._frameworkLoadingTime = endLoadingTime - startLoadingTime

	--[[ Console output ]]

	if Ume.Env.IsStudio then
		print(`🌸 {Ume.Env.Key} [{loadingTimeFormatted}s]`)
	else
		if Ume.Env.IsClient then
			print(`🌸 {Ume.Env.Key} [{loadingTimeFormatted}s]`)
			print(`\t🏷️ UME{Ume.Config.General._umeVersion}_G{Ume.Config.General.GameVersion} ─ (P{game.PlaceId}_V{game.PlaceVersion})`)
			print(`\t📌 Place: {Ume.Config.PlaceLoader.PlaceId} || Map: {Ume.Config.PlaceLoader.MapId}`)
			print(`\t👤 {Ume.Env.LocalPlayer.Name} [{Ume.Env.LocalPlayer.DisplayName}] ({Ume.Env.LocalPlayer.UserId})`)
			print("")
			print("─────────────────────────────────────────────────────────")
			print("── Found an error? Please share it with us on our community server. ──")
			print("─────────────────────── 「 ✦ Ume ✦ 」 ───────────────────────")
		else
			print(`🌸 {Ume.Env.Key} [{loadingTimeFormatted}s]`)
			print("─────────────────────── 「 ✦ Ume ✦ 」 ───────────────────────")
		end
	end
end

return Ume
