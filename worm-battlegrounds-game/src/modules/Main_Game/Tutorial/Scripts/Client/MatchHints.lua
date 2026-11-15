--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Spotlight = require(script.Parent:FindFirstChild("Spotlight")) --- @type Tutorial_Client_Spotlight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local matchFolder: Folder
local snailsFolder: Instance

--[[ State ]]

-- Whether this guide put the hint up, so it only takes down its own (the Studio map runs the lobby guide too)
local showing: boolean = false
local tickConnection: RBXScriptConnection?

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

--- @class Tutorial_Client_MatchHints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	elems["Slots"] = I.UserInterface.UI[_settings.MATCH_HUD_GUI_NAME]:FindFirstChild("U_Slots", true) --- @type Frame
	elems["Wind"] = I.UserInterface.UI[_settings.MATCH_HUD_GUI_NAME]:FindFirstChild("S_Wind", true) --- @type TextLabel
	elems["Lobby"] = I.UserInterface.UI[_settings.RESULTS_GUI_NAME]:FindFirstChild("S_Lobby", true) --- @type ImageButton
	matchFolder = I.Match.GetFolder()
	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")

	--[[ Connections ]]

	matchFolder:GetAttributeChangedSignal("Kind"):Connect(Module._checkKind)
	Module._checkKind()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check Kind

--[[
	Starts the guide when the match turns out to be the tutorial, and stops it when the server plays another kind.
]]
function Module._checkKind()
	--[[ Local Variables ]]

	local tutorial: boolean = matchFolder:GetAttribute("Kind") == _settings.MATCH_KIND

	--[[ Connections ]]

	if tutorial and not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	elseif not tutorial and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
		Module._hide()
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Shows the step the match is at: the lit spot to land on, then a step for each of the player's turns (the player
	plays first, so their turn is the round): shooting the bot, picking the Grenade and throwing it, the strong wind
	(Match's TUTORIAL_WINDS) and finishing the bot; the bot's turns, and the Return button once the results show.
]]
function Module._tick()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local myTurn: boolean = I.Match.IsMyTurn()
	local mine: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	local snail: Model? = I.Snails.GetMine()
	local bot: Model? = Module._getBot()
	local round: number = matchFolder:GetAttribute("Round") or 1

	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") or not mine then
		Module._hide()
		return
	end

	--[[ Showing ]]

	if phase == "Drop" and not mine:GetAttribute("Placed") then
		Module._show(Module._getHint("Drop"), Vector3.new(mine:GetAttribute("DropX") or 0, mine:GetAttribute("DropY") or 0, 0), "Drop")
	elseif phase == "Turn" and myTurn and bot and bot.PrimaryPart then
		local grenadeSlot: GuiObject? = elems["Slots"]:FindFirstChild(_settings.GRENADE)
		local holdsGrenade: boolean = snail ~= nil and snail:GetAttribute("HeldItem") == _settings.GRENADE
		if round == 1 then
			Module._show(Module._getHint("Aim"), bot.PrimaryPart, "Aim")
		elseif round == 2 and grenadeSlot and not holdsGrenade then
			Module._show(Module._getHint("Grenade"), grenadeSlot, "Grenade")
		elseif round == 2 then
			Module._show(Module._getHint("Throw"), bot.PrimaryPart, "Throw")
		elseif round == 3 then
			Module._show(Module._getHint("Wind"), elems["Wind"], "Wind")
		else
			Module._show(Module._getHint("Finish"), bot.PrimaryPart, "Finish")
		end
	elseif phase == "Turn" and not myTurn then
		Module._show(Module._getHint("BotTurn"), nil, "BotTurn")
	elseif phase == "Ended" then
		Module._show(Module._getHint("Lobby"), elems["Lobby"], "Lobby")
	else
		Module._hide()
	end
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a step through the guide (reporting it for the funnel) and remembers this guide put it up.
]]
function Module._show(text: string, target: (GuiObject | BasePart | Vector3)?, step: string)
	--[[ Applying ]]

	showing = true
	Spotlight.Show(text, target, step)
end

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	Takes the guide down if this guide put it up, leaving the lobby guide's alone.
]]
function Module._hide()
	--[[ Checks ]]

	-- Check if this guide is showing
	if not showing then
		return
	end

	--[[ Applying ]]

	showing = false
	Spotlight.Hide()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Bot

--[[
	Returns the tutorial bot's snail while it's in play.
]]
--- @return Model?
function Module._getBot()
	--[[ Finding ]]

	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("IsBot") and model:GetAttribute("Alive") then
			return model
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Hint

--[[
	Returns what a step's hint says for the player's device: on a pad its PAD_HINTS text, with each {Action} named for
	the pad by the Console module; on a touch screen its TOUCH_HINTS text; else its HINTS text.
]]
--- @return string
function Module._getHint(stepName: string)
	--[[ Returning ]]

	if I.Platform.Current == "Console" and _settings.PAD_HINTS[stepName] then
		return (string.gsub(_settings.PAD_HINTS[stepName], "{(%w+)}", I.Console.GetButtonName))
	end
	if I.Platform.Current == "Mobile" and _settings.TOUCH_HINTS[stepName] then
		return _settings.TOUCH_HINTS[stepName]
	end
	return _settings.HINTS[stepName] or ""
end

return Module
