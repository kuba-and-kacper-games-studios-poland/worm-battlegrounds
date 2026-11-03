--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = game:GetService("RunService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--%%%%%%%%%%%%%%%%%%%% General

--- @type ProfileStore_Helpers
local helpersScript = require(_scripts.helpers)

--- @type ProfileStore_Mock
local mockScript = require(_scripts.mock)

--- @type ProfileStore_DataStore
local dataStoreScript = require(_scripts.datastore)

--- @type ProfileStore_Save
local saveScript = require(_scripts.save)

--- @type Player_Profile
local profileScript = require(_scripts.profile)

--- @type ProfileStore_VersionQuery
local versionQueryScript = require(_scripts.version_query)

--- @type ProfileStore_Methods
local profileStoreScript = require(_scripts.profile_store)

--- @type ProfileStore_Runtime
local runtimeScript = require(_scripts.runtime)

--%%%%%%%%%%%%%%%%%%%% Other

--- @type ProfileStore_Signal
local Signal = require(_scripts.signal)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Types

export type JSONAcceptable = { JSONAcceptable } | { [string]: JSONAcceptable } | number | string | boolean | buffer

export type Profile<T> = {
	Data: T & JSONAcceptable,
	LastSavedData: T & JSONAcceptable,
	FirstSessionTime: number,
	SessionLoadCount: number,
	Session: { PlaceId: number, JobId: string }?,
	RobloxMetaData: JSONAcceptable,
	UserIds: { number },
	KeyInfo: DataStoreKeyInfo,
	OnSave: { Connect: (self: any, listener: () -> ()) -> { Disconnect: (self: any) -> () } },
	OnLastSave: {
		Connect: (self: any, listener: (reason: "Manual" | "External" | "Shutdown") -> ()) -> {
			Disconnect: (self: any) -> (),
		},
	},
	OnSessionEnd: { Connect: (self: any, listener: () -> ()) -> { Disconnect: (self: any) -> () } },
	OnAfterSave: {
		Connect: (self: any, listener: (last_saved_data: T & JSONAcceptable) -> ()) -> {
			Disconnect: (self: any) -> (),
		},
	},
	ProfileStore: JSONAcceptable,
	Key: string,

	IsActive: (self: any) -> boolean,
	Reconcile: (self: any) -> (),
	EndSession: (self: any) -> (),
	AddUserId: (self: any, user_id: number) -> (),
	RemoveUserId: (self: any, user_id: number) -> (),
	MessageHandler: (self: any, fn: (message: JSONAcceptable, processed: () -> ()) -> ()) -> (),
	Save: (self: any) -> (),
	SetAsync: (self: any) -> (),
}

export type VersionQuery<T> = {
	NextAsync: (self: any) -> Profile<T>?,
}

type ProfileStoreStandard<T> = {
	Name: string,
	StartSessionAsync: (self: any, profile_key: string, params: { Steal: boolean? }?) -> Profile<T>?,
	MessageAsync: (self: any, profile_key: string, message: JSONAcceptable) -> boolean,
	GetAsync: (self: any, profile_key: string, version: string?) -> Profile<T>?,
	VersionQuery: (self: any, profile_key: string, sort_direction: Enum.SortDirection?, min_date: DateTime | number | nil, max_date: DateTime | number | nil) -> VersionQuery<T>,
	RemoveAsync: (self: any, profile_key: string) -> boolean,
}

export type ProfileStore<T> = {
	Mock: ProfileStoreStandard<T>,
} & ProfileStoreStandard<T>

type ConstantName =
	"AUTO_SAVE_PERIOD"
	| "LOAD_REPEAT_PERIOD"
	| "FIRST_LOAD_REPEAT"
	| "SESSION_STEAL"
	| "ASSUME_DEAD"
	| "START_SESSION_TIMEOUT"
	| "CRITICAL_STATE_ERROR_COUNT"
	| "CRITICAL_STATE_ERROR_EXPIRE"
	| "CRITICAL_STATE_EXPIRE"
	| "MAX_MESSAGE_QUEUE"

export type ProfileStoreModule = {
	IsClosing: boolean,
	IsCriticalState: boolean,
	OnError: {
		Connect: (self: any, listener: (message: string, store_name: string, profile_key: string) -> ()) -> { Disconnect: (self: any) -> () },
	},
	OnOverwrite: {
		Connect: (self: any, listener: (store_name: string, profile_key: string) -> ()) -> {
			Disconnect: (self: any) -> (),
		},
	},
	OnCriticalToggle: { Connect: (self: any, listener: (is_critical: boolean) -> ()) -> { Disconnect: (self: any) -> () } },
	DataStoreState: "NotReady" | "NoInternet" | "NoAccess" | "Access",
	New: <T>(store_name: string, template: (T & JSONAcceptable)?) -> ProfileStore<T>,
	SetConstant: (name: ConstantName, value: number) -> (),
	_injectUme: (umeInstance: any) -> (),
}

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

--- @class ProfileStore : Ume_Library
local ProfileStore: ProfileStoreModule = {

	IsClosing = false,
	IsCriticalState = false,
	OnError = Signal.New(), -- (message, store_name, profile_key)
	OnOverwrite = Signal.New(), -- (store_name, profile_key)
	OnCriticalToggle = Signal.New(), -- (is_critical)
	DataStoreState = "NotReady", -- ("NotReady", "NoInternet", "NoAccess", "Access")
}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function ProfileStore._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.ProfileStore = ProfileStore --- @type ProfileStore
end

--[[ Class Metatable (used by ProfileStore instances) ]]

local ProfileStoreClass = {}
ProfileStoreClass.__index = ProfileStoreClass

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[
	Mutable tuning constants. Exposed through ProfileStore.SetConstant so
	developer code can adjust them at runtime without editing the module.
]]

