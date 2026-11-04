--[[
	Created By: 	Nari
]]

local _localName: string = "Widget"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Widget
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Title = "string",
		Close = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local bannerHeight: number = ctx.Number("Size", style.BannerHeight)
	local closeSize: number = ctx.Number("Size", style.CloseSize)
	local headerInset: number = ctx.Number("Size", style.HeaderInset)
	local padding: number = ctx.Number("Spacing", style.Padding)
	local headerBottom: number = headerInset + bannerHeight

	--[[ Building ]]

	-- The box WidgetManager tweens: no look of its own
	local widget: Frame = ctx.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(ctx.Number("Size", style.Width), ctx.Number("Size", style.Height)),
	})
	ctx.Create("UIScale", { Name = "S_ScreenScale", Parent = widget })

	--%%%%%%%%%%%%%%%%%%%% Panel

	local bottom: Frame = ctx.Create("Frame", {
		Name = "Bg_Bottom",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = -999,
		Parent = widget,
	})
	ctx.Build({ Control = "Slab", Style = style.Panel }, bottom)

	--%%%%%%%%%%%%%%%%%%%% Header

	-- A bar across the panel's top, just inside its frame: the title on the left, the close button on the right
	local top: Frame = ctx.Create("Frame", {
		Name = "Bg_Top",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, headerInset),
		Size = UDim2.new(1, -headerInset * 2, 0, bannerHeight),
		ZIndex = 999,
		Parent = widget,
	})

	local banner: Frame = ctx.Create("Frame", {
		Name = "Banner",
		Size = UDim2.fromScale(style.BannerWidth, 1),
		Parent = top,
	})
	ctx.Build({ Control = "Slab", Style = style.Banner }, banner)

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, padding, 0.5, 0),
		Size = UDim2.new(1, -padding * 2 - closeSize, 1, 0),
		Text = if style.TitleUpper then string.upper(node.Title) else node.Title,
		TextXAlignment = Enum.TextXAlignment[style.TitleAlign],
		ZIndex = 6,
		Parent = banner,
	})
	ctx.Text(title, style.TitleFont, style.TitleSize, style.Title)
	local titleStroke: UIStroke = ctx.Stroke(title, style.TitleStroke, style.TitleStrokeThickness)
	titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	titleStroke.Enabled = ctx.Number("Stroke", style.TitleStrokeThickness) > 0

	-- Closes through WidgetManager (style CloseTags): a click, or B on a gamepad
	if node.Close ~= false then
		local close = ctx.Build({ --- @type UmeGui_Handle
			Control = "Button",
			Text = "X",
			Style = style.CloseStyle,
			Props = {
				Name = "CloseButton",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -math.floor((bannerHeight - closeSize) / 2), 0.5, 0),
				Size = UDim2.fromOffset(closeSize, closeSize),
			},
		}, top)
		ctx.Tag(close.Button, style.CloseTags)
	end

	--%%%%%%%%%%%%%%%%%%%% Content

	local content: Frame = ctx.Create("Frame", {
		Name = "Content",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, headerBottom),
		Size = UDim2.new(1, 0, 1, -headerBottom),
		Parent = widget,
	})
	ctx.Padding(content, style.Padding)
	ctx.List(content, "Vertical", style.Gap)

	-- Frees the mouse from shift lock while the widget shows; exported beside the widget
	local mouseLockFix: ImageButton = ctx.Create("ImageButton", {
		Name = "MouseLockFix",
		BackgroundTransparency = 1,
		Image = "",
		ImageTransparency = 1,
		Interactable = false,
		Modal = true,
		Selectable = false,
	})

	--[[ Handle ]]

	local handle = { Instance = widget, Slot = content, Siblings = { mouseLockFix } } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Title

	--[[
		Replaces the header's title.
	]]
	function handle.SetTitle(text: string)
		title.Text = if style.TitleUpper then string.upper(text) else text
	end

	--[[ Returning ]]

	return handle
end

return Module
