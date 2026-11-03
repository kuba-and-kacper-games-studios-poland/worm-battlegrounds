--[[
	Created By: 	Nari
]]

local _localName: string = "Label"

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

--- @class UmeGui_Controls_Label
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

	local label: TextLabel = ctx.Create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Text = if style.Upper then string.upper(node.Text) else node.Text,
		TextWrapped = node.Wrap ~= false,
		TextXAlignment = Enum.TextXAlignment[node.Align or "Left"],
	})
	ctx.Typography(label, style.Font, style.TextSize)

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
		label.Text = if style.Upper then string.upper(text) else text
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

return Module
