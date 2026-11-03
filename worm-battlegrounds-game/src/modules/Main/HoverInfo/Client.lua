--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "HoverInfo"

--- @type HoverInfo_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ General ]]

local moduleGui: ScreenGui

--[[ Providers ]]

local providers = {} --- @type { [string]: HoverInfo_Provider }

--[[ Shown ]]

local shownTarget: GuiObject? = nil
local shownInput = "Mouse" --- @type HoverInfo_Input
local shownRows = {} --- @type { GuiObject }
local followConnection: RBXScriptConnection? = nil

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()
	Module._applyScreenScale()
	Module._createConnections()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Component
	I.Component.RegisterOnLoaded("HoverInfo_Target", _components.Target)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.HoverInfo = {

		--[[ Control ]]

		Show = Module.Show,
		Hide = Module.Hide,
		RegisterProvider = Module.RegisterProvider,

		--[[ Methods ]]

		GetContent = Module.GetContent,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]

	--[[ General ]]

	elems["Box"] = moduleGui:FindFirstChild("U_HoverInfo", true) --- @type Frame
	elems["ScreenScale"] = elems["Box"]:FindFirstChild("S_ScreenScale") --- @type UIScale
	elems["Accent"] = elems["Box"]:FindFirstChild("S_Accent", true) --- @type Frame
	elems["Content"] = elems["Box"]:FindFirstChild("S_Content") --- @type Frame
	elems["Divider"] = elems["Box"]:FindFirstChild("S_Divider", true) --- @type Frame

	elems["Header"] = elems["Box"]:FindFirstChild("U_Header", true) --- @type Frame
	elems["Top"] = elems["Header"]:FindFirstChild("S_Top") --- @type Frame
	elems["Rarity"] = elems["Top"]:FindFirstChild("S_Rarity") --- @type TextLabel
	elems["RarityGlow"] = elems["Top"]:FindFirstChild("S_RarityGlow") --- @type TextLabel
	elems["Tier"] = elems["Top"]:FindFirstChild("S_Tier") --- @type TextLabel
	elems["Name"] = elems["Header"]:FindFirstChild("S_Name") --- @type TextLabel

	elems["Stats"] = elems["Box"]:FindFirstChild("U_Stats", true) --- @type Frame

	elems["Level"] = elems["Box"]:FindFirstChild("U_Level", true) --- @type Frame
	elems["LevelText"] = elems["Level"]:FindFirstChild("S_Level") --- @type TextLabel
	elems["Xp"] = elems["Level"]:FindFirstChild("S_Xp") --- @type TextLabel
	elems["XpFill"] = elems["Level"]:FindFirstChild("S_XpFill", true) --- @type Frame

	elems["Enchantments"] = elems["Box"]:FindFirstChild("U_Enchantments", true) --- @type Frame

	--[[ Prefab ]]

	prefabs["Stat"] = elems["Stats"]:FindFirstChild("PREFAB | Stat") --- @type Frame
	prefabs["Enchantment"] = elems["Enchantments"]:FindFirstChild("PREFAB | Enchantment") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Scales the box with the screen, fits its height to its rows, follows a gamepad's pick, and hides the box on a mouse
	press.
]]
function Module._createConnections()
	--[[ Screen ]]

	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Module._applyScreenScale)

	--[[ Height ]]

	-- The rows' height, at 1080, is the box's: an AutomaticSize box would never shrink, since its glass is sized by it
	elems["Content"]:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		elems["Box"].Size = UDim2.new(elems["Box"].Size.X, UDim.new(0, elems["Content"].AbsoluteSize.Y / elems["ScreenScale"].Scale))
	end)

	--[[ Gamepad ]]

	I.S.GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(Module._onSelectionChanged)

	--[[ Mouse ]]

	-- A press (a click, the start of a drag) hides the box until the mouse enters again
	I.S.UserInputService.InputBegan:Connect(function(input: InputObject)
		if shownInput == "Mouse" and input.UserInputType == Enum.UserInputType.MouseButton1 then
			Module.Hide()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	**CLIENT** |
	Shows the box for a hovered element, filled from its content (`GetContent`), and keeps it by the pointer: right of and
	under the mouse, or above the element for a finger or a gamepad. An element with no content hides the box.
]]
--- @param input HoverInfo_Input?
function Module.Show(target: GuiObject, input)
	--[[ Data ]]

	local content = Module.GetContent(target) --- @type HoverInfo_Content?

	--[[ Checks ]]

	-- Check if the element has anything to show
	if not content then
		Module.Hide()
		return
	end

	--[[ Saving ]]

	shownTarget = target
	shownInput = input or "Mouse"

	--[[ Showing ]]

	Module._draw(content)
	elems["Box"].Visible = true
	Module._place()

	-- Follow the pointer only while the box shows
	if not followConnection then
		followConnection = I.S.RunService.RenderStepped:Connect(Module._follow)
	end
