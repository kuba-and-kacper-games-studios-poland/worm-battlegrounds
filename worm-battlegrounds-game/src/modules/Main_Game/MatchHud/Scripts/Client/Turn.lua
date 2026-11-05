--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local matchFolder: Folder
local tickConnection: RBXScriptConnection?
local shownSeconds: number = -1

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
	elems["Timer"] = elems["Turn"]:FindFirstChild("S_Timer", true) --- @type TextLabel
	elems["WindArrow"] = elems["Turn"]:FindFirstChild("S_WindArrow", true) --- @type ImageLabel
	elems["Wind"] = elems["Turn"]:FindFirstChild("S_Wind", true) --- @type TextLabel
	elems["Stamina"] = gui:FindFirstChild("U_Stamina") --- @type Frame
	elems["StaminaFill"] = elems["Stamina"]:FindFirstChild("Fill", true) --- @type Frame
	elems["StaminaStatus"] = elems["Stamina"]:FindFirstChild("Status", true) --- @type TextLabel

	--[[ Connections ]]

	matchFolder = I.Match.GetFolder()
	matchFolder:GetAttributeChangedSignal("Wind"):Connect(Module._refreshWind)
	matchFolder:GetAttributeChangedSignal("TurnOrder"):Connect(Module._refresh)
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	I.Topic.Subscribe("Match_TurnStarted", Module._refresh)
	I.Topic.Subscribe("Match_MyTurn", Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the turn panel while turns run, the stamina bar on the player's own turn, and the banner on it ("Your
	turn!") or, on other worms' turns, how many turns until the player's own; ticks the timer only while it shows.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local inTurns: boolean = phase == "Turn" or phase == "Flight" or phase == "Settle"
	local myTurn: boolean = I.Match.IsMyTurn()
	local turnsLeft: number? = if myTurn then nil else Module._getTurnsLeft()

	--[[ Banner ]]

	elems["Banner"].Visible = myTurn or turnsLeft ~= nil
	elems["Banner"].Text = if myTurn then "Your turn!" elseif turnsLeft == 1 then "You're next!" else `Your turn in {turnsLeft} turns`

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
	elems["Wind"].Text = `Wind {math.abs(wind)}`
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the turn's seconds down, and fills the stamina bar from the player's worm.
]]
function Module._tick()
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("TurnEndsAt") or 0
	local seconds: number = if I.Match.GetPhase() == "Turn" then math.max(math.ceil(endsAt - I.S.Workspace:GetServerTimeNow()), 0) else 0

	--[[ Timer ]]

	if seconds ~= shownSeconds then
		shownSeconds = seconds
		elems["Timer"].Text = tostring(seconds)
	end

	--[[ Stamina ]]

	local mine: Model? = I.Worms.GetMine()
	if not elems["Stamina"].Visible or not mine then
		return
	end
	local share: number = math.clamp((mine:GetAttribute("Stamina") or 0) / I.Settings["WormControl"].STAMINA_STUDS, 0, 1)
	elems["StaminaFill"].Size = UDim2.fromScale(share, 1)
	elems["StaminaStatus"].Text = `{math.round(share * 100)}%`
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Turns Left

--[[
	How many turns come before the player's own, counting the one playing now (1 when they're next), from the
	match's `TurnOrder`. Nil when their worm can't play.
]]
--- @return number?
function Module._getTurnsLeft()
	--[[ Data ]]

	local mine: Model? = I.Worms.GetMine()

	--[[ Checks ]]

	-- Check if the player's worm is still in play
	if not mine or not mine:GetAttribute("Alive") then
		return nil
	end

	--[[ Returning ]]

	return table.find(string.split(matchFolder:GetAttribute("TurnOrder") or "", ","), mine.Name)
end

return Module
