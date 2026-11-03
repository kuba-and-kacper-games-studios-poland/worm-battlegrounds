--[[
	Created By: 	Nari
]]

local _localName: string = "Thumb"

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

--- @class UmeGui_Controls_Thumb
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string?",
		Subtext = "string?",
		Image = "string?",
		Favorite = "boolean?",
		AspectRatio = "number?",
		Height = "number?",
		Selected = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local layout: string = style.Layout
	local padding: number = ctx.Number("Spacing", style.Padding)
	local overlayPadding: number = ctx.Number("Spacing", style.OverlayPadding)
	local rowSize: number = ctx.Number("Size", style.RowSize)
	local bannerHeight: number = ctx.Number("Size", style.BannerHeight)
	local heartSize: number = ctx.Number("Size", style.HeartSize)
	local aspectRatio: number = node.AspectRatio or 1
	-- A fixed preview height wins over the aspect ratio
	local fixedHeight: number? = node.Height
	local favorite: boolean = node.Favorite == true
	local hovered: boolean = false
	local heartHovered: boolean = false
	local gradient: UIGradient? = nil
	-- Tints the overlaid name's outline with a copy of the preview's gradient
	local nameStrokeGradient: UIGradient? = nil
	local menu = {} --- @type { any }
	local glow: UIShadow? = nil

	--[[ Building ]]

	local cardSize: UDim2 = if layout == "Row" then UDim2.new(1, 0, 0, rowSize + padding * 2) elseif layout == "Banner" then UDim2.new(1, 0, 0, bannerHeight) else UDim2.fromScale(1, 0)
	local parts = ctx.Pressable(cardSize) --- @type UmeGui_Pressable
	ctx.Corner(parts.Background, style.Radius)
	ctx.Color(parts.Background, "BackgroundColor3", style.Fill)
	parts.Background.BackgroundTransparency = style.FillTransparency
	local stroke: UIStroke = ctx.Stroke(parts.Background, style.Stroke, style.StrokeThickness)

	-- Preview: a filled frame holding the image, or tinted by a UIGradient
	local preview: Frame = ctx.Create("Frame", {
		Name = "Preview",
		BackgroundTransparency = style.PreviewTransparency,
		Size = UDim2.fromScale(1, 1),
		Parent = parts.Content,
	})
	ctx.Corner(preview, style.PreviewRadius)

	local image: ImageLabel = ctx.Create("ImageLabel", {
		Name = "Image",
		Image = node.Image or "",
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = preview,
	})

	-- A round soft light behind the image, white in Night and dark in Light
	if style.Glow then
		local glowFrame: Frame = ctx.Create("Frame", {
			Name = "Glow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(style.GlowScale, style.GlowScale),
			Parent = preview,
		})
		ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = glowFrame })
		glow = ctx.Create("UIShadow", {
			BlurRadius = UDim.new(0, style.GlowBlur),
			Transparency = style.GlowTransparency,
			Parent = glowFrame,
		})
		ctx.Color(glow, "Color", style.GlowColor)
	end

	-- Texts: along the preview's top edge, in a strip under it, or beside it
	local texts: Frame = ctx.Create("Frame", {
		Name = "Texts",
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		ZIndex = 2,
		Parent = parts.Content,
	})
	ctx.List(texts, "Vertical", "None")

	local title: TextLabel = ctx.Create("TextLabel", {
		Name = "Title",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Text = node.Text or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = (node.Text or "") ~= "",
		Parent = texts,
	})
	ctx.Typography(title, style.Font, style.TextSize)

	local subtitle: TextLabel = ctx.Create("TextLabel", {
		Name = "Subtext",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0),
		Text = node.Subtext or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = (node.Subtext or "") ~= "",
		Parent = texts,
	})
	ctx.Text(subtitle, style.SubFont, style.SubSize, style.Subtext)

	-- The heart, its own button over the preview: a small round chip, see-through until hovered
	local heart = ctx.Pressable(UDim2.fromOffset(heartSize, heartSize)) --- @type UmeGui_Pressable
	heart.Container.Name = "Favorite"
	heart.Container.ZIndex = 3
	heart.Container.Parent = parts.Content
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = heart.Background })
	ctx.Color(heart.Background, "BackgroundColor3", style.HeartFill)

	-- The icon scales with the chip: a share of its size
	local heartIcon: ImageLabel = ctx.Glyph("heart", 0, nil)
	heartIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	heartIcon.Position = UDim2.fromScale(0.5, 0.5)
	heartIcon.Size = UDim2.fromScale(style.HeartIconScale, style.HeartIconScale)
	heartIcon.Parent = heart.Content
	ctx.Tag(heart.Button, style.HeartTags)

	--[[ Placing ]]

	if layout == "Banner" then
		-- The preview fills the card under a scrim that darkens the left, where the texts sit; the heart on the right
		preview.Size = UDim2.fromScale(1, 1)
		preview.ClipsDescendants = true
		local scrim: Frame = ctx.Create("Frame", {
			Name = "Scrim",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = parts.Content,
		})
		ctx.Color(scrim, "BackgroundColor3", style.Scrim)
		ctx.Corner(scrim, style.PreviewRadius)
		ctx.Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, style.ScrimTransparency),
				NumberSequenceKeypoint.new(style.ScrimFade * 0.55, (style.ScrimTransparency + 1) / 2),
				NumberSequenceKeypoint.new(style.ScrimFade, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = scrim,
		})
		texts.ZIndex = 3
		texts.AnchorPoint = Vector2.new(0, 0.5)
		texts.Position = UDim2.new(0, padding, 0.5, 0)
		texts.Size = UDim2.new(1, -(padding * 3 + heartSize), 0, 0)
		heart.Container.ZIndex = 4
		heart.Container.AnchorPoint = Vector2.new(1, 0.5)
		heart.Container.Position = UDim2.new(1, -padding, 0.5, 0)
	elseif layout == "Row" then
		-- Square preview on the left, texts after it, the heart on the right
		preview.Position = UDim2.fromOffset(padding, padding)
		preview.Size = UDim2.fromOffset(rowSize, rowSize)
		texts.AnchorPoint = Vector2.new(0, 0.5)
		texts.Position = UDim2.new(0, rowSize + padding * 2, 0.5, 0)
		texts.Size = UDim2.new(1, -(rowSize + padding * 3 + heartSize), 0, 0)
		heart.Container.AnchorPoint = Vector2.new(1, 0.5)
		heart.Container.Position = UDim2.new(1, -padding, 0.5, 0)
	elseif layout == "Overlay" then
		-- The bottom right corner, out of the way of the name along the top
		local heartInset: number = ctx.Number("Spacing", style.HeartInset)
		heart.Container.AnchorPoint = Vector2.new(1, 1)
		heart.Container.Position = UDim2.new(1, -heartInset, 1, -heartInset)
	else
		-- The card's top right corner, clear of the centred image
		local heartInset: number = ctx.Number("Spacing", style.HeartInset)
		heart.Container.AnchorPoint = Vector2.new(1, 0)
		heart.Container.Position = UDim2.new(1, -heartInset, 0, heartInset)
	end

	if layout == "Overlay" then
		-- The name sits centred along the preview's top edge, white with an outline in the preview's colors
		texts.AnchorPoint = Vector2.new(0.5, 0)
		texts.Position = UDim2.new(0.5, 0, 0, ctx.Number("Spacing", style.OverlayTextTop))
		texts.Size = UDim2.new(1, -overlayPadding * 2, 0, 0)
		title.TextXAlignment = Enum.TextXAlignment.Center
		subtitle.Visible = false

		-- Bolder and a step larger, on one line: a long name is cut with an ellipsis instead of wrapping or shrinking
		title.AutomaticSize = Enum.AutomaticSize.None
		title.TextWrapped = false
		ctx.Typography(title, style.OverlayFont, style.OverlayTextSize, true)
		title:FindFirstChildOfClass("UITextSizeConstraint").MinTextSize = ctx.Number("TextSize", style.OverlayTextSize)

		-- A grey outline multiplied by the preview's colors, so it takes on a darker shade of the gradient under it
		local outline: UIStroke = ctx.Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = style.OverlayStroke,
			Thickness = ctx.Number("Stroke", style.OverlayStrokeThickness),
			Transparency = style.OverlayStrokeTransparency,
			Parent = title,
		})
		nameStrokeGradient = ctx.Create("UIGradient", { Enabled = false, Parent = outline })
	elseif layout == "Caption" then
		-- The name and subtext sit centred under the image, one line each: a long one is cut with an ellipsis. Fixed
		-- line heights, since scaled text sized by AutomaticSize collapses to nothing in a grid cell
		ctx.Padding(texts, style.CaptionPadding, style.Padding)

		--- @param label TextLabel
		for _index: number, label in ipairs({ title, subtitle }) do
			local textSize: any = if label == title then style.TextSize else style.SubSize
			label.AutomaticSize = Enum.AutomaticSize.None
			label.TextWrapped = false
			label.TextXAlignment = Enum.TextXAlignment.Center
			ctx.Typography(label, if label == title then style.Font else style.SubFont, textSize, true)
			label:FindFirstChildOfClass("UITextSizeConstraint").MinTextSize = ctx.Number("TextSize", textSize)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Colors the preview and the name: a gradient needs a white base to show its own colors, and an overlaid name stays
		white.
	]]
	local function paint()
		preview.BackgroundColor3 = if gradient then style.GradientBase else ctx.ResolveColor(style.PreviewFill)
		title.TextColor3 = if layout == "Overlay" then style.OverlayText else ctx.ResolveColor(style.Text)
	end

	--%%%%%%%%%%%%%%%%%%%% Fit

	--[[
		Makes an Overlay or Caption thumb as tall as its preview (its fixed height, else its aspect ratio), plus the
		caption strip under it. The preview is `PreviewScale` of the card's width, centred.
	]]
	local function fit()
		--[[ Checks ]]

		-- Rows and banners keep their fixed height
		if layout == "Row" or layout == "Banner" then
			return
		end

		--[[ Local Variables ]]

		-- A caption thumb insets its preview, so the rounded preview sits inside the card
		local inset: number = if layout == "Caption" then padding else 0
		local width: number = math.max(math.round((parts.Container.AbsoluteSize.X - inset * 2) * style.PreviewScale), 0)
		local previewHeight: number = fixedHeight or math.max(math.round(width / aspectRatio), 0)
		local captionHeight: number = if layout == "Caption" then texts.AbsoluteSize.Y else 0
		local size: UDim2 = parts.Container.Size

		--[[ Applying ]]

		preview.AnchorPoint = Vector2.new(0.5, 0)
		preview.Position = UDim2.new(0.5, 0, 0, inset)
		preview.Size = UDim2.fromOffset(width, previewHeight)
		if layout == "Caption" then
			texts.Position = UDim2.fromOffset(0, inset + previewHeight)
		end
		parts.Container.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, inset + previewHeight + captionHeight)
	end

	--%%%%%%%%%%%%%%%%%%%% Paint Heart

	--[[
		Fades the heart in while it is a favorite or hovered and out otherwise, filled for a favorite and easing into its
		tint. Its chip firms up while the pointer is on it. A faded-out heart takes no clicks.
	]]
	local function paintHeart()
		--[[ Local Variables ]]

		local shown: boolean = node.Favorite ~= nil and (favorite or hovered)
		local fill: number = if not shown then 1 elseif heartHovered then style.HeartHoverTransparency else style.HeartFillTransparency

		--[[ Applying ]]

		heart.Button.Interactable = shown
		heartIcon.Image = ctx.Icon(if favorite then "heart-filled" else "heart")
		ctx.Tween(heartIcon, {
			ImageColor3 = ctx.ResolveColor(if favorite then style.HeartActive else style.HeartIcon),
			ImageTransparency = if shown then 0 else 1,
		}, style.HeartMotion)
		ctx.Tween(heart.Background, { BackgroundTransparency = fill }, style.HeartMotion)
	end

	--[[ Theme ]]

	paint()
	ctx.Refresh(paint)
	fit()
	ctx.Connect(parts.Container:GetPropertyChangedSignal("AbsoluteSize"), fit)
	ctx.Connect(texts:GetPropertyChangedSignal("AbsoluteSize"), fit)
	paintHeart()
	ctx.Refresh(paintHeart)

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Stroke = { Instance = stroke, Property = "Color" },
		Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
		FillTransparency = { Instance = parts.Background, Property = "BackgroundTransparency" },
	}, style)
	states.Set("Selected", node.Selected == true)
	ctx.Hover(parts.Button, states)

	--[[ Handle ]]

	local handle = { --- @type UmeGui_Handle
		Instance = parts.Container,
		Button = parts.Button,
		Preview = preview,
		Clicked = ctx.Signal.new(),
		FavoriteClicked = ctx.Signal.new(),
		MenuAction = ctx.Signal.new(),
	}

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the name; an empty name hides it.
	]]
	function handle.SetText(text: string)
		title.Text = text
		title.Visible = text ~= ""
	end

	--%%%%%%%%%%%%%%%%%%%% Set Subtext

	--[[
		Replaces the line under the name; empty hides it. Overlay thumbs show no subtext.
	]]
	function handle.SetSubtext(text: string)
		subtitle.Text = text
		subtitle.Visible = text ~= "" and layout ~= "Overlay"
	end

	--%%%%%%%%%%%%%%%%%%%% Set Image

	--[[
		Shows an image in the preview (an asset id or content url).
	]]
	function handle.SetImage(content: string)
		image.Image = content
	end

	--%%%%%%%%%%%%%%%%%%%% Set Glow

	--[[
		Changes how see-through the glow behind the preview is (0 solid, 1 gone). Thumbs without a glow ignore it.
	]]
	function handle.SetGlow(transparency: number)
		--[[ Applying ]]

		if glow then
			glow.Transparency = transparency
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set Gradient

	--[[
		Fills the preview with a gradient, or clears it with nil.
	]]
	function handle.SetGradient(color: ColorSequence?, transparency: NumberSequence?)
		--[[ Clearing ]]

		-- No color removes the gradient, and the name's outline goes back to plain grey
		if not color then
			if gradient then
				gradient:Destroy()
				gradient = nil
			end
			if nameStrokeGradient then
				nameStrokeGradient.Enabled = false
			end
			paint()
			return
		end

		--[[ Applying ]]

		gradient = gradient or ctx.Create("UIGradient", { Parent = preview })
		gradient.Color = color
		gradient.Transparency = transparency or NumberSequence.new(0)
		if nameStrokeGradient then
			nameStrokeGradient.Color = color
			nameStrokeGradient.Enabled = true
		end
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Favorite

	--[[
		Fills or empties the heart without firing anything.
	]]
	function handle.SetFavorite(isFavorite: boolean)
		--[[ Applying ]]

		favorite = isFavorite
		paintHeart()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Outlines the thumb as the active one.
	]]
	function handle.SetSelected(selected: boolean)
		states.Set("Selected", selected)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Aspect Ratio

	--[[
		Reshapes an Overlay or Caption preview to a width / height ratio.
	]]
	function handle.SetAspectRatio(ratio: number)
		--[[ Applying ]]

		aspectRatio = ratio
		fit()
	end

	--%%%%%%%%%%%%%%%%%%%% Set Height

	--[[
		Fixes an Overlay or Caption preview to a height in pixels, or follows the aspect ratio again with nil.
	]]
	function handle.SetHeight(height: number?)
		--[[ Applying ]]

		fixedHeight = height
		fit()
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

	if ctx.Interactive then
		ctx.Connect(parts.Button.Activated, function()
			handle.Clicked:Fire()
		end)
		ctx.Connect(heart.Button.Activated, function()
			handle.FavoriteClicked:Fire()
		end)

		-- The chip firms up under the pointer
		ctx.Connect(heart.Button.MouseEnter, function()
			heartHovered = true
			paintHeart()
		end)
		ctx.Connect(heart.Button.MouseLeave, function()
			heartHovered = false
			paintHeart()
		end)
		ctx.Connect(parts.Button.MouseEnter, function()
			hovered = true
			paintHeart()
		end)
		ctx.Connect(parts.Button.MouseLeave, function()
			hovered = false
			paintHeart()
		end)

		-- Thumbs without actions have no menu
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
