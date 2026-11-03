--[[
	Created By: 	Nari
]]

local _localName: string = "Dropdown"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Rows shown before the menu scrolls
local MAX_VISIBLE_ITEMS: number = 8

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

--- @class UmeGui_Controls_Dropdown
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Options = "table",
		Value = "string?",
		Placeholder = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local options = table.clone(node.Options) --- @type { string }
	local value: string? = node.Value
	local display: string? = nil
	local itemActions = {} --- @type { [string]: { any } }
	local height: number = ctx.Number("Size", style.Height)

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

	-- Box
	local parts = ctx.Pressable(UDim2.new(1, 0, 0, height), "") --- @type UmeGui_Pressable
	local box: ImageButton = parts.Button
	parts.Container.Name = "Box"
	parts.Container.LayoutOrder = 1
	parts.Container.Parent = root
	ctx.Corner(parts.Background, style.Radius)
	ctx.Padding(parts.Content, "None", style.PaddingX)
	local stroke: UIStroke = ctx.Stroke(parts.Background, style.Stroke, style.StrokeThickness)

	-- The value reads left to right and leaves room for the chevron
	local valueText: TextLabel = parts.Text
	ctx.Typography(valueText, style.Font, style.TextSize, true)
	valueText.TextXAlignment = Enum.TextXAlignment.Left
	ctx.Create("UIPadding", { PaddingRight = UDim.new(0, 20), Parent = valueText })

	-- Chevron drawn from two bars, so it does not depend on a font having the glyph
	local arrow: Frame = ctx.Create("Frame", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(10, 6),
		Parent = parts.Content,
	})
	for _index: number, side: number in ipairs({ -1, 1 }) do
		local bar: Frame = ctx.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			Position = UDim2.new(0.5, side * 2, 0.5, 0),
			Rotation = side * -45,
			Size = UDim2.fromOffset(6, ctx.Number("Stroke", style.ArrowThickness)),
			Parent = arrow,
		})
		ctx.Color(bar, "BackgroundColor3", style.Arrow)
	end

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
		Stroke = { Instance = stroke, Property = "Color" },
	}, style)
	ctx.Hover(box, states)

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Shows the selected option, or the placeholder in a dim color.
	]]
	local function paint()
		valueText.Text = display or value or node.Placeholder or "Select"
		valueText.TextColor3 = ctx.ResolveColor(if value then style.Text else style.Placeholder)
	end

	--[[ Theme ]]

	paint()
	ctx.Refresh(paint)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = root,
		Changed = ctx.Signal.new(),
		ItemAction = ctx.Signal.new(),
		Restore = title.Restore,
	}

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Display

	--[[
		Shows this text in the box instead of the selected option (rich text allowed), or the option again with nil.
	]]
	function handle.SetDisplay(text: string?)
		display = text
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Item Actions

	--[[
		Gives options their right-click actions, by option name; options left out have none.
	]]
	--- @param actions { [string]: { any } }
	function handle.SetItemActions(actions)
		itemActions = table.clone(actions)
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Selects an option (nil clears it) without firing Changed.
	]]
	function handle.Set(option: string?)
		value = option
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the selected option.
	]]
	--- @return string?
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Set Options

	--[[
		Replaces the options, clearing the selection when it is no longer listed.
	]]
	--- @param newOptions { string }
	function handle.SetOptions(newOptions)
		--[[ Applying ]]

		options = table.clone(newOptions)
		if value and not table.find(options, value) then
			handle.Set(nil)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Open

	--[[
		Opens the option menu below the box, or above it when it does not fit below; it always stays a margin inside the
		gui and scrolls when taller than that. Picking an option sets it and fires Changed.
	]]
	local function open()
		--[[ Local Variables ]]

		local itemHeight: number = ctx.Number("Size", style.ItemHeight)
		local padding: number = ctx.Number("Spacing", style.MenuPadding)
		local margin: number = ctx.Number("Spacing", style.MenuMargin)
		local gap: number = ctx.Number("Spacing", style.MenuGap)
		local menuHeight: number = math.min(#options, MAX_VISIBLE_ITEMS) * itemHeight + padding * 2
		local overlay: ImageButton

		--%%%%%%%%%%%%%%%%%%%% Close

		--[[
			Removes the menu, and a context menu open on it.
		]]
		local function close()
			overlay:Destroy()
		end

		--%%%%%%%%%%%%%%%%%%%% Open Context

		--[[
			Opens an option's right-click actions at the pointer, over the list. Picking one closes both menus and fires
			ItemAction; a click anywhere else closes only the context menu.
		]]
		local function openContext(option: string)
			--[[ Checks ]]

			local actions = itemActions[option] --- @type { any }?

			-- Options without actions have no context menu
			if not actions or #actions == 0 then
				return
			end

			--[[ Opening ]]

			ctx.ContextMenu(actions, function(actionId: string)
				close()
				handle.ItemAction:Fire(option, actionId)
			end)
		end

		--[[ Overlay ]]

		overlay = ctx.Overlay(close)

		--[[ Menu ]]

		local offset: Vector2 = box.AbsolutePosition - overlay.AbsolutePosition
		local bounds: number = overlay.AbsoluteSize.Y
		menuHeight = math.min(menuHeight, bounds - margin * 2)

		-- Below the box when it fits, else above it, else as low as the margin allows
		local menuY: number = offset.Y + height + gap
		if menuY + menuHeight > bounds - margin then
			local above: number = offset.Y - gap - menuHeight
			menuY = if above >= margin then above else math.max(margin, bounds - margin - menuHeight)
		end

		local menu: ScrollingFrame = ctx.Create("ScrollingFrame", {
			Name = "Menu",
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = ctx.ResolveColor(style.MenuFill),
			BackgroundTransparency = 0,
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(offset.X, menuY),
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.fromOffset(box.AbsoluteSize.X, menuHeight),
			Parent = overlay,
		})
		menu.ScrollBarImageColor3 = ctx.ResolveColor(style.MenuStroke)
		ctx.Corner(menu, style.Radius)
		ctx.Padding(menu, style.MenuPadding)
		ctx.Create("UIListLayout", { Parent = menu })
		ctx.Create("UIStroke", {
			Color = ctx.ResolveColor(style.MenuStroke),
			Thickness = ctx.Number("Stroke", style.StrokeThickness),
			Parent = menu,
		})

		--[[ Items ]]

		for index: number, option: string in ipairs(options) do
			local item = ctx.Pressable(UDim2.new(1, 0, 0, itemHeight), option) --- @type UmeGui_Pressable
			item.Container.Name = option
			item.Container.LayoutOrder = index
			item.Container.Parent = menu
			item.Background.BackgroundColor3 = ctx.ResolveColor(style.ItemHover)
			item.Background.BackgroundTransparency = 1
			ctx.Typography(item.Text, if option == value then style.SelectedFont else style.Font, style.TextSize, true)
			item.Text.TextColor3 = ctx.ResolveColor(if option == value then style.Text else style.ItemText)
			item.Text.TextXAlignment = Enum.TextXAlignment.Left
			ctx.Corner(item.Background, "Small")
			ctx.Padding(item.Content, "None", style.PaddingX)

			item.Button.MouseEnter:Connect(function()
				item.Background.BackgroundTransparency = 0
			end)
			item.Button.MouseLeave:Connect(function()
				item.Background.BackgroundTransparency = 1
			end)
			item.Button.Activated:Connect(function()
				close()
				handle.Set(option)
				handle.Changed:Fire(option)
			end)
			item.Button.MouseButton2Click:Connect(function()
				openContext(option)
			end)
		end
	end

	--[[ Connections ]]

	if ctx.Interactive then
		ctx.Connect(box.Activated, open)
	end

	--[[ Returning ]]

	return handle
end

return Module
