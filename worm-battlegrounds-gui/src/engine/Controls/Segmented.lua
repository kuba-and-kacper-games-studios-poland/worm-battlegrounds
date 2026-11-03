--[[
	Created By: 	Nari
]]

local _localName: string = "Segmented"

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

--- @class UmeGui_Controls_Segmented
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Options = "table",
		Value = "string?",
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
	local value: string? = node.Value or options[1]
	local segments = {} --- @type { [string]: UmeGui_States }
	local containers = {} --- @type { [string]: Frame }

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(root, "Vertical", style.Gap)

	-- Label
	if node.Label then
		ctx.Build({ Control = "Label", Text = node.Label, Style = style.LabelStyle }, root).Instance.LayoutOrder = 0
	end

	-- Outlined box; a canvas inside Content clips the selected fill to the rounded corners
	local box = ctx.Surface(UDim2.new(1, 0, 0, ctx.Number("Size", style.Height))) --- @type UmeGui_Surface
	box.Root.Name = "Box"
	box.Root.LayoutOrder = 1
	box.Root.Parent = root
	ctx.Color(box.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(box.Background, style.Radius)
	ctx.Stroke(box.Background, style.Stroke, style.StrokeThickness)

	local canvas: CanvasGroup = ctx.Create("CanvasGroup", {
		Name = "Canvas",
		Size = UDim2.fromScale(1, 1),
		Parent = box.Content,
	})
	ctx.Corner(canvas, style.Radius)
	local list: UIListLayout = ctx.List(canvas, "Horizontal", "None")
	list.HorizontalFlex = Enum.UIFlexAlignment.Fill

	--[[ Handle ]]

	local handle = { Instance = root, Changed = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Build Segments

	--[[
		Replaces the segments with one per option, the selected one filled.
	]]
	local function buildSegments()
		--[[ Clearing ]]

		for _option: string, container: Frame in pairs(containers) do
			container:Destroy()
		end
		table.clear(containers)
		table.clear(segments)

		--[[ Segments ]]

		for index: number, option: string in ipairs(options) do
			local parts = ctx.Pressable(UDim2.fromScale(0, 1), option) --- @type UmeGui_Pressable
			parts.Container.Name = option
			parts.Container.LayoutOrder = index
			parts.Container.Parent = canvas
			ctx.Typography(parts.Text, style.Font, style.TextSize, true)

			-- Separator on the left of every option but the first
			if index > 1 then
				local separator: Frame = ctx.Create("Frame", {
					Name = "Separator",
					BackgroundTransparency = 0,
					Size = UDim2.new(0, ctx.Number("Stroke", style.StrokeThickness), 1, 0),
					Parent = parts.Content,
				})
				ctx.Color(separator, "BackgroundColor3", style.Divider)
			end

			-- States
			local states = ctx.States({ --- @type UmeGui_States
				Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
				Text = { Instance = parts.Text, Property = "TextColor3" },
			}, style)
			states.Set("Selected", option == value)
			states.Refresh(true)
			ctx.Hover(parts.Button, states)
			segments[option] = states
			containers[option] = parts.Container

			-- Selecting
			ctx.Connect(parts.Button.Activated, function()
				-- Skip the option that is already selected
				if value == option then
					return
				end

				handle.Set(option)
				handle.Changed:Fire(option)
			end)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Selects an option without firing Changed.
	]]
	function handle.Set(option: string)
		--[[ Applying ]]

		value = option
		--- @param states UmeGui_States
		for segmentOption: string, states in pairs(segments) do
			states.Set("Selected", segmentOption == option)
		end
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
		Replaces the options, keeping the selected one; the segments are only rebuilt when the list changed.
	]]
	--- @param newOptions { string }
	function handle.SetOptions(newOptions)
		--[[ Checks ]]

		-- Skip when the segments already match
		if table.concat(newOptions, "\0") == table.concat(options, "\0") then
			return
		end

		--[[ Applying ]]

		options = table.clone(newOptions)
		buildSegments()
	end

	--[[ Segments ]]

	buildSegments()

	--[[ Returning ]]

	return handle
end

return Module
