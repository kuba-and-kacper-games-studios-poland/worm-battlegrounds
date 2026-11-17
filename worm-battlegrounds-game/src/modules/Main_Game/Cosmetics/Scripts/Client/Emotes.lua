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

--[[ Wheel ]]

-- The wheel's slices round the ring from the top, and their emotes
local slices = {} --- @type { Frame }
local sliceEmotes = {} --- @type { string }

-- The slice pointed at (0 for none), whether the wheel's key holds it open (else a press opened it) and since when
local hovered: number = 0
local holding: boolean = false
local heldAt: number = 0

-- What a quick tap of the wheel's key plays: the last emote picked from the wheel
local lastEmote: string = _settings.WHEEL_BUTTON_EMOTE

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
	elems["EmoteButton"] = hud:FindFirstChild("U_EmoteButton", true) --- @type Frame
	elems["EmoteButtonPress"] = elems["EmoteButton"]:FindFirstChild("Button") --- @type ImageButton
	elems["EmoteButtonIcon"] = elems["EmoteButton"]:FindFirstChild("S_Icon", true) --- @type ImageLabel
	elems["Wheel"] = hud:FindFirstChild("U_EmoteWheel", true) --- @type Frame
	elems["WheelPop"] = elems["Wheel"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["Slices"] = elems["Wheel"]:FindFirstChild("S_Slices") --- @type Frame
	elems["WheelName"] = elems["Wheel"]:FindFirstChild("S_Name", true) --- @type TextLabel
	elems["WheelSub"] = elems["Wheel"]:FindFirstChild("S_Sub", true) --- @type TextLabel
	elems["WheelHit"] = elems["Wheel"]:FindFirstChild("S_Hit") --- @type ImageButton
	elems["Party"] = I.UserInterface.UI[_settings.PARTY_GUI_NAME]:FindFirstChild("U_Party", true) --- @type Frame
	prefabs["WheelSlice"] = elems["Wheel"]:FindFirstChild("PREFAB | WheelSlice") --- @type Frame

	--[[ Applying ]]

	local buttonEmote = I.G_Inventory.Items[_settings.WHEEL_BUTTON_EMOTE] --- @type Inventory_ItemData?
	elems["Wheel"].Visible = false
	elems["EmoteButtonIcon"].Image = if buttonEmote then buttonEmote.IconId else ""

	--[[ Connections ]]

	I.Interact.OnPress(elems["EmoteButtonPress"], Module._onButton)
	I.Interact.OnPress(elems["WheelHit"], Module._onWheelPress)
	elems["WheelHit"].InputBegan:Connect(Module._onWheelInput)
	I.S.UserInputService.InputBegan:Connect(Module._onInputBegan)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.UserInputService.InputEnded:Connect(Module._onInputEnded)
	elems["EmoteButton"]:GetPropertyChangedSignal("Visible"):Connect(Module._onButtonShown)
	hud:GetPropertyChangedSignal("Enabled"):Connect(Module._onButtonShown)
	elems["Wheel"]:GetPropertyChangedSignal("Visible"):Connect(Module._onWheelShown)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.Network.Fired("Cosmetics_EmotePlayed", Module._onEmotePlayed)
	Module._refresh()
	Module._onButtonShown()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Builds the match's emote wheel: a slice per emote in a fixed order (as the emote shop: by the level that unlocks it,
	then its price), each cut to its share of the ring with its icon at the share's middle; one not owned yet is greyed
	under a lock and its level.
]]
function Module._refresh()
	--[[ Clearing ]]

	for _index: number, slice: Frame in ipairs(slices) do
		slice:Destroy()
	end
	slices = {}
	sliceEmotes = Module._getWheelEmotes()
	hovered = 0

	--[[ Local Variables ]]

	local share: number = 360 / math.max(#sliceEmotes, 1)
	local gap: number = _settings.WHEEL_SLICE_GAP / 2

	--[[ Building ]]

	for index: number, emoteId: string in ipairs(sliceEmotes) do
		local middle: number = (index - 1) * share
		slices[index] = Module._makeSlice(emoteId, middle - share / 2 + gap, middle + share / 2 - gap)
	end
end

--%%%%%%%%%%%%%%%%%%%% Make Slice

--[[
	Clones an emote's slice of the wheel, cut to the ring between two directions (degrees clockwise from the top): its
	disc's gradient keeps the half from the first direction on, its group's the half up to the second. A gradient keeps
	the half-plane centred 90° before its rotation, as Roblox turns gradients clockwise from the right.
]]
--- @return Frame
function Module._makeSlice(emoteId: string, from: number, to: number)
	--[[ Data ]]

	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?
	local emote = I.G_Cosmetics.GetEmote(emoteId) --- @type Cosmetics_EmoteData?

	--[[ Local Variables ]]

	local owned: boolean = Module._isOwned(emoteId)
	local middle: number = math.rad((from + to) / 2)

	--[[ Cloning ]]

	local slice: Frame = prefabs["WheelSlice"]:Clone()
	slice.Name = emoteId

	--[[ Elements ]]

	local icon: ImageLabel = slice:FindFirstChild("S_Icon")
	local level: TextLabel = icon:FindFirstChild("S_Level")

	--[[ Cutting ]]

	slice:FindFirstChild("S_CutStart", true).Rotation = from + 180
	slice:FindFirstChild("S_CutEnd", true).Rotation = to

	--[[ Icon ]]

	icon.Image = if item then item.IconId else ""
	icon.Position = UDim2.fromScale(0.5 + math.sin(middle) * _settings.WHEEL_ICON_RADIUS, 0.5 - math.cos(middle) * _settings.WHEEL_ICON_RADIUS)
	icon.ImageColor3 = if owned then Color3.new(1, 1, 1) else slice:GetAttribute("Look_LockedIconColor")
	icon.ImageTransparency = if owned then 0 else slice:GetAttribute("Look_LockedIconTransparency")
	icon:FindFirstChild("S_Lock").Visible = not owned
	level.Visible = not owned and emote ~= nil and emote.Level > 1
	level.Text = if emote then string.format(_settings.WHEEL_LEVEL_TEXT, emote.Level) else ""

	--[[ Saving ]]

	slice.Visible = true
	slice.Parent = elems["Slices"]
	return slice
end

--%%%%%%%%%%%%%%%%%%%% On Button Shown

--[[
	While the HUD's emote button shows (the player's snail is in play in a match), WHEEL_KEY opens the wheel, bound over
	the game's keys; once it hides, the key goes and the wheel closes.
]]
function Module._onButtonShown()
	--[[ Applying ]]

	if I.Utils.IsGuiShown(elems["EmoteButton"]) then
		I.S.ContextActionService:BindActionAtPriority("Cosmetics_EmoteWheel", Module._onKey, false, Enum.ContextActionPriority.High.Value, _settings.WHEEL_KEY)
	else
		I.S.ContextActionService:UnbindAction("Cosmetics_EmoteWheel")
		Module._close()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Key

