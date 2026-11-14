--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Arena"

--- @type Arena_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Loader = require(script.Parent:FindFirstChild("Loader")) --- @type Arena_Server_Loader
local Obsidian = require(script.Parent:FindFirstChild("Obsidian")) --- @type Arena_Server_Obsidian

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Grid ]]

local CELL: number = _settings.LIQUID_CELL
local cols: number = 0
local rows: number = 0
local origin: Vector3 = Vector3.zero
local depth: number = 0

-- One byte per cell: solid terrain (1) or not, the liquid kind's id (0 is none), and whether it moved this step
local solid: buffer = buffer.create(0)
local liquid: buffer = buffer.create(0)
local moved: buffer = buffer.create(0)

-- The liquid cells joined to the sea (1), and whether the map holds both water and lava, which react
local sea: buffer = buffer.create(0)
local reactive: boolean = false

-- How many liquid blocks each row holds (row + 1), so empty rows are skipped
local rowCounts = {} --- @type { number }

-- Each kind's spread and pressure, by its id
local spreads = {} --- @type { number }
local pressures = {} --- @type { number }

--[[ Simulation ]]

local awake: boolean = false
local generation: number = 0
local stepCount: number = 0

--[[ Drawing ]]

local liquidFolder: Folder?
local probe: Part?
local changed: boolean = false

-- The liquid of the map's sea, which sudden death raises
local mapKind: string? = nil

-- The sea's surface: the top of the liquid that starts at the map's floor, raised by sudden death; ponds above it are safe
local seaLevel: number = -math.huge
local blockParts = {} --- @type { Part }

-- Each liquid's colour on this map: its marker's Arena_LiquidColor, else LIQUID_COLORS
local colors = {} --- @type { [string]: Color3 }

-- The liquids this map draws in Neon, so they glow: their marker's Arena_LiquidNeon
local neon = {} --- @type { [string]: boolean }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Free

--[[
	Returns whether a cell is inside the grid and holds neither terrain nor liquid; the grid's edges are walls.
]]
--- @return boolean
local function isFree(cx: number, cy: number)
	--[[ Checks ]]

	-- Check if the cell is inside the grid
	if cx < 0 or cx >= cols or cy < 0 or cy >= rows then
		return false
	end

	--[[ Returning ]]

	local index: number = cy * cols + cx
	return buffer.readu8(solid, index) == 0 and buffer.readu8(liquid, index) == 0
end

--%%%%%%%%%%%%%%%%%%%% Is Open

--[[
	Returns whether a cell known to be inside the grid holds neither terrain nor liquid.
]]
--- @return boolean
local function isOpen(index: number)
	return buffer.readu8(solid, index) == 0 and buffer.readu8(liquid, index) == 0
end

--%%%%%%%%%%%%%%%%%%%% Set Liquid

