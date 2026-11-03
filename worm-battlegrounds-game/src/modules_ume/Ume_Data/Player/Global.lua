--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Player"

--- @type Player_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Functions ]]

--- @type { [number]: { function } }
local playerAddedFunctions = {}
--- @type { [number]: { function } }
local playerRemovingFunctions = {}
--- @type { [number]: { function } }
local characterAddedFunctions = {}
--- @type { [number]: { function } }
local characterRemovingFunctions = {}

--[[ Debug ]]

-- Table containing tracebacks for all registered player events.
local functionsTraceBacks = {}

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

	I.OnStarted(I.Priority.First, Module._sortPlayerEvents)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	--[[ Player ]]

	if I.Env.IsServer then
		I.Topic.Register("_Player_PlayerAdded", { "Player" })
		I.Topic.Subscribe("_Player_PlayerAdded", function(...: Player)
			Module._runPlayerEvents(playerAddedFunctions, ...)
		end)
	end

	--[[ Character ]]

	if I.Env.IsServer then
		I.Topic.Register("_Player_CharacterAdded", { "Player", "Model" })
	else
		I.Topic.Register("_Player_CharacterAdded", { "Model" })
	end
	I.Topic.Subscribe("_Player_CharacterAdded", function(...: Player | Model)
		Module._runPlayerEvents(characterAddedFunctions, ...)
	end)

	if I.Env.IsServer then
		I.Topic.Register("_Player_CharacterRemoving", { "Player", "Model" })
	else
		I.Topic.Register("_Player_CharacterRemoving", { "Model" })
	end
	I.Topic.Subscribe("_Player_CharacterRemoving", function(...: Player | Model)
		Module._runPlayerEvents(characterRemovingFunctions, ...)
	end)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Player = {

		--[[ Register Control ]]

		OnPlayerAdded = Module.RegisterPlayerAddedEvent,
		OnPlayerRemoving = Module.RegisterPlayerRemovingEvent,
		OnCharacterAdded = Module.RegisterCharacterAddedEvent,
		OnCharacterRemoving = Module.RegisterCharacterRemovingEvent,

		--[[ Private ]]

		_runPlayerRemoving = Module._runPlayerRemoving,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run Player Events

--[[
	Runs provided events table for player in a new thread.
]]
function Module._runPlayerEvents(eventsTable: table, ...: Player | Model)
	task.spawn(Module._runEventsNow, eventsTable, ...)
end

--%%%%%%%%%%%%%%%%%%%% Run Player Removing

--[[
	Runs the server's removing callbacks for a player in this thread and returns once they all finished.
]]
function Module._runPlayerRemoving(player: Player, reason: Enum.PlayerExitReason)
	Module._runEventsNow(playerRemovingFunctions, player, reason)
end

--%%%%%%%%%%%%%%%%%%%% Run Events Now

--[[
	Runs every callback of a sorted events table in priority order, each in a `pcall`, and debugs their runtime.
]]
function Module._runEventsNow(eventsTable: table, ...: Player | Model | EnumItem)
	--[[ Local Variables ]]

	local args = table.pack(...) --- @type { any }

	--[[ Running ]]

	--- @param entry Ume_PriorityFunctionEntry
	for _: number, entry in ipairs(eventsTable) do
		--- @param func function
		for _, func in entry.functions do
			--%%%%%%%%%%%%%%%%%%%% Executing Function

			local funcStartTime: number = os.clock()

			local success: boolean
			local result: any | string?
			success, result = pcall(func, table.unpack(args, 1, args.n))
			if not success then
				warn(`[{_localName}::{script.Name}]: {result}`)
				continue
			end

			local funcEndTime: number = os.clock()

			--%%%%%%%%%%%%%%%%%%%% Printing Runtime

			if _settings.DEBUG_FUNCTIONS_RUNTIME and functionsTraceBacks[tostring(func)] then
				local funcRunTime: number = funcEndTime - funcStartTime

				if funcRunTime >= _settings.DEBUG_FUNCTIONS_THRESHOLD then
					print("------------------------------------")
					print(`Time to run - {funcRunTime}`)
					print("------------------------------------")
					print(functionsTraceBacks[tostring(func)])
				end
			end

			if _settings.TASK_WAIT_AFTER_PLAYER_FUNCTION then
				task.wait()
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Register Control

--%%%%%%%%%%%%%%%%%%%% Register Player Event

--[[
	Registers a player-related event callback under provided priority.
]]
--- @param callback function
function Module._registerPlayerEvent(eventsTable: table, priority: number, callback, ignoreExecTime: boolean?)
	--[[ Checks ]]

	-- Invalid priority
	if type(priority) ~= "number" then
		warn(`[{_localName}::{script.Name}]: Invalid (priority) type. Expected (number), got ({priority}: {typeof(priority)})!`)
		return
	end

	-- Invalid callback
	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) type. Expected (function), got ({callback}: {typeof(callback)})!`)
		return
	end

	-- Invalid framework started
	if I.Started then
		warn(`[{_localName}::{script.Name}]: Cannot register ({callback}) function after framework started!`)
		return
	end

	--[[ Initialize Table for Priority ]]

	if not eventsTable[priority] then
		eventsTable[priority] = {}
	end

	--[[ Save Debug Info if Enabled ]]

	if _settings.DEBUG_FUNCTIONS_RUNTIME and not ignoreExecTime then
		functionsTraceBacks[tostring(callback)] = debug.traceback()
	end

	--[[ Register Callback ]]

	table.insert(eventsTable[priority], callback)
end

--%%%%%%%%%%%%%%%%%%%% Event Registry Functions

--[[
	Registers a function to fire when a player joins the game.
]]
--- @param callback function
function Module.RegisterPlayerAddedEvent(priority: number, callback, ignoreExecTime: boolean?)
	--[[ Checks ]]

	-- Warn when a game callback runs after the client was told it loaded
	if type(priority) == "number" and priority <= I.Priority.Last and not ignoreExecTime then
		warn(`[{_localName}::{script.Name}]: OnPlayerAdded priority ({priority}) runs after the client was told it loaded - use a priority above I.Priority.Last!`)
	end

	--[[ Registering ]]

	Module._registerPlayerEvent(playerAddedFunctions, priority, callback, ignoreExecTime)
end

--[[
	Registers a function to fire when a player leaves the game.
]]
--- @param callback function
function Module.RegisterPlayerRemovingEvent(priority: number, callback, ignoreExecTime: boolean?)
	Module._registerPlayerEvent(playerRemovingFunctions, priority, callback, ignoreExecTime)
end

--[[
	Registers a function to fire when a player's character is added.
]]
--- @param callback function
function Module.RegisterCharacterAddedEvent(priority: number, callback, ignoreExecTime: boolean?)
	Module._registerPlayerEvent(characterAddedFunctions, priority, callback, ignoreExecTime)
end

--[[
	Registers a function to fire when a player's character is removed.
]]
--- @param callback function
function Module.RegisterCharacterRemovingEvent(priority: number, callback, ignoreExecTime: boolean?)
	Module._registerPlayerEvent(characterRemovingFunctions, priority, callback, ignoreExecTime)
end

--%%%%%%%%%%%%%%%%%%%% Sort Player Events

--[[
	Sorts all registered priority-based tables by their priority in descending order.
]]
function Module._sortPlayerEvents()
	--[[
		Sorts a priority-based table in descending order.
	]]
	--- @param functionsTable { [number]: { function } }
	--- @return { Ume_PriorityFunctionEntry }
	local function sortTable(functionsTable)
		--- @type { Ume_PriorityFunctionEntry }
		local sortedTable = {}

		--- @param v { function }
		for k: number, v in pairs(functionsTable) do
			table.insert(sortedTable, { key = k, functions = v })
		end

		--- @param a Ume_PriorityFunctionEntry
		--- @param b Ume_PriorityFunctionEntry
		table.sort(sortedTable, function(a, b)
			return a.key > b.key -- Descending order
		end)

		return sortedTable
	end

	--[[ Apply Sorting ]]

	if I.Env.IsServer then
		playerAddedFunctions = sortTable(playerAddedFunctions)
		playerRemovingFunctions = sortTable(playerRemovingFunctions)
	end

	characterAddedFunctions = sortTable(characterAddedFunctions)
	characterRemovingFunctions = sortTable(characterRemovingFunctions)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
