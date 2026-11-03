--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--- @type WidgetManager_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Elements ]]

local dimGui: ScreenGui
local dimFrame: Frame

--[[ Other ]]

--- @type { [boolean]: Tween }
local dimTweens = {}

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
	Module._createTweens()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("WidgetManager_Opened", function()
		Module._tweenDim(true)
	end)

	I.Topic.Subscribe("WidgetManager_Closed", function()
		Module._tweenDim(false)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Dim Widget

--[[
	Creates the dim `ScreenGui`.
]]
function Module._createDimWidget()
	dimGui = Instance.new("ScreenGui")
	dimGui.Parent = I.Env.PlayerGui

	dimGui.DisplayOrder = _settings.DIM_ORDER
	dimGui.Enabled = true
	dimGui.IgnoreGuiInset = true
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

--%%%%%%%%%%%%%%%%%%%% Create Tweens

--[[
	Creates Tweens for the Dim.
]]
function Module._createTweens()
	dimTweens[true] = TweenService:Create(dimFrame, _settings.DIM_TWEENINFO, { BackgroundTransparency = _settings.DIM_TRANSPARENCY })
	dimTweens[false] = TweenService:Create(dimFrame, _settings.DIM_TWEENINFO, { BackgroundTransparency = 1 })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Showing

--%%%%%%%%%%%%%%%%%%%% Tween Dim

--[[
	Plays Tween for the Dim.
]]
function Module._tweenDim(show: boolean)
	if dimTweens[show] then
		dimTweens[show]:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
