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

-- Whether the player closed the knocked-out panel to watch
local spectating: boolean = false

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

--- @class MatchHud_Client_Panels
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Waiting"] = gui:FindFirstChild("U_Waiting") --- @type Frame
	elems["Count"] = elems["Waiting"]:FindFirstChild("S_Count", true) --- @type TextLabel
	elems["Drop"] = gui:FindFirstChild("U_Drop") --- @type Frame
	elems["DropTimer"] = elems["Drop"]:FindFirstChild("S_Timer", true) --- @type TextLabel
	elems["KnockedOut"] = gui:FindFirstChild("U_KnockedOut") --- @type Frame
	elems["Spectate"] = elems["KnockedOut"]:FindFirstChild("S_Spectate", true):FindFirstChild("Button") --- @type ImageButton
	elems["Leave"] = elems["KnockedOut"]:FindFirstChild("S_Leave", true):FindFirstChild("Button") --- @type ImageButton
	elems["LoadoutBar"] = gui:FindFirstChild("U_LoadoutBar") --- @type Frame
	elems["EmoteButton"] = gui:FindFirstChild("U_EmoteButton") --- @type Frame

	--[[ Connections ]]

	local participants: Folder = I.Match.GetFolder():WaitForChild("Participants")
	matchFolder = I.Match.GetFolder()
	matchFolder.AttributeChanged:Connect(Module._refresh)
	participants.ChildAdded:Connect(Module._watchEntry)
	for _index: number, entry: Instance in ipairs(participants:GetChildren()) do
		Module._watchEntry(entry)
	end
	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.Interact.OnPress(elems["Spectate"], Module._spectate)
	I.Interact.OnPress(elems["Leave"], Module._leave)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Watch Entry

--[[
	Refreshes the panels when a participant's entry appears or changes (when the player's snail goes out).
]]
function Module._watchEntry(entry: Instance)
	--[[ Connections ]]

	entry.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	A new match (its Waiting or Drop phase) brings the knocked-out panel back for the next knockout.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Saving ]]

	if phase == "Waiting" or phase == "Drop" then
		spectating = false
	end

	--[[ Refreshing ]]

	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows each phase's panel: who has arrived while waiting, the drop timer, the knocked-out panel once the player's
	snail is out, and the loadout bar while the player's snail is in play.
]]
function Module._refresh()
	--[[ Data ]]

	local phase: string = I.Match.GetPhase()
	local entry: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	local out: boolean = entry ~= nil and entry:GetAttribute("Out") == true

	--[[ Visibility ]]

	elems["Waiting"].Visible = phase == "Waiting"
	elems["Drop"].Visible = phase == "Drop"
	elems["KnockedOut"].Visible = out and not spectating and phase ~= "Ended"
	elems["LoadoutBar"].Visible = entry ~= nil and not out and (phase == "Turn" or phase == "Flight" or phase == "Settle" or phase == "Landing")
	elems["EmoteButton"].Visible = elems["LoadoutBar"].Visible

	--[[ Texts ]]

	elems["Count"].Text = `{matchFolder:GetAttribute("Arrived") or 0} / {matchFolder:GetAttribute("Expected") or 0}`

	--[[ Ticking ]]

	if elems["Drop"].Visible and not tickConnection then
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	elseif not elems["Drop"].Visible and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts the drop phase's seconds down.
]]
function Module._tick()
	--[[ Local Variables ]]

	local endsAt: number = matchFolder:GetAttribute("DropEndsAt") or 0

	--[[ Applying ]]

	elems["DropTimer"].Text = tostring(math.max(math.ceil(endsAt - I.S.Workspace:GetServerTimeNow()), 0))
end

--%%%%%%%%%%%%%%%%%%%% Spectate

--[[
	Closes the knocked-out panel; the camera keeps following the match.
]]
function Module._spectate()
	--[[ Saving ]]

	spectating = true

	--[[ Refreshing ]]

	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Leave

--[[
	Asks the server to take the player back to the lobby.
]]
function Module._leave()
	--[[ Sending ]]

	I.Network.Fire("Match_Leave")
end

return Module
