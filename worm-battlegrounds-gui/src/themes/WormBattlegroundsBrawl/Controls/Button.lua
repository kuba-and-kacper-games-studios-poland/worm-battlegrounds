--[[
	Created By: 	Nari
]]

local _localName: string = "Button"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Controls: Instance = script.Parent

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Slab = require(Controls:FindFirstChild("Slab")) --- @type UmeGui_Themes_WormBattlegroundsBrawl_Controls_Slab

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

--- @class UmeGui_Themes_WormBattlegroundsBrawl_Controls_Button
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Icon = "string?",
		AutoWidth = "boolean?",
		Disabled = "boolean?",
		Selected = "boolean?",
		Screen = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local height: number = ctx.Number("Size", style.Height)
	local lift: number = ctx.Number("Size", style.TextLift)
	local disabled: boolean = node.Disabled == true
	local selected: boolean = node.Selected == true

	--[[ Building ]]

	-- The shared Button's structure, its look one kit skin behind the text
	local parts = ctx.Pressable(UDim2.new(if node.AutoWidth then 0 else 1, 0, 0, height), Module._getText(node.Text, style)) --- @type UmeGui_Pressable
	local button: ImageButton = parts.Button
	local buttonText: TextLabel = parts.Text
	parts.Background.BackgroundTransparency = 1
	ctx.Typography(buttonText, style.Font, style.TextSize, true)
	ctx.Padding(parts.Content, "None", style.PaddingX)
	ctx.Tag(button, style.Tags)

	-- One placed on the screen by itself (a touch button) scales with it and per device, as the Box panels do
	if node.Screen then
		ctx.Create("UIScale", { Name = "S_ScreenScale", Parent = parts.Container })
		ctx.Tag(parts.Container, { Utils_PlatformScale = style.PlatformScale })
	end

	local slab = ctx.Build({ Control = "Slab", Style = { Skin = Module._getSkin(style, height, false, false), Drop = style.Drop } }, parts.Background) --- @type UmeGui_Handle
	local textStroke: UIStroke = ctx.Stroke(buttonText, style.TextStroke, style.TextStrokeThickness)
	textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	textStroke.Enabled = ctx.Number("Stroke", style.TextStrokeThickness) > 0

	-- The text sits on the face, above the lip drawn into the skin
	buttonText.Position = UDim2.new(0.5, 0, 0.5, -lift)

	-- A picture beside the text, or alone in the middle of an icon button
	if node.Icon then
		local iconSize: number = ctx.Number("Size", style.IconSize)
		local icon: ImageLabel = ctx.Glyph(node.Icon, iconSize)
		icon.AnchorPoint = Vector2.new(if node.Text == "" then 0.5 else 0, 0.5)
		icon.Position = UDim2.new(if node.Text == "" then 0.5 else 0, 0, 0.5, -lift)
		icon.Parent = parts.Content
		buttonText.AnchorPoint = Vector2.new(1, 0.5)
		buttonText.Position = UDim2.new(1, 0, 0.5, -lift)
		buttonText.Size = UDim2.new(1, -iconSize - ctx.Number("Spacing", style.IconGap), 0, buttonText.Size.Y.Offset)
	end

	-- An auto-width button fits its styled text
	if node.AutoWidth then
		ctx.FitWidth(parts)
	end

	--[[ States ]]

	-- Hover and press are the ButtonScale tags; a press also dims the skin a little
	local states = ctx.States({ --- @type UmeGui_States
		SkinTint = { Instance = slab.Skin, Property = "ImageColor3" },
		Text = { Instance = buttonText, Property = "TextColor3" },
		TextStroke = { Instance = textStroke, Property = "Color" },
	}, style)
	ctx.Hover(button, states)

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = button, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Refresh Skin

	--[[
		Shows the skin for the button's state: grey when it can't be pressed, its selected colour when picked.
	]]
	local function refreshSkin()
		Slab.SetSkin(slab, Module._getSkin(style, height, disabled, selected), style.SkinScale, ctx)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the label.
	]]
	function handle.SetText(text: string)
		--[[ Applying ]]

		buttonText.Text = Module._getText(text, style)
		if node.AutoWidth then
			ctx.FitWidth(parts)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set Disabled

	--[[
		Greys the button out and stops it firing Clicked.
	]]
	function handle.SetDisabled(isDisabled: boolean)
		--[[ Applying ]]

		disabled = isDisabled
		states.Set("Disabled", isDisabled)
		refreshSkin()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Shows the button as the active choice.
	]]
	function handle.SetSelected(isSelected: boolean)
		--[[ Applying ]]

		selected = isSelected
		states.Set("Selected", isSelected)
		refreshSkin()
	end

	--[[ Applying ]]

	states.Set("Disabled", disabled)
	states.Set("Selected", selected)
	states.Refresh(true)
	refreshSkin()

	-- Exports are static: game code shows a state by swapping the skin to one of these
	slab.Skin:SetAttribute("Kit_Image", ctx.Icon(Module._getSkin(style, height, false, false)))
	slab.Skin:SetAttribute("Kit_SelectedImage", ctx.Icon(Module._getSkin(style, height, false, true)))
	slab.Skin:SetAttribute("Kit_DisabledImage", ctx.Icon(Module._getSkin(style, height, true, false)))

	--[[ Connections ]]

	ctx.Connect(button.Activated, function()
		-- Ignore clicks while disabled
		if disabled then
			return
		end

		handle.Clicked:Fire()
	end)

	--[[ Returning ]]

	return handle
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Skin

--[[
	Returns the skin for a state. A slanted skin names its height ("{height}"), since each height has its own image.
]]
--- @param style UmeGui_Style
--- @return string
function Module._getSkin(style, height: number, disabled: boolean, selected: boolean)
	--[[ Local Variables ]]

	local skin: string = if disabled then style.DisabledSkin elseif selected then style.SelectedSkin else style.Skin

	--[[ Returning ]]

	return (string.gsub(skin, "{height}", tostring(height)))
end

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
