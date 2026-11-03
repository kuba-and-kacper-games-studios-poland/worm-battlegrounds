--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Place_Loader
local _task = {

	--[[ Stores ]]

	MapHashMap = nil, --- @type MemoryStoreHashMap
	LobbyStore = nil, --- @type DataStore

	--[[ Lobby ]]

	IsLobby = false, --- @type boolean
	IsPersistentLobby = false, --- @type boolean

	--[[ Configs ]]

	PlaceId = nil, --- @type number
	PlaceConfig = nil, --- @type Ume_PlaceLoader_PlaceSettings

	MapId = nil, --- @type string
	MapConfig = nil, --- @type Ume_PlaceLoader_MapSettings
	Metadata = nil, --- @type Ume_PlaceLoader_Metadata?
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Config = require(script.Config)(_task) --- @type Ume_Task_Place_Loader_Config
local Directories = require(script.Directories)(_task) --- @type Ume_Task_Place_Loader_Directories
local Lobby = require(script.Lobby)(_task) --- @type Ume_Task_Place_Loader_Lobby
local Map = require(script.Map)(_task, script) --- @type Ume_Task_Place_Loader_Map
local Teleport = require(script.Teleport)(_task) --- @type Ume_Task_Place_Loader_Teleport

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

_task.FindDuplicated = Directories.FindDuplicated
_task.VerifyConfigs = Config.VerifyConfigs
_task.GetStores = Config.GetStores
_task.GetCurrentPlaceConfig = Config.GetCurrentPlaceConfig

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lobby Control

_task.IsLobbyPersistent = Lobby.IsLobbyPersistent
_task.CreateLobbyFunctions = Lobby.CreateLobbyFunctions

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Map Control

_task.FetchMapId = Map.FetchMapId
_task.UpdateCurrentMapConfig = Map.UpdateCurrentMapConfig
_task.MoveWorkspaceMap = Directories.MoveWorkspaceMap
_task.UpdateDirectories = Directories.UpdateDirectories

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Teleport Control

_task.TeleportPlayersToMainServer = Teleport.TeleportPlayersToMainServer
_task.CreateTeleportFunction = Teleport.CreateTeleportFunction

return _task
