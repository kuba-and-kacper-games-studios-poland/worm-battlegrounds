--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The snails marked now, as the aimbot can hit them
local marked = {} --- @type { Model }

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

--- @class Combat_Client_Aimbot
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.Network.Fired("Combat_AimbotTargets", Module._onTargets)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Targets

--[[
	Marks the snails the server found the player can hit (only while an admin turned their aimbot on, on their turn)
	with a faint fill on their team outline, and takes it off the ones marked before; an empty list clears them.
]]
--- @param targets { Model }
function Module._onTargets(targets)
	--[[ Clearing ]]

	for _index: number, model: Model in ipairs(marked) do
		Module._mark(model, false)
	end

	--[[ Marking ]]

	marked = targets
	for _index: number, model: Model in ipairs(marked) do
		Module._mark(model, true)
	end
end

--%%%%%%%%%%%%%%%%%%%% Mark

--[[
	Turns a snail's mark on or off: the fill of the TeamOutline Highlight Snails' tags give it (none until its tag is
	made, nor once it's gone).
]]
function Module._mark(model: Model?, on: boolean)
	--[[ Data ]]

	local outline: Highlight? = model and model:FindFirstChild("TeamOutline")

	--[[ Checks ]]

	-- Skip a snail that has no outline (yet, or any more)
	if not outline then
		return
	end

	--[[ Applying ]]

	outline.FillColor = _settings.AIMBOT_FILL_COLOR
	outline.FillTransparency = if on then _settings.AIMBOT_FILL_TRANSPARENCY else 1
end

return Module
