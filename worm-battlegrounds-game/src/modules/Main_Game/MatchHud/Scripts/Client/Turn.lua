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

-- The turn's clock as the shot left (or the time ran out), held dimmed while the shot flies and the arena settles
local spentTimer: string?

-- The banner's, timer's and wait line's colours from the gui, put back after a turn's own looks
local bannerColor: Color3
local timerColor: Color3
local waitColor: Color3
local windColor: Color3

-- The callout title gradient's turn and offset from the gui, put back after sudden death's fill
local titleRotation: number
local titleOffset: Vector2

-- The wind shown last, so a change flashes
local shownWind: number? = nil

-- The turn panel's place from the gui, put back when the device isn't a phone or tablet
local turnPosition: UDim2

--[[ Feel ]]

-- The last tick played (seconds left), the tension band's pulse so far, and how many callouts have popped
local tickedAt: number? = nil
local tensionPhase: number = 0
local callouts: number = 0

-- Local play: the snail the callout holds for while its player takes the controller, and how many callouts it popped
local handOffId: string? = nil
local handOffCallout: number = 0

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
	elems["TimerPlate"] = elems["Timer"].Parent --- @type Frame
	elems["WindArrow"] = elems["Turn"]:FindFirstChild("S_WindArrow", true) --- @type TextLabel
	elems["Wind"] = elems["Turn"]:FindFirstChild("S_Wind", true) --- @type TextLabel
	elems["WindPlate"] = elems["Wind"].Parent --- @type Frame
	elems["Health"] = gui:FindFirstChild("U_Health", true) --- @type Frame
	elems["HealthBar"] = elems["Health"]:FindFirstChild("S_Bar") --- @type ImageLabel
	elems["HealthMask"] = elems["Health"]:FindFirstChild("S_BarMask") --- @type ImageLabel
	elems["HealthText"] = elems["Health"]:FindFirstChild("S_Text") --- @type TextLabel
	elems["Stamina"] = gui:FindFirstChild("U_Stamina", true) --- @type Frame
	elems["StaminaBar"] = elems["Stamina"]:FindFirstChild("S_Bar") --- @type ImageLabel
	elems["StaminaMask"] = elems["Stamina"]:FindFirstChild("S_BarMask") --- @type ImageLabel
	elems["StaminaText"] = elems["Stamina"]:FindFirstChild("S_Text") --- @type TextLabel
	elems["Fuel"] = elems["Stamina"]:FindFirstChild("U_Fuel") --- @type Frame
	elems["FuelBar"] = elems["Fuel"]:FindFirstChild("S_Bar") --- @type ImageLabel
	elems["FuelMask"] = elems["Fuel"]:FindFirstChild("S_BarMask") --- @type ImageLabel
	elems["FuelText"] = elems["Fuel"]:FindFirstChild("S_Text") --- @type TextLabel
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
	elems["KnockedOut"] = gui:FindFirstChild("U_KnockedOut") --- @type Frame
	elems["Tension"] = gui:FindFirstChild("U_Tension") --- @type Frame
	elems["TensionGlow"] = elems["Tension"]:FindFirstChild("S_Glow") --- @type UIStroke
	elems["Inset"] = gui:FindFirstChild("U_Inset") --- @type UIPadding
	bannerColor = elems["Banner"].TextColor3
	timerColor = elems["Timer"].TextColor3
	waitColor = elems["Wait"].TextColor3
	windColor = elems["Wind"].TextColor3
	titleRotation = elems["CalloutTitleGradient"].Rotation
	titleOffset = elems["CalloutTitleGradient"].Offset
	turnPosition = elems["Turn"].Position

	--[[ Connections ]]

	matchFolder = I.Match.GetFolder()
	matchFolder:GetAttributeChangedSignal("Wind"):Connect(Module._refreshWind)
	matchFolder:GetAttributeChangedSignal("WindOn"):Connect(Module._refreshWind)
	matchFolder:GetAttributeChangedSignal("TurnOrder"):Connect(Module._refresh)
	matchFolder:GetAttributeChangedSignal("SuddenDeath"):Connect(Module._onSuddenDeath)
	matchFolder:GetAttributeChangedSignal("HandOff"):Connect(Module._refresh)
	matchFolder:GetAttributeChangedSignal("HandOff"):Connect(Module._onHandOff)
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	I.Topic.Subscribe("Match_TurnStarted", Module._refresh)
	I.Topic.Subscribe("Match_TurnStarted", Module._onTurnStarted)
	I.Topic.Subscribe("Match_MyTurn", Module._refresh)
	I.Topic.Subscribe("Platform_Changed", Module._refreshLayout)
	Module._refreshLayout()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Layout

