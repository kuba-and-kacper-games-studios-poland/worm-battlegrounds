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

local matchFolder: Folder
local tickConnection: RBXScriptConnection?
local shownTimer: string?

-- The banner's, timer's and wait line's colours from the gui, put back after a turn's own looks
local bannerColor: Color3
local timerColor: Color3
local waitColor: Color3

--[[ Feel ]]

-- The last tick played (seconds left), the tension band's pulse so far, and how many callouts have popped
local tickedAt: number? = nil
local tensionPhase: number = 0
local callouts: number = 0

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

--- @class MatchHud_Client_Turn
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Turn"] = gui:FindFirstChild("U_Turn") --- @type Frame
	elems["Banner"] = elems["Turn"]:FindFirstChild("S_Banner", true) --- @type TextLabel
	elems["Wait"] = elems["Turn"]:FindFirstChild("S_Wait", true) --- @type TextLabel
	elems["Timer"] = elems["Turn"]:FindFirstChild("S_Timer", true) --- @type TextLabel
	elems["WindArrow"] = elems["Turn"]:FindFirstChild("S_WindArrow", true) --- @type TextLabel
	elems["Wind"] = elems["Turn"]:FindFirstChild("S_Wind", true) --- @type TextLabel
	elems["Stamina"] = gui:FindFirstChild("U_Stamina") --- @type Frame
	elems["StaminaBar"] = elems["Stamina"]:FindFirstChild("S_Bar") --- @type ImageLabel
	elems["StaminaText"] = elems["Stamina"]:FindFirstChild("S_Text") --- @type TextLabel
	elems["TurnList"] = gui:FindFirstChild("U_TurnList", true) --- @type Frame
	prefabs["TurnEntry"] = elems["TurnList"]:FindFirstChild("PREFAB | TurnEntry") --- @type Frame
	elems["Callout"] = gui:FindFirstChild("U_TurnCallout") --- @type Frame
	elems["CalloutBand"] = elems["Callout"]:FindFirstChild("S_Band") --- @type Frame
	elems["CalloutLineTop"] = elems["CalloutBand"]:FindFirstChild("S_LineTop") --- @type Frame
	elems["CalloutLineBottom"] = elems["CalloutBand"]:FindFirstChild("S_LineBottom") --- @type Frame
	elems["CalloutContent"] = elems["Callout"]:FindFirstChild("S_Content") --- @type Frame
	elems["CalloutPop"] = elems["CalloutContent"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["CalloutAvatar"] = elems["CalloutContent"]:FindFirstChild("S_Avatar") --- @type ImageLabel
	elems["CalloutAvatarStroke"] = elems["CalloutAvatar"]:FindFirstChild("S_AvatarStroke") --- @type UIStroke
	elems["CalloutTitle"] = elems["CalloutContent"]:FindFirstChild("S_Title") --- @type TextLabel
	elems["CalloutTitleGradient"] = elems["CalloutTitle"]:FindFirstChild("S_TitleGradient") --- @type UIGradient
	elems["CalloutSub"] = elems["CalloutContent"]:FindFirstChild("S_Sub") --- @type TextLabel
	elems["Tension"] = gui:FindFirstChild("U_Tension") --- @type Frame
	elems["TensionGlow"] = elems["Tension"]:FindFirstChild("S_Glow") --- @type UIStroke
	bannerColor = elems["Banner"].TextColor3
	timerColor = elems["Timer"].TextColor3
	waitColor = elems["Wait"].TextColor3

	--[[ Connections ]]

	matchFolder = I.Match.GetFolder()
	matchFolder:GetAttributeChangedSignal("Wind"):Connect(Module._refreshWind)
	matchFolder:GetAttributeChangedSignal("TurnOrder"):Connect(Module._refresh)
	matchFolder:GetAttributeChangedSignal("SuddenDeath"):Connect(Module._onSuddenDeath)
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	I.Topic.Subscribe("Match_TurnStarted", Module._refresh)
	I.Topic.Subscribe("Match_TurnStarted", Module._onTurnStarted)
	I.Topic.Subscribe("Match_MyTurn", Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the turn panel and the turn list while turns run, the stamina bar on the player's own turn, and whose turn it
	is: "Your turn!", or another snail's name in its team colour with how many turns until the player's own; ticks only
	while it shows.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local inTurns: boolean = phase == "Turn" or phase == "Flight" or phase == "Settle"
	local myTurn: boolean = I.Match.IsMyTurn()
	local turnsLeft: number? = if myTurn then nil else Module._getTurnsLeft()
	local activeId: string? = I.Match.GetActive()
	local active: Model? = if activeId and not myTurn then I.Snails.Get(activeId) else nil

	--[[ Banner ]]

	elems["Banner"].Visible = myTurn or active ~= nil
	elems["Banner"].Text = if active then `{active:GetAttribute("DisplayName")}'s turn` else "Your turn!"
	elems["Banner"].TextColor3 = if active then active:GetAttribute("Color") else bannerColor
	elems["Wait"].Visible = turnsLeft ~= nil
	elems["Wait"].Text = if turnsLeft == 1 then "You're next!" elseif turnsLeft then `Your turn in {turnsLeft} turns` else ""

	--[[ Visibility ]]

	elems["Turn"].Visible = inTurns
	elems["TurnList"].Visible = inTurns
	elems["Stamina"].Visible = myTurn and phase == "Turn"

	--[[ Turn List ]]

	Module._refreshTurnList(if inTurns then activeId else nil)

	--[[ Ticking ]]

	if inTurns and not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	elseif not inTurns and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
	end
	Module._refreshWind()
	Module._tick()
end

--%%%%%%%%%%%%%%%%%%%% Refresh Turn List

--[[
	Lists the snail playing now (in the list's current look) and the ones that play after it, in order (the match's
	`TurnOrder`), up to TURN_LIST_ENTRIES, each with its avatar and name in its team colour, its player's badges after
	the name.
]]
function Module._refreshTurnList(activeId: string?)
	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["TurnList"]:GetChildren()) do
		if child.Name == "TurnEntry" then
			child:Destroy()
		end
	end

	--[[ Checks ]]

	-- Check if a turn is playing
	if not activeId then
		return
	end

	--[[ Local Variables ]]

	local ids = { activeId } --- @type { string }
	for _index: number, id: string in ipairs(string.split(matchFolder:GetAttribute("TurnOrder") or "", ",")) do
		if id ~= "" and id ~= activeId and #ids < _settings.TURN_LIST_ENTRIES then
			table.insert(ids, id)
		end
	end

	--[[ Building ]]

	for index: number, id: string in ipairs(ids) do
		local entry: Configuration? = I.Match.GetParticipantInfo(id)
		if not entry then
			continue
		end

		--[[ Cloning ]]

		local row: Frame = prefabs["TurnEntry"]:Clone()
		local current: boolean = index == 1

		--[[ Elements ]]

		local background: Frame = row:FindFirstChild("Background")
		local main: ImageLabel = background:FindFirstChild("Main")
		local stroke: ImageLabel = background:FindFirstChild("Stroke")

		--[[ Applying ]]

		row.Name = "TurnEntry"
		row.LayoutOrder = index
		row.Visible = true
		main.Image = row:GetAttribute(if current then "Look_CurrentMain" else "Look_Main")
		main.ImageColor3 = row:GetAttribute(if current then "Look_CurrentMainColor" else "Look_MainColor")
		stroke.ImageColor3 = if current then row:GetAttribute("Look_CurrentStrokeColor") else entry:GetAttribute("Color")
		background:FindFirstChild("S_Mask").Visible = current
		row:FindFirstChild("S_Name").Text = entry:GetAttribute("DisplayName")
		I.PlayerBadges.Show(row:FindFirstChild("S_Name"), entry:GetAttribute("UserId"))
		Teams.SetAvatar(row:FindFirstChild("S_Avatar", true), entry)
		row.Parent = elems["TurnList"]
	end
end

--%%%%%%%%%%%%%%%%%%%% Refresh Wind

--[[
	Points the wind's arrow the way the wind blows and writes its strength with the side it blows to ("+3" right,
	"-3" left); no arrow in still air.
]]
function Module._refreshWind()
	--[[ Local Variables ]]

	local wind: number = matchFolder:GetAttribute("Wind") or 0

	--[[ Applying ]]

	elems["WindArrow"].Visible = wind ~= 0
	elems["WindArrow"].Text = if wind < 0 then "&lt;" else "&gt;"
	elems["Wind"].Text = if wind == 0 then "0" else string.format("%+d", wind)
