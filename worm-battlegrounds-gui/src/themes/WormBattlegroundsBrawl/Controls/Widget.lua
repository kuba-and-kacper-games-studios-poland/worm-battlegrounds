--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Widget
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

	local plateWidth: number = ctx.Number("Size", style.PlateWidth)
	local plateHeight: number = ctx.Number("Size", style.PlateHeight)
	local plateRise: number = ctx.Number("Size", style.PlateRise)
	local closeWidth: number = ctx.Number("Size", style.CloseWidth)
	local closeHeight: number = ctx.Number("Size", style.CloseHeight)
	local headerBottom: number = plateHeight - plateRise

	--[[ Building ]]

	-- The box WidgetManager tweens: no look of its own
	local widget: Frame = ctx.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(ctx.Number("Size", style.Width), ctx.Number("Size", style.Height)),
	})
	ctx.Create("UIScale", { Name = "S_ScreenScale", Parent = widget })

	-- Its size per device (Utils_PlatformScale, on S_ScreenScale), which ScreenScale multiplies with the screen's
	ctx.Tag(widget, { Utils_PlatformScale = style.PlatformScale })

	--%%%%%%%%%%%%%%%%%%%% Panel

	-- The window: a gradient body with the diamond pattern, inside a glowing border skin
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

	-- The title plate breaks out of the top-left corner, tilted; the close leans with it on the top-right corner
	local top: Frame = ctx.Create("Frame", {
		Name = "Bg_Top",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -plateRise),
		Size = UDim2.new(1, 0, 0, plateHeight),
		ZIndex = 999,
		Parent = widget,
	})

	local plate: ImageLabel = ctx.Create("ImageLabel", {
		Name = "Banner",
		Image = ctx.Icon(style.Plate),
		Position = UDim2.fromOffset(ctx.Number("Size", style.PlateX), 0),
		Rotation = style.Tilt,
		Size = UDim2.fromOffset(plateWidth, plateHeight),
		Parent = top,
	})

	-- The title sits on the plate's face, above its lip
	local titleInset: number = ctx.Number("Size", style.TitleInset)
	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, -titleInset * 2, 0, plateHeight - ctx.Number("Size", style.PlateLip)),
		Text = if style.TitleUpper then string.upper(node.Title) else node.Title,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 6,
		Parent = plate,
	})
	ctx.Text(title, style.TitleFont, style.TitleSize, style.Title)
	local titleStroke: UIStroke = ctx.Stroke(title, style.TitleStroke, style.TitleStrokeThickness)
	titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	-- A title the game writes later stays in capitals too (its TextCase_Upper component)
	if style.TitleUpper then
		ctx.Tag(title, { TextCase_Upper = {} })
	end

	-- Closes through WidgetManager (style CloseTags): a click, or B on a gamepad
	if node.Close ~= false then
		ctx.Build({
			Control = "Button",
			Text = "",
			Style = style.CloseStyle,
			-- B's badge on Console (the game's Console module, its Back action)
			Hint = "Back",
			Tags = style.CloseTags,
			Props = {
				Name = "CloseButton",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, ctx.Number("Size", style.CloseOut), 0, ctx.Number("Size", style.CloseY)),
				Rotation = style.Tilt,
				Size = UDim2.fromOffset(closeWidth, closeHeight),
			},
		}, top)
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
		Replaces the plate's title.
	]]
	function handle.SetTitle(text: string)
		title.Text = if style.TitleUpper then string.upper(text) else text
	end

	--[[ Returning ]]

	return handle
end

return Module