end

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	**CLIENT** |
	Hides the box; with a `target`, only when it shows for that element.
]]
function Module.Hide(target: GuiObject?)
	--[[ Checks ]]

	-- Check if the box shows for another element
	if target and target ~= shownTarget then
		return
	end

	--[[ Hiding ]]

	shownTarget = nil
	elems["Box"].Visible = false

	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Provider

--[[
	**CLIENT** |
	Names a function that gives the content of the elements whose `HoverInfo_Provider` attribute is that name.
]]
--- @param provider HoverInfo_Provider
function Module.RegisterProvider(name: string, provider)
	--[[ Checks ]]

	-- Check if the name is taken
	if providers[name] then
		warn(`[{_localName}::{script.Name}]: Provider ({name}) is already registered!`)
		return
	end

	--[[ Saving ]]

	providers[name] = provider
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Writes a content into the box: the rarity in its look and its colour on the top line, the tier and the name, then a
	row per stat, the level with its XP, and a row per enchantment, hiding the parts it doesn't have.
]]
--- @param content HoverInfo_Content
function Module._draw(content)
	--[[ Data ]]

	local look = if content.Rarity then I.Rarity.GetLook(content.Rarity) else nil --- @type Rarity_Look?

	--[[ Local Variables ]]

	local stats = content.Stats or {} --- @type { HoverInfo_Stat }
	local enchantments = content.Enchantments or {} --- @type { HoverInfo_Enchantment }
	local level = content.Level --- @type HoverInfo_Level?

	--[[ Header ]]

	elems["Rarity"].Visible = look ~= nil
	elems["RarityGlow"].Visible = false
	if look then
		I.Rarity.ApplyLook(elems["Rarity"], elems["RarityGlow"], content.Rarity)
	end
	elems["Accent"].BackgroundColor3 = if look then look.Base else _settings.ACCENT_COLOR
	elems["Tier"].Visible = content.Tier ~= nil
	elems["Tier"].Text = if content.Tier then Module._getSpaced(`TIER {content.Tier}`) else ""
	elems["Top"].Visible = look ~= nil or content.Tier ~= nil
	elems["Name"].Text = content.Name
	elems["Name"].Size = UDim2.new(1, 0, 0, Module._getNameHeight(content.Name))

	--[[ Clearing ]]

	for _index: number, row: GuiObject in ipairs(shownRows) do
		row:Destroy()
	end
	table.clear(shownRows)

	--[[ Stats ]]

	--- @param stat HoverInfo_Stat
	for index: number, stat in ipairs(stats) do
		local row: Frame = prefabs["Stat"]:Clone()
		row.Name = "Stat"
		row.LayoutOrder = index
		row:FindFirstChild("S_Label").Text = Module._getSpaced(string.upper(stat.Label))
		row:FindFirstChild("S_Value").Text = stat.Value
		row:FindFirstChild("S_Value").TextColor3 = stat.Color or Color3.fromRGB(255, 255, 255)
		if stat.Badge then
			local badge: TextLabel = row:FindFirstChild("S_Badge")
			badge.Text = stat.Badge.Text
			badge.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, stat.Badge.Colors[1]),
				ColorSequenceKeypoint.new(0.5, stat.Badge.Colors[2]),
				ColorSequenceKeypoint.new(1, stat.Badge.Colors[3]),
			})
			badge.UIStroke.Color = stat.Badge.Stroke
			badge.Visible = true
		end
		row.Visible = true
		row.Parent = elems["Stats"]
		table.insert(shownRows, row)
	end
	elems["Stats"].Visible = #stats > 0

	--[[ Level ]]

	elems["Level"].Visible = level ~= nil
	if level then
		elems["LevelText"].Text = `Level {level.Level}`
		elems["Xp"].Text = level.Xp
		elems["XpFill"].Size = UDim2.fromScale(math.clamp(level.Progress, 0, 1), 1)
		-- An empty fill would still draw its outline as a sliver
		elems["XpFill"].Visible = level.Progress > 0
	end

	--[[ Enchantments ]]

	--- @param enchantment HoverInfo_Enchantment
	for index: number, enchantment in ipairs(enchantments) do
		local row: Frame = prefabs["Enchantment"]:Clone()
		row.Name = "Enchantment"
		row.LayoutOrder = index
		row:FindFirstChild("S_Name").Text = enchantment.Name
		row:FindFirstChild("S_Level").Text = _settings.NUMERALS[enchantment.Level] or tostring(enchantment.Level)
		row.Visible = true
		row.Parent = elems["Enchantments"]
		table.insert(shownRows, row)
	end
	elems["Enchantments"].Visible = #enchantments > 0

	--[[ Divider ]]

	elems["Divider"].Visible = #stats > 0 or level ~= nil or #enchantments > 0
