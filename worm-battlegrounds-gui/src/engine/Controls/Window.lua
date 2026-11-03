--[[
	Created By: 	Nari
]]

local _localName: string = "Window"

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

--- @class UmeGui_Controls_Window
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Title = "string?",
		Logo = "string?",
		ModeToggle = "boolean?",
		Minimize = "boolean?",
		Close = "boolean?",
		Grip = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local width: number = ctx.Number("Size", style.Width)
	local height: number = ctx.Number("Size", style.Height)
	local titleHeight: number = ctx.Number("Size", style.TitleHeight)

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromOffset(width, height)) --- @type UmeGui_Surface
	local window: Frame = surface.Root
	local content: Frame = surface.Content
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(surface.Background, style.Radius)
	ctx.Stroke(surface.Background, style.Stroke, style.StrokeThickness)
	content.ClipsDescendants = true
	ctx.List(content, "Vertical", "None")

	--%%%%%%%%%%%%%%%%%%%% Title Bar

	local titleBar: Frame = ctx.Create("Frame", {
		Name = "TitleBar",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, titleHeight),
		Parent = content,
	})
	ctx.Padding(titleBar, "None", style.PaddingX)
	ctx.List(titleBar, "Horizontal", style.Gap)

	-- Logo
	if node.Logo then
		local logo: ImageLabel = ctx.Create("ImageLabel", {
			Name = "Logo",
			Image = node.Logo,
			LayoutOrder = 0,
			Size = UDim2.fromOffset(22, 22),
			Parent = titleBar,
		})
		ctx.Color(logo, "ImageColor3", style.Text)
	end

	-- Title
	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 1),
		Text = node.Title or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = titleBar,
	})
	ctx.Text(title, style.Font, style.TextSize, style.Text)
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = title })

	-- Light / Night switch
	local modeToggle = nil --- @type UmeGui_Handle?
	if node.ModeToggle then
		modeToggle = ctx.Build({
			Control = "Toggle",
			OffText = "Light",
			OnText = "Night",
			Value = ctx.GetMode() == "Night",
		}, titleBar)
		modeToggle.Instance.Name = "ModeToggle"
		modeToggle.Instance.LayoutOrder = 2
	end

	-- Minimize and close
	local minimize = nil --- @type UmeGui_Handle?
	if node.Minimize ~= false then
		minimize = ctx.Build({ Control = "IconButton", Icon = "–" }, titleBar)
		minimize.Instance.Name = "Minimize"
		minimize.Instance.LayoutOrder = 3
	end

	local close = nil --- @type UmeGui_Handle?
	if node.Close ~= false then
		close = ctx.Build({ Control = "IconButton", Icon = "×" }, titleBar)
		close.Instance.Name = "Close"
		close.Instance.LayoutOrder = 4
	end

	--%%%%%%%%%%%%%%%%%%%% Body

	local divider: Frame = ctx.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Stroke", "Thin")),
		Parent = content,
	})
	ctx.Color(divider, "BackgroundColor3", style.Divider)

	local body: Frame = ctx.Create("Frame", {
		Name = "Body",
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 1),
		Parent = content,
	})
	ctx.List(body, "Vertical", "None")
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = body })

	--%%%%%%%%%%%%%%%%%%%% Grip

	local grip: Frame = ctx.Create("Frame", {
		Name = "Grip",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.GripHeight)),
		Visible = node.Grip ~= false,
		Parent = content,
	})
	local gripBar: Frame = ctx.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(32, 4),
		Parent = grip,
	})
	ctx.Color(gripBar, "BackgroundColor3", style.Grip)
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = gripBar })

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = window,
		Slot = body,
		Closed = ctx.Signal.new(),
		Minimized = ctx.Signal.new(),
	}
	local minimized: boolean = false

	--%%%%%%%%%%%%%%%%%%%% Set Title

	--[[
		Replaces the title text.
	]]
	function handle.SetTitle(text: string)
		title.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Minimized

	--[[
		Collapses the window to its title bar, or opens it again.
	]]
	function handle.SetMinimized(isMinimized: boolean)
		--[[ Applying ]]

		minimized = isMinimized
		body.Visible = not isMinimized
		divider.Visible = not isMinimized
		grip.Visible = not isMinimized and node.Grip ~= false
		window.Size = UDim2.fromOffset(width, if isMinimized then titleHeight else height)
		if minimize then
			minimize.SetIcon(if isMinimized then "+" else "–")
		end
	end

	--[[ Connections ]]

	if modeToggle then
		ctx.Connect(modeToggle.Changed, function(isNight: boolean)
			ctx.SetMode(if isNight then "Night" else "Light")
		end)
		ctx.Refresh(function()
			modeToggle.Set(ctx.GetMode() == "Night")
		end)
	end

	if minimize then
		ctx.Connect(minimize.Clicked, function()
			handle.SetMinimized(not minimized)
			handle.Minimized:Fire(minimized)
		end)
	end

	if close then
		ctx.Connect(close.Clicked, function()
			window.Visible = false
			handle.Closed:Fire()
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