--[[
	Writes a cell's liquid, keeping its row's count and marking the liquid to redraw.
]]
local function setLiquid(index: number, kind: number)
	--[[ Local Variables ]]

	local before: number = buffer.readu8(liquid, index)

	--[[ Saving ]]

	if (before > 0) ~= (kind > 0) then
		rowCounts[index // cols + 1] += if kind > 0 then 1 else -1
	end
	buffer.writeu8(liquid, index, kind)
	changed = true
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

--- @class Arena_Server_Liquid
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Steps the liquid LIQUID_FPS times a second and redraws the rows that changed, until another map loads.
]]
function Module._mainLoop(loopGeneration: number)
	while loopGeneration == generation do
		task.wait(1 / _settings.LIQUID_FPS)
		if loopGeneration ~= generation then
			break
		end
		if awake then
			Module._step()
		end
		Module._render()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Lays a cell grid over the loaded map's bounds, marks the cells terrain fills, and fills the empty cells inside each
	liquid marker with its liquid. It yields every few rows, and stops when another map loads meanwhile. Maps with no
	liquid get the grid too, so sudden death can raise water on them.
]]
function Module.Build()
	--[[ Data ]]

	local bounds: BasePart = Loader.GetBounds()
	local markers = {} --- @type { BasePart }
	for _index: number, marker: Instance in ipairs(Loader.GetMarkers():GetDescendants()) do
		if marker:IsA("BasePart") and marker:GetAttribute("Arena_Liquid") then
			table.insert(markers, marker)
		end
	end

	--[[ Clearing ]]

	generation += 1
	local buildGeneration: number = generation
	cols = 0
	rows = 0
	changed = false
	mapKind = nil
	seaLevel = -math.huge
	blockParts = {}
	reactive = false
	colors = table.clone(_settings.LIQUID_COLORS)
	neon = {}
	for _index: number, marker: BasePart in ipairs(markers) do
		colors[marker:GetAttribute("Arena_Liquid")] = marker:GetAttribute("Arena_LiquidColor") or colors[marker:GetAttribute("Arena_Liquid")]
		neon[marker:GetAttribute("Arena_Liquid")] = marker:GetAttribute("Arena_LiquidNeon") or neon[marker:GetAttribute("Arena_Liquid")]
	end
	awake = false

	--[[ Local Variables ]]

	local bottom: number = bounds.Position.Y - bounds.Size.Y / 2
	local top: number = bounds.Position.Y + bounds.Size.Y / 2
	local ground: NumberRange = Loader.GetGroundDepth()

	-- The sea is the liquid that starts at the map's floor (a pond on the ground above it isn't)
	for _index: number, marker: BasePart in ipairs(markers) do
		if marker.Position.Y - marker.Size.Y / 2 <= bottom + CELL then
			mapKind = marker:GetAttribute("Arena_Liquid")
			seaLevel = math.max(seaLevel, marker.Position.Y + marker.Size.Y / 2)
		end
	end

	cols = math.floor(bounds.Size.X / CELL)
	rows = math.ceil((top - bottom) / CELL)
	-- As deep as the map's ground, so the liquid never juts out in front of it or behind it
	origin = Vector3.new(bounds.Position.X - bounds.Size.X / 2, bottom, (ground.Min + ground.Max) / 2)
	depth = ground.Max - ground.Min
	solid = buffer.create(cols * rows)
	liquid = buffer.create(cols * rows)
	moved = buffer.create(cols * rows)
	sea = buffer.create(cols * rows)
	rowCounts = table.create(rows, 0)
	for id: number, name: string in ipairs(_settings.LIQUID_KINDS) do
		spreads[id] = _settings.LIQUID_SPREAD[name]
		pressures[id] = _settings.LIQUID_PRESSURE[name]
	end

	--[[ Building ]]

	liquidFolder = I.Create("Folder")({
		Name = "Liquid",
		Parent = Loader.GetArenaFolder(),
	})
	probe = I.Create("Part")({
		Name = "LiquidProbe",
		Size = Vector3.new(CELL, CELL, depth) * _settings.LIQUID_PROBE_SCALE,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Parent = Loader.GetArenaFolder(),
	})

	--[[ Filling ]]

	for cy: number = 0, rows - 1 do
		for cx: number = 0, cols - 1 do
			local index: number = cy * cols + cx
			if Module._probeSolid(cx, cy) then
				buffer.writeu8(solid, index, 1)
				continue
			end

			local center: Vector3 = Module._getCellCenter(cx, cy)
			for _index: number, marker: BasePart in ipairs(markers) do
				local inside: Vector3 = marker.CFrame:PointToObjectSpace(center)
				if math.abs(inside.X) <= marker.Size.X / 2 and math.abs(inside.Y) <= marker.Size.Y / 2 then
					setLiquid(index, Module._getKindId(marker:GetAttribute("Arena_Liquid")))
					break
				end
			end
		end

		-- Give the server a frame every few rows; stop if another map loaded meanwhile
		if cy % _settings.LIQUID_BUILD_ROWS_PER_FRAME == 0 then
			task.wait()
			if buildGeneration ~= generation then
				return
			end
		end
	end

	--[[ Starting ]]

	-- Water and lava react where they meet (a lava sea under a water pond, or the other way round)
	local kinds = {} --- @type { [string]: boolean }
	for _index: number, marker: BasePart in ipairs(markers) do
		kinds[marker:GetAttribute("Arena_Liquid")] = true
	end
	reactive = kinds.Water == true and kinds.Lava == true
	Module._markSea()

	awake = true
	task.spawn(Module._mainLoop, generation)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Checks again which cells in a box the terrain fills, after a carve or after debris lands, and wakes the liquid.
	Liquid in a cell that became solid moves up its column to the first free cell.
]]
function Module.Refresh(low: Vector3, high: Vector3)
	--[[ Checks ]]

	-- Check if the map has liquid
	if cols == 0 then
		return
	end

	--[[ Local Variables ]]

	local fromX: number = math.max(math.floor((low.X - origin.X) / CELL), 0)
	local toX: number = math.min(math.floor((high.X - origin.X) / CELL), cols - 1)
	local fromY: number = math.max(math.floor((low.Y - origin.Y) / CELL), 0)
	local toY: number = math.min(math.floor((high.Y - origin.Y) / CELL), rows - 1)

	--[[ Probing ]]

	for cy: number = fromY, toY do
		for cx: number = fromX, toX do
			local index: number = cy * cols + cx
			local isSolid: boolean = Module._probeSolid(cx, cy)
			buffer.writeu8(solid, index, if isSolid then 1 else 0)

			-- Push liquid out of a cell the terrain now fills
			local kind: number = buffer.readu8(liquid, index)
			if isSolid and kind > 0 then
				setLiquid(index, 0)
				for above: number = cy + 1, rows - 1 do
					if isFree(cx, above) then
						setLiquid(above * cols + cx, kind)
						break
					end
				end
			end
		end
	end

	--[[ Saving ]]

	awake = true
