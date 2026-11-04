--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "ScreenScale"

--- @type ScreenScale_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Every S_ScreenScale in the game's guis
local scales = {} --- @type { UIScale }

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	for _index: number, guiName: string in ipairs(_settings.GUIS) do
		local gui: ScreenGui? = I.UserInterface.UI[guiName]
		if not gui then
			continue
		end
		for _index2: number, descendant: Instance in ipairs(gui:GetDescendants()) do
			if descendant.Name == "S_ScreenScale" and descendant:IsA("UIScale") then
				table.insert(scales, descendant)
			end
		end
	end

	Module._applyScale()
	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Module._applyScale)
	I.Topic.Subscribe("Platform_Changed", Module._applyScale)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply Scale

--[[
	Scales every panel to the screen: its height over the design height, bigger on short Mobile screens.
]]
function Module._applyScale()
	--[[ Local Variables ]]

	local height: number = I.Env.Camera.ViewportSize.Y
	local scale: number = height / _settings.DESIGN_HEIGHT

	-- Boost short touch screens
	if I.Platform.Current == "Mobile" and height < _settings.SMALL_SCREEN then
		scale *= _settings.MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, uiScale: UIScale in ipairs(scales) do
		uiScale.Scale = scale
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
