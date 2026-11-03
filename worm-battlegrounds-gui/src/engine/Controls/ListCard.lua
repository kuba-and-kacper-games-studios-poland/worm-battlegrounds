--[[
	Created By: 	Nari
]]

local _localName: string = "ListCard"

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

--- @class UmeGui_Controls_ListCard
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Subtext = "string?",
		Actions = "table?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	local card: Frame = surface.Content
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(surface.Background, style.Radius)
	ctx.Stroke(surface.Background, style.Stroke, style.StrokeThickness)
	ctx.Padding(card, style.Padding)
	ctx.List(card, "Horizontal", style.Gap)

	-- Title and subtitle
	local texts: Frame = ctx.Create("Frame", {
		Name = "Texts",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 0),
		Parent = card,
	})
	ctx.List(texts, "Vertical", "None")
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = texts })

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Text = node.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = texts,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)

	local subtitle: TextLabel = ctx.Create("TextLabel", {
		Name = "Subtext",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Text = node.Subtext or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = node.Subtext ~= nil,
		Parent = texts,
	})
	ctx.Text(subtitle, style.SubFont, style.SubSize, style.Subtext)

	-- Actions
	local actions: Frame = ctx.Create("Frame", {
		Name = "Actions",
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 1,
		Parent = card,
	})
	ctx.List(actions, "Horizontal", style.ActionGap)

	--[[ Handle ]]

	local handle = { Instance = surface.Root, Action = ctx.Signal.new() } --- @type UmeGui_Handle

	--[[ Actions ]]

	for index: number, actionName: string in ipairs(node.Actions or {}) do
		local button = ctx.Build({ Control = "Button", Text = actionName, AutoWidth = true, Style = style.ActionStyle }, actions) --- @type UmeGui_Handle
		button.Instance.Name = actionName
		button.Instance.LayoutOrder = index
		ctx.Connect(button.Clicked, function()
			handle.Action:Fire(actionName)
		end)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the title.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Subtext

	--[[
		Replaces the subtitle.
	]]
	function handle.SetSubtext(text: string)
		subtitle.Text = text
		subtitle.Visible = true
	end

	--[[ Returning ]]

	return handle
end

return Module
