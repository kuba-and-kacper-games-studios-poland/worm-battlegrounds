--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Cutter = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Cutter")) --- @type Arena_Cutter
local PropCut = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("PropCut")) --- @type Arena_PropCut
local PropBoxes = require(script.Parent:FindFirstChild("PropBoxes")) --- @type Arena_Client_PropBoxes
local Thrown = require(script.Parent:FindFirstChild("Thrown")) --- @type Arena_Client_Thrown

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local arenaFolder: Instance

-- Where this screen's cutter boxes stay between blasts: the terrain carver's folder of local pieces
local cutterFolder: Instance

-- One prop cut at a time, in the order the carves came, as the server's
local predicting: boolean = false

-- What this screen shows of each prop it cut, threw or dropped ahead of the server
local states = {} --- @type { [PVInstance]: Arena_PropState }

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

--- @class Arena_Client_PropCarver
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Instance)
	--[[ Local Variables ]]

	arenaFolder = folder
	cutterFolder = arenaFolder:FindFirstChild("Predicted")

	--[[ Connections ]]

	I.Network.Fired("Arena_Carve", Module._onCarve)
	I.Network.Fired("Arena_PropFall", Module._onFall)
	arenaFolder.DescendantAdded:Connect(Module._onAdded)
	arenaFolder.DescendantRemoving:Connect(Module._onRemoving)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Carve

--[[
	Cuts a blast's hole through the props on this screen the moment the server announces it (Arena_Carve), one carve
	at a time, in their order.
]]
function Module._onCarve(carveId: number, center: Vector3, radius: number)
	--[[ Waiting ]]

	while predicting do
		task.wait()
	end
	predicting = true

	--[[ Carving ]]

	-- Props are only drawn: a cut that fails here gives the props back to the server's parts instead of blocking the next
	local success: boolean
	local result: any | string?
	success, result = pcall(Module._predict, carveId, center, radius)
	if not success then
		warn(`[{_localName}::{script.Name}]: Could not cut the props! - ({result})`)
		--- @param state Arena_PropState
		for prop: PVInstance, state in pairs(states) do
			if state.Busy then
				state.Busy = false
				Module._restore(prop, state)
			end
		end
	end

	--[[ Saving ]]

	predicting = false
end

--%%%%%%%%%%%%%%%%%%%% On Fall

--[[
	A prop whose ground is gone (Arena_PropFall): what this screen shows of it falls straight down with the ground
	under it, lies there and fades.
]]
function Module._onFall(prop: PVInstance?, drop: number, started: number)
	--[[ Checks ]]

	-- Check if this screen has the prop (streaming may leave it out)
	if not prop then
		return
	end

	--[[ Data ]]

	--- @type Arena_PropState
	local state = Module._getState(prop)

	--[[ Waiting ]]

	-- A cut of it running now finishes first
	while state.Busy do
		task.wait()
	end

	--[[ Dropping ]]

	local parts = Module._getShown(prop) --- @type { BasePart }
	local owned = {} --- @type { [BasePart]: boolean }

	for _index: number, part: BasePart in ipairs(parts) do
		if state.Pieces[part] then
			state.Pieces[part] = nil
			owned[part] = true
		end
	end
	state.Gone = true
	PropBoxes.Forget(prop)
	Thrown.Drop(parts, owned, drop, started)
end

--%%%%%%%%%%%%%%%%%%%% On Added

--[[
	A server piece turning up in a prop this screen is ahead of (it cut a later carve there) stays hidden until the
	server's result catches up.
]]
function Module._onAdded(item: Instance)
	--[[ Checks ]]

	-- Check if this is a part
	if not item:IsA("BasePart") then
		return
	end

	--[[ Data ]]

	local prop: PVInstance? = PropBoxes.GetProp(item)
	local state = if prop then states[prop] else nil --- @type Arena_PropState?

	--[[ Checks ]]

	-- Check if this screen shows its own cut of a standing prop and the part isn't one of its pieces
	if not state or state.Gone or state.Pieces[item] then
		return
	end

	--[[ Hiding ]]

	item.LocalTransparencyModifier = 1
	state.Hidden[item] = true
end

--%%%%%%%%%%%%%%%%%%%% On Removing

--[[
	A prop the server removed takes what this screen showed of it along.
]]
function Module._onRemoving(item: Instance)
	--[[ Data ]]

	local state = states[item] --- @type Arena_PropState?
	if not state then
		return
	end

	--[[ Clearing ]]

	if state.Connection then
		state.Connection:Disconnect()
	end
	states[item] = nil
end

--%%%%%%%%%%%%%%%%%%%% On Server Cut

