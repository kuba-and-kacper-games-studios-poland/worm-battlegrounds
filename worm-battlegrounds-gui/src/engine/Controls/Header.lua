--[[
	Created By: 	Nari
]]

local _localName: string = "Header"

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

--- @class UmeGui_Controls_Header
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Text = "string",
		Logo = "string?",
		Back = "boolean|string?",
		Inline = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local header: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(header, "Vertical", "None")

	-- Title row
	local row: Frame = ctx.Create("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.Height) + ctx.Number("Spacing", style.PaddingY) * 2),
		Parent = header,
	})
	ctx.Padding(row, style.PaddingY, style.PaddingX)
	ctx.List(row, "Horizontal", style.Gap)

	-- Back button
	local back = nil --- @type UmeGui_Handle?
	if node.Back then
		back = ctx.Build({
			Control = "Button",
			Text = if type(node.Back) == "string" then node.Back else "‹  Back",
			AutoWidth = true,
			Style = style.BackStyle,
		}, row)
		back.Instance.Name = "Back"
		back.Instance.LayoutOrder = 0
	end

	-- Title, followed by the inline children; the group takes the free width
	local titleGroup: Frame = ctx.Create("Frame", {
		Name = "TitleGroup",
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 1),
		Parent = row,
	})
	ctx.List(titleGroup, "Horizontal", style.InlineGap)
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = titleGroup })

	-- Logo before the title
	if node.Logo then
		local logoSize: number = ctx.Number("Size", style.LogoSize)
		ctx.Create("ImageLabel", {
			Name = "Logo",
			Image = node.Logo,
			LayoutOrder = -1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(logoSize, logoSize),
			Parent = titleGroup,
		})
	end

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 1),
		Text = node.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = titleGroup,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Shrink, Parent = title })

	-- Children slot on the right
	local actions: Frame = ctx.Create("Frame", {
		Name = "Actions",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		Size = UDim2.fromScale(0, 1),
		Parent = row,
	})
	ctx.List(actions, "Horizontal", style.ActionGap)

	-- Divider below
	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = header,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = header,
		Slot = actions,
		BackClicked = if back then back.Clicked else ctx.Signal.new(),
	}
	local placed: number = 0

	--%%%%%%%%%%%%%%%%%%%% Add Child

	--[[
		Places the first `Inline` children after the title and the rest on the right end.
	]]
	--- @param child UmeGui_Handle
	function handle.AddChild(child)
		--[[ Placing ]]

		placed += 1
		child.Instance.Parent = if placed <= (node.Inline or 0) then titleGroup else actions
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the title.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--[[ Returning ]]

	return handle
end

return Module
