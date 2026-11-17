--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Teams = require(script.Parent:FindFirstChild("Teams")) --- @type MatchHud_Client_Teams

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local matchFolder: Folder
local tickConnection: RBXScriptConnection?
local voted: boolean = false

-- The Rematch button's own colours, put back after the tutorial greyed it (the Studio map plays on)
local rematchColors = {} --- @type { [string]: Color3 }

-- Which results the level bar plays: a newer results screen (or closing it) stops an older one's
local xpRun: number = 0

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

--- @class MatchHud_Client_Results
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.RESULTS_GUI_NAME]
	elems["Result"] = moduleGui:FindFirstChild("S_Result", true) --- @type TextLabel
	elems["Placings"] = moduleGui:FindFirstChild("U_Placings", true) --- @type ScrollingFrame
	elems["Coins"] = moduleGui:FindFirstChild("U_Earned", true):FindFirstChild("S_Coins", true) --- @type TextLabel
	elems["Xp"] = moduleGui:FindFirstChild("S_Xp", true) --- @type TextLabel
	elems["LevelUp"] = moduleGui:FindFirstChild("S_LevelUp", true) --- @type TextLabel
	elems["XpRow"] = moduleGui:FindFirstChild("S_XpRow", true) --- @type Frame
	elems["LevelPop"] = elems["XpRow"]:FindFirstChild("S_LevelPop", true) --- @type UIScale
	elems["LevelGradient"] = elems["XpRow"]:FindFirstChild("S_LevelGradient", true) --- @type UIGradient
	elems["LevelNum"] = elems["XpRow"]:FindFirstChild("S_LevelNum", true) --- @type TextLabel
	elems["LevelTitle"] = elems["XpRow"]:FindFirstChild("S_LevelTitle", true) --- @type TextLabel
	elems["XpFill"] = elems["XpRow"]:FindFirstChild("S_XpFill", true) --- @type Frame
	elems["XpCount"] = elems["XpRow"]:FindFirstChild("S_XpCount", true) --- @type TextLabel
	elems["Damage"] = moduleGui:FindFirstChild("S_Damage", true) --- @type TextLabel
	elems["Knockouts"] = moduleGui:FindFirstChild("S_Knockouts", true) --- @type TextLabel
	elems["BestShot"] = moduleGui:FindFirstChild("S_BestShot", true) --- @type TextLabel
	elems["Rematch"] = moduleGui:FindFirstChild("S_Rematch", true) --- @type ImageButton
	elems["RematchText"] = elems["Rematch"]:FindFirstChild("S_Text") --- @type TextLabel
	elems["RematchMain"] = elems["Rematch"]:FindFirstChild("Main", true) --- @type ImageLabel
	elems["RematchStroke"] = elems["Rematch"]:FindFirstChild("Stroke", true) --- @type ImageLabel
	elems["RematchMask"] = elems["Rematch"]:FindFirstChild("Mask", true) --- @type ImageLabel
	elems["Lobby"] = moduleGui:FindFirstChild("S_Lobby", true) --- @type ImageButton
	prefabs["Placing"] = elems["Placings"]:FindFirstChild("PREFAB | Placing") --- @type Frame

	--[[ Saving ]]

	rematchColors.Main = elems["RematchMain"].ImageColor3
	rematchColors.Stroke = elems["RematchStroke"].ImageColor3
	rematchColors.Text = elems["RematchText"].TextColor3

	--[[ Connections ]]

	matchFolder = I.Match.GetFolder()
	I.Network.Fired("Match_Results", Module._onResults)
	I.Interact.OnPress(elems["Rematch"], Module._voteRematch)
	I.Interact.OnPress(elems["Lobby"], Module._goToLobby)
	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._onMoved)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Results

