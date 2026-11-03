--[[
	Created By: 	Nari
]]

local _localName: string = "Dialog"

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

--- @class UmeGui_Controls_Dialog
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Title = "string",
		Text = "string?",
		Input = "string?",
		Placeholder = "string?",
		ConfirmText = "string?",
		CancelText = "string?",
		Danger = "boolean?",
		Dismissible = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local margin: number = ctx.Number("Spacing", style.Margin)
	local dismissible: boolean = node.Dismissible ~= false

	--[[ Building ]]

	-- Backdrop: an input-blocking button over the whole gui
	local root: ImageButton = ctx.Create("ImageButton", {
		Active = true,
		BackgroundTransparency = style.BackdropTransparency,
		Interactable = true,
		ImageTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = style.ZIndex,
	})
	ctx.Color(root, "BackgroundColor3", style.Backdrop)

	-- Card, centred
	local card = ctx.Surface(UDim2.new(1, -margin * 2, 0, 0), true) --- @type UmeGui_Surface
	card.Root.Name = "Card"
	card.Root.Active = true
	card.Root.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Root.Position = UDim2.fromScale(0.5, 0.5)
	card.Root.Parent = root
	ctx.Create("UISizeConstraint", { MaxSize = Vector2.new(ctx.Number("Size", style.MaxWidth), math.huge), Parent = card.Root })
	ctx.Color(card.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(card.Background, style.Radius)
	ctx.Stroke(card.Background, style.Stroke, style.StrokeThickness)

	-- Soft shadow under the card
	local shadow: UIShadow = ctx.Create("UIShadow", {
		BlurRadius = UDim.new(0, style.ShadowBlur),
		Offset = UDim2.fromOffset(0, style.ShadowOffset),
		Transparency = style.ShadowTransparency,
		Parent = card.Background,
	})
	ctx.Color(shadow, "Color", style.Shadow)
	ctx.Padding(card.Content, style.Padding)
	ctx.List(card.Content, "Vertical", style.Gap)

	local title = ctx.Build({ Control = "Label", Text = node.Title, Style = style.TitleStyle }, card.Content) --- @type UmeGui_Handle
	title.Instance.LayoutOrder = 0

	local message = ctx.Build({ Control = "Label", Text = node.Text or "", Style = style.TextStyle }, card.Content) --- @type UmeGui_Handle
	message.Instance.LayoutOrder = 1
	message.Instance.Visible = node.Text ~= nil

	-- Text field
	local input = nil --- @type UmeGui_Handle?
	if node.Input ~= nil then
		input = ctx.Build({ Control = "Input", Value = node.Input, Placeholder = node.Placeholder }, card.Content)
		input.Instance.LayoutOrder = 2
	end

	-- Children of the node
	local extra: Frame = ctx.Create("Frame", {
		Name = "Extra",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
		Size = UDim2.fromScale(1, 0),
		Visible = node.Children ~= nil,
		Parent = card.Content,
	})
	ctx.List(extra, "Vertical", style.Gap)

	local errorText = ctx.Build({ Control = "Label", Text = "", Style = style.ErrorStyle }, card.Content) --- @type UmeGui_Handle
	errorText.Instance.LayoutOrder = 4
	errorText.Instance.Visible = false

	-- Buttons in the bottom right: Cancel, then the confirm button
	local row = ctx.Build({ Control = "Stack", Direction = "Horizontal", Align = "End", Style = "Buttons" }, card.Content) --- @type UmeGui_Handle
	row.Instance.LayoutOrder = 5

	local cancelNode = { Control = "Button", Text = node.CancelText or "Cancel", AutoWidth = true, Style = style.CancelStyle } --- @type UmeGui_Node
	local cancel = ctx.Build(cancelNode) --- @type UmeGui_Handle
	cancel.Instance.Name = "Cancel"
	cancel.Instance.LayoutOrder = 0
	cancel.Instance.Visible = dismissible
	row.AddChild(cancel, cancelNode)

	local confirmNode = { --- @type UmeGui_Node
		Control = "Button",
		Text = node.ConfirmText or "OK",
		AutoWidth = true,
		Style = if node.Danger then style.DangerStyle else style.ConfirmStyle,
	}
	local confirm = ctx.Build(confirmNode) --- @type UmeGui_Handle
	confirm.Instance.Name = "Confirm"
	confirm.Instance.LayoutOrder = 1
	row.AddChild(confirm, confirmNode)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = root,
		Slot = extra,
		Field = if input then input.Field else nil,
		Confirmed = ctx.Signal.new(),
		Cancelled = ctx.Signal.new(),
	}

	--%%%%%%%%%%%%%%%%%%%% Set Error

	--[[
		Shows a problem with the answer under the field (nil hides it), keeping the dialog open.
	]]
	function handle.SetError(text: string?)
		--[[ Applying ]]

		errorText.SetText(text or "")
		errorText.Instance.Visible = text ~= nil
	end

	--%%%%%%%%%%%%%%%%%%%% Confirm

	--[[
		Fires Confirmed with the field's current text.
	]]
	local function fireConfirmed()
		handle.Confirmed:Fire(if input then input.Field.Text else nil)
	end

	--[[ Connections ]]

	if ctx.Interactive then
		ctx.Connect(confirm.Clicked, fireConfirmed)
		ctx.Connect(cancel.Clicked, function()
			handle.Cancelled:Fire()
		end)
		ctx.Connect(root.Activated, function()
			-- A dialog that must be answered stays open
			if dismissible then
				handle.Cancelled:Fire()
			end
		end)

		-- The field starts focused with its text selected; Enter confirms
		if input then
			local field: TextBox = input.Field
			ctx.Connect(field.FocusLost, function(enterPressed: boolean)
				if enterPressed then
					fireConfirmed()
				end
			end)
			task.defer(function()
				if field.Parent then
					field:CaptureFocus()
					field.SelectionStart = 1
					field.CursorPosition = #field.Text + 1
				end
			end)
		end
	end

	--[[ Returning ]]

	return handle
end

return Module
