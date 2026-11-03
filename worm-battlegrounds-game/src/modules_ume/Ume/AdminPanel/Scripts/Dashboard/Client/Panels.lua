--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Sizes ]]

local BUTTON_SIZE: UDim2 = UDim2.fromOffset(118, 34)
local OPTION_PADDING: number = 24
local OPTION_HEIGHT: number = 30

--[[ Prefabs ]]

local prefabs = {} --- @type { [string]: GuiObject }

--[[ State ]]

local values = {} --- @type { [string]: any }
local built = {} --- @type { GuiObject }
local connections = {} --- @type { RBXScriptConnection }
local dragging = nil --- @type AdminPanel_DashboardSlider?
local accent: Color3 = _settings.DASHBOARD_ACCENT

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Value Key

--[[
	Returns the key a block's value is kept under while the dashboard runs.
]]
--- @param section AdminPanel_DashboardPageSection
--- @return string
local function getValueKey(pageId: string, section, blockId: string)
	return `{pageId}/{section.PanelId}/{blockId}`
end

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

--- @class AdminPanel_Dashboard_Client_Panels
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Finds every `PREFAB | Name` in the dashboard's gui and hides it, for `Clone`, and connects the slider drag.
]]
function Module.Bind(gui: ScreenGui)
	--[[ Prefabs ]]

	for _index: number, descendant: Instance in ipairs(gui:GetDescendants()) do
		-- Keep each prefab by its name without the prefix
		if descendant:IsA("GuiObject") and string.sub(descendant.Name, 1, 9) == "PREFAB | " then
			prefabs[string.sub(descendant.Name, 10)] = descendant
			descendant.Visible = false
		end
	end

	--[[ Connections ]]

	I.S.UserInputService.InputChanged:Connect(Module._onSliderMoved)
	I.S.UserInputService.InputEnded:Connect(Module._onSliderEnded)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Clone

--[[
	Clones a prefab into a parent, shown and named without its prefix.
]]
--- @return GuiObject
function Module.Clone(name: string, parent: Instance)
	--[[ Cloning ]]

	local copy: GuiObject = prefabs[name]:Clone()
	copy.Name = name
	copy.Visible = true
	copy.Parent = parent

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a page in a content area: its header (icon, name, description, stats), then a section per section, each
	holding its blocks. A block shows the server's value when it sends one, else what was last picked or typed in it.
	Pressing a block that runs something calls `onRun` with its section, the block and every value in the section.
	Lets go of the last page first.
]]
--- @param page AdminPanel_DashboardPage
--- @param onRun (section: AdminPanel_DashboardPageSection, block: AdminPanel_DashboardPageBlock, values: { [string]: any }) -> ()
function Module.Show(content: ScrollingFrame, page, onRun)
	--[[ Cleaning ]]

	Module.Clear()

	--[[ Header ]]

	local header: GuiObject = Module._clone("PanelHeader", content)
	local icon: ImageLabel = header:FindFirstChild("S_Icon", true)
	local stats: TextLabel = header:FindFirstChild("S_Stats", true)
	local nameLabel: TextLabel = header:FindFirstChild("S_Name", true)
	local description: TextLabel = header:FindFirstChild("S_Description", true)
	icon.Image = page.Icon or ""
	icon.BackgroundColor3 = page.Color or _settings.DASHBOARD_COLORS.Swatch
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if page.Round then UDim.new(1, 0) else UDim.new(0, 12)
	Module.PaintLetter(icon, page.Name)
	nameLabel.Text = page.Name
	description.Text = page.Description
	stats.Text = page.Stats or ""
	stats.Visible = page.Stats ~= nil
	header.LayoutOrder = 0

	--[[ Sections ]]

	--- @param section AdminPanel_DashboardPageSection
	for sectionIndex: number, section in ipairs(page.Sections) do
		local sectionFrame: GuiObject = Module._clone("Section", content)
		local title: TextLabel = sectionFrame:FindFirstChild("S_Title", true)
		local blocks: Frame = sectionFrame:FindFirstChild("S_Blocks", true)
		title.Text = string.upper(section.Title)
		sectionFrame.LayoutOrder = sectionIndex

		--- @param block AdminPanel_DashboardPageBlock
		for blockIndex: number, block in ipairs(section.Blocks) do
			local root: GuiObject = Module._buildBlock(page, section, block, blocks, function()
				onRun(section, block, Module._getSectionValues(page.Id, section))
			end)
			root.LayoutOrder = blockIndex
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes the shown page and disconnects everything made for it.
]]
function Module.Clear()
	--[[ Cleaning ]]

	for _index: number, connection: RBXScriptConnection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)

	for _index: number, instance: GuiObject in ipairs(built) do
		instance:Destroy()
	end
	table.clear(built)
	dragging = nil