--[[
	Lifts the turn panel to the top of the HUD on phones and tablets (TURN_MOBILE_POSITION; its smaller size is the
	gui's Utils_MobileSize), clear of the aim, and puts it back elsewhere; then refreshes what it shows.
]]
function Module._refreshLayout()
	--[[ Applying ]]

	elems["Turn"].Position = if I.Platform.Current == "Mobile" then _settings.TURN_MOBILE_POSITION else turnPosition
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the turn panel (once a local turn's player has the controller) and the turn list while turns run, the stamina
	bar on the player's own turn (and after a throw while they still move), and whose turn it is: "Your turn!" (not on
	phones and tablets, where the callout and the turn arrow say it and the line sat in the aim), or another snail's
	name in its team colour with how many turns until the player's own; ticks only while it shows. The tutorial has no
	clock and no turn count (the owner, 2026-11-24).
]]
function Module._refresh()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local inTurns: boolean = phase == "Turn" or phase == "Flight" or phase == "Settle"
	local myTurn: boolean = I.Match.IsMyTurn()
	local turnsLeft: number? = if myTurn then nil else Module._getTurnsLeft()
	local activeId: string? = I.Match.GetActive()
	local active: Model? = if activeId and not myTurn then I.Snails.Get(activeId) else nil
	local tutorial: boolean = matchFolder:GetAttribute("Kind") == "Tutorial"

	--[[ Banner ]]

	elems["Banner"].Visible = active ~= nil or (myTurn and I.Platform.Current ~= "Mobile")
	elems["Banner"].Text = if active then `{active:GetAttribute("DisplayName")}'s turn` else "Your turn!"
	elems["Banner"].TextColor3 = if active then active:GetAttribute("Color") else bannerColor
	elems["Wait"].Visible = turnsLeft ~= nil and not tutorial
	elems["TimerPlate"].Visible = not tutorial
	elems["Wait"].Text = if turnsLeft == 1 then "You're next!" elseif turnsLeft then `You play in {turnsLeft} turns` else ""

	--[[ Visibility ]]

	-- In local play the turn's timer waits under the callout until its player has the controller (Match's HandOff)
	elems["Turn"].Visible = inTurns and matchFolder:GetAttribute("HandOff") == nil
	elems["TurnList"].Visible = inTurns
	-- After a throw the player runs on with what's left until it bursts (SnailControl's CanMove)
	local mine: Model? = I.Snails.GetMine()
	elems["Stamina"].Visible = myTurn and (phase == "Turn" or phase == "Flight" and mine ~= nil and mine:GetAttribute("CanMove") == true)
	-- The player's own health at the bottom left through the turns, while their snail is in play (the owner, 2026-11-24)
	elems["Health"].Visible = inTurns and mine ~= nil and mine:GetAttribute("Alive") == true

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
	Shows the wind plate only in a match with wind (WindOn), points the wind's arrow the way the wind blows and writes its
	strength with the side it blows to ("+3" right, "-3" left); no arrow in still air. A change of wind flashes the
	strength in NEXT_FLASH_COLOR.
]]
function Module._refreshWind()
	--[[ Local Variables ]]

	local wind: number = matchFolder:GetAttribute("Wind") or 0

	--[[ Applying ]]

	-- No wind plate in a match without wind (the owner, 2026-11-24: off unless a custom lobby or local play turns it on)
	elems["WindPlate"].Visible = matchFolder:GetAttribute("WindOn") == true
	elems["WindArrow"].Visible = wind ~= 0
	elems["WindArrow"].Text = if wind < 0 then "&lt;" else "&gt;"
	elems["Wind"].Text = if wind == 0 then "0" else string.format("%+d", wind)

	--[[ Flashing ]]

	if shownWind ~= nil and wind ~= shownWind then
		elems["Wind"].TextColor3 = _settings.NEXT_FLASH_COLOR

		local Flash_TweenGoal = { TextColor3 = windColor }
		local Flash_Tween: Tween = I.S.TweenService:Create(elems["Wind"], _settings.NEXT_FLASH_TWEENINFO, Flash_TweenGoal)
		Flash_Tween:Play()
	end
	shownWind = wind
end

--%%%%%%%%%%%%%%%%%%%% On Turn Started

