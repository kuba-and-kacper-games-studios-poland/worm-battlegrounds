--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Network"

--- @type Network_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Inbound = require(_scripts:FindFirstChild("Global"):FindFirstChild("Inbound")) --- @type Network_Global_Inbound
local Stats = require(_scripts:FindFirstChild("Global"):FindFirstChild("Stats")) --- @type Network_Global_Stats

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local remotesDir: Folder

--[[ Remotes]]

--- @type { [string]: RemoteEvent | UnreliableRemoteEvent | RemoteFunction }
local savedRemotes = {}

--- @type { [string]: Validate_ArgumentSchema }
local remoteArgTypes = {}

--- @type { [string]: { Validate_SchemaSpec } }
local remoteSpecs = {}

--- @type { [string]: Network_RemoteOptions }
local remoteOptions = {}

--- @type { [string]: boolean }
local ownedRemotes = {}

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

	if I.Env.IsClient then
		Module._storeExisting()
	end

	Inbound.Init(remoteArgTypes, remoteSpecs, remoteOptions)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Network = {

		--[[ Control ]]

		Fire = Module.Fire,
		FireAll = Module.FireAll,
		Fired = Module.Fired,

		UFire = Module.UFire,
		UFireAll = Module.UFireAll,
		UFired = Module.UFired,

		Invoke = Module.Invoke,
		OnInvoke = Module.OnInvoke,

		--[[ Methods ]]

		GetEvent = Module.GetEvent,
		GetFunction = Module.GetFunction,
		GetUEvent = Module.GetUEvent,

		--[[ Private ]]

		_getStats = Stats.Get,
		_resetStats = Stats.Reset,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Directories

--[[
	Creates folder for storing created remotes.
]]
function Module._createDirectories()
	--[[ Server: Creating Folder ]]

	if I.Env.IsServer then
		if not script.Parent:FindFirstChild("Remotes") then
			remotesDir = I.Create("Folder")({
				Name = "Remotes",
				Parent = script.Parent,
			})
		else
			remotesDir = script.Parent:FindFirstChild("Remotes")
		end
	end

	--[[ Client: Saving Folder ]]

	if I.Env.IsClient then
		remotesDir = script.Parent:FindFirstChild("Remotes")
	end
end

--%%%%%%%%%%%%%%%%%%%% Store Existing

--[[
	**CLIENT** |
	Stores all existing remotes that were created on the server.
]]
function Module._storeExisting()
	for _, elem: Instance in ipairs(remotesDir:GetChildren()) do
		--[[ Getting Remote Name ]]

		local remoteName = elem:GetAttribute("Network_Name")
		if not remoteName or savedRemotes[remoteName] then
			continue
		end

		--[[ Saving Remote ]]

		elem:SetAttribute("Network_Name", nil)
		savedRemotes[remoteName] = elem
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remote Event

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Fires a `RemoteEvent`.
]]
function Module.Fire(name: string, optionalPlayer: any, ...: any)
	--[[ Getting Remote ]]

	local remote: RemoteEvent = Module._getForUse(name, "RemoteEvent", "fired")
	if not remote then
		return
	end

	--[[ Checks ]]

	-- Server: Player is invalid
	if I.Env.IsServer and (not optionalPlayer or not I.Player.Valid(optionalPlayer)) then
		warn(`[{_localName}::{script.Name}]: ({optionalPlayer}) is not a valid Player!`)
		return nil
	end

	--[[ Firing ]]

	Stats.Record(name, "Out", optionalPlayer, ...)

	if I.Env.IsServer then
		remote:FireClient(optionalPlayer, ...)
		return
	end

	-- Client: Send no arguments when none were passed
	if optionalPlayer == nil and select("#", ...) == 0 then
		remote:FireServer()
		return
	end

	remote:FireServer(optionalPlayer, ...)
end

--%%%%%%%%%%%%%%%%%%%% Fire All

