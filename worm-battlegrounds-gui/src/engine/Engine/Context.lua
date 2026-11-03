--[[
	Created By: 	Nari
]]

local _localName: string = "Context"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Engine: Folder = script.Parent
local UmeGui: ModuleScript = Engine.Parent

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = game:GetService("RunService")
local TextService: TextService = game:GetService("TextService")
local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Primitives = require(UmeGui:FindFirstChild("Primitives")) --- @type UmeGui_Primitives
local States = require(Engine:FindFirstChild("States")) --- @type UmeGui_Engine_States
local Style = require(Engine:FindFirstChild("Style")) --- @type UmeGui_Engine_Style
local Signal = require(UmeGui:FindFirstChild("Libs"):FindFirstChild("Mirror"):FindFirstChild("GoodSignal")) --- @type UmeGui_Signal

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local OVERLAY_Z_INDEX: number = 1000

-- Box height per text size for one line of scaled text
local LINE_HEIGHT: number = 1.25

-- Running tweens per instance and property, so a newer write can cancel them
local activeTweens = setmetatable({}, { __mode = "k" }) --- @type { [Instance]: { [string]: Tween } }

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

--- @class UmeGui_Engine_Context
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Create

--- @param view UmeGui_View
--- @param scope UmeGui_Scope
--- @param buildNode (view: UmeGui_View, scope: UmeGui_Scope, node: UmeGui_Node, path: string, ids: { [string]: UmeGui_Handle }, layoutOrder: number) -> UmeGui_Handle
--- @return UmeGui_Context
function Module.Create(view, scope, buildNode)
	--[[ Context ]]

	local ctx = { --- @type UmeGui_Context
		Theme = view.Theme,
		Interactive = view.Interactive,
		Signal = Signal,
	}

	--%%%%%%%%%%%%%%%%%%%% Create

	--[[
		Creates a raw instance with its class defaults.
	]]
	--- @param props { [string]: any } | nil
	--- @return Instance
	function ctx.Create(className: string, props)
		return Primitives.Create(className, props)
	end

	--%%%%%%%%%%%%%%%%%%%% Build

	--[[
		Builds a nested node (a control inside a control) through the engine, so it gets its own theme style.
	]]
	--- @param node UmeGui_Node
	--- @return UmeGui_Handle
	function ctx.Build(node, parent: Instance?)
		--[[ Building ]]

		local handle = buildNode(view, scope, node, `(inner {node.Control or node.Primitive})`, {}, 0) --- @type UmeGui_Handle

		--[[ Parenting ]]

		if parent then
			handle.Instance.Parent = parent
		end

		--[[ Returning ]]

		return handle
	end

	--%%%%%%%%%%%%%%%%%%%% Tag

	--[[
		Adds framework component tags and their attributes, so exported guis animate in game the same way.
	]]
	--- @param tags { [string]: { [string]: any } } | nil
	function ctx.Tag(instance: Instance, tags)
		--- @param attributes { [string]: any }
		for tag: string, attributes in pairs(tags or {}) do
			instance:AddTag(tag)
			for attributeName: string, value: any in pairs(attributes) do
				instance:SetAttribute(attributeName, value)
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Resolve Color

	--[[
		Returns the Color3 for a palette token in the view's current mode.
	]]
	--- @return Color3
	function ctx.ResolveColor(value: any)
		return Style.Color(view.Theme, view.Mode, view.Tokens, value)
	end

	--%%%%%%%%%%%%%%%%%%%% Color

	--[[
		Sets a color property from a token and keeps it in sync when the mode or a token changes.
	]]
	function ctx.Color(instance: Instance, property: string, value: any)
		--%%%%%%%%%%%%%%%%%%%% Apply

		--[[
			Writes the token's current color.
		]]
		local function apply()
			instance[property] = ctx.ResolveColor(value)
		end

		--[[ Applying ]]

		apply()
		table.insert(scope.Refreshers, apply)
	end

	--%%%%%%%%%%%%%%%%%%%% Number

	--[[
		Returns a number token from a group (`Size`, `Radius`, `Spacing`, `TextSize`, `Stroke`, `Motion`).
	]]
	--- @return number
	function ctx.Number(group: string, value: any)
		return Style.Number(view.Theme, group, value)
	end

	--%%%%%%%%%%%%%%%%%%%% Font

	--[[
		Returns a Font from a font token.
	]]
	--- @return Font
	function ctx.Font(value: any)
		return Style.Font(view.Theme, value)
	end

	--%%%%%%%%%%%%%%%%%%%% Icon

	--[[
		Returns the image for an icon name from the theme's Icons (an image id passes through; nil or "" is none).
	]]
	--- @return string
	function ctx.Icon(value: string?)
		return Style.Icon(view.Theme, value)
	end

	--%%%%%%%%%%%%%%%%%%%% Glyph

	--[[
		Creates an icon: a square ImageLabel `size` px wide showing an icon name's image, tinted with a color token
		(kept in sync with the mode) when `color` is given. Swap the icon later with `glyph.Image = ctx.Icon(name)`.
	]]
	--- @return ImageLabel
	function ctx.Glyph(name: string?, size: number, color: any)
		--[[ Building ]]

		local glyph: ImageLabel = Primitives.Create("ImageLabel", {
			Name = "Icon",
			Image = ctx.Icon(name),
			Size = UDim2.fromOffset(size, size),
		})

		--[[ Theme ]]

		if color ~= nil then
			ctx.Color(glyph, "ImageColor3", color)
		end

		--[[ Returning ]]

		return glyph
	end

	--%%%%%%%%%%%%%%%%%%%% Typography

	--[[
		Applies font and size tokens to a text instance the one way the gui rules allow: TextScaled and RichText on,
		with a UITextSizeConstraint capping the scaled text at the token size, so it renders at that size and only
		shrinks when its box is too small. `lineHeight` sets the box height to one line (button texts).
	]]
	function ctx.Typography(instance: TextLabel, font: any, textSize: any, lineHeight: boolean?)
		--[[ Local Variables ]]

		local size: number = ctx.Number("TextSize", textSize)
		local constraint: UITextSizeConstraint? = instance:FindFirstChildOfClass("UITextSizeConstraint")

		--[[ Applying ]]

		instance.FontFace = ctx.Font(font)
		instance.TextSize = size
		instance.TextScaled = true
		instance.RichText = true

		-- Cap the scaled text at the token size
		if not constraint then
			constraint = Primitives.Create("UITextSizeConstraint", { Parent = instance })
		end
		constraint.MaxTextSize = size

		-- One line tall, centered by the text's own anchor
		if lineHeight then
			instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, 0, math.ceil(size * LINE_HEIGHT))
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Text

	--[[
		Applies font, size and color tokens to a text instance (see Typography).
	]]
	function ctx.Text(instance: TextLabel, font: any, textSize: any, color: any)
		--[[ Applying ]]

		ctx.Typography(instance, font, textSize)
		ctx.Color(instance, "TextColor3", color)
	end

	--%%%%%%%%%%%%%%%%%%%% Corner

	--[[
		Rounds an instance with a radius token.
	]]
	--- @return UICorner
	function ctx.Corner(instance: Instance, radius: any)
		return Primitives.Create("UICorner", {
			CornerRadius = UDim.new(0, ctx.Number("Radius", radius)),
			Parent = instance,
		})
	end

	--%%%%%%%%%%%%%%%%%%%% Stroke

	--[[
		Outlines an instance with color and thickness tokens.
	]]
	--- @return UIStroke
	function ctx.Stroke(instance: Instance, color: any, thickness: any)
		--[[ Creating ]]

		local stroke: UIStroke = Primitives.Create("UIStroke", {
			Thickness = ctx.Number("Stroke", thickness),
			Parent = instance,
		})
		ctx.Color(stroke, "Color", color)

		--[[ Returning ]]

		return stroke
	end

	--%%%%%%%%%%%%%%%%%%%% Padding

	--[[
		Pads an instance with spacing tokens: `spacing` on every side, or `horizontal` on the sides when given.
	]]
	--- @return UIPadding
	function ctx.Padding(instance: Instance, spacing: any, horizontal: any?)
		--[[ Local Variables ]]

		local vertical: UDim = UDim.new(0, ctx.Number("Spacing", spacing))
		local sides: UDim = if horizontal ~= nil then UDim.new(0, ctx.Number("Spacing", horizontal)) else vertical

		--[[ Returning ]]

		return Primitives.Create("UIPadding", {
			PaddingTop = vertical,
			PaddingBottom = vertical,
			PaddingLeft = sides,
			PaddingRight = sides,
			Parent = instance,
		})
	end

	--%%%%%%%%%%%%%%%%%%%% List

	--[[
		Lays out an instance's children in a row or column with a spacing token between them.
	]]
	--- @return UIListLayout
	function ctx.List(instance: Instance, direction: string, gap: any)
		return Primitives.Create("UIListLayout", {
			FillDirection = Enum.FillDirection[direction],
			Padding = UDim.new(0, ctx.Number("Spacing", gap)),
			VerticalAlignment = if direction == "Horizontal" then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top,
			Parent = instance,
		})
	end

	--%%%%%%%%%%%%%%%%%%%% Field Title

	--[[
		Builds a field's title row: the label and a small restore button. SetModified(true) italicizes the label and
		shows the button, whose presses fire Restore; fields use it to mark a value changed from its preset or default.
		The row sizes to its content.
	]]
	--- @return UmeGui_FieldTitle
	function ctx.FieldTitle(text: string, font: any, textSize: any, color: any)
		--[[ Building ]]

		local row: Frame = Primitives.Create("Frame", {
			Name = "Title",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, ctx.Number("Size", "IconButtonSmall")),
		})
		local rowList: UIListLayout = ctx.List(row, "Horizontal", "XS")
		rowList.VerticalAlignment = Enum.VerticalAlignment.Center

		-- Optional image before the label (a class icon), shown by SetIcon
		local iconSize: number = ctx.Number("TextSize", "Symbol")
		local icon: ImageLabel = Primitives.Create("ImageLabel", {
			Name = "Icon",
			LayoutOrder = -1,
			Size = UDim2.fromOffset(iconSize, iconSize),
			Visible = false,
			Parent = row,
		})

		local label: TextLabel = Primitives.Create("TextLabel", {
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 0,
			Size = UDim2.fromScale(0, 1),
			Text = text,
			Parent = row,
		})
		ctx.Text(label, font, textSize, color)

		local restore = ctx.Build({ Control = "IconButton", Icon = "arrow-spin-counter-clockwise", Style = { "Builder", "Ghost", "Small" } }, row) --- @type UmeGui_Handle
		restore.Instance.Name = "Restore"
		restore.Instance.LayoutOrder = 1
		restore.Instance.Visible = false

		--[[ Title ]]

		local title = { Row = row, Label = label, Restore = restore.Clicked } --- @type UmeGui_FieldTitle

		--%%%%%%%%%%%%%%%%%%%% Set Modified

		--[[
			Italicizes the label and shows the restore button while the field differs from its preset or default.
		]]
		function title.SetModified(modified: boolean)
			label.Text = if modified then `<i>{text}</i>` else text
			restore.Instance.Visible = modified
		end

		--%%%%%%%%%%%%%%%%%%%% Set Icon

		--[[
			Shows an image before the label, optionally a sprite from a sheet (`rectOffset`, `rectSize`), or hides it
			with nil.
		]]
		function title.SetIcon(image: string?, rectOffset: Vector2?, rectSize: Vector2?)
			--[[ Applying ]]

			icon.Image = image or ""
			icon.ImageRectOffset = rectOffset or Vector2.zero
			icon.ImageRectSize = rectSize or Vector2.zero
			icon.Visible = image ~= nil
		end

		--[[ Returning ]]

		return title
	end

	--%%%%%%%%%%%%%%%%%%%% Pressable

	--[[
		Builds the one button structure every pressable control uses (never a TextButton):
		ButtonContainer (Frame, the layout item) > Button (invisible ImageButton, centered) > Background (ZIndex 1:
		fill, corners, strokes) + Content (ZIndex 2: ButtonText and other content). With `text`, Content gets a centered
		ButtonText. Size a button to its text with `ctx.FitWidth`, never with AutomaticSize.
	]]
	--- @return UmeGui_Pressable
	function ctx.Pressable(size: UDim2, text: string?)
		--[[ Building ]]

		local container: Frame = Primitives.Create("Frame", {
			Name = "ButtonContainer",
			Size = size,
		})

		local button: ImageButton = Primitives.Create("ImageButton", {
			Name = "Button",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "",
			ImageTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Parent = container,
		})

		local background: Frame = Primitives.Create("Frame", {
			Name = "Background",
			BackgroundTransparency = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = button,
		})

		local content: Frame = Primitives.Create("Frame", {
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = button,
		})

		--[[ Text ]]

		local buttonText: TextLabel? = nil
		if text then
			buttonText = Primitives.Create("TextLabel", {
				Name = "ButtonText",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = content,
			})
		end

		--[[ Returning ]]

		return {
			Container = container,
			Button = button,
			Background = background,
			Content = content,
			Text = buttonText,
		}
	end

	--%%%%%%%%%%%%%%%%%%%% Surface

	--[[
		Builds the structure every container with a look uses, the same split as buttons:
		root (transparent Frame, the layout item) > Background (ZIndex 1, Size 1,1: fill, corners, strokes) +
		Content (ZIndex 2: layout, padding, children). With `autoHeight`, Content grows with its children and the root
		follows it; otherwise both fill the root.
	]]
	--- @return UmeGui_Surface
	function ctx.Surface(size: UDim2, autoHeight: boolean?)
		--[[ Building ]]

		local root: Frame = Primitives.Create("Frame", {
			AutomaticSize = if autoHeight then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
			Size = size,
		})

		local background: Frame = Primitives.Create("Frame", {
			Name = "Background",
			BackgroundTransparency = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = root,
		})

		local content: Frame = Primitives.Create("Frame", {
			Name = "Content",
			AutomaticSize = if autoHeight then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
			Size = if autoHeight then UDim2.fromScale(1, 0) else UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = root,
		})

		--[[ Returning ]]

		return { Root = root, Background = background, Content = content }
	end

	--%%%%%%%%%%%%%%%%%%%% Measure Text

	--[[
		Returns the width a styled text takes on one line at its token size, with two pixels of slack so rounding never
		truncates it. Measured with TextService, so it also works unparented and in exports.
	]]
	--- @return number
	function ctx.MeasureText(instance: TextLabel)
		--[[ Measuring ]]

		local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
		params.Text = instance.Text
		params.Font = instance.FontFace
		params.Size = instance.TextSize
		params.Width = math.huge

		local success: boolean
		local result: any | string?
		success, result = pcall(TextService.GetTextBoundsAsync, TextService, params)

		--[[ Returning ]]

		-- Fall back to an estimate when the font cannot be measured
		local textWidth: number = if success then result.X else #instance.Text * instance.TextSize * 0.55
		return math.ceil(textWidth) + 2
	end

	--%%%%%%%%%%%%%%%%%%%% Fit Width

	--[[
		Sets a pressable's container width to its ButtonText plus Content's side padding. Call it after the text is
		styled and whenever the text changes. AutomaticSize is not used because the scale-sized Background/Content
		inflate it.
	]]
	--- @param parts UmeGui_Pressable
	function ctx.FitWidth(parts)
		--[[ Data ]]

		local padding: UIPadding? = parts.Content:FindFirstChildOfClass("UIPadding")
		local size: UDim2 = parts.Container.Size

		--[[ Local Variables ]]

		local sides: number = if padding then padding.PaddingLeft.Offset + padding.PaddingRight.Offset else 0

		--[[ Applying ]]

		parts.Container.Size = UDim2.new(0, ctx.MeasureText(parts.Text) + sides, size.Y.Scale, size.Y.Offset)
	end

	--%%%%%%%%%%%%%%%%%%%% States

	--[[
		Creates a state driver over the given targets and keeps it in sync with mode changes.
	]]
	--- @param targets { [string]: UmeGui_StateTarget }
	--- @param style UmeGui_Style
	--- @return UmeGui_States
	function ctx.States(targets, style)
		--[[ Creating ]]

		local states = States.Create(targets, style, ctx.ResolveColor, ctx.Animate) --- @type UmeGui_States

		--[[ Saving ]]

		table.insert(scope.Refreshers, function()
			states.Refresh(true)
		end)

		--[[ Returning ]]

		return states
	end

	--%%%%%%%%%%%%%%%%%%%% Hover

	--[[
		Drives a button's Hover and Pressed states from mouse and touch input. Skipped for exports.
	]]
	--- @param states UmeGui_States
	function ctx.Hover(button: GuiObject, states)
		--[[ Checks ]]

		-- Exported guis have no engine behaviour
		if not view.Interactive then
			return
		end

		--[[ Connections ]]

		ctx.Connect(button.MouseEnter, function()
			states.Set("Hover", true)
		end)
		ctx.Connect(button.MouseLeave, function()
			states.Set("Hover", false)
			states.Set("Pressed", false)
		end)
		ctx.Connect(button.InputBegan, function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				states.Set("Pressed", true)
			end
		end)
		ctx.Connect(button.InputEnded, function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				states.Set("Pressed", false)
			end
		end)
	end

	--%%%%%%%%%%%%%%%%%%%% Animate

	--[[
		Moves properties to their goals: tweened with a motion token, or written at once when `instant`, when the gui
		has no engine behaviour (exports), or while the build scope has not settled (its first frame, when a rebuilt
		gui restores its state). Any tween still running on a property is cancelled first, so it cannot overwrite the
		new value.
	]]
	--- @param goals { [string]: any }
	function ctx.Animate(instance: Instance, goals, instant: boolean?, speed: string?)
		--[[ Data ]]

		local running = activeTweens[instance] --- @type { [string]: Tween }?

		--[[ Cancelling ]]

		if running then
			for property: string, _value: any in pairs(goals) do
				-- Stop a tween that would keep writing this property
				if running[property] then
					running[property]:Cancel()
					running[property] = nil
				end
			end
		end

		--[[ Instant ]]

		-- Write at once when there is nothing to animate yet
		if instant or not view.Interactive or not scope.Settled then
			for property: string, value: any in pairs(goals) do
				instance[property] = value
			end
			return
		end

		--[[ Playing ]]

		local info: TweenInfo = TweenInfo.new(ctx.Number("Motion", speed or "Default"), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		running = running or {}
		activeTweens[instance] = running

		for property: string, value: any in pairs(goals) do
			local tween: Tween = TweenService:Create(instance, info, { [property] = value })
			running[property] = tween
			tween:Play()
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Tween

	--[[
		Tweens properties with a motion token (`Fast`, `Default`, `Slow`), following Animate's instant rules.
	]]
	--- @param goals { [string]: any }
	function ctx.Tween(instance: Instance, goals, speed: string?)
		ctx.Animate(instance, goals, false, speed)
	end

	--%%%%%%%%%%%%%%%%%%%% Overlay

	--[[
		Covers the gui's layer with an invisible input-blocking button (the modal overlay rule).
		Clicking it calls `onClose`; children added to it float above the whole gui.
	]]
	--- @return ImageButton
	function ctx.Overlay(onClose: (() -> ())?)
		--[[ Data ]]

		local layer: Instance = view.Root:FindFirstAncestorWhichIsA("LayerCollector") or view.Root.Parent

		--[[ Creating ]]

		local overlay: ImageButton = Primitives.Create("ImageButton", {
			Name = "Overlay",
			Active = true,
			Interactable = true,
			ImageTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = OVERLAY_Z_INDEX,
			Parent = layer,
		})

		--[[ Connections ]]

		-- Close when the empty area is clicked
		if onClose then
			overlay.Activated:Connect(onClose)
		end

		--[[ Returning ]]

		return overlay
	end

	--%%%%%%%%%%%%%%%%%%%% Context Menu

	--[[
		Opens a menu of actions at the pointer, above everything else in the gui, drawn with the theme's Menu style.
		An action is a name or `{ Id, Text?, Icon? (an icon name, Tokens.Icons), Danger? (red) }`. Picking one closes the menu and
		calls `onPick` with its id; a click or right click anywhere else only closes it. Returns a function that closes it.
	]]
	--- @param actions { any }
	--- @return () -> ()
	function ctx.ContextMenu(actions, onPick: (actionId: string) -> ())
		--[[ Local Variables ]]

		local style = Style.Resolve(view.Theme, "Menu", nil) --- @type UmeGui_Style
		local itemHeight: number = ctx.Number("Size", style.ItemHeight)
		local padding: number = ctx.Number("Spacing", style.Padding)
		local margin: number = ctx.Number("Spacing", style.Margin)
		local paddingX: number = ctx.Number("Spacing", style.PaddingX)
		local iconSize: number = ctx.Number("TextSize", style.IconSize)
		local overlay: ImageButton

		--%%%%%%%%%%%%%%%%%%%% Close

		--[[
			Removes the menu.
		]]
		local function close()
			overlay:Destroy()
		end

		--[[ Overlay ]]

		-- One above other overlays, so a menu opened from a dropdown's list sits over it
		overlay = ctx.Overlay(close)
		overlay.Name = "ContextMenu"
		overlay.ZIndex = OVERLAY_Z_INDEX + 1
		overlay.MouseButton2Click:Connect(close)

		local layer: Instance = overlay.Parent
		local pointer: Vector2 = if layer:IsA("PluginGui") then layer:GetRelativeMousePosition() else UserInputService:GetMouseLocation()

		--[[ Menu ]]

		local menu: Frame = Primitives.Create("Frame", {
			Name = "Menu",
			Active = true,
			BackgroundTransparency = 0,
			Parent = overlay,
		})
		ctx.Color(menu, "BackgroundColor3", style.Fill)
		ctx.Corner(menu, style.Radius)
		ctx.Stroke(menu, style.Stroke, style.StrokeThickness)
		ctx.Padding(menu, style.Padding)
		ctx.List(menu, "Vertical", "None")

		--[[ Items ]]

		local width: number = ctx.Number("Size", style.MinWidth)
		for index: number, action: any in ipairs(actions) do
			local actionId: string = if type(action) == "table" then action.Id else action
			local icon: string? = if type(action) == "table" then action.Icon else nil
			local color: any = if type(action) == "table" and action.Danger then style.DangerText else style.Text
			local iconWidth: number = if icon then iconSize + ctx.Number("Spacing", style.IconGap) else 0

			local item = ctx.Pressable(UDim2.new(1, 0, 0, itemHeight), if type(action) == "table" then action.Text or actionId else actionId) --- @type UmeGui_Pressable
			item.Container.Name = actionId
			item.Container.LayoutOrder = index
			item.Container.Parent = menu
			item.Background.BackgroundTransparency = 1
			ctx.Color(item.Background, "BackgroundColor3", style.ItemHover)
			ctx.Corner(item.Background, style.ItemRadius)
			ctx.Padding(item.Content, "None", style.PaddingX)
			ctx.Text(item.Text, style.Font, style.TextSize, color)
			ctx.Typography(item.Text, style.Font, style.TextSize, true)
			item.Text.TextXAlignment = Enum.TextXAlignment.Left
			width = math.max(width, ctx.MeasureText(item.Text) + iconWidth + paddingX * 2 + padding * 2)

			-- Icon on the left, the text after it
			if icon then
				local glyph: ImageLabel = ctx.Glyph(icon, iconSize, color)
				glyph.AnchorPoint = Vector2.new(0, 0.5)
				glyph.Position = UDim2.fromScale(0, 0.5)
				glyph.Parent = item.Content
				Primitives.Create("UIPadding", { PaddingLeft = UDim.new(0, iconWidth), Parent = item.Text })
			end

			item.Button.MouseEnter:Connect(function()
				item.Background.BackgroundTransparency = 0
			end)
			item.Button.MouseLeave:Connect(function()
				item.Background.BackgroundTransparency = 1
			end)
			item.Button.Activated:Connect(function()
				close()
				onPick(actionId)
			end)
		end

		--[[ Placing ]]

		-- At the pointer, kept inside the gui
		local height: number = #actions * itemHeight + padding * 2
		local position: Vector2 = pointer - overlay.AbsolutePosition
		menu.Size = UDim2.fromOffset(width, height)
		menu.Position =
			UDim2.fromOffset(math.clamp(position.X, margin, math.max(margin, overlay.AbsoluteSize.X - margin - width)), math.clamp(position.Y, margin, math.max(margin, overlay.AbsoluteSize.Y - margin - height)))

		--[[ Returning ]]

		return close
	end

	--%%%%%%%%%%%%%%%%%%%% Capture

	--[[
		Follows the pointer every frame until the press ends, for drags (sliders, color bars). `onMove` gets the pointer
		in the same space as AbsolutePosition. The drag ends on release anywhere: on `source` (the pressed element, which
		owns the release), over the gui, outside it, or when the pointer leaves the gui.
	]]
	function ctx.Capture(onMove: (position: Vector2) -> (), onRelease: (() -> ())?, source: GuiObject?)
		--[[ Local Variables ]]

		local overlay: ImageButton = ctx.Overlay(nil)
		local layer: Instance = overlay.Parent
		local connections = {} --- @type { RBXScriptConnection }
		local lastPointer: Vector2? = nil

		--%%%%%%%%%%%%%%%%%%%% Get Pointer

		--[[
			Returns the pointer position: relative to the widget inside plugin widgets, on screen elsewhere.
		]]
		--- @return Vector2
		local function getPointer()
			return if layer:IsA("PluginGui") then layer:GetRelativeMousePosition() else UserInputService:GetMouseLocation()
		end

		--%%%%%%%%%%%%%%%%%%%% Release

		--[[
			Ends the drag once.
		]]
		local function release()
			--[[ Checks ]]

			-- Only release once
			if not overlay.Parent then
				return
			end

			--[[ Releasing ]]

			for _index: number, connection: RBXScriptConnection in ipairs(connections) do
				connection:Disconnect()
			end
			overlay:Destroy()
			if onRelease then
				onRelease()
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Release On Input

		--[[
			Ends the drag when the input is the primary button or a touch.
		]]
		local function releaseOnInput(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				release()
			end
		end

		--[[ Connections ]]

		-- Only a pointer that moved is reported, so a held drag does not redo its work every frame
		table.insert(
			connections,
			RunService.Heartbeat:Connect(function()
				local pointer: Vector2 = getPointer()
				if pointer ~= lastPointer then
					lastPointer = pointer
					onMove(pointer)
				end
			end)
		)
		table.insert(connections, UserInputService.InputEnded:Connect(releaseOnInput))
		table.insert(connections, overlay.InputEnded:Connect(releaseOnInput))
		table.insert(connections, overlay.MouseButton1Up:Connect(release))
		table.insert(connections, overlay.MouseLeave:Connect(release))
		if source then
			table.insert(connections, source.InputEnded:Connect(releaseOnInput))
		end

		--[[ Moving ]]

		lastPointer = getPointer()
		onMove(lastPointer)
	end

	--%%%%%%%%%%%%%%%%%%%% Connect

	--[[
		Connects to a signal for as long as the build scope lives.
	]]
	--- @param signal RBXScriptSignal | UmeGui_Signal
	function ctx.Connect(signal, callback: (...any) -> ())
		table.insert(scope.Connections, signal:Connect(callback))
	end

	--%%%%%%%%%%%%%%%%%%%% Refresh

	--[[
		Runs a callback whenever the mode or a token changes, after colors are re-applied.
	]]
	function ctx.Refresh(refresher: () -> ())
		table.insert(scope.Refreshers, refresher)
	end

	--%%%%%%%%%%%%%%%%%%%% Get Mode

	--[[
		Returns the view's current mode.
	]]
	--- @return UmeGui_Mode
	function ctx.GetMode()
		return view.Mode
	end

	--%%%%%%%%%%%%%%%%%%%% Set Mode

	--[[
		Switches the whole view to another mode.
	]]
	--- @param mode UmeGui_Mode
	function ctx.SetMode(mode)
		view:SetMode(mode)
	end

	--[[ Returning ]]

	return ctx
end

return Module
