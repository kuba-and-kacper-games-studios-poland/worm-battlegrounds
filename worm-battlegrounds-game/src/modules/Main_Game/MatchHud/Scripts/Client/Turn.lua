--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local matchFolder: Folder
local tickConnection: RBXScriptConnection?
local shownTimer: string?

-- The stamina bar's name from the gui ("Stamina"), written before its percentage
local staminaText: string

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
	elems["WindArrow"] = elems["Turn"]:FindFirstChild("S_WindArrow", true) --- @type ImageLabel
	elems["Wind"] = elems["Turn"]:FindFirstChild("S_Wind", true) --- @type TextLabel
	elems["Stamina"] = gui:FindFirstChild("U_Stamina", true) --- @type Frame
	elems["StaminaFill"] = elems["Stamina"]:FindFirstChild("Fill", true) --- @type Frame
	elems["StaminaStatus"] = elems["Stamina"]:FindFirstChild("Status", true) --- @type TextLabel
	staminaText = elems["StaminaStatus"].Text
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
	Shows the turn panel while turns run, the stamina bar on the player's own turn, and whose turn it is: "Your turn!",
	or another snail's name in its team colour with how many turns until the player's own; ticks only while it shows.
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
	elems["Stamina"].Visible = myTurn and phase == "Turn"

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

--%%%%%%%%%%%%%%%%%%%% Refresh Wind

--[[
	Points the wind arrow the way the wind blows and writes its strength; no arrow in still air.
]]
function Module._refreshWind()
	--[[ Local Variables ]]

	local wind: number = matchFolder:GetAttribute("Wind") or 0

	--[[ Applying ]]

	elems["WindArrow"].Visible = wind ~= 0
	elems["WindArrow"].Rotation = if wind < 0 then 180 else 0
	elems["Wind"].Text = tostring(math.abs(wind))
end

--%%%%%%%%%%%%%%%%%%%% Tick

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
	Counts the turn's seconds down on the turn panel, blank while a shot flies and settles (ticking aloud through the
	player's own last TICK_SOUND_FROM seconds), and fills the stamina bar from the player's snail.
]]
function Module._tick()
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("TurnEndsAt") or 0
	local seconds: number = math.max(math.ceil(endsAt - I.S.Workspace:GetServerTimeNow()), 0)

	-- Only the Turn phase has a clock: a 0 while a shot flies reads as time running out
	local timerText: string = if I.Match.GetPhase() == "Turn" then tostring(seconds) else ""

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
	elems["StaminaFill"].Size = UDim2.fromScale(share, 1)
	elems["StaminaStatus"].Text = `{staminaText} {math.round(share * 100)}%`
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