--[[
	Announces a turn on the callout banner with the snail's avatar (headshot or bot). The player's own: "Your turn!" in
	gold over orange lines, with a whoosh and a bugle call (Turn_Yours), and a phone or pad taps twice. Anyone else's:
	their name in white over lines in their colour, smaller, with how long until the player's own and a drum roll
	(Turn_Start). When the player plays next, their "You're next!" line flashes with Turn_Next. In sudden death the sea's
	rise is heard (Match_WaterRise), and the line under the title says the liquid rises. In local play the gold banner
	names the snail whose turn it is, in its colour, and holds while its player takes the controller (On Hand Off).
]]
function Module._onTurnStarted(activeId: string)
	--[[ Checks ]]

	-- Check if the player is in the match (on the Studio map a match goes on beside the lobby)
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		return
	end

	--[[ Local Variables ]]

	local myTurn: boolean = I.Match.IsMyTurn()
	local active: Model? = I.Snails.Get(activeId)
	local entry: Configuration? = I.Match.GetParticipantInfo(activeId)
	local turnsLeft: number? = if myTurn then nil else Module._getTurnsLeft()
	-- In local play every snail on this screen is "yours", so the banner names whose turn it is
	local localPlay: boolean = matchFolder:GetAttribute("Kind") == "Local"
	local handingOff: boolean = myTurn and matchFolder:GetAttribute("HandOff") == activeId
	local accent: Color3 = if active and (localPlay or not myTurn) then active:GetAttribute("Color") else _settings.CALLOUT_ACCENT_COLOR
	local gradient = if myTurn then _settings.CALLOUT_MINE_GRADIENT else _settings.CALLOUT_OTHER_GRADIENT --- @type { Color3 }
	local handOffText: string = _settings.HANDOFF_TEXTS[I.Platform.Current] or _settings.HANDOFF_TEXTS.Desktop

	--[[ Callout ]]

	if entry then
		Teams.SetAvatar(elems["CalloutAvatar"], entry)
	end
	elems["CalloutAvatar"].Visible = true
	elems["CalloutTitle"].Text = if myTurn and not localPlay then "Your turn!" elseif active then `{active:GetAttribute("DisplayName")}'s turn` else ""
	elems["CalloutSub"].Text = if handingOff then handOffText else Module._getCalloutLine(myTurn, turnsLeft)
	elems["CalloutTitleGradient"].Color = ColorSequence.new(gradient[1], gradient[2])
	elems["CalloutTitleGradient"].Rotation = titleRotation
	elems["CalloutTitleGradient"].Offset = titleOffset
	elems["CalloutLineTop"].BackgroundColor3 = accent
	elems["CalloutLineBottom"].BackgroundColor3 = accent
	elems["CalloutAvatarStroke"].Color = accent

	--[[ Announcing ]]

	if handingOff then
		-- Held until the player takes the controller; their turn's call plays then
		I.Sound.Play({ Name = "Turn_Next", SoundGroup = "SFX" })
		handOffId = activeId
		handOffCallout = Module._openCallout(1)
	elseif myTurn then
		Module._playMyTurn()
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

--%%%%%%%%%%%%%%%%%%%% On Hand Off

