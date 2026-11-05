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

-- One card per crate, by crate id
local cards = {} --- @type { [string]: Frame }

-- The currency each crate pays with, by crate id
local paying = {} --- @type { [string]: string }

-- Whether a crate is opening, so a second press waits
local busy: boolean = false

-- Opens the odds widget for a crate and currency, and shows what a crate gave
local showOdds: (crateId: string, currency: string) -> ()
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

--- @param oddsOpener (crateId: string, currency: string) -> ()
--- @param resultsOpener (crateId: string, count: number, payWith: string, results: { Crates_Result }) -> ()
function Module.Start(oddsOpener, resultsOpener)
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["List"] = moduleGui:FindFirstChild("U_CrateList", true) --- @type ScrollingFrame
	elems["TutorialCrate"] = moduleGui:FindFirstChild("U_TutorialCrate", true) --- @type Frame
	prefabs["CrateCard"] = elems["List"]:FindFirstChild("PREFAB | CrateCard") --- @type Frame
	elems["Badge"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("U_OpenCrates", true):FindFirstChild("S_Badge", true) --- @type Frame
	elems["BadgeCount"] = elems["Badge"]:FindFirstChild("S_Count", true) --- @type TextLabel
	showOdds = oddsOpener
	showResults = resultsOpener

	--[[ Building ]]

	--- @param row Crates_CrateData
	for crateId: string, row in pairs(I.G_Crates.GetAll()) do
		if not row.Hidden then
			Module._buildCard(crateId, row)
		end
	end

	--[[ Connections ]]

	I.Interact.OnPress(elems["TutorialCrate"]:FindFirstChild("S_Open", true):FindFirstChild("Button"), function()
		Module.Open(_settings.TUTORIAL_CRATE, 1, "Coins")
	end)
	I.Topic.Subscribe("Currency_Changed", Module._refreshBadge)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Card

--[[
	Makes a crate's card: its picture, name and prices, and connects its buttons.
]]
--- @param row Crates_CrateData
function Module._buildCard(crateId: string, row)
	--[[ Local Variables ]]

	paying[crateId] = if row.Prices["Coins"] then "Coins" else "Diamonds"

	--[[ Cloning ]]

	local card: Frame = prefabs["CrateCard"]:Clone()
	card.Name = crateId
	card.LayoutOrder = row.LayoutOrder
	card.Visible = true

	--[[ Elements ]]

	local payCoins: Frame = card:FindFirstChild("S_PayCoins", true)
	local payDiamonds: Frame = card:FindFirstChild("S_PayDiamonds", true)

	--[[ Texts ]]

	card:FindFirstChild("S_Picture", true).Image = row.Picture
	card:FindFirstChild("S_Name", true).Text = row.Name
	payCoins:FindFirstChild("ButtonText", true).Text = if row.Prices["Coins"] then `{row.Prices["Coins"].One} COINS` else ""
	payDiamonds:FindFirstChild("ButtonText", true).Text = if row.Prices["Diamonds"] then `{row.Prices["Diamonds"].One} DIAMONDS` else ""

	--[[ Visibility ]]

	card:FindFirstChild("S_Free", true).Visible = false

	--[[ Saving ]]

	card.Parent = elems["List"]
	cards[crateId] = card

	--[[ Connections ]]

	I.Interact.OnPress(payCoins:FindFirstChild("Button"), function()
		Module._pick(crateId, "Coins")
	end)
	I.Interact.OnPress(payDiamonds:FindFirstChild("Button"), function()
		Module._pick(crateId, "Diamonds")
	end)
	I.Interact.OnPress(card:FindFirstChild("S_Open", true):FindFirstChild("Button"), function()
		Module.Open(crateId, 1, if Module._isFree(crateId) then "VipDaily" else paying[crateId])
	end)
	I.Interact.OnPress(card:FindFirstChild("S_Open10", true):FindFirstChild("Button"), function()
		Module.Open(crateId, 10, paying[crateId])
	end)
	I.Interact.OnPress(card:FindFirstChild("S_Details", true):FindFirstChild("Button"), function()
		showOdds(crateId, paying[crateId])
	end)
	Module._refreshCard(crateId)
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

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the tutorial crate in place of the list while it waits, the free badge on VIP's daily crate, and the lobby's
	Crates button badge.
]]
function Module._refresh()
	--[[ Visibility ]]

	local tutorialReady: boolean = tutorialRep ~= nil and tutorialRep:GetAttribute("CrateReady") == true
	elems["TutorialCrate"].Visible = tutorialReady
	elems["List"].Visible = not tutorialReady

	--[[ Cards ]]

	for crateId: string, _card: Frame in pairs(cards) do
		Module._refreshCard(crateId)
	end

	--[[ Badge ]]

	Module._refreshBadge()
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Picks the currency a crate pays with.
]]
function Module._pick(crateId: string, currency: string)
	--[[ Saving ]]

	paying[crateId] = currency

	--[[ Applying ]]

	Module._refreshCard(crateId)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Card

