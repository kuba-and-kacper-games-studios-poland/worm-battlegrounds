--[[
	Created By: 	Nari
]]

local _localName: string = "VectorInput"

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

--- @class UmeGui_Controls_VectorInput
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "Vector3?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local value: Vector3 = node.Value or Vector3.zero
	local fields = {} --- @type { [string]: UmeGui_Handle }

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(root, "Vertical", style.Gap)

	local title = ctx.FieldTitle(node.Label or "", style.LabelFont, style.LabelSize, style.LabelColor) --- @type UmeGui_FieldTitle
	title.Row.LayoutOrder = 0
	title.Row.Visible = node.Label ~= nil
	title.Row.Parent = root

	local row = ctx.Build({ Control = "Stack", Direction = "Horizontal", Fill = true, Style = style.RowStyle }, root) --- @type UmeGui_Handle
	row.Instance.Name = "Fields"
	row.Instance.LayoutOrder = 1

	for index: number, axis: string in ipairs({ "X", "Y", "Z" }) do
		local fieldNode = { Control = "Input", Value = value[axis], Numeric = true, Placeholder = axis } --- @type UmeGui_Node
		local field = ctx.Build(fieldNode) --- @type UmeGui_Handle
		field.Instance.Name = axis
		field.Instance.LayoutOrder = index
		row.AddChild(field, fieldNode)
		fields[axis] = field
	end

	--[[ Handle ]]

	local handle = { Instance = root, Changed = ctx.Signal.new(), Restore = title.Restore } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Sets the vector without firing Changed.
	]]
	function handle.Set(newValue: Vector3)
		--[[ Applying ]]

		value = newValue
		fields.X.Set(newValue.X)
		fields.Y.Set(newValue.Y)
		fields.Z.Set(newValue.Z)
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the vector.
	]]
	--- @return Vector3
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--[[ Connections ]]

	--- @param field UmeGui_Handle
	for _axis: string, field in pairs(fields) do
		ctx.Connect(field.Changed, function()
			value = Vector3.new(fields.X.Get(), fields.Y.Get(), fields.Z.Get())
			handle.Changed:Fire(value)
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
