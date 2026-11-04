--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Shop"

--- @type Shop_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

-- The top bar button, hidden while the player is in a match (the Studio map plays both on one server)
local topBarButton = nil --- @type TopBar_Button?

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._getElements()
	Module._createConnections()
	Module._addTopBarButton()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the shop widget's lists and prefabs.
]]
function Module._getElements()
	--[[ General ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Packs"] = moduleGui:FindFirstChild("U_Packs", true) --- @type ScrollingFrame
	elems["Passes"] = moduleGui:FindFirstChild("U_Passes", true) --- @type ScrollingFrame

	--[[ Prefab ]]

	prefabs["Pack"] = elems["Packs"]:FindFirstChild("PREFAB | Pack") --- @type Frame
	prefabs["Pass"] = elems["Passes"]:FindFirstChild("PREFAB | Pass") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Draws the shop when it opens (the currency bar's + opens it through its tags), and tags VIP players' chat
	messages.
]]
function Module._createConnections()
	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.S.TextChatService.OnIncomingMessage = Module._onIncomingMessage
end

--%%%%%%%%%%%%%%%%%%%% Add Top Bar Button

--[[
	Adds the top bar button that opens the shop, on the maps that sell from it.
]]
function Module._addTopBarButton()
	--[[ Checks ]]

	-- Check if this map shows the button
	if not table.find(_settings.TOP_BAR_MAPS, I.Config.PlaceLoader.MapId) then
		return
	end

	--[[ Building ]]

	topBarButton = I.TopBar.AddButton("Left")
	topBarButton:SetLayoutOrder(2)
	topBarButton:SetText(_settings.TOP_BAR_TEXT)
	topBarButton:SetCallback(function()
		I.WidgetManager.Open(_settings.GUI_NAME)
	end)

	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshTopBarButton)
	Module._refreshTopBarButton()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Top Bar Button

--[[
	Hides the top bar button while the player is in a match.
]]
function Module._refreshTopBarButton()
	--[[ Applying ]]

	topBarButton.Instance.Visible = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the shop when it opens: the diamond packs and the game passes, each with its live price.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the shop
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Clearing ]]

	for _index: number, holder: Instance in ipairs({ elems["Packs"], elems["Passes"] }) do
		for _childIndex: number, child: Instance in ipairs(holder:GetChildren()) do
			if child:IsA("Frame") and child ~= prefabs["Pack"] and child ~= prefabs["Pass"] then
				child:Destroy()
			end
		end
	end

	--[[ Packs ]]

	--- @param pack Shop_Pack
	for index: number, pack in ipairs(_settings.PACKS) do
		local card: Frame = prefabs["Pack"]:Clone()
		card.Name = pack.Product
		card.LayoutOrder = index
		card.Visible = true
		card:FindFirstChild("S_Name", true).Text = pack.Name
		card:FindFirstChild("S_Icon", true).Image = _settings.PACK_ICON
		card:FindFirstChild("S_Info", true).Text = `{pack.Diamonds} diamonds`
		card.Parent = elems["Packs"]
		Module._showPrice(card:FindFirstChild("S_Price", true), pack.Product, Enum.InfoType.Product)
		I.Interact.OnPress(card:FindFirstChild("Button"), function()
			I.Network.Fire("Marketplace_PromptProductPurchase", pack.Product)
		end)
	end

	--[[ Passes ]]

	--- @param pass Shop_Pass
	for index: number, pass in ipairs(_settings.PASSES) do
		local owned: boolean = I.G_Marketplace.PlayerOwnsGamePass(I.S.Players.LocalPlayer, pass.GamePass)
		local card: Frame = prefabs["Pass"]:Clone()
		local buy: Frame = card:FindFirstChild("S_Buy", true)
		card.Name = pass.GamePass
		card.LayoutOrder = index
		card.Visible = true
		card:FindFirstChild("S_Name", true).Text = pass.Name
		card:FindFirstChild("S_Benefits", true).Text = pass.Benefits
		buy:FindFirstChild("ButtonText", true).Text = if owned then "OWNED" else "BUY"
		card.Parent = elems["Passes"]
		Module._showPrice(card:FindFirstChild("S_Price", true), pass.GamePass, Enum.InfoType.GamePass)
		I.Interact.OnPress(buy:FindFirstChild("Button"), function()
			if not I.G_Marketplace.PlayerOwnsGamePass(I.S.Players.LocalPlayer, pass.GamePass) then
				I.Network.Fire("Marketplace_PromptGamePassPurchase", pass.GamePass)
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Price

--[[
	Writes a product's live Robux price on a label once Roblox answers, or a dash while it isn't on sale.
]]
function Module._showPrice(label: TextLabel, productName: string, infoType: Enum.InfoType)
	--[[ Applying ]]

	label.Text = "..."
	task.spawn(function()
		local price: (string | number)? = I.G_Marketplace.GetProductPrice(productName, infoType, true)
		label.Text = if price then tostring(price) else "-"
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Incoming Message

--[[
	Puts the VIP tag in front of a VIP player's chat messages.
]]
--- @return TextChatMessageProperties?
function Module._onIncomingMessage(message: TextChatMessage)
	--[[ Data ]]

	local source: TextSource? = message.TextSource
	local sender: Player? = source and I.S.Players:GetPlayerByUserId(source.UserId)

	--[[ Checks ]]

	-- Check if a VIP player sent it
	if not sender or sender:GetAttribute("Vip") ~= true then
		return nil
	end

	--[[ Returning ]]

	local properties: TextChatMessageProperties = Instance.new("TextChatMessageProperties")
	properties.PrefixText = _settings.VIP_CHAT_TAG .. message.PrefixText
	return properties
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