--[[
	Opens the results when the match ends: every player's place (1st to 3rd in their medal colours), name in team colours
	(their badges after it), username and coins, what the local player earned (their level bar filling from before the
	match to after it, when the server sent both), their match stats, and the rematch vote.
]]
--- @param placements { Match_Placement }
--- @param stats { [string]: Match_Stats }
--- @param earned MatchRewards_Earned
function Module._onResults(placements, stats, earned)
	--[[ Local Variables ]]

	local myId: string = I.Match.GetMyParticipantId()
	local myStats = stats[myId] --- @type Match_Stats?
	local myPlace: number? = nil
	voted = false

	-- A server from before the level bar sends no level before and after: its level-up line shows at once instead
	local playsXp: boolean = earned.XpBefore ~= nil and earned.XpAfter ~= nil
	xpRun += 1

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Placings"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["Placing"] then
			child:Destroy()
		end
	end

	--[[ Placings ]]

	-- The design fits RESULTS_FIT_PLACINGS cards across; more players share that width
	local cardWidth: number = prefabs["Placing"].Size.X.Scale * _settings.RESULTS_FIT_PLACINGS / math.max(#placements, _settings.RESULTS_FIT_PLACINGS)

	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		local entry: Configuration? = I.Match.GetParticipantInfo(placement.ParticipantId)
		local row: Frame = prefabs["Placing"]:Clone()
		local nameLabel: TextLabel = row:FindFirstChild("S_Name", true)
		local avatar: ImageLabel = row:FindFirstChild("S_Avatar", true)
		local userId: number = entry and entry:GetAttribute("UserId") or 0
		local player: Player? = I.S.Players:GetPlayerByUserId(userId)
		local placeLabel: TextLabel = row:FindFirstChild("S_Place", true)
		local look: string = if placement.Place <= 3 then tostring(placement.Place) else ""
		row.Name = placement.ParticipantId
		row.LayoutOrder = placement.Place
		row.Size = UDim2.fromScale(cardWidth, row.Size.Y.Scale)
		row.Visible = true
		placeLabel.Text = Module._getOrdinal(placement.Place)
		placeLabel.TextColor3 = row:GetAttribute(`Look_{look}PlaceColor`)
		row:FindFirstChild("S_Stroke", true).ImageColor3 = row:GetAttribute(`Look_{look}StrokeColor`)
		row:FindFirstChild("S_Username", true).Text = if player then `@{player.Name}` else ""
		nameLabel.Text = entry and entry:GetAttribute("DisplayName") or "?"
		nameLabel.TextColor3 = entry and entry:GetAttribute("Color") or Color3.new(1, 1, 1)
		I.PlayerBadges.Show(nameLabel, userId)
		row:FindFirstChild("S_Coins", true).Text = `+{earned.Coins[placement.ParticipantId] or "0"} coins`
		if entry then
			Teams.SetAvatar(avatar, entry)
		end
		row.Parent = elems["Placings"]
		if placement.ParticipantId == myId then
			myPlace = placement.Place
			elems["Result"].Text = `You placed <font color="#{placeLabel.TextColor3:ToHex()}">{Module._getOrdinal(placement.Place)}</font>!`
		end
	end

	--[[ Earned ]]

	elems["Coins"].Text = `+{earned.Coins[myId] or "0"} coins`
	elems["Xp"].Text = if playsXp then "+0 XP" else `+{earned.Xp} XP`
	elems["LevelUp"].Visible = earned.LevelUp and not playsXp
	elems["LevelUp"].Text = `Level up! Level {earned.Level}`
	elems["XpRow"].Visible = playsXp
	if playsXp then
		Module._showLevel(earned.XpBefore.Level, earned.XpBefore.Into, earned.XpBefore.For)
	end

	--[[ Visibility ]]

	-- The tutorial match always goes back to the lobby: its Rematch shows grey (its gold Mask hidden) and does nothing
	local colors = if Module._isTutorial() then _settings.LOCKED_REMATCH_COLORS else rematchColors --- @type { [string]: Color3 }
	elems["RematchMask"].Visible = not Module._isTutorial()
	elems["RematchMain"].ImageColor3 = colors.Main
	elems["RematchStroke"].ImageColor3 = colors.Stroke
	elems["RematchText"].TextColor3 = colors.Text

	--[[ Stats ]]

	elems["Damage"].Text = `Damage dealt: {myStats and myStats.Damage or 0}`
	elems["Knockouts"].Text = `Knockouts: {myStats and myStats.Knockouts or 0}`
	elems["BestShot"].Text = `Best shot: {myStats and myStats.BestShot or 0}`

	--[[ Opening ]]

	I.WidgetManager.Open(_settings.RESULTS_GUI_NAME)
	if not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	end
	if playsXp then
		task.spawn(Module._playXp, earned, xpRun)
	end

	--[[ Sound ]]

	-- A fanfare for first place, a sad trombone for the rest; nothing for a spectator
	if myPlace then
		I.Sound.Play({ Name = if myPlace == 1 then "Match_Win" else "Match_Lose", SoundGroup = "SFX" })
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Shows the rematch votes and the time left to vote on the Rematch button while the results show.
]]
function Module._tick()
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("RematchEndsAt") or 0
	local left: number = math.ceil(math.max(endsAt - I.S.Workspace:GetServerTimeNow(), 0))
	local votes: number = matchFolder:GetAttribute("RematchVotes") or 0

	--[[ Counting ]]

	-- The players still in the match (the Studio map's lobby shares the server)
	local playing: number = 0
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player:GetAttribute("InMatch") then
			playing += 1
		end
	end

	--[[ Applying ]]

	if Module._isTutorial() then
		elems["RematchText"].Text = "Rematch"
		return
	end
	elems["RematchText"].Text = (if voted then "Voted" else "Rematch") .. `  {votes}/{playing}  |  0:{string.format("%02d", left)}`
end

--%%%%%%%%%%%%%%%%%%%% Play Xp

--[[
	Plays the match's XP on the level bar, from the level before the match: after RESULTS_XP_DELAY each XP line adds to
	the total with Xp_Line and fills the bar with rising Xp_Tick ticks, and each level reached plays Level_Up. A newer
	results screen, or closing this one, stops it.
]]
--- @param earned MatchRewards_Earned
function Module._playXp(earned, run: number)
	--[[ Local Variables ]]

	-- An older server's results carry no lines: the match's XP is one
	--- @type { Progression_XpLine }
	local lines = earned.XpLines or { { Key = "Match", Label = "", Count = 1, Amount = earned.Xp } }
	local level: number = earned.XpBefore.Level
	local into: number = earned.XpBefore.Into
	local cost: number = earned.XpBefore.For
	local total: number = 0

	--[[ Waiting ]]

	task.wait(_settings.RESULTS_XP_DELAY)

	--[[ Lines ]]

	--- @param line Progression_XpLine
	for _index: number, line in ipairs(lines) do
		-- Stop once a newer results screen took over, or this one closed
		if run ~= xpRun then
			return
		end

		total += line.Amount
		elems["Xp"].Text = `+{total} XP`
		I.Sound.Play({ Name = "Xp_Line", SoundGroup = "UI" })

		local left: number = line.Amount
		while left > 0 and run == xpRun do
			-- One stretch of the bar: up to the end of this level, or what's left of the line
			local gain: number = if cost > 0 then math.min(left, cost - into) else left
			Module._fillXp(into, into + gain, cost, gain / line.Amount, run)
			into += gain
			left -= gain

			if cost > 0 and into >= cost then
				level += 1
				into = 0
				cost = Module._getCost(earned, level)
				Module._levelUp(level, cost)
			end
		end
		task.wait(_settings.RESULTS_XP_LINE_GAP)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fill Xp

--[[
	Fills the level bar from one amount of XP to another, a share of RESULTS_XP_FILL_SECONDS, counting the XP up with
	Xp_Tick ticks that climb through RESULTS_XP_TICK_PITCH as the bar fills.
]]
function Module._fillXp(from: number, to: number, cost: number, share: number, run: number)
	--[[ Local Variables ]]

	local seconds: number = math.max(0.15, _settings.RESULTS_XP_FILL_SECONDS * share)
	local ticks: number = math.max(1, math.round(_settings.RESULTS_XP_TICKS * share))
	local pitch: NumberRange = _settings.RESULTS_XP_TICK_PITCH

	--[[ Filling ]]

	local Fill_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Fill_TweenGoal = { Size = UDim2.fromScale(if cost > 0 then to / cost else 1, 1) }
	local Fill_Tween: Tween = I.S.TweenService:Create(elems["XpFill"], Fill_TweenInfo, Fill_TweenGoal)
	Fill_Tween:Play()

	--[[ Ticking ]]

	for step: number = 1, ticks do
		-- Stop once a newer results screen took over, or this one closed
		if run ~= xpRun then
			return
		end

		local through: number = from + (to - from) * step / ticks
		local stepPitch: number = pitch.Min + (pitch.Max - pitch.Min) * (if cost > 0 then through / cost else 1)
		elems["XpCount"].Text = if cost > 0 then `{math.floor(through)} / {cost} XP` else "Max level"
		I.Sound.Play({ Name = "Xp_Tick", SoundGroup = "UI", PitchMin = stepPitch, PitchMax = stepPitch })
		task.wait(seconds / ticks)
	end
end

--%%%%%%%%%%%%%%%%%%%% Level Up

--[[
	A level reached on the bar: Level_Up plays, the diamond pops in the new level's frame, the level-up line shows, and
	the bar starts again from empty.
]]
function Module._levelUp(level: number, cost: number)
	--[[ Applying ]]

	I.Sound.Play({ Name = "Level_Up", SoundGroup = "UI" })
	elems["LevelUp"].Text = `Level up! Level {level}`
	elems["LevelUp"].Visible = true
	Module._showLevel(level, 0, cost)

	--[[ Tweening ]]

	elems["LevelPop"].Scale = 1.4
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["LevelPop"], _settings.RESULTS_LEVEL_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Level

--[[
	Shows a level on the bar at once: its number in the diamond in its prestige frame's colours (Progression's
	ApplyFrame, as the lobby's plate), "Level 14", the fill and "60 / 156 XP" ("Max level" at the top).
]]
function Module._showLevel(level: number, into: number, cost: number)
	--[[ Applying ]]

	I.G_Progression.ApplyFrame(elems["LevelGradient"], level)
	elems["LevelNum"].Text = tostring(level)
	elems["LevelTitle"].Text = `Level {level}`
	elems["XpFill"].Size = UDim2.fromScale(if cost > 0 then into / cost else 1, 1)
	elems["XpCount"].Text = if cost > 0 then `{into} / {cost} XP` else "Max level"
end

--%%%%%%%%%%%%%%%%%%%% Vote Rematch

--[[
	Votes to play the match again.
]]
function Module._voteRematch()
	--[[ Checks ]]

	-- Check if the match can be played again
	if Module._isTutorial() then
		return
	end

	--[[ Sending ]]

	voted = true
	I.Network.Fire("Match_Rematch")
end

--%%%%%%%%%%%%%%%%%%%% Go To Lobby

--[[
	Goes back to the lobby now.
]]
function Module._goToLobby()
	--[[ Sending ]]

	I.Network.Fire("Match_Leave")
end

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	Closes the results when a rematch starts.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Checks ]]

	-- Check if a new match started
	if phase == "Ended" then
		return
	end

	--[[ Closing ]]

	Module._close()
