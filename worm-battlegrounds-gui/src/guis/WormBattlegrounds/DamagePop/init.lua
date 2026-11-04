--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Worms clones it where a worm is hit, rises and fades it (only with the DamageNumbers setting on)
	Name = "DamagePop",
	Kind = "Billboard",
	Theme = "WormBattlegrounds",
	Preview = { Width = 140, Height = 64 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Pop",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
		Children = {
			{ Control = "Label", Id = "S_Amount", Text = "-45", Align = "Center", Style = { "Display", "Danger" } },
		},
	},
}

return _gui
