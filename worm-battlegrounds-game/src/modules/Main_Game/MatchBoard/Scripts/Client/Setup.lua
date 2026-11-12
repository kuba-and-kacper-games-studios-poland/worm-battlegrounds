--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

-- The bots the player picked ("None" only in a party), and whether the panel sets up a party match
local picked: string = "Medium"
local party: boolean = false

-- Called whenever the panel opens or closes, so the board swaps its panels
local onChanged: () -> ()

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

--- @class MatchBoard_Client_Setup
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(moduleGui: ScreenGui, changed: () -> ())
	--[[ Elements ]]

	onChanged = changed
	elems["Setup"] = moduleGui:FindFirstChild("U_Setup") --- @type Frame
	elems["Title"] = elems["Setup"]:FindFirstChild("S_Title", true) --- @type TextLabel
	elems["RewardText"] = elems["Setup"]:FindFirstChild("S_RewardText", true) --- @type TextLabel
	elems["RewardAmount"] = elems["Setup"]:FindFirstChild("S_RewardAmount", true) --- @type Frame
	elems["Reward"] = elems["Setup"]:FindFirstChild("S_Reward", true) --- @type TextLabel
	elems["Back"] = elems["Setup"]:FindFirstChild("S_Back", true) --- @type ImageButton
	elems["Start"] = elems["Setup"]:FindFirstChild("S_Start", true) --- @type ImageButton

	--[[ Connections ]]

	for _index: number, difficulty: string in ipairs(Module._getChoices()) do
		elems[difficulty] = elems["Setup"]:FindFirstChild(`S_{difficulty}`, true) --- @type ImageButton
		I.Interact.OnPress(elems[difficulty], function()
			picked = difficulty
			Module._refresh()
		end)
	end
	I.Interact.OnPress(elems["Back"], Module.Close)
	I.Interact.OnPress(elems["Start"], Module._start)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Shows the setup panel for a solo match, or for the player's party (which may play without bots).
]]
function Module.Open(asParty: boolean)
	--[[ Saving ]]

	party = asParty
	if not party and picked == "None" then
		picked = "Medium"
	end

	--[[ Showing ]]

	elems["Setup"].Visible = true
	Module._refresh()
	onChanged()

	--[[ Selection ]]

	-- On a pad the panel holds the selection (Start first), and B goes back to the board
	I.Console.Focus(elems["Setup"], Module.Close)
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Hides the setup panel, back to the board.
]]
function Module.Close()
	--[[ Hiding ]]

	elems["Setup"].Visible = false
	onChanged()

	--[[ Selection ]]

	I.Console.Unfocus(elems["Setup"])
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Writes the title, shows No bots only for a party, outlines the picked choice in the design's white, and says what
	a win pays: a solo match's coins, or how a party match pays.
]]
function Module._refresh()
	--[[ Texts ]]

	elems["Title"].Text = if party then "Play with party" else "Play solo"
	elems["RewardText"].Text = _settings.REWARD_TEXT[if not party then "Solo" elseif picked == "None" then "PartyNoBots" else "Party"]
	elems["RewardAmount"].Visible = not party
	elems["Reward"].Text = tostring(_settings.SOLO_WIN_COINS[picked] or 0)

	--[[ Choices ]]

	elems["None"].Visible = party
	for _index: number, difficulty: string in ipairs(Module._getChoices()) do
		local button: ImageButton = elems[difficulty]
		button:FindFirstChild("Background"):FindFirstChild("Stroke").ImageColor3 = button:GetAttribute(if difficulty == picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end
end

--%%%%%%%%%%%%%%%%%%%% Start

--[[
	Starts the solo or party match with the picked bots, and goes back to the board.
]]
function Module._start()
	--[[ Sending ]]

	if party then
		I.Network.Fire("MatchBoard_PlayParty", picked)
	else
		I.Network.Fire("MatchBoard_PlaySolo", picked)
	end

	--[[ Closing ]]

	Module.Close()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Open

--[[
	Returns whether the setup panel shows.
]]
--- @return boolean
function Module.IsOpen()
	return elems["Setup"].Visible
end

--%%%%%%%%%%%%%%%%%%%% Get Choices

--[[
	Returns every choice the panel has: No bots, then the difficulties.
]]
--- @return { string }
function Module._getChoices()
	--[[ Local Variables ]]

	local choices = { "None" } --- @type { string }
	table.move(_settings.SOLO_DIFFICULTIES, 1, #_settings.SOLO_DIFFICULTIES, 2, choices)

	--[[ Returning ]]

	return choices
end

return Module