end

--%%%%%%%%%%%%%%%%%%%% On Moved

--[[
	Closes the results when the player goes back to the Studio map's lobby, where the match keeps going without them.
]]
function Module._onMoved()
	--[[ Checks ]]

	-- Check if the player left the match
	if I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		return
	end

	--[[ Closing ]]

	Module._close()
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Closes the results and stops their rematch countdown and level bar.
]]
function Module._close()
	--[[ Closing ]]

	xpRun += 1
	if tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
	end
	if I.WidgetManager.GetCurrent() == moduleGui then
		I.WidgetManager.Close(_settings.RESULTS_GUI_NAME)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ordinal

--[[
	Returns a place as an ordinal: 1st, 2nd, 3rd, 4th.
]]
--- @return string
function Module._getOrdinal(place: number)
	--[[ Local Variables ]]

	local suffix: string = if place % 100 >= 11 and place % 100 <= 13 then "th" elseif place % 10 == 1 then "st" elseif place % 10 == 2 then "nd" elseif place % 10 == 3 then "rd" else "th"

	--[[ Returning ]]

	return `{place}{suffix}`
end

--%%%%%%%%%%%%%%%%%%%% Get Cost

--[[
	Returns the XP a level costs, for the bar between the levels before and after the match: the client never gets the
	level curve, but it rises by the same step every level, so a level between costs the share of the way from the
	one before to the one after.
]]
--- @param earned MatchRewards_Earned
--- @return number
function Module._getCost(earned, level: number)
	--[[ Data ]]

	local before = earned.XpBefore --- @type Progression_Progress
	local after = earned.XpAfter --- @type Progression_Progress

	--[[ Checks ]]

	-- Check if it's the level the match ended on
	if level >= after.Level then
		return after.For
	end

	--[[ Returning ]]

	return math.round(before.For + (after.For - before.For) * (level - before.Level) / (after.Level - before.Level))
end

--%%%%%%%%%%%%%%%%%%%% Is Tutorial

--[[
	Returns whether this is the tutorial match, which can't be played again.
]]
--- @return boolean
function Module._isTutorial()
	return matchFolder:GetAttribute("Kind") == "Tutorial"
end

return Module
