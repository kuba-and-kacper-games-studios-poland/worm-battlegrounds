--[[
	Created By: 	HungryN00B
]]

local _localName: string = "SettingsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Settings ]]

-- ume's Settings module's rows: the Sound group's volumes (0 to 100), then a group of switches a game adds, each with
-- what it does (empty when the name says it all)
--- @type { { [string]: any } }
local ROWS = {
	{ Header = "Sound" },
	{ Name = "Master", Detail = "", Volume = 100 },
	{ Name = "Music", Detail = "", Volume = 50 },
	{ Name = "Sound Effects", Detail = "", Volume = 50 },
	{ Header = "Gameplay" },
	{ Name = "Show tips", Detail = "Hints while you play", On = true },
	{ Name = "Camera shake", Detail = "", On = false },
}

-- Each group's colours (light, then dark): its heading's gradient, its rows' outline and tint
--- @type { [string]: { Color3 } }
local GROUPS = {
	Sound = { Color3.fromRGB(230, 205, 255), Color3.fromRGB(150, 110, 255) },
	Gameplay = { Color3.fromRGB(200, 255, 150), Color3.fromRGB(60, 200, 70) },
}

--[[ Looks ]]

-- A switch's gradient (bottom to top) on and off, and a chevron's while it can step and at the end, as ume's Settings
-- module's SWITCH_LOOKS and CHEVRON_LOOKS (System/_Primitives_ButtonsColors' Accept, Cancel, Blue and Gray)
--- @type { [boolean]: ColorSequence }
local SWITCH_LOOKS = {
	[true] = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)),
	[false] = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)),
}
--- @type { [boolean]: ColorSequence }
local CHEVRON_LOOKS = {
	[true] = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)),
	[false] = ColorSequence.new(Color3.fromRGB(130, 143, 162), Color3.fromRGB(205, 220, 252)),
}

--[[ Steppers ]]

-- How much one chevron press changes a volume, and its range
local VOLUME_STEP: number = 10
local VOLUME_MAX: number = 100

--[[ Screen ]]

-- The screen height the window is laid out for, and the boost on short Mobile screens, as ume's Settings module's
local DESIGN_HEIGHT: number = 1080
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3

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

