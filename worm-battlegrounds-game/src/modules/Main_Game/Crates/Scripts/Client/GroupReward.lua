--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Panel = require(script.Parent:FindFirstChild("Panel")) --- @type Crates_Client_Panel

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: any }

--[[ General ]]

local moduleGui: ScreenGui
local cratesRep: Folder?

--[[ State ]]

--[[
	Whether the crates screen shows (the badge sits on it), whether a crate opens on it (the badge makes way), and
	whether the lobby's screens show (the tile sits there)
]]
local cratesOpen: boolean = false
local opening: boolean = false
local lobbyShown: boolean = false

-- The widget the dialog was opened over (the crates screen, from its badge), opened again when the dialog closes
local returnTo: string? = nil

-- The crate turning in the dialog, its turn so far, the twinkles round it, and the CLAIM pulse while it's lit
local crate: Model? = nil
local crateTurn: number = 0
local sparkles = nil --- @type UIEmitter_Instance?
local claimPulse: Tween? = nil

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

--- @class Crates_Client_GroupReward
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GROUP_GUI_NAME]
	elems["Button"] = moduleGui:FindFirstChild("U_Button") --- @type ImageButton
	elems["LobbyButton"] = moduleGui:FindFirstChild("U_LobbyButton") --- @type ImageButton
	elems["TileShine"] = elems["LobbyButton"]:FindFirstChild("S_TileShine", true) --- @type UIGradient
	elems["TileBob"] = elems["LobbyButton"]:FindFirstChild("S_TileBob", true) --- @type UIScale
	elems["DialogGui"] = I.UserInterface.UI[_settings.GROUP_DIALOG_GUI_NAME] --- @type ScreenGui
	elems["Dialog"] = elems["DialogGui"]:FindFirstChild("U_Dialog", true) --- @type Frame
	elems["Pop"] = elems["Dialog"]:FindFirstChild("S_Pop") --- @type UIScale
	elems["Rays"] = elems["Dialog"]:FindFirstChild("S_Rays", true) --- @type ImageLabel
	elems["CrateView"] = elems["Dialog"]:FindFirstChild("S_CrateView", true) --- @type ViewportFrame
	elems["Sparkles"] = elems["Dialog"]:FindFirstChild("S_Sparkles", true) --- @type Frame
	elems["Like"] = elems["Dialog"]:FindFirstChild("S_Like", true) --- @type ImageButton
	elems["LikePop"] = elems["Dialog"]:FindFirstChild("S_LikePop", true) --- @type UIScale
	elems["LikeDone"] = elems["Dialog"]:FindFirstChild("S_LikeDone", true) --- @type Frame
	elems["Join"] = elems["Dialog"]:FindFirstChild("S_Join", true) --- @type ImageButton
	elems["JoinTitle"] = elems["Dialog"]:FindFirstChild("S_JoinTitle", true) --- @type TextLabel
	elems["JoinDone"] = elems["Dialog"]:FindFirstChild("S_JoinDone", true) --- @type Frame
	elems["GroupIcon"] = elems["Dialog"]:FindFirstChild("S_GroupIcon", true) --- @type ImageLabel
	elems["ClaimButton"] = elems["Dialog"]:FindFirstChild("S_ClaimButton", true) --- @type ImageButton
	elems["ClaimText"] = elems["Dialog"]:FindFirstChild("S_ClaimText", true) --- @type TextLabel
	elems["ClaimShine"] = elems["Dialog"]:FindFirstChild("S_ClaimShine", true) --- @type UIGradient
	elems["ClaimPulse"] = elems["Dialog"]:FindFirstChild("S_ClaimPulse", true) --- @type UIScale
	elems["CloseButton"] = elems["Dialog"]:FindFirstChild("S_CloseButton", true) --- @type ImageButton

	--[[ Building ]]

	Module._buildCrate()
	elems["GroupIcon"].Image = `rbxthumb://type=GroupIcon&id={I.G_Group.GetId(_settings.GROUP_NAME)}&w=150&h=150`

	--[[ Connections ]]

	I.Interact.OnPress(elems["Button"], Module._openDialog)
	I.Interact.OnPress(elems["LobbyButton"], Module._openDialog)
	I.Interact.OnPress(elems["CloseButton"], Module._closeDialog)
	I.Interact.OnPress(elems["Like"], Module._onLike)
	I.Interact.OnPress(elems["Join"], function()
		I.Group.PromptJoin(_settings.GROUP_NAME)
		Module._refresh()
	end)
	I.Interact.OnPress(elems["ClaimButton"], Module._onClaim)
	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		Module._onWidget(widgetName, true)
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		Module._onWidget(widgetName, false)
	end)
	local lobbyGui: ScreenGui = I.UserInterface.UI["Lobby"]
	lobbyGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		lobbyShown = lobbyGui.Enabled
		Module._refresh()
	end)
	lobbyShown = lobbyGui.Enabled
	I.S.RunService.RenderStepped:Connect(Module._animate)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Crate

