--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local matchFolder: Folder

-- The player's Statistic folder in the Replicator (their MatchesPlayed), once it's there
local statisticRep: Folder? = nil

-- The tip over the strip now (HINT_TIPS)
local tipIndex: number = 1

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

--- @class MatchHud_Client_Hints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.HINTS_GUI_NAME]
	elems["Tip"] = moduleGui:FindFirstChild("S_Tip", true) --- @type TextLabel
	elems["TipStroke"] = elems["Tip"]:FindFirstChildOfClass("UIStroke") --- @type UIStroke

	--[[ Connections ]]

	matchFolder = I.Match.GetFolder()
	matchFolder:GetAttributeChangedSignal("Kind"):Connect(Module._refresh)
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.DoEvery.Every(_settings.HINT_TIP_SECONDS, Module._nextTip)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's MatchesPlayed statistic, which hides the strip for good once it reaches HINTS_MATCHES.
]]
function Module._connectReplicator()
	--[[ Data ]]

	statisticRep = I.Replicator.GetFolder("Statistic")
	if not statisticRep then
		return
	end

	--[[ Connections ]]

	statisticRep:GetAttributeChangedSignal("MatchesPlayed"):Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the strip while the player waits for the match and picks where to land, in their first HINTS_MATCHES matches
	only (their MatchesPlayed, hidden until it's known) and never in the tutorial match. Each device sees its own row
	(Utils_HideOnPlatform), so picking up a pad switches it at once.
]]
function Module._refresh()
	--[[ Data ]]

	local played: number? = if statisticRep then tonumber(statisticRep:GetAttribute("MatchesPlayed")) else nil

	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local waiting: boolean = phase == "Waiting" or phase == "Drop"
	local learning: boolean = played ~= nil and played < _settings.HINTS_MATCHES
	local shown: boolean = I.S.Players.LocalPlayer:GetAttribute("InMatch") == true and waiting and learning and matchFolder:GetAttribute("Kind") ~= "Tutorial"

	--[[ Tip ]]

	-- The strip opens on the tip it was on, shown at once
	if shown and not moduleGui.Enabled then
		elems["Tip"].Text = _settings.HINT_TIPS[tipIndex]
		elems["Tip"].TextTransparency = 0
		elems["TipStroke"].Transparency = 0
	end

	--[[ Visibility ]]

	moduleGui.Enabled = shown
end

--%%%%%%%%%%%%%%%%%%%% Next Tip

--[[
	Fades the tip over the strip out, then puts the next one in (every HINT_TIP_SECONDS, while the strip shows).
]]
function Module._nextTip()
	--[[ Checks ]]

	-- Check if the strip shows
	if not moduleGui.Enabled then
		return
	end

	--[[ Fading ]]

	local Out_TweenGoal = { TextTransparency = 1 }
	local Out_Tween: Tween = I.S.TweenService:Create(elems["Tip"], _settings.HINT_TIP_TWEENINFO, Out_TweenGoal)
	local StrokeOut_TweenGoal = { Transparency = 1 }
	local StrokeOut_Tween: Tween = I.S.TweenService:Create(elems["TipStroke"], _settings.HINT_TIP_TWEENINFO, StrokeOut_TweenGoal)
	Out_Tween.Completed:Once(Module._showNextTip)
	Out_Tween:Play()
	StrokeOut_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Next Tip

--[[
	Puts the next tip in (the first again after the last) and fades it back in.
]]
function Module._showNextTip()
	--[[ Applying ]]

	tipIndex = tipIndex % #_settings.HINT_TIPS + 1
	elems["Tip"].Text = _settings.HINT_TIPS[tipIndex]

	--[[ Fading ]]

	local In_TweenGoal = { TextTransparency = 0 }
	local In_Tween: Tween = I.S.TweenService:Create(elems["Tip"], _settings.HINT_TIP_TWEENINFO, In_TweenGoal)
	local StrokeIn_TweenGoal = { Transparency = 0 }
	local StrokeIn_Tween: Tween = I.S.TweenService:Create(elems["TipStroke"], _settings.HINT_TIP_TWEENINFO, StrokeIn_TweenGoal)
	In_Tween:Play()
	StrokeIn_Tween:Play()
end

return Module