--[[
	Local play: once the player the callout holds for has the controller (Match's HandOff clears), the line under their
	name becomes their turn's, their turn's call plays, and the callout goes as any turn's does.
]]
function Module._onHandOff()
	--[[ Checks ]]

	-- Check if the callout holds for a hand-off that's over
	if not handOffId or matchFolder:GetAttribute("HandOff") == handOffId then
		return
	end

	--[[ Releasing ]]

	handOffId = nil
	Module._playMyTurn()
	if handOffCallout == callouts then
		elems["CalloutSub"].Text = Module._getCalloutLine(true, nil)
		Module._closeCallout(handOffCallout, _settings.CALLOUT_HOLD)
	end
end

--%%%%%%%%%%%%%%%%%%%% Play My Turn

--[[
	The player's own turn's call: a bugle (Turn_Yours) over a whoosh, and a phone or pad taps twice.
]]
function Module._playMyTurn()
	--[[ Playing ]]

	I.Sound.Play({ Name = "Turn_Yours", SoundGroup = "SFX" })
	I.Sound.Play({ Name = "Turn_Whoosh", SoundGroup = "SFX" })
	I.Haptic.PlayOnce("Match_YourTurn")
end

--%%%%%%%%%%%%%%%%%%%% Pop Callout

--[[
	Plays the callout banner at a scale (Open Callout), holds CALLOUT_HOLD seconds (or the hold given), then closes it
	(Close Callout). None while the knocked-out screen shows: it would cross it.
]]
function Module._popCallout(scale: number, hold: number?)
	--[[ Checks ]]

	-- Check if the knocked-out screen is up
	if elems["KnockedOut"].Visible then
		return
	end

	--[[ Playing ]]

	Module._closeCallout(Module._openCallout(scale), _settings.CALLOUT_IN_TWEENINFO.Time + (hold or _settings.CALLOUT_HOLD))
end

--%%%%%%%%%%%%%%%%%%%% Open Callout

--[[
	Opens the callout banner at a scale: the band snaps open while its content slides in from the left and settles from
	CALLOUT_START_SCALE. A newer callout takes over from an older one.
]]
--- @return number
function Module._openCallout(scale: number)
	--[[ Local Variables ]]

	callouts += 1

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

	--[[ Returning ]]

	return callouts
end

--%%%%%%%%%%%%%%%%%%%% Close Callout

--[[
	After a delay, slides the callout's content off right as the band closes, unless a newer callout has the screen.
]]
function Module._closeCallout(count: number, delay: number)
	--[[ Hiding ]]

	task.delay(delay, function()
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
	Sounds the siren when sudden death starts and, once the turn's own callout is gone, announces the rising liquid on
	the callout: "Water is rising..." with no avatar, its lines in the liquid's colour, its title filling with it from
	the bottom.
]]
function Module._onSuddenDeath()
	--[[ Data ]]

	local liquid = Module._getSuddenDeathLiquid() --- @type MatchHud_SuddenDeathLiquid?

	--[[ Checks ]]

	-- Check if sudden death just started, in the player's match
	if not liquid or not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		return
	end

	--[[ Playing ]]

	I.Sound.Play({ Name = "Match_SuddenDeath", SoundGroup = "SFX" })

	--[[ Announcing ]]

	local wait: number = _settings.CALLOUT_IN_TWEENINFO.Time + _settings.CALLOUT_HOLD + _settings.CALLOUT_OUT_TWEENINFO.Time
	task.delay(wait, function()
		elems["CalloutAvatar"].Visible = false
		elems["CalloutTitle"].Text = string.format(_settings.SUDDEN_DEATH_TITLE, liquid.Name)
		elems["CalloutSub"].Text = _settings.SUDDEN_DEATH_SUB
		elems["CalloutLineTop"].BackgroundColor3 = liquid.Color
		elems["CalloutLineBottom"].BackgroundColor3 = liquid.Color
		elems["CalloutTitleGradient"].Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.52, liquid.Color),
			ColorSequenceKeypoint.new(1, liquid.Color),
		})
		elems["CalloutTitleGradient"].Rotation = 90
		elems["CalloutTitleGradient"].Offset = _settings.SUDDEN_DEATH_FILL_FROM
		Module._popCallout(1, _settings.SUDDEN_DEATH_HOLD)

		local Fill_TweenGoal = { Offset = _settings.SUDDEN_DEATH_FILL_TO }
		local Fill_Tween: Tween = I.S.TweenService:Create(elems["CalloutTitleGradient"], _settings.SUDDEN_DEATH_FILL_TWEENINFO, Fill_TweenGoal)
		Fill_Tween:Play()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the turn down on the timer ("0:30"), held dimmed on the time left while a shot flies and settles (the owner,
	2026-11-15), blank between turns, and fills the health and stamina bars at the bottom left from the
	player's snail, and the jetpack's fuel bar over them while the snail wears one. The player's own last seconds tighten: the timer turns orange, then red as it ticks aloud (faster
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

	local phase: string = I.Match.GetPhase()
	local spent: boolean = phase == "Flight" or phase == "Settle"

	-- The clock stops where the shot left it, and stays there dimmed until the turn is over
	if inTurn then
		spentTimer = string.format("%d:%02d", seconds // 60, seconds % 60)
	elseif not spent then
		spentTimer = nil
	end
	local timerText: string = if inTurn or spent then spentTimer or "" else ""

	--[[ Timer ]]

	if timerText ~= shownTimer then
		shownTimer = timerText
		elems["Timer"].Text = timerText
	end
	elems["Timer"].TextColor3 = if spent then _settings.TIMER_SPENT_COLOR elseif ticking then _settings.TIMER_DANGER_COLOR elseif tense and seconds <= _settings.TIMER_WARN_FROM then _settings.TIMER_WARN_COLOR else timerColor

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

		-- Along the whole screen's edges, up past the phone's top padding (U_Inset) to the screen's top, as on a PC (the owner, 2026-11-25: "make sure its streched too")
		local padding: number = elems["Inset"].PaddingTop.Offset
		elems["Tension"].Position = UDim2.new(0.5, 0, 0.5, -padding / 2)
		elems["Tension"].Size = UDim2.new(_settings.TENSION_SIZE.X, 0, _settings.TENSION_SIZE.Y, _settings.TENSION_SIZE.Y * padding)
	end

	--[[ Health ]]

	local mine: Model? = I.Snails.GetMine()
	if elems["Health"].Visible and mine then
		local health: number = mine:GetAttribute("Health") or 0
		Module._cutBar(elems["HealthBar"], elems["HealthMask"], math.clamp(health / (mine:GetAttribute("MaxHealth") or 1), 0, 1))
		elems["HealthText"].Text = string.format(_settings.HEALTH_FORMAT, health)
	end

	--[[ Stamina ]]

	if not elems["Stamina"].Visible or not mine then
		return
	end
	local share: number = math.clamp((mine:GetAttribute("Stamina") or 0) / I.Settings["SnailControl"].STAMINA_STUDS, 0, 1)
	Module._cutBar(elems["StaminaBar"], elems["StaminaMask"], share)
	elems["StaminaText"].Text = string.format(_settings.STAMINA_FORMAT, math.round(share * 100))

	--[[ Fuel ]]

	-- A snail wears its jetpack while it has fuel (SnailControl's JetpackFuel); this screen burns it as it flies
	elems["Fuel"].Visible = mine:GetAttribute("JetpackFuel") ~= nil
	if elems["Fuel"].Visible then
		local fuel: number = I.SnailControl.GetFuelShare()
		Module._cutBar(elems["FuelBar"], elems["FuelMask"], fuel)
		elems["FuelText"].Text = if mine:GetAttribute("JetpackRest") then _settings.FUEL_REST_TEXT else string.format(_settings.FUEL_FORMAT, math.round(fuel * 100))
	end
end

--%%%%%%%%%%%%%%%%%%%% Cut Bar

--[[
	Fills a bar to a share: its and its texture's gradients cut the pictures there (the fill is BAR_FILL of their width),
	so they never squash.
]]
function Module._cutBar(bar: ImageLabel, mask: ImageLabel, share: number)
	--[[ Local Variables ]]

	local edge: number = math.clamp(share, 0.001, 0.998) * _settings.BAR_FILL
	local cut: NumberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(edge, 0),
		NumberSequenceKeypoint.new(edge + 0.001, 1),
		NumberSequenceKeypoint.new(1, 1),
	})

	--[[ Applying ]]

	bar.UIGradient.Transparency = cut
	mask.UIGradient.Transparency = cut
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

