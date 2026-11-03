--[[
	Created By: 	Nari
]]

local _localName: string = "Input"

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

--- @class UmeGui_Controls_Input
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "string|number?",
		Placeholder = "string?",
		Numeric = "boolean?",
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

	local value: string = if node.Value ~= nil then tostring(node.Value) else ""

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(root, "Vertical", style.Gap)

	-- Label
	local title = ctx.FieldTitle(node.Label or "", style.LabelFont, style.LabelSize, style.LabelColor) --- @type UmeGui_FieldTitle
	title.Row.LayoutOrder = 0
	title.Row.Visible = node.Label ~= nil
	title.Row.Parent = root

	-- Outlined box
	local box = ctx.Surface(UDim2.new(1, 0, 0, ctx.Number("Size", style.Height))) --- @type UmeGui_Surface
	box.Root.Name = "Box"
	box.Root.LayoutOrder = 1
	box.Root.Parent = root
	ctx.Corner(box.Background, style.Radius)
	ctx.Padding(box.Content, "None", style.PaddingX)
	local stroke: UIStroke = ctx.Stroke(box.Background, style.Stroke, style.StrokeThickness)

	local field: TextBox = ctx.Create("TextBox", {
		Name = "Field",
		AnchorPoint = Vector2.new(0.5, 0.5),
		PlaceholderText = node.Placeholder or "",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Text = value,
		Parent = box.Content,
	})
	ctx.Typography(field, style.Font, style.TextSize, true)
	ctx.Color(field, "TextColor3", style.Text)

	-- Icon on the left; the field takes the rest of the box
	if node.Icon then
		local iconSize: number = ctx.Number("TextSize", style.IconSize)
		local icon: ImageLabel = ctx.Glyph(node.Icon, iconSize, style.Icon)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.fromScale(0, 0.5)
		icon.Parent = box.Content

		local inset: number = iconSize + ctx.Number("Spacing", style.IconGap)
		field.AnchorPoint = Vector2.new(1, 0.5)
		field.Position = UDim2.fromScale(1, 0.5)
		field.Size = UDim2.new(1, -inset, field.Size.Y.Scale, field.Size.Y.Offset)
	end
	ctx.Color(field, "PlaceholderColor3", style.Placeholder)

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = box.Background, Property = "BackgroundColor3" },
		Stroke = { Instance = stroke, Property = "Color" },
	}, style)

	--[[ Handle ]]

	local handle = { Instance = root, Field = field, Changed = ctx.Signal.new(), Restore = title.Restore } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Replaces the text without firing Changed.
	]]
	function handle.Set(newValue: string | number)
		--[[ Applying ]]

		value = tostring(newValue)
		field.Text = value
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the text, or the number for numeric fields.
	]]
	--- @return string | number
	function handle.Get()
		return if node.Numeric then tonumber(value) or 0 else value
	end

	--[[ Connections ]]

	if ctx.Interactive then
		ctx.Connect(field.Focused, function()
			states.Set("Selected", true)
		end)
		ctx.Connect(field.FocusLost, function()
			--[[ Focus ]]

			states.Set("Selected", false)

			-- Bring the last value back when a numeric field gets something else
			if node.Numeric and not tonumber(field.Text) then
				field.Text = value
				return
			end

			-- Skip when nothing changed
			if field.Text == value then
				return
			end

			--[[ Applying ]]

			value = field.Text
			handle.Changed:Fire(handle.Get())
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
