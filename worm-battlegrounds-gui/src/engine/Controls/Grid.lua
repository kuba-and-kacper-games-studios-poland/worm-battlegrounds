--[[
	Created By: 	Nari
]]

local _localName: string = "Grid"

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

--- @class UmeGui_Controls_Grid
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Columns = "number?",
		MinCellWidth = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local gap: number = ctx.Number("Spacing", style.Gap)
	local fixedColumns: number = math.max(1, math.floor(node.Columns or 2))
	local minCellWidth: number? = node.MinCellWidth
	local columns: number = fixedColumns
	local cells = {} --- @type { GuiObject }
	local rows = {} --- @type { Frame }
	local watched = {} --- @type { [GuiObject]: boolean }
	local reflowQueued: boolean = false

	--[[ Building ]]

	local grid: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(grid, "Vertical", style.Gap)

	--%%%%%%%%%%%%%%%%%%%% Is Placed

	--[[
		Returns whether a cell still sits in this grid: in one of its rows, or added and waiting for the next reflow.
	]]
	--- @return boolean
	local function isPlaced(cell: GuiObject)
		--[[ Local Variables ]]

		local parent: Instance? = cell.Parent

		--[[ Returning ]]

		return parent ~= nil and (parent == grid or parent.Parent == grid)
	end

	--%%%%%%%%%%%%%%%%%%%% Reflow

	--[[
		Puts every cell in its row and column width, adding or removing rows to match. Cells that were destroyed or that
		another grid took over are dropped first. Properties that already hold their value are not written again, so a
		reflow that changes one cell stays cheap.
	]]
	local function reflow()
		--[[ Pruning ]]

		for index: number = #cells, 1, -1 do
			if not isPlaced(cells[index]) then
				table.remove(cells, index)
			end
		end

		--[[ Rows ]]

		local needed: number = math.ceil(#cells / columns)
		while #rows < needed do
			local row: Frame = ctx.Create("Frame", {
				Name = `Row{#rows + 1}`,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = #rows + 1,
				Size = UDim2.fromScale(1, 0),
				Parent = grid,
			})
			ctx.List(row, "Horizontal", style.Gap).VerticalAlignment = Enum.VerticalAlignment.Top
			table.insert(rows, row)
		end

		--[[ Cells ]]

		local widthScale: number = 1 / columns
		local widthOffset: number = -gap * (columns - 1) / columns

		for index: number, cell: GuiObject in ipairs(cells) do
			local size: UDim2 = cell.Size
			local row: Frame = rows[math.ceil(index / columns)]
			if size.X.Scale ~= widthScale or size.X.Offset ~= widthOffset then
				cell.Size = UDim2.new(widthScale, widthOffset, size.Y.Scale, size.Y.Offset)
			end
			if cell.LayoutOrder ~= index then
				cell.LayoutOrder = index
			end
			if cell.Parent ~= row then
				cell.Parent = row
			end
		end

		-- Rows left empty go once their cells moved
		while #rows > needed do
			table.remove(rows):Destroy()
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Queue Reflow

	--[[
		Reflows once at the end of the frame's current work, so a batch of added or removed cells costs one reflow.
	]]
	local function queueReflow()
		--[[ Checks ]]

		-- One reflow is already on its way
		if reflowQueued then
			return
		end

		--[[ Scheduling ]]

		reflowQueued = true
		task.defer(function()
			reflowQueued = false

			-- None once the grid itself is gone
			if grid.Parent then
				reflow()
			end
		end)
	end

	--%%%%%%%%%%%%%%%%%%%% Watch

	--[[
		Drops a cell from the grid once it is destroyed. Each cell is watched once, however often it comes back.
	]]
	local function watch(cell: GuiObject)
		--[[ Checks ]]

		-- Already watched
		if watched[cell] then
			return
		end

		--[[ Connections ]]

		watched[cell] = true
		ctx.Connect(cell.Destroying, function()
			watched[cell] = nil
			local index: number? = table.find(cells, cell)
			if index then
				table.remove(cells, index)
				queueReflow()
			end
		end)
	end

	--%%%%%%%%%%%%%%%%%%%% Apply Columns

	--[[
		Recounts the columns: from the width when they follow it, else the fixed count. Reflows when the count changed.
	]]
	local function applyColumns()
		--[[ Local Variables ]]

		local width: number = grid.AbsoluteSize.X
		local count: number = fixedColumns

		--[[ Counting ]]

		if minCellWidth then
			-- Not laid out yet
			if width <= 0 then
				return
			end
			count = math.max(1, math.floor((width + gap) / (minCellWidth + gap)))
		end

		--[[ Applying ]]

		if count ~= columns then
			columns = count
			reflow()
		end
	end

	--[[ Handle ]]

	local handle = { Instance = grid, Slot = grid } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Add Child

	--[[
		Adds a cell after the others. Cells added in one go are laid out together at the end of the frame's work.
	]]
	--- @param child UmeGui_Handle
	function handle.AddChild(child)
		--[[ Adding ]]

		local cell: GuiObject = child.Instance
		cell.Parent = grid
		table.insert(cells, cell)
		watch(cell)
		queueReflow()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Cells

	--[[
		Shows exactly these children, in this order. A child kept by another grid moves here; a cell of this grid left
		out is taken out of the gui (parented to nil) but not destroyed, so its script can show it again later.
	]]
	--- @param children { UmeGui_Handle }
	function handle.SetCells(children)
		--[[ Local Variables ]]

		local nextCells = {} --- @type { GuiObject }
		local kept = {} --- @type { [GuiObject]: boolean }

		--- @param child UmeGui_Handle
		for _index: number, child in ipairs(children) do
			table.insert(nextCells, child.Instance)
			kept[child.Instance] = true
		end

		--[[ Removing ]]

		for _index: number, cell: GuiObject in ipairs(cells) do
			-- Only cells still here; one another grid took is that grid's now
			if not kept[cell] and isPlaced(cell) then
				cell.Parent = nil
			end
		end

		--[[ Placing ]]

		for _index: number, cell: GuiObject in ipairs(nextCells) do
			watch(cell)

			-- Taken in now, so the prune in reflow keeps it
			if not isPlaced(cell) then
				cell.Parent = grid
			end
		end
		cells = nextCells
		reflow()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Layout

	--[[
		Changes the columns: a fixed count, or as many as fit cells `minWidth` wide (wins over the count when given).
	]]
	function handle.SetLayout(count: number?, minWidth: number?)
		--[[ Applying ]]

		fixedColumns = math.max(1, math.floor(count or 2))
		minCellWidth = minWidth
		applyColumns()
	end

	--[[ Connections ]]

	applyColumns()
	ctx.Connect(grid:GetPropertyChangedSignal("AbsoluteSize"), function()
		if minCellWidth then
			applyColumns()
		end
	end)

	--[[ Returning ]]

	return handle
end

return Module