--[[
	Stands the group's crate (its 3D model) in a WorldModel in the dialog's viewport, so it can turn cheaply.
]]
function Module._buildCrate()
	--[[ Data ]]

	local row = I.G_Crates.GetAll()[_settings.GROUP_CRATE] --- @type Crates_CrateData
	local model: Model = I.Dirs.Assets:FindFirstChild("Crates"):FindFirstChild(row.Model):Clone()

	--[[ Building ]]

	local world: WorldModel = I.Create("WorldModel")({ Parent = elems["CrateView"] })
	local camera: Camera = I.Create("Camera")({ FieldOfView = 30, Parent = elems["CrateView"] })
	local box: CFrame
	local size: Vector3
	model:PivotTo(CFrame.new())
	model.Parent = world
	box, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(box.Position + Vector3.new(0, size.Y * 0.45, size.Magnitude * 2.2), box.Position)
	elems["CrateView"].CurrentCamera = camera

	--[[ Saving ]]

	crate = model
end

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the Crates folder (whether the group's crate was opened) and the player's membership of the group.
]]
function Module._connectReplicator()
	--[[ Data ]]

	cratesRep = I.Replicator.GetFolder(_localName)

	--[[ Connections ]]

	if cratesRep then
		cratesRep.AttributeChanged:Connect(Module._refresh)
	end
	local changed: RBXScriptSignal? = I.Group.GetChangedSignal(_settings.GROUP_NAME)
	if changed then
		changed:Connect(Module._refresh)
	end
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Opening

--[[
	A crate starts or stops opening on the crates screen (Reveal): the badge makes way for the opening and comes back
	with the shop.
]]
function Module.SetOpening(isOpening: boolean)
	--[[ Refreshing ]]

	opening = isOpening
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Widget

--[[
	Notes whether the crates screen shows, so the badge shows on it, and draws the dialog as WidgetManager opens and
	closes it.
]]
function Module._onWidget(widgetName: string, opened: boolean)
	--[[ Dialog ]]

	if widgetName == _settings.GROUP_DIALOG_GUI_NAME then
		if opened then
			Module._onDialogOpened()
		else
			Module._onDialogClosed()
		end
		return
	end

	--[[ Checks ]]

	-- Check if it's the crates screen
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Refreshing ]]

	cratesOpen = opened
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% Open Dialog

