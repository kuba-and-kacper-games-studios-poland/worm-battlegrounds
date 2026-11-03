--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local state --- @type AdminPanel_CommandBar_ClientState

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Build Selection Text

--[[
	Builds the rich-text selection display from a left position, a right position, and the raw text.
]]
--- @return string
local function buildSelectionText(rawText: string, leftPos: number, rightPos: number)
	local textStart: string = rawText:sub(1, leftPos - 1)
	local selectedText: string = rawText:sub(leftPos, rightPos - 1)
	local textEnd: string = rawText:sub(rightPos, -1)

	local result: string = `{I.RichText.Format(textStart, { Transparency = 1 })}`
	result ..= `{I.RichText.Format(selectedText, { Color = _settings.SELECTION_TEXT_COLOR, Mark_Color = _settings.SELECTION_BACKGROUND_COLOR, Mark_Transparency = 0 })}`
	result ..= `{I.RichText.Format(textEnd, { Transparency = 1 })}`

	return result
end

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

--- @class AdminPanel_CommandBar_Client_Selection
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	state = _shared.state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Selection Control

--%%%%%%%%%%%%%%%%%%%% Update Selection Display

--[[
	Updates display of the selected text in the command bar input.
]]
function Module.UpdateSelectionDisplay()
	local elems = state.elems

	--[[ Local Variables ]]

	local selectionStart: number = elems["InputBox"].SelectionStart
	local currentCursorPos: number = elems["InputBox"].CursorPosition

	--[[ Active Selection ]]

	if selectionStart > -1 then
		local rawText: string = elems["InputBox"].Text

		-- Right -> Left
		if selectionStart > currentCursorPos then
			elems["SelectionBox"].Text = buildSelectionText(rawText, currentCursorPos, selectionStart)
			return
		end

		-- Left -> Right
		if selectionStart < currentCursorPos then
			elems["SelectionBox"].Text = buildSelectionText(rawText, selectionStart, currentCursorPos)
			return
		end
	end

	--[[ No Selection ]]

	elems["SelectionBox"].Text = ""
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
