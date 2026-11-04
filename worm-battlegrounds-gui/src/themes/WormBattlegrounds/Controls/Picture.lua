--[[
	Created By: 	Nari
]]

local _localName: string = "Picture"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Picture
local Module = {

	--[[ Schema ]]

	Params = {
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

	-- An image that isn't a button: an avatar, a map picture, a coin beside a number
	local picture: ImageLabel = ctx.Create("ImageLabel", {
		BackgroundTransparency = style.FillTransparency,
		Image = ctx.Icon(node.Image or style.Image),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(ctx.Number("Size", style.Width), ctx.Number("Size", style.Height)),
	})
	ctx.Color(picture, "BackgroundColor3", style.Fill)
	ctx.Color(picture, "ImageColor3", style.Tint)
	ctx.Corner(picture, style.Radius)
	ctx.Stroke(picture, style.Stroke, style.StrokeThickness)

	--[[ Returning ]]

	return { Instance = picture }
end

return Module
