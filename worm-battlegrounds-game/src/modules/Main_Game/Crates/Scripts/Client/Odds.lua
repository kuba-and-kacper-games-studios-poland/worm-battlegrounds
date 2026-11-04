--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

-- The crate and currency the widget shows
local shownCrate: string = ""
local shownCurrency: string = "Coins"

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

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.ODDS_GUI_NAME]
	elems["Crate"] = moduleGui:FindFirstChild("S_Crate", true) --- @type TextLabel
	elems["Price"] = moduleGui:FindFirstChild("S_Price", true) --- @type TextLabel
	elems["Total"] = moduleGui:FindFirstChild("S_Total", true) --- @type TextLabel
	elems["Odds"] = moduleGui:FindFirstChild("U_Odds", true) --- @type ScrollingFrame
	prefabs["OddsRow"] = elems["Odds"]:FindFirstChild("PREFAB | OddsRow") --- @type Frame

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show For

--[[
	Opens the odds widget for a crate, paid in a currency.
]]
function Module.ShowFor(crateId: string, currency: string)
	--[[ Saving ]]

	shownCrate = crateId
	shownCurrency = currency

	--[[ Opening ]]

	I.WidgetManager.Open(_settings.ODDS_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the odds when the widget opens: the crate's name and prices, then one row per item with its rarity and
	chance, likeliest first.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the odds widget
	if widgetName ~= _settings.ODDS_GUI_NAME then
		return
	end

	--[[ Data ]]

	local row = I.G_Crates.Get(shownCrate) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Odds"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["OddsRow"] then
			child:Destroy()
		end
	end

	--[[ Texts ]]

	local price = row.Prices[shownCurrency] --- @type Crates_Price?
	elems["Crate"].Text = row.Name
	elems["Price"].Text = if price then `{price.One} {string.lower(shownCurrency)} · 10 for {price.Ten}` else ""
	elems["Total"].Text = "Total: 100%"

	--[[ Rows ]]

	local odds = row.OddsByCurrency[shownCurrency] or {} --- @type { [string]: number }
	for itemId: string, chance: number in pairs(odds) do
		Module._addRow(itemId, `{chance}%`, -chance)
	end
	for index: number, itemId: string in ipairs(row.Fixed) do
		Module._addRow(itemId, "Always", index)
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Row

--[[
	Adds one item's row: its picture, name, rarity and chance.
]]
function Module._addRow(itemId: string, chanceText: string, order: number)
	--[[ Data ]]

	local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
	if not item then
		return
	end

	--[[ Cloning ]]

	local row: Frame = prefabs["OddsRow"]:Clone()
	row.Name = itemId
	row.LayoutOrder = math.floor(order * 100)
	row.Visible = true

	--[[ Elements ]]

	local rarity: TextLabel = row:FindFirstChild("S_Rarity", true)

	--[[ Texts ]]

	row:FindFirstChild("S_Icon", true).Image = item.IconId
	row:FindFirstChild("S_Name", true).Text = item.Name
	row:FindFirstChild("S_Chance", true).Text = chanceText
	rarity.Text = item.Rarity
	rarity.TextColor3 = I.Rarity.GetLook(item.Rarity).Base

	--[[ Saving ]]

	row.Parent = elems["Odds"]
end

return Module
