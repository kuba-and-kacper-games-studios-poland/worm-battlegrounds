--[[
	Created By: 	Nari
]]

local _localName: string = "Card"

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

--- @class UmeGui_Controls_Card
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Caption = "string?",
		Text = "string?",
		Status = "string?",
		StatusTone = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local statusTone: any = node.StatusTone or style.Status

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	local card: Frame = surface.Content
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(surface.Background, style.Radius)
	ctx.Stroke(surface.Background, style.Stroke, style.StrokeThickness)
	ctx.Padding(card, style.Padding)
	ctx.List(card, "Vertical", style.Gap)

	-- Caption
	local caption: TextLabel = ctx.Create("TextLabel", {
		Name = "Caption",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = -2,
		Size = UDim2.fromScale(1, 0),
		Text = string.upper(node.Caption or ""),
		Visible = node.Caption ~= nil,
		Parent = card,
	})
	ctx.Text(caption, style.CaptionFont, style.CaptionSize, style.Caption)

	-- Value line
	local row: Frame = ctx.Create("Frame", {
		Name = "Row",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = -1,
		Size = UDim2.fromScale(1, 0),
		Visible = node.Text ~= nil or node.Status ~= nil,
		Parent = card,
	})
	ctx.List(row, "Horizontal", style.Gap)

	local text: TextLabel = ctx.Create("TextLabel", {
		Name = "Text",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 0),
		Text = node.Text or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	ctx.Text(text, style.Font, style.TextSize, style.Text)
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = text })

	local status: TextLabel = ctx.Create("TextLabel", {
		Name = "Status",
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 1,
		Text = node.Status or "",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	ctx.Typography(status, style.StatusFont, style.StatusSize)

	--%%%%%%%%%%%%%%%%%%%% Paint Status

	--[[
		Colors the status with its current tone.
	]]
	local function paintStatus()
		status.TextColor3 = ctx.ResolveColor(statusTone)
	end

	--[[ Theme ]]

	paintStatus()
	ctx.Refresh(paintStatus)

	--[[ Handle ]]

	local handle = { Instance = surface.Root, Slot = card } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Caption

	--[[
		Replaces the caption.
	]]
	function handle.SetCaption(value: string)
		caption.Text = string.upper(value)
		caption.Visible = true
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the value line.
	]]
	function handle.SetText(value: string)
		text.Text = value
		row.Visible = true
	end

	--%%%%%%%%%%%%%%%%%%%% Set Status

	--[[
		Replaces the status, optionally recolored with a palette token ("Success", "Danger", …).
	]]
	function handle.SetStatus(value: string, tone: string?)
		--[[ Applying ]]

		status.Text = value
		statusTone = tone or style.Status
		row.Visible = true
		paintStatus()
	end

	--[[ Returning ]]

	return handle
end

return Module
