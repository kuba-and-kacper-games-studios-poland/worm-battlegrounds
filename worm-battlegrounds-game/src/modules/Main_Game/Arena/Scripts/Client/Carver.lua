--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Cutter = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Cutter")) --- @type Arena_Cutter

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local arenaFolder: Instance
local piecesFolder: Folder
local predicting: boolean = false

-- Re-cuts of the server's pieces still running: while any is, the pieces they replace stay up, so nothing flickers
local recarving: number = 0

local pending = {} --- @type { Arena_PendingCarve }
local predicted = {} --- @type { [BasePart]: Arena_Prediction }
local stale = {} --- @type { BasePart }

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

--- @class Arena_Client_Carver
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Instance)
	--[[ Local Variables ]]

	arenaFolder = folder
	piecesFolder = I.Create("Folder")({
		Name = "Predicted",
		Parent = arenaFolder,
	})

	--[[ Connections ]]

	I.Network.Fired("Arena_Carve", Module._onCarve)
	arenaFolder.DescendantAdded:Connect(Module._onAdded)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Carve

--[[
	Cuts a blast's hole on this screen the moment the server announces it, and remembers it until the server's own
	pieces show it was cut there too.
]]
function Module._onCarve(carveId: number, center: Vector3, radius: number)
	--[[ Saving ]]

	local carve = { Id = carveId, Center = center, Radius = radius } --- @type Arena_PendingCarve
	table.insert(pending, carve)
	task.delay(_settings.PREDICT_TIMEOUT, Module._forget, carveId)

	--[[ Carving ]]

	Module._predict(Module._getHits(carve), carve)
end

--%%%%%%%%%%%%%%%%%%%% On Added

--[[
	A piece the server cut: every carve up to its own is in it, so those stop waiting, and the carves this screen cut
	after it are cut into it again at once (hidden until then), so the holes they made stay open.
]]
function Module._onAdded(descendant: Instance)
	--[[ Checks ]]

	-- Check if this is one of the server's carved pieces
	local carveId: number? = descendant:GetAttribute("Arena_Carve")
	if not carveId or not descendant:IsA("BasePart") then
		return
	end

	--[[ Confirming ]]

	for index: number = #pending, 1, -1 do
		if pending[index].Id <= carveId then
			table.remove(pending, index)
		end
	end

	--[[ Recarving ]]

	local later = {} --- @type { Arena_PendingCarve }
	--- @param carve Arena_PendingCarve
	for _index: number, carve in ipairs(pending) do
		if Module._isReached(descendant, carve) then
			table.insert(later, carve)
		end
	end
	if #later == 0 then
		return
	end
	descendant.LocalTransparencyModifier = 1
	recarving += 1
	--- @param carve Arena_PendingCarve
	for _index: number, carve in ipairs(later) do
		Module._predict({ descendant }, carve)
	end
	recarving -= 1

	--[[ Clearing ]]

	if recarving == 0 then
		for _index: number, piece: BasePart in ipairs(stale) do
			piece:Destroy()
		end
		table.clear(stale)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Predict

