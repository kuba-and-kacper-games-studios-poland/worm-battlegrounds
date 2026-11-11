--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "PlayerBadges"

--- @type PlayerBadges_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each name label showing badges: its own size and position, its badges, and whose they are
local labels = {} --- @type { [TextLabel]: PlayerBadges_Label }

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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.PlayerBadges = {

		--[[ Control ]]

		Show = Module.Show,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	**CLIENT** |
	Shows a player's badges right after their name, sized to its text, in the S_Badges frame beside the name label,
	and keeps them in step with the player's badges until the label goes. A bot (no user id) or a player who left has
	none.
]]
function Module.Show(label: TextLabel, userId: number?)
	--[[ Local Variables ]]

	local entry = labels[label] --- @type PlayerBadges_Label?

	--[[ Watching ]]

	-- The first time, remember the name's own room and text size, and follow its text and size
	if not entry then
		local constraint: UITextSizeConstraint = label:FindFirstChildOfClass("UITextSizeConstraint")
		entry = {
			UserId = 0,
			PlayerConnection = nil,
			Size = label.Size,
			Position = label.Position,
			Constraint = constraint,
			MaxTextSize = constraint.MaxTextSize,
			Width = nil,
			Frame = label.Parent:FindFirstChild("S_Badges"),
			Badges = {},
		}
		labels[label] = entry
		label:GetPropertyChangedSignal("TextBounds"):Connect(function()
			Module._place(label)
		end)
		label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Module._place(label)
		end)
		label:GetPropertyChangedSignal("Text"):Connect(function()
			task.spawn(Module._measure, label)
		end)
		label.Destroying:Once(function()
			Module._forget(label)
		end)
		task.spawn(Module._measure, label)
	end

	-- Follow the player's badges
	if entry.UserId ~= (userId or 0) then
		local player: Player? = I.S.Players:GetPlayerByUserId(userId or 0)
		if entry.PlayerConnection then
			entry.PlayerConnection:Disconnect()
		end
		entry.UserId = userId or 0
		entry.PlayerConnection = player and player:GetAttributeChangedSignal(_settings.ATTRIBUTE):Connect(function()
			Module._refresh(label)
		end)
	end

	--[[ Showing ]]

	Module._refresh(label)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Puts a badge after a name for each of its player's badge ids, in their order.
]]
function Module._refresh(label: TextLabel)
	--[[ Checks ]]

	-- Check if the name still shows (a list rebuilt on the same attribute change destroys its rows)
	if not label.Parent then
		return
	end

	--[[ Data ]]

	local entry = labels[label] --- @type PlayerBadges_Label
	local player: Player? = I.S.Players:GetPlayerByUserId(entry.UserId)
	local ids = string.split(player and player:GetAttribute(_settings.ATTRIBUTE) or "", ",") --- @type { string }

	--[[ Clearing ]]

	for _index: number, badge: ImageLabel in ipairs(entry.Badges) do
		badge:Destroy()
	end
	entry.Badges = {}

	--[[ Building ]]

	local prefab: ImageLabel = entry.Frame:FindFirstChild("PREFAB | Badge")
	for _index: number, id: string in ipairs(ids) do
		--- @type PlayerBadges_Badge?
		local badge = id ~= "" and Module._getBadge(id) or nil
		if not badge then
			continue
		end

		local icon: ImageLabel = prefab:Clone()
		icon.Name = "Badge"
		icon.Image = badge.Image or ""
		icon:FindFirstChild("S_Glyph").Text = badge.Glyph or ""
		icon.Visible = true
		icon.Parent = entry.Frame
		table.insert(entry.Badges, icon)
	end

	--[[ Placing ]]

	Module._place(label)
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Lays a name's badges out after its text, BADGE_SIZE of its height each: the name gives up their room and keeps
	its left edge (so a centred name centres with its badges), its text shrinking to fit on one line, and past
	MAX_SHARE of the name's width the badges shrink too.
]]
function Module._place(label: TextLabel)
	--[[ Checks ]]

	-- Check if the name still shows (a measure can finish after its row was destroyed)
	if not label.Parent or not labels[label] then
		return
	end

	--[[ Data ]]

	local entry = labels[label] --- @type PlayerBadges_Label

	--[[ Local Variables ]]

	local frame: Frame = entry.Frame
	local parent: GuiBase2d = label.Parent
	local count: number = #entry.Badges
	local parentSize: Vector2 = parent.AbsoluteSize
	local height: number = label.AbsoluteSize.Y

	--[[ Checks ]]

	-- Check if the name has badges, or give it back its own room
	if count == 0 then
		label.Size = entry.Size
		label.Position = entry.Position
		entry.Constraint.MaxTextSize = entry.MaxTextSize
		frame.Visible = false
		return
	end

	-- Check if the name is laid out
	if parentSize.X <= 0 or parentSize.Y <= 0 or height <= 0 then
		return
	end

	--[[ Sizing ]]

	local room: number = entry.Size.X.Scale * parentSize.X
	local size: number = height * _settings.BADGE_SIZE
	local gap: number = height * _settings.BADGE_GAP
	local reserve: number = count * (size + gap)

	-- Past MAX_SHARE of the name's width the badges shrink too
	if reserve > room * _settings.MAX_SHARE then
		local fit: number = room * _settings.MAX_SHARE / reserve
		size *= fit
		gap *= fit
		reserve *= fit
	end

	--[[ Name ]]

	local width: number = room - reserve
	local share: number = reserve / parentSize.X
	local origin: UDim2 = entry.Position
	label.Size = UDim2.new(entry.Size.X.Scale - share, entry.Size.X.Offset, entry.Size.Y.Scale, entry.Size.Y.Offset)
	label.Position = UDim2.new(origin.X.Scale - label.AnchorPoint.X * share, origin.X.Offset, origin.Y.Scale, origin.Y.Offset)

	-- Its text no bigger than fits on one line, so scaled text shrinks rather than breaking the name mid-word
	if entry.Width then
		local fits: number = math.floor(width / (entry.Width * _settings.TEXT_ROOM))
		entry.Constraint.MaxTextSize = math.clamp(fits, 1, entry.MaxTextSize)
	end

	--[[ Placing ]]

	-- Where the text ends in the narrowed name, by its alignment
	local textWidth: number = math.min(label.TextBounds.X, width)
	local textEnd: number = if label.TextXAlignment == Enum.TextXAlignment.Left then textWidth elseif label.TextXAlignment == Enum.TextXAlignment.Right then width else (width + textWidth) / 2

	local left: number = label.AbsolutePosition.X - parent.AbsolutePosition.X
	local middle: number = label.AbsolutePosition.Y - parent.AbsolutePosition.Y + height / 2
	local rowWidth: number = count * size + (count - 1) * gap
	frame.Position = UDim2.fromScale((left + textEnd + gap) / parentSize.X, middle / parentSize.Y)
	frame.Size = UDim2.fromScale(rowWidth / parentSize.X, size / parentSize.Y)
	frame.Visible = true

	--- @param badge ImageLabel
	for index: number, badge in ipairs(entry.Badges) do
		badge.Position = UDim2.fromScale((index - 1) * (size + gap) / rowWidth, 0)
		badge.Size = UDim2.fromScale(size / rowWidth, 1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Measure

--[[
	Measures how wide a name's text is per pixel of text size (a web font loads first), then lays its badges out again.
]]
function Module._measure(label: TextLabel)
	--[[ Local Variables ]]

	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = label.Text
	params.Font = label.FontFace
	params.Size = 100
	params.Width = 10000
	params.RichText = label.RichText

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.TextService.GetTextBoundsAsync, I.S.TextService, params)

	--[[ Checks ]]

	-- Check if it measured, and the label is still shown with the same text
	if not success or not labels[label] or label.Text ~= params.Text then
		return
	end

	--[[ Saving ]]

	labels[label].Width = result.X / params.Size

	--[[ Placing ]]

	Module._place(label)
end

--%%%%%%%%%%%%%%%%%%%% Forget

--[[
	Stops following a name label's player once the label goes.
]]
function Module._forget(label: TextLabel)
	--[[ Data ]]

	local entry = labels[label] --- @type PlayerBadges_Label

	--[[ Clearing ]]

	if entry.PlayerConnection then
		entry.PlayerConnection:Disconnect()
	end
	labels[label] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Badge

--[[
	Returns a badge's row in BADGES by its id, or nil (with a warning) for an id the game doesn't know.
]]
--- @return PlayerBadges_Badge?
function Module._getBadge(badgeId: string)
	--[[ Finding ]]

	--- @param badge PlayerBadges_Badge
	for _index: number, badge in ipairs(_settings.BADGES) do
		if badge.Id == badgeId then
			return badge
		end
	end

	--[[ Checks ]]

	-- Warn about a badge the game doesn't know
	warn(`[{_localName}::{script.Name}]: Badge ({badgeId}) is missing!`)
	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