--[[
	WHEEL_KEY held opens the wheel; let go, it plays what's pointed at (a quick tap, the last emote again).
]]
--- @return Enum.ContextActionResult
function Module._onKey(_action: string, state: Enum.UserInputState, _input: InputObject)
	--[[ Applying ]]

	if state == Enum.UserInputState.Begin then
		Module._hold()
	elseif state == Enum.UserInputState.End then
		Module._release()
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Button

--[[
	The emote button opens the wheel to pick from with a click or a tap (or the pad's selection), or closes it.
]]
function Module._onButton()
	--[[ Applying ]]

	if elems["Wheel"].Visible then
		Module._close()
	else
		holding = false
		Module._open()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Wheel Input

--[[
	A click or a tap on the wheel points at the slice under it, which its press then plays.
]]
function Module._onWheelInput(input: InputObject)
	--[[ Checks ]]

	-- Check if it's a click or a tap
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	--[[ Pointing ]]

	Module._pointAt(Vector2.new(input.Position.X, input.Position.Y))
end

--%%%%%%%%%%%%%%%%%%%% On Wheel Press

--[[
	A press on the wheel plays the slice pointed at: the one clicked or tapped, or on a pad the one the stick points at.
]]
function Module._onWheelPress()
	--[[ Playing ]]

	Module._pick(sliceEmotes[hovered])
end

--%%%%%%%%%%%%%%%%%%%% On Input Began

--[[
	Holding the pad's Emotes button (X, the Console module's) opens the wheel; a click or tap anywhere but a button
	closes it.
]]
function Module._onInputBegan(input: InputObject, gameProcessed: boolean)
	--[[ Holding ]]

	if I.Console.IsAction("Emotes", input.KeyCode) and not gameProcessed and I.Utils.IsGuiShown(elems["EmoteButton"]) then
		Module._hold()
		return
	end

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

	Module._close()
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	While the wheel is open, points at the slice in the mouse's direction from its middle, or the one the left stick
	leans toward (the Console module's Move).
]]
function Module._onInputChanged(input: InputObject)
	--[[ Checks ]]

	-- Check if the wheel is open
	if not elems["Wheel"].Visible then
		return
	end

	--[[ Pointing ]]

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		Module._pointAt(Vector2.new(input.Position.X, input.Position.Y))
	elseif I.Console.IsAction("Move", input.KeyCode) and input.Position.Magnitude >= _settings.WHEEL_STICK_DEADZONE then
		-- The stick's Y points up
		Module._hover(Module._getSliceAt(math.deg(math.atan2(input.Position.X, input.Position.Y))))
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Ended

