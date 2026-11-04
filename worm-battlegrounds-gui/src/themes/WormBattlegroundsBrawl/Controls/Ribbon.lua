--[[
	Created By: 	Nari
]]

local _localName: string = "Ribbon"

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Ribbon
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param _node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(_node, style, ctx)
	--[[ Local Variables ]]

	local height: number = ctx.Number("Size", style.Height)
	local raysSize: number = ctx.Number("Size", style.RaysSize)

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		Size = UDim2.new(style.Width, 0, 0, height),
	})

	-- Sunburst rays turning slowly behind the banner (Utils_Motion's Rotate, in game too)
	if style.Rays then
		local rays: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Rays",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = ctx.Icon("wb-rays"),
			ImageTransparency = style.RaysTransparency,
			Position = UDim2.fromScale(style.RaysX, 0.5),
			Size = UDim2.fromOffset(raysSize, raysSize),
			ZIndex = 0,
			Parent = root,
		})
		ctx.Color(rays, "ImageColor3", style.RaysColor)
		ctx.Tag(rays, { Utils_Motion = { Utils_MotionKind = "Rotate", Utils_MotionAmount = style.RaysSpeed } })
	end

	--[[
		The slanted banner, 9-sliced so its ends keep their slant at any width; scaled so the image's height is the
		ribbon's, since a stretched middle row would bend the slant
	]]
	local banner: ImageLabel = ctx.Create("ImageLabel", {
		Name = "Banner",
		Image = ctx.Icon(style.Image),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(1, 1),
		SliceCenter = style.SliceCenter,
		SliceScale = height / style.ImageHeight,
		ZIndex = 1,
		Parent = root,
	})
	ctx.Color(banner, "ImageColor3", style.Tint)

	local content: Frame = ctx.Create("Frame", {
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = root,
	})
	ctx.Padding(content, "None", style.PaddingX)
	local list: UIListLayout = ctx.List(content, "Vertical", style.Gap)
	list.VerticalAlignment = Enum.VerticalAlignment.Center

	--[[ Returning ]]

	return { Instance = root, Slot = content }
end

return Module
