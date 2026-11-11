--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local SkinModels = require(script.Parent:FindFirstChild("SkinModels")) --- @type Crates_Client_SkinModels

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

-- The rarity sections drawn now, by rarity
local sections = {} --- @type { [string]: Frame }

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

--- @class Crates_Client_Odds
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Odds"] = moduleGui:FindFirstChild("U_Odds", true) --- @type ScrollingFrame
	prefabs["RaritySection"] = elems["Odds"]:FindFirstChild("PREFAB | RaritySection") --- @type Frame
	prefabs["OddsItem"] = prefabs["RaritySection"]:FindFirstChild("PREFAB | OddsItem", true) --- @type ImageButton
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws a crate's odds in the Crates widget's left list, paid in a currency: one section per rarity, rarest first,
	each with a card per item and its chance, likeliest first. Items a crate always gives show "Always".
]]
function Module.Draw(crateId: string, currency: string)
	--[[ Data ]]

	local row = I.G_Crates.Get(crateId) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Clearing ]]

	for _rarity: string, section: Frame in pairs(sections) do
		section:Destroy()
	end
	table.clear(sections)

	--[[ Items ]]

	local odds = row.OddsByCurrency[currency] or {} --- @type { [string]: number }
	for itemId: string, chance: number in pairs(odds) do
		Module._addItem(itemId, `{chance}%`, -chance)
	end
	for index: number, itemId: string in ipairs(row.Fixed) do
		Module._addItem(itemId, "Always", index)
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Item

--[[
	Adds one item's card to its rarity's section (made on its first item): its picture (a skin's snail, posed, when it
	has one), name and chance.
]]
function Module._addItem(itemId: string, chanceText: string, order: number)
	--[[ Data ]]

	local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
	if not item then
		return
	end

	--[[ Local Variables ]]

	local section: Frame = sections[item.Rarity] or Module._addSection(item.Rarity)
	local snail: boolean = SkinModels.GetModelName(itemId) ~= nil

	--[[ Cloning ]]

	local card: ImageButton = prefabs["OddsItem"]:Clone()
	card.Name = itemId
	card.LayoutOrder = math.floor(order * 100)
	card.Visible = true

	--[[ Applying ]]

	card:FindFirstChild("S_Icon", true).Image = item.IconId
	card:FindFirstChild("S_Icon", true).Visible = not snail
	card:FindFirstChild("S_Model", true).Visible = snail
	card:FindFirstChild("S_Name", true).Text = item.Name
	card:FindFirstChild("S_Chance", true).Text = chanceText

	--[[ Snail ]]

	SkinModels.Put(card, itemId)

	--[[ Rarity Look ]]

	card:FindFirstChild("S_Stroke", true).ImageColor3 = section:FindFirstChild("S_TitleStroke", true).ImageColor3

	--[[ Saving ]]

	card.Parent = section:FindFirstChild("S_Items")
end

--%%%%%%%%%%%%%%%%%%%% Add Section

--[[
	Adds a rarity's section to the list, rarest on top, in its look from the prefab's Look_<Rarity>_* attributes
	(Common's for a rarity the design has no look for).
]]
--- @return Frame
function Module._addSection(rarity: string)
	--[[ Local Variables ]]

	local look: string = if prefabs["RaritySection"]:GetAttribute(`Look_{rarity}_Color`) then rarity else "Common"

	--[[ Cloning ]]

	local section: Frame = prefabs["RaritySection"]:Clone()
	section.Name = rarity
	section.LayoutOrder = 50 - (I.Rarity.GetTier(rarity) or 0)
	section.Visible = true

	--[[ Elements ]]

	local title: TextLabel = section:FindFirstChild("S_Rarity", true)

	--[[ Texts ]]

	title.Text = rarity

	--[[ Rarity Look ]]

	section:FindFirstChild("S_TitleStroke", true).ImageColor3 = section:GetAttribute(`Look_{look}_Color`)
	section:FindFirstChild("S_TitleMask", true).Image = section:GetAttribute(`Look_{look}_Mask`)
	title.UIGradient.Color = section:GetAttribute(`Look_{look}_Gradient`)

	--[[ Saving ]]

	-- The section's copy of the card prefab goes: cards are cloned from the prefab's own
	section:FindFirstChild("PREFAB | OddsItem", true):Destroy()
	section.Parent = elems["Odds"]
	sections[rarity] = section

	--[[ Returning ]]

	return section
end

return Module
