--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local LOADED_REMOTE_NAME = "PlayerLoaded"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Sort Priority Table

--[[
	Sorts the given table by priority and returns it.
]]
--- @param t { [number]: { function } }
--- @return { Ume_PriorityFunctionEntry }
local function sortPriorityTable(t)
	--- @type { Ume_PriorityFunctionEntry }
	local sortedTable = {}

	-- Creating sortable table
	--- @param v { function }
	for k: number, v in pairs(t) do -- Using `pairs` because the `t` table does not have proper numeric keys
		table.insert(sortedTable, { key = k, functions = v })
	end

	-- Sorting
	--- @param a Ume_PriorityFunctionEntry
	--- @param b Ume_PriorityFunctionEntry
	table.sort(sortedTable, function(a, b)
		return a.key > b.key -- Descending order
	end)

	return sortedTable
end

--%%%%%%%%%%%%%%%%%%%% Run Priority Table

--[[
	Sorts the given table and runs all functions within it.
]]
--- @param t { [number]: { function } }
local function runPriorityTable(t)
	--- @type { Ume_PriorityFunctionEntry }
	local sortedTable = sortPriorityTable(t)

	--- @param entry Ume_PriorityFunctionEntry
	for _: number, entry in ipairs(sortedTable) do
		--- @param func function
		for _, func in ipairs(entry.functions) do
			-- Executing function
			local success: boolean, errorMessage: string? = pcall(function()
				func()
			end)

			-- Error while executing
			if not success then
				warn(errorMessage)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_FinishedFunctions
local _task = {
	FrameworkStartedFunctions = nil, --- @type { [number]: { function } }
	PlayerLoadedFunctions = nil, --- @type { [number]: { function } }
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Register Control

--%%%%%%%%%%%%%%%%%%%% Create On Started Function

--[[
	Creates and assigns the `OnStarted` function to the Ume framework.
]]
function _task.CreateOnStartedFunction(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	_task.FrameworkStartedFunctions = {}

	--[[
		Shared priorities for `I.OnStarted`, `I.OnLoaded` and the `I.G_Player` events, from 100 down to -100. Higher runs first.
		`First` and `Last` are the framework's own; modules use the bands between them.
	]]
	--- @type Ume_Priority
	I.Priority = table.freeze({

		--[[ Framework ]]

		First = 100,
		Last = -100,

		--[[ Modules ]]

		Data = 90,
		Replicator = 80,
		Setup = 50,
		Default = 0,
		Late = -50,
	})

	--%%%%%%%%%%%%%%%%%%%%

	--[[
		Registers a function to be executed after all modules have loaded.
	]]
	--- @param callback () -> ()
	I.OnStarted = function(priority: number, callback)
		--[[ Checks ]]

		if not callback or type(callback) ~= "function" then
			error(`[Ume::{script.Name}]: Invalid (callback) type! Expected (function), got ({callback}: {typeof(callback)})!`, 2)
		end

		if not priority or not tonumber(priority) then
			error(`[Ume::{script.Name}]: Invalid (priority) type! Expected (number), got ({priority}: {typeof(priority)})!`, 2)
		end

		if not _task.FrameworkStartedFunctions then
			error(`[Ume::{script.Name}]: Cannot register (OnStarted) function after framework started!`, 2)
		end

		--[[ Saving ]]

		if not _task.FrameworkStartedFunctions[priority] then
			_task.FrameworkStartedFunctions[priority] = {}
		end

		table.insert(_task.FrameworkStartedFunctions[priority], callback)
	end
end

--%%%%%%%%%%%%%%%%%%%% Create On Loaded Function

--[[
	**CLIENT** |
	Creates and assigns the `OnLoaded` function to the Ume framework.
]]
function _task.CreateOnLoadedFunction(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsClient then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	_task.PlayerLoadedFunctions = {}

	--%%%%%%%%%%%%%%%%%%%%

	--[[
		**CLIENT** |
		Registers a function to be executed after the player's data has loaded on the server.
	]]
	--- @param callback () -> ()
	I.OnLoaded = function(priority: number, callback)
		--[[ Checks ]]

		if not callback or type(callback) ~= "function" then
			error(`[Ume::{script.Name}]: Invalid (callback) type! Expected (function), got ({callback}: {typeof(callback)})!`, 2)
		end

		if not priority or not tonumber(priority) then
			error(`[Ume::{script.Name}]: Invalid (priority) type! Expected (number), got ({priority}: {typeof(priority)})!`, 2)
		end

		if not _task.PlayerLoadedFunctions then
			error(`[Ume::{script.Name}]: Cannot register (OnLoaded) function after framework started!`, 2)
		end

		--[[ Saving ]]

		if not _task.PlayerLoadedFunctions[priority] then
			_task.PlayerLoadedFunctions[priority] = {}
		end

		table.insert(_task.PlayerLoadedFunctions[priority], callback)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Loaded Control

--%%%%%%%%%%%%%%%%%%%% Create On Loaded Remote

--[[
	**SERVER** |
	Creates a remote event. When fired using `I._informPlayerLoaded`, it notifies the player that their data has been loaded.
]]
function _task.CreateOnLoadedRemote(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	local playerLoadedRemote: RemoteEvent = Instance.new("RemoteEvent")
	playerLoadedRemote.Name = LOADED_REMOTE_NAME
	playerLoadedRemote.Parent = script

	--[[
		**SERVER** | Fires the remote event to inform the player that their data has been loaded on the server,
		so they can begin loading the game.
	]]
	I._informPlayerLoaded = function(player: Player)
		if player and player:IsA("Player") then
			playerLoadedRemote:FireClient(player)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Listen For Player Loaded Remote

--[[
	**CLIENT** |
	Connects a listener that executes all functions registered with `I.OnLoaded` once the player is informed their data has been loaded.
]]
function _task.ListenForPlayerLoadedRemote(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsClient then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Getting Remote Event ]]

	local remote: RemoteEvent = script:FindFirstChild(LOADED_REMOTE_NAME)
	if not remote then
		error(`[Ume::{script.Name}]: (PlayerLoaded) remote event not found!`, 2)
	end

	--[[ Listening for Client Loaded ]]

	remote.OnClientEvent:Once(function()
		_task._runPlayerLoaded()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Run Control

--%%%%%%%%%%%%%%%%%%%% Run Framework Started

--[[
	Executes all functions registered with `I.OnStarted`.
]]
function _task.RunFrameworkStarted()
	if not _task.FrameworkStartedFunctions then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Executing
	runPriorityTable(_task.FrameworkStartedFunctions)

	-- Clearing
	_task.FrameworkStartedFunctions = nil
end

--%%%%%%%%%%%%%%%%%%%% Run Player Loaded

--[[
	**CLIENT** |
	Executes all functions registered with `I.OnLoaded`.
]]
function _task._runPlayerLoaded()
	if not _task.PlayerLoadedFunctions then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Executing
	runPriorityTable(_task.PlayerLoadedFunctions)

	-- Clearing
	_task.PlayerLoadedFunctions = nil
end

return _task
