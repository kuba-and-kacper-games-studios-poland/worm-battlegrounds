--[[
	Created By: 	Nari
]]

local _localName: string = "CheckItem"

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

--- @class UmeGui_Controls_CheckItem
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Text = "string",
		Value = "string?",
		Expanded = "boolean?",
		Disabled = "boolean?",
		Muted = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Marks ]]

-- Icon drawn in the box per value
--- @type { [string]: string }
local MARKS = {
	None = "",
	Partial = "minus",
	Checked = "check",
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local value: string = if node.Value and MARKS[node.Value] then node.Value else "None"
	local expanded: boolean = node.Expanded == true
	local muted: boolean = node.Muted == true
	local menu = {} --- @type { any }
	local height: number = ctx.Number("Size", style.Height)
	local boxSize: number = ctx.Number("Size", style.BoxSize)
	local chevronSize: number = ctx.Number("TextSize", style.ChevronSize)
	local iconSize: number = ctx.Number("TextSize", style.IconSize)

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	ctx.Corner(surface.Background, style.Radius)
	ctx.List(surface.Content, "Vertical", "None")

	-- Row: clicking it expands the item
	local row = ctx.Pressable(UDim2.new(1, 0, 0, height)) --- @type UmeGui_Pressable
	row.Container.Name = "Row"
	row.Container.LayoutOrder = 0
	row.Container.Parent = surface.Content
	row.Background.BackgroundTransparency = 1
	ctx.Padding(row.Content, "None", style.PaddingX)
	local rowList: UIListLayout = ctx.List(row.Content, "Horizontal", style.Gap)
	rowList.VerticalAlignment = Enum.VerticalAlignment.Center

	-- Checkbox, its own button over the row
	local box = ctx.Pressable(UDim2.fromOffset(boxSize, boxSize)) --- @type UmeGui_Pressable
	box.Container.Name = "Check"
	box.Container.LayoutOrder = 0
	box.Container.Parent = row.Content
	ctx.Corner(box.Background, style.BoxRadius)
	local boxStroke: UIStroke = ctx.Stroke(box.Background, style.BoxStroke, style.StrokeThickness)
	local mark: ImageLabel = ctx.Glyph(MARKS[value], ctx.Number("TextSize", style.MarkSize), nil)
	mark.Name = "Mark"
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Parent = box.Content

	-- Optional image before the title (a class icon), shown by SetIcon
	local icon: ImageLabel = ctx.Create("ImageLabel", {
		Name = "Icon",
		LayoutOrder = 1,
		Size = UDim2.fromOffset(iconSize, iconSize),
		Visible = false,
		Parent = row.Content,
	})

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		LayoutOrder = 2,
		Size = UDim2.fromScale(0, 1),
		Text = node.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row.Content,
	})
	ctx.Typography(title, style.Font, style.TextSize)
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = title })

	-- Points down while expanded, right while collapsed (a glyph swap: rotation is not drawn inside a clipping Scroll)
	local chevron: ImageLabel = ctx.Glyph(if expanded then "chevron-small-down" else "chevron-small-right", chevronSize, style.Chevron)
	chevron.Name = "Chevron"
	chevron.LayoutOrder = 3
	chevron.Visible = style.ShowChevron
	chevron.Parent = row.Content

	-- Details, lined up with the title
	local details: Frame = ctx.Create("Frame", {
		Name = "Details",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Visible = expanded,
		Parent = surface.Content,
	})
	ctx.List(details, "Vertical", style.DetailsGap)
	local detailsPadding: UIPadding = ctx.Padding(details, "None", style.PaddingX)
	detailsPadding.PaddingLeft = UDim.new(0, detailsPadding.PaddingLeft.Offset + boxSize + ctx.Number("Spacing", style.Gap))
	detailsPadding.PaddingBottom = UDim.new(0, ctx.Number("Spacing", style.DetailsPaddingBottom))

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = surface.Background, Property = "BackgroundColor3" },
		FillTransparency = { Instance = surface.Background, Property = "BackgroundTransparency" },
		BoxFill = { Instance = box.Background, Property = "BackgroundColor3" },
		BoxStroke = { Instance = boxStroke, Property = "Color" },
		Mark = { Instance = mark, Property = "ImageColor3" },
	}, style)
	states.Set("Selected", value == "Checked")
	states.Set("Disabled", node.Disabled == true)
	states.Refresh(true)
	ctx.Hover(row.Button, states)

	--%%%%%%%%%%%%%%%%%%%% Paint Title

	--[[
		Colors the title and fades the icon, dimmed while muted.
	]]
	local function paintTitle()
		title.TextColor3 = ctx.ResolveColor(if muted then style.MutedText else style.Text)
		icon.ImageTransparency = if muted then style.MutedIconTransparency else 0
	end

	--[[ Theme ]]

	paintTitle()
	ctx.Refresh(paintTitle)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = surface.Root,
		Slot = details,
		CheckClicked = ctx.Signal.new(),
		ExpandToggled = ctx.Signal.new(),
		MenuAction = ctx.Signal.new(),
	}

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Shows a checkbox value ("None", "Partial" or "Checked") without firing anything.
	]]
	function handle.Set(newValue: string)
		--[[ Applying ]]

		value = if MARKS[newValue] then newValue else "None"
		mark.Image = ctx.Icon(MARKS[value])
		states.Set("Selected", value == "Checked")
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the checkbox value.
	]]
	--- @return string
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Set Disabled

	--[[
		Greys the checkbox out and stops it firing CheckClicked; the row still expands.
	]]
	function handle.SetDisabled(disabled: boolean)
		states.Set("Disabled", disabled)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Expanded

	--[[
		Shows or hides the children without firing ExpandToggled.
	]]
	function handle.SetExpanded(isExpanded: boolean)
		--[[ Applying ]]

		expanded = isExpanded
		details.Visible = expanded
		chevron.Image = ctx.Icon(if expanded then "chevron-small-down" else "chevron-small-right")
	end

	--%%%%%%%%%%%%%%%%%%%% Set Muted

	--[[
		Dims the title, for items that are hidden or out of use.
	]]
	function handle.SetMuted(isMuted: boolean)
		--[[ Applying ]]

		muted = isMuted
		paintTitle()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the title.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Icon

	--[[
		Shows an image before the title, optionally a sprite from a sheet (`rectOffset`, `rectSize`), or hides it with
		nil.
	]]
	function handle.SetIcon(image: string?, rectOffset: Vector2?, rectSize: Vector2?)
		--[[ Applying ]]

		icon.Image = image or ""
		icon.ImageRectOffset = rectOffset or Vector2.zero
		icon.ImageRectSize = rectSize or Vector2.zero
		icon.Visible = image ~= nil
	end

	--%%%%%%%%%%%%%%%%%%%% Set Menu

	--[[
		Sets the actions a right click offers (none hides the menu). An action is a name or
		`{ Id, Text?, Icon?, Danger? }`.
	]]
	--- @param actions { any }
	function handle.SetMenu(actions)
		menu = table.clone(actions)
	end

	--%%%%%%%%%%%%%%%%%%%% Open Menu

	--[[
		Opens the right-click actions at the pointer.
	]]
	local function openMenu()
		--[[ Checks ]]

		-- Items without actions have no menu
		if #menu == 0 then
			return
		end

		--[[ Opening ]]

		ctx.ContextMenu(menu, function(actionId: string)
			handle.MenuAction:Fire(actionId)
		end)
	end

	--[[ Connections ]]

	if ctx.Interactive then
		ctx.Connect(box.Button.Activated, function()
			-- Ignore clicks while disabled
			if states.IsActive("Disabled") then
				return
			end

			handle.CheckClicked:Fire()
		end)
		ctx.Connect(row.Button.Activated, function()
			handle.SetExpanded(not expanded)
			handle.ExpandToggled:Fire(expanded)
		end)
		ctx.Connect(row.Button.MouseButton2Click, openMenu)
		ctx.Connect(box.Button.MouseButton2Click, openMenu)
	end

	--[[ Returning ]]

	return handle
end

return Module
