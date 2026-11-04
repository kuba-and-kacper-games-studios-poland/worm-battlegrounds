--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui
local matchFolder: Folder
local wormsFolder: Instance

--[[ State ]]

-- The hint the player is on: Walk, Jump, Fire, BotTurn, Finish, then Done
local step: string = "Walk"

-- Whether the bot's turn has started since the player fired
local sawBotTurn: boolean = false

local tickConnection: RBXScriptConnection?

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

--- @class Tutorial_Client_MatchHints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.HINT_GUI_NAME]
	elems["Text"] = moduleGui:FindFirstChild("S_Text", true) --- @type TextLabel
	elems["Arrow"] = moduleGui:FindFirstChild("S_Arrow", true) --- @type ImageLabel
	matchFolder = I.Match.GetFolder()
	wormsFolder = I.Dirs.UmeWorkspace:WaitForChild("Worms")

	--[[ Connections ]]

	matchFolder:GetAttributeChangedSignal("Kind"):Connect(Module._checkKind)
	Module._checkKind()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check Kind

--[[
	Starts the hints once the match turns out to be the tutorial.
]]
function Module._checkKind()
	--[[ Checks ]]

	-- Check if this is the tutorial match, and the hints aren't running or over
	if matchFolder:GetAttribute("Kind") ~= _settings.MATCH_KIND or tickConnection or step == "Done" then
		return
	end

	--[[ Connections ]]

	elems["Arrow"].Visible = false
	tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Moves the hints on as the player does each thing (walks, jumps, fires, sits through the bot's turn, fires again),
	and shows the current one while it applies: the player's hints on their turn, the bot's hint on its turn.
]]
function Module._tick()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local myTurn: boolean = phase == "Turn" and I.Match.IsMyTurn()
	local myShot: boolean = phase == "Flight" and I.Match.IsMyTurn()
	local inMatch: boolean = I.S.Players.LocalPlayer:GetAttribute("InMatch") == true
	local worm: Instance? = wormsFolder:FindFirstChild(I.Match.GetMyParticipantId())
	local root: Instance? = worm and worm:FindFirstChild("Root")

	--[[ Stepping ]]

	if step == "Walk" and worm and (worm:GetAttribute("Stamina") or math.huge) < I.Settings["WormControl"].STAMINA_STUDS then
		step = "Jump"
	elseif step == "Jump" and root and root:IsA("BasePart") and root.AssemblyLinearVelocity.Y > _settings.JUMP_SPEED then
		step = "Fire"
	end
	if (step == "Walk" or step == "Jump" or step == "Fire") and myShot then
		step = "BotTurn"
	elseif step == "BotTurn" and phase == "Turn" and not myTurn then
		sawBotTurn = true
	elseif step == "BotTurn" and sawBotTurn and myTurn then
		step = "Finish"
	elseif step == "Finish" and myShot then
		step = "Done"
	end

	--[[ Applying ]]

	moduleGui.Enabled = inMatch and (if step == "BotTurn" then phase == "Turn" and not myTurn else myTurn and step ~= "Done")
	elems["Text"].Text = _settings.HINTS[step] or ""

	--[[ Finishing ]]

	if step == "Done" and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
	end
end

return Module
