--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Worms clones it where a worm is hit, rises and fades it (only with the DamageNumbers setting on)
	Name = "DamagePop",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale: as tall as one line of the Display number, scaled with the screen by code
	Preview = { Width = 160, Height = 100 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Pop",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(160, 100) },
		Children = {
			-- Set with the billboard's size by ScreenScale
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			{ Control = "Label", Id = "S_Amount", Text = "-45", Align = "Center", Style = { "Display", "Danger" } },
		},
	},
}

return _gui
