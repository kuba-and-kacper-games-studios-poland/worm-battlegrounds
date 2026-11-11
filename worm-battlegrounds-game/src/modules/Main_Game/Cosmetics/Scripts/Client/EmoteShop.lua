--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui

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

--- @class Cosmetics_Client_EmoteShop
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.EMOTE_SHOP_GUI_NAME]
	elems["Emotes"] = moduleGui:FindFirstChild("U_Emotes", true) --- @type Frame
	prefabs["EmoteCard"] = elems["Emotes"]:FindFirstChild("PREFAB | EmoteCard") --- @type ImageButton

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the emote shop when it opens.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the emote shop
	if widgetName ~= _settings.EMOTE_SHOP_GUI_NAME then
		return
	end

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Redraws the emote shop while it's open, once a bought emote arrives.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Check if the shop shows
	if not moduleGui.Enabled then
		return
	end

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws one card per emote, cheapest first: its icon, name and rarity; one not owned yet wears the locked cover with
	its price and the level it needs, and a press buys it.
]]
function Module._draw()
	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Emotes"]:GetChildren()) do
		if child:IsA("ImageButton") and child ~= prefabs["EmoteCard"] then
			child:Destroy()
		end
	end

	--[[ Local Variables ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }

	--[[ Cards ]]

	--- @param emote Cosmetics_EmoteData
	for emoteId: string, emote in pairs(I.G_Cosmetics.GetEmotes()) do
		local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?
		if not item then
			continue
		end
		local owned: boolean = standard[emoteId] ~= nil
		local look = I.Rarity.GetLook(item.Rarity) --- @type Rarity_Look?
		local card: ImageButton = prefabs["EmoteCard"]:Clone()
		local locked: Frame = card:FindFirstChild("S_Locked")
		card.Name = emoteId
		card.LayoutOrder = emote.Level * 1000 + (tonumber(emote.Coins) or 0) // 10
		card.Visible = true
		card:FindFirstChild("S_Icon").Image = item.IconId
		card:FindFirstChild("S_Name").Text = item.Name
		card:FindFirstChild("S_Rarity").ImageColor3 = if look then look.Base else Color3.new(1, 1, 1)
		locked.Visible = not owned
		locked:FindFirstChild("S_Price").Text = if emote.Coins == "0" then "Free" else I.Format.Text(emote.Coins)
		locked:FindFirstChild("S_Level").Text = if emote.Level <= 1 then "Any level" else `Level {emote.Level}`
		card.Parent = elems["Emotes"]
		I.Interact.OnPress(card, function()
			if not owned then
				Module._buy(emoteId)
			end
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Buy

--[[
	Asks the server to buy an emote, and says why when it can't.
]]
function Module._buy(emoteId: string)
	--[[ Data ]]

	local emote = I.G_Cosmetics.GetEmote(emoteId) --- @type Cosmetics_EmoteData?
	if not emote then
		return
	end

	--[[ Buying ]]

	if not I.Network.Invoke("Cosmetics_BuyEmote", emoteId) then
		I.WidgetManager.ShowMessage(`You need level {emote.Level} and {emote.Coins} coins for this emote.`)
	end
end

return Module