--[[
	Shows a card's currencies (none bought with Robux where the policy restricts paid random items, and no card left
	without one), tints the picked one and shows the free badge.
]]
function Module._refreshCard(crateId: string)
	--[[ Data ]]

	local row = I.G_Crates.Get(crateId) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Elements ]]

	local card: Frame = cards[crateId]
	local payCoins: Frame = card:FindFirstChild("S_PayCoins", true)
	local payDiamonds: Frame = card:FindFirstChild("S_PayDiamonds", true)
	local coinsFace: ImageLabel = payCoins:FindFirstChild("Face", true)
	local diamondsFace: ImageLabel = payDiamonds:FindFirstChild("Face", true)

	--[[ Local Variables ]]

	local restricted: boolean = policyRep == nil or policyRep:GetAttribute("ArePaidRandomItemsRestricted") ~= false
	local coinsShown: boolean = row.Prices["Coins"] ~= nil and not (restricted and table.find(_settings.PAID_CURRENCIES, "Coins") ~= nil)
	local diamondsShown: boolean = row.Prices["Diamonds"] ~= nil and not (restricted and table.find(_settings.PAID_CURRENCIES, "Diamonds") ~= nil)
	if (paying[crateId] == "Coins" and not coinsShown) or (paying[crateId] == "Diamonds" and not diamondsShown) then
		paying[crateId] = if coinsShown then "Coins" else "Diamonds"
	end

	--[[ Visibility ]]

	payCoins.Visible = coinsShown
	payDiamonds.Visible = diamondsShown
	card.Visible = coinsShown or diamondsShown

	--[[ Applying ]]

	-- The paying currency's tab wears its selected skin (the gui kit's button records both skins)
	coinsFace.Image = coinsFace:GetAttribute(if paying[crateId] == "Coins" then "Kit_SelectedImage" else "Kit_Image")
	diamondsFace.Image = diamondsFace:GetAttribute(if paying[crateId] == "Diamonds" then "Kit_SelectedImage" else "Kit_Image")
	card:FindFirstChild("S_Free", true).Visible = Module._isFree(crateId)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Badge

--[[
	Shows the lobby's Crates button badge: BADGE_FREE while a free crate waits (the tutorial's, or VIP's daily one), else
	how many of the cheapest coin crate the player's coins open (BADGE_MAX+ past BADGE_MAX), hidden at none.
]]
function Module._refreshBadge()
	--[[ Local Variables ]]

	local free: boolean = (tutorialRep ~= nil and tutorialRep:GetAttribute("CrateReady") == true) or Module._isFree(_settings.VIP_CRATE)
	local price: string? = Module._getCheapestCoinPrice()
	local count = if price then I.BN.DivideWithPrecision(I.Currency.Get("Coins") or "0", price) else I.BN.new(0) --- @type BigNum_Instance
	local max = I.BN.new(_settings.BADGE_MAX) --- @type BigNum_Instance

	--[[ Applying ]]

	elems["Badge"].Visible = free or I.BN.Lt(I.BN.new(0), count)
	elems["BadgeCount"].Text = if free then _settings.BADGE_FREE elseif I.BN.Lt(max, count) then `{_settings.BADGE_MAX}+` else tostring(count)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Free

--[[
	Returns whether the player's free daily VIP crate is this one, and ready.
]]
--- @return boolean
function Module._isFree(crateId: string)
	return crateId == _settings.VIP_CRATE and shopRep ~= nil and shopRep:GetAttribute("VipCrateReady") == true
end

--%%%%%%%%%%%%%%%%%%%% Get Cheapest Coin Price

--[[
	Returns the lowest price of one crate in coins, among the crates the panel shows.
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

return Module
