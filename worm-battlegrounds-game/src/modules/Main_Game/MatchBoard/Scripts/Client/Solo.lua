--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

-- The difficulty the player picked
local picked: string = "Medium"

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

--- @class MatchBoard_Client_Solo
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.SOLO_GUI_NAME]
	elems["Start"] = moduleGui:FindFirstChild("S_Start", true):FindFirstChild("Button") --- @type ImageButton
	for _index: number, difficulty: string in ipairs(_settings.SOLO_DIFFICULTIES) do
		elems[difficulty] = moduleGui:FindFirstChild(`S_{difficulty}`, true) --- @type Frame
		I.Interact.OnPress(elems[difficulty]:FindFirstChild("Button"), function()
			picked = difficulty
			Module._refresh()
		end)
	end

	--[[ Connections ]]

	I.Interact.OnPress(elems["Start"], Module._start)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Marks the picked difficulty.
]]
function Module._refresh()
	--[[ Applying ]]

	for _index: number, difficulty: string in ipairs(_settings.SOLO_DIFFICULTIES) do
		local face: Frame = elems[difficulty]:FindFirstChild("Background", true):FindFirstChild("Face", true)
		face.BackgroundColor3 = if difficulty == picked then _settings.SELECTED_COLOR else _settings.TILE_COLOR
	end
end

--%%%%%%%%%%%%%%%%%%%% Start

--[[
	Starts the solo match at the picked difficulty and closes the window.
]]
function Module._start()
	--[[ Sending ]]

	I.Network.Fire("MatchBoard_PlaySolo", picked)

	--[[ Closing ]]

	I.WidgetManager.Close(_settings.SOLO_GUI_NAME)
end

return Module