--[[
	Letting go of the pad's Emotes button plays what the wheel points at.
]]
function Module._onInputEnded(input: InputObject)
	--[[ Checks ]]

	-- Check if it's the pad's Emotes button
	if not I.Console.IsAction("Emotes", input.KeyCode) then
		return
	end

	--[[ Playing ]]

	Module._release()
end

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Opens the wheel held by its key (T, or the pad's X): letting go plays what's pointed at.
]]
function Module._hold()
	--[[ Opening ]]

	holding = true
	heldAt = os.clock()
	Module._open()
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Letting go of the wheel's key: a press shorter than WHEEL_TAP_SECONDS plays the last emote again, a longer one the
	emote pointed at; the wheel closes either way.
]]
function Module._release()
	--[[ Checks ]]

	-- Check if the key held the wheel
	if not holding then
		return
	end

	--[[ Playing ]]

	local quick: boolean = os.clock() - heldAt < _settings.WHEEL_TAP_SECONDS
	Module._pick(if quick then lastEmote else sliceEmotes[hovered])
end

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Opens the wheel round the middle of the screen, spinning and growing in with Emote_WheelOpen, nothing pointed at.
	It stays shut while the emote button is hidden, and while the player's snail is hit or thrown.
]]
function Module._open()
	--[[ Checks ]]

	-- Check if the wheel can open
	if elems["Wheel"].Visible or not I.Utils.IsGuiShown(elems["EmoteButton"]) or not Module._canEmote() then
		return
	end

	--[[ Opening ]]

	Module._hover(0)
	elems["Wheel"].Rotation = _settings.WHEEL_OPEN_SPIN
	elems["WheelPop"].Scale = _settings.WHEEL_OPEN_SCALE
	elems["Wheel"].Visible = true
	I.Sound.Play({ Name = "Emote_WheelOpen", SoundGroup = "UI" })

	--[[ Tweening ]]

	local Spin_TweenGoal = { Rotation = 0 }
	local Spin_Tween: Tween = I.S.TweenService:Create(elems["Wheel"], _settings.WHEEL_OPEN_TWEENINFO, Spin_TweenGoal)
	Spin_Tween:Play()
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["WheelPop"], _settings.WHEEL_OPEN_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Closes the wheel, its pointed slice back to rest.
]]
function Module._close()
	--[[ Applying ]]

	holding = false
	Module._hover(0)
	elems["Wheel"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Closes the wheel and plays an emote the player owns, unless their snail is hit or thrown; a quick tap of the wheel's
	key plays it again.
]]
function Module._pick(emoteId: string?)
	--[[ Closing ]]

	Module._close()

	--[[ Checks ]]

	-- Check if an owned emote was picked
	if not emoteId or not Module._isOwned(emoteId) then
		return
	end

	-- Check if the snail can emote (not while it's hit or thrown)
	if not Module._canEmote() then
		return
	end

	--[[ Sending ]]

	lastEmote = emoteId
	I.Network.Fire("Cosmetics_PlayEmote", emoteId)
end

--%%%%%%%%%%%%%%%%%%%% Point At

--[[
	Points at the slice in the direction of a spot on the screen from the wheel's middle; nothing over the middle.
]]
function Module._pointAt(position: Vector2)
	--[[ Local Variables ]]

	local wheel: Frame = elems["Wheel"]
	local offset: Vector2 = position - (wheel.AbsolutePosition + wheel.AbsoluteSize / 2)

	--[[ Pointing ]]

	if offset.Magnitude < wheel.AbsoluteSize.Y * _settings.WHEEL_DEAD_RADIUS then
		Module._hover(0)
	else
		-- Degrees clockwise from the top: the screen's Y points down
		Module._hover(Module._getSliceAt(math.deg(math.atan2(offset.X, -offset.Y))))
	end
end

--%%%%%%%%%%%%%%%%%%%% Hover

--[[
	Lights the slice pointed at in the player's colour, grown, with Emote_WheelHover, and names its emote in the middle
	(with what opens one not owned yet); the slice before goes back to rest. With nothing pointed at, the middle names
	what a quick tap plays.
]]
function Module._hover(index: number)
	--[[ Checks ]]

	-- Check if the pointed slice changed (pointing at nothing still names the quick tap's emote)
	if index == hovered and index ~= 0 then
		return
	end

	--[[ Data ]]

	local emoteId: string = sliceEmotes[index] or lastEmote
	local item = I.G_Inventory.Items[emoteId] --- @type Inventory_ItemData?
	local emote = I.G_Cosmetics.GetEmotes()[emoteId] --- @type Cosmetics_EmoteData?

	--[[ Local Variables ]]

	local previous: Frame? = slices[hovered]
	local slice: Frame? = slices[index]
	local level: number = I.S.Players.LocalPlayer:GetAttribute("Level") or 1
	hovered = index

	--[[ Slices ]]

	if previous then
		Module._lightSlice(previous, nil)
	end
	if slice then
		Module._lightSlice(slice, Module._getMyColor())
		I.Sound.Play({ Name = "Emote_WheelHover", SoundGroup = "UI" })
	end

	--[[ Texts ]]

	elems["WheelName"].Text = if item then item.Name else ""
	elems["WheelSub"].Text = ""
	if slice and emote and not Module._isOwned(emoteId) then
		elems["WheelSub"].Text = if level >= emote.Level then _settings.WHEEL_SHOP_TEXT else string.format(_settings.WHEEL_LOCKED_TEXT, emote.Level)
	end
end

--%%%%%%%%%%%%%%%%%%%% Light Slice

--[[
	Lights a slice in a colour, grown out from the wheel's middle over its neighbours, or puts it back to rest (its
	Look_* attributes).
]]
function Module._lightSlice(slice: Frame, color: Color3?)
	--[[ Elements ]]

	local wedge: Frame = slice:FindFirstChild("S_Wedge", true)

	--[[ Applying ]]

	slice.ZIndex = if color then 22 else 21
	wedge.BackgroundColor3 = color or slice:GetAttribute("Look_Color")
	wedge.BackgroundTransparency = if color then 0 else slice:GetAttribute("Look_Transparency")

	--[[ Tweening ]]

	local Grow_TweenGoal = { Scale = if color then _settings.WHEEL_HOVER_SCALE else 1 }
	local Grow_Tween: Tween = I.S.TweenService:Create(slice:FindFirstChild("S_Grow"), _settings.WHEEL_HOVER_TWEENINFO, Grow_TweenGoal)
	Grow_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% On Wheel Shown

--[[
	On a pad, the wheel opened from the button takes the gamepad's selection while it's open (the stick points, A plays,
	B closes it: the Console module's focus); one held open by X needs none.
]]
function Module._onWheelShown()
	--[[ Focusing ]]

	if elems["Wheel"].Visible and not holding then
		I.Console.Focus(elems["Wheel"], Module._close)
	else
		I.Console.Unfocus(elems["Wheel"])
	end
end

--%%%%%%%%%%%%%%%%%%%% On Emote Played

--[[
	A played emote, on every screen: the player's snail (by UserId) or a bot's (by its snail's id) plays it (in a match,
	or on the lobby's stage), its icon pops up in a thought cloud over that snail's head, and in the lobby also in a
	speech bubble over their party card's avatar.
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

	-- A card named by the user id, in either of the party panel's columns
	local member: GuiObject? = elems["Party"]:FindFirstChild(tostring(who), true)
	if member then
		Module._showCardBubble(member, item.IconId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Card Bubble

--[[
	Pops an emote's icon up in a speech bubble over the top right corner of the avatar on a party card, its tail
	pointing down at the picture, so it never covers the name or the badges: inside the avatar, so the column's layout
	and scale carry it. It's CARD_BUBBLE_SIZE of the avatar tall, and goes after EMOTE_SECONDS.
]]
function Module._showCardBubble(member: GuiObject, image: string)
	--[[ Elements ]]

	local avatar: GuiObject = member:FindFirstChild("S_Avatar", true)
	local old: Instance? = avatar:FindFirstChild("EmoteBubble")

	--[[ Building ]]

	if old then
		old:Destroy()
	end
	local bubble: Frame = I.ChatBubbles.BuildIconBubble(image)
	local pop: UIScale = bubble:FindFirstChild("S_Pop")
	bubble.Name = "EmoteBubble"
	bubble.AnchorPoint = Vector2.new(0.5, 1)
	bubble.Position = UDim2.fromScale(_settings.CARD_BUBBLE_ANCHOR.X, _settings.CARD_BUBBLE_ANCHOR.Y)
	bubble.ZIndex = 20
	pop.Scale = 1
	bubble.Parent = avatar

	--[[ Local Variables ]]

	-- The bubble's height on the screen at its own size (the column's scales included), against the avatar's
	local scale: number = _settings.CARD_BUBBLE_SIZE * avatar.AbsoluteSize.Y / math.max(bubble.AbsoluteSize.Y, 1)

	--[[ Tweening ]]

	pop.Scale = scale * 0.6
	local Pop_TweenInfo: TweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Pop_TweenGoal = { Scale = scale }
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

--%%%%%%%%%%%%%%%%%%%% Get Wheel Emotes

--[[
	Returns every emote in the wheel's order, as the emote shop: by the level that unlocks it, then its price, then its
	id.
]]
--- @return { string }
function Module._getWheelEmotes()
	--[[ Data ]]

	local emotes = I.G_Cosmetics.GetEmotes() --- @type { [string]: Cosmetics_EmoteData }

	--[[ Sorting ]]

	local order = {} --- @type { string }
	--- @param _emote Cosmetics_EmoteData
	for emoteId: string, _emote in pairs(emotes) do
		table.insert(order, emoteId)
	end
	table.sort(order, function(a: string, b: string): boolean
		local keyA: number = emotes[a].Level * 1e6 + (tonumber(emotes[a].Coins) or 0)
		local keyB: number = emotes[b].Level * 1e6 + (tonumber(emotes[b].Coins) or 0)
		return if keyA == keyB then a < b else keyA < keyB
	end)

	--[[ Returning ]]

	return order
end

--%%%%%%%%%%%%%%%%%%%% Get Slice At

--[[
	Returns the wheel's slice in a direction from its middle (degrees clockwise from the top), the first at the top; 0
	when it has none.
]]
--- @return number
function Module._getSliceAt(degrees: number)
	--[[ Checks ]]

	-- Check if the wheel has slices
	if #slices == 0 then
		return 0
	end

	--[[ Returning ]]

	local share: number = 360 / #slices
	return math.floor(((degrees + share / 2) % 360) / share) + 1
end

--%%%%%%%%%%%%%%%%%%%% Get My Color

--[[
	Returns the player's colour in the match (their team's, or their own in a free-for-all), that lights the slice they
	point at.
]]
--- @return Color3
function Module._getMyColor()
	--[[ Data ]]

	local entry: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())

	--[[ Returning ]]

	return if entry then entry:GetAttribute("Color") else Color3.new(1, 1, 1)
end

--%%%%%%%%%%%%%%%%%%%% Is Owned

--[[
	Returns whether the player owns an emote.
]]
--- @return boolean
function Module._isOwned(emoteId: string)
	--[[ Data ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }

	--[[ Returning ]]

	return standard[emoteId] ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Can Emote

--[[
	Returns whether the player's snail may emote now: not while it's hit or thrown (a screen with no snail of theirs
	always may).
]]
--- @return boolean
function Module._canEmote()
	--[[ Data ]]

	local skin: Model? = Module._getSkin(I.S.Players.LocalPlayer.UserId, I.S.Players.LocalPlayer)

	--[[ Returning ]]

	return not skin or I.SnailRig.CanEmote(skin)
end

return Module