end

--%%%%%%%%%%%%%%%%%%%% Paint Letter

--[[
	Writes a name's initial on an icon (its `S_Letter`) while the icon has no image, dark on a light swatch and white on
	a dark one.
]]
function Module.PaintLetter(icon: ImageLabel, name: string)
	--[[ Elements ]]

	local letter: TextLabel = icon:FindFirstChild("S_Letter")

	--[[ Applying ]]

	letter.Text = if icon.Image == "" then string.upper(string.sub(name, 1, 1)) else ""
	letter.TextColor3 = if I.Color.GetColorLuminance(icon.BackgroundColor3) > _settings.DASHBOARD_LIGHT_LUMINANCE then _settings.DASHBOARD_COLORS.Dark else _settings.DASHBOARD_COLORS.Letter
end

--%%%%%%%%%%%%%%%%%%%% Clone Kept

--[[
	Clones a prefab and keeps it, so the next `Show` or `Clear` removes it.
]]
--- @return GuiObject
function Module._clone(name: string, parent: Instance)
	--[[ Cloning ]]

	local copy: GuiObject = Module.Clone(name, parent)
	table.insert(built, copy)

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%% Build Block

--[[
	Builds one block from its prefab and wires it: a Button runs at once, a Toggle switches then runs, a Slider runs
	when let go, an Input runs from its button or Enter, a Choice runs on a pick, and a Give block runs from its Give
	button. Blocks the server gave no callback only keep their value. Returns the block's root.
]]
--- @param page AdminPanel_DashboardPage
--- @param section AdminPanel_DashboardPageSection
--- @param block AdminPanel_DashboardPageBlock
--- @return GuiObject
function Module._buildBlock(page, section, block, parent: Frame, run: () -> ())
	--[[ Data ]]

	local key: string = getValueKey(page.Id, section, block.Id)
	local value: any = if block.Value ~= nil then block.Value else values[key]

	--[[ Local Variables ]]

	local colors = _settings.DASHBOARD_COLORS --- @type { [string]: Color3 }

	--%%%%%%%%%%%%%%%%%%%% Button

	if block.Type == "Button" then
		local root: GuiObject = Module.Clone("ActionButton", parent)
		local button: ImageButton = root:FindFirstChild("S_Button", true)
		local label: TextLabel = root:FindFirstChild("S_Label", true)
		label.Text = block.Text
		label.TextColor3 = if block.Danger then colors.Danger else colors.Label
		root.Size = BUTTON_SIZE

		-- Run only a block with a callback
		if block.Run then
			table.insert(connections, button.Activated:Connect(run))
		end

		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Toggle

	if block.Type == "Toggle" then
		local root: GuiObject = Module.Clone("ToggleButton", parent)
		local button: ImageButton = root:FindFirstChild("S_Button", true)
		root:FindFirstChild("S_Label", true).Text = block.Text
		root.Size = BUTTON_SIZE
		values[key] = value == true
		Module._paintToggle(button, values[key])
		table.insert(
			connections,
			button.Activated:Connect(function()
				values[key] = not values[key]
				Module._paintToggle(button, values[key])

				-- Run only a block with a callback
				if block.Run then
					run()
				end
			end)
		)
		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Slider

	if block.Type == "Slider" then
		local root: GuiObject = Module.Clone("SliderRow", parent)
		local track: ImageButton = root:FindFirstChild("S_Track", true)

		--- @type AdminPanel_DashboardSlider
		local slider = { Block = block, Key = key, Root = root, Track = track, Run = if block.Run then run else nil }

		root:FindFirstChild("S_Label", true).Text = block.Text
		root:FindFirstChild("S_Fill", true).BackgroundColor3 = accent
		Module._setSlider(slider, value or block.Min or 0)
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
		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Input

	if block.Type == "Input" then
		local root: GuiObject = Module.Clone("InputRow", parent)
		local field: TextBox = root:FindFirstChild("S_Field", true)
		local send: ImageButton = root:FindFirstChild("S_Send", true)
		root:FindFirstChild("S_Label", true).Text = block.Text
		root:FindFirstChild("S_SendLabel", true).Text = block.Button or "Send"
		field.PlaceholderText = block.Placeholder or ""
		field.Text = if value ~= nil then tostring(value) else ""
		values[key] = field.Text
		table.insert(
			connections,
			field:GetPropertyChangedSignal("Text"):Connect(function()
				values[key] = field.Text
			end)
		)

		-- Run only a block with a callback, from its button or Enter
		if block.Run then
			table.insert(connections, send.Activated:Connect(run))
			table.insert(
				connections,
				field.FocusLost:Connect(function(enterPressed: boolean)
					if enterPressed then
						run()
					end
				end)
			)
		end

		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Choice

	if block.Type == "Choice" then
		local root: GuiObject = Module.Clone("ChoiceRow", parent)
		local options: Frame = root:FindFirstChild("S_Options", true)
		local optionList = block.Options or {} --- @type { string }
		local pills = {} --- @type { GuiObject }
		root:FindFirstChild("S_Label", true).Text = block.Text
		values[key] = if table.find(optionList, value) then value else optionList[1]

		for optionIndex: number, option: string in ipairs(optionList) do
			local pill: GuiObject = Module.Clone("ChoiceOption", options)
			local label: TextLabel = pill:FindFirstChild("S_Label", true)
			local measure: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
			measure.Text = option
			measure.Font = label.FontFace
			measure.Size = label.TextSize
			measure.Width = 1000
			local width: number = I.S.TextService:GetTextBoundsAsync(measure).X
			label.Text = option
			pill.LayoutOrder = optionIndex
			pill.Size = UDim2.fromOffset(math.ceil(width) + OPTION_PADDING, OPTION_HEIGHT)
			table.insert(pills, pill)
			table.insert(
				connections,
				pill:FindFirstChild("S_Button", true).Activated:Connect(function()
					values[key] = option
					Module._paintChoice(pills, optionList, option)

					-- Run only a block with a callback
					if block.Run then
						run()
					end
				end)
			)
		end
		Module._paintChoice(pills, optionList, values[key])
		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Give

	if block.Type == "Give" then
		local root: GuiObject = Module.Clone("GiveBlock", parent)
		local amount: TextBox = root:FindFirstChild("S_Amount", true)
		local items: Frame = root:FindFirstChild("S_Items", true)
		local give: ImageButton = root:FindFirstChild("S_Give", true)
		local itemList = block.Items or {} --- @type { AdminPanel_DashboardItem }
		local tiles = {} --- @type { GuiObject }
		local picked: number = 0

		--%%%%%%%%%%%%%%%%%%%% Show Give

		--[[
			Lights the picked tile and says what Give gives, then keeps the pick and amount as the block's value.
		]]
		local function showGive()
			Module._showGive(root, tiles, itemList, picked, page.Name)
			values[key] = if picked > 0 then { Item = itemList[picked].Name, Amount = math.max(1, math.floor(I.Number.ToNumberOr(amount.Text, 1))) } else nil
		end

		--- @param item AdminPanel_DashboardItem
		for itemIndex: number, item in ipairs(itemList) do
			local tile: GuiObject = Module.Clone("ItemTile", items)
			local tileIcon: ImageLabel = tile:FindFirstChild("S_Icon", true)
			tileIcon.Image = item.Icon or ""
			tileIcon.BackgroundColor3 = item.Color or colors.Off
			tile:FindFirstChild("S_Name", true).Text = item.Name
			tile.LayoutOrder = itemIndex
			table.insert(tiles, tile)
			table.insert(
				connections,
				tile:FindFirstChild("S_Button", true).Activated:Connect(function()
					picked = itemIndex
					showGive()
				end)
			)
		end

		table.insert(connections, amount:GetPropertyChangedSignal("Text"):Connect(showGive))

		-- Run only a block with a callback, once an item is picked
		if block.Run then
			table.insert(
				connections,
				give.Activated:Connect(function()
					if picked > 0 then
						run()
					end
				end)
			)
		end

		showGive()
		return root
	end

	--%%%%%%%%%%%%%%%%%%%% Info

	local root: GuiObject = Module.Clone("InfoRow", parent)
	root:FindFirstChild("S_Label", true).Text = block.Text
	root:FindFirstChild("S_Value", true).Text = if value ~= nil then tostring(value) else ""
	return root
