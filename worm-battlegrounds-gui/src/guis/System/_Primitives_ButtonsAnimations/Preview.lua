--[[
	Created By: 	Nari
]]

local _localName: string = "PrimitivesButtonsAnimationsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Press All ]]

-- Seconds between two buttons' presses, so each animation is seen on its own
local PRESS_GAP: number = 0.35

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

--- @class UmeGui_Guis_System__Primitives_ButtonsAnimations_Preview
local Module = {

	--[[ Settings ]]

	-- Presses every showcase button in reading order, without the mouse
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Button", Id = "S_PressAll", Text = "Press all" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Action

--[[
	Plays a press on every showcase button one after another, left to right and top to bottom, with its click sound.
]]
--- @param preview UmeGui_Preview
function Module.Action(preview, id: string)
	--[[ Checks ]]

	-- Skip anything but Press all
	if id ~= "S_PressAll" then
		return
	end

	-- Skip on a Gui tool too old to play presses
	if not preview.PlayPress then
		warn(`[{_localName}]: This Gui tool can't play presses; update the Ume plugin.`)
		return
	end

	--[[ Pressing ]]

	local buttons = Module._getButtons(preview) --- @type { ImageButton }

	task.spawn(function()
		for _index: number, button: ImageButton in ipairs(buttons) do
			preview.PlayPress(button)
			task.wait(PRESS_GAP)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Buttons

--[[
	Returns the showcase's ButtonScale buttons in reading order: by row, then left to right.
]]
--- @param preview UmeGui_Preview
--- @return { ImageButton }
function Module._getButtons(preview)
	--[[ Finding ]]

	local buttons = {} --- @type { ImageButton }

	for _index: number, descendant: Instance in ipairs(preview.View:Get("U_Buttons").Instance:GetDescendants()) do
		-- Keep the buttons carrying an animation
		if descendant:IsA("ImageButton") and descendant:HasTag("Utils_ButtonScale") then
			table.insert(buttons, descendant)
		end
	end

	--[[ Sorting ]]

	table.sort(buttons, function(a: ImageButton, b: ImageButton)
		-- Order a row before the next one, then left to right inside it
		if math.abs(a.AbsolutePosition.Y - b.AbsolutePosition.Y) > 1 then
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end

		return a.AbsolutePosition.X < b.AbsolutePosition.X
	end)

	--[[ Returning ]]

	return buttons
end

return Module