end

--%%%%%%%%%%%%%%%%%%%% Follow

--[[
	Keeps the shown box by the pointer each frame, and hides it once its element is gone or hidden.
]]
function Module._follow()
	--[[ Checks ]]

	-- Check if the element is still on screen
	if not shownTarget or not shownTarget:IsDescendantOf(game) or not I.Utils.IsGuiShown(shownTarget) then
		Module.Hide()
		return
	end

	--[[ Placing ]]

	Module._place()
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Puts the box by the pointer, inside the screen: right of and under the mouse (left or above it when it doesn't fit
	there), or centred above the element for a finger or a gamepad (under it when it doesn't fit above).
]]
function Module._place()
	--[[ Local Variables ]]

	local target: GuiObject = shownTarget
	local viewport: Vector2 = moduleGui.AbsoluteSize
	local size: Vector2 = elems["Box"].AbsoluteSize
	local gap: number = _settings.POINTER_GAP
	local margin: number = _settings.EDGE_MARGIN
	local x: number
	local y: number

	--[[ Calculating ]]

	if shownInput == "Mouse" then
		local mouse: Vector2 = I.S.UserInputService:GetMouseLocation()
		x = mouse.X + gap
		y = mouse.Y + gap

		-- Flip to the mouse's other side where the box doesn't fit
		if x + size.X > viewport.X - margin then
			x = mouse.X - gap - size.X
		end
		if y + size.Y > viewport.Y - margin then
			y = mouse.Y - gap - size.Y
		end
	else
		-- The element's top left on this gui, which starts at the screen's top
		local layer: LayerCollector = target:FindFirstAncestorWhichIsA("LayerCollector")
		local position: Vector2 = target.AbsolutePosition + layer.AbsolutePosition - moduleGui.AbsolutePosition
		x = position.X + (target.AbsoluteSize.X - size.X) / 2
		y = position.Y - gap - size.Y

		-- Drop under the element when the box doesn't fit above it
		if y < margin then
			y = position.Y + target.AbsoluteSize.Y + gap
		end
	end

	--[[ Applying ]]

	x = math.clamp(x, margin, math.max(margin, viewport.X - margin - size.X))
	y = math.clamp(y, margin, math.max(margin, viewport.Y - margin - size.Y))
	elems["Box"].Position = UDim2.fromOffset(x + size.X / 2, y + size.Y / 2)
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the box to the screen: its height over the design height, bigger on short Mobile screens.
]]
function Module._applyScreenScale()
	--[[ Local Variables ]]

	local height: number = I.Env.Camera.ViewportSize.Y
	local scale: number = height / _settings.DESIGN_HEIGHT

	-- Boost short touch screens, as every window does
	if I.Platform.Current == "Mobile" and height < _settings.SMALL_SCREEN then
		scale *= _settings.MOBILE_BOOST
	end

	--[[ Applying ]]

	elems["ScreenScale"].Scale = scale
