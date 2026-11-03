--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Settings"

--- @type Settings_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ General ]]

local moduleGui: ScreenGui

--[[ Rows ]]

local switches = {} --- @type { [string]: ImageButton }
local steppers = {} --- @type { [string]: Frame }

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

--- @class Settings_Client_SettingsGui
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()
	Module._populate()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._createConnections()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the settings window's elements and hides its prefabs.
]]
function Module._getElements()
	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]

	--[[ General ]]

	elems["Widget"] = moduleGui:FindFirstChild("U_Widget") --- @type Frame
	elems["ScreenScale"] = elems["Widget"]:FindFirstChild("S_ScreenScale") --- @type UIScale
	elems["List"] = elems["Widget"]:FindFirstChild("U_List", true) --- @type ScrollingFrame

	--[[ Prefab ]]

	prefabs["Header"] = elems["List"]:FindFirstChild("PREFAB | Header") --- @type Frame
	prefabs["Setting"] = elems["List"]:FindFirstChild("PREFAB | Setting") --- @type Frame
	prefabs["Stepper"] = elems["List"]:FindFirstChild("PREFAB | Stepper") --- @type Frame
	prefabs["Header"].Visible = false
	prefabs["Setting"].Visible = false
	prefabs["Stepper"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Populate

--[[
	Places a heading for each group and a row for each setting under it, in the groups' and settings' order, each row
	in its group's colours: a switch that flips the setting, or a volume between two chevrons that step it.
]]
function Module._populate()
	--[[ Headers ]]

	--- @param sectionData Settings_Section
	for sectionName: string, sectionData in pairs(_settings.SECTIONS) do
		--[[ Cloning ]]

		local header: Frame = prefabs["Header"]:Clone()
		header.Name = sectionName
		header.LayoutOrder = sectionData.LayoutOrder * 100
		header.Visible = true

		--[[ Elements ]]

		local text: TextLabel = header:FindFirstChild("S_Text", true)

		--[[ Texts ]]

		text.Text = sectionData.Text
		text.UIGradient.Color = ColorSequence.new(sectionData.Colors[1], sectionData.Colors[2])

		--[[ Saving ]]

		header.Parent = elems["List"]
	end

	--[[ Settings ]]

	--- @param settingData Settings_Setting
	for settingName: string, settingData in pairs(_settings.SETTINGS) do
		--[[ Local Variables ]]

		--- @type Settings_Section
		local sectionData = _settings.SECTIONS[settingData.Section]
		local isVolume: boolean = typeof(settingData.Default) == "number"

		--[[ Cloning ]]

		local row: Frame = prefabs[if isVolume then "Stepper" else "Setting"]:Clone()
		row.Name = settingName
		row.LayoutOrder = sectionData.LayoutOrder * 100 + settingData.LayoutOrder
		row.Visible = true

		--[[ Elements ]]

		local name: TextLabel = row:FindFirstChild("S_Name", true)
		local detail: TextLabel = row:FindFirstChild("S_Detail", true)
		local switch: ImageButton? = row:FindFirstChild("S_Switch", true)
		local left: ImageButton? = row:FindFirstChild("S_Left", true)
		local right: ImageButton? = row:FindFirstChild("S_Right", true)
		local valueBox: Frame? = row:FindFirstChild("ValueBox", true)

		--[[ Texts ]]

		name.Text = settingData.Text
		detail.Text = settingData.Detail

		-- A setting without a detail line centres its name in the row
		if settingData.Detail == "" then
			name.Position = UDim2.new(name.Position.X, UDim.new(0.5, 0))
		end

		--[[ Background Color ]]

		row.UIStroke.Color = sectionData.Colors[2]
		row.UIStroke.Transparency = _settings.ACCENT_TRANSPARENCY
		row:FindFirstChild("Tint").BackgroundColor3 = sectionData.Colors[2]

		-- A volume's box is outlined in the group's colour too
		if isVolume then
			valueBox.UIStroke.Color = sectionData.Colors[2]
		end

		--[[ Buttons ]]

		if isVolume then
			I.Interact.OnPress(left, function()
				Module._stepVolume(settingName, -1)
			end)
			I.Interact.OnPress(right, function()
				Module._stepVolume(settingName, 1)
			end)
		else
			I.Interact.OnPress(switch, function()
				I.PlayerSettings.Set(settingName, not I.PlayerSettings.Get(settingName))
			end)
		end

		--[[ Saving ]]

		row.Parent = elems["List"]

		if isVolume then
			steppers[settingName] = row
		else
			switches[settingName] = switch
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Redraws the window each time it opens, and keeps it scaled to the screen.
]]
function Module._createConnections()
	--[[ Opened ]]

	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		-- Skip every other widget
		if widgetName ~= _settings.GUI_NAME then
			return
		end

		Module._applyScreenScale()
		Module.Refresh()
	end)

	--[[ Screen ]]

	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Module._applyScreenScale)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows every setting as it is now: a switch green with On or red with Off, a volume's value with its chevrons.
]]
function Module.Refresh()
	--[[ Checks ]]

	-- Check if the window is open
	if not moduleGui.Enabled then
		return
	end

	--[[ Switches ]]

	for settingName: string, switch: ImageButton in pairs(switches) do
		Module._setSwitchLook(switch, I.PlayerSettings.Get(settingName))
	end

	--[[ Volumes ]]

	for settingName: string, row: Frame in pairs(steppers) do
		Module._setStepperLook(row, I.PlayerSettings.Get(settingName))
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Volume

