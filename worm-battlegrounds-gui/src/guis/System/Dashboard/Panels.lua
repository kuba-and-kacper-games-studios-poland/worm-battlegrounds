--[[
	Created By: 	Nari
]]

local _localName: string = "DashboardPanels"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TextService: TextService = game:GetService("TextService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Types ]]

-- A gui folder can't hold a _meta/_types.lua (GetGuiNames would list it as a gui), so the shapes live here

--- @class UmeGui_Guis_System_Dashboard_Block
---
--- # General #
---
--- @field Type "Button" | "Toggle" | "Slider" | "Input" | "Choice" | "Info" | "Give"
--- @field Id string
--- @field Text string
---
--- # Value #
---
--- @field Value any?
--- @field Min number?
--- @field Max number?
--- @field Step number?
--- @field Format string?
--- @field Options { string }?
---
--- # Input #
---
--- @field Placeholder string?
--- @field Button string?
---
--- # Give #
---
--- @field Items { UmeGui_Guis_System_Dashboard_Item }?
---
--- # Look #
---
--- @field Danger boolean?
local _block = {}

--- @class UmeGui_Guis_System_Dashboard_Item
---
--- # General #
---
--- @field Name string
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
local _item = {}

--- @class UmeGui_Guis_System_Dashboard_Section
---
--- # General #
---
--- @field Title string
--- @field Blocks { UmeGui_Guis_System_Dashboard_Block }
local _section = {}

--- @class UmeGui_Guis_System_Dashboard_Panel
---
--- # General #
---
--- @field Id string
--- @field Name string
--- @field Description string
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
--- @field Round boolean?
--- @field Stats string?
---
--- # Layout #
---
--- @field Sections { UmeGui_Guis_System_Dashboard_Section }
local _panel = {}

--[[ Sizes ]]

-- A button's or switch's size in a section (four to a row at the dashboard's starting width), and the room a choice
-- pill keeps beside its text
local BUTTON_SIZE: UDim2 = UDim2.fromOffset(118, 34)
local OPTION_PADDING: number = 24

--[[ Colors ]]

-- Text in a panel: bright, a block's label, red for what can't be undone, and dark (on a light accent); the fill and
-- outline every button has while off, and a switch's dot while off
local TEXT_COLOR: Color3 = Color3.fromRGB(230, 230, 234)
local LABEL_COLOR: Color3 = Color3.fromRGB(200, 200, 206)
local DANGER_COLOR: Color3 = Color3.fromRGB(255, 110, 110)
local DARK_TEXT_COLOR: Color3 = Color3.fromRGB(14, 14, 16)
-- An icon's initial: white, or dark on a swatch lighter than LIGHT_LUMINANCE (relative luminance, 0 to 1)
local LETTER_COLOR: Color3 = Color3.fromRGB(255, 255, 255)
local LIGHT_LUMINANCE: number = 0.6
local SURFACE_COLOR: Color3 = Color3.fromRGB(255, 255, 255)
local OFF_COLOR: Color3 = Color3.fromRGB(80, 80, 86)

--[[ State ]]

-- Every block's value, kept across rebuilds by "<panel id>/<block id>"; the header and sections built for the shown
-- panel, the connections made to them, the slider being dragged, and the accent the panel is lit with
local values = {} --- @type { [string]: any }
local sections = {} --- @type { UmeGui_Subview }
local connections = {} --- @type { RBXScriptConnection }
local dragging = nil --- @type { [string]: any }?
local accent: Color3 = Color3.new(1, 1, 1)

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

--- @class UmeGui_Guis_System_Dashboard_Panels
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a panel in a content area (a PREFAB | Content clone): a PREFAB | PanelHeader with its icon (round for a
	player), name, description and stats, then a PREFAB | Section per section of its definition, each holding a block
	per entry. Every switch, slider, choice, field and picked item starts at its value from the last time it was shown,
	else its definition's. Lets go of the last panel first.
]]
--- @param view UmeGui_View
--- @param panel UmeGui_Guis_System_Dashboard_Panel
function Module.Show(view, content: ScrollingFrame, panel, accentColor: Color3)
	--[[ Cleaning ]]

	Module.Clear()
	accent = accentColor

	--[[ Header ]]

	local header = view:Build("PREFAB | PanelHeader", content) --- @type UmeGui_Subview
	local icon: ImageLabel = header:Get("S_Icon").Instance
	local stats: TextLabel = header:Get("S_Stats").Instance
	icon.Image = panel.Icon or ""
	icon.BackgroundColor3 = panel.Color or OFF_COLOR
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if panel.Round then UDim.new(1, 0) else UDim.new(0, 12)
	Module.PaintLetter(icon, panel.Name)
	header:Get("S_Name").Instance.Text = panel.Name
	header:Get("S_Description").Instance.Text = panel.Description
	stats.Text = panel.Stats or ""
	stats.Visible = panel.Stats ~= nil
	header.Root.Instance.LayoutOrder = 0
	table.insert(sections, header)
	content.CanvasPosition = Vector2.zero

	--[[ Sections ]]

	--- @param section UmeGui_Guis_System_Dashboard_Section
	for sectionIndex: number, section in ipairs(panel.Sections) do
		local subview = view:Build("PREFAB | Section", content) --- @type UmeGui_Subview
		local blocks: Frame = subview:Get("S_Blocks").Instance
		subview:Get("S_Title").Instance.Text = string.upper(section.Title)
		subview.Root.Instance.LayoutOrder = sectionIndex
		table.insert(sections, subview)

		--- @param block UmeGui_Guis_System_Dashboard_Block
		for blockIndex: number, block in ipairs(section.Blocks) do
			local root: GuiObject = Module._buildBlock(view, blocks, block, `{panel.Id}/{block.Id}`, panel.Name)
			root.LayoutOrder = blockIndex
		end
	end

	--[[ Connections ]]

	table.insert(connections, UserInputService.InputChanged:Connect(Module._onSliderMoved))
	table.insert(connections, UserInputService.InputEnded:Connect(Module._onSliderEnded))
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes the shown panel's header and sections and disconnects everything made for them.
]]
function Module.Clear()
	--[[ Cleaning ]]

	--- @param connection RBXScriptConnection
	for _index: number, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)

	--- @param subview UmeGui_Subview
	for _index: number, subview in ipairs(sections) do
		subview:Destroy()
	end
	table.clear(sections)
	dragging = nil