end

--%%%%%%%%%%%%%%%%%%%% Raise Liquid

--[[
	Fills the lowest rows that still have room, a row at a time, with the map's liquid (water when it has none), and
	wakes the liquid: sudden death's rising sea.
]]
function Module.RaiseLiquid(rowsToFill: number)
	--[[ Checks ]]

	-- Check if a grid is built
	if cols == 0 then
		return
	end

	--[[ Local Variables ]]

	local kind: number = Module._getKindId(Module.GetLiquidKind() or "Water")
	local filled: number = 0

	--[[ Filling ]]

	for cy: number = 0, rows - 1 do
		local any: boolean = false
		for cx: number = 0, cols - 1 do
			local index: number = cy * cols + cx
			if isOpen(index) then
				setLiquid(index, kind)
				any = true
			end
		end
		if any then
			filled += 1
			seaLevel = math.max(seaLevel, origin.Y + (cy + 1) * CELL)
			if filled >= rowsToFill then
				break
			end
		end
	end

	--[[ Saving ]]

	Module._markSea()
	awake = true
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves every liquid block once, bottom row first: down (up to LIQUID_FALL cells), else diagonally down, else
	sideways toward the nearest drop along its row, up to its kind's spread, so pools level out; then pressure evens
	out connected liquid. Empty rows and blocks buried in liquid or terrain are skipped. Sweeps alternate direction
	each step so the liquid doesn't drift one way. Sleeps once nothing moved.
]]
function Module._step()
	--[[ Local Variables ]]

	local anyMoved: boolean = false
	stepCount += 1
	local flip: boolean = stepCount % 2 == 0
	buffer.fill(moved, 0, 0)

	--[[ Moving ]]

	for cy: number = 0, rows - 1 do
		if rowCounts[cy + 1] == 0 then
			continue
		end

		local rowStart: number = cy * cols
		for i: number = 0, cols - 1 do
			local cx: number = if flip then cols - 1 - i else i
			local index: number = rowStart + cx
			local kind: number = buffer.readu8(liquid, index)
			if kind == 0 or buffer.readu8(moved, index) == 1 then
				continue
			end

			-- Buried: nothing below, beside or diagonally below is free, so it can't move
			if cy > 0 and cx > 0 and cx < cols - 1 and not isOpen(index - cols) and not isOpen(index - 1) and not isOpen(index + 1) and not isOpen(index - cols - 1) and not isOpen(index - cols + 1) then
				continue
			end

			local target: number? = Module._getMove(cx, cy, kind, flip)
			if target then
				setLiquid(index, 0)
				setLiquid(target, kind)
				buffer.writeu8(moved, target, 1)
				anyMoved = true
			end
		end
	end

	--[[ Pressure ]]

	if Module._pressure() then
		anyMoved = true
	end

	--[[ Reacting ]]

	if reactive and Module._react() then
		anyMoved = true
	end
	if stepCount % _settings.SEA_MARK_STEPS == 0 then
		Module._markSea()
	end

	--[[ Saving ]]

	awake = anyMoved