--[[
	**SERVER** |
	Fires a `RemoteEvent` for all players.
]]
function Module.FireAll(name: string, ...: any)
	--[[ Checks ]]

	-- Client: FireAll is server only
	if I.Env.IsClient then
		warn(`[{_localName}::{script.Name}]: FireAll can only be called on the server!`)
		return
	end

	--[[ Getting Remote ]]

	local remote: RemoteEvent = Module._getForUse(name, "RemoteEvent", "fired")
	if not remote then
		return
	end

	--[[ Firing ]]

	Stats.Record(name, "Out", ...)
	remote:FireAllClients(...)
end

--%%%%%%%%%%%%%%%%%%%% Fired

--[[
	Connects `callback` to execute when a `RemoteEvent` with associated `name` is fired.
]]
--- @param callback function
--- @return RBXScriptConnection?
function Module.Fired(name: string, callback)
	--[[ Getting Remote ]]

	local remote: RemoteEvent = Module._getForUse(name, "RemoteEvent", "listened to")
	if not remote then
		return nil
	end

	--[[ Checks ]]

	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) for RemoteEvent ({name})! Expected (function), got ({callback}: {typeof(callback)}).`)
		return nil
	end

	--[[ Connecting ]]

	local function onFire(...: any)
		-- Drop calls that fail the inbound checks
		if not Inbound.Accept("RemoteEvent", name, ...) then
			return
		end

		callback(...)
	end

	if I.Env.IsServer then
		return remote.OnServerEvent:Connect(onFire)
	end

	return remote.OnClientEvent:Connect(onFire)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unreliable Remote Event

--%%%%%%%%%%%%%%%%%%%% UFire

--[[
	Fires an `UnreliableRemoteEvent`.
]]
function Module.UFire(name: string, optionalPlayer: any, ...: any)
	--[[ Getting Remote ]]

	local remote: UnreliableRemoteEvent = Module._getForUse(name, "UnreliableRemoteEvent", "fired")
	if not remote then
		return
	end

	--[[ Checks ]]

	-- Server: Player is invalid
	if I.Env.IsServer and (not optionalPlayer or not I.Player.Valid(optionalPlayer)) then
		warn(`[{_localName}::{script.Name}]: ({optionalPlayer}) is not a valid Player!`)
		return nil
	end

	--[[ Firing ]]

	Stats.Record(name, "Out", optionalPlayer, ...)

	if I.Env.IsServer then
		remote:FireClient(optionalPlayer, ...)
		return
	end

	-- Client: Send no arguments when none were passed
	if optionalPlayer == nil and select("#", ...) == 0 then
		remote:FireServer()
		return
	end

	remote:FireServer(optionalPlayer, ...)
end

--%%%%%%%%%%%%%%%%%%%% UFire All

--[[
	**SERVER** |
	Fires an `UnreliableRemoteEvent` for all players.
]]
function Module.UFireAll(name: string, ...: any)
	--[[ Checks ]]

	-- Client: UFireAll is server only
	if I.Env.IsClient then
		warn(`[{_localName}::{script.Name}]: UFireAll can only be called on the server!`)
		return
	end

	--[[ Getting Remote ]]

	local remote: UnreliableRemoteEvent = Module._getForUse(name, "UnreliableRemoteEvent", "fired")
	if not remote then
		return
	end

	--[[ Firing ]]

	Stats.Record(name, "Out", ...)
	remote:FireAllClients(...)
end

--%%%%%%%%%%%%%%%%%%%% UFired

--[[
	Connects `callback` to execute when an `UnreliableRemoteEvent` with associated `name` is fired.
]]
--- @param callback function
--- @return RBXScriptConnection?
function Module.UFired(name: string, callback)
	--[[ Getting Remote ]]

	local remote: UnreliableRemoteEvent = Module._getForUse(name, "UnreliableRemoteEvent", "listened to")
	if not remote then
		return nil
	end

	--[[ Checks ]]

	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) for UnreliableRemoteEvent ({name})! Expected (function), got ({callback}: {typeof(callback)}).`)
		return nil
	end

	--[[ Connecting ]]

	local function onFire(...: any)
		-- Drop calls that fail the inbound checks
		if not Inbound.Accept("UnreliableRemoteEvent", name, ...) then
			return
		end

		callback(...)
	end

	if I.Env.IsServer then
		return remote.OnServerEvent:Connect(onFire)
	end

	return remote.OnClientEvent:Connect(onFire)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remote Function

