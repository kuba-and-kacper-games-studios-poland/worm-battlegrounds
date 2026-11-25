--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Payout = require(_scripts:FindFirstChild("Client"):FindFirstChild("Payout")) --- @type Progression_Client_Payout
local Unlock = require(_scripts:FindFirstChild("Client"):FindFirstChild("Unlock")) --- @type Progression_Client_Unlock

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: any }
local prefabs = {} --- @type { [string]: any }

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder

--[[ Replay ]]

-- Whether the replay is playing, and whether the player tapped to skip the rest of it
local replaying: boolean = false
local skipping: boolean = false

-- Whether a level was reached while skipping: its fanfare waits for the end, so many never sound at once
local skippedLevelUp: boolean = false

--[[ Bought Diamonds ]]

-- The diamonds bought packs gave that haven't played yet, and whether their payout is playing or waiting to
local bought: string = "0"
local buying: boolean = false

-- The sparks flying from each XP line into the bar, and the stars a level-up throws, made on the first replay
local sparks = nil --- @type UIEmitter_Instance?
local stars = nil --- @type UIEmitter_Instance?

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

	Module._getElements()
	Payout.Init()
	Unlock.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Progression = {

		--[[ Control ]]

		HoldPurchase = Module.HoldPurchase,
		PlayPurchase = Module.PlayPurchase,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.OnLoaded(I.Priority.Default, Module._connectReplicator)
	moduleGui:GetPropertyChangedSignal("Enabled"):Connect(Module._tryReplay)
	I.S.UserInputService.InputBegan:Connect(Module._onInput)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Finds the plate's and the replay's elements in the LevelPlate gui.
]]
function Module._getElements()
	--[[ General ]]

	moduleGui = I.UserInterface.UI["LevelPlate"]
	elems["Replay"] = moduleGui:FindFirstChild("U_Replay") --- @type Frame
	elems["Dim"] = elems["Replay"]:FindFirstChild("S_Dim") --- @type Frame
	elems["Flash"] = elems["Replay"]:FindFirstChild("S_Flash") --- @type Frame
	elems["Particles"] = elems["Replay"]:FindFirstChild("S_Particles") --- @type Frame

	--[[ Stage ]]

	elems["Plate"] = elems["Replay"]:FindFirstChild("U_Plate") --- @type Frame
	elems["Pop"] = elems["Plate"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["Rays"] = elems["Plate"]:FindFirstChild("S_Rays") --- @type ImageLabel
	elems["RaysBack"] = elems["Plate"]:FindFirstChild("S_RaysBack") --- @type ImageLabel
	elems["Glow"] = elems["Plate"]:FindFirstChild("S_Glow") --- @type ImageLabel
	elems["Badge"] = elems["Plate"]:FindFirstChild("S_Badge") --- @type Frame
	elems["BadgeScale"] = elems["Badge"]:FindFirstChild("S_BadgeScale") --- @type UIScale
	elems["TierGradient"] = elems["Badge"]:FindFirstChild("S_TierGradient", true) --- @type UIGradient
	elems["LevelNum"] = elems["Badge"]:FindFirstChild("S_LevelNum") --- @type TextLabel
	elems["LevelUpScale"] = elems["Plate"]:FindFirstChild("S_LevelUpScale", true) --- @type UIScale
	elems["Pips"] = elems["Plate"]:FindFirstChild("S_Pips") --- @type Frame
	elems["TierName"] = elems["Plate"]:FindFirstChild("S_TierName") --- @type TextLabel
	elems["TierNameGradient"] = elems["TierName"]:FindFirstChild("S_TierNameGradient") --- @type UIGradient
	elems["TierNameScale"] = elems["TierName"]:FindFirstChild("S_TierNameScale") --- @type UIScale
	elems["Xp"] = elems["Plate"]:FindFirstChild("S_Xp", true) --- @type TextLabel
	elems["Track"] = elems["Plate"]:FindFirstChild("S_Track") --- @type Frame
	elems["Fill"] = elems["Track"]:FindFirstChild("S_Fill") --- @type Frame
	elems["FillGradient"] = elems["Fill"]:FindFirstChild("S_FillGradient") --- @type UIGradient
	elems["Head"] = elems["Plate"]:FindFirstChild("S_Head", true) --- @type ImageLabel
	elems["Lines"] = elems["Plate"]:FindFirstChild("S_Lines") --- @type Frame

	--[[ Next Reward ]]

	elems["Next"] = elems["Plate"]:FindFirstChild("S_Next") --- @type Frame
	elems["NextScale"] = elems["Next"]:FindFirstChild("S_NextScale") --- @type UIScale
	elems["NextGlow"] = elems["Next"]:FindFirstChild("S_NextGlow") --- @type ImageLabel
	elems["NextIcon"] = elems["Next"]:FindFirstChild("S_NextIcon") --- @type ImageLabel
	elems["NextRound"] = elems["NextIcon"]:FindFirstChild("S_NextRound") --- @type UICorner
	elems["NextRing"] = elems["Next"]:FindFirstChild("S_NextRing") --- @type Frame
	elems["NextFoil"] = elems["Next"]:FindFirstChild("S_NextFoil") --- @type Frame
	elems["NextGold"] = elems["Next"]:FindFirstChild("S_NextGold") --- @type Frame
	elems["NextRingGradient"] = elems["NextRing"]:FindFirstChild("S_NextRingGradient", true) --- @type UIGradient
	elems["NextLevel"] = elems["Next"]:FindFirstChild("S_NextLevel") --- @type TextLabel
	elems["NextTag"] = elems["Next"]:FindFirstChild("S_NextTag", true) --- @type TextLabel
	elems["NextTagGradient"] = elems["Next"]:FindFirstChild("S_NextTagGradient", true) --- @type UIGradient

	--[[ At Rest ]]

	elems["Rest"] = moduleGui:FindFirstChild("U_Rest") --- @type Frame
	elems["RestTierGradient"] = elems["Rest"]:FindFirstChild("S_RestTierGradient", true) --- @type UIGradient
	elems["RestLevel"] = elems["Rest"]:FindFirstChild("S_RestLevel", true) --- @type TextLabel
	elems["RestFill"] = elems["Rest"]:FindFirstChild("S_RestFill", true) --- @type Frame
	elems["RestFillGradient"] = elems["RestFill"]:FindFirstChild("S_RestFillGradient") --- @type UIGradient

	--[[ Prefab ]]

	prefabs["XpLine"] = elems["Plate"]:FindFirstChild("PREFAB | XpLine") --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's level and any XP replay waiting in their Progression folder.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)

	--[[ Connections ]]

	moduleRep.AttributeChanged:Connect(function(attribute: string)
		if attribute == "Replay" then
			Module._tryReplay()
		elseif not replaying then
			Module._showCurrent()
		end
	end)

	--[[ Applying ]]

	Module._showCurrent()
	Module._tryReplay()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hold Purchase

--[[
	**CLIENT** |
	Holds the diamonds slot at what it showed before a bought pack (`before`, when the shop knows it), until the pack's
	payout plays once the shop closes.
]]
function Module.HoldPurchase(amount: string, before: string?)
	Payout.Hold(amount, before)
end

--%%%%%%%%%%%%%%%%%%%% Play Purchase

--[[
	**CLIENT** |
	Plays the diamonds bought packs gave once the shop has closed: the replay's payout with more diamonds for a bigger
	pack, the gift's pop and a fanfare as they land, in the gem blue vignette. Waits for a replay playing and for the
	lobby to show; packs bought meanwhile play together.
]]
function Module.PlayPurchase(amount: string)
	--[[ Checks ]]

	-- Check if there are diamonds to play
	if amount == "0" then
		return
	end

	--[[ Saving ]]

	bought = `{I.BN.new(bought) + I.BN.new(amount)}`

	--[[ Checks ]]

	-- Check if a payout is already on its way, which plays these too
	if buying then
		return
	end

	--[[ Saving ]]

	buying = true

	--[[ Playing ]]

	task.delay(_settings.PURCHASE_DELAY, function()
		while replaying or not moduleGui.Enabled do
			task.wait(0.2)
		end
		local total: string = bought
		bought = "0"
		local root: number = math.sqrt(I.Number.ToNumberOr(total, 0))
		local look = { --- @type Progression_PayoutLook
			Icons = math.clamp(math.ceil(root * _settings.PURCHASE_ICONS_PER_ROOT), _settings.PURCHASE_ICONS_MIN, _settings.PURCHASE_ICONS_MAX),
			PopSound = _settings.PURCHASE_POP_SOUND,
			LandSound = _settings.PURCHASE_LAND_SOUND,
		}
		Payout.SetVignette(true)
		local success: boolean
		local result: any | string?
		success, result = pcall(Payout.Play, total, look)
		if not success then
			warn(`[{_localName}::{script.Name}]: The bought diamonds' payout failed! - ({result})`)
		end
		Payout.Release()
		elems["Replay"].Visible = false
		Payout.SetVignette(false)
		buying = false

		-- Packs bought while it played, and a replay that waited, come next
		if bought ~= "0" then
			local queued: string = bought
			bought = "0"
			Module.PlayPurchase(queued)
		end
		Module._tryReplay()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Show Current

--[[
	Shows the player's level as it is now, on the stage and by the diamonds.
]]
function Module._showCurrent()
	--[[ Checks ]]

	-- Check if the level has arrived
	if not moduleRep or not moduleRep:GetAttribute("Level") then
		return
	end

	--[[ Local Variables ]]

	local level: number = moduleRep:GetAttribute("Level")
	local into: number = moduleRep:GetAttribute("XPIntoLevel") or 0
	local cost: number = moduleRep:GetAttribute("XPForLevel") or 0

	--[[ Applying ]]

	Module._showLevel(level, into, cost)
	Module._showRest(level, into, cost)
end

--%%%%%%%%%%%%%%%%%%%% Show Rest

--[[
	Writes the level under the diamonds, on the replay's bar: the crest and the fill in the tier's colours, the fill
	reaching the XP's share from where the crest ends (REST_FILL_START).
]]
function Module._showRest(level: number, into: number, cost: number)
	--[[ Local Variables ]]

	local share: number = if cost > 0 then math.clamp(into / cost, 0, 1) else 1

	--[[ Applying ]]

	I.G_Progression.ApplyFrame(elems["RestTierGradient"], level)
	I.G_Progression.ApplyFrame(elems["RestFillGradient"], level, true)
	elems["RestLevel"].Text = tostring(level)
	elems["RestFill"].Size = UDim2.fromScale(_settings.REST_FILL_START + share * (1 - _settings.REST_FILL_START), 1)
end

--%%%%%%%%%%%%%%%%%%%% Show Level

--[[
	Writes a level and the XP into it on the stage: the crest in its tier, the bar, and the next reward's card.
]]
function Module._showLevel(level: number, into: number, cost: number)
	--[[ Local Variables ]]

	local _nextText: string?
	local nextLevel: number?
	_nextText, nextLevel = I.G_Progression.GetNextUnlock(level)

	--[[ Applying ]]

	Module._showCrest(level)
	elems["Xp"].Text = if cost > 0 then `{math.floor(into)} / {cost} XP` else "Max level"
	elems["Fill"].Size = UDim2.fromScale(if cost > 0 then math.clamp(into / cost, 0, 1) else 1, 1)
	elems["Head"].Position = UDim2.fromScale(elems["Fill"].Size.X.Scale, 0.5)
	Module._showReward(nextLevel, false)
end

--%%%%%%%%%%%%%%%%%%%% Show Crest

--[[
	Dresses the crest in a level's prestige tier: the level, the rim's colours, the rays and glow in the tier's colour
	(richer each tier, REPLAY_TIER_LOOKS), the pips lit up to the tier and its name.
]]
function Module._showCrest(level: number)
	--[[ Local Variables ]]

	local tier = I.G_Progression.GetTier(level) --- @type Progression_Tier
	local tierIndex: number = table.find(_settings.FRAME_TIERS, tier) or 1
	local look = _settings.REPLAY_TIER_LOOKS[tierIndex] --- @type Progression_ReplayTierLook
	local color: Color3 = tier.Colors[2]

	--[[ Crest ]]

	I.G_Progression.ApplyFrame(elems["TierGradient"], level)
	I.G_Progression.ApplyFrame(elems["TierNameGradient"], level)
	I.G_Progression.ApplyFrame(elems["FillGradient"], level, true)
	elems["Head"].ImageColor3 = color
	elems["LevelNum"].Text = tostring(level)
	elems["TierName"].Text = tier.Name

	--[[ Light ]]

	elems["Rays"].ImageColor3 = color
	elems["Rays"].ImageTransparency = look.Rays
	elems["RaysBack"].ImageColor3 = color
	elems["RaysBack"].ImageTransparency = look.RaysBack
	elems["Glow"].ImageColor3 = color
	elems["Glow"].ImageTransparency = look.Glow

	--[[ Pips ]]

	for _index: number, pip: Instance in ipairs(elems["Pips"]:GetChildren()) do
		if pip:IsA("Frame") then
			local gem: Frame = pip:FindFirstChild("Gem")
			gem.BackgroundColor3 = if pip.LayoutOrder <= tierIndex then color else _settings.PIP_OFF_COLOR
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Reward

--[[
	Shows a level's reward on the card at the bar's end (a weapon look in its Shiny foil or Golden rim), tagged NEXT, or
	UNLOCKED once the bar reached it; hides the card
	when no level is left to reach.
]]
function Module._showReward(atLevel: number?, unlocked: boolean)
	--[[ Checks ]]

	-- Check if a reward is left (the bar takes the middle without its card)
	elems["Next"].Visible = atLevel ~= nil
	elems["Track"].Position = UDim2.fromScale(if atLevel then _settings.TRACK_X else 0.5, elems["Track"].Position.Y.Scale)
	if not atLevel then
		return
	end

	--[[ Local Variables ]]

	local reward = Module._getReward(atLevel) --- @type Progression_RewardLook

	--[[ Applying ]]

	elems["NextIcon"].Image = reward.Icon
	elems["NextRound"].CornerRadius = UDim.new(if reward.Frame then 1 else 0, 0)
	elems["NextRing"].Visible = reward.Frame
	elems["NextFoil"].Visible = reward.Variant == "Shiny"
	elems["NextGold"].Visible = reward.Variant == "Golden"
	if reward.Frame then
		I.G_Progression.ApplyFrame(elems["NextRingGradient"], atLevel)
	end
	elems["NextGlow"].ImageColor3 = reward.Color
	elems["NextLevel"].Text = `Lv {atLevel}`
	elems["NextTag"].Text = if unlocked then "Unlocked!" else "Next"
	elems["NextTagGradient"].Color = if unlocked then _settings.REWARD_TAG_UNLOCKED else _settings.REWARD_TAG_NEXT
end

--%%%%%%%%%%%%%%%%%%%% Try Replay

--[[
	Starts the XP replay when one is waiting and the lobby shows, once the teleport card has had time to slide off.
]]
function Module._tryReplay()
	--[[ Checks ]]

	-- Check if a replay waits and the lobby's screens show
	if replaying or buying or not moduleRep or (moduleRep:GetAttribute("Replay") or "") == "" or not moduleGui.Enabled then
		return
	end

	--[[ Playing ]]

	-- The diamonds slot holds the old count until the diamonds fly in
	replaying = true
	local replay = I.S.HttpService:JSONDecode(moduleRep:GetAttribute("Replay")) --- @type Progression_Replay
	Payout.Hold(replay.Diamonds or "0")
	task.delay(_settings.REPLAY_DELAY, function()
		local success: boolean
		local result: any | string?
		success, result = pcall(Module._playReplay)
		if not success then
			warn(`[{_localName}::{script.Name}]: The XP replay failed! - ({result})`)
		end
		Payout.Release()
		Module._endReplay()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Play Replay

--[[
	Plays what the last matches gave: the diamonds they paid fly into the diamonds slot (Payout), then the plate pops up in
	the middle over a dimmed lobby, each XP line pops in and
	fills the bar with ticks and sparks, and every level-up bursts, flips the level and shows what it opened.
]]
function Module._playReplay()
	--[[ Data ]]

	local replay = I.S.HttpService:JSONDecode(moduleRep:GetAttribute("Replay")) --- @type Progression_Replay

	--[[ Diamonds ]]

	Payout.Play(replay.Diamonds or "0")

	--[[ Checks ]]

	-- Check if there's XP to play after the diamonds
	if #replay.Lines == 0 then
		return
	end

	--[[ Local Variables ]]

	local level: number = replay.Before.Level
	local into: number = replay.Before.Into
	local cost: number = replay.Before.For
	skipping = false
	skippedLevelUp = false

	--[[ Opening ]]

	-- The replay takes the lobby: its panels and the stage's nameplates make way
	I.Lobby.SetTakeover(true)
	elems["Rest"].Visible = false
	Module._showLevel(level, into, cost)
	elems["LevelUpScale"].Scale = 0
	elems["NextScale"].Scale = 1
	elems["Replay"].Visible = true
	elems["Plate"].Visible = true
	Module._tween(elems["Dim"], _settings.PLATE_TWEENINFO, { BackgroundTransparency = 1 - _settings.REPLAY_DIM })
	Module._tween(elems["Pop"], _settings.PLATE_TWEENINFO, { Scale = _settings.REPLAY_SCALE })
	Module._wait(_settings.PLATE_TWEENINFO.Time)

	--[[ Lines ]]

	--- @param line Progression_XpLine
	for index: number, line in ipairs(replay.Lines) do
		local row: Frame = Module._addLine(line, index)
		Module._wait(_settings.REPLAY_LINE_GAP)
		Module._emitSparks(row)

		local left: number = line.Amount
		while left > 0 do
			-- One stretch of the bar: up to the end of this level, or what's left of the line
			local room: number = if cost > 0 then cost - into else left
			local gain: number = math.min(left, room)
			Module._fill(into, into + gain, cost, gain / line.Amount)
			into += gain
			left -= gain

			if cost > 0 and into >= cost then
				level += 1
				into = 0
				cost = Module._getCost(replay, level)
				Module._levelUp(level)
				Module._showLevel(level, into, cost)
			end
		end
	end

	--[[ Closing ]]

	-- One fanfare for the levels a skip passed, not one each in the same frame
	if skippedLevelUp then
		I.Sound.Play({ Name = "Level_Up", SoundGroup = "UI" })
	end
	Module._wait(_settings.REPLAY_END_HOLD)
end

--%%%%%%%%%%%%%%%%%%%% End Replay

--[[
	Closes the replay: the stage shrinks away, the lobby brightens and comes back, the tiles go, the stage takes the
	level as it is now, and the server forgets the replay.
]]
function Module._endReplay()
	--[[ Applying ]]

	Module._tween(elems["Dim"], _settings.PLATE_BACK_TWEENINFO, { BackgroundTransparency = 1 })
	Module._tween(elems["Pop"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	Module._tween(elems["LevelUpScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	task.wait(_settings.PLATE_BACK_TWEENINFO.Time)
	I.Lobby.SetTakeover(false)
	elems["Rest"].Visible = true

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Lines"]:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	elems["Replay"].Visible = false
	elems["Plate"].Visible = false
	elems["Head"].ImageTransparency = 1

	--[[ Publishing ]]

	I.Network.Fire("Progression_ReplaySeen")
	replaying = false
	skipping = false
	Module._showCurrent()
end

--%%%%%%%%%%%%%%%%%%%% Add Line

--[[
	Pops one XP tile in along the stage's bottom, its picture by what it was for, with its chime.
]]
--- @param line Progression_XpLine
--- @return Frame
function Module._addLine(line, index: number)
	--[[ Cloning ]]

	local row: Frame = prefabs["XpLine"]:Clone()
	row.Name = "XpLine"
	row.LayoutOrder = index

	--[[ Elements ]]

	local scale: UIScale = row:FindFirstChild("S_Scale")
	local icon: ImageLabel = row:FindFirstChild("S_Icon")
	local label: TextLabel = row:FindFirstChild("S_Label")
	local amount: TextLabel = row:FindFirstChild("S_Amount")

	--[[ Texts ]]

	-- A saved replay can be older than the pictures (no Key, or one since renamed)
	icon.Image = _settings.XP_ICONS[line.Key] or _settings.XP_ICONS.Played
	label.Text = line.Label
	amount.Text = `+{line.Amount} XP`

	--[[ Showing ]]

	scale.Scale = 0
	row.Visible = true
	row.Parent = elems["Lines"]
	Module._tween(scale, _settings.PLATE_TWEENINFO, { Scale = 1 })
	if not skipping then
		I.Sound.Play({ Name = "Xp_Line", SoundGroup = "UI" })
	end

	--[[ Returning ]]

	return row
end

--%%%%%%%%%%%%%%%%%%%% Fill

--[[
	Fills the bar from one amount of XP to another, its glow riding the end, ticking higher as it fills.
]]
function Module._fill(from: number, to: number, cost: number, share: number)
	--[[ Local Variables ]]

	local seconds: number = if skipping then 0 else math.max(0.15, _settings.REPLAY_FILL_SECONDS * share)
	local ticks: number = math.max(1, math.round(_settings.REPLAY_TICKS * share))
	local fillTo: number = if cost > 0 then to / cost else 1

	--[[ Filling ]]

	elems["Head"].ImageTransparency = 0.1
	local Fill_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Module._tween(elems["Fill"], Fill_TweenInfo, { Size = UDim2.fromScale(fillTo, 1) })
	Module._tween(elems["Head"], Fill_TweenInfo, { Position = UDim2.fromScale(fillTo, 0.5) })

	--[[ Ticking ]]

	for tick: number = 1, ticks do
		local through: number = from + (to - from) * tick / ticks
		local pitch: number = _settings.REPLAY_TICK_PITCH.Min + (_settings.REPLAY_TICK_PITCH.Max - _settings.REPLAY_TICK_PITCH.Min) * (if cost > 0 then through / cost else 1)
		elems["Xp"].Text = if cost > 0 then `{math.floor(through)} / {cost} XP` else "Max level"
		if not skipping then
			I.Sound.Play({ Name = "Xp_Tick", SoundGroup = "UI", PitchMin = pitch, PitchMax = pitch })
		end
		Module._wait(seconds / ticks)
	end
	elems["Head"].ImageTransparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Level Up

--[[
	Bursts a level-up on the stage: stars, the crest punching into the new level (a new rank flashes white and its name
	pops), LEVEL UP! slammed across it and the reward card turning UNLOCKED when the level opened it, with the fanfare; a
	level that opens a weapon's look then plays its unlock (even when skipping), which waits for a tap.
]]
function Module._levelUp(level: number)
	--[[ Local Variables ]]

	local tier = I.G_Progression.GetTier(level) --- @type Progression_Tier
	local newFrame: boolean = tier.Level == level
	local _opened: string?
	local openedAt: number?
	_opened, openedAt = I.G_Progression.GetNextUnlock(level - 1)

	--[[ Bursting ]]

	-- A new frame's sting swells for FRAME_UNLOCK_LEAD before its hit, so the burst waits for it; skipped, the fanfare waits for the end
	if skipping then
		skippedLevelUp = true
	else
		I.Sound.Play({ Name = if newFrame then "Frame_Unlock" else "Level_Up", SoundGroup = "UI" })
	end
	if newFrame then
		Module._wait(_settings.FRAME_UNLOCK_LEAD)
	end
	Module._showCrest(level)
	Module._emitStars(level)
	elems["BadgeScale"].Scale = _settings.CREST_PUNCH
	Module._tween(elems["BadgeScale"], _settings.PLATE_TWEENINFO, { Scale = 1 })
	elems["LevelUpScale"].Scale = 0
	Module._tween(elems["LevelUpScale"], _settings.LEVEL_UP_TWEENINFO, { Scale = 1 })

	--[[ New Rank ]]

	if newFrame then
		elems["Flash"].BackgroundTransparency = _settings.RANK_FLASH
		Module._tween(elems["Flash"], _settings.RANK_FLASH_TWEENINFO, { BackgroundTransparency = 1 })
		elems["TierNameScale"].Scale = 0
		Module._tween(elems["TierNameScale"], _settings.LEVEL_UP_TWEENINFO, { Scale = 1 })
	end

	--[[ Reward ]]

	if openedAt == level then
		Module._showReward(level, true)
		elems["NextScale"].Scale = _settings.REWARD_POP
		Module._tween(elems["NextScale"], _settings.PLATE_TWEENINFO, { Scale = 1 })
	end

	--[[ Holding ]]

	Module._wait(_settings.REPLAY_LEVEL_HOLD)
	Module._tween(elems["LevelUpScale"], _settings.PLATE_BACK_TWEENINFO, { Scale = 0 })
	elems["Fill"].Size = UDim2.fromScale(0, 1)
	elems["Head"].Position = UDim2.fromScale(0, 0.5)

	--[[ Weapon Reward ]]

	-- The tap that closes the unlock mustn't skip the rest of the replay
	if _settings.WEAPON_REWARDS[level] then
		local wasSkipping: boolean = skipping
		Unlock.Play(level)
		skipping = wasSkipping
	end
end

--%%%%%%%%%%%%%%%%%%%% Emit Sparks

--[[
	Throws a few sparks from an XP line that fly into the bar's end.
]]
function Module._emitSparks(row: Frame)
	--[[ Checks ]]

	-- Check if the player skipped
	if skipping then
		return
	end

	--[[ Building ]]

	local unit: number = Module._getUnit()
	if not sparks then
		sparks = I.UIEmitter.new({
			Parent = elems["Particles"],
			Rate = 0,
			Texture = _settings.REPLAY_TEXTURES.Spark,
			SizeSpace = "Offset",
			AspectRatio = 3,
			Size = NumberSequence.new(34 * unit, 12 * unit),
			Lifetime = NumberRange.new(0.8, 1.2),
			Velocity = NumberRange.new(250 * unit, 600 * unit),
			SpreadAngle = 360,
			FaceMovementDirection = true,
			AttractTo = elems["Head"],
			AttractStrength = 9000 * unit,
			AttractDestroyOnArrive = true,
			Color = _settings.REPLAY_COLORS[1],
			CullOffscreen = false,
		})
	end

	--[[ Emitting ]]

	sparks:Emit(_settings.REPLAY_SPARKS, row.AbsolutePosition + row.AbsoluteSize * Vector2.new(0.85, 0.5))
end

--%%%%%%%%%%%%%%%%%%%% Emit Stars

--[[
	Throws the level-up's stars from the crest, in the replay's colours, more for a higher tier.
]]
function Module._emitStars(level: number)
	--[[ Checks ]]

	-- Check if the player skipped
	if skipping then
		return
	end

	--[[ Building ]]

	local unit: number = Module._getUnit()
	if not stars then
		stars = I.UIEmitter.new({
			Parent = elems["Particles"],
			Rate = 0,
			Texture = _settings.REPLAY_TEXTURES.Star,
			SizeSpace = "Offset",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 30 * unit, 10 * unit), NumberSequenceKeypoint.new(1, 0) }),
			Lifetime = NumberRange.new(0.6, 1.3),
			Velocity = NumberRange.new(300 * unit, 900 * unit),
			SpreadAngle = 360,
			Drag = 1.8,
			RotationSpeed = NumberRange.new(-120, 120),
			CullOffscreen = false,
		})
	end

	--[[ Emitting ]]

	local tier = I.G_Progression.GetTier(level) --- @type Progression_Tier
	local look = _settings.REPLAY_TIER_LOOKS[table.find(_settings.FRAME_TIERS, tier) or 1] --- @type Progression_ReplayTierLook
	local center: Vector2 = elems["Badge"].AbsolutePosition + elems["Badge"].AbsoluteSize / 2
	for _index: number, color: Color3 in ipairs(_settings.REPLAY_COLORS) do
		stars.Color = color
		stars:Emit(math.round(_settings.REPLAY_STARS * look.Stars / #_settings.REPLAY_COLORS), center)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input

--[[
	A press while the replay plays skips the rest of it (the bar jumps to its end).
]]
function Module._onInput(input: InputObject)
	--[[ Checks ]]

	-- Check if a replay is playing and it's a press
	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA
	if not replaying or not press then
		return
	end

	--[[ Saving ]]

	skipping = true
end

--%%%%%%%%%%%%%%%%%%%% Tween

--[[
	Plays a tween on one instance (instantly while the player skips).
]]
--- @param goal { [string]: any }
function Module._tween(instance: Instance, info: TweenInfo, goal)
	--[[ Playing ]]

	local Step_TweenInfo: TweenInfo = if skipping then TweenInfo.new(0) else info
	local Step_TweenGoal = goal
	local Step_Tween: Tween = I.S.TweenService:Create(instance, Step_TweenInfo, Step_TweenGoal)
	Step_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Wait

--[[
	Waits a number of seconds, or not at all while the player skips.
]]
function Module._wait(seconds: number)
	--[[ Waiting ]]

	if not skipping and seconds > 0 then
		task.wait(seconds)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Cost

--[[
	Returns the XP a level takes, from the replay's costs (the server sends each level's on the way).
]]
--- @param replay Progression_Replay
--- @return number
function Module._getCost(replay, level: number)
	return replay.Costs[level - replay.Before.Level + 1] or replay.After.For
end

--%%%%%%%%%%%%%%%%%%%% Get Reward

--[[
	Returns how a level's reward shows on the card: a weapon look's picture in its variant's colour, the player's own
	face in the frame the level opens (in its tier's colour; before a skin at the same level, whose picture is still a
	stand-in), or a skin's or an emote's picture.
]]
--- @return Progression_RewardLook
function Module._getReward(atLevel: number)
	--[[ Local Variables ]]

	local weapon = _settings.WEAPON_REWARDS[atLevel] --- @type Progression_WeaponReward?
	local skinId: string? = _settings.LEVEL_REWARDS[atLevel]
	local tier = I.G_Progression.GetTier(atLevel) --- @type Progression_Tier

	--[[ Items ]]

	if weapon then
		return {
			Icon = I.G_Arsenal.Get(weapon.Item).Icon,
			Color = _settings.UNLOCK_LOOKS[weapon.Variant].Accent,
			Frame = false,
			Variant = weapon.Variant,
		}
	end
	if tier.Level == atLevel then
		return Module._getFrameReward(tier)
	end
	if skinId then
		return { Icon = I.G_Inventory.Items[skinId].IconId, Color = _settings.REWARD_COLOR, Frame = false }
	end
	--- @param row Cosmetics_EmoteData
	for emoteId: string, row in pairs(I.G_Cosmetics.GetEmotes()) do
		if (row.Level or 1) == atLevel then
			return { Icon = I.G_Inventory.Items[emoteId].IconId, Color = _settings.REWARD_COLOR, Frame = false }
		end
	end

	--[[ Returning ]]

	return Module._getFrameReward(tier)
end

--%%%%%%%%%%%%%%%%%%%% Get Frame Reward

--[[
	Returns a frame reward's look: the player's own face, in the tier's colour.
]]
--- @param tier Progression_Tier
--- @return Progression_RewardLook
function Module._getFrameReward(tier)
	return {
		Icon = `rbxthumb://type=AvatarHeadShot&id={I.S.Players.LocalPlayer.UserId}&w=150&h=150`,
		Color = tier.Colors[2],
		Frame = true,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Unit

--[[
	Returns the screen's size against a 1920 × 1080 one, for particle sizes and speeds.
]]
--- @return number
function Module._getUnit()
	--[[ Local Variables ]]

	local size: Vector2 = moduleGui.AbsoluteSize

	--[[ Returning ]]

	return math.max(0.1, math.min(size.X / 1920, size.Y / 1080))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