end

--%%%%%%%%%%%%%%%%%%%% React

--[[
	Turns the water lava touches (beside, above or below it) into obsidian: those cells leave the liquid and become
	terrain (Obsidian), which blasts cut like any ground. Returns whether
	any did.
]]
--- @return boolean
function Module._react()
	--[[ Local Variables ]]

	local water: number = Module._getKindId("Water")
	local lava: number = Module._getKindId("Lava")
	local cells = {} --- @type { number }

	--[[ Finding ]]

	for cy: number = 0, rows - 1 do
		if rowCounts[cy + 1] == 0 then
			continue
		end
		for cx: number = 0, cols - 1 do
			local index: number = cy * cols + cx
			if buffer.readu8(liquid, index) ~= water then
				continue
			end
			local below: boolean = cy > 0 and buffer.readu8(liquid, index - cols) == lava
			local above: boolean = cy < rows - 1 and buffer.readu8(liquid, index + cols) == lava
			local left: boolean = cx > 0 and buffer.readu8(liquid, index - 1) == lava
			local right: boolean = cx < cols - 1 and buffer.readu8(liquid, index + 1) == lava
			if below or above or left or right then
				table.insert(cells, index)
			end
		end
	end

	--[[ Checks ]]

	-- Check if lava touched any water
	if #cells == 0 then
		return false
	end

	--[[ Hardening ]]

	for _index: number, index: number in ipairs(cells) do
		setLiquid(index, 0)
		buffer.writeu8(solid, index, 1)
	end

	--[[ Building ]]

	Obsidian.Build(cells, cols, origin, CELL, depth)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Mark Sea

