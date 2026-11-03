--[[
	Created By: 	Nari
]]

local _localName: string = "EmptyState"

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

--- @class UmeGui_Controls_EmptyState
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Icon = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local iconSize: number = ctx.Number("TextSize", style.IconSize)

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = root })

	-- Faded icon behind the message
	local icon: ImageLabel = ctx.Glyph(node.Icon, iconSize, style.Icon)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.ImageTransparency = style.IconTransparency
	icon.Visible = node.Icon ~= nil
	icon.ZIndex = 1
	icon.Parent = root

	-- Message, centred on the icon
	local message = ctx.Build({ Control = "Label", Text = node.Text, Align = "Center", Style = style.TextStyle }, root) --- @type UmeGui_Handle
	message.Instance.Name = "Message"
	message.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
	message.Instance.Position = UDim2.fromScale(0.5, 0.5)
	message.Instance.Size = UDim2.fromScale(style.TextWidth, 0)
	message.Instance.ZIndex = 2

	--[[ Handle ]]

	local handle = { Instance = root } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the message.
	]]
	function handle.SetText(text: string)
		message.SetText(text)
	end

	--[[ Returning ]]

	return handle
end

return Module
