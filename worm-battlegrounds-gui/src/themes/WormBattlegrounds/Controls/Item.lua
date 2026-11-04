--[[
	Created By: 	Nari
]]

local _localName: string = "Item"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Item
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Text = "string?",
		Subtext = "string?",
		Image = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local parts = ctx.Pressable(UDim2.fromOffset(ctx.Number("Size", style.Width), ctx.Number("Size", style.Height))) --- @type UmeGui_Pressable
	local content: Frame = parts.Content
	parts.Background.BackgroundTransparency = 1
	ctx.Padding(content, style.Padding)
	ctx.List(content, "Vertical", style.Gap).HorizontalAlignment = Enum.HorizontalAlignment.Center
	ctx.Tag(parts.Button, style.Tags)

	local slab = ctx.Build({ Control = "Slab", Style = style.Slab }, parts.Background) --- @type UmeGui_Handle

	-- The name on a strip across the top, shown when the card has one
	local strip: Frame = ctx.Create("Frame", {
		Name = "Strip",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.StripHeight)),
		Visible = node.Text ~= nil,
		Parent = content,
	})
	ctx.Color(strip, "BackgroundColor3", style.StripFill)
	ctx.Corner(strip, "Small")

	local name: TextLabel = ctx.Create("TextLabel", {
		Name = "S_Name",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -8, 1, -4),
		Text = if style.Upper then string.upper(node.Text or "") else node.Text or "",
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = strip,
	})
	ctx.Text(name, style.Font, style.TextSize, style.Text)
	local nameStroke: UIStroke = ctx.Stroke(name, style.TextStroke, style.TextStrokeThickness)
	nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	nameStroke.Enabled = ctx.Number("Stroke", style.TextStrokeThickness) > 0

	-- The picture in a well that takes the height the texts leave free
	local well: Frame = ctx.Create("Frame", {
		Name = "Well",
		BackgroundTransparency = 0,
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		Parent = content,
	})
	ctx.Color(well, "BackgroundColor3", style.IconFill)
	ctx.Corner(well, "Small")
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = well })

	local icon: ImageLabel = ctx.Create("ImageLabel", {
		Name = "S_Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = ctx.Icon(node.Image or style.Image),
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(style.IconScale, style.IconScale),
		Parent = well,
	})
	ctx.Color(icon, "ImageColor3", style.Tint)

	local info: TextLabel = ctx.Create("TextLabel", {
		Name = "S_Info",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, ctx.Number("TextSize", style.SubtextSize)),
		Text = node.Subtext or "",
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = node.Subtext ~= nil,
		Parent = content,
	})
	ctx.Text(info, style.SubtextFont, style.SubtextSize, style.Subtext)

	-- Badges the gui places over the card (copies, lock, shiny mark, cooldown)
	local overlay: Frame = ctx.Create("Frame", {
		Name = "Overlay",
		Size = content.Size,
		ZIndex = 3,
		Parent = parts.Button,
	})

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = slab.Face, Property = "BackgroundColor3" },
		Stroke = { Instance = slab.Stroke, Property = "Color" },
		BevelColor = { Instance = slab.Bevel, Property = "Color" },
	}, style)
	states.Refresh(true)
	ctx.Hover(parts.Button, states)

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = parts.Button, Slot = overlay, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--[[ Connections ]]

	ctx.Connect(parts.Button.Activated, function()
		handle.Clicked:Fire()
	end)

	--[[ Returning ]]

	return handle
end

return Module
