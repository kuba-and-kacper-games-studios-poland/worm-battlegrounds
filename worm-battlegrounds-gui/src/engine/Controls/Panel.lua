--[[
	Created By: 	Nari
]]

local _localName: string = "Panel"

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

--- @class UmeGui_Controls_Panel
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

	local surface = ctx.Surface(UDim2.fromScale(1, 1)) --- @type UmeGui_Surface
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Padding(surface.Content, style.Padding)
	ctx.List(surface.Content, "Vertical", style.Gap)

	--[[ Returning ]]

	return { Instance = surface.Root, Slot = surface.Content }
end

return Module
