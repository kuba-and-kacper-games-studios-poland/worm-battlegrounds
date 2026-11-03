--[[
    Created By:     loleris (MAD STUDIO)
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type ProfileStore_Shared

-- Shared idle runner thread reused across all Signal instances.
local freeRunnerThread: thread? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Acquire Runner Thread And Call Event Handler

--[[
	Locks current thread and executes given function with additional arguments.
]]
local function acquireRunnerThreadAndCallEventHandler(callback, ...)
	local acquired: thread? = freeRunnerThread
	freeRunnerThread = nil

	callback(...)

	-- Restore the runner thread so it can service the next dispatch.
	freeRunnerThread = acquired
end

--%%%%%%%%%%%%%%%%%%%% Run Event Handler In Free Thread

--[[
	Yields current thread until there is a function to execute.
]]
local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Connection

--- @class ProfileStore_Connection
local _connection = {}
_connection.__index = _connection

--%%%%%%%%%%%%%%%%%%%% Disconnect

--[[
	Unhook connection from the signal. Idempotent - repeated calls are a no-op.
]]
function _connection:Disconnect()
	if self.is_connected == false then
		return
	end

	self.is_connected = false

	local signal = self.signal
	signal.listener_count -= 1

	if signal.head == self then
		signal.head = self.next
	else
		local prev = signal.head
		while prev ~= nil and prev.next ~= self do
			prev = prev.next
		end
		if prev ~= nil then
			prev.next = self.next
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal

--- @class ProfileStore_Signal
local _signal = {
	Init = function(_shared)
		shared = _shared
	end,
}
_signal.__index = _signal

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Returns a new signal metatable.
]]
function _signal.New()
	return setmetatable({
		head = nil,
		listener_count = 0,
	}, _signal)
end

--%%%%%%%%%%%%%%%%%%%% Connect

--[[
	Connects function to execute when the signal is fired.
]]
function _signal:Connect(listener: (...any) -> ())
	if type(listener) ~= "function" then
		error(`[{shared._localName}::{script.Name}]: "listener" must be a function; Received {typeof(listener)}`)
	end

	local connection = setmetatable({
		listener = listener,
		signal = self,
		next = self.head,
		is_connected = true,
	}, _connection)

	self.head = connection
	self.listener_count += 1

	return connection
end

--%%%%%%%%%%%%%%%%%%%% Listener Count

--[[
	Returns the number of connected listeners.
]]
--- @return number
function _signal:GetListenerCount()
	return self.listener_count
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Fires signal with any amount of params. Listeners run on the shared
	runner thread so yielding inside a listener does not block dispatch.
]]
function _signal:Fire(...)
	local item = self.head
	while item ~= nil do
		if item.is_connected == true then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread :: thread, item.listener, ...)
		end
		item = item.next
	end
end

--%%%%%%%%%%%%%%%%%%%% Wait

--[[
	Halts current thread until the signal is fired.
]]
function _signal:Wait()
	local co = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(co, ...)
	end)
	return coroutine.yield()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return table.freeze({
	New = _signal.New,
	Init = _signal.Init,
})
