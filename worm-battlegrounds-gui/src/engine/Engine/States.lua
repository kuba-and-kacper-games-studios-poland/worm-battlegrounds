--[[
	Created By: 	Nari
]]

local _localName: string = "States"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Later states win when several are active at once
local ORDER = { "Selected", "Hover", "Pressed", "Disabled" } --- @type { string }

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

--- @class UmeGui_Engine_States
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Create

--- @param targets { [string]: UmeGui_StateTarget }
--- @param style UmeGui_Style
--- @param resolveColor (value: any) -> Color3
--- @param animate (instance: Instance, goals: { [string]: any }, instant: boolean | nil) -> ()
--- @return UmeGui_States
function Module.Create(targets, style, resolveColor, animate)
	--[[ Local Variables ]]

	local states = {} --- @type UmeGui_States
	local active = {} --- @type { [string]: boolean }
	local base = {} --- @type { [string]: any }
	local stateStyles = style.States or {} --- @type { [string]: UmeGui_Style }

	--[[ Base ]]

	for styleKey: string, _target in pairs(targets) do
		base[styleKey] = style[styleKey]
	end

	--%%%%%%%%%%%%%%%%%%%% Refresh

	--[[
		Writes every target's value for the active states, tweened unless `instant` (animate also writes at once on a fresh build).
	]]
	function states.Refresh(instant: boolean?)
		--- @param target UmeGui_StateTarget
		for styleKey: string, target in pairs(targets) do
			--[[ Picking ]]

			local value: any = base[styleKey]
			for _index: number, stateName: string in ipairs(ORDER) do
				-- While selected, Hover and Pressed use their Selected look when the style has one
				local selectedStyle = if active.Selected then stateStyles[`Selected{stateName}`] else nil --- @type UmeGui_Style?
				local stateStyle = selectedStyle or stateStyles[stateName] --- @type UmeGui_Style?

				-- Skip states that are off or leave this key alone
				if not active[stateName] or not stateStyle or stateStyle[styleKey] == nil then
					continue
				end

				value = stateStyle[styleKey]
			end

			--[[ Applying ]]

			local current: any = target.Instance[target.Property]
			local goal: any = if typeof(current) == "Color3" then resolveColor(value) else value
			animate(target.Instance, { [target.Property] = goal }, instant)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Turns a state on or off and moves the look to match.
	]]
	function states.Set(stateName: string, isActive: boolean)
		--[[ Checks ]]

		-- Skip when nothing changes
		if (active[stateName] == true) == isActive then
			return
		end

		--[[ Applying ]]

		active[stateName] = isActive
		states.Refresh(false)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Base

	--[[
		Replaces the resting value of one style key, for looks that change with data (a status color, a tone).
	]]
	function states.SetBase(styleKey: string, value: any)
		--[[ Applying ]]

		base[styleKey] = value
		states.Refresh(false)
	end

	--%%%%%%%%%%%%%%%%%%%% Is Active

	--[[
		Returns whether a state is on.
	]]
	--- @return boolean
	function states.IsActive(stateName: string)
		return active[stateName] == true
	end

	--[[ Returning ]]

	states.Refresh(true)
	return states
end

return Module
