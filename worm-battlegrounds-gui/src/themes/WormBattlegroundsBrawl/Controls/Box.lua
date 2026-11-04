--[[
	Created By: 	Nari
]]

local _localName: string = "Box"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Themes: Instance = script:FindFirstAncestor("Themes")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local BaseBox = require(Themes:FindFirstChild("WormBattlegrounds"):FindFirstChild("Controls"):FindFirstChild("Box")) --- @type UmeGui_Themes_WormBattlegrounds_Controls_Box

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Box
local Module = {

	--[[ Schema ]]

	Children = BaseBox.Children,
	Params = BaseBox.Params,
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	-- The base theme's Box, its look from this theme's Slab
	local handle = BaseBox.Build(node, style, ctx) --- @type UmeGui_Handle

	--[[ Applying ]]

	-- A panel placed on the screen has its size per device too (Utils_PlatformScale, on its S_ScreenScale)
	if node.Screen then
		ctx.Tag(handle.Instance, { Utils_PlatformScale = style.PlatformScale })
	end

	--[[ Returning ]]

	return handle
end

return Module
