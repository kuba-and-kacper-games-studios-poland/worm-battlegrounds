--[[
	Created By: 	Nari
]]

local _localName: string = "Footer"

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

--- @class UmeGui_Controls_Footer
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
	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	local footer: Frame = surface.Content
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.List(footer, "Vertical", "None")

	-- Divider along the top edge
	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = footer,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	-- Padded body that holds the children
	local body: Frame = ctx.Create("Frame", {
		Name = "Body",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Parent = footer,
	})
	ctx.Padding(body, style.Padding)
	ctx.List(body, "Vertical", style.Gap)

	--[[ Returning ]]

	return { Instance = surface.Root, Slot = body }
end

return Module
