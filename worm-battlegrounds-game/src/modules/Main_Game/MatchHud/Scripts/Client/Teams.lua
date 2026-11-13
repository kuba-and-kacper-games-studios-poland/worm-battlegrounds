--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local participants: Folder

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

--- @class MatchHud_Client_Teams
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Left"] = gui:FindFirstChild("U_TeamsLeft", true) --- @type Frame
	elems["Right"] = gui:FindFirstChild("U_TeamsRight", true) --- @type Frame
	prefabs["Team"] = elems["Left"]:FindFirstChild("PREFAB | Team") --- @type Frame

	--[[ Connections ]]

	participants = I.Match.GetFolder():WaitForChild("Participants")
	participants.ChildAdded:Connect(Module._watchEntry)
	participants.ChildRemoved:Connect(Module._refresh)
	for _index: number, entry: Instance in ipairs(participants:GetChildren()) do
		Module._watchEntry(entry)
	end
	I.Topic.Subscribe("Match_PhaseChanged", Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Avatar

--[[
	Shows a participant's avatar headshot on an image, or BOT_AVATAR (the default snail's headshot) for a bot. A
	Studio test's players (negative user ids, which have no headshot) show the first Roblox avatar's.
]]
function Module.SetAvatar(image: ImageLabel, entry: Configuration)
	--[[ Local Variables ]]

	local userId: number = entry:GetAttribute("UserId") or 0

	--[[ Applying ]]

	image.Image = if entry:GetAttribute("IsBot") then _settings.BOT_AVATAR else `rbxthumb://type=AvatarHeadShot&id={math.max(userId, 1)}&w=150&h=150`
end

--%%%%%%%%%%%%%%%%%%%% Watch Entry

--[[
	Redraws the panels when a participant joins the match, and when one is knocked out.
]]
function Module._watchEntry(entry: Instance)
	--[[ Connections ]]

	entry:GetAttributeChangedSignal("Out"):Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws every team in the top corners from the drop on: the player's own team first on the left, the others in turn
	on the right and the left, each with its players' avatars in its colour (knocked-out ones darkened) and its name.
]]
function Module._refresh()
	--[[ Clearing ]]

	for _index: number, side: string in ipairs({ "Left", "Right" }) do
		for _childIndex: number, child: Instance in ipairs(elems[side]:GetChildren()) do
			if child.Name == "Team" then
				child:Destroy()
			end
		end
	end

	--[[ Data ]]

	local entries = participants:GetChildren() --- @type { Configuration }
	local mine: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	local myTeam: number? = if mine then mine:GetAttribute("Team") else nil

	--[[ Checks ]]

	-- Check if the match has its participants
	local phase: string = I.Match.GetPhase()
	elems["Left"].Visible = phase ~= "Waiting" and #entries > 0
	elems["Right"].Visible = elems["Left"].Visible
	if not elems["Left"].Visible then
		return
	end

	--[[ Grouping ]]

	-- Members by team, and the teams in order: the player's own first
	local members = {} --- @type { [number]: { Configuration } }
	local order = {} --- @type { number }
	local teamMode: boolean = false
	table.sort(entries, function(a: Configuration, b: Configuration): boolean
		return a.Name < b.Name
	end)
	for _index: number, entry: Configuration in ipairs(entries) do
		local team: number = entry:GetAttribute("Team")
		if not members[team] then
			members[team] = {}
			table.insert(order, team)
		end
		table.insert(members[team], entry)
		teamMode = teamMode or #members[team] > 1
	end
	table.sort(order, function(a: number, b: number): boolean
		if a == myTeam or b == myTeam then
			return a == myTeam
		end
		return a < b
	end)

	--[[ Sides ]]

	-- Teams alternate left and right; each side shrinks its players when more than fit
	local sides = { Left = {}, Right = {} } --- @type { [string]: { number } }
	local players = { Left = 0, Right = 0 } --- @type { [string]: number }
	for index: number, team: number in ipairs(order) do
		local side: string = if index % 2 == 1 then "Left" else "Right"
		table.insert(sides[side], team)
		players[side] += #members[team]
	end

	--[[ Building ]]

	--- @param teams { number }
	for side: string, teams in pairs(sides) do
		local padding: number = elems[side]:FindFirstChildOfClass("UIListLayout").Padding.Scale
		local fit: number = math.min(1, (1 - padding * math.max(#teams - 1, 0)) / math.max(players[side] * _settings.TEAM_PLAYER_WIDTH, 1e-3))
		for index: number, team: number in ipairs(teams) do
			Module._buildTeam(side, index, team, members[team], team == myTeam, teamMode, fit)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Build Team

--[[
	Clones a team panel on one side: its players' avatars (the side's own pictures, outlined in their colour), and its
	name in the team's colour ("Your team", "Red team"; in a free-for-all "You" or the snail's name).
]]
--- @param teamMembers { Configuration }
function Module._buildTeam(side: string, index: number, team: number, teamMembers, isMine: boolean, teamMode: boolean, fit: number)
	--[[ Local Variables ]]

	local color: Color3 = teamMembers[1]:GetAttribute("Color")
	local name: string
	if teamMode then
		name = if isMine then "Your team" else `{I.Settings["Match"].TEAMS[team].Name} team`
	else
		name = if isMine then "You" else teamMembers[1]:GetAttribute("DisplayName")
	end

	--[[ Cloning ]]

	local panel: Frame = prefabs["Team"]:Clone()

	--[[ Elements ]]

	local list: Frame = panel:FindFirstChild("S_Players")
	local nameLabel: TextLabel = panel:FindFirstChild("S_Name")
	local playerPrefab: Frame = list:FindFirstChild("PREFAB | TeamPlayer")

	--[[ Texts ]]

	nameLabel.Text = name
	nameLabel.TextColor3 = color
	nameLabel.TextXAlignment = if side == "Left" then Enum.TextXAlignment.Left else Enum.TextXAlignment.Right

	--[[ Players ]]

	for playerIndex: number, entry: Configuration in ipairs(teamMembers) do
		local slot: Frame = playerPrefab:Clone()
		local background: Frame = slot:FindFirstChild("Background")
		local avatar: ImageLabel = slot:FindFirstChild("S_Avatar", true)
		slot.Name = "TeamPlayer"
		slot.LayoutOrder = playerIndex
		slot.Size = UDim2.fromScale(1 / #teamMembers, slot.Size.Y.Scale)
		slot.Visible = true
		for _partIndex: number, part: string in ipairs({ "Main", "Stroke2", "Stroke" }) do
			background:FindFirstChild(part).Image = slot:GetAttribute(`Look_{side}{part}`)
		end
		background:FindFirstChild("Stroke").ImageColor3 = entry:GetAttribute("Color")
		Module.SetAvatar(avatar, entry)
		avatar.ImageColor3 = if entry:GetAttribute("Out") then _settings.OUT_AVATAR_COLOR else Color3.new(1, 1, 1)
		slot.Parent = list
	end
	playerPrefab:Destroy()

	--[[ Saving ]]

	panel.Name = "Team"
	panel.LayoutOrder = index
	panel.Size = UDim2.fromScale(#teamMembers * _settings.TEAM_PLAYER_WIDTH * fit, panel.Size.Y.Scale)
	panel.Visible = true
	panel.Parent = elems[side]
end

return Module