--[[
	Marks which liquid is the sea: the cells of the sea's kind (water on a map whose sudden death raises it) at or
	under its level along the grid's sides and floor, and all of that kind joined to them, so a pond the rising sea
	reaches is the sea's from then on. Water that pooled low in a hole on the land isn't, unless it joins the sea.
]]
function Module._markSea()
	--[[ Local Variables ]]

	local kind: number = Module._getKindId(mapKind or "Water")
	local top: number = math.min(math.floor((seaLevel - origin.Y) / CELL) - 1, rows - 1)
	local stack = {} --- @type { number }
	buffer.fill(sea, 0, 0)

	--[[ Seeding ]]

	for cy: number = 0, top do
		for cx: number = 0, cols - 1 do
			local index: number = cy * cols + cx
			if (cy == 0 or cx == 0 or cx == cols - 1) and buffer.readu8(liquid, index) == kind then
				buffer.writeu8(sea, index, 1)
				table.insert(stack, index)
			end
		end
	end

	--[[ Spreading ]]

	while #stack > 0 do
		local index: number = stack[#stack]
		stack[#stack] = nil
		local cx: number = index % cols
		for _side: number, neighbour: number in ipairs({ index - cols, index + cols, if cx > 0 then index - 1 else -1, if cx < cols - 1 then index + 1 else -1 }) do
			if neighbour >= 0 and neighbour < cols * rows and buffer.readu8(sea, neighbour) == 0 and buffer.readu8(liquid, neighbour) == kind then
				buffer.writeu8(sea, neighbour, 1)
				table.insert(stack, neighbour)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Pressure

--[[
	Evens out each connected body of liquid as if under pressure: up to its kind's pressure of its highest blocks move
	to the lowest free resting cells beside the body that sit below them, nearest the highest block first. Liquid then
	levels through gaps and under debris that dips into it. Returns whether anything moved.
]]
--- @return boolean
function Module._pressure()
	--[[ Local Variables ]]

	-- Runs of one kind in a row; a run joins the body of every run of its kind it touches in the row below
	local runRow = {} --- @type { number }
	local runStart = {} --- @type { number }
	local runEnd = {} --- @type { number }
	local runKind = {} --- @type { number }

	-- Each run's parent run; a body's first run is its own parent
	local parent = {} --- @type { number }

	local belowFirst: number = 1
	local belowLast: number = 0
	local anyMoved: boolean = false

	--[[ Joining ]]

	for cy: number = 0, rows - 1 do
		local rowFirst: number = #runRow + 1
		local start: number = 0
		local kind: number = 0

		-- One past the last column closes the final run
		for cx: number = 0, if rowCounts[cy + 1] > 0 then cols else -1 do
			local cellKind: number = if cx < cols then buffer.readu8(liquid, cy * cols + cx) else 0
			if cellKind == kind then
				continue
			end

			if kind > 0 then
				local run: number = #runRow + 1
				runRow[run] = cy
				runStart[run] = start
				runEnd[run] = cx - 1
				runKind[run] = kind
				parent[run] = run
				for below: number = belowFirst, belowLast do
					if runKind[below] == kind and runStart[below] <= cx - 1 and runEnd[below] >= start then
						parent[Module._getBody(parent, below)] = Module._getBody(parent, run)
					end
				end
			end
			start = cx
			kind = cellKind
		end
		belowFirst = rowFirst
		belowLast = #runRow
	end

	--[[ Highest Blocks ]]

	-- Each body's highest blocks, highest first, up to its kind's pressure
	local tops = {} --- @type { [number]: { number } }
	for run: number = #runRow, 1, -1 do
		local body: number = Module._getBody(parent, run)
		local bodyTops = tops[body] or {} --- @type { number }
		tops[body] = bodyTops
		for cx: number = runEnd[run], runStart[run], -1 do
			if #bodyTops >= pressures[runKind[run]] then
				break
			end
			table.insert(bodyTops, runRow[run] * cols + cx)
		end
	end

	--[[ Free Cells ]]

	-- Each body's free cells that rest on something, beside or above its runs and below its highest block
	local frees = {} --- @type { [number]: { number } }
	local seen = {} --- @type { [number]: boolean }
	for run: number = 1, #runRow do
		local body: number = Module._getBody(parent, run)
		local topRow: number = tops[body][1] // cols
		local cy: number = runRow[run]
		local bodyFrees = frees[body] or {} --- @type { number }
		frees[body] = bodyFrees

		-- Beside the run, on terrain or liquid
		if cy < topRow then
			for _side: number, cx: number in ipairs({ runStart[run] - 1, runEnd[run] + 1 }) do
				if isFree(cx, cy) and not isFree(cx, cy - 1) and not seen[cy * cols + cx] then
					seen[cy * cols + cx] = true
					table.insert(bodyFrees, cy * cols + cx)
				end
			end
		end

		-- On top of the run
		if cy + 1 < topRow then
			for cx: number = runStart[run], runEnd[run] do
				local index: number = (cy + 1) * cols + cx
				if isOpen(index) and not seen[index] then
					seen[index] = true
					table.insert(bodyFrees, index)
				end
			end
		end
	end

	--[[ Moving ]]

	--- @param bodyTops { number }
	for body: number, bodyTops in pairs(tops) do
		local bodyFrees = frees[body] --- @type { number }
		local topX: number = bodyTops[1] % cols
		for _index: number, top: number in ipairs(bodyTops) do
			-- The lowest free cell, nearest the highest block's column
			local best: number = 0
			local bestKey: number = math.huge
			for slot: number, cell: number in ipairs(bodyFrees) do
				local key: number = cell // cols * cols + math.abs(cell % cols - topX)
				if key < bestKey then
					best = slot
					bestKey = key
				end
			end

			-- Stop once no free cell sits below this block
			if best == 0 or bodyFrees[best] // cols >= top // cols then
				break
			end

			local target: number = bodyFrees[best]
			bodyFrees[best] = bodyFrees[#bodyFrees]
			bodyFrees[#bodyFrees] = nil

			-- Another body may have filled it this step
			if isOpen(target) then
				setLiquid(target, buffer.readu8(liquid, top))
				setLiquid(top, 0)
				anyMoved = true
			end
		end
	end

	--[[ Returning ]]

	return anyMoved
end

--%%%%%%%%%%%%%%%%%%%% Render

--[[
	Redraws the liquid as merged stud parts when it changed. A run of one kind in a row merges with the same run in
	the rows above into one rectangle, so still liquid is a few big blocks with no inner faces. The sea is drawn
	SEA_EDGE_WIDTH past the map's sides, up to its level: its blocks at the sides reach out, and a block outside tops it
	up where land stands at a side. A part is written only when its size, place or look differs, so still areas send
	nothing to clients.
]]
function Module._render()
	--[[ Checks ]]

	-- Skip when nothing changed since the last draw
	if not changed then
		return
	end
	changed = false

	--[[ Local Variables ]]

	local rects = {} --- @type { Arena_LiquidRect }

	-- The rectangles the row below left open, by their run's start, end and kind (cols stay under 8192)
	local open = {} --- @type { [number]: Arena_LiquidRect }

	-- The sea standing on the floor in the map's first and last columns, in rows: it reaches past the map's sides
	local leftRun: number = Module._getFloorRun(0)
	local rightRun: number = Module._getFloorRun(cols - 1)

	--[[ Merging ]]

	for cy: number = 0, rows - 1 do
		local stillOpen = {} --- @type { [number]: Arena_LiquidRect }
		local runStart: number = 0
		local runKind: number = 0

		-- One past the last column closes the final run
		for cx: number = 0, if rowCounts[cy + 1] > 0 then cols else -1 do
			local kind: number = if cx < cols then buffer.readu8(liquid, cy * cols + cx) else 0
			if kind == runKind then
				continue
			end

			if runKind > 0 then
				local key: number = (runStart * 8192 + cx) * 16 + runKind
				local rect = open[key] --- @type Arena_LiquidRect?
				if rect then
					rect.Height += 1
				else
					rect = { Start = runStart, Length = cx - runStart, Row = cy, Height = 1, Kind = runKind }
					table.insert(rects, rect)
				end
				stillOpen[key] = rect
			end
			runStart = cx
			runKind = kind
		end
		open = stillOpen
	end

	--[[ Edges ]]

	-- Where land stands on a side of the map under the sea's level, the sea past that side is topped up to its level
	local seaRows: number = math.round((seaLevel - origin.Y) / CELL)
	local edgeCells: number = _settings.SEA_EDGE_WIDTH / CELL
	if seaRows > leftRun then
		table.insert(rects, { Start = -edgeCells, Length = edgeCells, Row = leftRun, Height = seaRows - leftRun, Kind = Module._getKindId(mapKind or "Water") })
	end
	if seaRows > rightRun then
		table.insert(rects, { Start = cols, Length = edgeCells, Row = rightRun, Height = seaRows - rightRun, Kind = Module._getKindId(mapKind or "Water") })
	end

	--[[ Drawing ]]

	--- @param rect Arena_LiquidRect
	for index: number, rect in ipairs(rects) do
		local part: Part = blockParts[index] or Module._createBlock()
		local name: string = _settings.LIQUID_KINDS[rect.Kind]

		-- The sea at the map's sides is drawn SEA_EDGE_WIDTH past them, so the camera never shows where it ends
		local left: number = if rect.Start == 0 and rect.Row + rect.Height <= leftRun then _settings.SEA_EDGE_WIDTH else 0
		local right: number = if rect.Start + rect.Length == cols and rect.Row + rect.Height <= rightRun then _settings.SEA_EDGE_WIDTH else 0
		local size: Vector3 = Vector3.new(rect.Length * CELL + left + right, rect.Height * CELL, depth)
		local cframe: CFrame = CFrame.new(origin + Vector3.new((rect.Start + rect.Length / 2) * CELL + (right - left) / 2, (rect.Row + rect.Height / 2) * CELL, 0))
		blockParts[index] = part
		if part.Size ~= size then
			part.Size = size
		end
		if part.CFrame ~= cframe then
			part.CFrame = cframe
		end
		if part.Color ~= colors[name] then
			part.Color = colors[name]
			part.Transparency = _settings.LIQUID_TRANSPARENCY[name]
			part.Material = if neon[name] then Enum.Material.Neon else Enum.Material.SmoothPlastic
		end

		-- Its kind, for clients' effects (Atmosphere's splashes, bubbles and glints)
		if part:GetAttribute("Arena_Liquid") ~= name then
			part:SetAttribute("Arena_Liquid", name)
		end
		if part.Parent ~= liquidFolder then
			part.Parent = liquidFolder
		end
	end

	--[[ Hiding ]]

	for index: number = #rects + 1, #blockParts do
		if blockParts[index].Parent then
			blockParts[index].Parent = nil
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Block

--[[
	Makes one liquid part in the stud look; its size, place and colour are set when it's drawn.
]]
--- @return Part
function Module._createBlock()
	return I.Create("Part")({
		Name = "Liquid",
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Material = Enum.Material.SmoothPlastic,
		MaterialVariant = _settings.LIQUID_VARIANT,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Liquid

--[[
	**SERVER** |
	Returns the liquid at a position ("Water", "Lava"), or nil when there is none.
]]
--- @return string?
function Module.GetLiquid(position: Vector3)
	--[[ Local Variables ]]

	local cx: number = math.floor((position.X - origin.X) / CELL)
	local cy: number = math.floor((position.Y - origin.Y) / CELL)

	--[[ Checks ]]

	-- Check if the position is inside the grid
	if cx < 0 or cx >= cols or cy < 0 or cy >= rows then
		return nil
	end

	--[[ Returning ]]

	return _settings.LIQUID_KINDS[buffer.readu8(liquid, cy * cols + cx)]
end

--%%%%%%%%%%%%%%%%%%%% Is Sea

--[[
	**SERVER** |
	Returns whether a position is in liquid joined to the sea (a pond the rising sea reached).
]]
--- @return boolean
function Module.IsSea(position: Vector3)
	--[[ Local Variables ]]

	local cx: number = math.floor((position.X - origin.X) / CELL)
	local cy: number = math.floor((position.Y - origin.Y) / CELL)

	--[[ Returning ]]

	return cx >= 0 and cx < cols and cy >= 0 and cy < rows and buffer.readu8(sea, cy * cols + cx) == 1
end

--%%%%%%%%%%%%%%%%%%%% Is Open Sea

--[[
	**SERVER** |
	Returns whether a position is in the open sea: in the sea, no higher than SEA_SLACK over its level, under a surface
	at least SEA_MIN_WIDTH studs across, or under the land's floor. A snail in a small hole the sea seeped into stays in
	play, and one in a crater it flooded as wide as that, or sinking through a hole cut below the land, doesn't.
]]
--- @return boolean
function Module.IsOpenSea(position: Vector3)
	--[[ Checks ]]

	-- Check if it's the sea, at its height
	if position.Y > seaLevel + _settings.SEA_SLACK or not Module.IsSea(position) then
		return false
	end

	-- Check if it's under the land's floor, in the sea the islands stand on (a hole cut through drops a snail in)
	if position.Y < Loader.GetFloor() then
		return true
	end

	--[[ Local Variables ]]

	local cx: number = math.floor((position.X - origin.X) / CELL)
	local surface: number = math.floor((position.Y - origin.Y) / CELL)
	local needed: number = math.ceil(_settings.SEA_MIN_WIDTH / CELL)
	local width: number = 1

	--[[ Surfacing ]]

	-- Up the liquid over it to its surface, where the hole's or the sea's width shows
	while surface + 1 < rows and buffer.readu8(liquid, (surface + 1) * cols + cx) ~= 0 do
		surface += 1
	end
	local row: number = surface * cols

	--[[ Measuring ]]

	-- Free cells to each side of the surface, up to the terrain (the grid's sides open onto the sea beyond)
	for _side: number, direction: number in ipairs({ -1, 1 }) do
		local x: number = cx + direction
		while width < needed and x >= 0 and x < cols and buffer.readu8(solid, row + x) == 0 do
			width += 1
			x += direction
		end
		if x < 0 or x >= cols then
			return true
		end
	end

	--[[ Returning ]]

	return width >= needed
end

--%%%%%%%%%%%%%%%%%%%% Get Sea Level

--[[
	**SERVER** |
	Returns the height of the sea's surface: the liquid that starts at the map's floor, raised by sudden death
	(-math.huge on a map without a sea, until sudden death raises one).
]]
--- @return number
function Module.GetSeaLevel()
	return seaLevel
end

--%%%%%%%%%%%%%%%%%%%% Get Liquid Kind

--[[
	Returns the liquid of the loaded map's sea ("Water" or "Lava"), or nil when it has none.
]]
--- @return string?
function Module.GetLiquidKind()
	return mapKind
end

--%%%%%%%%%%%%%%%%%%%% Get Move

--[[
	Returns the cell a liquid block moves to this step, or nil when it stays.
]]
--- @return number?
function Module._getMove(cx: number, cy: number, kind: number, flip: boolean)
	--[[ Local Variables ]]

	local first: number = if flip then 1 else -1

	--[[ Falling ]]

	-- Straight down, as far as LIQUID_FALL cells in one step
	if isFree(cx, cy - 1) then
		local y: number = cy - 1
		for _cell: number = 2, _settings.LIQUID_FALL do
			if not isFree(cx, y - 1) then
				break
			end
			y -= 1
		end
		return y * cols + cx
	end

	-- Diagonally down, never squeezing between two solid corners
	for pass: number = 1, 2 do
		local side: number = if pass == 1 then first else -first
		if isFree(cx + side, cy - 1) and buffer.readu8(solid, cy * cols + cx + side) == 0 then
			return (cy - 1) * cols + cx + side
		end
	end

	--[[ Spreading ]]

	-- Sideways toward the nearest cell with a drop below it along free cells, at most its kind's spread per step
	local blockedFirst: boolean = false
	local blockedSecond: boolean = false
	for distance: number = 1, cols do
		for pass: number = 1, 2 do
			local direction: number = if pass == 1 then first else -first
			local x: number = cx + direction * distance
			if (pass == 1 and blockedFirst) or (pass == 2 and blockedSecond) then
				continue
			end
			if not isFree(x, cy) then
				if pass == 1 then
					blockedFirst = true
				else
					blockedSecond = true
				end
			elseif isFree(x, cy - 1) then
				return cy * cols + cx + direction * math.min(distance, spreads[kind])
			end
		end
		if blockedFirst and blockedSecond then
			break
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Body

--[[
	Returns the first run of the body a run belongs to, shortening the parent links it walks.
]]
--- @param parent { number }
--- @return number
function Module._getBody(parent, run: number)
	--[[ Walking ]]

	local current: number = run
	while parent[current] ~= current do
		parent[current] = parent[parent[current]]
		current = parent[current]
	end

	--[[ Returning ]]

	return current
end

--%%%%%%%%%%%%%%%%%%%% Get Floor Run

--[[
	Returns how many rows of liquid stand unbroken on the grid's floor in a column: the sea there.
]]
--- @return number
function Module._getFloorRun(cx: number)
	--[[ Counting ]]

	local run: number = 0
	while run < rows and buffer.readu8(liquid, run * cols + cx) > 0 do
		run += 1
	end

	--[[ Returning ]]

	return run
end

--%%%%%%%%%%%%%%%%%%%% Probe Solid

--[[
	Returns whether any terrain part overlaps a cell, by moving the probe part there and asking.
]]
--- @return boolean
function Module._probeSolid(cx: number, cy: number)
	probe.CFrame = CFrame.new(Module._getCellCenter(cx, cy))
	return #I.S.Workspace:GetPartsInPart(probe, Loader.GetTerrainParams()) > 0
end

--%%%%%%%%%%%%%%%%%%%% Get Cell Center

--[[
	Returns the world position of a cell's center.
]]
--- @return Vector3
function Module._getCellCenter(cx: number, cy: number)
	return origin + Vector3.new((cx + 0.5) * CELL, (cy + 0.5) * CELL, 0)
end

--%%%%%%%%%%%%%%%%%%%% Get Kind Id

--[[
	Returns a liquid kind's id in the grid, warning and using the first kind for an unknown name.
]]
--- @return number
function Module._getKindId(kindName: string)
	--[[ Checks ]]

	-- Check if the kind exists
	local id: number? = table.find(_settings.LIQUID_KINDS, kindName)
	if not id then
		warn(`[{_localName}::{script.Name}]: Liquid kind ({kindName}) is unknown - using {_settings.LIQUID_KINDS[1]}.`)
		return 1
	end

	--[[ Returning ]]

	return id
end

return Module
