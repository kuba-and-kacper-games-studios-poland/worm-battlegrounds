--[[
    Created By:    	stravant
	Edited By:    	Nari
]]

local _localName = "GoodSignal"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The currently idle thread to run the next handler on
local freeRunnerThread: thread? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--[[
	Locks current thread and executes given function with additional arguments.
]]
local function acquireRunnerThreadAndCallEventHandler(callback, ...)
	local acquiredRunnerThread: thread? = freeRunnerThread
	freeRunnerThread = nil

	callback(...)

	freeRunnerThread = acquiredRunnerThread
end

--[[
	Yields current thread until there is a function to execute.
]]
local function runEventHandlerInFreeThread()
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Connections

--- @type Signal_Connection
local Connection = {}
Connection.__index = Connection

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Returns a new connection metatable.
]]
--- @param signal Signal
--- @return Signal_Connection
function Connection.new(signal, callback: (...any) -> ())
	return setmetatable({
		_connected = true,
		_signal = signal,
		_fn = callback,
		_next = false,
	}, Connection)
end

--%%%%%%%%%%%%%%%%%%%% Disconnect

--[[
	Unhook connection from the signal. Idempotent - repeated calls are a no-op.
]]
function Connection:Disconnect()
	-- Return early if the connection is already disconnected
	if not self._connected then
		return
	end

	-- Mark the connection as disconnected
	self._connected = false

	-- Remove the connection from the signal's handler list
	local signal = self._signal
	if signal._handlerListHead == self then
		signal._handlerListHead = self._next
	else
		--- @type Signal_Connection
		local prev = signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal

--- @type Signal
local Signal = {}
Signal.__index = Signal

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Signal._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Signal = Signal --- @type Signal
end

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Returns a new signal metatable.
]]
--- @return Signal
function Signal.new()
	return setmetatable({
		_handlerListHead = false,
	}, Signal)
end

--%%%%%%%%%%%%%%%%%%%% Connect

--[[
	Connects function to execute when the signal is fired.
]]
--- @return Signal_Connection
function Signal:Connect(callback: (...any) -> ())
	-- Validate the callback is a function
	if type(callback) ~= "function" then
		warn(`[{_localName}]: Invalid (callback) type. Expected (function), got ({callback}: {typeof(callback)})!`)
		return nil
	end

	--[[ Creating Connection ]]

	--- @type Signal_Connection
	local connection = Connection.new(self, callback)
	connection._next = self._handlerListHead
	self._handlerListHead = connection
	return connection
end

--%%%%%%%%%%%%%%%%%%%% Disconnect All

--[[
	Disconnects all connections from signal.
]]
function Signal:DisconnectAll()
	--[[
		Mark every live connection as disconnected so any in-flight Fire loop
		stops dispatching, and a stale reference to Disconnect becomes a no-op.
	]]
	--- @type Signal_Connection
	local connection = self._handlerListHead
	while connection do
		connection._connected = false
		connection = connection._next
	end
	self._handlerListHead = false
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Fires signal with any amount of params.
]]
function Signal:Fire(...: any)
	--[[ Checking for Connections ]]

	local connection --- @type Signal_Connection
	connection = self._handlerListHead
	if not connection then
		return
	end

	--[[ Ensuring Runner Thread ]]

	-- Ensure we have a runner thread ready before entering the dispatch loop,
	-- so we don't re-check on every iteration.
	if not freeRunnerThread then
		freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
		coroutine.resume(freeRunnerThread :: thread)
	end

	--[[ Dispatching Connections ]]

	while connection do
		-- Cache _next before dispatch; a handler may disconnect itself
		-- (mutating the list) before we read _next otherwise.
		local nextConnection = connection._next --- @type Signal_Connection | boolean
		if connection._connected then
			task.spawn(freeRunnerThread :: thread, connection._fn, ...)
			-- A re-entrant Fire may have consumed our runner; make sure the
			-- next iteration has one available without re-checking per-item.
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
				coroutine.resume(freeRunnerThread :: thread)
			end
		end
		connection = nextConnection
	end
end

--%%%%%%%%%%%%%%%%%%%% Wait

--[[
	Halts current thread until the signal is fired.
]]
function Signal:Wait()
	local waitingCoroutine: thread = coroutine.running()
	local connection --- @type Signal_Connection
	connection = self:Connect(function(...)
		if connection._connected then
			connection:Disconnect()
		end
		task.spawn(waitingCoroutine :: thread, ...)
	end)
	return coroutine.yield()
end

--%%%%%%%%%%%%%%%%%%%% Once

--[[
	Fires given function once and disconnects it.
]]
--- @return Signal_Connection
function Signal:Once(callback: (...any) -> ())
	local cn --- @type Signal_Connection
	cn = self:Connect(function(...)
		if cn._connected then
			cn:Disconnect()
		end
		callback(...)
	end)
	return cn
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Signal