end

--%%%%%%%%%%%%%%%%%%%% Paint Letter

--[[
	Writes a name's initial on an icon (its S_Letter) while the icon has no image, dark on a light swatch and white on a
	dark one; leaves it blank once the icon shows an image.
]]
function Module.PaintLetter(icon: ImageLabel, name: string)
	--[[ Local Variables ]]

	local letter: TextLabel = icon:FindFirstChild("S_Letter")
	local color: Color3 = icon.BackgroundColor3

	--[[ Applying ]]

	letter.Text = if icon.Image == "" then string.upper(string.sub(name, 1, 1)) else ""
	letter.TextColor3 = if 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B > LIGHT_LUMINANCE then DARK_TEXT_COLOR else LETTER_COLOR
end

--%%%%%%%%%%%%%%%%%%%% Paint Toggle

--[[
	Shows a switch on or off: on, its fill, outline and dot take the accent and its name brightens; off, they go back
	to the plain button.
]]
function Module.PaintToggle(button: ImageButton, on: boolean, accentColor: Color3)
	--[[ Elements ]]

	local stroke: UIStroke = button:FindFirstChildOfClass("UIStroke")
	local label: TextLabel = button:FindFirstChild("S_Label")
	local dot: Frame = button:FindFirstChild("S_State")

	--[[ Applying ]]

	button.BackgroundColor3 = if on then accentColor else SURFACE_COLOR
	button.BackgroundTransparency = if on then 0.85 else 0.95
	stroke.Color = if on then accentColor else SURFACE_COLOR
	stroke.Transparency = if on then 0.3 else 0.92
	label.TextColor3 = if on then TEXT_COLOR else LABEL_COLOR
	dot.BackgroundColor3 = if on then accentColor else OFF_COLOR
