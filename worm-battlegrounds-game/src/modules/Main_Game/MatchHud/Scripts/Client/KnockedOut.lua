--[[
	Created By: 	HungryN00B
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

--[[ Screen ]]

-- Where the cause line sits under the title, and its size (it takes the killer card's place when no snail did it)
local causeHome: UDim2
local causeSize: UDim2

-- Whether Play again was sent
local playingAgain: boolean = false

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

--- @class MatchHud_Client_KnockedOut
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Panel"] = gui:FindFirstChild("U_KnockedOut") --- @type Frame
	elems["Callout"] = gui:FindFirstChild("U_TurnCallout") --- @type Frame
	elems["Pop"] = elems["Panel"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["Cause"] = elems["Panel"]:FindFirstChild("S_Cause") --- @type TextLabel
	elems["Killer"] = elems["Panel"]:FindFirstChild("S_Killer") --- @type Frame
	elems["KillerAvatar"] = elems["Killer"]:FindFirstChild("S_KillerAvatar") --- @type ImageLabel
	elems["KillerStroke"] = elems["KillerAvatar"]:FindFirstChild("S_KillerStroke") --- @type UIStroke
	elems["KillerName"] = elems["Killer"]:FindFirstChild("S_KillerName") --- @type TextLabel
	elems["Weapon"] = elems["Killer"]:FindFirstChild("S_Weapon") --- @type ImageLabel
	elems["Place"] = elems["Panel"]:FindFirstChild("S_Place", true) --- @type TextLabel
	elems["Diamonds"] = elems["Panel"]:FindFirstChild("S_Diamonds", true) --- @type TextLabel
	elems["Xp"] = elems["Panel"]:FindFirstChild("S_Xp", true) --- @type TextLabel
	elems["Pending"] = elems["Panel"]:FindFirstChild("S_Pending", true) --- @type TextLabel
	elems["Stats"] = elems["Panel"]:FindFirstChild("S_Stats") --- @type TextLabel
	elems["PlayAgain"] = elems["Panel"]:FindFirstChild("S_PlayAgain", true) --- @type ImageButton
	elems["PlayAgainText"] = elems["PlayAgain"]:FindFirstChild("Name1") --- @type TextLabel
	causeHome = elems["Cause"].Position
	causeSize = elems["Cause"].Size

	--[[ Connections ]]

	I.Network.Fired("Match_KnockedOut", Module._onKnockedOut)
	I.Network.Fired("MatchRewards_Earned", Module._onEarned)
	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.Interact.OnPress(elems["PlayAgain"], Module._playAgain)
	elems["Panel"]:GetPropertyChangedSignal("Visible"):Connect(Module._onShown)
	Module._reset()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Clears the screen for a new match: no rewards yet (the team's still in), Play again only for matches that play
	again (public and solo).
]]
function Module._reset()
	--[[ Local Variables ]]

	local kind: string? = I.Match.GetFolder():GetAttribute("Kind")

	--[[ Applying ]]

	playingAgain = false
	elems["Place"].Text = "—"
	elems["Diamonds"].Visible = false
	elems["Xp"].Visible = false
	elems["Pending"].Visible = true
	elems["Stats"].Visible = false
	elems["PlayAgain"].Visible = kind == "Public" or kind == "Solo"
	elems["PlayAgainText"].Text = "Play again"
end

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	A new match (its Waiting or Drop phase) clears the screen for the next knockout.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Clearing ]]

	if phase == "Waiting" or phase == "Drop" then
		Module._reset()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Knocked Out

--[[
	Fills the screen when the player's own snail goes out: who did it (their picture in their team's colour, their name
	and the weapon), or how it happened ("You fell into the water"), which then takes the killer card's place.
]]
function Module._onKnockedOut(participantId: string, cause: string, killerId: string?, itemId: string?)
	--[[ Checks ]]

	-- Check if it's the player's own snail
	if participantId ~= I.Match.GetMyParticipantId() then
		return
	end

	--[[ Data ]]

	local killer: Configuration? = if killerId and killerId ~= participantId then I.Match.GetParticipantInfo(killerId) else nil
	local row = if itemId then I.G_Arsenal.Get(itemId) else nil --- @type Arsenal_WeaponData?

	--[[ Texts ]]

	elems["Killer"].Visible = killer ~= nil
	elems["Cause"].Position = if killer then causeHome else elems["Killer"].Position
	elems["Cause"].Size = if killer then causeSize else UDim2.fromScale(causeSize.X.Scale, causeSize.Y.Scale * _settings.KO_CAUSE_ALONE_SCALE)
	if killer then
		elems["Cause"].Text = if row then `with the {row.Name}` else ""
		elems["KillerName"].Text = killer:GetAttribute("DisplayName") or "Someone"
		elems["KillerName"].TextColor3 = killer:GetAttribute("Color") or Color3.new(1, 1, 1)
		elems["KillerStroke"].Color = killer:GetAttribute("Color") or Color3.new(1, 1, 1)
		elems["Weapon"].Image = if row then row.Icon else ""
		Teams.SetAvatar(elems["KillerAvatar"], killer)
	elseif killerId == participantId then
		elems["Cause"].Text = "You knocked yourself out" .. (if row then ` with the {row.Name}` else "")
	elseif cause == "Water" or cause == "Lava" then
		elems["Cause"].Text = `You fell into the {string.lower(cause)}`
	elseif cause == "Bounds" then
		elems["Cause"].Text = "You fell out of the arena"
	else
		elems["Cause"].Text = "You were knocked out"
	end
