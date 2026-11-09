--[[
	Created By: 	Nari
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

-- The banner's colour from the gui, put back on the player's own turn
local bannerColor: Color3

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
	bannerColor = elems["Banner"].TextColor3

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
	`TurnOrder`), up to TURN_LIST_ENTRIES, each with its avatar and name in its team colour.
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
		Teams.SetAvatar(row:FindFirstChild("S_Avatar"), entry)
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
	Chimes when a turn starts: brighter on the player's own (Turn_Yours) than on anyone else's (Turn_Start).
]]
function Module._onTurnStarted()
	I.Sound.Play({ Name = if I.Match.IsMyTurn() then "Turn_Yours" else "Turn_Start", SoundGroup = "SFX" })
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
	Counts the turn down on the timer ("0:30"), blank while a shot flies and settles (ticking aloud through the player's
	own last TICK_SOUND_FROM seconds), and fills the stamina bar from the player's snail.
]]
function Module._tick()
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("TurnEndsAt") or 0
	local seconds: number = math.max(math.ceil(endsAt - I.S.Workspace:GetServerTimeNow()), 0)

	-- Only the Turn phase has a clock: a 0 while a shot flies reads as time running out
	local timerText: string = if I.Match.GetPhase() == "Turn" then string.format("%d:%02d", seconds // 60, seconds % 60) else ""

	--[[ Timer ]]

	if timerText ~= shownTimer then
		shownTimer = timerText
		elems["Timer"].Text = timerText
		if timerText ~= "" and seconds > 0 and seconds <= _settings.TICK_SOUND_FROM and I.Match.IsMyTurn() then
			I.Sound.Play({ Name = "Turn_Tick", SoundGroup = "SFX" })
		end
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
