--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ Variants ]]

	-- The results lineup: a tall card per player
	Players = { Grid = true, CellWidth = "PlayerCard", CellHeight = "PlayerCardTall" },
	-- A waiting room's player slots
	Slots = { Grid = true, CellWidth = "Slot", CellHeight = "SlotTall" },
}

return _styles
