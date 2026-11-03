--[[
	Created By: 	Nari
]]

local _localName: string = "Tabs"

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

--- @class UmeGui_Controls_Tabs
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Options = "table",
		Value = "string?",
		Shared = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local value: string = node.Value or node.Options[1]
	local pages = {} --- @type { GuiObject }
	local sharedCount: number = 0

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
	})
	ctx.List(root, "Vertical", "None")
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = root })

	-- Tab bar
	local bar: Frame = ctx.Create("Frame", {
		Name = "Bar",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Parent = root,
	})
	ctx.Padding(bar, style.PaddingY, style.PaddingX)
	local selector = ctx.Build({ Control = "Segmented", Options = node.Options, Value = value, Style = style.BarStyle }, bar) --- @type UmeGui_Handle

	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = root,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	-- Children shown on every page, under the bar
	local sharedFrame: Frame = ctx.Create("Frame", {
		Name = "Shared",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		Visible = (node.Shared or 0) > 0,
		Parent = root,
	})
	ctx.List(sharedFrame, "Vertical", "None")

	-- Pages, stacked; only one is visible
	local pagesFrame: Frame = ctx.Create("Frame", {
		Name = "Pages",
		ClipsDescendants = true,
		LayoutOrder = 3,
		Size = UDim2.fromScale(1, 1),
		Parent = root,
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = pagesFrame })

	--[[ Handle ]]

	local handle = { Instance = root, Changed = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Show Selected

	--[[
		Shows the selected option's page and hides the others.
	]]
	local function showSelected()
		--[[ Applying ]]

		local selectedIndex: number = table.find(node.Options, value) or 1
		for index: number, page: GuiObject in ipairs(pages) do
			page.Visible = index == selectedIndex
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Add Child

	--[[
		Adds the next page; pages follow the options in order.
	]]
	--- @param child UmeGui_Handle
	function handle.AddChild(child)
		--[[ Shared ]]

		-- The leading children are for every page
		if sharedCount < (node.Shared or 0) then
			sharedCount += 1
			child.Instance.Parent = sharedFrame
			return
		end

		--[[ Placing ]]

		table.insert(pages, child.Instance)
		child.Instance.Parent = pagesFrame
		showSelected()
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Selects a tab without firing Changed.
	]]
	function handle.Set(option: string)
		--[[ Applying ]]

		value = option
		selector.Set(option)
		showSelected()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the selected tab.
	]]
	--- @return string
	function handle.Get()
		return value
	end

	--[[ Connections ]]

	ctx.Connect(selector.Changed, function(option: string)
		value = option
		showSelected()
		handle.Changed:Fire(option)
	end)

	--[[ Returning ]]

	return handle
end

return Module