end

--%%%%%%%%%%%%%%%%%%%% Show Give

--[[
	Outlines a Give block's picked tile with the accent, fills its Give button with it, and says what Give gives the
	page's player.
]]
--- @param tiles { GuiObject }
--- @param itemList { AdminPanel_DashboardItem }
function Module._showGive(root: GuiObject, tiles, itemList, picked: number, target: string)
	--[[ Elements ]]

	local give: ImageButton = root:FindFirstChild("S_Give", true)
	local giveLabel: TextLabel = root:FindFirstChild("S_GiveLabel", true)
	local hint: TextLabel = root:FindFirstChild("S_GiveHint", true)
	local amount: TextBox = root:FindFirstChild("S_Amount", true)

	--[[ Tiles ]]

	for index: number, tile: GuiObject in ipairs(tiles) do
		local button: ImageButton = tile:FindFirstChild("S_Button", true)
		local stroke: UIStroke = button:FindFirstChildOfClass("UIStroke")
		button.BackgroundTransparency = if index == picked then 0.9 else 0.95
		stroke.Color = if index == picked then accent else _settings.DASHBOARD_COLORS.Surface
		stroke.Transparency = if index == picked then 0.2 else 0.92
	end

	--[[ Button ]]

	give.BackgroundColor3 = accent
	giveLabel.TextColor3 = if I.Color.GetColorLuminance(accent) > 0.5 then _settings.DASHBOARD_COLORS.Dark else _settings.DASHBOARD_COLORS.Text

	--[[ Checks ]]

	-- Ask for an item until one is picked
	if picked == 0 then
		hint.Text = "Pick an item to give"
		return
	end

	--[[ Hint ]]

	hint.Text = `Gives {math.max(1, math.floor(I.Number.ToNumberOr(amount.Text, 1)))} × {itemList[picked].Name} to {target}`
