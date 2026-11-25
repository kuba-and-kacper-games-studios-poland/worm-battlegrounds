--[[
    Created By:     Nari
    Edited By:     HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--- @type WidgetManager_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local dimGui: ScreenGui
local dimFrame: Frame

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

--- @class WidgetManager_Dim
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createDimWidget()
	Module._createDimFrame()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		Module._tweenDim(Module._getDimTransparency(widgetName))
	end)

	I.Topic.Subscribe("WidgetManager_Closed", function()
		Module._tweenDim(1)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Dim Widget

--[[
	Creates the dim `ScreenGui`, over the whole screen out to a phone's notch sides.
]]
function Module._createDimWidget()
	dimGui = Instance.new("ScreenGui")
	dimGui.Parent = I.Env.PlayerGui

	dimGui.DisplayOrder = _settings.DIM_ORDER
	dimGui.Enabled = true
	dimGui.IgnoreGuiInset = true
	dimGui.ScreenInsets = Enum.ScreenInsets.None
	dimGui.ClipToDeviceSafeArea = false
	dimGui.ResetOnSpawn = false
	dimGui.Name = "_Dim"
	dimGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
end

--%%%%%%%%%%%%%%%%%%%% Create Dim Frame

--[[
	Creates the dim `Frame`.
]]
function Module._createDimFrame()
	dimFrame = Instance.new("Frame")
	dimFrame.Parent = dimGui

	dimFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	dimFrame.Position = UDim2.fromScale(0.5, 0.5)
	dimFrame.Size = UDim2.fromScale(1, 1)
	dimFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dimFrame.BackgroundTransparency = 1
	dimFrame.BorderSizePixel = 0
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Showing

--%%%%%%%%%%%%%%%%%%%% Tween Dim

--[[
	Fades the dim to a transparency: a widget's (Get Dim Transparency) as it opens, 1 (gone) as it closes.
]]
function Module._tweenDim(transparency: number)
	--[[ Playing ]]

	local Dim_TweenInfo: TweenInfo = _settings.DIM_TWEENINFO
	local Dim_TweenGoal = { BackgroundTransparency = transparency }
	local Dim_Tween: Tween = TweenService:Create(dimFrame, Dim_TweenInfo, Dim_TweenGoal)
	Dim_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Dim Transparency

--[[
	Returns how see-through the dim is behind a widget: its U_Widget's WidgetManager_Dim attribute (a darker dim for a
	window the screen makes way for, like the match setups), else DIM_TRANSPARENCY.
]]
--- @return number
function Module._getDimTransparency(widgetName: string)
	--[[ Data ]]

	local gui: ScreenGui? = I.UserInterface.UI[widgetName]
	local widget: Instance? = gui and gui:FindFirstChild("U_Widget")

	--[[ Returning ]]

	return if widget and widget:GetAttribute("WidgetManager_Dim") then widget:GetAttribute("WidgetManager_Dim") else _settings.DIM_TRANSPARENCY
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