--[[
	Opens the dialog through WidgetManager (its blur and dim, and the lobby pieces it covers hidden by Lobby), noting
	the crates screen to go back to when it's opened from there.
]]
function Module._openDialog()
	--[[ Opening ]]

	returnTo = if cratesOpen then _settings.GUI_NAME else nil
	I.WidgetManager.Open(_settings.GROUP_DIALOG_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% Close Dialog

--[[
	Closes the dialog through WidgetManager.
]]
function Module._closeDialog()
	I.WidgetManager.Close(_settings.GROUP_DIALOG_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Dialog Opened

--[[
	Pops the dialog in as WidgetManager shows it, its twinkles rising round the crate.
]]
function Module._onDialogOpened()
	--[[ Showing ]]

	elems["Pop"].Scale = 0.6
	local Pop_TweenGoal = { Scale = 1 }
	local Pop_Tween: Tween = I.S.TweenService:Create(elems["Pop"], _settings.GROUP_POP_TWEENINFO, Pop_TweenGoal)
	Pop_Tween:Play()
	Module._getSparkles():Play()
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Dialog Closed

--[[
	Stops the twinkles once the dialog is gone, and opens the crates screen again when the dialog was opened from it
	and closed with nothing opening in its place; a message over the dialog (WidgetManager's utility widgets) hands the
	dialog back after, so it keeps the way back.
]]
function Module._onDialogClosed()
	--[[ Clearing ]]

	if sparkles then
		sparkles:Stop()
		sparkles:Clear()
	end

	--[[ Checks ]]

	-- Check if it goes back anywhere
	if not returnTo then
		return
	end

	--[[ Returning ]]

	task.defer(function()
		local current: ScreenGui? = I.WidgetManager.GetCurrent()

		-- Skip a message over the dialog: the dialog comes back after it
		if current and table.find(I.Settings["WidgetManager"].UTILITY_WIDGETS, current.Name) then
			return
		end

		local back: string? = returnTo
		returnTo = nil
		if back and not current then
			I.WidgetManager.Open(back)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the gui while the group's crate is unclaimed: the tile in the lobby, the badge on the crates screen; in the
	dialog, JOIN ticked by the player's membership, and CLAIM locked and grey until then, gold and pulsing after.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Check if the player's data has arrived (the Group module's arrives before it)
	if not cratesRep then
		return
	end

	--[[ Local Variables ]]

	local claimed: boolean = cratesRep:GetAttribute("GroupCrateClaimed") ~= false
	local member: boolean = I.Group.IsMember(_settings.GROUP_NAME) == true
	local claim: ImageButton = elems["ClaimButton"]

	--[[ Visibility ]]

	moduleGui.Enabled = (cratesOpen or lobbyShown) and not claimed
	elems["Button"].Visible = cratesOpen and not opening
	elems["LobbyButton"].Visible = lobbyShown and not cratesOpen

	-- A claimed crate's dialog has nothing left to offer
	if claimed then
		Module._closeDialog()
	end

	--[[ Join ]]

	elems["JoinDone"].Visible = member
	elems["JoinTitle"].Text = if member then "JOINED" else "JOIN"

	--[[ Claim ]]

	claim:FindFirstChild("Main", true).ImageColor3 = claim:GetAttribute(if member then "Look_MainColor" else "Look_LockedMainColor")
	claim:FindFirstChild("Stroke", true).ImageColor3 = claim:GetAttribute(if member then "Look_StrokeColor" else "Look_LockedStrokeColor")
	elems["ClaimText"].Text = if member then "CLAIM" else "🔒 CLAIM"
	elems["ClaimShine"].Enabled = member
	if member and not claimPulse then
		local Pulse_TweenGoal = { Scale = 1.05 }
		local Pulse_Tween: Tween = I.S.TweenService:Create(elems["ClaimPulse"], _settings.GROUP_PULSE_TWEENINFO, Pulse_TweenGoal)
		Pulse_Tween:Play()
		claimPulse = Pulse_Tween
	elseif not member and claimPulse then
		claimPulse:Cancel()
		claimPulse = nil
		elems["ClaimPulse"].Scale = 1
	end
end

--%%%%%%%%%%%%%%%%%%%% Animate

--[[
	Moves what shows each frame: the dialog's rays wheel and its crate turns while the dialog shows, and a light sweeps
	the lobby tile and a lit CLAIM every so often.
]]
function Module._animate(deltaTime: number)
	--[[ Checks ]]

	-- Check if the tile or the dialog shows
	if not moduleGui.Enabled and not elems["DialogGui"].Enabled then
		return
	end

	--[[ Local Variables ]]

	local cycle: number = _settings.GROUP_SHINE_SECONDS + _settings.GROUP_SHINE_PAUSE
	local sweep: number = (os.clock() % cycle) / _settings.GROUP_SHINE_SECONDS
	local offset: Vector2 = Vector2.new(if sweep <= 1 then sweep * 2 - 1 else 1, 0)

	--[[ Tile ]]

	if moduleGui.Enabled and elems["LobbyButton"].Visible then
		elems["TileShine"].Offset = offset
		elems["TileBob"].Scale = 1 + math.sin(os.clock() * 3) * 0.04
	end

	--[[ Dialog ]]

	if elems["DialogGui"].Enabled then
		elems["Rays"].Rotation = (elems["Rays"].Rotation + _settings.GROUP_RAYS_SPEED * deltaTime) % 360
		elems["ClaimShine"].Offset = offset
		if crate then
			crateTurn = (crateTurn + _settings.GROUP_CRATE_SPIN * deltaTime) % 360
			crate:PivotTo(CFrame.Angles(0, math.rad(crateTurn), 0) * CFrame.new(0, math.sin(os.clock() * 2) * 0.15, 0))
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Like

--[[
	LIKE: no game can check it, so it only ticks and pops the thumb.
]]
function Module._onLike()
	--[[ Applying ]]

	elems["LikeDone"].Visible = true
	elems["LikePop"].Scale = 1.4
	local Like_TweenGoal = { Scale = 1 }
	local Like_Tween: Tween = I.S.TweenService:Create(elems["LikePop"], _settings.GROUP_POP_TWEENINFO, Like_TweenGoal)
	Like_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% On Claim

--[[
	CLAIM: once the player is in the group, the crate shakes with the claim sound, the crates screen opens in the
	dialog's place and the crate opens there like a bought one; before that, a message asks them to join first.
]]
function Module._onClaim()
	--[[ Checks ]]

	-- Check if the player is in the group
	if I.Group.IsMember(_settings.GROUP_NAME) ~= true then
		I.WidgetManager.ShowMessage(_settings.GROUP_JOIN_FIRST)
		return
	end

	--[[ Shaking ]]

	I.Sound.Play({ Name = "Free_Claim", SoundGroup = "UI" })
	for step: number = 1, 6 do
		elems["CrateView"].Rotation = if step % 2 == 0 then 6 else -6
		task.wait(0.05)
	end
	elems["CrateView"].Rotation = 0

	--[[ Opening ]]

	-- The crates screen takes the dialog's place (WidgetManager closes it), wherever it was opened from
	returnTo = nil
	if not cratesOpen then
		I.WidgetManager.Open(_settings.GUI_NAME)
		for _try: number = 1, 30 do
			if cratesOpen then
				break
			end
			task.wait(0.05)
		end
	end
	Panel.ShowTab(_settings.GROUP_CRATE)
	Panel.Open(_settings.GROUP_CRATE, 1, "GroupReward")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Sparkles

--[[
	Returns the twinkles round the dialog's crate, made the first time (the crate screen's star picture).
]]
--- @return UIEmitter_Instance
function Module._getSparkles()
	--[[ Building ]]

	if not sparkles then
		sparkles = I.UIEmitter.new({
			Parent = elems["Sparkles"],
			Rate = _settings.GROUP_SPARKLE_RATE,
			Texture = _settings.FX_TEXTURES.Star,
			EmissionArea = Vector2.new(0.8, 0.8),
			SizeSpace = "Scale",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.07), NumberSequenceKeypoint.new(1, 0) }),
			Lifetime = NumberRange.new(0.8, 1.4),
			Velocity = 0,
			RotationSpeed = NumberRange.new(-90, 90),
			Color = Color3.fromRGB(255, 250, 200),
		})
	end

	--[[ Returning ]]

	return sparkles
end

return Module