end

--%%%%%%%%%%%%%%%%%%%% On Turn Started

--[[
	Announces a turn on the callout banner with the snail's avatar (headshot or bot). The player's own: "Your turn!" in
	gold over orange lines, with a whoosh and a bugle call (Turn_Yours), and a phone or pad taps twice. Anyone else's:
	their name in white over lines in their colour, smaller, with how long until the player's own and a drum roll
	(Turn_Start). When the player plays next, their "You're next!" line flashes with Turn_Next. In sudden death the sea's
	rise is heard (Match_WaterRise).
]]
function Module._onTurnStarted(activeId: string)
	--[[ Local Variables ]]

	local myTurn: boolean = I.Match.IsMyTurn()
	local active: Model? = I.Snails.Get(activeId)
	local entry: Configuration? = I.Match.GetParticipantInfo(activeId)
	local turnsLeft: number? = if myTurn then nil else Module._getTurnsLeft()
	local accent: Color3 = if myTurn or not active then _settings.CALLOUT_ACCENT_COLOR else active:GetAttribute("Color")
	local gradient = if myTurn then _settings.CALLOUT_MINE_GRADIENT else _settings.CALLOUT_OTHER_GRADIENT --- @type { Color3 }

	--[[ Callout ]]

	if entry then
		Teams.SetAvatar(elems["CalloutAvatar"], entry)
	end
	elems["CalloutTitle"].Text = if myTurn then "Your turn!" elseif active then `{active:GetAttribute("DisplayName")}'s turn` else ""
	elems["CalloutSub"].Text = if myTurn then "Aim and fire!" elseif turnsLeft == 1 then "You're next!" elseif turnsLeft then `Your turn in {turnsLeft} turns` else ""
	elems["CalloutTitleGradient"].Color = ColorSequence.new(gradient[1], gradient[2])
	elems["CalloutLineTop"].BackgroundColor3 = accent
	elems["CalloutLineBottom"].BackgroundColor3 = accent
	elems["CalloutAvatarStroke"].Color = accent

	--[[ Announcing ]]

	if myTurn then
		I.Sound.Play({ Name = "Turn_Yours", SoundGroup = "SFX" })
		I.Sound.Play({ Name = "Turn_Whoosh", SoundGroup = "SFX" })
		I.Haptic.PlayOnce("Match_YourTurn")
		Module._popCallout(1)
	else
		I.Sound.Play({ Name = "Turn_Start", SoundGroup = "SFX" })
		if active then
			Module._popCallout(_settings.CALLOUT_OTHER_SCALE)
		end
	end

	--[[ Next ]]

	if turnsLeft == 1 then
		I.Sound.Play({ Name = "Turn_Next", SoundGroup = "SFX", Volume = 0.5 })
		elems["Wait"].TextColor3 = _settings.NEXT_FLASH_COLOR

		local Flash_TweenGoal = { TextColor3 = waitColor }
		local Flash_Tween: Tween = I.S.TweenService:Create(elems["Wait"], _settings.NEXT_FLASH_TWEENINFO, Flash_TweenGoal)
		Flash_Tween:Play()
	end

	--[[ Sea ]]

	-- The sea rises at the start of every sudden-death turn
	if matchFolder:GetAttribute("SuddenDeath") then
		I.Sound.Play({ Name = "Match_WaterRise", SoundGroup = "SFX" })
	end