--%%%%%%%%%%%%%%%%%%%% Invoke

--[[
	Invokes a `RemoteFunction`. On the server the call gives up after `INVOKE_CLIENT_TIMEOUT` seconds.
]]
--- @return any | nil
function Module.Invoke(name: string, optionalPlayer: any, ...: any)
	--[[ Getting Remote ]]

	local remote: RemoteFunction = Module._getForUse(name, "RemoteFunction", "invoked")
	if not remote then
		return nil
	end

	--[[ Checks ]]

	-- Server: Player is invalid
	if I.Env.IsServer and (not optionalPlayer or not I.Player.Valid(optionalPlayer)) then
		warn(`[{_localName}::{script.Name}]: ({optionalPlayer}) is not a valid Player!`)
		return nil
	end

	--[[ Server ]]

	Stats.Record(name, "Out", optionalPlayer, ...)

	if I.Env.IsServer then
		return Module._invokeClient(remote, name, optionalPlayer, ...)
	end

	--[[ Client ]]

	local success: boolean
	local result: any | string?
	if optionalPlayer == nil and select("#", ...) == 0 then
		success, result = pcall(function()
			return table.pack(remote:InvokeServer())
		end)
	else
		local packedArgs = table.pack(optionalPlayer, ...) --- @type { any }
		success, result = pcall(function()
			return table.pack(remote:InvokeServer(table.unpack(packedArgs, 1, packedArgs.n)))
		end)
	end

	-- Check if the server answered
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to invoke RemoteFunction ({name}) on server! - ({result})`)
		return nil
	end

	--[[ Returning ]]

	return table.unpack(result, 1, result.n)
end

--%%%%%%%%%%%%%%%%%%%% Invoke Client

--[[
	Invokes a client and resumes with its answer, or with nothing once `INVOKE_CLIENT_TIMEOUT` passes.
]]
--- @return any | nil
function Module._invokeClient(remote: RemoteFunction, name: string, player: Player, ...: any)
	--[[ Local Variables ]]

	local packedArgs = table.pack(...) --- @type { any }
	local callerThread: thread = coroutine.running()
	local finished: boolean = false

	--[[ Invoking ]]

	task.spawn(function()
		--- @type { any }
		local results = table.pack(pcall(function()
			return remote:InvokeClient(player, table.unpack(packedArgs, 1, packedArgs.n))
		end))

		-- Skip the answer when the call already timed out
		if finished then
			return
		end

		finished = true
		task.defer(callerThread, results)
	end)

	--[[ Timeout ]]

	task.delay(_settings.INVOKE_CLIENT_TIMEOUT, function()
		-- Skip the timeout when the client already answered
		if finished then
			return
		end

		finished = true
		task.defer(callerThread, nil)
	end)

	--[[ Waiting ]]

	--- @type { any }?
	local results = coroutine.yield()

	-- Check if the client answered in time
	if not results then
		warn(`[{_localName}::{script.Name}]: RemoteFunction ({name}) timed out on client ({player}) after {_settings.INVOKE_CLIENT_TIMEOUT}s!`)
		return nil
	end

	-- Check if the invoke succeeded
	if not results[1] then
		warn(`[{_localName}::{script.Name}]: Failed to invoke RemoteFunction ({name}) on client ({player})! - ({results[2]})`)
		return nil
	end

	--[[ Returning ]]

	return table.unpack(results, 2, results.n)
end

--%%%%%%%%%%%%%%%%%%%% On Invoke

--[[
	Connects `callback` to execute when a `RemoteFunction`	is invoked.
]]
function Module.OnInvoke(name: string, callback)
	--[[ Getting Remote ]]

	local remote: RemoteFunction = Module._getForUse(name, "RemoteFunction", "listened to")
	if not remote then
		return
	end

	--[[ Checks ]]

	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) for RemoteFunction ({name})! Expected (function), got ({callback}: {typeof(callback)}).`)
		return
	end

	--[[ Connecting ]]

	--- @return any | nil
	local function onInvoke(...: any)
		-- Drop calls that fail the inbound checks
		if not Inbound.Accept("RemoteFunction", name, ...) then
			return nil
		end

		return callback(...)
	end

	if I.Env.IsServer then
		remote.OnServerInvoke = onInvoke
	end

	if I.Env.IsClient then
		remote.OnClientInvoke = onInvoke
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Event

