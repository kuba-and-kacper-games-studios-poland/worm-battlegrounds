--[[
	Created By: 	Nari
]]

local _localName: string = "Slab"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Theme: Instance = script:FindFirstAncestor("WormBattlegroundsBrawl")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Skins = require(Theme:FindFirstChild("Skins")) --- @type { [string]: Rect }

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Slab
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

	local inset: number = ctx.Number("Size", style.Inset)
	local drop: number = ctx.Number("Size", style.Drop)
	local patternSize: number = ctx.Number("Size", style.PatternSize)

	--[[ Building ]]

	--[[
		The kit's surface the other controls draw on: a body (a fill, a gradient from the library or a see-through
		slot), the diamond pattern over it, and a skin image on top with the outline, light and lip drawn in.
		A Folder, so its parts size to the frame it's in
	]]
	local root: Folder = ctx.Create("Folder", { Name = "Slab" })

	local skin: ImageLabel? = nil
	local shadow: ImageLabel? = nil
	if style.Skin ~= "" then
		-- Named Face like the base theme's, so game code that finds a piece's face still does
		skin = ctx.Create("ImageLabel", {
			Name = "Face",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4,
			Parent = root,
		})
		Module.SetSkin({ Skin = skin }, style.Skin, style.SkinScale, ctx)
		ctx.Color(skin, "ImageColor3", style.SkinTint)

		-- The ink drop under a raised piece: the same skin, dark and see-through, a few px lower
		if drop > 0 then
			shadow = skin:Clone()
			shadow.Name = "Drop"
			shadow.ImageTransparency = style.DropTransparency
			shadow.Position = UDim2.fromOffset(0, drop)
			shadow.ZIndex = 1
			shadow.Parent = root
			ctx.Color(shadow, "ImageColor3", "Ink")
		end
	end

	-- The body inside the skin's outline
	local body: Frame? = nil
	if style.Fill ~= "" then
		body = ctx.Create("Frame", {
			Name = "Body",
			BackgroundTransparency = style.FillTransparency,
			Position = UDim2.fromOffset(inset, inset),
			Size = UDim2.new(1, -inset * 2, 1, -inset * 2),
			ZIndex = 2,
			Parent = root,
		})
		ctx.Color(body, "BackgroundColor3", style.Fill)
		ctx.Corner(body, style.Radius)

		-- A gradient from the library, top to bottom, or a slot fading clearer toward its bottom
		if style.Gradient or style.Fade > 0 then
			ctx.Create("UIGradient", {
				Color = style.Gradient or ColorSequence.new(Color3.new(1, 1, 1)),
				Rotation = 90,
				Transparency = NumberSequence.new(0, style.Fade),
				Parent = body,
			})
		end
	end

	-- The diamond pattern over the body, barely there
	if style.Pattern ~= "" then
		local pattern: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Pattern",
			Image = ctx.Icon(style.Pattern),
			ImageTransparency = style.PatternTransparency,
			Position = UDim2.fromOffset(inset, inset),
			ScaleType = Enum.ScaleType.Tile,
			Size = UDim2.new(1, -inset * 2, 1, -inset * 2),
			TileSize = UDim2.fromOffset(patternSize, patternSize),
			ZIndex = 3,
			Parent = root,
		})
		ctx.Corner(pattern, style.Radius)
	end

	--[[ Returning ]]

	return { Instance = root, Skin = skin, Drop = shadow, Body = body }
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Set Skin

--[[
	Shows another skin on a built slab (a button greying out): 9-slice when Skins.lua has its centre, stretched whole
	otherwise.
]]
--- @param slab UmeGui_Handle
--- @param ctx UmeGui_Context
function Module.SetSkin(slab, name: string, scale: number, ctx)
	--[[ Local Variables ]]

	local center: Rect? = Skins[name]

	--[[ Applying ]]

	--- @param image ImageLabel
	for _index: number, image in ipairs({ slab.Skin, slab.Drop }) do
		image.Image = ctx.Icon(name)
		image.ScaleType = if center then Enum.ScaleType.Slice else Enum.ScaleType.Stretch
		image.SliceCenter = center or Rect.new(0, 0, 0, 0)
		image.SliceScale = scale
	end
end

return Module
