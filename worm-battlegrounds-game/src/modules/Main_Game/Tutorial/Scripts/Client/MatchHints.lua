--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Spotlight = require(script.Parent:FindFirstChild("Spotlight")) --- @type Tutorial_Client_Spotlight

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local matchFolder: Folder
local winGui: ScreenGui

--[[ State ]]

-- Whether this guide put the hint up, so it only takes down its own (the Studio map runs the lobby guide too)
local showing: boolean = false
local tickConnection: RBXScriptConnection?

-- Whether the win card opened for this match's end
local winOpened: boolean = false

-- The first turn's "Move here": the spot on the ground, where the snail stood when it showed, and whether it's done
local moveSpot: Vector3? = nil
local moveFrom: Vector3? = nil
local moveDone: boolean = false

-- END TUTORIAL on the top bar, shown only through the tutorial match
local endButton = nil --- @type TopBar_Button

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

	winGui = I.UserInterface.UI[_settings.WIN_GUI_NAME]
	elems["Fire"] = I.UserInterface.UI[_settings.MATCH_HUD_GUI_NAME]:FindFirstChild("U_Fire", true) --- @type ImageButton
	elems["WinTitle"] = winGui:FindFirstChild("S_Title", true) --- @type TextLabel
	elems["Continue"] = winGui:FindFirstChild("S_Continue", true) --- @type ImageButton
	matchFolder = I.Match.GetFolder()

	--[[ End Tutorial ]]

	-- In Leave game's place on the top bar (after Settings and the music button)
	endButton = I.TopBar.AddButton("Left")
	endButton:SetLayoutOrder(3)
	endButton:SetIcon(_settings.END_ICON)
	endButton:SetText(_settings.END_TEXT)
	endButton:SetCallback(Module._askEnd)

	--[[ Connections ]]

	I.Interact.OnPress(elems["Continue"], Module._continue)
	matchFolder:GetAttributeChangedSignal("Kind"):Connect(Module._checkKind)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._checkKind)
	Module._checkKind()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check Kind

