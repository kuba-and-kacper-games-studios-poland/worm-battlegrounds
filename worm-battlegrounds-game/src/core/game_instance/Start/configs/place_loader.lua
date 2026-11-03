--[[
	Place Loader Configuration.
]]
--- @class Ume_Config_PlaceLoader
local _config = {

	--%%%%%%%%%%%%%%%%%%%% General

	--[[
		Id of the default starting place (where players join the game and where the main lobby is located).
		You should point it to a specific place if the game works across multiple places.
	]]
	DefaultPlaceId = game.PlaceId,

	--%%%%%%%%%%%%%%%%%%%% Map Loader / Persistent Lobby

	-- Id used by `MemoryStoreService` to identify the currently loaded map.
	_mapStoreId = "__Ume_MapId",

	-- Id used by `DataStore` to check and update state of the persistent lobby.
	_lobbyStoreId = "__Ume_PersistentLobby",

	-- Determines whether the persistent lobby should also load in Studio.
	PersistentLobbyInStudio = true,

	-- List of private server Ids excluded from the persistent lobby.
	PersistentLobbyExcludedServers = {}, --- @type { string }

	--%%%%%%%%%%%%%%%%%%%% Places/Maps Configs

	-- Current PlaceId. Set by the `place_loader` task.
	PlaceId = nil, --- @type number

	-- Current MapId. Set by the `place_loader` task.
	MapId = nil, --- @type string

	--[[
		Table with place configuration indexed by their placeId.
	]]
	--- @type { [number]: Ume_PlaceLoader_PlaceSettings }
	PlaceConfigs = {
		[game.PlaceId] = {
			DefaultMapId = "Default",
			LobbyId = "UmeLobby",

			MapConfigs = {
				["Default"] = {
					-- Data
					ProfileStoreName = "UmeTesting_-1",
					LeaderboardStoreName = "UmeTesting_-1",

					-- Accessibility
					VRSupport = false,

					-- Directories
					GameDirs = {
						Workspace_Ume = { "Default" },
						ReplicatedStorage_Ume = { "Default" },
						ServerStorage_Ume = { "Default" },

						StarterGui = { "Default" },
						StarterPack = { "Default" },
						StarterPlayer = { "Default" },

						Assets = { "Default" },
						SAssets = { "Default" },
					},

					-- Modules
					ModulesDirs = {
						-- Ume
						"Ume",
						"Ume_Data",
						"Roblox",

						-- Game
						"Utils",
						"Main",
						"Main_Game",
						"Main_Controllers",
					},
					DisabledModules = {},
					LoadingOrder = {},

					-- Other
					ReturnPlaceId = nil,
				},
				["UmeLobby"] = {
					-- Data
					ProfileStoreName = "UmeTesting_-1",
					LeaderboardStoreName = "UmeTesting_-1",

					-- Accessibility
					VRSupport = false,

					-- Directories
					GameDirs = {
						Workspace_Ume = { "UmeLobby" },
						ReplicatedStorage_Ume = { "UmeLobby" },
						ServerStorage_Ume = { "UmeLobby" },

						StarterGui = { "UmeLobby" },
						StarterPack = { "UmeLobby" },
						StarterPlayer = { "UmeLobby" },

						Assets = { "UmeLobby" },
						SAssets = { "UmeLobby" },
					},

					-- Modules
					ModulesDirs = {
						-- Ume
						"Ume",
						"Ume_Data",
						"Roblox",

						-- Game
						"Utils",
						"Main",
						"Main_Game",
						"Main_Controllers",
					},
					DisabledModules = {},
					LoadingOrder = {},

					-- Other
					ReturnPlaceId = game.PlaceId,
				},
			},
		},
	},
}

return _config
