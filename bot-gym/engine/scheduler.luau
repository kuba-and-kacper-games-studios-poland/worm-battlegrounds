--[[
	Roblox's task scheduler on a virtual clock: `task`, Heartbeat and signals. Time only moves while every thread
	waits, a 60 fps frame at a time, so a 1.5 s wait in the game's code costs no real time. os.clock() reads this
	clock too, so code that measures its own thinking time never yields (it never runs out).
]]

local FRAME: number = 1 / 60

local scheduler = {}
local now: number = 0
local frame: number = 0

-- Threads waiting for a time: { thread, wakeAt, args, order }
local sleeping = {}
local order: number = 0
-- Threads waiting for the next frame (Heartbeat:Wait())
local frameWaiters = {}
local cancelled = setmetatable({}, { __mode = "k" })

--%%%%%%%%%%%%%%%%%%%% Errors

local function report(thread: thread, err: any)
	local trace = debug.traceback(thread, tostring(err))
	print(`[gym] error in a thread: {trace}`)
	scheduler.Errors += 1
	if scheduler.ErrorHandler then
		scheduler.ErrorHandler(trace)
	end
end
scheduler.Errors = 0

local function resume(thread: thread, ...)
	if cancelled[thread] or coroutine.status(thread) ~= "suspended" then
		return
	end
	local ok, err = coroutine.resume(thread, ...)
	if not ok then
		report(thread, err)
	end
end

--%%%%%%%%%%%%%%%%%%%% Signal

local SignalMeta = {}
SignalMeta.__index = SignalMeta
local ConnectionMeta = {}
ConnectionMeta.__index = ConnectionMeta

function ConnectionMeta:Disconnect()
	self.Connected = false
	local list = self._signal._handlers
	local index = table.find(list, self)
	if index then
		table.remove(list, index)
	end
end

function SignalMeta:Connect(handler)
	local connection = setmetatable({ Connected = true, _signal = self, _handler = handler }, ConnectionMeta)
	table.insert(self._handlers, connection)
	return connection
end
SignalMeta.connect = SignalMeta.Connect
function SignalMeta:Once(handler)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		handler(...)
	end)
	return connection
end
function SignalMeta:Wait()
	local thread = coroutine.running()
	table.insert(self._waiters, thread)
	return coroutine.yield()
end
function SignalMeta:Fire(...)
	for _, connection in table.clone(self._handlers) do
		if connection.Connected then
			local thread = coroutine.create(connection._handler)
			resume(thread, ...)
		end
	end
	local waiters = self._waiters
	self._waiters = {}
	for _, thread in waiters do
		resume(thread, ...)
	end
end

function scheduler.NewSignal()
	return setmetatable({ _handlers = {}, _waiters = {} }, SignalMeta)
end

scheduler.Heartbeat = scheduler.NewSignal()
scheduler.Stepped = scheduler.NewSignal()
scheduler.RenderStepped = scheduler.NewSignal()

-- Heartbeat:Wait() waits a frame and returns its length
function scheduler.Heartbeat:Wait()
	table.insert(frameWaiters, coroutine.running())
	coroutine.yield()
	return FRAME
end

--%%%%%%%%%%%%%%%%%%%% Clock

function scheduler.Now(): number
	return now
end

--%%%%%%%%%%%%%%%%%%%% task

local function sleep(thread: thread, seconds: number, ...)
	order += 1
	table.insert(sleeping, { thread, now + seconds, table.pack(...), order })
end

local task = {}

function task.spawn(callback, ...)
	local thread = if type(callback) == "thread" then callback else coroutine.create(callback)
	resume(thread, ...)
	return thread
end
function task.defer(callback, ...)
	local thread = if type(callback) == "thread" then callback else coroutine.create(callback)
	sleep(thread, 0, ...)
	return thread
end
function task.delay(seconds: number?, callback, ...)
	local thread = if type(callback) == "thread" then callback else coroutine.create(callback)
	sleep(thread, seconds or 0, ...)
	return thread
end
function task.wait(seconds: number?): number
	local started = now
	sleep(coroutine.running(), math.max(seconds or 0, FRAME))
	coroutine.yield()
	return now - started
end
function task.cancel(thread: thread)
	cancelled[thread] = true
end
function task.synchronize() end
function task.desynchronize() end
scheduler.task = task

--%%%%%%%%%%%%%%%%%%%% Running

--[[
	Runs a function as the main thread and steps the clock until it returns, frame by frame: each frame wakes the
	threads whose time came, then fires Heartbeat. Returns what the function returned; its error is raised here.
]]
function scheduler.Run(callback, ...)
	local main: thread
	local results = nil
	local failure = nil
	local wrapped = coroutine.create(function(...)
		local packed = table.pack(xpcall(callback, debug.traceback, ...))
		if packed[1] then
			results = packed
		else
			failure = packed[2]
		end
	end)
	main = wrapped
	resume(main, ...)
	while coroutine.status(main) ~= "dead" do
		frame += 1
		now = frame * FRAME

		-- Wake the threads whose time came, in the order they slept
		local due = {}
		local kept = {}
		for _, entry in sleeping do
			if entry[2] <= now + 1e-9 then
				table.insert(due, entry)
			else
				table.insert(kept, entry)
			end
		end
		sleeping = kept
		table.sort(due, function(a, b)
			if a[2] ~= b[2] then
				return a[2] < b[2]
			end
			return a[4] < b[4]
		end)
		for _, entry in due do
			resume(entry[1], table.unpack(entry[3], 1, entry[3].n))
		end

		-- Then the frame's Heartbeat
		local waiters = frameWaiters
		frameWaiters = {}
		for _, thread in waiters do
			resume(thread, FRAME)
		end
		scheduler.Stepped:Fire(now, FRAME)
		scheduler.Heartbeat:Fire(FRAME)

		if #sleeping == 0 and #frameWaiters == 0 and #scheduler.Heartbeat._handlers == 0 and coroutine.status(main) ~= "dead" then
			error("[gym] the main thread waits on something that never comes")
		end
	end
	if failure ~= nil then
		error(failure, 0)
	end
	return table.unpack(results, 2, results.n)
end

--[[
	Forgets every waiting thread and handler (between matches, so a map's loops don't pile up).
]]
function scheduler.Reset()
	sleeping = {}
	frameWaiters = {}
	scheduler.Heartbeat._handlers = {}
	scheduler.Heartbeat._waiters = {}
end

return scheduler