end

--%%%%%%%%%%%%%%%%%%%% On Earned

--[[
	Shows what the player's team's knockout paid them: their place, diamonds and XP, and their match's damage, knockouts
	and best shot.
]]
--- @param earned MatchRewards_Earned
--- @param stats Match_Stats?
function Module._onEarned(place: number, _lastPlace: number, earned, stats)
	--[[ Local Variables ]]

	local diamonds: string = earned.Diamonds[I.Match.GetMyParticipantId()] or "0"

	--[[ Texts ]]

	elems["Place"].Text = Module._getOrdinal(place)
	elems["Diamonds"].Text = `+{diamonds} diamonds`
	elems["Xp"].Text = `+{earned.Xp} XP`
	elems["Stats"].Text = if stats then `Damage {math.floor(stats.Damage)}   ·   Knockouts {stats.Knockouts}   ·   Best shot {math.floor(stats.BestShot)}` else ""

	--[[ Visibility ]]

	elems["Diamonds"].Visible = true
	elems["Xp"].Visible = true
	elems["Pending"].Visible = false
	elems["Stats"].Visible = stats ~= nil
end

--%%%%%%%%%%%%%%%%%%%% On Shown

--[[
	Pops the screen in each time it shows (KO_POP_START_SCALE to 1), taking down a turn's callout banner still up (it
	would cross the screen; Turn holds the next ones while it shows).
]]
function Module._onShown()
	--[[ Checks ]]

	-- Check if it just showed
	if not elems["Panel"].Visible then
		return
	end

	--[[ Popping ]]

	elems["Callout"].Visible = false
	elems["Pop"].Scale = _settings.KO_POP_START_SCALE
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["Pop"], _settings.KO_POP_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Play Again

--[[
	Asks the server to put the player straight into another match like this one (by way of the lobby); a second press
	does nothing while it's on its way.
]]
function Module._playAgain()
	--[[ Checks ]]

	-- Check if it's already on its way
	if playingAgain then
		return
	end

	--[[ Sending ]]

	playingAgain = true
	elems["PlayAgainText"].Text = "Joining..."
	I.Network.Fire("Match_PlayAgain")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ordinal

--[[
	Returns a place as the results write it: 1st, 2nd, 3rd, 4th…
]]
--- @return string
function Module._getOrdinal(place: number)
	--[[ Local Variables ]]

	local tens: number = place % 100
	local suffix: string = if tens >= 11 and tens <= 13 then "th" elseif place % 10 == 1 then "st" elseif place % 10 == 2 then "nd" elseif place % 10 == 3 then "rd" else "th"

	--[[ Returning ]]

	return `{place}{suffix}`
end

return Module