end

--%%%%%%%%%%%%%%%%%%%% Pop Callout

--[[
	Plays the callout banner at a scale: the band snaps open while its content slides in from the left and settles from
	CALLOUT_START_SCALE, holds CALLOUT_HOLD seconds, then the content slides off right as the band closes. A newer
	callout takes over from an older one.
]]
function Module._popCallout(scale: number)
	--[[ Local Variables ]]

	callouts += 1
	local count: number = callouts

	--[[ Showing ]]

	elems["CalloutBand"].Size = UDim2.fromScale(1, 0)
	elems["CalloutContent"].Position = UDim2.fromScale(0.5 - _settings.CALLOUT_SLIDE, 0.5)
	elems["CalloutPop"].Scale = scale * _settings.CALLOUT_START_SCALE
	elems["Callout"].Visible = true

	local Open_TweenGoal = { Size = UDim2.fromScale(1, 1) }
	local Open_Tween: Tween = I.S.TweenService:Create(elems["CalloutBand"], _settings.CALLOUT_BAND_TWEENINFO, Open_TweenGoal)
	Open_Tween:Play()

	local SlideIn_TweenGoal = { Position = UDim2.fromScale(0.5, 0.5) }
	local SlideIn_Tween: Tween = I.S.TweenService:Create(elems["CalloutContent"], _settings.CALLOUT_IN_TWEENINFO, SlideIn_TweenGoal)
	SlideIn_Tween:Play()

	local Pop_TweenGoal = { Scale = scale }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["CalloutPop"], _settings.CALLOUT_IN_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()

	--[[ Hiding ]]

	task.delay(_settings.CALLOUT_IN_TWEENINFO.Time + _settings.CALLOUT_HOLD, function()
		-- A newer callout has the screen
		if count ~= callouts then
			return
		end

		local SlideOut_TweenGoal = { Position = UDim2.fromScale(0.5 + _settings.CALLOUT_SLIDE, 0.5) }
		local SlideOut_Tween: Tween = I.S.TweenService:Create(elems["CalloutContent"], _settings.CALLOUT_OUT_TWEENINFO, SlideOut_TweenGoal)
		SlideOut_Tween:Play()

		local Close_TweenGoal = { Size = UDim2.fromScale(1, 0) }
		local Close_Tween: Tween = I.S.TweenService:Create(elems["CalloutBand"], _settings.CALLOUT_OUT_TWEENINFO, Close_TweenGoal)
		Close_Tween:Play()
		Close_Tween.Completed:Once(function()
			if count == callouts then
				elems["Callout"].Visible = false
			end
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Sudden Death

--[[
	Sounds the siren when sudden death starts.
]]
function Module._onSuddenDeath()
	--[[ Checks ]]

	-- Check if sudden death just started
	if not matchFolder:GetAttribute("SuddenDeath") then
		return
	end

	--[[ Playing ]]

	I.Sound.Play({ Name = "Match_SuddenDeath", SoundGroup = "SFX" })
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the turn down on the timer ("0:30"), blank while a shot flies and settles, and fills the stamina bar from the
	player's snail. The player's own last seconds tighten: the timer turns orange, then red as it ticks aloud (faster
	and higher at the very end), a band pulses along the screen's sides, and Turn_TimeUp sounds when it runs out.
]]
function Module._tick(deltaTime: number?)
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("TurnEndsAt") or 0
	local left: number = math.max(endsAt - I.S.Workspace:GetServerTimeNow(), 0)
	local seconds: number = math.ceil(left)
	local inTurn: boolean = I.Match.GetPhase() == "Turn"
	local tense: boolean = inTurn and I.Match.IsMyTurn() and left > 0
	local ticking: boolean = tense and seconds <= _settings.TICK_SOUND_FROM

	-- Only the Turn phase has a clock: a 0 while a shot flies reads as time running out
	local timerText: string = if inTurn then string.format("%d:%02d", seconds // 60, seconds % 60) else ""

	--[[ Timer ]]

	if timerText ~= shownTimer then
		shownTimer = timerText
		elems["Timer"].Text = timerText
	end
	elems["Timer"].TextColor3 = if ticking then _settings.TIMER_DANGER_COLOR elseif tense and seconds <= _settings.TIMER_WARN_FROM then _settings.TIMER_WARN_COLOR else timerColor

	--[[ Ticking ]]

	-- Each second, then each half second from TICK_FAST_FROM, a little higher as time runs out
	local step: number = if seconds <= _settings.TICK_FAST_FROM then 0.5 else 1
	local tickAt: number? = if ticking then math.ceil(left / step) * step else nil
	if tickAt and tickAt ~= tickedAt then
		local pitch: number = 1 + 0.3 * (1 - left / _settings.TICK_SOUND_FROM)
		I.Sound.Play({ Name = "Turn_Tick", SoundGroup = "SFX", PitchMin = pitch, PitchMax = pitch })
	end

	-- The ticking stops at 0 while the turn is still on: the time ran out without a shot
	if tickedAt and not tickAt and inTurn and left <= 0 then
		I.Sound.Play({ Name = "Turn_TimeUp", SoundGroup = "SFX" })
	end
	tickedAt = tickAt

	--[[ Tension ]]

	elems["Tension"].Visible = ticking
	if ticking then
		tensionPhase += (deltaTime or 0) * _settings.TENSION_PULSE_RATE * (2 - left / _settings.TICK_SOUND_FROM)
		elems["TensionGlow"].Transparency = 0.35 + 0.3 * (1 + math.cos(tensionPhase * 2 * math.pi))
	end

	--[[ Stamina ]]

	local mine: Model? = I.Snails.GetMine()
	if not elems["Stamina"].Visible or not mine then
		return
	end
	local share: number = math.clamp((mine:GetAttribute("Stamina") or 0) / I.Settings["SnailControl"].STAMINA_STUDS, 0, 1)

	-- The bar's gradient cuts the picture at the share (its fill is BAR_FILL of its width), so it never squashes
	local edge: number = math.clamp(share, 0.001, 0.998) * _settings.BAR_FILL
	elems["StaminaBar"].UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(edge, 0),
		NumberSequenceKeypoint.new(edge + 0.001, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	elems["StaminaText"].Text = string.format(_settings.STAMINA_FORMAT, math.round(share * 100))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Turns Left

--[[
	How many turns come before the player's own, counting the one playing now (1 when they're next), from the
	match's `TurnOrder`. Nil when their snail can't play.
]]
--- @return number?
function Module._getTurnsLeft()
	--[[ Data ]]

	local mine: Model? = I.Snails.GetMine()

	--[[ Checks ]]

	-- Check if the player's snail is still in play
	if not mine or not mine:GetAttribute("Alive") then
		return nil
	end

	--[[ Returning ]]

	return table.find(string.split(matchFolder:GetAttribute("TurnOrder") or "", ","), mine.Name)
end

return Module