--[[
	Starts the guide and shows END TUTORIAL while the player is in the tutorial match, and stops both (closing the win
	card) once they aren't.
]]
function Module._checkKind()
	--[[ Local Variables ]]

	local tutorial: boolean = matchFolder:GetAttribute("Kind") == _settings.MATCH_KIND and I.S.Players.LocalPlayer:GetAttribute("InMatch") == true

	--[[ Applying ]]

	endButton.Instance.Visible = tutorial

	--[[ Connections ]]

	if tutorial and not tickConnection then
		winOpened = false
		moveSpot = nil
		moveFrom = nil
		moveDone = false
		tickConnection = I.S.RunService.Heartbeat:Connect(Module._tick)
	elseif not tutorial and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
		Module._hide()
		if I.WidgetManager.GetCurrent() == winGui then
			I.WidgetManager.Close(_settings.WIN_GUI_NAME)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Shows the step the match is at (the owner, 2026-11-24: "click to land - then aiming, click Fire"): the lit spot to
	land on; on the player's first turn "Move here" at a spot on the ground with how to walk under it (2026-11-25), then
	on their turns "Drag to aim" under their snail until they've dragged, then the arrow on FIRE; nothing on the bot's
	turns; and once the match ends, the win card with the arrow pointing up at CONTINUE.
]]
function Module._tick()
	--[[ Local Variables ]]

	local phase: string = I.Match.GetPhase()
	local mine: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	local snail: Model? = I.Snails.GetMine()

	--[[ Checks ]]

	-- Check if the player has a snail in the match
	if not mine then
		Module._hide()
		return
	end

	-- Check if another window covers the match (END TUTORIAL's question, Settings): the guide waits under it
	local current: ScreenGui? = I.WidgetManager.GetCurrent()
	if current and current ~= winGui then
		Module._hide()
		return
	end

	--[[ Showing ]]

	-- The match is over once the win card shows: CONTINUE goes on to the equip step
	endButton.Instance.Visible = phase ~= "Ended"
	if phase == "Drop" and not mine:GetAttribute("Placed") then
		-- From under the spot: the player's drop pin hangs over it
		Module._show(Module._getHint("Drop"), Vector3.new(mine:GetAttribute("DropX") or 0, mine:GetAttribute("DropY") or 0, 0), "Drop", "Below")
	elseif phase == "Turn" and I.Match.IsMyTurn() and snail and snail.PrimaryPart then
		if Module._needsMove(snail) then
			-- From under the ring, so the tip has room below the hint
			Module._show(Module._getHint("Move"), moveSpot, "Move", "Below", Module._getMoveTip())
		elseif not I.MatchHud.HasAimedThisTurn() then
			Module._show(Module._getHint("Aim"), snail.PrimaryPart, "Aim", "Alone")
		elseif elems["Fire"].Visible then
			Module._show(Module._getHint("Fire"), elems["Fire"], "Fire")
		else
			Module._hide()
		end
	elseif phase == "Ended" then
		Module._openWin(snail ~= nil and snail:GetAttribute("Alive") == true)
		Module._show("", elems["Continue"], "Won", "Below")
	else
		Module._hide()
	end
end

--%%%%%%%%%%%%%%%%%%%% Open Win

--[[
	Opens the win card once as the tutorial match ends (in place of the results): "You won!" with the win fanfare, or
	"Nice try!" when the player's snail went out, and CONTINUE.
]]
function Module._openWin(won: boolean)
	--[[ Checks ]]

	-- Check if the card is already open for this match
	if winOpened then
		return
	end

	--[[ Opening ]]

	winOpened = true
	elems["WinTitle"].Text = if won then _settings.WIN_TITLE else _settings.LOST_TITLE
	I.WidgetManager.Open(_settings.WIN_GUI_NAME)
	if won then
		I.Sound.Play({ Name = "Match_Win", SoundGroup = "SFX" })
	end
end

--%%%%%%%%%%%%%%%%%%%% Continue

--[[
	CONTINUE on the win card: back to the lobby, where the guide picks up.
]]
function Module._continue()
	--[[ Sending ]]

	I.Network.Fire("Match_Leave")
end

--%%%%%%%%%%%%%%%%%%%% Ask End

--[[
	END TUTORIAL: asks first, since a thumb dragging the aim can catch the top bar.
]]
function Module._askEnd()
	--[[ Asking ]]

	I.WidgetManager.ShowConfirmation(_settings.END_QUESTION, Module._end)
end

--%%%%%%%%%%%%%%%%%%%% End

--[[
	Ends the whole tutorial (the server pays its diamonds and gives the starter weapons), then goes back to the lobby.
]]
function Module._end()
	--[[ Sending ]]

	I.Network.Fire("Tutorial_End")
	I.Network.Fire("Match_Leave")
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a step through the guide (reporting it for the funnel), with its tip under it when it has one, and remembers
	this guide put it up.
]]
function Module._show(text: string, target: GuiObject | BasePart | Vector3, step: string, place: ("Below" | "Left" | "Alone")?, tip: string?)
	--[[ Applying ]]

	showing = true
	Spotlight.Show(text, target, step, place, tip)
end

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	Takes the guide down if this guide put it up, leaving the lobby guide's alone.
]]
function Module._hide()
	--[[ Checks ]]

	-- Check if this guide is showing
	if not showing then
		return
	end

	--[[ Applying ]]

	showing = false
	Spotlight.Hide()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Needs Move