--[[
	The server's own cut of a prop is in (its `Arena_Carve`): once it's at least as new as what this screen cut there,
	this screen's pieces give way to the server's.
]]
function Module._onServerCut(prop: Model)
	--[[ Data ]]

	local state = states[prop] --- @type Arena_PropState?
	local carveId: number? = prop:GetAttribute("Arena_Carve")

	--[[ Checks ]]

	-- Check if the server's cut is at least as new as this screen's
	if not state or state.Gone or not carveId or carveId < state.Carve then
		return
	end

	--[[ Waiting ]]

	-- A cut of it running now finishes first, then gives way
	while state.Busy do
		task.wait()
	end

	--[[ Checks ]]

	-- Check if nothing newer came meanwhile
	if states[prop] ~= state or state.Gone or carveId < state.Carve then
		return
	end

	--[[ Restoring ]]

	Module._restore(prop, state)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Predict

--[[
	Cuts a carve's stepped cutter (the server's prop cutter) through every prop it reaches on this screen (yields),
	all their parts at once: each cut part hides and its pieces still joined to the prop's base show in its place, and
	what the cut frees flies off at once (Thrown). A one-part prop it reaches flies off whole.
]]
function Module._predict(carveId: number, center: Vector3, radius: number)
	--[[ Finding ]]

	local reached = {} --- @type { PVInstance }
	local span: NumberRange? = nil
	--- @param box Arena_PropBox
	for prop: PVInstance, box in pairs(PropBoxes.Get()) do
		local state = states[prop] --- @type Arena_PropState?
		if (state and state.Gone) or PropCut.GetGap(box.CFrame.Position, box.Size, center) > radius then
			continue
		end
		table.insert(reached, prop)
		if prop:IsA("Model") then
			span = PropCut.GetSpan(box.CFrame, box.Size, span)
		end
	end

	--[[ Checks ]]

	-- Check if the blast reaches a prop
	if #reached == 0 then
		return
	end

	--[[ Marking ]]

	-- Each one waits on this carve now: a cut of the server's for an earlier carve leaves this screen's in place
	local marked = {} --- @type { [PVInstance]: Arena_PropState }
	for _index: number, prop: PVInstance in ipairs(reached) do
		marked[prop] = Module._getState(prop)
		marked[prop].Carve = carveId
		marked[prop].Busy = true
	end

	--[[ Cutting ]]

	local shown = {} --- @type { [PVInstance]: { BasePart } }
	local results = {} --- @type { [BasePart]: { BasePart } }
	if span then
		local boxes = Cutter.Build(center, radius, (span.Min + span.Max) / 2, span.Max - span.Min + _settings.CARVE_DEPTH_MARGIN, cutterFolder) --- @type { BasePart }
		local cutter = Cutter.Merge(boxes) --- @type { BasePart }
		local running: number = 0

		for _index: number, prop: PVInstance in ipairs(reached) do
			if not prop:IsA("Model") then
				continue
			end
			shown[prop] = Module._getShown(prop)
			for _partIndex: number, part: BasePart in ipairs(shown[prop]) do
				-- Skip parts the blast doesn't reach; a part wholly inside it is gone
				if not PropCut.IsReached(part, center, radius) then
					continue
				end
				if PropCut.IsInside(part, center, radius) then
					results[part] = {}
					continue
				end

				running += 1
				task.spawn(function()
					local pieces = Cutter.Subtract(part, cutter, true) --- @type { BasePart }?
					for _pieceIndex: number, piece: BasePart in ipairs(pieces or {}) do
						piece.Anchored = true
						piece.CanCollide = false
						piece.CanQuery = false
						piece.CanTouch = false
						piece.LocalTransparencyModifier = 0
					end
					results[part] = pieces
					running -= 1
				end)
			end
		end
		while running > 0 do
			task.wait()
		end
		Cutter.Release(boxes, cutter)
	end

	--[[ Applying ]]

	for _index: number, prop: PVInstance in ipairs(reached) do
		local state = marked[prop] --- @type Arena_PropState
		if prop:IsA("BasePart") then
			state.Gone = true
			PropBoxes.Forget(prop)
			Thrown.Throw({ prop }, {}, PropCut.GetPush(prop.Position, center))
		else
			Module._apply(prop, state, shown[prop], results, center)
		end
		state.Busy = false
		task.delay(_settings.PREDICT_TIMEOUT, Module._undo, prop, carveId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Puts one prop's cut in place on this screen: the pieces still joined to its base (PropCut's Split, at its
	`Arena_PropBase`) show where their parts were, those parts hide (or go, when they were this screen's own pieces),
	and each group the cut frees flies off away from the blast. A prop the server removed meanwhile keeps nothing, but
	what it freed still flies.
]]
--- @param state Arena_PropState
--- @param shownParts { BasePart }
--- @param results { [BasePart]: { BasePart } }
function Module._apply(prop: Model, state, shownParts, results, center: Vector3)
	--[[ Data ]]

	local base: number? = prop:GetAttribute("Arena_PropBase")

	--[[ Local Variables ]]

	local alive: boolean = prop:IsDescendantOf(arenaFolder)
	local parts = {} --- @type { BasePart }
	local cut = {} --- @type { BasePart }
	local homes = {} --- @type { [BasePart]: Instance }
	for _index: number, part: BasePart in ipairs(shownParts) do
		local pieces = results[part] --- @type { BasePart }?
		if not pieces then
			table.insert(parts, part)
			continue
		end
		table.insert(cut, part)
		for _pieceIndex: number, piece: BasePart in ipairs(pieces) do
			homes[piece] = part.Parent
			table.insert(parts, piece)
		end
	end

	--[[ Splitting ]]

	local kept = parts --- @type { BasePart }
	local thrown = {} --- @type { { BasePart } }
	if base then
		kept, thrown = PropCut.Split(parts, base)
	end

	--[[ Swapping ]]

	-- What still stands shows in place of the parts it was cut from
	for _index: number, piece: BasePart in ipairs(kept) do
		local home: Instance? = homes[piece]
		if home and alive and home:IsDescendantOf(arenaFolder) then
			state.Pieces[piece] = true
			piece.Parent = home
		elseif home then
			piece:Destroy()
		end
	end
	for _index: number, part: BasePart in ipairs(cut) do
		if state.Pieces[part] then
			state.Pieces[part] = nil
			part:Destroy()
		else
			state.Hidden[part] = true
			part.LocalTransparencyModifier = 1
		end
	end

	--[[ Throwing ]]

	--- @param members { BasePart }
	for _index: number, members in ipairs(thrown) do
		local owned = {} --- @type { [BasePart]: boolean }
		local middle: Vector3 = Vector3.zero
		for _memberIndex: number, member: BasePart in ipairs(members) do
			middle += member.Position
			if homes[member] then
				owned[member] = true
			elseif state.Pieces[member] then
				state.Pieces[member] = nil
				owned[member] = true
			end
		end
		Thrown.Throw(members, owned, PropCut.GetPush(middle / #members, center))
	end
end

--%%%%%%%%%%%%%%%%%%%% Restore

--[[
	Gives a prop back to the server's parts on this screen: its own pieces go and the parts it hid show again.
]]
--- @param state Arena_PropState
function Module._restore(prop: PVInstance, state)
	--[[ Clearing ]]

	for piece: BasePart in pairs(state.Pieces) do
		piece:Destroy()
	end
	for part: BasePart in pairs(state.Hidden) do
		part.LocalTransparencyModifier = 0
	end
	if state.Connection then
		state.Connection:Disconnect()
	end
	states[prop] = nil
end

--%%%%%%%%%%%%%%%%%%%% Undo

--[[
	Gives a prop back to the server's parts when the server still hasn't cut it a while after this screen's last cut
	there (PREDICT_TIMEOUT): the server didn't cut it after all.
]]
function Module._undo(prop: PVInstance, carveId: number)
	--[[ Data ]]

	local state = states[prop] --- @type Arena_PropState?

	--[[ Checks ]]

	-- Check if the prop still waits on this carve
	if not state or state.Gone or state.Busy or state.Carve ~= carveId then
		return
	end

	--[[ Restoring ]]

	Module._restore(prop, state)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get State

--[[
	Returns what this screen shows of a prop, made when it has none yet; a Model's hears the server's cuts of it.
]]
--- @return Arena_PropState
function Module._getState(prop: PVInstance)
	--[[ Data ]]

	local state = states[prop] --- @type Arena_PropState?
	if state then
		return state
	end

	--[[ Building ]]

	--- @type Arena_PropState
	local made = {
		Carve = 0,
		Pieces = {},
		Hidden = {},
		Busy = false,
		Gone = false,
		Connection = nil,
	}
	if prop:IsA("Model") then
		made.Connection = prop:GetAttributeChangedSignal("Arena_Carve"):Connect(function()
			Module._onServerCut(prop)
		end)
	end
	states[prop] = made

	--[[ Returning ]]

	return made
end

--%%%%%%%%%%%%%%%%%%%% Get Shown

--[[
	Returns the parts of a prop this screen shows: the server's it hasn't hidden and its own pieces, without the parts
	it's throwing.
]]
--- @return { BasePart }
function Module._getShown(prop: PVInstance)
	--[[ Checks ]]

	-- A one-part prop is its own part
	if prop:IsA("BasePart") then
		return { prop }
	end

	--[[ Local Variables ]]

	local state = states[prop] --- @type Arena_PropState?
	local shown = {} --- @type { BasePart }

	--[[ Collecting ]]

	for _index: number, part: Instance in ipairs(prop:GetDescendants()) do
		if part:IsA("BasePart") and not (state and state.Hidden[part]) and not Thrown.IsFlying(part) then
			table.insert(shown, part)
		end
	end

	--[[ Returning ]]

	return shown
end

return Module