--[[
	Cuts a carve's stepped cutter out of terrain parts on this screen only (yields): each part hides and its local pieces
	show in its place, or the pieces this screen already cut from it are cut again. One prediction runs at a time, in
	the order they were asked for, as the server's carves do.
]]
--- @param parts { BasePart }
--- @param carve Arena_PendingCarve
function Module._predict(parts, carve)
	--[[ Checks ]]

	-- Check if the carve reaches any terrain
	if #parts == 0 then
		return
	end

	--[[ Waiting ]]

	while predicting do
		task.wait()
	end
	predicting = true

	--[[ Local Variables ]]

	local bounds: BasePart = arenaFolder:FindFirstChild("Markers"):FindFirstChild("Bounds")
	local cutter = Cutter.Build(carve.Center, carve.Radius, bounds.Position.Z, bounds.Size.Z + _settings.CARVE_DEPTH_MARGIN, piecesFolder) --- @type { BasePart }
	local results = {} --- @type { [BasePart]: { BasePart } }
	local running: number = 0

	--[[ Carving ]]

	-- Every part (or every piece already cut from it) at the same time
	for _index: number, part: BasePart in ipairs(parts) do
		local targets = if predicted[part] then predicted[part].Pieces else { part } --- @type { BasePart }
		results[part] = {}
		for _targetIndex: number, target: BasePart in ipairs(targets) do
			running += 1
			task.spawn(function()
				local pieces = Cutter.Subtract(target, cutter) or { target:Clone() } --- @type { BasePart }
				table.move(pieces, 1, #pieces, #results[part] + 1, results[part])
				running -= 1
			end)
		end
	end
	while running > 0 do
		task.wait()
	end

	--[[ Swapping ]]

	--- @param pieces { BasePart }
	for part: BasePart, pieces in pairs(results) do
		-- A part the server removed while this was cutting needs nothing
		if not part:IsDescendantOf(arenaFolder) then
			for _index: number, piece: BasePart in ipairs(pieces) do
				piece:Destroy()
			end
			continue
		end

		for _index: number, piece: BasePart in ipairs(pieces) do
			piece:SetAttribute("Arena_Carve", nil)
			piece.CanCollide = false
			piece.CanQuery = false
			piece.CanTouch = false
			piece.LocalTransparencyModifier = 0
			piece.Parent = piecesFolder
		end
		if predicted[part] then
			for _index: number, piece: BasePart in ipairs(predicted[part].Pieces) do
				piece:Destroy()
			end
		else
			part.AncestryChanged:Connect(function()
				if not part:IsDescendantOf(arenaFolder) then
					Module._drop(part)
				end
			end)
		end
		part.LocalTransparencyModifier = 1
		predicted[part] = { Pieces = pieces, CarveId = carve.Id }
		task.delay(_settings.PREDICT_TIMEOUT, Module._undo, part, carve.Id)
	end

	--[[ Cleaning ]]

	for _index: number, box: BasePart in ipairs(cutter) do
		box:Destroy()
	end
	predicting = false
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	Takes away the pieces this screen cut from a part the server removed: its own pieces replace them. While re-cuts run
	they wait, so the server's pieces are cut before these go.
]]
function Module._drop(part: BasePart)
	--[[ Data ]]

	local prediction = predicted[part] --- @type Arena_Prediction?
	if not prediction then
		return
	end

	--[[ Clearing ]]

	predicted[part] = nil
	for _index: number, piece: BasePart in ipairs(prediction.Pieces) do
		if recarving > 0 then
			table.insert(stale, piece)
		else
			piece:Destroy()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Undo

--[[
	Shows a part again, and takes its predicted pieces away, when the server still hasn't replaced it a while after
	its last cut here: the server didn't cut it after all.
]]
function Module._undo(part: BasePart, carveId: number)
	--[[ Checks ]]

	-- Check if the part is still waiting on this carve
	if not predicted[part] or predicted[part].CarveId ~= carveId then
		return
	end

	--[[ Restoring ]]

	part.LocalTransparencyModifier = 0
	for _index: number, piece: BasePart in ipairs(predicted[part].Pieces) do
		piece:Destroy()
	end
	predicted[part] = nil
end

--%%%%%%%%%%%%%%%%%%%% Forget

--[[
	Stops waiting on a carve the server's pieces never confirmed (it cut nothing, or removed whole parts).
]]
function Module._forget(carveId: number)
	for index: number = #pending, 1, -1 do
		if pending[index].Id == carveId then
			table.remove(pending, index)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hits

--[[
	Returns the terrain parts a carve's cutter reaches on this screen, once each; none while no map is loaded.
]]
--- @param carve Arena_PendingCarve
--- @return { BasePart }
function Module._getHits(carve)
	--[[ Data ]]

	local terrain: Instance? = arenaFolder:FindFirstChild("Terrain")
	local markers: Instance? = arenaFolder:FindFirstChild("Markers")
	if not terrain or not markers then
		return {}
	end

	--[[ Local Variables ]]

	local bounds: BasePart = markers:FindFirstChild("Bounds")
	local params: OverlapParams = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { terrain }
	local cutter = Cutter.Build(carve.Center, carve.Radius, bounds.Position.Z, bounds.Size.Z + _settings.CARVE_DEPTH_MARGIN, piecesFolder) --- @type { BasePart }
	local hits = {} --- @type { BasePart }
	local found = {} --- @type { [BasePart]: boolean }

	--[[ Querying ]]

	for _boxIndex: number, box: BasePart in ipairs(cutter) do
		for _hitIndex: number, part: BasePart in ipairs(I.S.Workspace:GetPartsInPart(box, params)) do
			if not found[part] then
				found[part] = true
				table.insert(hits, part)
			end
		end
		box:Destroy()
	end

	--[[ Returning ]]

	return hits
end

--%%%%%%%%%%%%%%%%%%%% Is Reached

--[[
	Returns whether a carve's stepped circle could reach a part, by their boxes on the plane.
]]
--- @param carve Arena_PendingCarve
--- @return boolean
function Module._isReached(part: BasePart, carve)
	--[[ Local Variables ]]

	local reach: number = carve.Radius + _settings.CARVE_CELL
	local half: Vector3 = part.ExtentsSize / 2
	local offset: Vector3 = part.Position - carve.Center

	--[[ Returning ]]

	return math.abs(offset.X) <= half.X + reach and math.abs(offset.Y) <= half.Y + reach
end

return Module
