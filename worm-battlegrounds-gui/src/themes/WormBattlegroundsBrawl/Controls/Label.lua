--[[
	Created By: 	Nari
]]

local _localName: string = "Label"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Themes: Instance = script:FindFirstAncestor("Themes")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local BaseLabel = require(Themes:FindFirstChild("WormBattlegrounds"):FindFirstChild("Controls"):FindFirstChild("Label")) --- @type UmeGui_Themes_WormBattlegrounds_Controls_Label

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Label
local Module = {

	--[[ Schema ]]

	Params = BaseLabel.Params,
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local handle = BaseLabel.Build(node, style, ctx) --- @type UmeGui_Handle

	--[[ Applying ]]

	-- Text the game writes later stays in capitals too (its TextCase_Upper component)
	if style.Upper then
		ctx.Tag(handle.Instance, { TextCase_Upper = {} })
	end

	--[[ Returning ]]

	return handle
end

return Module