--- @class UmeGui_Guis_WormBattlegrounds_Settings_Preview
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Lists the settings in their groups as ume's Settings module does, each group in its colours, each switch at its
	default and each volume between its chevrons; clicking a switch flips it, a chevron steps the volume.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local headers = {} --- @type { { [string]: any } }
	local settings = {} --- @type { { [string]: any } }
	local steppers = {} --- @type { { [string]: any } }
	local colors = {} --- @type { Color3 }

	--[[ Sorting ]]

	-- Each row takes its group's colours, from the header above it
	for order: number, row: { [string]: any } in ipairs(ROWS) do
		colors = if row.Header then GROUPS[row.Header] else colors
		row.Order = order
		row.Colors = colors
		table.insert(if row.Header then headers elseif row.Volume then steppers else settings, row)
	end

	--[[ Headers ]]

	local headerRows = preview.Fill("PREFAB | Header", #headers) --- @type { UmeGui_Subview }

	--- @param header UmeGui_Subview
	for index: number, header in ipairs(headerRows) do
		local text: TextLabel = header:Get("S_Text").Instance
		header.Root.Instance.LayoutOrder = headers[index].Order
		text.Text = headers[index].Header
		text:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new(headers[index].Colors[1], headers[index].Colors[2])
	end

	--[[ Settings ]]

	local settingRows = preview.Fill("PREFAB | Setting", #settings) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(settingRows) do
		local setting = settings[index] --- @type { [string]: any }
		local switch: ImageButton = row:Get("S_Switch").Instance
		local on: boolean = setting.On
		Module._applyRow(row, setting)
		Module._applySwitch(switch, on)

		switch.Activated:Connect(function()
			on = not on
			Module._applySwitch(switch, on)
		end)
	end

	--[[ Steppers ]]

	local stepperRows = preview.Fill("PREFAB | Stepper", #steppers) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(stepperRows) do
		local setting = steppers[index] --- @type { [string]: any }
		local volume: number = setting.Volume
		Module._applyRow(row, setting)
		row.Root.Instance:FindFirstChild("ValueBox", true):FindFirstChildOfClass("UIStroke").Color = setting.Colors[2]
		Module._applyVolume(row, volume)

		row:Get("S_Left").Instance.Activated:Connect(function()
			volume = math.max(0, volume - VOLUME_STEP)
			Module._applyVolume(row, volume)
		end)
		row:Get("S_Right").Instance.Activated:Connect(function()
			volume = math.min(VOLUME_MAX, volume + VOLUME_STEP)
			Module._applyVolume(row, volume)
		end)
	end

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Row

--[[
	Writes a row's name and detail line (a name with no detail centred in the row), and colours its outline and tint in
	its group's colour.
]]
--- @param row UmeGui_Subview
--- @param setting { [string]: any }
function Module._applyRow(row, setting)
	--[[ Local Variables ]]

	local root: Frame = row.Root.Instance
	local name: TextLabel = row:Get("S_Name").Instance

	--[[ Texts ]]

	root.LayoutOrder = setting.Order
	name.Text = setting.Name
	row:Get("S_Detail").Instance.Text = setting.Detail

	-- A setting without a detail line centres its name in the row
	if setting.Detail == "" then
		name.Position = UDim2.new(name.Position.X, UDim.new(0.5, 0))
	end

	--[[ Colors ]]

	root:FindFirstChildOfClass("UIStroke").Color = setting.Colors[2]
	root:FindFirstChild("Tint").BackgroundColor3 = setting.Colors[2]
end

--%%%%%%%%%%%%%%%%%%%% Apply Switch

--[[
	Turns a switch on (green, On) or off (red, Off).
]]
function Module._applySwitch(switch: ImageButton, on: boolean)
	--[[ Applying ]]

	Module._setButtonColors(switch, SWITCH_LOOKS[on])
	switch:FindFirstChild("ButtonText", true).Text = if on then "On" else "Off"
end

--%%%%%%%%%%%%%%%%%%%% Apply Volume

--[[
	Writes a volume into its box (Off at 0) and greys out the chevron at the end it has reached, which stops taking
	presses; the other stays blue.
]]
--- @param row UmeGui_Subview
function Module._applyVolume(row, volume: number)
	--[[ Local Variables ]]

	local left: ImageButton = row:Get("S_Left").Instance
	local right: ImageButton = row:Get("S_Right").Instance

	--[[ Applying ]]

	row:Get("S_Value").Instance.Text = if volume == 0 then "Off" else `{volume}%`
	Module._setButtonColors(left, CHEVRON_LOOKS[volume > 0])
	Module._setButtonColors(right, CHEVRON_LOOKS[volume < VOLUME_MAX])
	left.Active = volume > 0
	right.Active = volume < VOLUME_MAX
end

--%%%%%%%%%%%%%%%%%%%% Set Button Colors

--[[
	Gives a button its gradient on both its faces, as the System buttons have it.
]]
function Module._setButtonColors(button: ImageButton, colors: ColorSequence)
	--[[ Applying ]]

	button:FindFirstChild("Background_Front"):FindFirstChildOfClass("UIGradient").Color = colors
	button:FindFirstChild("Background_Back"):FindFirstChildOfClass("UIGradient").Color = colors
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the window to the previewed screen as ume's Settings module does: its height over the design height, bigger
	on short Mobile screens.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local scale: number = height / DESIGN_HEIGHT

	-- Boost short touch screens so the buttons stay big enough to tap
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	end

	--[[ Applying ]]

	preview.View:Get("U_Widget", "S_ScreenScale").Instance.Scale = scale
end

return Module
