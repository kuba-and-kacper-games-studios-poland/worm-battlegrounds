--[[
	Created By: 	Nari
]]

local _localName: string = "Box"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Box
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Title = "string?",
		Screen = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), style.AutoHeight) --- @type UmeGui_Surface
	local content: Frame = surface.Content

	-- The slab takes the background's place, straight in the root, so an auto-height box keeps its content's height
	surface.Background:Destroy()
	ctx.Build({ Control = "Slab", Style = style.Slab }, surface.Root)
	content.ZIndex = 6

	local padding: UIPadding = ctx.Padding(content, style.Padding)

	local list: UIListLayout = ctx.List(content, "Vertical", style.Gap)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- A fixed box in a column takes the height the column leaves free
	if style.Flex then
		ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = surface.Root })
	end

	-- A panel placed on the screen scales itself to it; its gui gives it a U_ Id, so code finds S_ScreenScale
	if node.Screen then
		ctx.Create("UIScale", { Name = "S_ScreenScale", Parent = surface.Root })
	end

	-- The title on a header band across the box's top, just inside its frame
	if node.Title then
		local bandInset: number = ctx.Number("Size", style.BandInset)
		local bandPadding: number = ctx.Number("Spacing", style.BandPadding)
		padding.PaddingTop = UDim.new(0, bandInset)

		local band: Frame = ctx.Create("Frame", {
			Name = "Band",
			LayoutOrder = -1,
			Size = UDim2.new(1, (ctx.Number("Spacing", style.Padding) - bandInset) * 2, 0, ctx.Number("Size", style.BandHeight)),
			Parent = content,
		})
		ctx.Build({ Control = "Slab", Style = style.Band }, band)

		local title: TextLabel = ctx.Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -bandPadding * 2, 1, 0),
			Text = if style.TitleUpper then string.upper(node.Title) else node.Title,
			TextXAlignment = Enum.TextXAlignment[style.TitleAlign],
			ZIndex = 6,
			Parent = band,
		})
		ctx.Text(title, style.TitleFont, style.TitleSize, style.Title)
		local titleStroke: UIStroke = ctx.Stroke(title, style.TitleStroke, style.TitleStrokeThickness)
		titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		titleStroke.Enabled = ctx.Number("Stroke", style.TitleStrokeThickness) > 0
	end

	--[[ Returning ]]

	return { Instance = surface.Root, Slot = content }
end

return Module