end

--%%%%%%%%%%%%%%%%%%%% Paint Toggle

--[[
	Shows a switch on or off: on, its fill, outline and dot take the accent and its name brightens.
]]
function Module._paintToggle(button: ImageButton, on: boolean)
	--[[ Elements ]]

	local stroke: UIStroke = button:FindFirstChildOfClass("UIStroke")
	local label: TextLabel = button:FindFirstChild("S_Label")
	local dot: Frame = button:FindFirstChild("S_State")

	--[[ Applying ]]

	button.BackgroundColor3 = if on then accent else _settings.DASHBOARD_COLORS.Surface
	button.BackgroundTransparency = if on then 0.85 else 0.95
	stroke.Color = if on then accent else _settings.DASHBOARD_COLORS.Surface
	stroke.Transparency = if on then 0.3 else 0.92
	label.TextColor3 = if on then _settings.DASHBOARD_COLORS.Text else _settings.DASHBOARD_COLORS.Label
	dot.BackgroundColor3 = if on then accent else _settings.DASHBOARD_COLORS.Off
end

--%%%%%%%%%%%%%%%%%%%% Paint Choice

--[[
	Fills the picked option's pill with the accent and brightens its text; the others go back to the plain button.
]]
--- @param pills { GuiObject }
--- @param options { string }
function Module._paintChoice(pills, options, picked: string?)
	--[[ Applying ]]

	for index: number, pill: GuiObject in ipairs(pills) do
		local button: ImageButton = pill:FindFirstChild("S_Button", true)
		local label: TextLabel = pill:FindFirstChild("S_Label", true)
		button.BackgroundColor3 = if options[index] == picked then accent else _settings.DASHBOARD_COLORS.Surface
		button.BackgroundTransparency = if options[index] == picked then 0.8 else 0.95
		label.TextColor3 = if options[index] == picked then _settings.DASHBOARD_COLORS.Text else _settings.DASHBOARD_COLORS.Label
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Slider At