--[[
	Creates or returns existing `RemoteEvent`.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @param options Network_RemoteOptions?
--- @return RemoteEvent
function Module.GetEvent(name: string, argTypes, options)
	return Module._get(name, "RemoteEvent", argTypes, options)
end

--%%%%%%%%%%%%%%%%%%%% Get UEvent

--[[
	Creates or returns existing `UnreliableRemoteEvent`.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @param options Network_RemoteOptions?
--- @return UnreliableRemoteEvent
function Module.GetUEvent(name: string, argTypes, options)
	return Module._get(name, "UnreliableRemoteEvent", argTypes, options)
end

--%%%%%%%%%%%%%%%%%%%% Get Function

--[[
	Creates or returns existing `RemoteFunction`.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @param options Network_RemoteOptions?
--- @return RemoteFunction
function Module.GetFunction(name: string, argTypes, options)
	return Module._get(name, "RemoteFunction", argTypes, options)
end

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Owner path of `Get*`: stores the schema and options on the first call, warns when a later call passes new ones.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @param options Network_RemoteOptions?
--- @return RemoteEvent | UnreliableRemoteEvent | RemoteFunction | nil
function Module._get(name: string, remoteType: string, argTypes, options)
	--[[ Checks ]]

	-- Warn when a schema or options arrive after the owner already created the remote
	if ownedRemotes[name] then
		if (argTypes and remoteArgTypes[name] ~= argTypes) or (options and remoteOptions[name] ~= options) then
			warn(`[{_localName}::{script.Name}]: {remoteType} ({name}) was already created - its argument types and options won't be updated!`)
		end

		return Module._getRemote(name, remoteType)
	end

	--[[ Returning ]]

	return Module._initialGet(name, remoteType, argTypes, options)
end

--%%%%%%%%%%%%%%%%%%%% Get For Use

--[[
	Send and listen path: returns the remote without storing a schema, and warns in Studio when the server uses one no `Get*` created yet.
]]
--- @return RemoteEvent | UnreliableRemoteEvent | RemoteFunction | nil
function Module._getForUse(name: string, remoteType: string, usage: string)
	--[[ Checks ]]

	-- Studio: Warn when the server uses a remote before its owner created it
	if I.Env.IsServer and I.Env.IsStudio and not ownedRemotes[name] then
		warn(`[{_localName}::{script.Name}]: {remoteType} ({name}) was {usage} before any module created it with Get*!`)
	end

	--[[ Returning ]]

	return Module._getRemote(name, remoteType)
end

--%%%%%%%%%%%%%%%%%%%% Initial Get

--[[
	Creates or returns existing remote and validates argument types and options.
]]
--- @param argTypes Validate_ArgumentSchema?
--- @param options Network_RemoteOptions?
--- @return RemoteEvent | UnreliableRemoteEvent | RemoteFunction | nil
function Module._initialGet(name: string, remoteType: string, argTypes, options)
	--[[ Checks ]]

	if type(name) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (name) type! Expected (string), got ({name}: {typeof(name)}).`)
		return nil
	end

	if argTypes and type(argTypes) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (argTypes) type! Expected (table), got ({argTypes}: {typeof(argTypes)}).`)
		return nil
	end

	-- Check if the options are valid
	if options and not Module._areOptionsValid(name, options) then
		return nil
	end

	--[[ Validating Argument Types ]]

	if argTypes then
		local success: boolean, result: string = I.Validate.Types(argTypes)
		if not success then
			warn(`[{_localName}::{script.Name}]: Passed argument types for RemoteFunction ({name}) are invalid! - ({result})`)
			warn("Types:", argTypes)
			return nil
		end

		--[[ Player Argument ]]

		if I.Env.IsServer then
			-- Checking if Player argument is valid
			local playerArg: string | table = argTypes[1]
			local isPlayerArg = playerArg == "Player"
			local isPlayerInstanceArg = type(playerArg) == "table" and playerArg.Type == "Instance" and playerArg.ClassName == "Player"

			-- Returning if invalid
			if not isPlayerArg and not isPlayerInstanceArg then
				warn(`[{_localName}::{script.Name}]: First argument for a {remoteType} ({name}) on the server must be a Player!`)
				return nil
			end
		end
	end

	--[[ Creating & Saving ]]

	local remote: Instance? = Module._getRemote(name, remoteType)
	if not remote then
		return nil
	end
	remoteArgTypes[name] = argTypes
	remoteSpecs[name] = if argTypes then I.Validate.Compile(argTypes) else nil
	remoteOptions[name] = options
	ownedRemotes[name] = true

	--[[ Returning ]]

	return remote
end

--%%%%%%%%%%%%%%%%%%%% Are Options Valid

--[[
	Checks a remote's options table and warns about the first invalid field.
]]
--- @param options Network_RemoteOptions
--- @return boolean
function Module._areOptionsValid(name: string, options)
	--[[ Checks ]]

	-- Check if the options are a table
	if type(options) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (options) for ({name})! Expected (table), got ({options}: {typeof(options)}).`)
		return false
	end

	-- Check if the rate limit is a positive integer
	if options.RateLimit ~= nil and (type(options.RateLimit) ~= "number" or options.RateLimit < 1 or options.RateLimit % 1 ~= 0) then
		warn(`[{_localName}::{script.Name}]: Invalid (RateLimit) for ({name})! Expected a positive integer, got ({options.RateLimit}).`)
		return false
	end

	-- Check if the period is a positive number
	if options.Per ~= nil and (type(options.Per) ~= "number" or options.Per <= 0) then
		warn(`[{_localName}::{script.Name}]: Invalid (Per) for ({name})! Expected a number greater than 0, got ({options.Per}).`)
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Remote

--[[
	Finds or creates a remote (or creates it when called by server) and returns it.
]]
--- @return RemoteEvent | UnreliableRemoteEvent | RemoteFunction | nil
function Module._getRemote(name: string, remoteType: string)
	--[[ Checks ]]

	if not table.find(_settings.REMOTE_TYPES, remoteType) then
		warn(`[{_localName}::{script.Name}]: ({remoteType}) is not a valid Remote Type!`)
		return nil
	end

	if type(name) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (name) type! Expected (string), got ({name}: {typeof(name)}).`)
		return nil
	end

	--[[ Getting Remote ]]

	-- Getting from table
	local remote: Instance = savedRemotes[name]

	-- Saving to table if missing
	if not remote then
		--[[ Finding Remote ]]

		remote = remotesDir:FindFirstChild(name)
		for _, elem: Instance in ipairs(remotesDir:GetChildren()) do
			if elem:GetAttribute("Network_Name") == name then
				remote = elem
				break
			end
		end

		--[[ Saving it ]]

		if remote then
			savedRemotes[name] = remote
		end
	end

	--[[ Remote Found ]]

	if remote then
		if remote.ClassName == remoteType then
			return remote
		else
			warn(`[{_localName}::{script.Name}]: ({name}) is a ({remote.ClassName}), not a ({remoteType})!`)
			return nil
		end
	end

	--[[ Server: Creating ]]

	if I.Env.IsServer then
		savedRemotes[name] = I.Create(remoteType)({
			Name = _settings.OBFUSCATE and I.Obfuscate.GetRandomString(20) or name,
			Parent = remotesDir,
		}, {
			Network_Name = name,
			Ume_Unprotected = true,
		})

		return savedRemotes[name]
	end

	--[[ Client ]]

	warn(`[{_localName}::{script.Name}]: {remoteType} ({name}) doesn't exist!`)
	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