--%%%%%%%%%%%%%%%%%%%% Get Sudden Death Liquid

--[[
	Returns the rising liquid's name and colour while sudden death runs (the match's SeaKind, water when unknown), nil
	before it.
]]
--- @return MatchHud_SuddenDeathLiquid?
function Module._getSuddenDeathLiquid()
	--[[ Checks ]]

	-- Check if sudden death runs
	if not matchFolder:GetAttribute("SuddenDeath") then
		return nil
	end

	--[[ Returning ]]

	return _settings.SUDDEN_DEATH_LIQUIDS[matchFolder:GetAttribute("SeaKind") or "Water"] or _settings.SUDDEN_DEATH_LIQUIDS.Water
end

--%%%%%%%%%%%%%%%%%%%% Get Callout Line

--[[
	Returns the line under the callout's title: "Aim and fire!" on the player's own turn, else how long until it, with
	the sudden-death reminder after it while the liquid rises.
]]
--- @return string
function Module._getCalloutLine(myTurn: boolean, turnsLeft: number?)
	--[[ Local Variables ]]

	local line: string = if myTurn then "Aim and fire!" elseif turnsLeft == 1 then "You're next!" elseif turnsLeft then `You play in {turnsLeft} turns` else ""
	local liquid = Module._getSuddenDeathLiquid() --- @type MatchHud_SuddenDeathLiquid?

	--[[ Returning ]]

	return if liquid then `{line}  ·  {string.format(_settings.SUDDEN_DEATH_REMINDER, string.lower(liquid.Name))}` else line
end

return Module
