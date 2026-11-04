--[[
	Created By: 	Nari
]]

local _localName: string = "Slab"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Slab
local Module = {

	--[[ Schema ]]

	Params = {},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param _node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(_node, style, ctx)
	--[[ Local Variables ]]

	local bevelInset: number = ctx.Number("Size", style.BevelInset)
	local patternSize: number = ctx.Number("Size", style.PatternSize)

	--[[ Building ]]

	--[[
		The flat framed surface the other controls draw on: its face and outline, a texture, a bevel line.
		A Folder, so its parts size to the frame it's in: a scale-sized frame inside an auto-height box grows it to its parent
	]]
	local root: Folder = ctx.Create("Folder", { Name = "Slab" })

	local face: Frame = ctx.Create("Frame", {
		Name = "Face",
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = root,
	})
	ctx.Color(face, "BackgroundColor3", style.Fill)
	ctx.Corner(face, style.Radius)

	local stroke: UIStroke = ctx.Stroke(face, style.Stroke, style.StrokeThickness)
	stroke.Enabled = ctx.Number("Stroke", style.StrokeThickness) > 0

	-- A texture tiled over the face (header stripes)
	if style.Pattern ~= "" then
		local pattern: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Pattern",
			Image = ctx.Icon(style.Pattern),
			ImageTransparency = style.PatternTransparency,
			ScaleType = Enum.ScaleType.Tile,
			Size = UDim2.fromScale(1, 1),
			TileSize = UDim2.fromOffset(patternSize, patternSize),
			ZIndex = 3,
			Parent = root,
		})
		ctx.Corner(pattern, style.Radius)
	end

	-- A light line just inside the face's edge, the frame's bevel
	local bevel: Frame = ctx.Create("Frame", {
		Name = "Bevel",
		Position = UDim2.fromOffset(bevelInset, bevelInset),
		Size = UDim2.new(1, -bevelInset * 2, 1, -bevelInset * 2),
		ZIndex = 4,
		Parent = root,
	})
	ctx.Corner(bevel, math.max(ctx.Number("Radius", style.Radius) - bevelInset, 0))

	local bevelStroke: UIStroke = ctx.Stroke(bevel, style.BevelColor, style.Bevel)
	bevelStroke.Enabled = ctx.Number("Stroke", style.Bevel) > 0

	--[[ Returning ]]

	return { Instance = root, Face = face, Stroke = stroke, Bevel = bevelStroke }
end

return Module
