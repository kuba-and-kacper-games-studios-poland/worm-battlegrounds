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

--[[ General ]]

local moduleGui: ScreenGui
local shopRep: Folder?
local tutorialRep: Folder?
local policyRep: Folder?

--[[ State ]]

-- One tab per crate, and one buy button per pack size
local tabs = {} --- @type { [string]: ImageButton }
local buyButtons = {} --- @type { [number]: ImageButton }

-- The crate whose tab is selected, and the currency each crate pays with, by crate id
local selected: string = ""
local paying = {} --- @type { [string]: string }

-- Whether a crate is opening, so a second press waits
local busy: boolean = false

-- Draws a crate's odds in the left list, and shows what a crate gave
local drawOdds: (crateId: string, currency: string) -> ()
local showResults --- @type (crateId: string, count: number, payWith: string, results: { Crates_Result }) -> ()

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

--- @class Crates_Client_Panel
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

--- @param oddsDrawer (crateId: string, currency: string) -> ()
--- @param resultsOpener (crateId: string, count: number, payWith: string, results: { Crates_Result }) -> ()
function Module.Start(oddsDrawer, resultsOpener)
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Tabs"] = moduleGui:FindFirstChild("U_Tabs", true) --- @type Frame
	elems["Crate"] = moduleGui:FindFirstChild("U_Crate", true) --- @type ImageLabel
	prefabs["CrateTab"] = elems["Tabs"]:FindFirstChild("PREFAB | CrateTab") --- @type ImageButton
	elems["Menu"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("U_Menu", true) --- @type Frame
	elems["Badge"] = elems["Menu"]:FindFirstChild("S_Badge", true) --- @type Frame
	elems["BadgeCount"] = elems["Badge"]:FindFirstChild("S_Count", true) --- @type TextLabel
	for _index: number, currency: string in ipairs(_settings.PAY_CURRENCIES) do
		elems[`Pay{currency}`] = moduleGui:FindFirstChild(`U_Pay{currency}`, true) --- @type ImageButton
	end
	for _index: number, count: number in ipairs(_settings.COUNTS) do
		buyButtons[count] = moduleGui:FindFirstChild(`U_BuyX{count}`, true)
	end
	drawOdds = oddsDrawer
	showResults = resultsOpener

	--[[ Building ]]

	--- @param row Crates_CrateData
	for crateId: string, row in pairs(I.G_Crates.GetAll()) do
		Module._buildTab(crateId, row)
	end

	--[[ Connections ]]

	for _index: number, currency: string in ipairs(_settings.PAY_CURRENCIES) do
		I.Interact.OnPress(elems[`Pay{currency}`], function()
			Module._pick(currency)
		end)
	end
	for count: number, button: ImageButton in pairs(buyButtons) do
		I.Interact.OnPress(button, function()
			Module.Open(selected, count, if count == 1 and Module._isFree(selected) then "VipDaily" else paying[selected])
		end)
	end

	-- The lobby menu's Weapons and Skins buttons open the widget on their crate's tab
	for _index: number, button: ImageButton in ipairs({ elems["Menu"]:FindFirstChild("S_Weapons", true), elems["Menu"]:FindFirstChild("S_Skins", true) }) do
		I.Interact.OnPress(button, function()
			selected = button:GetAttribute("Crates_CrateId")
			I.WidgetManager.Open(_settings.GUI_NAME)
		end)
	end
	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("Currency_Changed", Module._refreshBadge)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Tab

--[[
	Makes a crate's tab and connects it.
]]
--- @param row Crates_CrateData
function Module._buildTab(crateId: string, row)
	--[[ Cloning ]]

	local tab: ImageButton = prefabs["CrateTab"]:Clone()
	tab.Name = crateId
	tab.LayoutOrder = row.LayoutOrder
	tab.Visible = false

	--[[ Texts ]]

	tab:FindFirstChild("S_Name", true).Text = row.TabName

	--[[ Saving ]]

	tab.Parent = elems["Tabs"]
	tabs[crateId] = tab

	--[[ Connections ]]

	I.Interact.OnPress(tab, function()
		selected = crateId
		Module._draw()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the Shop folder (VIP's free crate), the Tutorial folder (the tutorial crate) and the Policy folder (paid
	random items).
]]
function Module._connectReplicator()
	--[[ Data ]]

	shopRep = I.Replicator.GetFolder("Shop")
	tutorialRep = I.Replicator.GetFolder("Tutorial")
	policyRep = I.Replicator.GetFolder("Policy")

	--[[ Connections ]]

	--- @param folder Folder?
	for _index: number, folder in ipairs({ shopRep, tutorialRep, policyRep }) do
		if folder then
			folder.AttributeChanged:Connect(Module._refresh)
		end
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Asks the server to open a crate, then shows what it gave.
]]
function Module.Open(crateId: string, count: number, payWith: string)
	--[[ Checks ]]

	-- Check if another crate is still opening
	if busy then
		return
	end

	--[[ Opening ]]

	busy = true
	local results = I.Network.Invoke("Crates_Open", crateId, count, payWith) --- @type { Crates_Result }?
	busy = false

	--[[ Showing ]]

	if not results then
		I.WidgetManager.ShowMessage("You can't open that crate right now. Check your coins and diamonds.")
		return
	end
	showResults(crateId, count, payWith, results)
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the crates widget when it opens.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the crates widget
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Redraws the widget while it's open, and the lobby menu's badge, when the free crates or the policy change.
]]
function Module._refresh()
	--[[ Drawing ]]

	Module._draw()
	Module._refreshBadge()
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Picks the currency the selected crate pays with.
]]
function Module._pick(currency: string)
	--[[ Saving ]]

	paying[selected] = currency

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws the selected crate: the tabs shown (only the tutorial crate while it waits), the crate's picture, the balance
	chips of the currencies it takes (the paying one picked), the buy buttons' prices and the odds.
]]
function Module._draw()
	--[[ Checks ]]

	-- Check if the widget is open
	if not moduleGui.Enabled then
		return
	end

	--[[ Selection ]]

	-- A hidden tab (the tutorial crate opened, diamonds restricted) gives way to the first one shown
	if not Module._isShown(selected) then
		local first: number = math.huge
		for crateId: string, tab: ImageButton in pairs(tabs) do
			if Module._isShown(crateId) and tab.LayoutOrder < first then
				first = tab.LayoutOrder
				selected = crateId
			end
		end
	end

	--[[ Data ]]

	local row = I.G_Crates.Get(selected) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Local Variables ]]

	-- A crate pays in its first currency until another is picked, or when the picked one is gone
	local currencies = Module._getCurrencies(selected) --- @type { string }
	if not table.find(currencies, paying[selected]) then
		paying[selected] = currencies[1]
	end
	local free: boolean = Module._isFree(selected)

	--[[ Tabs ]]

	for crateId: string, tab: ImageButton in pairs(tabs) do
		local picked: boolean = crateId == selected
		tab.Visible = Module._isShown(crateId)
		tab:FindFirstChild("S_Stroke2", true).Image = tab:GetAttribute(if picked then "Look_SelectedStroke2" else "Look_Stroke2")
		tab:FindFirstChild("S_Stroke", true).Image = tab:GetAttribute(if picked then "Look_SelectedStroke" else "Look_Stroke")
		tab:FindFirstChild("S_Stroke", true).ImageColor3 = tab:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
		tab:FindFirstChild("S_Name", true).TextColor3 = tab:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")
	end

	--[[ Picture ]]

	elems["Crate"].Image = row.Picture

	--[[ Balance ]]

	for _index: number, currency: string in ipairs(_settings.PAY_CURRENCIES) do
		local chip: ImageButton = elems[`Pay{currency}`]
		local picked: boolean = currency == paying[selected]
		chip.Visible = table.find(currencies, currency) ~= nil
		chip:FindFirstChild("S_Stroke", true).ImageColor3 = chip:GetAttribute(if picked then "Look_SelectedStrokeColor" else "Look_StrokeColor")
		chip:FindFirstChild("S_Amount", true).TextColor3 = chip:GetAttribute(if picked then "Look_SelectedTextColor" else "Look_TextColor")
	end

	--[[ Buy Buttons ]]

	-- A hidden crate (the tutorial's) opens only one at a time; VIP's free crate is the x1
	for count: number, button: ImageButton in pairs(buyButtons) do
		local icon: ImageLabel = button:FindFirstChild("S_Icon", true)
		local freeOne: boolean = free and count == 1
		button.Visible = not row.Hidden or count == 1
		button:FindFirstChild("S_Price", true).Text = if freeOne then _settings.PRICE_FREE else I.Format.Text(I.G_Crates.GetPrice(selected, paying[selected], count))
		icon.Visible = not freeOne
		icon.Image = button:GetAttribute(`Look_{paying[selected]}Icon`)
	end

	--[[ Odds ]]

	drawOdds(selected, paying[selected])
end

--%%%%%%%%%%%%%%%%%%%% Refresh Badge

--[[
	Shows the badge on the lobby menu's Weapons button: BADGE_FREE while a free crate waits (the tutorial's, or VIP's
	daily one), else how many of the cheapest coin crate the player's coins open (BADGE_MAX+ past BADGE_MAX), hidden at
	none.
]]
function Module._refreshBadge()
	--[[ Local Variables ]]

	local free: boolean = Module._isTutorialReady() or Module._isFree(_settings.VIP_CRATE)
	local price: string? = Module._getCheapestCoinPrice()
	local count = if price then I.BN.DivideWithPrecision(I.Currency.Get("Coins") or "0", price) else I.BN.new(0) --- @type BigNum_Instance
	local max = I.BN.new(_settings.BADGE_MAX) --- @type BigNum_Instance

	--[[ Applying ]]

	elems["Badge"].Visible = free or I.BN.Lt(I.BN.new(0), count)
	elems["BadgeCount"].Text = if free then _settings.BADGE_FREE elseif I.BN.Lt(max, count) then `{_settings.BADGE_MAX}+` else tostring(count)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Currencies