--- @class ProfileStore_Constants
local constants = {
	AUTO_SAVE_PERIOD = 300, -- Seconds between auto saves for a single profile
	LOAD_REPEAT_PERIOD = 10, -- Seconds between successive reads during session conflicts
	FIRST_LOAD_REPEAT = 5, -- Seconds between first and second session-conflict reads
	SESSION_STEAL = 40, -- Seconds until a session conflict is resolved by stealing
	ASSUME_DEAD = 630, -- Seconds of no updates before an active session is assumed crashed
	START_SESSION_TIMEOUT = 120, -- Seconds before StartSessionAsync gives up when no Cancel is set

	CRITICAL_STATE_ERROR_COUNT = 5, -- Concurrent-error threshold for critical state
	CRITICAL_STATE_ERROR_EXPIRE = 120, -- Seconds after which a logged issue expires
	CRITICAL_STATE_EXPIRE = 120, -- Seconds of quiet before leaving critical state

	MAX_MESSAGE_QUEUE = 1000, -- Max messages stored per profile via MessageAsync
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shared Context

--[[
	The "shared" bag passed to each sub-script's Init. Fields are:
		Module            - the public ProfileStore table (for signal access & closing flag)
		ProfileStoreClass - class metatable used by ProfileStore.New
		Signal            - Signal.New factory
		constants         - tunable numeric constants (mutated via SetConstant)
		state             - mutable runtime state tables (active sessions, queues, ...)
		env               - read-only environment info (PlaceId / JobId / IsStudio)
		_localName        - name used in log prefixes
		Helpers / Mock / DataStore / Save / Profile / VersionQuery - filled in order
]]

--- @class ProfileStore_State
local _state = {
	ActiveSessionCheck = {}, -- [session_token] = profile
	AutoSaveList = {}, -- profiles in auto-save ring
	IssueQueue = {}, -- {issue_time_clock, ...}
	UpdateQueue = {}, -- [session_token] = { coroutine, ... }
	MockStore = {}, -- Fallback mock data (used when API is off)
	UserMockStore = {}, -- User-opted-in mock data (ProfileStore.Mock)
	MockFlag = false, -- Set by ProfileStore.Mock wrappers
	AutoSaveIndex = 1,
	LastAutoSave = os.clock(),
	LoadIndex = 0,
	ActiveProfileLoadJobs = 0,
	ActiveProfileSaveJobs = 0,
	CriticalStateStart = 0,
}

--- @class ProfileStore_Env
local _env = {
	PlaceId = game.PlaceId,
	JobId = game.JobId,
	IsStudio = RunService:IsStudio(),
}

--- @class ProfileStore_Shared
local shared = {
	_localName = script.Name,

	Module = ProfileStore,
	ProfileStoreClass = ProfileStoreClass,
	Signal = Signal,
	constants = constants,
	state = _state,
	env = _env,
}

Signal.Init(shared)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub-script Initialization

--[[
	Init order matters: each sub-script reads references set by earlier
	ones from `shared`. Concretely:
		helpers       -> no deps
		mock          -> Helpers
		datastore     -> Helpers, Mock
		save          -> Helpers, DataStore
		profile       -> Signal, Helpers, Save
		version_query -> Helpers
		profile_store -> Helpers, DataStore, Save, Profile, VersionQuery
		runtime       -> Save
]]

helpersScript.Init(shared)
shared.Helpers = helpersScript

mockScript.Init(shared)
shared.Mock = mockScript

dataStoreScript.Init(shared)
shared.DataStore = dataStoreScript

saveScript.Init(shared)
shared.Save = saveScript

profileScript.Init(shared)
shared.Profile = profileScript

versionQueryScript.Init(shared)
shared.VersionQuery = versionQueryScript

profileStoreScript.Init(shared)
runtimeScript.Init(shared)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Class Methods

--[[
	Attach the public instance methods to the class metatable so they
	resolve via __index for every ProfileStore instance returned by
	ProfileStore.New(...).
]]

ProfileStoreClass.StartSessionAsync = profileStoreScript.StartSessionAsync
ProfileStoreClass.MessageAsync = profileStoreScript.MessageAsync
ProfileStoreClass.GetAsync = profileStoreScript.GetAsync
ProfileStoreClass.RemoveAsync = profileStoreScript.RemoveAsync
ProfileStoreClass.VersionQuery = profileStoreScript.VersionQuery

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Static Functions

--%%%%%%%%%%%%%%%%%%%%%%%%%% New

--[[
	**SERVER** |
	Creates a ProfileStore instance. See Scripts/profile_store.lua for details.
]]
ProfileStore.New = profileStoreScript.New

--%%%%%%%%%%%%%%%%%%%%%%%%%% Set Constant

--[[
	**SERVER** |
	Updates a tunable constant at runtime. Validates the name and enforces
	a numeric value so callers can't silently break behaviour.
]]
function ProfileStore.SetConstant(name, value)
	if type(value) ~= "number" then
		error(`[{shared._localName}]: Invalid value type`)
	end

	if constants[name] == nil then
		error(`[{shared._localName}]: Invalid constant name was provided`)
	end

	constants[name] = value
end

--%%%%%%%%%%%%%%%%%%%%%%%%%% Test (Studio-only)

--[[
	**SERVER** |
	Exposes internal tables for test assertions. Gated to Studio only so
	production server code can't accidentally mutate live ProfileStore
	internals. Returns a fresh table of references each call.
]]
function ProfileStore.Test()
	if shared.env.IsStudio == false then
		return nil
	end

	return {
		ActiveSessionCheck = shared.state.ActiveSessionCheck,
		AutoSaveList = shared.state.AutoSaveList,
		ActiveProfileLoadJobs = shared.state.ActiveProfileLoadJobs,
		ActiveProfileSaveJobs = shared.state.ActiveProfileSaveJobs,
		MockStore = shared.state.MockStore,
		UserMockStore = shared.state.UserMockStore,
		UpdateQueue = shared.state.UpdateQueue,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Runtime Startup

runtimeScript.StartAll()

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return ProfileStore
