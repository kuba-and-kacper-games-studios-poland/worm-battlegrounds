--[[
	Created By: 	HungryN00B
	Edited By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "ChatBubbles"

--- @type ChatBubbles_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local worldFolder: Folder

-- The bubbles' billboard (the ChatBubble gui), cloned once per speaker
local template: BillboardGui

-- How far the newest bubble's body sits over its bubble's bottom: the tail's room, read from the gui
local tailRoom: number

-- A thought cloud's height with its trail of puffs, read from the gui
local thoughtHeight: number

--[[ Speakers ]]

-- Each speaker's billboard over their snail and its bubbles, by user id
local speakers = {} --- @type { [number]: ChatBubbles_Speaker }

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

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	worldFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	-- Roblox's own bubbles would show over the avatars parked out of sight, and twice over a snail
	I.S.TextChatService:FindFirstChildOfClass("BubbleChatConfiguration").Enabled = false

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.ChatBubbles = {

		--[[ Control ]]

		ShowIcon = Module.ShowIcon,
		BuildIconBubble = Module.BuildIconBubble,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	template = I.Dirs.Assets:FindFirstChild(_localName):FindFirstChild(_settings.TEMPLATE, true)
	tailRoom = -template:FindFirstChild("S_Body", true).Position.Y.Offset
	thoughtHeight = template:FindFirstChild("PREFAB | Thought", true).Size.Y.Offset
	I.S.TextChatService.MessageReceived:Connect(Module._onMessage)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Icon

--[[
	**CLIENT** |
	Shows a picture in a thought cloud over a player's snail, in the same stack as their chat (an emote's icon), when
	this screen shows their snail; it stays ICON_SECONDS.
]]
function Module.ShowIcon(userId: number, image: string)
	--[[ Data ]]

	--- @type ChatBubbles_Anchor?
	local anchor = Module._getAnchor(userId)
	if not anchor then
		return
	end

	--[[ Posting ]]

	Module._post(userId, anchor, Module._buildThought(image), _settings.ICON_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% On Message

--[[
	Shows a player's chat message (its text as filtered for this player) in a bubble over their snail, when this screen
	shows one: in a match, or on the lobby's stage.
]]
function Module._onMessage(message: TextChatMessage)
	--[[ Checks ]]

	-- Check if a player sent it, not the system
	if not message.TextSource or message.Status ~= Enum.TextChatMessageStatus.Success or message.Text == "" then
		return
	end

	--[[ Data ]]

	local userId: number = message.TextSource.UserId

	--- @type ChatBubbles_Anchor?
	local anchor = Module._getAnchor(userId)
	if not anchor then
		return
	end

	--[[ Posting ]]

	-- Measured first: it waits for the font, and the speaker's last bubble may go meanwhile
	local bubble: Frame = Module._buildBubble(message.Text)
	Module._post(userId, anchor, bubble, Module._getLifetime(message.Text))
end

--%%%%%%%%%%%%%%%%%%%% Post

--[[
	Puts a finished bubble at the bottom of a speaker's stack over their anchor (the newest with the tail), pops it in
	and takes it away after its lifetime.
]]
--- @param anchor ChatBubbles_Anchor
function Module._post(userId: number, anchor, bubble: Frame, lifetime: number)
	--[[ Speaker ]]

	local speaker = speakers[userId] or Module._addSpeaker(userId) --- @type ChatBubbles_Speaker
	speaker.Billboard.Adornee = anchor.Part
	speaker.Billboard.StudsOffset = Vector3.yAxis * anchor.Offset
	Module._watchTag(speaker, anchor.Tag)

	--[[ Bubbles ]]

	local previous: Frame? = speaker.Bubbles[#speaker.Bubbles]
	speaker.Count += 1
	bubble.LayoutOrder = speaker.Count
	bubble.Parent = speaker.Billboard:FindFirstChild("U_Bubbles")
	table.insert(speaker.Bubbles, bubble)

	-- Only the newest has the tail (a thought's trail), and the oldest goes past MAX_BUBBLES
	if previous and previous.Name == "Thought" then
		Module._setTrail(previous, false)
	elseif previous then
		Module._setTail(previous, false)
	end
	if #speaker.Bubbles > _settings.MAX_BUBBLES then
		Module._removeBubble(userId, speaker.Bubbles[1])
	end

	--[[ Tweening ]]

	local pop: UIScale = bubble:FindFirstChild("S_Pop")
	pop.Scale = _settings.POP_FROM
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(pop, _settings.POP_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()

	--[[ Fading ]]

	task.delay(lifetime, Module._removeBubble, userId, bubble)
end

--%%%%%%%%%%%%%%%%%%%% Add Speaker

--[[
	Puts a billboard for a speaker's bubbles in the world, sized with the screen, its bottom edge on the point its
	anchor sets.
]]
--- @return ChatBubbles_Speaker
function Module._addSpeaker(userId: number)
	--[[ Building ]]

	local billboard: BillboardGui = template:Clone()
	billboard.Name = `ChatBubble_{userId}`
	billboard.AlwaysOnTop = true
	billboard.SizeOffset = Vector2.new(0, 0.5)
	I.ScreenScale.AddBillboard(billboard)
	billboard.Parent = worldFolder

	--[[ Saving ]]

	--- @type ChatBubbles_Speaker
	local speaker = { Billboard = billboard, Bubbles = {}, Count = 0, Tag = nil, TagConnection = nil }
	speakers[userId] = speaker

	--[[ Returning ]]

	return speaker
end

--%%%%%%%%%%%%%%%%%%%% Watch Tag

--[[
	Keeps a speaker's bubbles over their snail's tag, its name and health bar: as tall as the tag's stack, which grows
	with the turn marker and the level, and a gap. Bubbles over a snail with no tag sit on their anchor.
]]
--- @param speaker ChatBubbles_Speaker
function Module._watchTag(speaker, tag: BillboardGui?)
	--[[ Checks ]]

	-- Skip when the bubbles already watch this tag
	if speaker.Tag == tag then
		return
	end

	--[[ Clearing ]]

	local clearance: UIPadding = speaker.Billboard:FindFirstChild("S_Clearance", true)
	if speaker.TagConnection then
		speaker.TagConnection:Disconnect()
		speaker.TagConnection = nil
	end
	speaker.Tag = tag
	clearance.PaddingBottom = UDim.new(0, 0)

	--[[ Checks ]]

	-- Check if the snail has a tag to stand over
	if not tag then
		return
	end

	--[[ Elements ]]

	local stack: Frame = tag:FindFirstChild("S_Stack", true)
	local scale: UIScale = tag:FindFirstChild("S_ScreenScale", true)

	--%%%%%%%%%%%%%%%%%%%% Fit

	--[[
		Lifts the bubbles over the tag's stack, in the billboards' design px; while the tag hides (its snail moving or
		aiming) they keep their height.
	]]
	local function fit()
		--[[ Checks ]]

		-- Skip a hidden tag, whose stack reads no height
		if stack.AbsoluteSize.Y <= 0 or scale.Scale <= 0 then
			return
		end

		--[[ Applying ]]

		clearance.PaddingBottom = UDim.new(0, stack.AbsoluteSize.Y / scale.Scale + _settings.TAG_GAP)
	end

	--[[ Connections ]]

	speaker.TagConnection = stack:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
end

--%%%%%%%%%%%%%%%%%%%% Build Bubble

--[[
	Makes a bubble for a message: its body sized to the text, measured at the text's design size and wrapped at
	TEXT_MAX_WIDTH, with the tail.
]]
--- @return Frame
function Module._buildBubble(text: string)
	--[[ Cloning ]]

	local bubble: Frame = template:FindFirstChild("PREFAB | Bubble", true):Clone()

	--[[ Elements ]]

	local body: Frame = bubble:FindFirstChild("S_Body")
	local label: TextLabel = body:FindFirstChild("S_Text")
	local padding: UIPadding = label:FindFirstChildOfClass("UIPadding")

	--[[ Local Variables ]]

	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = text
	params.Font = label.FontFace
	params.Size = label.TextSize
	params.Width = _settings.TEXT_MAX_WIDTH
	params.RichText = true

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.TextService.GetTextBoundsAsync, I.S.TextService, params)

	-- A failed measure (the font not loading) gives the widest bubble, one line per TextSize
	local bounds: Vector2 = if success then result else Vector2.new(_settings.TEXT_MAX_WIDTH, label.TextSize)
	local width: number = math.ceil(bounds.X * _settings.TEXT_ROOM) + padding.PaddingLeft.Offset + padding.PaddingRight.Offset
	local height: number = math.ceil(bounds.Y * _settings.TEXT_ROOM) + padding.PaddingTop.Offset + padding.PaddingBottom.Offset

	--[[ Applying ]]

	bubble.Name = "Bubble"
	bubble.Visible = true
	label.Text = text
	body.Size = UDim2.fromOffset(width, height)
	Module._setTail(bubble, true)

	--[[ Returning ]]

	return bubble
end

--%%%%%%%%%%%%%%%%%%%% Build Icon Bubble

--[[
	**CLIENT** |
	Makes a bubble holding a picture instead of text (an emote's icon), ICON_SIZE big, with its tail under it, or on
	its left to point at a name beside it (the lobby's party cards).
]]
--- @return Frame
function Module.BuildIconBubble(image: string, tailLeft: boolean?)
	--[[ Cloning ]]

	local bubble: Frame = template:FindFirstChild("PREFAB | Bubble", true):Clone()

	--[[ Elements ]]

	local body: Frame = bubble:FindFirstChild("S_Body")
	local icon: ImageLabel = body:FindFirstChild("S_Icon")
	local tail: Frame = bubble:FindFirstChild("S_Tail")
	local joint: Frame = bubble:FindFirstChild("S_Joint")

	--[[ Applying ]]

	bubble.Name = "Bubble"
	bubble.Visible = true
	body:FindFirstChild("S_Text").Visible = false
	icon.Image = image
	icon.Visible = true
	body.Size = UDim2.fromOffset(_settings.ICON_SIZE.X, _settings.ICON_SIZE.Y)
	Module._setTail(bubble, true)

	--[[ Left Tail ]]

	-- The tail's room moves from under the body to its left, the joint turned to cover the body's left outline
	if tailLeft then
		local outline: number = body:FindFirstChildOfClass("UIStroke").Thickness
		body.AnchorPoint = Vector2.new(1, 0.5)
		body.Position = UDim2.new(1, -outline, 0.5, 0)
		tail.Position = UDim2.new(0, tailRoom, 0.5, 0)
		joint.AnchorPoint = Vector2.new(0, 0.5)
		joint.Position = UDim2.new(0, tailRoom - outline, 0.5, 0)
		joint.Size = UDim2.fromOffset(joint.Size.Y.Offset, joint.Size.X.Offset)
		bubble.Size = UDim2.fromOffset(body.Size.X.Offset + outline + tailRoom, body.Size.Y.Offset + outline * 2)
	end

	--[[ Returning ]]

	return bubble
end

--%%%%%%%%%%%%%%%%%%%% Build Thought

--[[
	Makes a thought cloud holding a picture (an emote's icon), with its trail of puffs down to the snail.
]]
--- @return Frame
function Module._buildThought(image: string)
	--[[ Cloning ]]

	local thought: Frame = template:FindFirstChild("PREFAB | Thought", true):Clone()

	--[[ Applying ]]

	thought.Name = "Thought"
	thought.Visible = true
	thought:FindFirstChild("S_Icon", true).Image = image
	Module._setTrail(thought, true)

	--[[ Returning ]]

	return thought
end

--%%%%%%%%%%%%%%%%%%%% Set Trail

--[[
	Shows or hides a thought cloud's trail of puffs, and gives the cloud the trail's room under it or none.
]]
function Module._setTrail(thought: Frame, shown: boolean)
	--[[ Applying ]]

	thought:FindFirstChild("S_Trail").Visible = shown
	thought.Size = UDim2.fromOffset(thought.Size.X.Offset, if shown then thoughtHeight else thought:FindFirstChild("Cloud").Size.Y.Offset)
end

--%%%%%%%%%%%%%%%%%%%% Set Tail

--[[
	Shows or hides a bubble's tail, and gives the bubble the tail's room under its body or just its outline's.
]]
function Module._setTail(bubble: Frame, shown: boolean)
	--[[ Elements ]]

	local body: Frame = bubble:FindFirstChild("S_Body")

	--[[ Local Variables ]]

	local outline: number = body:FindFirstChildOfClass("UIStroke").Thickness
	local below: number = if shown then tailRoom else outline

	--[[ Applying ]]

	bubble:FindFirstChild("S_Tail").Visible = shown
	bubble:FindFirstChild("S_Joint").Visible = shown
	body.Position = UDim2.new(0.5, 0, 1, -below)
	bubble.Size = UDim2.fromOffset(body.Size.X.Offset + outline * 2, body.Size.Y.Offset + outline + below)
end

--%%%%%%%%%%%%%%%%%%%% Remove Bubble

--[[
	Fades a speaker's bubble out and takes it away, with their billboard when it was their last.
]]
function Module._removeBubble(userId: number, bubble: Frame)
	--[[ Data ]]

	local speaker = speakers[userId] --- @type ChatBubbles_Speaker?
	local index: number? = speaker and table.find(speaker.Bubbles, bubble)

	--[[ Checks ]]

	-- Check if the bubble still shows (a newer message may have taken its place)
	if not speaker or not index then
		return
	end

	--[[ Saving ]]

	table.remove(speaker.Bubbles, index)
	local last: boolean = #speaker.Bubbles == 0
	if last then
		speakers[userId] = nil
		Module._watchTag(speaker, nil)
	end

	--[[ Tweening ]]

	-- Every drawn part of the bubble or cloud fades: fills, outlines, text and the icon
	local Fade_Tween: Tween
	for _index: number, part: Instance in ipairs(bubble:GetDescendants()) do
		local property: string? = if part:IsA("UIStroke")
			then "Transparency"
			elseif part:IsA("TextLabel") then "TextTransparency"
			elseif part:IsA("ImageLabel") then "ImageTransparency"
			elseif part:IsA("Frame") and part.BackgroundTransparency < 1 then "BackgroundTransparency"
			else nil
		if property then
			local Fade_TweenGoal = { [property] = 1 }
			Fade_Tween = I.S.TweenService:Create(part, _settings.FADE_TWEENINFO, Fade_TweenGoal)
			Fade_Tween:Play()
		end
	end

	--[[ Cleaning ]]

	Fade_Tween.Completed:Once(function()
		if last then
			speaker.Billboard:Destroy()
		else
			bubble:Destroy()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Anchor

--[[
	Returns where a speaker's bubbles stand on this screen: over their snail and its tag while this player is in a
	match, over their snail on the lobby's stage otherwise; nil when this screen shows no snail of theirs.
]]
--- @return ChatBubbles_Anchor?
function Module._getAnchor(userId: number)
	--[[ Match ]]

	if I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		local model: Model? = I.Snails.Get(`P_{userId}`)

		-- Check if the speaker's snail is in play
		if not model or model:GetAttribute("Ghost") then
			return nil
		end

		local root: BasePart = model:FindFirstChild("Root")
		return { Part = root, Offset = I.Settings["Snails"].TAG_OFFSET, Tag = root:FindFirstChild("SnailTag") }
	end

	--[[ Checks ]]

	-- Check if this map has the lobby's stage (the match map leaves Lobby out)
	if not I.Lobby then
		return nil
	end

	--[[ Data ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(userId)
	local model: Model? = player and I.Lobby.GetStageSnail(player)
	if not model then
		return nil
	end

	--[[ Local Variables ]]

	-- The top of its Body (eyestalks included) over its RootPart, where the bubbles' bottom edge goes; the model's box would reach the shell's rest place, high above its back
	local body: BasePart = model:FindFirstChild("Body", true)
	local top: number = body.Position.Y + body.Size.Y / 2 - model.PrimaryPart.Position.Y

	--[[ Returning ]]

	return { Part = model.PrimaryPart, Offset = top + _settings.STAGE_GAP, Tag = nil }
end

--%%%%%%%%%%%%%%%%%%%% Get Lifetime

--[[
	Returns how long a message's bubble stays: longer for a longer message.
]]
--- @return number
function Module._getLifetime(text: string)
	return math.min(_settings.BUBBLE_SECONDS + (utf8.len(text) or #text) * _settings.BUBBLE_SECONDS_PER_LETTER, _settings.BUBBLE_MAX_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