--[[
	Sets a slider to the value under a point across its track.
]]
--- @param slider AdminPanel_DashboardSlider
function Module._setSliderAt(slider, x: number)
	--[[ Local Variables ]]

	local block = slider.Block --- @type AdminPanel_DashboardPageBlock
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
--- @param slider AdminPanel_DashboardSlider
function Module._setSlider(slider, value: number)
	--[[ Local Variables ]]

	local block = slider.Block --- @type AdminPanel_DashboardPageBlock
	local step: number = block.Step or 1
	local rounded: number = math.clamp(math.round(value / step) * step, block.Min, block.Max)
	local share: number = (rounded - block.Min) / math.max(block.Max - block.Min, 1e-9)

	-- As many decimals as the step has
	local decimals: number = if step % 1 == 0 then 0 else math.max(0, math.ceil(-math.log10(step % 1)))
	local text: string = string.format(`%.{decimals}f`, rounded)

	--[[ Applying ]]

	values[slider.Key] = rounded
	slider.Root:FindFirstChild("S_Fill", true).Size = UDim2.fromScale(share, 1)
	slider.Root:FindFirstChild("S_Knob", true).Position = UDim2.fromScale(share, 0.5)
	slider.Root:FindFirstChild("S_Value", true).Text = if block.Format then string.gsub(block.Format, "{}", text) else text
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
	Ends a slider's drag when the click or touch is let go, running the slider when it has a callback.
]]
function Module._onSliderEnded(input: InputObject)
	--[[ Checks ]]

	-- Skip anything but the end of a click or a touch during a drag
	if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then
		return
	end

	--[[ Running ]]

	local slider = dragging --- @type AdminPanel_DashboardSlider
	dragging = nil

	-- Run a slider with a callback
	if slider.Run then
		slider.Run()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Section Values

--[[
	Returns the value of every block in a section, by block id.
]]
--- @param section AdminPanel_DashboardPageSection
--- @return { [string]: any }
function Module._getSectionValues(pageId: string, section)
	--[[ Local Variables ]]

	local sectionValues = {} --- @type { [string]: any }

	--[[ Collecting ]]

	--- @param block AdminPanel_DashboardPageBlock
	for _index: number, block in ipairs(section.Blocks) do
		sectionValues[block.Id] = values[getValueKey(pageId, section, block.Id)]
	end

	--[[ Returning ]]

	return sectionValues
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
