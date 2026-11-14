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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Button

--[[
	Returns the button of a card: the card itself when it is one (the lobby's ported cards), else the ImageButton a
	theme control keeps inside it (the match hud's).
]]
local function getButton(card: Instance): GuiButton
	return if card:IsA("GuiButton") then card else card:FindFirstChild("Button", true)
end

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

--- @class Cosmetics_Client_Emotes
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local hud: ScreenGui = I.UserInterface.UI[_settings.MATCH_HUD_GUI_NAME]
	elems["Row"] = I.UserInterface.UI[_settings.LOADOUT_GUI_NAME]:FindFirstChild("U_Emotes", true) --- @type ScrollingFrame
	elems["EmoteButton"] = hud:FindFirstChild("U_EmoteButton", true) --- @type GuiObject
	elems["Wheel"] = hud:FindFirstChild("U_EmoteWheel", true) --- @type Frame
	elems["Party"] = I.UserInterface.UI[_settings.PARTY_GUI_NAME]:FindFirstChild("U_Members", true) --- @type Frame
	prefabs["Emote"] = elems["Row"]:FindFirstChild("PREFAB | Emote") --- @type ImageButton
	prefabs["WheelEmote"] = elems["Wheel"]:FindFirstChild("PREFAB | WheelEmote") --- @type GuiObject

	--[[ Applying ]]

	elems["Wheel"].Visible = false

	--[[ Connections ]]

	I.Interact.OnPress(getButton(elems["EmoteButton"]), function()
		elems["Wheel"].Visible = not elems["Wheel"].Visible
	end)
	I.S.UserInputService.InputBegan:Connect(Module._onInput)
	elems["EmoteButton"]:GetPropertyChangedSignal("Visible"):Connect(function()
		if not elems["EmoteButton"].Visible then
			elems["Wheel"].Visible = false
		end
	end)
	elems["Wheel"]:GetPropertyChangedSignal("Visible"):Connect(Module._onWheelShown)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.Network.Fired("Cosmetics_EmotePlayed", Module._onEmotePlayed)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws the owned emotes twice: in the lobby's emote row (before its + for the emote shop), and around the match's
	emote wheel.
]]
function Module._refresh()
	--[[ Clearing ]]

	for _index: number, holder: Instance in ipairs({ elems["Row"], elems["Wheel"] }) do
		for _childIndex: number, child: Instance in ipairs(holder:GetChildren()) do
			if child:IsA("GuiObject") and child.Name:sub(1, 6) == "Emote_" then
				child:Destroy()
			end
		end
	end

	--[[ Local Variables ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	local owned = {} --- @type { string }
	for itemId: string, _quantity: string in pairs(standard) do
		if I.G_Cosmetics.GetEmotes()[itemId] then
			table.insert(owned, itemId)
		end
	end
	table.sort(owned)

	--[[ Building ]]

	for index: number, emoteId: string in ipairs(owned) do
		local angle: number = math.rad(index / #owned * 360 - 90)
		local rowEmote: GuiObject = Module._makeEmote(prefabs["Emote"], emoteId)
		rowEmote.LayoutOrder = index
		rowEmote.Visible = true
		rowEmote.Parent = elems["Row"]
		local wheelEmote: GuiObject = Module._makeEmote(prefabs["WheelEmote"], emoteId)
		wheelEmote.Position = UDim2.fromScale(0.5 + math.cos(angle) * _settings.WHEEL_RADIUS, 0.5 + math.sin(angle) * _settings.WHEEL_RADIUS)
		wheelEmote.Visible = true
		wheelEmote.Parent = elems["Wheel"]
	end
end

--%%%%%%%%%%%%%%%%%%%% Make Emote

--[[
	Clones an emote card from a prefab, named after its emote, that plays it when pressed.
]]
--- @return GuiObject
function Module._makeEmote(prefab: Instance, emoteId: string)
	--[[ Data ]]

	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?

	--[[ Cloning ]]

	local card: GuiObject = prefab:Clone()
	card.Name = emoteId

	--[[ Elements ]]

	-- Only a theme Item card has an info line (the match hud's wheel), which an emote leaves empty
	local info: TextLabel? = card:FindFirstChild("S_Info", true)

	--[[ Texts ]]

	card:FindFirstChild("S_Icon", true).Image = if item then item.IconId else ""
	card:FindFirstChild("S_Name", true).Text = if item then item.Name else emoteId
	if info then
		info.Text = ""
	end

	--[[ Connections ]]

	I.Interact.OnPress(getButton(card), function()
		elems["Wheel"].Visible = false

		-- A snail that's hit or thrown can't emote
		local skin: Model? = Module._getSkin(I.S.Players.LocalPlayer.UserId, I.S.Players.LocalPlayer)
		if skin and not I.SnailRig.CanEmote(skin) then
			return
		end
		I.Network.Fire("Cosmetics_PlayEmote", emoteId)
	end)

	--[[ Returning ]]

	return card
end

--%%%%%%%%%%%%%%%%%%%% On Input

--[[
	Closes the emote wheel when the player clicks or taps anywhere but a button (the world, the wheel's gaps).
]]
function Module._onInput(input: InputObject, gameProcessed: boolean)
	--[[ Checks ]]

	-- Check if the wheel is open and a button didn't take the press
	if not elems["Wheel"].Visible or gameProcessed then
		return
	end

	-- Check if it's a click or a tap
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	--[[ Closing ]]

	elems["Wheel"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% On Wheel Shown

--[[
	On a pad, the emote wheel takes the gamepad's selection while it's open, and B closes it (the Console module's focus).
]]
function Module._onWheelShown()
	--[[ Focusing ]]

	if elems["Wheel"].Visible then
		I.Console.Focus(elems["Wheel"], function()
			elems["Wheel"].Visible = false
		end)
	else
		I.Console.Unfocus(elems["Wheel"])
	end
end

--%%%%%%%%%%%%%%%%%%%% On Emote Played

--[[
	A played emote, on every screen: the player's snail (by UserId) or a bot's (by its snail's id) plays it (in a match,
	or on the lobby's stage), its icon pops up in a thought cloud over that snail's head, and in the lobby also in a
	speech bubble beside their party card's name.
]]
function Module._onEmotePlayed(who: number | string, emoteId: string)
	--[[ Data ]]

	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?
	local player: Player? = if type(who) == "number" then I.S.Players:GetPlayerByUserId(who) else nil
	if not item then
		return
	end

	--[[ Animating ]]

	-- Refused while the snail is hit or thrown on this screen: no bubble either
	local skin: Model? = Module._getSkin(who, player)
	if skin and not I.SnailRig.Emote(skin, emoteId, _settings.EMOTE_SECONDS) then
		return
	end

	--[[ Bubbles ]]

	I.ChatBubbles.ShowIcon(who, item.IconId)
	if I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		return
	end
	local member: GuiObject? = elems["Party"]:FindFirstChild(tostring(who))
	if member then
		Module._showCardBubble(member, item.IconId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Card Bubble

--[[
	Pops an emote's icon up in a speech bubble just after the player's name on their party card, its tail pointing at
	the name, sized with the screen, and takes it away after EMOTE_SECONDS.
]]
function Module._showCardBubble(member: GuiObject, image: string)
	--[[ Elements ]]

	local name: TextLabel = member:FindFirstChild("S_Name", true)
	local old: Instance? = member:FindFirstChild("EmoteBubble")

	--[[ Local Variables ]]

	local unit: number = elems["Party"]:FindFirstAncestorOfClass("ScreenGui").AbsoluteSize.Y / 1080
	local nameEnd: number = name.AbsolutePosition.X + math.min(name.TextBounds.X, name.AbsoluteSize.X)
	local x: number = nameEnd - member.AbsolutePosition.X + _settings.CARD_BUBBLE_GAP * unit
	local y: number = name.AbsolutePosition.Y + name.AbsoluteSize.Y / 2 - member.AbsolutePosition.Y

	--[[ Building ]]

	if old then
		old:Destroy()
	end
	local bubble: Frame = I.ChatBubbles.BuildIconBubble(image, true)
	bubble.Name = "EmoteBubble"
	bubble.AnchorPoint = Vector2.new(0, 0.5)
	bubble.Position = UDim2.fromOffset(x, y)
	bubble.ZIndex = 20
	bubble.Parent = member

	--[[ Tweening ]]

	local pop: UIScale = bubble:FindFirstChild("S_Pop")
	pop.Scale = unit * 0.6
	local Pop_TweenInfo: TweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Pop_TweenGoal = { Scale = unit }
	local Pop_Tween: Tween = I.S.TweenService:Create(pop, Pop_TweenInfo, Pop_TweenGoal)
	Pop_Tween:Play()
	I.S.Debris:AddItem(bubble, _settings.EMOTE_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Skin

--[[
	Returns the skin of a snail this screen shows (a player's by UserId, a bot's by its snail's id): theirs in a match,
	a player's on the lobby's stage; nil when it shows none.
]]
--- @return Model?
function Module._getSkin(who: number | string, player: Player?)
	--[[ Match ]]

	if I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		local model: Model? = I.Snails.Get(if type(who) == "string" then who else `P_{who}`)
		return if model then model:FindFirstChild("Skin") else nil
	end

	--[[ Checks ]]

	-- Check if this map has the lobby's stage (the match map leaves Lobby out)
	if not player or not I.Lobby then
		return nil
	end

	--[[ Returning ]]

	return I.Lobby.GetStageSnail(player)
end

return Module
