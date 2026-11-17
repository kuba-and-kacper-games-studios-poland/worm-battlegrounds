--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local matchFolder: Folder

-- The local snail whose turn waits for the controller now, or nil
local waiting: string? = nil

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

--- @class Match_Client_HandOff
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(folder: Folder)
	--[[ Connections ]]

	matchFolder = folder
	matchFolder:GetAttributeChangedSignal("HandOff"):Connect(Module._refresh)
	I.S.UserInputService.InputBegan:Connect(Module._onInput)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Notes whether a local turn of one of this screen's snails waits for its player (the match's HandOff attribute);
	MatchHud's turn callout names them meanwhile.
]]
function Module._refresh()
	--[[ Data ]]

	local participantId: string? = matchFolder:GetAttribute("HandOff")
	local info: Configuration? = if participantId then I.Match.GetParticipantInfo(participantId) else nil

	--[[ Saving ]]

	waiting = if info and info:GetAttribute("UserId") == I.S.Players.LocalPlayer.UserId then participantId else nil
end

--%%%%%%%%%%%%%%%%%%%% On Input

--[[
	A press (a click, a tap, A, Space or Enter) while a local turn waits says the player has the controller.
]]
function Module._onInput(input: InputObject)
	--[[ Checks ]]

	-- Check if a turn waits on this screen and it's a press
	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.ButtonA
		or input.KeyCode == Enum.KeyCode.Space
		or input.KeyCode == Enum.KeyCode.Return
	if not waiting or not press then
		return
	end

	--[[ Sending ]]

	waiting = nil
	I.Network.Fire("Match_HandOffReady")
end

return Module
