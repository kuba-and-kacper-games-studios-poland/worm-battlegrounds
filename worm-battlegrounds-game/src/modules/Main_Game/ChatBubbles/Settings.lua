--- @class ChatBubbles_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Template

	-- The bubbles' billboard in Assets.ChatBubbles: the BillboardGui of PREFAB | ChatBubble (the ChatBubble gui)
	TEMPLATE = "U_ChatBubble",

	--%%%%%%%%%%%%%%%%%%%% Bubbles

	-- A bubble's text wraps past this width, in design px, measured at the text's TextSize
	TEXT_MAX_WIDTH = 170,

	-- Scaled text draws about 5% bigger than TextService measures it, so the text gets this much more room
	TEXT_ROOM = 1.06,

	-- The most bubbles over one snail: a newer message takes the oldest one's place
	MAX_BUBBLES = 3,

	-- A bubble stays BUBBLE_SECONDS, plus BUBBLE_SECONDS_PER_LETTER for each letter, BUBBLE_MAX_SECONDS at most
	BUBBLE_SECONDS = 4,
	BUBBLE_SECONDS_PER_LETTER = 0.06,
	BUBBLE_MAX_SECONDS = 10,

	-- A picture's bubble (an emote's icon, I.ChatBubbles.ShowIcon): its body's size in design px, and how long it stays
	ICON_SIZE = Vector2.new(64, 58),
	ICON_SECONDS = 3.5,

	--%%%%%%%%%%%%%%%%%%%% Motion

	-- A new bubble pops in from POP_FROM times its size; one whose time is up fades out
	POP_FROM = 0.6,
	POP_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	FADE_TWEENINFO = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

	--%%%%%%%%%%%%%%%%%%%% Placement

	-- In a match the bubbles stand this many design px over the snail's tag (its name and health bar)
	TAG_GAP = 6,

	-- On the lobby's stage they stand this many studs over the top of the snail
	STAGE_GAP = 0.6,
}

return _settings