--[[
	Returns the currencies a crate can be paid in now, in PAY_CURRENCIES order: those it has a price in, less those
	bought with Robux where the policy restricts paid random items (a crate with fixed items isn't random).
]]
--- @return { string }
function Module._getCurrencies(crateId: string)
	--[[ Data ]]

	local row = I.G_Crates.GetAll()[crateId] --- @type Crates_CrateData?
	if not row then
		return {}
	end

	--[[ Local Variables ]]

	local restricted: boolean = #row.Fixed == 0 and (policyRep == nil or policyRep:GetAttribute("ArePaidRandomItemsRestricted") ~= false)
	local currencies = {} --- @type { string }

	--[[ Filtering ]]

	for _index: number, currency: string in ipairs(_settings.PAY_CURRENCIES) do
		if row.Prices[currency] and not (restricted and table.find(_settings.PAID_CURRENCIES, currency)) then
			table.insert(currencies, currency)
		end
	end

	--[[ Returning ]]

	return currencies
end

--%%%%%%%%%%%%%%%%%%%% Get Cheapest Coin Price

--[[
	Returns the lowest price of one crate in coins, among the crates the tabs show (not the hidden tutorial crate).
]]
--- @return string?
function Module._getCheapestCoinPrice()
	--[[ Local Variables ]]

	local cheapest: string? = nil

	--[[ Searching ]]

	--- @param row Crates_CrateData
	for _crateId: string, row in pairs(I.G_Crates.GetAll()) do
		local coins = row.Prices["Coins"] --- @type Crates_Price?
		if not row.Hidden and coins and (not cheapest or I.BN.Lt(I.BN.new(coins.One), I.BN.new(cheapest))) then
			cheapest = coins.One
		end
	end

	--[[ Returning ]]

	return cheapest
end

--%%%%%%%%%%%%%%%%%%%% Is Shown

--[[
	Returns whether a crate's tab shows: only the tutorial crate while it waits, else every crate on the panel that
	can be paid in some currency now.
]]
--- @return boolean
function Module._isShown(crateId: string)
	--[[ Data ]]

	local row = I.G_Crates.GetAll()[crateId] --- @type Crates_CrateData?
	if not row then
		return false
	end

	--[[ Returning ]]

	return if Module._isTutorialReady() then crateId == _settings.TUTORIAL_CRATE else not row.Hidden and #Module._getCurrencies(crateId) > 0
end

--%%%%%%%%%%%%%%%%%%%% Is Free

--[[
	Returns whether the player's free daily VIP crate is this one, and ready.
]]
--- @return boolean
function Module._isFree(crateId: string)
	return crateId == _settings.VIP_CRATE and shopRep ~= nil and shopRep:GetAttribute("VipCrateReady") == true
end

--%%%%%%%%%%%%%%%%%%%% Is Tutorial Ready

--[[
	Returns whether the tutorial crate waits for the player.
]]
--- @return boolean
function Module._isTutorialReady()
	return tutorialRep ~= nil and tutorialRep:GetAttribute("CrateReady") == true
end

return Module
