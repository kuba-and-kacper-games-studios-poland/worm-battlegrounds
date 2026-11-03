--[[
	Created By: 	Nari
]]

local _localName: string = "Tile"

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

--- @class UmeGui_Controls_Tile
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Subtext = "string?",
		LeftActions = "table?",
		RightActions = "table?",
		Selected = "boolean?",
		AspectRatio = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local padding: number = ctx.Number("Spacing", style.Padding)
	local aspectRatio: number = node.AspectRatio or 1
	local menu = {} --- @type { any }

	--[[ Building ]]

	local parts = ctx.Pressable(UDim2.fromScale(1, 0)) --- @type UmeGui_Pressable
	ctx.Corner(parts.Background, style.Radius)
	ctx.Color(parts.Background, "BackgroundColor3", style.Fill)
	local stroke: UIStroke = ctx.Stroke(parts.Background, style.Stroke, style.StrokeThickness)

	-- Preview above the caption, rounded on its own: a ViewportFrame inside a CanvasGroup is not redrawn when a hidden
	-- ancestor (another tab's page) is shown again. Its rounded bottom reaches under the caption.
	local viewport: ViewportFrame = ctx.Create("ViewportFrame", {
		Name = "Viewport",
		Size = UDim2.fromScale(1, 1),
		Parent = parts.Content,
	})
	ctx.Corner(viewport, style.Radius)
	local camera: Camera = ctx.Create("Camera", { Parent = viewport })
	viewport.CurrentCamera = camera

	-- The caption is clipped to the same rounded corners as the Background
	local clip: CanvasGroup = ctx.Create("CanvasGroup", {
		Name = "Clip",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = parts.Content,
	})
	ctx.Corner(clip, style.Radius)
	ctx.List(clip, "Vertical", "None").VerticalAlignment = Enum.VerticalAlignment.Bottom

	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = clip,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	-- Caption strip under the preview
	local caption: Frame = ctx.Create("Frame", {
		Name = "Caption",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Parent = clip,
	})
	ctx.Color(caption, "BackgroundColor3", style.CaptionFill)
	ctx.Padding(caption, style.CaptionPadding, style.Padding)
	ctx.List(caption, "Vertical", "None")

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Text = node.Text,
		Parent = caption,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)

	local subtitle: TextLabel = ctx.Create("TextLabel", {
		Name = "Subtext",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Text = node.Subtext or "",
		Visible = node.Subtext ~= nil,
		Parent = caption,
	})
	ctx.Text(subtitle, style.SubFont, style.SubSize, style.Subtext)

	--%%%%%%%%%%%%%%%%%%%% Fit

	--[[
		Makes the tile as tall as its preview's aspect ratio plus the caption, and ends the preview one corner radius
		below the top of the caption, so its rounded bottom stays hidden.
	]]
	local function fit()
		--[[ Local Variables ]]

		local chrome: number = caption.AbsoluteSize.Y + divider.AbsoluteSize.Y
		local size: UDim2 = parts.Container.Size

		--[[ Applying ]]

		parts.Container.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, math.round(parts.Container.AbsoluteSize.X / aspectRatio + chrome))
		viewport.Size = UDim2.new(1, 0, 1, -math.max(chrome - ctx.Number("Radius", style.Radius), 0))
	end

	fit()
	ctx.Connect(caption:GetPropertyChangedSignal("AbsoluteSize"), fit)
	ctx.Connect(parts.Container:GetPropertyChangedSignal("AbsoluteSize"), fit)

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Stroke = { Instance = stroke, Property = "Color" },
	}, style)
	states.Set("Selected", node.Selected == true)
	ctx.Hover(parts.Button, states)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = parts.Container,
		Button = parts.Button,
		Viewport = viewport,
		Camera = camera,
		Clicked = ctx.Signal.new(),
		Action = ctx.Signal.new(),
		MenuAction = ctx.Signal.new(),
	}

	--[[ Actions ]]

	--- @param side { [number]: any }
	for _index: number, side in ipairs({ { node.LeftActions, 0 }, { node.RightActions, 1 } }) do
		-- Skip a corner without actions
		if not side[1] then
			continue
		end

		local group: Frame = ctx.Create("Frame", {
			Name = if side[2] == 0 then "LeftActions" else "RightActions",
			AnchorPoint = Vector2.new(side[2], 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Position = UDim2.new(side[2], if side[2] == 0 then padding else -padding, 0, padding),
			ZIndex = 3,
			Parent = parts.Content,
		})
		ctx.List(group, "Horizontal", style.ActionGap)

		for order: number, action: any in ipairs(side[1]) do
			local actionId: string = if type(action) == "table" then action.Id else action
			local icon: string = if type(action) == "table" then action.Icon else action
			local button = ctx.Build({ Control = "IconButton", Icon = icon, Style = style.ActionStyle }, group) --- @type UmeGui_Handle
			button.Instance.Name = actionId
			button.Instance.LayoutOrder = order
			ctx.Connect(button.Clicked, function()
				handle.Action:Fire(actionId)
			end)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the caption title.
	]]
	function handle.SetText(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Subtext

	--[[
		Replaces the caption subtitle.
	]]
	function handle.SetSubtext(text: string)
		subtitle.Text = text
		subtitle.Visible = true
	end

	--%%%%%%%%%%%%%%%%%%%% Set Aspect Ratio

	--[[
		Reshapes the preview to a width / height ratio.
	]]
	function handle.SetAspectRatio(ratio: number)
		--[[ Applying ]]

		aspectRatio = ratio
		fit()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Outlines the tile as the active one.
	]]
	function handle.SetSelected(selected: boolean)
		states.Set("Selected", selected)
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

	--[[ Connections ]]

	ctx.Connect(parts.Button.Activated, function()
		handle.Clicked:Fire()
	end)

	-- Tiles without actions have no menu
	if ctx.Interactive then
		ctx.Connect(parts.Button.MouseButton2Click, function()
			if #menu > 0 then
				ctx.ContextMenu(menu, function(actionId: string)
					handle.MenuAction:Fire(actionId)
				end)
			end
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
