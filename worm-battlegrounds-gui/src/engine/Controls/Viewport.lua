--[[
	Created By: 	Nari
]]

local _localName: string = "Viewport"

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

--- @class UmeGui_Controls_Viewport
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string?",
		Subtext = "string?",
		Status = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local text: string = node.Text or ""
	local subtext: string = node.Subtext or ""

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 1)) --- @type UmeGui_Surface
	ctx.Corner(surface.Background, style.Radius)
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Stroke(surface.Background, style.Stroke, style.StrokeThickness)
	ctx.List(surface.Content, "Vertical", "None")

	-- Take the height the parent column leaves free
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = surface.Root })

	-- Stage: the preview, the status over it and the drag surface, in the height the caption leaves
	local stage: Frame = ctx.Create("Frame", {
		Name = "Stage",
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Parent = surface.Content,
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = stage })

	local viewport: ViewportFrame = ctx.Create("ViewportFrame", {
		Name = "Viewport",
		LightDirection = style.LightDirection,
		Size = UDim2.fromScale(1, 1),
		Parent = stage,
	})
	ctx.Corner(viewport, style.Radius)
	ctx.Color(viewport, "Ambient", style.Ambient)
	ctx.Color(viewport, "LightColor", style.LightColor)
	local camera: Camera = ctx.Create("Camera", { Parent = viewport })
	viewport.CurrentCamera = camera

	local status: TextLabel = ctx.Create("TextLabel", {
		Name = "Status",
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(style.StatusWidth, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 2,
		Parent = stage,
	})
	ctx.Text(status, style.StatusFont, style.StatusSize, style.Status)

	-- A bare transparent button over the preview takes the drags
	local drag: ImageButton = ctx.Create("ImageButton", {
		Name = "Drag",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = stage,
	})

	-- Caption under the preview, after a divider line
	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = surface.Content,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	local caption: Frame = ctx.Create("Frame", {
		Name = "Caption",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		Parent = surface.Content,
	})
	ctx.Padding(caption, style.CaptionPadding, style.Padding)
	ctx.List(caption, "Vertical", "None")

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = caption,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)

	local subtitle: TextLabel = ctx.Create("TextLabel", {
		Name = "Subtext",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = caption,
	})
	ctx.Text(subtitle, style.SubFont, style.SubSize, style.Subtext)

	--%%%%%%%%%%%%%%%%%%%% Apply Caption

	--[[
		Writes the caption's texts; the caption and its divider hide while both are empty.
	]]
	local function applyCaption()
		--[[ Applying ]]

		title.Text = text
		title.Visible = text ~= ""
		subtitle.Text = subtext
		subtitle.Visible = subtext ~= ""
		caption.Visible = text ~= "" or subtext ~= ""
		divider.Visible = caption.Visible
	end

	--%%%%%%%%%%%%%%%%%%%% Apply Status

	--[[
		Shows the status message over the preview and fades the preview behind it; an empty message hides it.
	]]
	local function applyStatus(message: string)
		--[[ Applying ]]

		status.Text = message
		status.Visible = message ~= ""
		viewport.ImageTransparency = if message ~= "" then style.StatusFade else 0
	end

	applyCaption()
	applyStatus(node.Status or "")

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = surface.Root,
		Viewport = viewport,
		Camera = camera,
		Dragged = ctx.Signal.new(),
	}

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the caption title.
	]]
	function handle.SetText(newText: string)
		--[[ Applying ]]

		text = newText
		applyCaption()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Subtext

	--[[
		Replaces the line under the caption title.
	]]
	function handle.SetSubtext(newSubtext: string)
		--[[ Applying ]]

		subtext = newSubtext
		applyCaption()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Status

	--[[
		Shows a message centred over the faded preview; nil or empty hides it.
	]]
	function handle.SetStatus(message: string?)
		applyStatus(message or "")
	end

	--[[ Connections ]]

	-- A drag reports how far the pointer moved since the last frame
	if ctx.Interactive then
		ctx.Connect(drag.MouseButton1Down, function()
			local last: Vector2? = nil
			ctx.Capture(function(position: Vector2)
				if last then
					handle.Dragged:Fire(position - last)
				end
				last = position
			end, nil, drag)
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