end

--%%%%%%%%%%%%%%%%%%%% Build Block

--[[
	Builds one block of a section from its prefab and wires it: a Button acts once, a Toggle switches, a Slider drags
	between its Min and Max by its Step, an Input sends its field, a Choice picks one of its Options, an Info line shows
	its Value, and a Give block picks one of its Items to give the panel's player (`target`). Returns the block's root,
	for its place in the section.
]]
--- @param view UmeGui_View
--- @param block UmeGui_Guis_System_Dashboard_Block
--- @return GuiObject
function Module._buildBlock(view, parent: Frame, block, key: string, target: string)
	--[[ Data ]]

	local value: any = if values[key] ~= nil then values[key] else block.Value

	--[[ Button ]]

	if block.Type == "Button" then
		local subview = view:Build("PREFAB | ActionButton", parent) --- @type UmeGui_Subview
		local label: TextLabel = subview:Get("S_Label").Instance
		label.Text = block.Text
		label.TextColor3 = if block.Danger then DANGER_COLOR else LABEL_COLOR
		subview.Root.Instance.Size = BUTTON_SIZE
		return subview.Root.Instance
	end

	--[[ Toggle ]]

	if block.Type == "Toggle" then
		local subview = view:Build("PREFAB | ToggleButton", parent) --- @type UmeGui_Subview
		local button: ImageButton = subview:Get("S_Button").Instance
		subview:Get("S_Label").Instance.Text = block.Text
		subview.Root.Instance.Size = BUTTON_SIZE
		Module.PaintToggle(button, value == true, accent)
		table.insert(
			connections,
			button.Activated:Connect(function()
				values[key] = not values[key]
				Module.PaintToggle(button, values[key], accent)
			end)
		)
		values[key] = value == true
		return subview.Root.Instance
	end

	--[[ Slider ]]

	if block.Type == "Slider" then
		local subview = view:Build("PREFAB | SliderRow", parent) --- @type UmeGui_Subview
		local track: ImageButton = subview:Get("S_Track").Instance
		local slider = { Block = block, Key = key, Subview = subview, Track = track } --- @type { [string]: any }
		subview:Get("S_Label").Instance.Text = block.Text
		subview:Get("S_Fill").Instance.BackgroundColor3 = accent
		Module._setSlider(slider, value)
		table.insert(
			connections,
			track.InputBegan:Connect(function(input: InputObject)
				-- Start a drag on a click or a touch, setting the value under it at once
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = slider
					Module._setSliderAt(slider, input.Position.X)
				end
			end)
		)
		return subview.Root.Instance
	end

	--[[ Input ]]

	if block.Type == "Input" then
		local subview = view:Build("PREFAB | InputRow", parent) --- @type UmeGui_Subview
		local field: TextBox = subview:Get("S_Field").Instance
		subview:Get("S_Label").Instance.Text = block.Text
		subview:Get("S_SendLabel").Instance.Text = block.Button or "Send"
		field.PlaceholderText = block.Placeholder or ""
		field.Text = value or ""
		table.insert(
			connections,
			field:GetPropertyChangedSignal("Text"):Connect(function()
				values[key] = field.Text
			end)
		)
		return subview.Root.Instance
	end

	--[[ Choice ]]

	if block.Type == "Choice" then
		local subview = view:Build("PREFAB | ChoiceRow", parent) --- @type UmeGui_Subview
		local options: Frame = subview:Get("S_Options").Instance
		local pills = {} --- @type { UmeGui_Subview }
		subview:Get("S_Label").Instance.Text = block.Text
		values[key] = value or block.Options[1]

		--- @param option string
		for optionIndex: number, option in ipairs(block.Options) do
			local pill = view:Build("PREFAB | ChoiceOption", options) --- @type UmeGui_Subview
			local label: TextLabel = pill:Get("S_Label").Instance
			local measure: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
			measure.Text = option
			measure.Font = label.FontFace
			measure.Size = label.TextSize
			measure.Width = 1000
			local width: number = TextService:GetTextBoundsAsync(measure).X
			label.Text = option
			pill.Root.Instance.LayoutOrder = optionIndex
			pill.Root.Instance.Size = UDim2.fromOffset(math.ceil(width) + OPTION_PADDING, 30)
			table.insert(pills, pill)
			table.insert(
				connections,
				pill:Get("S_Button").Instance.Activated:Connect(function()
					values[key] = option
					Module._paintChoice(pills, block.Options, option)
				end)
			)
		end
		Module._paintChoice(pills, block.Options, values[key])
		return subview.Root.Instance
	end

	--[[ Give ]]

	if block.Type == "Give" then
		local subview = view:Build("PREFAB | GiveBlock", parent) --- @type UmeGui_Subview
		local tiles = {} --- @type { UmeGui_Subview }
		local amount: TextBox = subview:Get("S_Amount").Instance
		values[key] = value or 0

		--- @param item UmeGui_Guis_System_Dashboard_Item
		for itemIndex: number, item in ipairs(block.Items) do
			local tile = view:Build("PREFAB | ItemTile", subview:Get("S_Items").Instance) --- @type UmeGui_Subview
			local icon: ImageLabel = tile:Get("S_Icon").Instance
			icon.Image = item.Icon or ""
			icon.BackgroundColor3 = item.Color or OFF_COLOR
			tile:Get("S_Name").Instance.Text = item.Name
			tile.Root.Instance.LayoutOrder = itemIndex
			table.insert(tiles, tile)
			table.insert(
				connections,
				tile:Get("S_Button").Instance.Activated:Connect(function()
					values[key] = itemIndex
					Module._showGive(subview, tiles, block, key, target, false)
				end)
			)
		end

		table.insert(
			connections,
			amount:GetPropertyChangedSignal("Text"):Connect(function()
				Module._showGive(subview, tiles, block, key, target, false)
			end)
		)
		table.insert(
			connections,
			subview:Get("S_Give").Instance.Activated:Connect(function()
				Module._showGive(subview, tiles, block, key, target, true)
			end)
		)
		Module._showGive(subview, tiles, block, key, target, false)
		return subview.Root.Instance
	end

	--[[ Info ]]

	local subview = view:Build("PREFAB | InfoRow", parent) --- @type UmeGui_Subview
	subview:Get("S_Label").Instance.Text = block.Text
	subview:Get("S_Value").Instance.Text = tostring(value or "")
	return subview.Root.Instance
