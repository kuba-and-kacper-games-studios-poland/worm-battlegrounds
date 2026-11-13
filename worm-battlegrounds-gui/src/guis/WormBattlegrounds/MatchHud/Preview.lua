--[[
	Created By: 	Nari
]]

local _localName: string = "MatchHudPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Knockouts for the kill feed
--- @type { string }
local FEED = {
	"Bax knocked out Ninja with the Black hole grenade",
	"Ninja knocked out Pip with the Shotgun",
	"Pip fell into the water",
}

-- The loadout's items in order (the Bazooka first): name and icon, as the Arsenal rows have them
--- @type { { string } }
local SLOT_ITEMS = {
	{ "Bazooka", "rbxassetid://89888640314244" },
	{ "Grenade", "rbxassetid://88613468948489" },
	{ "Shotgun", "rbxassetid://104705832389891" },
	{ "Homing missile", "rbxassetid://107350591430267" },
	{ "Dynamite", "rbxassetid://99998769993186" },
	{ "Jetpack", "rbxassetid://99911728604760" },
	{ "Uzi", "rbxassetid://79744307043186" },
}

-- The snails in the match: name and team colour, two teams of two, then two more teams
--- @type { { any } }
local SNAILS = {
	{ "Nari", Color3.fromRGB(64, 156, 255) },
	{ "Bax", Color3.fromRGB(64, 156, 255) },
	{ "Ninja", Color3.fromRGB(255, 84, 84) },
	{ "Pip", Color3.fromRGB(255, 84, 84) },
	{ "Moss", Color3.fromRGB(96, 214, 96) },
	{ "Shelly", Color3.fromRGB(96, 214, 96) },
	{ "Gus", Color3.fromRGB(255, 206, 64) },
	{ "Slimy", Color3.fromRGB(255, 206, 64) },
}

-- Team names in order, as the MatchHud module writes them
--- @type { string }
local TEAM_NAMES = { "Your team", "Red team", "Green team", "Yellow team" }

-- A player's share of a team panel's width, as MatchHud's TEAM_PLAYER_WIDTH
local TEAM_PLAYER_WIDTH: number = 0.235

--[[ Screen ]]

-- The screen size the guis are laid out for, the Mobile boost and the PC floor, as ScreenScale's Settings
local DESIGN_HEIGHT: number = 1080
local DESIGN_WIDTH: number = 1920
local SMALL_SCREEN: number = 500
local MOBILE_BOOST: number = 1.3
local MIN_SCALE: number = 0.6

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

