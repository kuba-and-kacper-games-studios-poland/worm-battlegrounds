--[[
	Created By: 	Nari
]]

local _localName: string = "Stack"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Stack
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Direction = "string?",
		Align = "string?",
		Fill = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local horizontal: boolean = node.Direction == "Horizontal"
	local alignment: string = if node.Align == "Center" then "Center" elseif node.Align == "End" then "Right" else "Left"

	--[[ Building ]]

	local frame: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.Padding(frame, style.PaddingY, style.PaddingX)
	local list: UIListLayout = ctx.List(frame, if horizontal then "Horizontal" else "Vertical", style.Gap)
	list.HorizontalAlignment = Enum.HorizontalAlignment[alignment]
	if horizontal and node.Fill then
		list.HorizontalFlex = Enum.UIFlexAlignment.Fill
	end

	--[[ Handle ]]

	local handle = { Instance = frame, Slot = frame } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Add Child

	--[[
		Places a child as the shared Stack does, except that a text in a row is as wide as it measures: AutomaticSize
		measures in screen pixels under a panel's S_ScreenScale.
	]]
	--- @param child UmeGui_Handle
	--- @param childNode UmeGui_Node
	function handle.AddChild(child, childNode)
		--[[ Local Variables ]]

		local instance: GuiObject = child.Instance
		local size: UDim2 = instance.Size

		--[[ Sizing ]]

		-- A row hands out width by flex share, by measured text, or by content
		if horizontal and (node.Fill or childNode.Grow) then
			instance.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
		elseif horizontal and size.X.Scale > 0 and instance:IsA("TextLabel") then
			instance.Size = UDim2.new(0, ctx.MeasureText(instance), size.Y.Scale, size.Y.Offset)
		elseif horizontal and size.X.Scale > 0 then
			instance.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
			instance.AutomaticSize = if instance.AutomaticSize == Enum.AutomaticSize.Y then Enum.AutomaticSize.XY else Enum.AutomaticSize.X
		end

		--[[ Parenting ]]

		instance.Parent = frame
	end

	--[[ Returning ]]

	return handle
end

return Module