end

--%%%%%%%%%%%%%%%%%%%% Show Give

--[[
	Outlines a Give block's picked tile with the accent, fills its Give button with it, and says what Give gives the
	player, or, right after a press, what it gave.
]]
--- @param subview UmeGui_Subview
--- @param tiles { UmeGui_Subview }
--- @param block UmeGui_Guis_System_Dashboard_Block
function Module._showGive(subview, tiles, block, key: string, target: string, given: boolean)
	--[[ Local Variables ]]

	local picked: number = values[key]
	local give: ImageButton = subview:Get("S_Give").Instance
	local hint: TextLabel = subview:Get("S_GiveHint").Instance

	--[[ Tiles ]]

	--- @param tile UmeGui_Subview
	for index: number, tile in ipairs(tiles) do
		local button: ImageButton = tile:Get("S_Button").Instance
		local stroke: UIStroke = button:FindFirstChildOfClass("UIStroke")
		button.BackgroundTransparency = if index == picked then 0.9 else 0.95
		stroke.Color = if index == picked then accent else SURFACE_COLOR
		stroke.Transparency = if index == picked then 0.2 else 0.92
	end

	--[[ Button ]]

	give.BackgroundColor3 = accent
	subview:Get("S_GiveLabel").Instance.TextColor3 = if accent.R * 0.2126 + accent.G * 0.7152 + accent.B * 0.0722 > 0.5 then DARK_TEXT_COLOR else TEXT_COLOR

	--[[ Checks ]]

	-- Ask for an item until one is picked
	if picked == 0 then
		hint.Text = "Pick an item to give"
		return
	end

	--[[ Hint ]]

	local amount: number = math.max(1, math.floor(tonumber(subview:Get("S_Amount").Instance.Text) or 1))
	local item: string = block.Items[picked].Name
	hint.Text = if given then `Gave {amount} × {item} to {target}` else `Gives {amount} × {item} to {target}`
