--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local hideReasons = {} --- @type { [Instance]: { [string]: boolean } }

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

--- @class Utils_HideReasons
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Hidden

--[[
	Hides or shows `instance` for one `reason` (a component tag).
	The instance stays hidden while any reason hides it and is shown once none is left.
]]
function Module.SetHidden(instance: Instance, reason: string, hidden: boolean)
	--[[ Saving ]]

	if hidden then
		-- Create the instance's reasons on its first hide
		if not hideReasons[instance] then
			hideReasons[instance] = {}
		end

		hideReasons[instance][reason] = true
	else
		Module.Clear(instance, reason)
	end

	--[[ Applying ]]

	if hideReasons[instance] then
		I.HideOnPlay.Hide({ instance })
	else
		I.HideOnPlay.Show({ instance })
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Forgets `reason` for `instance` without changing its visibility, and forgets the instance once no reason is left.
]]
function Module.Clear(instance: Instance, reason: string)
	--[[ Checks ]]

	-- Skip an instance nothing hides
	if not hideReasons[instance] then
		return
	end

	--[[ Clearing ]]

	hideReasons[instance][reason] = nil

	-- Forget the instance once no reason is left
	if next(hideReasons[instance]) == nil then
		hideReasons[instance] = nil
	end
end

return Module
