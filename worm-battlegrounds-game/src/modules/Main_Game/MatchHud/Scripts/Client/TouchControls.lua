--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

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

--- @class MatchHud_Client_TouchControls
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Touch"] = gui:FindFirstChild("U_Touch") --- @type Frame
	elems["PadControls"] = gui:FindFirstChild("U_PadControls") --- @type Frame

	--[[ Connections ]]

	for _index: number, control: string in ipairs({ "Left", "Right", "Jump" }) do
		local button: ImageButton = elems["Touch"]:FindFirstChild(`S_{control}`, true)
		button.InputBegan:Connect(function(input: InputObject)
			Module._hold(control, input, true)
		end)
		button.InputEnded:Connect(function(input: InputObject)
			Module._hold(control, input, false)
		end)
	end
	I.Topic.Subscribe("Match_MyTurn", Module._refresh)
	Module._refresh(I.Match.IsMyTurn())
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Presses or releases a walk or jump button for the player's snail.
]]
function Module._hold(control: string, input: InputObject, state: boolean)
	--[[ Checks ]]

	-- Only fingers and the mouse press these buttons
	if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	--[[ Holding ]]

	I.SnailControl.Hold(control, state)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the buttons during the player's turn only (Utils_HideOnPlatform keeps the frame to touch screens), and the
	pad's controls strip then too (a Console_Hint, so only on Console).
]]
function Module._refresh(myTurn: boolean)
	--[[ Applying ]]

	for _index: number, control: string in ipairs({ "Left", "Right", "Jump" }) do
		elems["Touch"]:FindFirstChild(`S_{control}`, true).Visible = myTurn
	end
	elems["PadControls"]:SetAttribute("Console_HintHidden", not myTurn)
end

return Module
