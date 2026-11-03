--[[
    Created By: 	Nari
]]

local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local state --- @type AdminPanel_CommandBar_ClientState

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

--- @class AdminPanel_CommandBar_Client_Cursor
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	state = _shared.state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cursor Control

--%%%%%%%%%%%%%%%%%%%% Update Cursor Position

--[[
	Update position of the custom cursor to match the current position on TextBox.
]]
function Module.UpdateCursorPosition()
	local elems = state.elems

	-- Getting Position
	local rawText: string = elems["InputBox"].Text
	local currentPos: number = elems["InputBox"].CursorPosition

	-- Updating
	elems["CursorPosBox"].Text = rawText:sub(1, currentPos - 1)
	elems["Cursor"].Position = _settings.CURSOR_OFFSET + UDim2.fromOffset(elems["CursorPosBox"].TextBounds.X, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
