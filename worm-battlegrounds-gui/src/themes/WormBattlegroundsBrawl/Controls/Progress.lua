--[[
	Created By: 	Nari
]]

local _localName: string = "Progress"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Controls: Instance = script:FindFirstAncestor("Themes").Parent:FindFirstChild("Controls")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local BaseProgress = require(Controls:FindFirstChild("Progress")) --- @type UmeGui_Controls_Progress

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Progress
local Module = {

	--[[ Schema ]]

	Params = BaseProgress.Params,
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local handle = BaseProgress.Build(node, style, ctx) --- @type UmeGui_Handle
	local status: TextLabel = handle.Instance:FindFirstChild("Status")

	--[[ Status ]]

	-- One line tall at its design size: AutomaticSize measures in screen pixels under a panel's S_ScreenScale
	status.AutomaticSize = Enum.AutomaticSize.None
	ctx.Typography(status, style.Font, style.TextSize, true)
	status.TextXAlignment = Enum.TextXAlignment[style.StatusAlign]

	-- The ink outline every text in the kit has, following the letters
	local stroke: UIStroke = ctx.Stroke(status, style.TextStroke, style.TextStrokeThickness)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	--[[ Returning ]]

	return handle
end

return Module
