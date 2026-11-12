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
	elems["Damage"] = moduleGui:FindFirstChild("S_Damage", true) --- @type TextLabel
	elems["Knockouts"] = moduleGui:FindFirstChild("S_Knockouts", true) --- @type TextLabel
	elems["BestShot"] = moduleGui:FindFirstChild("S_BestShot", true) --- @type TextLabel
	elems["Rematch"] = moduleGui:FindFirstChild("S_Rematch", true) --- @type ImageButton
	elems["RematchText"] = elems["Rematch"]:FindFirstChild("S_Text") --- @type TextLabel
	elems["Lobby"] = moduleGui:FindFirstChild("S_Lobby", true) --- @type ImageButton
	prefabs["Placing"] = elems["Placings"]:FindFirstChild("PREFAB | Placing") --- @type Frame

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
	(their badges after it), username and coins, what the local player earned, their match stats, and the rematch vote.
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
	elems["Xp"].Text = `+{earned.Xp} XP`
	elems["LevelUp"].Visible = earned.LevelUp
	elems["LevelUp"].Text = `Level up! Level {earned.Level}`

	--[[ Visibility ]]

	-- The tutorial match always goes back to the lobby
	elems["Rematch"].Visible = matchFolder:GetAttribute("Kind") ~= "Tutorial"

	--[[ Stats ]]

	elems["Damage"].Text = `Damage dealt: {myStats and myStats.Damage or 0}`
	elems["Knockouts"].Text = `Knockouts: {myStats and myStats.Knockouts or 0}`
	elems["BestShot"].Text = `Best shot: {myStats and myStats.BestShot or 0}`

	--[[ Opening ]]

	I.WidgetManager.Open(_settings.RESULTS_GUI_NAME)
	if not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
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

	elems["RematchText"].Text = (if voted then "Voted" else "Rematch") .. `  {votes}/{playing}  |  0:{string.format("%02d", left)}`
end

--%%%%%%%%%%%%%%%%%%%% Vote Rematch

--[[
	Votes to play the match again.
]]
function Module._voteRematch()
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
	Closes the results and stops their rematch countdown.
]]
function Module._close()
	--[[ Closing ]]

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

return Module
