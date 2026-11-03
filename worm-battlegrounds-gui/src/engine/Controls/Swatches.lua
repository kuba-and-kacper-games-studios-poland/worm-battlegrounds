--[[
	Created By: 	Nari
]]

local _localName: string = "Swatches"

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

--- @class UmeGui_Controls_Swatches
local Module = {

	--[[ Schema ]]

	Params = {
		Colors = "string|table",
		Value = "Color3?",
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Same Color

--[[
	Returns whether two colors match to 8-bit precision.
]]
--- @return boolean
local function isSameColor(first: Color3?, second: Color3?)
	--[[ Checks ]]

	-- A missing color never matches
	if not first or not second then
		return false
	end

	--[[ Returning ]]

	return first:ToHex() == second:ToHex()
end

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Data ]]

	local colors = if type(node.Colors) == "string" then ctx.Theme.Tokens.Swatches[node.Colors] else node.Colors --- @type { Color3 }?

	-- Check if the swatch set exists
	if not colors then
		error(`unknown swatch set "{node.Colors}"`, 0)
	end

	--[[ Local Variables ]]

	local value: Color3? = node.Value
	local size: number = ctx.Number("Size", style.Size)
	local rings = {} --- @type { [UIStroke]: Color3 }

	--[[ Building ]]

	local row: Frame = ctx.Create("Frame", {
		Size = UDim2.new(1, 0, 0, size),
	})
	local list: UIListLayout = ctx.List(row, "Horizontal", style.Gap)
	list.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween

	--[[ Handle ]]

	local handle = { Instance = row, Changed = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Selects the tile matching a color (none when no tile matches) without firing Changed.
	]]
	function handle.Set(color: Color3?)
		--[[ Applying ]]

		value = color
		for ring: UIStroke, ringColor: Color3 in pairs(rings) do
			ring.Enabled = isSameColor(ringColor, color)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the selected color.
	]]
	--- @return Color3?
	function handle.Get()
		return value
	end

	--[[ Tiles ]]

	for index: number, color: Color3 in ipairs(colors) do
		local tile = ctx.Pressable(UDim2.fromOffset(size, size)) --- @type UmeGui_Pressable
		tile.Container.Name = `Swatch{index}`
		tile.Container.LayoutOrder = index
		tile.Container.Parent = row
		tile.Background.BackgroundColor3 = color
		ctx.Corner(tile.Background, style.Radius)

		local ring: UIStroke = ctx.Stroke(tile.Background, style.Ring, style.RingThickness)
		ring.Enabled = isSameColor(color, value)
		rings[ring] = color

		ctx.Connect(tile.Button.Activated, function()
			handle.Set(color)
			handle.Changed:Fire(color)
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
