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

-- The screen's scale, set on every S_ScreenScale times its device scale
local screenScale: number = 1

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

				-- Utils_PlatformScale sets its device scale straight on the UIScale: put the screen's back on top
				descendant:GetPropertyChangedSignal("Scale"):Connect(function()
					Module._fitScale(descendant)
				end)
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
	Scales every panel to the screen: its height over the design height (or its width over the design width on a
	narrower screen), bigger on short Mobile screens.
]]
function Module._applyScale()
	--[[ Local Variables ]]

	local height: number = I.Env.Camera.ViewportSize.Y
	local width: number = I.Env.Camera.ViewportSize.X

	-- A screen narrower than the layout (4:3, 5:4, a tablet) scales by its width, so side-by-side panels still fit
	screenScale = math.min(height / _settings.DESIGN_HEIGHT, width / _settings.DESIGN_WIDTH)

	-- Boost short touch screens
	if I.Platform.Current == "Mobile" and height < _settings.SMALL_SCREEN then
		screenScale *= _settings.MOBILE_BOOST
	end

	--[[ Applying ]]

	for _index: number, uiScale: UIScale in ipairs(scales) do
		Module._fitScale(uiScale)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fit Scale

--[[
	Sets one panel's scale: the screen's times its device scale, which Utils_PlatformScale keeps in the UIScale's
	Utils_BaseScale attribute (1 without the tag).
]]
function Module._fitScale(uiScale: UIScale)
	--[[ Local Variables ]]

	local scale: number = screenScale * (uiScale:GetAttribute(_settings.BASE_SCALE_ATTRIBUTE) or 1)

	--[[ Applying ]]

	-- Skip an unchanged scale, so setting it doesn't fire this again
	if math.abs(uiScale.Scale - scale) > 1e-4 then
		uiScale.Scale = scale
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