end

--%%%%%%%%%%%%%%%%%%%% On Selection Changed

--[[
	Shows the box for a gamepad's pick when it is a hover target or inside one, and hides a gamepad's box otherwise.
]]
function Module._onSelectionChanged()
	--[[ Local Variables ]]

	local target: GuiObject? = I.S.GuiService.SelectedObject

	--[[ Finding ]]

	-- Walk up from the pick to the first hover target
	while target and not target:HasTag("HoverInfo_Target") do
		local parent: Instance? = target.Parent
		target = if parent and parent:IsA("GuiObject") then parent else nil
	end

	--[[ Applying ]]

	if target then
		Module.Show(target, "Gamepad")
	elseif shownInput == "Gamepad" then
		Module.Hide()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Content

--[[
	**CLIENT** |
	Returns what the box shows for an element: from the provider its `HoverInfo_Provider` attribute names, else its
	`HoverInfo_Title` (and `HoverInfo_Rarity`) attributes, else nil.
]]
--- @return HoverInfo_Content?
function Module.GetContent(target: GuiObject)
	--[[ Local Variables ]]

	local providerName: string = target:GetAttribute("HoverInfo_Provider") or ""
	local title: string = target:GetAttribute("HoverInfo_Title") or ""
	local rarity: string = target:GetAttribute("HoverInfo_Rarity") or ""

	--[[ Checks ]]

	-- Check if the provider is registered
	if providerName ~= "" and not providers[providerName] then
		warn(`[{_localName}::{script.Name}]: Provider ({providerName}) is not registered! -`, target)
		return nil
	end

	-- Check if the element has a provider or a title
	if providerName == "" and title == "" then
		return nil
	end

	--[[ Returning ]]

	return if providerName ~= "" then providers[providerName](target) else { Name = title, Rarity = if rarity ~= "" then rarity else nil }
end

--%%%%%%%%%%%%%%%%%%%% Get Name Height

--[[
	Returns the name's height at 1080 for the lines it wraps to at its design size, in the name label's own font, so a
	long name wraps instead of shrinking. One line's height when the font can't be measured.
]]
--- @return number
function Module._getNameHeight(name: string)
	--[[ Local Variables ]]

	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = name
	params.Font = elems["Name"].FontFace
	params.Size = _settings.NAME_TEXT_SIZE
	params.Width = _settings.NAME_WIDTH

	--[[ Measuring ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.TextService.GetTextBoundsAsync, I.S.TextService, params)

	--[[ Returning ]]

	return if success then math.max(_settings.NAME_HEIGHT, result.Y + _settings.NAME_HEIGHT - _settings.NAME_TEXT_SIZE) else _settings.NAME_HEIGHT
end

--%%%%%%%%%%%%%%%%%%%% Get Spaced

--[[
	Returns a text with a hair space between its letters, as the guis write their small capitals.
]]
--- @return string
function Module._getSpaced(text: string)
	return table.concat(string.split(text, ""), "\u{200A}")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