end

--%%%%%%%%%%%%%%%%%%%% Paint Choice

--[[
	Fills the picked option's pill with the accent and brightens its text; the others go back to the plain button.
]]
--- @param pills { UmeGui_Subview }
--- @param options { string }
function Module._paintChoice(pills, options, picked: string)
	--[[ Applying ]]

	--- @param pill UmeGui_Subview
	for index: number, pill in ipairs(pills) do
		local button: ImageButton = pill:Get("S_Button").Instance
		local label: TextLabel = pill:Get("S_Label").Instance
		button.BackgroundColor3 = if options[index] == picked then accent else SURFACE_COLOR
		button.BackgroundTransparency = if options[index] == picked then 0.8 else 0.95
		label.TextColor3 = if options[index] == picked then TEXT_COLOR else LABEL_COLOR
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Slider At

--[[
	Sets a slider to the value under a point across its track.
]]
--- @param slider { [string]: any }
function Module._setSliderAt(slider, x: number)
	--[[ Local Variables ]]

	local block = slider.Block --- @type UmeGui_Guis_System_Dashboard_Block
	local track: ImageButton = slider.Track
	local share: number = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)

	--[[ Applying ]]

	Module._setSlider(slider, block.Min + (block.Max - block.Min) * share)
end

--%%%%%%%%%%%%%%%%%%%% Set Slider

--[[
	Sets a slider's value, rounded to its Step and kept between its Min and Max: moves its fill and knob there and
	writes the value, in its Format when it has one ("×{}" shows "×2").
]]
--- @param slider { [string]: any }
function Module._setSlider(slider, value: number)
	--[[ Local Variables ]]

	local block = slider.Block --- @type UmeGui_Guis_System_Dashboard_Block
	local subview = slider.Subview --- @type UmeGui_Subview
	local step: number = block.Step or 1
	local rounded: number = math.clamp(math.round(value / step) * step, block.Min, block.Max)
	local share: number = (rounded - block.Min) / math.max(block.Max - block.Min, 1e-9)

	-- As many decimals as the step has
	local decimals: number = if step % 1 == 0 then 0 else math.max(0, math.ceil(-math.log10(step % 1)))
	local text: string = string.format(`%.{decimals}f`, rounded)

	--[[ Applying ]]

	values[slider.Key] = rounded
	subview:Get("S_Fill").Instance.Size = UDim2.fromScale(share, 1)
	subview:Get("S_Knob").Instance.Position = UDim2.fromScale(share, 0.5)
	subview:Get("S_Value").Instance.Text = if block.Format then string.gsub(block.Format, "{}", text) else text
end

--%%%%%%%%%%%%%%%%%%%% On Slider Moved

--[[
	Moves the dragged slider's value with the mouse or touch.
]]
function Module._onSliderMoved(input: InputObject)
	--[[ Checks ]]

	-- Skip anything but the pointer moving during a drag
	if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then
		return
	end

	--[[ Applying ]]

	Module._setSliderAt(dragging, input.Position.X)
end

--%%%%%%%%%%%%%%%%%%%% On Slider Ended

--[[
	Ends a slider's drag when the click or touch is let go.
]]
function Module._onSliderEnded(input: InputObject)
	--[[ Checks ]]

	-- Skip anything but the end of a click or a touch
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	--[[ Saving ]]

	dragging = nil
end

return Module
