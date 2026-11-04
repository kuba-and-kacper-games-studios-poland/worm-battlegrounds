--[[
	Created By: 	Nari
]]

local _localName: string = "Label"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Rich-text escapes, put back after upper-casing a text ("&LT;" doesn't draw a "<")
--- @type { [string]: string }
local ENTITIES = { LT = "&lt;", GT = "&gt;", AMP = "&amp;", QUOT = "&quot;", APOS = "&apos;" }

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Label
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Align = "string?",
		Wrap = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local tone: any = style.Text

	--[[ Building ]]

	-- As tall as its style's Lines: AutomaticSize measures in screen pixels under a panel's S_ScreenScale
	local label: TextLabel = ctx.Create("TextLabel", {
		Size = UDim2.fromScale(1, 0),
		Text = Module._getText(node.Text, style),
		TextWrapped = node.Wrap ~= false,
		TextXAlignment = Enum.TextXAlignment[node.Align or "Left"],
	})
	ctx.Typography(label, style.Font, style.TextSize, true)
	label.Size = UDim2.new(1, 0, 0, label.Size.Y.Offset * style.Lines)

	-- The outline follows the letters, not the box
	local stroke: UIStroke = ctx.Stroke(label, style.TextStroke, style.TextStrokeThickness)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Enabled = ctx.Number("Stroke", style.TextStrokeThickness) > 0

	-- Fixed text keeps its size: the scaled text may not shrink below the cap either
	if style.Fixed then
		local constraint: UITextSizeConstraint = label:FindFirstChildOfClass("UITextSizeConstraint")
		constraint.MinTextSize = constraint.MaxTextSize
	end

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Colors the text with the current tone.
	]]
	local function paint()
		label.TextColor3 = ctx.ResolveColor(tone)
	end

	--[[ Theme ]]

	paint()
	ctx.Refresh(paint)

	--[[ Handle ]]

	local handle = { Instance = label } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the text.
	]]
	function handle.SetText(text: string)
		label.Text = Module._getText(text, style)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Tone

	--[[
		Recolors the text with another palette token, e.g. "Success" or "Danger".
	]]
	function handle.SetTone(token: any)
		--[[ Applying ]]

		tone = token or style.Text
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the text.
	]]
	--- @return string
	function handle.Get()
		return label.Text
	end

	--[[ Returning ]]

	return handle
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Text

--[[
	Returns the text as the style shows it: upper-case when its Upper key is on, its rich-text escapes kept.
]]
--- @param style UmeGui_Style
--- @return string
function Module._getText(text: string, style)
	return if style.Upper then (string.gsub(string.upper(text), "&(%u+);", ENTITIES)) else text
end

return Module