--- @class UmeGui_Guis_WormBattlegrounds_MatchHud_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{
			Control = "Segmented",
			Id = "S_Phase",
			Label = "Phase",
			Options = { "Waiting", "Drop", "Turn", "Out" },
			Value = "Turn",
		},
		{ Control = "Toggle", Id = "S_MyTurn", Label = "My turn", Value = true },
		{ Control = "Toggle", Id = "S_Aiming", Label = "Aiming", Value = true },
		{ Control = "Slider", Id = "S_Power", Label = "Power", Value = 0.75, Min = 0, Max = 1, Step = 0.05 },
		{ Control = "Slider", Id = "S_Slots", Label = "Loadout items", Value = 5, Min = 1, Max = 7, Step = 1 },
		{ Control = "Slider", Id = "S_Teams", Label = "Teams of two", Value = 4, Min = 2, Max = 4, Step = 1 },
		{ Control = "Slider", Id = "S_Feed", Label = "Kill feed lines", Value = 2, Min = 0, Max = 3, Step = 1 },
		{ Control = "Toggle", Id = "S_Wheel", Label = "Emote wheel open", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the blocks of the picked phase and fills the screen as MatchHud does: whose turn, the turn list, the teams,
	the loadout bar (its second item cooling down, empty slots as "+"), stamina, the power slider, FIRE on Mobile, the
	kill feed and the emote wheel.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local view = preview.View --- @type UmeGui_View
	local phase: string = preview.Values.S_Phase
	local turn: boolean = phase == "Turn"
	local myTurn: boolean = turn and preview.Values.S_MyTurn
	local aiming: boolean = myTurn and preview.Values.S_Aiming

	--[[ Phases ]]

	view:Get("U_Waiting").Instance.Visible = phase == "Waiting"
	view:Get("U_Drop").Instance.Visible = phase == "Drop"
	view:Get("U_KnockedOut").Instance.Visible = phase == "Out"
	view:Get("U_Turn").Instance.Visible = turn
	view:Get("U_TurnList").Instance.Visible = turn
	view:Get("U_TeamsLeft").Instance.Visible = phase ~= "Waiting"
	view:Get("U_TeamsRight").Instance.Visible = phase ~= "Waiting"
	view:Get("U_Stamina").Instance.Visible = myTurn
	view:Get("U_Power").Instance.Visible = aiming
	view:Get("U_Fire").Instance.Visible = aiming and preview.Device == "Mobile"
	view:Get("U_LoadoutBar").Instance.Visible = phase ~= "Waiting" and phase ~= "Out"
	view:Get("U_EmoteButton").Instance.Visible = view:Get("U_LoadoutBar").Instance.Visible
	view:Get("U_EmoteWheel").Instance.Visible = preview.Values.S_Wheel

	--[[ Turn ]]

	-- On another snail's turn the banner names it in its team colour, with the player's wait under it
	view:Get("U_Turn", "S_Banner").Instance.Text = if preview.Values.S_MyTurn then "Your turn!" else `{SNAILS[3][1]}'s turn`
	view:Get("U_Turn", "S_Banner").Instance.TextColor3 = if preview.Values.S_MyTurn then Color3.new(1, 1, 1) else SNAILS[3][2]
	view:Get("U_Turn", "S_Wait").Instance.Visible = not preview.Values.S_MyTurn
	view:Get("U_Turn", "S_Timer").Instance.Text = "0:30"
	view:Get("U_Turn", "S_Wind").Instance.Text = "+3"

	--[[ Bars ]]

	view:Get("U_Stamina", "S_Text").Instance.Text = "Stamina 70%"
	Module._cutBar(view:Get("U_Stamina", "S_Bar").Instance, 0.7)
	local bar: ImageLabel = view:Get("U_Power", "S_Bar").Instance
	local handle: ImageButton = view:Get("U_Power", "S_Handle").Instance
	Module._cutBar(bar, preview.Values.S_Power)
	handle.Position = UDim2.fromScale(bar.Position.X.Scale + bar.Size.X.Scale * preview.Values.S_Power, handle.Position.Y.Scale)
	view:Get("U_Power", "S_Amount").Instance.Text = `{math.round(preview.Values.S_Power * 100)}%`
	view:Get("U_Power", "S_Info").Instance.Text = "45°"

	--[[ Turn List ]]

	local entries = preview.Fill("PREFAB | TurnEntry", 6) --- @type { UmeGui_Subview }

	--- @param entry UmeGui_Subview
	for index: number, entry in ipairs(entries) do
		local root: Frame = entry.Root.Instance
		local background: Frame = root:FindFirstChild("Background")
		local current: boolean = index == 1
		local snail = SNAILS[(index + 1) % #SNAILS + 1] --- @type { any }
		background:FindFirstChild("Main").Image = root:GetAttribute(if current then "Look_CurrentMain" else "Look_Main")
		background:FindFirstChild("Main").ImageColor3 = root:GetAttribute(if current then "Look_CurrentMainColor" else "Look_MainColor")
		background:FindFirstChild("Stroke").ImageColor3 = if current then root:GetAttribute("Look_CurrentStrokeColor") else snail[2]
		entry:Get("S_Mask").Instance.Visible = current
		entry:Get("S_Name").Instance.Text = snail[1]
	end

	--[[ Teams ]]

	Module._fillTeams(preview, view)

	--[[ Loadout Bar ]]

	local slots = preview.Fill("PREFAB | BarSlot", #SLOT_ITEMS) --- @type { UmeGui_Subview }

	--- @param slot UmeGui_Subview
	for index: number, slot in ipairs(slots) do
		local root: ImageButton = slot.Root.Instance
		local stroke: ImageLabel = root:FindFirstChild("Background"):FindFirstChild("Stroke")
		local item = SLOT_ITEMS[index] --- @type { string }
		local filled: boolean = index <= preview.Values.S_Slots
		slot:Get("S_Plus").Instance.Visible = not filled
		slot:Get("S_Icon").Instance.Visible = filled
		slot:Get("S_Key").Instance.Visible = filled and preview.Device == "Desktop"
		slot:Get("S_Uses").Instance.Visible = filled
		slot:Get("S_Name").Instance.Visible = filled
		slot:Get("S_Icon").Instance.Image = item[2]
		slot:Get("S_Icon").Instance.ImageColor3 = if index == 2 then root:GetAttribute("Look_CooldownIconColor") else Color3.new(1, 1, 1)
		slot:Get("S_Turns").Instance.Visible = filled and index == 2
		slot:Get("S_Key").Instance.Text = tostring(index)
		slot:Get("S_Name").Instance.Text = item[1]
		slot:Get("S_Uses").Instance.Text = if index == 1 then "" else "x2"
		stroke.ImageColor3 = root:GetAttribute(if not filled then "Look_EmptyStrokeColor" elseif index == 1 then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end

	--[[ Kill Feed ]]

	local lines = preview.Fill("PREFAB | FeedLine", preview.Values.S_Feed) --- @type { UmeGui_Subview }

	--- @param line UmeGui_Subview
	for index: number, line in ipairs(lines) do
		line.Root.SetText(FEED[index])
	end

	--[[ Emote Wheel ]]

	Module._placeWheel(preview.Fill("PREFAB | WheelEmote", 9))

	--[[ Screen ]]

	Module._applyScreenScale(preview)
end

--%%%%%%%%%%%%%%%%%%%% Fill Teams

--[[
	Fills the team panels as MatchHud does: the player's team first on the left, the others in turn on the right and
	the left, two avatars each with the side's own pictures, outlined in the team's colour.
]]
--- @param preview UmeGui_Preview
--- @param view UmeGui_View
function Module._fillTeams(preview, view)
	--[[ Building ]]

	local teams = preview.Fill("PREFAB | Team", preview.Values.S_Teams) --- @type { UmeGui_Subview }

	--- @param team UmeGui_Subview
	for index: number, team in ipairs(teams) do
		local root: Frame = team.Root.Instance
		local side: string = if index % 2 == 1 then "Left" else "Right"
		local list: Frame = team:Get("S_Players").Instance
		local playerPrefab: Frame = list:FindFirstChild("PREFAB | TeamPlayer")
		local nameLabel: TextLabel = team:Get("S_Name").Instance
		nameLabel.Text = TEAM_NAMES[index]
		nameLabel.TextColor3 = SNAILS[index * 2][2]
		nameLabel.TextXAlignment = if side == "Left" then Enum.TextXAlignment.Left else Enum.TextXAlignment.Right
		root.Size = UDim2.fromScale(2 * TEAM_PLAYER_WIDTH, root.Size.Y.Scale)
		root.LayoutOrder = index
		root.Parent = view:Get(`U_Teams{side}`).Instance

		-- The team's players, cloned from the nested prefab
		for member: number = 1, 2 do
			local slot: Frame = playerPrefab:Clone()
			local background: Frame = slot:FindFirstChild("Background")
			for _partIndex: number, part: string in ipairs({ "Main", "Stroke2", "Stroke" }) do
				background:FindFirstChild(part).Image = slot:GetAttribute(`Look_{side}{part}`)
			end
			background:FindFirstChild("Stroke").ImageColor3 = SNAILS[index * 2][2]
			slot.Name = "TeamPlayer"
			slot.LayoutOrder = member
			slot.Visible = true
			slot.Parent = list
		end
		playerPrefab:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%% Cut Bar

--[[
	Cuts a bar's picture at a share with its UIGradient, as MatchHud does, so the picture never squashes.
]]
function Module._cutBar(bar: ImageLabel, share: number)
	--[[ Local Variables ]]

	local edge: number = math.clamp(share, 0.001, 0.998)

	--[[ Applying ]]

	bar:FindFirstChildOfClass("UIGradient").Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(edge, 0),
		NumberSequenceKeypoint.new(edge + 0.001, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
end

--%%%%%%%%%%%%%%%%%%%% Place Wheel

--[[
	Places the emotes on a circle around the wheel's middle, the first at the top, as the Cosmetics module does.
]]
--- @param emotes { UmeGui_Subview }
function Module._placeWheel(emotes)
	--[[ Placing ]]

	--- @param emote UmeGui_Subview
	for index: number, emote in ipairs(emotes) do
		local angle: number = (index - 1) / #emotes * math.pi * 2
		emote.Root.Instance.Position = UDim2.fromScale(0.5 + math.sin(angle) * 0.4, 0.5 - math.cos(angle) * 0.4)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Screen Scale

--[[
	Scales the kept blocks (kill feed, wheel, phase panels) to the previewed screen as the game's ScreenScale does: its
	height over the design height (or its width over the design width on a narrower screen), bigger on short Mobile
	screens and never under the floor on others, times each block's device scale. The design's own frames scale by
	their screen fractions.
]]
--- @param preview UmeGui_Preview
function Module._applyScreenScale(preview)
	--[[ Local Variables ]]

	local height: number = Workspace.CurrentCamera.ViewportSize.Y
	local width: number = Workspace.CurrentCamera.ViewportSize.X

	-- A screen narrower than the layout scales by its width, so side-by-side panels still fit
	local scale: number = math.min(height / DESIGN_HEIGHT, width / DESIGN_WIDTH)

	-- Boost short touch screens so the buttons stay big enough to tap; anything else never shrinks below the floor
	if preview.Device == "Mobile" and height < SMALL_SCREEN then
		scale *= MOBILE_BOOST
	elseif preview.Device ~= "Mobile" then
		scale = math.max(scale, MIN_SCALE)
	end

	--[[ Applying ]]

	for _index: number, descendant: Instance in ipairs(preview.View.Root:GetDescendants()) do
		if descendant:IsA("UIScale") and descendant.Name == "S_ScreenScale" then
			-- Times the block's scale for the previewed device (its Utils_PlatformScale tag), as ScreenScale does
			local deviceScale: number = descendant.Parent:GetAttribute(`Utils_{preview.Device}Scale`) or 0
			descendant.Scale = scale * (if deviceScale == 0 then 1 else deviceScale)
		end
	end
end

return Module
