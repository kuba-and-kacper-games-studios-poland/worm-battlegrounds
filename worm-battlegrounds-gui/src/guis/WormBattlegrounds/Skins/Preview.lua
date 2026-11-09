--[[
	Created By: 	Nari
]]

local _localName: string = "SkinsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Skins in the grid: name, rarity colour, owned
--- @type { { any } }
local SKINS = {
	{ "Classic", Color3.fromRGB(176, 176, 185), true },
	{ "Pirate", Color3.fromRGB(68, 141, 224), true },
	{ "Ninja", Color3.fromRGB(167, 79, 224), true },
	{ "Robot", Color3.fromRGB(255, 196, 0), false },
	{ "Skeleton", Color3.fromRGB(68, 141, 224), false },
	{ "Wizard", Color3.fromRGB(167, 79, 224), false },
}

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

--- @class UmeGui_Guis_WormBattlegrounds_Skins_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Skins", Label = "Skins", Value = 6, Min = 1, Max = 6, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the grid as the Cosmetics module does: the first skin worn (the tile's selected look), the unowned ones
	locked.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Tiles ]]

	local tiles = preview.Fill("PREFAB | SkinTile", preview.Values.S_Skins) --- @type { UmeGui_Subview }

	--- @param tile UmeGui_Subview
	for index: number, tile in ipairs(tiles) do
		local root: GuiObject = tile.Root.Instance
		local background: Frame = root:FindFirstChild("Background")
		local worn: boolean = index == 1
		tile:Get("S_Name").Instance.Text = SKINS[index][1]
		tile:Get("S_Rarity").Instance.ImageColor3 = SKINS[index][2]
		tile:Get("S_Locked").Instance.Visible = not SKINS[index][3]
		background:FindFirstChild("Stroke2").Image = root:GetAttribute(if worn then "Look_SelectedStroke2" else "Look_Stroke2")
		background:FindFirstChild("Stroke").Image = root:GetAttribute(if worn then "Look_SelectedStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke").ImageColor3 = root:GetAttribute(if worn then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end
end

return Module