--[[
	Returns whether "Move here" still shows: on the player's first turn, until the snail reaches the spot (MOVE_REACH)
	or walks MOVE_DONE_DISTANCE any way, or the player aims; skipped when no flat ground is near.
]]
--- @return boolean
function Module._needsMove(snail: Model)
	--[[ Checks ]]

	-- Check if the step is done
	if moveDone then
		return false
	end

	--[[ Local Variables ]]

	local position: Vector3 = snail.PrimaryPart.Position

	-- The spot is picked when it first shows, from where the snail stands then
	if not moveFrom then
		moveFrom = position
		moveSpot = Module._getMoveSpot(snail)
	end

	--[[ Finishing ]]

	local reached: boolean = moveSpot ~= nil and math.abs(position.X - moveSpot.X) <= _settings.MOVE_REACH
	local walked: boolean = moveFrom ~= nil and math.abs(position.X - moveFrom.X) >= _settings.MOVE_DONE_DISTANCE
	if not moveSpot or reached or walked or I.MatchHud.HasAimedThisTurn() then
		moveDone = true
	end

	--[[ Returning ]]

	return not moveDone
end

--%%%%%%%%%%%%%%%%%%%% Get Move Spot

--[[
	Returns a spot on flat ground MOVE_DISTANCE studs from the snail toward the bot (else the other way, else
	MOVE_SHORT_DISTANCE), at most MOVE_STEP studs above or below its feet, on the arena's plane; nil with none.
]]
--- @return Vector3?
function Module._getMoveSpot(snail: Model)
	--[[ Local Variables ]]

	local position: Vector3 = snail.PrimaryPart.Position
	local feet: number = position.Y - I.Settings["Snails"].ROOT_SIZE / 2
	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { I.Dirs.UmeWorkspace:FindFirstChild("Arena") }

	-- Toward the nearest other snail first, so the walk leads into the fight
	local toward: number = 1
	local nearest: number = math.huge
	for _index: number, other: Instance in ipairs(I.Dirs.UmeWorkspace:FindFirstChild("Snails"):GetChildren()) do
		if other ~= snail and other:IsA("Model") and other.PrimaryPart and math.abs(other.PrimaryPart.Position.X - position.X) < nearest then
			nearest = math.abs(other.PrimaryPart.Position.X - position.X)
			toward = if other.PrimaryPart.Position.X < position.X then -1 else 1
		end
	end

	--[[ Searching ]]

	for _index: number, distance: number in ipairs({ _settings.MOVE_DISTANCE, _settings.MOVE_SHORT_DISTANCE }) do
		for _sideIndex: number, side: number in ipairs({ toward, -toward }) do
			local origin: Vector3 = Vector3.new(position.X + side * distance, feet + _settings.MOVE_STEP + 1, 0)
			local hit: RaycastResult? = I.S.Workspace:Raycast(origin, Vector3.new(0, -(_settings.MOVE_STEP * 2 + 1), 0), params)
			if hit and hit.Normal.Y > 0.7 then
				-- Ringed where the snail would stand there (its middle), not half in the ground
				return Vector3.new(hit.Position.X, hit.Position.Y + I.Settings["Snails"].ROOT_SIZE / 2, 0)
			end
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Move Tip

--[[
	Returns how to walk on the player's device (MOVE_TIPS), the pad's stick named by the Console module.
]]
--- @return string
function Module._getMoveTip()
	--[[ Local Variables ]]

	local tip: string = _settings.MOVE_TIPS[I.Platform.Current] or _settings.MOVE_TIPS.Desktop

	--[[ Returning ]]

	return (string.gsub(tip, "{(%w+)}", I.Console.GetButtonName))
end

--%%%%%%%%%%%%%%%%%%%% Get Hint

--[[
	Returns what a step's hint says for the player's device: on a pad its PAD_HINTS text, with each {Action} named for
	the pad by the Console module; on a touch screen its TOUCH_HINTS text; else its HINTS text.
]]
--- @return string
function Module._getHint(stepName: string)
	--[[ Returning ]]

	if I.Platform.Current == "Console" and _settings.PAD_HINTS[stepName] then
		return (string.gsub(_settings.PAD_HINTS[stepName], "{(%w+)}", I.Console.GetButtonName))
	end
	if I.Platform.Current == "Mobile" and _settings.TOUCH_HINTS[stepName] then
		return _settings.TOUCH_HINTS[stepName]
	end
	return _settings.HINTS[stepName] or ""
end

return Module