--[[
	Moves a volume one VOLUME_STEP down (-1) or up (1), kept between 0 and VOLUME_MAX.
]]
function Module._stepVolume(settingName: string, direction: number)
	--[[ Local Variables ]]

	local volume: number = I.PlayerSettings.Get(settingName)
	local stepped: number = math.clamp(volume + direction * _settings.VOLUME_STEP, 0, _settings.VOLUME_MAX)

	--[[ Checks ]]

	-- Check if the volume is already at that end
	if stepped == volume then
		return
	end

	--[[ Saving ]]

	I.PlayerSettings.Set(settingName, stepped)
end

--%%%%%%%%%%%%%%%%%%%% Set Switch Look

--[[
	Colours a switch from SWITCH_LOOKS and writes its word, On or Off.
]]
function Module._setSwitchLook(switch: ImageButton, on: boolean)
	--[[ Local Variables ]]

	local label: TextLabel = switch:FindFirstChild("ButtonText", true)

	--[[ Applying ]]

	Module._setButtonColors(switch, _settings.SWITCH_LOOKS[on])
	label.Text = _settings.SWITCH_TEXTS[on]
end

--%%%%%%%%%%%%%%%%%%%% Set Stepper Look

--[[
	Writes a volume into its box (Off at 0, else a percentage) and locks the chevron at the end it has reached.
]]
function Module._setStepperLook(row: Frame, volume: number)
	--[[ Local Variables ]]

	local value: TextLabel = row:FindFirstChild("S_Value", true)
	local left: ImageButton = row:FindFirstChild("S_Left", true)
	local right: ImageButton = row:FindFirstChild("S_Right", true)
	local canLower: boolean = volume > 0
	local canRaise: boolean = volume < _settings.VOLUME_MAX

	--[[ Applying ]]

	value.Text = if canLower then `{volume}%` else _settings.SWITCH_TEXTS[false]
	Module._setButtonColors(left, _settings.CHEVRON_LOOKS[canLower])
	Module._setButtonColors(right, _settings.CHEVRON_LOOKS[canRaise])
	left.Active = canLower
	right.Active = canRaise
end

--%%%%%%%%%%%%%%%%%%%% Set Button Colors

--[[
	Colours a switch or a chevron: its gradient on both its faces, as ume-gui's System buttons have it.
]]
function Module._setButtonColors(button: ImageButton, colors: ColorSequence)
	--[[ Applying ]]

	button:FindFirstChild("Background_Front"):FindFirstChildOfClass("UIGradient").Color = colors
	button:FindFirstChild("Background_Back"):FindFirstChildOfClass("UIGradient").Color = colors
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the window to the screen: its height over the design height, bigger on short Mobile screens.
]]
function Module._applyScreenScale()
	--[[ Local Variables ]]

	local height: number = I.Env.Camera.ViewportSize.Y
	local scale: number = height / _settings.DESIGN_HEIGHT

	-- Boost short touch screens so the switches stay big enough to tap
	if I.Platform.Current == "Mobile" and height < _settings.SMALL_SCREEN then
		scale *= _settings.MOBILE_BOOST
	end

	--[[ Applying ]]

	elems["ScreenScale"].Scale = scale
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
