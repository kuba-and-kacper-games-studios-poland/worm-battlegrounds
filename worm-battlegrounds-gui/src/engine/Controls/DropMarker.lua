--[[
	Created By: 	Nari
]]

local _localName: string = "DropMarker"

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

--- @class UmeGui_Controls_DropMarker
local Module = {

	--[[ Schema ]]

	Params = {
		Direction = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local thickness: number = ctx.Number("Stroke", style.Thickness)
	local fade: number = math.clamp(style.Fade, 0, 0.5)
	local direction: string = node.Direction or "Vertical"
	local shown: boolean = false

	-- Clear at both ends, solid through the middle
	local fadeSequence: NumberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(fade, 0),
		NumberSequenceKeypoint.new(1 - fade, 0),
		NumberSequenceKeypoint.new(1, 1),
	})

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(thickness, thickness),
	})

	local line: Frame = ctx.Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Parent = root,
	})
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = line })
	ctx.Color(line, "BackgroundColor3", style.Fill)
	local outline: UIStroke = ctx.Stroke(line, style.Outline, style.OutlineThickness)

	-- The bar and its outline fade together, so the outline never shows past the bar's faded ends
	local lineFade: UIGradient = ctx.Create("UIGradient", { Transparency = fadeSequence, Parent = line })
	local outlineFade: UIGradient = ctx.Create("UIGradient", { Transparency = fadeSequence, Parent = outline })

	--%%%%%%%%%%%%%%%%%%%% Orient

	--[[
		Turns the fades to run along the bar's length.
	]]
	local function orient()
		--[[ Applying ]]

		local rotation: number = if direction == "Vertical" then 90 else 0
		lineFade.Rotation = rotation
		outlineFade.Rotation = rotation
	end

	orient()

	--[[ Handle ]]

	local handle = { Instance = root } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Show

	--[[
		Places the marker centred on `position` (an offset in its parent), `length` pixels long along `markerDirection`.
		It glides there from the last slot, or appears at once when it was hidden.
	]]
	function handle.Show(position: Vector2, length: number, markerDirection: string)
		--[[ Local Variables ]]

		local span: number = math.max(length, thickness * 4)
		local goals = { --- @type { [string]: any }
			Position = UDim2.fromOffset(position.X, position.Y),
			Size = if markerDirection == "Vertical" then UDim2.fromOffset(thickness, span) else UDim2.fromOffset(span, thickness),
		}

		--[[ Applying ]]

		-- A turn to the other direction jumps; gliding would stretch the bar sideways
		local instant: boolean = not shown or markerDirection ~= direction
		direction = markerDirection
		orient()
		ctx.Animate(root, goals, instant, "Fast")
		root.Visible = true
		shown = true
	end

	--%%%%%%%%%%%%%%%%%%%% Hide

	--[[
		Hides the marker; the next Show appears at once.
	]]
	function handle.Hide()
		--[[ Applying ]]

		root.Visible = false
		shown = false
	end

	--[[ Returning ]]

	return handle
end

return Module
