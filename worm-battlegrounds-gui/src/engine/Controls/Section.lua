--[[
	Created By: 	Nari
]]

local _localName: string = "Section"

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

--- @class UmeGui_Controls_Section
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Text = "string",
		Count = "number?",
		Collapsible = "boolean?",
		Collapsed = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local collapsible: boolean = node.Collapsible ~= false
	local collapsed: boolean = node.Collapsed == true
	local barHeight: number = ctx.Number("Size", style.HeaderHeight) + ctx.Number("Spacing", style.PaddingY) * 2
	local menu = {} --- @type { any }

	--[[ Building ]]

	local section: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(section, "Vertical", "None")

	-- Title bar: the whole bar is the collapse button
	local bar = ctx.Pressable(UDim2.new(1, 0, 0, barHeight)) --- @type UmeGui_Pressable
	bar.Container.Name = "Header"
	bar.Container.LayoutOrder = 0
	bar.Container.Parent = section
	bar.Button.Active = collapsible
	ctx.Color(bar.Background, "BackgroundColor3", style.HeaderFill)
	ctx.Corner(bar.Background, style.HeaderRadius)
	ctx.Create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new(0, style.HeaderFade),
		Parent = bar.Background,
	})
	ctx.Padding(bar.Content, "None", style.PaddingX)
	ctx.List(bar.Content, "Horizontal", style.Gap)

	-- Bottom line, the separator under the bar
	local line: Frame = ctx.Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Visible = style.Line,
		ZIndex = 3,
		Parent = bar.Button,
	})
	ctx.Color(line, "BackgroundColor3", style.Divider)

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 1),
		Text = node.Text,
		Parent = bar.Content,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)

	local count: TextLabel = ctx.Create("TextLabel", {
		Name = "Count",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 1),
		Text = if node.Count then `· {node.Count}` else "",
		Visible = node.Count ~= nil,
		Parent = bar.Content,
	})
	ctx.Text(count, style.Font, style.TextSize, style.Count)

	-- Spacer pushes the chevron to the right
	local spacer: Frame = ctx.Create("Frame", {
		Name = "Spacer",
		LayoutOrder = 2,
		Size = UDim2.fromScale(0, 1),
		Parent = bar.Content,
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = spacer })

	-- Points down while open, right while collapsed. A glyph swap, not Rotation: rotation is not drawn inside a
	-- clipping ScrollingFrame, where sections usually sit
	local chevron: ImageLabel = ctx.Glyph(if collapsed then "chevron-small-right" else "chevron-small-down", ctx.Number("TextSize", style.ChevronSize), style.Chevron)
	chevron.Name = "Chevron"
	chevron.LayoutOrder = if style.ChevronLeft then -1 else 3
	chevron.Visible = collapsible
	chevron.Parent = bar.Content

	-- Content
	local content: Frame = ctx.Create("Frame", {
		Name = "Content",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Visible = not collapsed,
		Parent = section,
	})
	ctx.List(content, "Vertical", style.ContentGap)
	local padding: UIPadding = ctx.Padding(content, "None", style.PaddingX)
	padding.PaddingTop = UDim.new(0, ctx.Number("Spacing", style.PaddingTop))

	-- With the chevron first, content lines up with the title
	if style.ChevronLeft then
		padding.PaddingLeft = UDim.new(0, padding.PaddingLeft.Offset + ctx.Number("TextSize", style.ChevronSize) + ctx.Number("Spacing", style.Gap))
	end
	padding.PaddingBottom = UDim.new(0, ctx.Number("Spacing", style.PaddingBottom))

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		HeaderFill = { Instance = bar.Background, Property = "BackgroundColor3" },
	}, style)
	if collapsible then
		ctx.Hover(bar.Button, states)
	end

	--[[ Handle ]]

	-- The title bar's ImageButton, for scripts that drag sections
	local handle = { Instance = section, Slot = content, Button = bar.Button, Toggled = ctx.Signal.new(), MenuAction = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Collapsed

	--[[
		Hides or shows the section's content.
	]]
	function handle.SetCollapsed(isCollapsed: boolean)
		--[[ Applying ]]

		collapsed = isCollapsed
		content.Visible = not collapsed
		chevron.Image = ctx.Icon(if collapsed then "chevron-small-right" else "chevron-small-down")
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the title.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Count

	--[[
		Shows a count after the title, or hides it with nil.
	]]
	function handle.SetCount(value: number?)
		count.Text = if value then `· {value}` else ""
		count.Visible = value ~= nil
	end

	--%%%%%%%%%%%%%%%%%%%% Set Menu

	--[[
		Sets the actions a right click on the title bar offers (none hides the menu). An action is a name or
		`{ Id, Text?, Icon?, Danger? }`.
	]]
	--- @param actions { any }
	function handle.SetMenu(actions)
		menu = table.clone(actions)
	end

	--[[ Connections ]]

	if collapsible and ctx.Interactive then
		ctx.Connect(bar.Button.Activated, function()
			handle.SetCollapsed(not collapsed)
			handle.Toggled:Fire(collapsed)
		end)
	end
	if ctx.Interactive then
		ctx.Connect(bar.Button.MouseButton2Click, function()
			-- Sections without actions have no menu
			if #menu == 0 then
				return
			end

			ctx.ContextMenu(menu, function(actionId: string)
				handle.MenuAction:Fire(actionId)
			end)
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
