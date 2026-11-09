--[[
	Created By: 	Nari
]]

local _localName: string = "CratesPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The crate tabs, the first selected
--- @type { string }
local TABS = { "Weapons", "Premium", "Utility", "Skins" }

-- The weapon crate's odds by rarity, rarest first: item name and chance
--- @type { { any } }
local ODDS = {
	{ "Legendary", { { "Variety Grenade", "0.5%" }, { "Black Hole Grenade", "0.5%" } } },
	{ "Epic", { { "Homing Missile", "5%" }, { "One Punch", "5%" } } },
	{ "Rare", { { "Cluster Bomb", "10%" }, { "Spider Bomb", "10%" }, { "Minigun", "10%" } } },
	{ "Uncommon", { { "Dynamite", "14.75%" }, { "Spartan Spear", "14.75%" } } },
	{ "Common", { { "Uzi", "14.75%" }, { "Baseball Bat", "14.75%" } } },
}

-- The weapon crate's prices in coins, by pack size
--- @type { [number]: string }
local PRICES = { [1] = "100", [3] = "300", [10] = "900" }

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

--- @class UmeGui_Guis_WormBattlegrounds_Crates_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Toggle", Id = "S_Diamonds", Label = "Pay with diamonds", Value = false },
		{ Control = "Toggle", Id = "S_Free", Label = "Free x1 (VIP)", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the widget as the Crates module does: the tabs (the first selected), the paying currency's chip picked, the
	buy buttons' prices and the weapon crate's odds by rarity.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local currency: string = if preview.Values.S_Diamonds then "Diamonds" else "Coins"

	--[[ Tabs ]]

	local tabs = preview.Fill("PREFAB | CrateTab", #TABS) --- @type { UmeGui_Subview }

	--- @param tab UmeGui_Subview
	for index: number, tab in ipairs(tabs) do
		local root: GuiObject = tab.Root.Instance
		local picked: boolean = index == 1
		root.LayoutOrder = index
		tab:Get("S_Name").Instance.Text = TABS[index]
		tab:Get("S_Name").Instance.TextColor3 = root:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")
		tab:Get("S_Stroke2").Instance.Image = root:GetAttribute(if picked then "Look_SelectedStroke2" else "Look_Stroke2")
		tab:Get("S_Stroke").Instance.Image = root:GetAttribute(if picked then "Look_SelectedStroke" else "Look_Stroke")
		tab:Get("S_Stroke").Instance.ImageColor3 = root:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end

	--[[ Balance ]]

	for _index: number, chipCurrency: string in ipairs({ "Coins", "Diamonds" }) do
		local chip: ImageButton = preview.View:Get(`U_Pay{chipCurrency}`).Instance
		local picked: boolean = chipCurrency == currency
		chip:FindFirstChild("S_Stroke", true).ImageColor3 = chip:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
		chip:FindFirstChild("S_Amount", true).TextColor3 = chip:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")
	end

	--[[ Buy Buttons ]]

	for count: number, price: string in pairs(PRICES) do
		local button: ImageButton = preview.View:Get(`U_BuyX{count}`).Instance
		local freeOne: boolean = preview.Values.S_Free and count == 1
		button:FindFirstChild("S_Price", true).Text = if freeOne then "FREE" else price
		button:FindFirstChild("S_Icon", true).Visible = not freeOne
		button:FindFirstChild("S_Icon", true).Image = button:GetAttribute(`Look_{currency}Icon`)
	end

	--[[ Odds ]]

	local sections = preview.Fill("PREFAB | RaritySection", #ODDS) --- @type { UmeGui_Subview }

	--- @param section UmeGui_Subview
	for index: number, section in ipairs(sections) do
		--[[ Local Variables ]]

		local root: GuiObject = section.Root.Instance
		local rarity: string = ODDS[index][1]
		local color: Color3 = root:GetAttribute(`Look_{rarity}_Color`)
		local card: GuiObject = root:FindFirstChild("PREFAB | OddsItem", true)

		--[[ Section ]]

		root.LayoutOrder = index
		section:Get("S_Rarity").Instance.Text = rarity
		section:Get("S_Rarity").Instance.UIGradient.Color = root:GetAttribute(`Look_{rarity}_Gradient`)
		section:Get("S_TitleStroke").Instance.ImageColor3 = color
		section:Get("S_TitleMask").Instance.Image = root:GetAttribute(`Look_{rarity}_Mask`)

		--[[ Cards ]]

		-- The cards are clones of the section's own card prefab, which hides, as the module clones it
		--- @param entry { string }
		for order: number, entry in ipairs(ODDS[index][2]) do
			local clone: GuiObject = card:Clone()
			clone.Name = entry[1]
			clone.LayoutOrder = order
			clone:FindFirstChild("S_Name", true).Text = entry[1]
			clone:FindFirstChild("S_Chance", true).Text = entry[2]
			clone:FindFirstChild("S_Stroke", true).ImageColor3 = color
			clone.Parent = card.Parent
		end
		card.Visible = false
	end
end

return Module
