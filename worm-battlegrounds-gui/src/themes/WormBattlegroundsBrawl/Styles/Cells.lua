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
	-- The lobby's public matches: two cards a row, each a mode, its players and timer, and Join
	Matches = { Grid = true, CellWidth = 344, CellHeight = 152 },
}

return _styles
